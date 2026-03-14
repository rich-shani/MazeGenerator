/// ===============================================================================
/// GAME_CONSTANTS - Centralized game and layout constants
/// ===============================================================================
/// Use these instead of magic numbers for grid size, ghost house, and speeds.
/// ===============================================================================

// Grid
#macro TILE_PIXELS 16

// Ghost house (reference for offset math: xstart/ystart are per-ghost; 216/224 are standard)
#macro GHOST_HOUSE_CENTER_X 216
#macro GHOST_HOUSE_ENTRANCE_Y 224
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
#macro GHOST_HOUSE_ENTRANCE_X 208
#macro GHOST_HOUSE_ENTRANCE_Y_EYES 240

// Blinky spawn position in grid cells (used when spawning from tile map)
#macro BLINKY_SPAWN_COL 12
#macro BLINKY_SPAWN_ROW 11
