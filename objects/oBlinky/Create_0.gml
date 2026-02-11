/// ===============================================================================
/// BLINKY GHOST OBJECT - CREATE EVENT
/// ===============================================================================
/// Purpose: Initialize Blinky (Red Ghost) with oGhost inheritance
/// Personality: "Shadow" - Direct Chaser (fearless leader)
/// Strategy: Blinky directly chases Pac's current position (no prediction)
/// Scatter Corner: Top-right (416, 32)
///
/// This event runs when Blinky instance is created at room start.
/// event_inherited() loads all shared ghost variables from oGhost parent.
/// Then we override with Blinky-specific settings only.
///
/// Features:
/// - AI chase/scatter/frightened behavior
/// - Grid-based pathfinding with tile tracking
/// - Elroy (faster pursuit) mode when dots are low
/// - Power pellet vulnerability
/// - Smooth animation with sprite flashing
/// ===============================================================================

/// ===== PARENT INITIALIZATION (MUST BE FIRST!) =====
/// Load all shared ghost variables from oGhost parent
/// This includes: animation, position, pathfinding, state, direction, speeds
/// All base ghost functionality is inherited from oGhost.Create_0
event_inherited();

/// ===== BLINKY IDENTITY =====
/// Set Blinky's name and color (unique identity)
/// ghost_name is used for debugging and personality-based logic
ghost_name = "Blinky";                      // Ghost identifier string
ghost_color = ghost_color_blinky();         // Red color: RGB(255, 0, 0)

/// ===== STARTING POSITION & SPAWN LOCATION =====
/// Set where Blinky spawns (center of ghost house)
/// Blinky starts in the center of the ghost house
xstart = 216;                               // Spawn X coordinate (pixel)
ystart = 224;                               // Spawn Y coordinate (pixel)
x = xstart;                                 // Place instance at spawn X
y = ystart;                                 // Place instance at spawn Y

/// ===== SCATTER MODE TARGET =====
/// When in scatter mode (not chasing), Blinky targets the top-right corner
/// Scatter mode occurs when Pac is in certain areas or during specific game states
cornerx = 416;                              // Scatter target X coordinate (top-right)
cornery = 32;                               // Scatter target Y coordinate (top-right)

/// ===== INITIAL STATE & DIRECTION =====
/// Set Blinky's starting state and facing direction
/// Blinky starts in chase mode (ready to hunt immediately)
state = GHOST_STATE.CHASE;                  // Start in chase/scatter mode
dir = GHOST_DIRECTION.LEFT;                 // Start facing left (toward maze exit)

/// ===============================================================================
/// BLINKY'S PERSONALITY NOTES
/// ===============================================================================
/// Blinky is the "leader" ghost - he directly chases Pac without prediction.
/// This makes Blinky the most straightforward threat:
/// - No ambush tactics (unlike Pinky)
/// - No geometric calculations (unlike Inky)
/// - No distance-based switching (unlike Clyde)
/// - Just pure, direct pursuit
///
/// Blinky's behavior in Step_1:
/// - CHASE mode: pursuex = Pac's current grid position (direct chase)
/// - FRIGHTENED mode: Random movement (same as all ghosts)
/// - EYES mode: Target house entrance (same as all ghosts)
///
/// ===============================================================================
/// END BLINKY CREATE EVENT
/// ===============================================================================
