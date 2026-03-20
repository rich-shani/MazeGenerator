/// ===============================================================================
/// GAME_CONSTANTS - Centralized game and layout constants
/// ===============================================================================
/// Use these instead of magic numbers for grid size, ghost house, and speeds.
/// ===============================================================================

// Grid
#macro TILE_PIXELS 16

/// Cornering (per Pac-Man Dossier): complete when Pac reaches intersection centerline
/// 1px tolerance reduces visible snap/flicker while remaining arcade-faithful
#macro CORNER_SNAP_TOLERANCE 2

/// Pre-turn zone limits - original arcade has asymmetric 3/4 pixel zones (8px tiles)
/// Scaled 2x for 16px tiles: 3→6, 4→8. Approach from LEFT/UP = 3 pre. RIGHT/DOWN = 4 pre.
/// Post-turn zones use same constants with inverse mapping: LEFT/UP = 4 post (wide), RIGHT/DOWN = 3 post (narrow).
#macro CORNER_PRE_TURN_NARROW 6   // 3 px original * 2
#macro CORNER_PRE_TURN_WIDE 8     // 4 px original * 2

// Ghost house (reference for offset math: xstart/ystart are per-ghost; 216/224 are standard)
#macro GHOST_HOUSE_CENTER_X 224

#macro GHOST_HOUSE_BOTTOM_OFFSET 280
#macro GHOST_HOUSE_EYES_X_MIN 212
#macro GHOST_HOUSE_EYES_X_MAX 220

// Default ghost speeds (pixels per frame); overridden per-level in oGhost Other_4
#macro SPEED_NORMAL 1.875
#macro SPEED_TUNNEL 1.0
#macro SPEED_FRIGHTENED 1.25
#macro SPEED_ELROY 2.0
#macro SPEED_ELROY2 2.125
#macro SPEED_EYES 4.0

// Eyes target (house entrance) for pathfinding
#macro GHOST_HOUSE_ENTRANCE_X 224
#macro GHOST_HOUSE_ENTRANCE_Y 192

// Blinky spawn position in grid cells (used when spawning from tile map)
#macro BLINKY_SPAWN_COL 12
#macro BLINKY_SPAWN_ROW 11
// Pinky spawn position in grid cells (used when spawning from tile map)
#macro PINKY_SPAWN_COL 11
#macro PINKY_SPAWN_ROW 12