/// ===============================================================================
/// oGHOST - BASE GHOST OBJECT - CREATE EVENT
/// ===============================================================================
/// Purpose: Initialize all shared ghost variables and state
/// Parent: N/A (Base class)
/// Children: Blinky, Pinky, Inky, Clyde
///
/// This object contains ALL shared initialization logic that every ghost needs.
/// Child ghosts override only their unique properties:
/// - Ghost name and personality
/// - Starting position (xstart, ystart)
/// - Scatter corner (cornerx, cornery)
/// - Speed thresholds (elroydots, elroydots2)
///
/// Child ghosts call event_inherited() to use this code.
/// ===============================================================================

// ===== IDENTIFICATION & NAMING =====
/// Ghost identifier used for debugging and personality-based logic
/// Each ghost instance sets this to their name:
/// - "Blinky": Red, direct chaser (fearless leader)
/// - "Pinky": Pink, ambush predator (anticipates 4 ahead)
/// - "Inky": Cyan, geometric ambusher (double vector algorithm)
/// - "Clyde": Orange, ambiguous pursuer (distance-based personality)

ghost_name = "";  // Set by child object in their Create_0 BEFORE event_inherited()

// ===== ANIMATION STATE VARIABLES =====
/// Frame counter for sprite animation (0-15 continuous cycle)
/// This variable controls sprite frame progression manually
/// Incremented each frame in BEGIN_STEP: im = (im + 1) % 16
/// Range: 0-15 (16 frames per cycle, resets to 0 after 15)

im = 0;  // Animation frame index

/// Power pellet flashing effect counter (frightened mode only)
/// Controls the white flashing visual warning near end of power pellet
/// Cycles 0-29 continuously when state == FRIGHTENED
/// Used to create flashing effect (visible/invisible alternation)
/// When flash < 15: ghost visible
/// When flash >= 15: ghost invisible (flashing warning)

flash = 0;  // Flashing counter

/// Elroy mode speed indicator (0=normal, 1=fast, 2=fastest)
/// Tracks which Elroy speed mode ghost is currently in
/// Set based on remaining dot count (aggressive hunting when dots low)
/// - 0: Normal speed (plenty of dots remain)
/// - 1: Elroy mode 1 (dots below first threshold)
/// - 2: Elroy mode 2 (dots below second threshold)
/// Used by Draw event to show visual indicator (red eyes)

elroy = 0;  // Elroy mode (0-2)

// ===== POSITION TRACKING (16-PIXEL GRID ALIGNED) =====
/// Grid-aligned X position (snapped to 16-pixel cells)
/// This is calculated from actual x position each frame
/// Updated each frame: tilex = 16 * round(x / 16)
/// Used by pathfinding to determine which grid cell ghost is in
/// Range: Multiples of 16 (0, 16, 32, 48, ... 432, 448)

tilex = 0;  // Current tile X (grid coordinate)

/// Grid-aligned Y position (snapped to 16-pixel cells)
/// This is calculated from actual y position each frame
/// Updated each frame: tiley = 16 * round(y / 16)
/// Used by pathfinding to check valid directions at intersections
/// Range: Multiples of 16 (0, 16, 32, 48, ...)

tiley = 0;  // Current tile Y (grid coordinate)

/// Starting/respawn position X (pixel coordinate, not grid)
/// Set by child ghost object based on its personality
/// Used to reset ghost position when eaten (returns to house)
/// Typical values: 216 (Blinky), etc.

xstart = 0;  // Spawn point X

/// Starting/respawn position Y (pixel coordinate, not grid)
/// Set by child ghost object based on its personality
/// Used to reset ghost position when eaten (returns to house)
/// Typical value: 224 (standard ghost house entrance Y)

ystart = 0;  // Spawn point Y

// ===== PATHFINDING & TARGET TRACKING =====
/// Target X coordinate for current chase/behavior
/// Calculated in Step_1 event based on ghost personality and state
/// Used by pathfinding (chase_object script) to determine best direction
/// Set to different values based on state:
/// - CHASE: Pac's position (or variation for personality)
/// - FRIGHTENED: Not used (random movement)
/// - EYES: House entrance (216)

pursuex = 0;  // Pursuit target X

/// Target Y coordinate for current chase/behavior
/// Calculated in Step_1 event based on ghost personality and state
/// Used by pathfinding (chase_object script) to determine best direction
/// Set to different values based on state:
/// - CHASE: Pac's Y (or variation for personality)
/// - FRIGHTENED: Not used (random movement)
/// - EYES: House entrance (240)

