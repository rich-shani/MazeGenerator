/// ===============================================================================
/// TILE_SPRITE_INDICES - Sprite index constants for tile-to-sprite mapping
/// ===============================================================================
/// Centralized sprite index constants used in tile map conversion and rendering.
/// These replace hardcoded magic numbers throughout the codebase.
/// Used primarily in PACMAN_MAP_SPRITE_INDEX and PACMAN_MAZE_SPAWN modules.
/// ===============================================================================

// ============================================================================
// BASIC TILE SPRITES
// ============================================================================

/// @description Blank/empty tile (no visual sprite)
/// Used for: BLANK, PATHBLANK, GHOSTSPACE tile states
#macro SPRITE_BLANK 0

/// @description Normal path tile with dot
/// The standard pellet path that Pac-Man eats
#macro SPRITE_DOT 30

/// @description Tunnel path tile
/// Special path tiles in wrap-around tunnels (left/right edges)
#macro SPRITE_TUNNEL 31

/// @description Power pill / Energizer sprite
/// Large flashing pellets that make ghosts frightened
#macro SPRITE_ENERGIZER 29

/// @description Ghost house wall sprite
/// Special wall type that blocks Pac-Man but allows ghosts to pass through
#macro SPRITE_GHOSTWALL 19

// ============================================================================
// CHARACTER SPAWN MARKERS
// ============================================================================

/// @description Pac-Man spawn position marker
#macro SPRITE_PACMAN 28

/// @description Blinky (red ghost) spawn position marker
#macro SPRITE_BLINKY 36

/// @description Pinky (pink ghost) spawn position marker
#macro SPRITE_PINKY 35

/// @description Inky (cyan ghost) spawn position marker
#macro SPRITE_INKY 33

/// @description Clyde (orange ghost) spawn position marker
#macro SPRITE_CLYDE 34

/// @description Fruit spawn position marker
#macro SPRITE_FRUIT 32

// ============================================================================
// WALL SPRITE INDICES (calculated dynamically)
// ============================================================================

/// Wall sprites use indices 1-18 and 20-27 (excluding 19 which is GHOSTWALL)
/// These are calculated by pacman_map_calculate_wall_tile() based on neighbor tiles
/// See PACMAN_MAP_WALL_TILE.gml for the wall sprite selection algorithm
