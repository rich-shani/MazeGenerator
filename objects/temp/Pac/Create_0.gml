/// ===============================================================================
/// PAC-MAN OBJECT - CREATE EVENT (INITIALIZATION)
/// ===============================================================================
/// Purpose: Initialize all variables for Pac-Man character (Player 1 - main player)
/// This is the foundation for Player 1 gameplay mechanics
///
/// Features:
/// - Single-player support
/// - Movement with corner mechanics for smooth turns
/// - Power pellet (fright) mode with ghost eating
/// - Dot and fruit collection
/// - Death/life system
/// - Animation and collision handling
/// - Dynamic difficulty (Elroy thresholds)
/// - Siren audio management
///
/// Variables are organized into logical sections with clear purposes
/// ===============================================================================

// ===== MOVEMENT DIRECTION VARIABLES (PLAYER 1) =====
/// Target direction input variables (0=right, 1=up, 2=left, 3=down)
/// Used to detect keyboard input and set desired direction
xdir = 0;   // Horizontal direction component
ydir = 0;   // Vertical direction component
dir = 0;    // Cardinal direction (0-3, used for pathfinding)

/// Movement speeds for Player 1
/// Used to apply actual velocity each frame
/// Note: sp and spfright are managed by oGameManager

// ===== EATING ANIMATION VARIABLES =====
/// Direction Pac was eating in (used for eating animation)
/// Converted from direction angle to 8-way direction
/// -1 = not eating, 0-7 = eating in that direction

// ===== CHOMPING (GHOST EATING) VARIABLES =====
/// Current ghost eating state (0=not eating, 1=eating)
/// Set when Pac collides with frightened ghost
/// Triggers eating animation and freezes ghost movement
chomp = 0;

// ===== GHOST RELEASE TIMING =====
/// Ghost release timer (counts down from timerstart)
/// When reaches 0, next ghost exits house
timer = 0;

/// Timer start value (set per level)
timerstart = 240;

/// Ghost release signatures (dot count thresholds)
/// When Pac.dotcount reaches these values, ghosts are released
psig = 0;  /// Pinky release signature
isig = 0;  /// Inky release signature
csig = 0;  /// Clyde release signature

// ===== MOVEMENT PAUSE/SUSPENSION VARIABLES =====
/// Player 1 movement pause counter
/// Counts down each frame during pause states
/// 0 = not paused, >0 = paused (moving/eating blocked)
pause = 0;

/// Player 1 suspension state during dot/fruit collection
/// Set when eating dot/fruit to freeze movement briefly
/// Creates brief pause effect before continuing movement
stoppy = 0;

// ===== PLUS MODE VARIABLES =====
/// Plus mode bonus multiplier state
/// Affects score multipliers and ghost behavior during fright
/// 0 = normal mode, values 1-7 = different bonus configuration
plus = 0;

// ===== CORNER/TURN TRANSITION VARIABLES =====
/// Player 1 corner transition state (using PAC_CORNER enum)
/// NONE (0): Not in corner transition
/// Values 1-8: Smooth turn in progress (pre/post alignment states)
/// Used to smoothly turn Pac when input occurs mid-movement
corner = PAC_CORNER.NONE;

// ===== DEATH/GAME STATE VARIABLES =====
/// Current Pac state (using PAC_STATE enum)
/// ALIVE (0): Playing normally
/// DYING (1): Death animation in progress
/// DEAD (2): Waiting to respawn or end level
/// DEAD_FINAL (3): Final life lost, game over state
dead = PAC_STATE.ALIVE;

/// Flag indicating Pac is actively dying (death animation)
/// Set when collision with ghost detected
/// Used to trigger death sequence and sound effects
deader = 0;

// ===== COLLISION VARIABLES =====
/// Collision flag (currently unused)
bonked = 0;

// ===== BUFFERED DIRECTION VARIABLES =====
/// Buffered direction input for Player 1 (cardinal format)
/// Stores direction when player presses arrow key between intersections
/// Applied when Pac reaches next intersection for smooth turning
/// Range: 0-3 (using PAC_DIRECTION enum), -1 = no input buffered
park = 0;

/// Current facing direction in degrees for Player 1
/// Range: 0, 90, 180, 270 (representing 4 cardinal directions)
/// Updated each frame based on movement velocity
/// Used for sprite rotation and animation direction
direction = 0;