pursuey = 0;  // Pursuit target Y

/// House containment status flag
/// Determines if ghost is in house or free in maze
/// - 0: FREE - Ghost roaming the maze, normal behavior
/// - 1: IN_HOUSE - Ghost inside ghost house, exiting sequence
/// When eaten (state=EYES), ghost eyes return to house
/// Then house=1, housestate handles exit bounce sequence

house = 0;  // House containment (0=free, 1=in_house)

/// House state machine progress tracker
/// Sub-state within the IN_HOUSE state, varies by ghost type
/// Controls the bounce-down and bounce-up exit sequence
/// Different ghosts may have different house sequences
/// Blinky: 0=entering, 1=bouncing down, 2=bouncing up, 3=exiting
/// Pinky: Similar with dot-counting phase
/// Inky/Clyde: More complex sequences (0-4)

housestate = 0;  // House state machine (sub-state)

/// New tile intersection flag for pathfinding decision
/// Triggers ONCE when ghost reaches a new 16x16 grid cell
/// Controls when pathfinding/turning decisions are made
/// - 0: Not at intersection, continue moving straight
/// - 1: Just reached intersection, make turning decision
/// Set to 1 when tilex/tiley changes, set to 0 after decision

newtile = 0;  // Intersection flag (0=moving, 1=reached tile)

/// About-face/reverse direction flag for power pellet
/// When Pac eats power pellet, ghosts should reverse direction immediately
/// Rather than making a new decision, they 180° flip
/// - 0: Normal behavior, use pathfinding decision
/// - 1: REVERSE! Flip to opposite direction

aboutface = 0;  // Reversal flag (0=normal, 1=reverse)

// ===== AI STATE MACHINE =====
/// Current ghost behavioral state (uses GHOST_STATE enum)
/// - GHOST_STATE.CHASE = 0: Normal pursuit mode
/// - GHOST_STATE.FRIGHTENED = 1: Power pellet active, vulnerable
/// - GHOST_STATE.EYES = 2: Ghost eaten, eyes returning to house
/// - GHOST_STATE.IN_HOUSE = 3: Inside ghost house, bouncing
state = GHOST_STATE.IN_HOUSE;

// ===== ELROY MODE (Faster pursuit when dots are low) =====
/// Dot count threshold for Elroy mode 1 (first speed increase)
/// When oPacman.oPacman.dotcount <= this value, ghost becomes faster
/// Set by child object (Blinky uses 244)
elroydots = 244;

/// Dot count threshold for Elroy mode 2 (maximum speed)
/// When oPacman.oPacman.dotcount <= this value, ghost is at maximum speed
/// Set by child object
elroydots2 = 0;

// ===== SCATTER MODE =====
/// Scatter corner X coordinate (where ghost runs when not chasing)
/// Set by child object (varies by personality)
cornerx = 0;

/// Scatter corner Y coordinate
/// Set by child object (varies by personality)
cornery = 0;

// ===== DIRECTION TRACKING =====
/// GML built-in physics variable: direction (degrees) + speed → motion.
/// Values: 0°=RIGHT, 90°=UP, 180°=LEFT, 270°=DOWN.
/// Kept in degrees ONLY because GML physics requires it.
/// Derived from dir_applied at one conversion point in Step_2 — do not
/// read this variable directly for AI logic; use dir / dir_applied instead.

direction = 0;  // GML physics direction in degrees (RIGHT = 0°)

/// Desired GRID_DIRECTION chosen by pathfinding each intersection.
/// Set by chase_object / random_direction. May differ from dir_applied
/// when a requested turn hasn't been applied yet.

dir = GRID_DIRECTION.RIGHT;  // Desired direction (GRID_DIRECTION)

/// Last actually-applied GRID_DIRECTION — the direction the ghost is
/// physically moving right now. Updated by ghost_apply_grid_turn in Step_2.
/// Used by about-face logic so the reversal is based on actual movement.

dir_applied = GRID_DIRECTION.RIGHT;

/// Reverse/opposite direction (for reversal logic)
/// Value = direction_opposite(dir)

resdir = GRID_DIRECTION.LEFT;  // Opposite direction

// ===== SPEED CONFIGURATION VARIABLES =====
/// Normal pursuit speed (pixels per frame)
/// Used in CHASE mode when not in tunnel and no Elroy
/// Adjusted per level (varies from 1.8 to 2.0)
/// Standard value: 1.875 pixels/frame

sp = SPEED_NORMAL;

/// Tunnel/slow area speed (pixels per frame)
spslow = SPEED_TUNNEL;

