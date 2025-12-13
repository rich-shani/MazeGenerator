/// @description Tile state constants
/// These constants represent the different types of tiles in the Pacman maze.
/// Each tile can be in one of these states, which determines its appearance,
/// collision properties, and gameplay behavior.
enum TileState {
    BLANK = 0,          // Empty/void space - not walkable, no collision
    PATH = 1,           // Walkable path with a pellet - players can move here and collect pellets
    PATHBLANK = 2,      // Walkable path without pellet - used in tunnels and empty areas
    WALL = 3,           // Solid wall - blocks player and ghost movement
    GHOSTWALL = 4,      // Special wall that ghosts can pass through but players cannot
    ENERGIZER = 5,      // Power pellet location - large pellet that makes ghosts vulnerable
    GHOSTSPACE = 6,     // Ghost home/spawn area - where ghosts start and respawn
    PATHTUNNEL = 7      // Tunnel path - special path connecting left and right edges
}

/// @description Create a new Tile structure
/// A Tile represents a single square in the final rendered maze map.
/// Each tile has a position, state (wall, path, etc.), and optionally a reference
/// back to the Cell that generated it (for debugging and generation logic).
/// @param _x X coordinate in the tile map (0-based)
/// @param _y Y coordinate in the tile map (0-based)
/// @returns Tile structure instance with default state BLANK
function Tile_create(_x, _y) constructor {
    // Position in tile map - stored as intTuple for easy coordinate access
    position = new intTuple_create(_x, _y);
    
    // Current state - defaults to BLANK (empty space)
    // Will be set during maze generation to PATH, WALL, etc.
    state = TileState.BLANK;
    
    // Reference to parent Cell that generated this tile
    // Used during generation to track which cell a tile belongs to
    // Set to noone if tile is not directly associated with a cell
    cell = noone;
    
    // Instance method to check if tile is walkable
    // Returns true if players or ghosts can move onto this tile
    static isWalkable = function() {
        // All path types and energizers are walkable
        return (state == TileState.PATH || 
                state == TileState.PATHBLANK || 
                state == TileState.PATHTUNNEL ||
                state == TileState.ENERGIZER);
    }
    
    // Instance method to check if tile is a wall
    // Returns true if this tile blocks player movement
    // Note: GHOSTWALL blocks players but not ghosts
    static isWall = function() {
        return (state == TileState.WALL || state == TileState.GHOSTWALL);
    }
    
    // Instance method to check if tile has a pellet
    // Returns true if this tile contains a small pellet that can be collected
    static hasPellet = function() {
        // Only PATH tiles have regular pellets
        return (state == TileState.PATH);
    }
    
    // Instance method to check if tile is an energizer
    // Returns true if this tile contains a power pellet (energizer)
    static isEnergizer = function() {
        return (state == TileState.ENERGIZER);
    }
    
    // Instance method to check if tile is ghost space
    // Returns true if this tile is part of the ghost home/spawn area
    static isGhostSpace = function() {
        return (state == TileState.GHOSTSPACE);
    }
    
    // Instance method to set state
    // Changes the tile's state to a new value
    // @param newState The new TileState value to assign
    static setState = function(newState) {
        state = newState;
    }
    
    // Instance method to get state name
    static getStateName = function() {
        switch (state) {
            case TileState.BLANK: return "BLANK";
            case TileState.PATH: return "PATH";
            case TileState.PATHBLANK: return "PATHBLANK";
			case TileState.PATHTUNNEL: return "PATHTUNNEL";
            case TileState.WALL: return "WALL";
            case TileState.GHOSTWALL: return "GHOSTWALL";
            case TileState.ENERGIZER: return "ENERGIZER";
            case TileState.GHOSTSPACE: return "GHOSTSPACE";
            default: return "UNKNOWN";
        }
    }
    
    // Instance method to convert to string
    static toString = function() {
        return "Tile(" + string(position.x) + ", " + string(position.y) + 
               ", " + getStateName() + ")";
    }
}

/// @description Check if tile is walkable (standalone function)
/// Standalone function version of the instance method. Checks if a tile can be
/// walked on by players or ghosts. All path types and energizers are walkable.
/// @param tile Tile structure to check
/// @returns true if tile can be walked on (PATH, PATHBLANK, PATHTUNNEL, or ENERGIZER)
function Tile_isWalkable(tile) {
    return (tile.state == TileState.PATH || 
            tile.state == TileState.PATHBLANK ||  
            tile.state == TileState.PATHTUNNEL ||
            tile.state == TileState.ENERGIZER);
}

/// @description Check if tile is a wall
/// @param tile Tile structure
/// @returns true if tile is a wall
function Tile_isWall(tile) {
    return (tile.state == TileState.WALL || tile.state == TileState.GHOSTWALL);
}

/// @description Check if tile has a pellet
/// @param tile Tile structure
/// @returns true if tile contains a pellet
function Tile_hasPellet(tile) {
    return (tile.state == TileState.PATH);
}

/// @description Check if tile is an energizer
/// @param tile Tile structure
/// @returns true if tile is an energizer
function Tile_isEnergizer(tile) {
    return (tile.state == TileState.ENERGIZER);
}

/// @description Set tile state
/// @param tile Tile structure
/// @param newState New state value
function Tile_setState(tile, newState) {
    tile.state = newState;
}

/// @description Get tile state name
/// @param tile Tile structure
/// @returns String name of state
function Tile_getStateName(tile) {
    switch (tile.state) {
        case TileState.BLANK: return "BLANK";
        case TileState.PATH: return "PATH";
        case TileState.PATHBLANK: return "PATHBLANK";
		case TileState.PATHTUNNEL: return "PATHTUNNEL";
        case TileState.WALL: return "WALL";
        case TileState.GHOSTWALL: return "GHOSTWALL";
        case TileState.ENERGIZER: return "ENERGIZER";
        case TileState.GHOSTSPACE: return "GHOSTSPACE";
        default: return "UNKNOWN";
    }
}