// ===== VISUAL/ANIMATION VARIABLES =====
/// Blink animation counter during level intermission
/// Creates pulsing visual effect between levels
/// Increments each frame and resets at threshold
blink = 0;

/// Animation frame index for Pac sprite (0-7 for mouth animation)
/// Cycles through sprite frames to show opening/closing mouth
/// Makes Pac appear to be "eating" as he moves
im2 = 0;

/// Backup animation index (used in specific animation sequences)
i2m = 0;

/// Secondary animation index (used for alternating animations)
i2m2 = 0;

/// Death animation frame counter
/// Animates Pac dissolving when eaten by ghost
/// Ranges from 0 to completion (typically 11-12 frames)
deadani2m = 0;

/// Sprite scaling factor for visual effects
/// 1.0 = normal size, can increase/decrease for zoom effects
/// Used sparingly for visual polish
scale = 1;

// Note: Game mode variables (Pac.plus, Pac.prohibit, scatter, cycle)
// are now managed by oGameManager

// ===== TILE TRACKING VARIABLES =====
/// Tile-aligned X coordinate for Player 1 (grid position, not pixel)
/// Snapped to 16-pixel grid for collision and pathfinding
/// Updated based on actual pixel position each frame
tilex = 0;

/// Tile-aligned Y coordinate for Player 1
/// Used with tilex for grid-based collision detection
tiley = 0;

/// Level completion flag
/// 0 = Level in progress (dots still available)
/// 1 = All dots collected, level finished
finish = 0;

/// Total dots collected this level
dotcount = 0;

/// Countdown timer (for death/respawn sequences)
countdown  = 0;

// ===== GHOST AI CYCLE MANAGEMENT =====
/// Scatter mode active flag
/// 0 = Chase mode (ghosts hunt Pac)
/// 1 = Scatter mode (ghosts flee to corners)
scatter = 0;

/// Game cycle counter
/// Tracks which phase of level cycle is active
/// Used with scatter/chase mode timing
cycle = 0;

/// Scatter/Chase timing configuration (set per level in Other_4)
/// These define how long ghosts stay in each mode
scatter1 = 7;
chase1 = 20;
scatter2 = 7;
chase2 = 20;
scatter3 = 5;
chase3 = 20;
scatter4 = 5;

// ===== FRIGHT MODE (POWER PELLET) VARIABLES =====
/// Current fright mode state (using PAC_FRIGHT enum)
/// OFF (0): Normal mode, ghosts are dangerous
/// ACTIVE (1): Power pellet active, ghosts vulnerable
fright = PAC_FRIGHT.OFF;

/// Duration of fright mode in frames (set per level)
/// Set when power pellet collected, counts down to 0
frighttime = 0;

/// Bonus time duration for extended fright mode
/// When bonus fruit eaten during fright, extends fright timer
bonustime = 0;

/// Count of consecutive ghosts eaten in current fright period
/// Resets to 0 when fright mode ends
/// Used to determine eating score multiplier (200, 400, 800, 1600)
chompcount = 0;

/// Bonus multiplier active flag for ghost eating
/// When 1, all ghost eating scores are multiplied
pluseat  = 0;

/// Ghost interaction prohibition flag (using GHOST_PROHIBIT enum)
/// ALLOWED (0): Normal interaction
/// PLAYER1_BLOCKED (1): Pac cannot interact with ghosts
prohibit = GHOST_PROHIBIT.ALLOWED;

// ===== AUDIO/AMBIENCE VARIABLES =====
/// Current background music siren level (using SIREN_LEVEL enum)
/// LEVEL_0-4: Determines which siren sound plays
/// Changes as more dots are eaten (siren intensifies)
ambience = SIREN_LEVEL.LEVEL_0;

/// Siren progression tracker (0-4)
/// Separate variable tracking progression through siren levels
/// Based on dot count remaining
siren = 0;

sp = 0;
spfright = 0;
	
/// ===== INITIALIZE SUPPORTING OBJECTS =====
/// These objects are created at Pac's position to handle UI and input

/// Scroller: Handles viewport/camera movement
action_set_relative(0);
action_create_object(Scroller, 0, 0);

/// Drawless: Invisible object that handles HUD drawing and debug overlay
{
action_set_relative(1);
action_create_object(Drawless, 0, 0);
action_set_relative(0);
}

action_set_relative(0);