/// Frightened mode speed (pixels per frame)
spfright = SPEED_FRIGHTENED;

/// Elroy mode 1 speed (pixels per frame)
spelroy = SPEED_ELROY;

/// Elroy mode 2 speed (pixels per frame)
spelroy2 = SPEED_ELROY2;

/// Eyes return speed (pixels per frame)
speyes = SPEED_EYES;

// ===== DRAW/RENDER VARIABLES =====
/// Base draw color for ghost sprite
/// Tinted by Draw event based on ghost type and state
/// Child objects set their own ghost color (red, pink, cyan, orange)
/// Overridden during frightened mode to blue/white flashing

draw_color = c_white;  // Base color (overridden by child ghosts)

// ===== SPRITE ANIMATION VARIABLES =====
/// Current sprite frame index (GML built-in)
/// Set to 0 at start, incremented by animation system
/// Not used for ghost animation (im variable handles it)
/// Keep at 0 to avoid confusion with manual im control

image_index = 0;  // Sprite frame (unused, we use im instead)

/// Sprite animation speed setting (GML built-in)
/// Set to 0 to DISABLE automatic animation
/// Allows manual control via im variable
/// If set to > 0, GML auto-increments image_index (conflicts with im)

image_speed = 0;  // DISABLED - we control animation manually

// ===== PHYSICS SYSTEM VARIABLES =====
/// Horizontal velocity (pixels per frame)
/// Set based on current direction and speed
/// Positive = rightward, Negative = leftward
/// Updated each frame based on direction/speed values

hspeed = 0;  // Horizontal velocity

/// Vertical velocity (pixels per frame)
/// Set based on current direction and speed
/// Positive = downward, Negative = upward
/// Updated each frame based on direction/speed values

vspeed = 0;  // Vertical velocity

// ===== ELROY DISPLAY VARIABLE =====
/// Visual indicator for debug/tuning (rarely used)
/// Could display Elroy state in debug output
/// Currently unused in main implementation

elroy_display = 0;  // Debug indicator

// ===== INITIALIZATION COMPLETE =====
/// At this point, basic variables are initialized
/// Child ghost objects now call event_inherited() to execute this code
/// After event_inherited(), child sets its unique properties

/// ═══════════════════════════════════════════════════════════════════════════════
/// CRITICAL: How Child Ghosts Use This Create_0 Event
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Child ghost objects (Blinky, Pinky, Inky, Clyde) follow this pattern:
///
/// EXAMPLE - Blinky's Create_0.gml:
/// ───────────────────────────────────
/// /// Set Blinky-specific properties BEFORE inheriting base initialization
/// ghost_name = "Blinky";           // Unique identifier
/// xstart = 216;                    // Spawn position X
/// ystart = 224;                    // Spawn position Y
/// cornerx = 32;                    // Scatter corner (top-left)
/// cornery = 32;
/// elroydots = 244;                 // Elroy threshold 1 (dots remaining)
/// elroydots2 = 0;                  // Elroy threshold 2 (disabled for Blinky)
///
/// event_inherited();               // Call THIS Create_0 to init all base variables
///
/// /// Optional: Set Blinky-specific overrides AFTER inheritance
/// draw_color = c_red;              // Blinky's color
///
///
/// EXAMPLE - Pinky's Create_0.gml:
/// ────────────────────────────────
/// ghost_name = "Pinky";
/// xstart = 208;                    // Slightly left of center
/// ystart = 240;                    // In front house
/// cornerx = 400;                   // Scatter corner (top-right)
/// cornery = 32;
/// elroydots = 240;
/// elroydots2 = 0;
///
/// event_inherited();               // Initialize base
///
/// draw_color = c_fuchsia;          // Pinky's color (magenta)
///
///
/// KEY DESIGN NOTES:
/// ─────────────────
/// 1. Child sets properties BEFORE event_inherited()
///    → Ensures base initialization uses child's custom values
///
/// 2. Child can override properties AFTER event_inherited()
///    → Can customize colors, or other visual elements
///
/// 3. Each ghost instance has UNIQUE spawn position
///    → xstart/ystart positions them differently in house
///
/// 4. Scatter corners are DIFFERENT for each personality
///    → Blinky: Top-left (32, 32) - defensive
///    → Pinky: Top-right (400, 32) - offensive
///    → Inky: Bottom-right (closest to Pac start)
///    → Clyde: Bottom-left (far from Pac start)
///
/// ═══════════════════════════════════════════════════════════════════════════════

/// ===============================================================================
/// END oGHOST CREATE EVENT
/// ===============================================================================
