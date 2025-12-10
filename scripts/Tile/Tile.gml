/// @description Tile state constants
enum TileState {
    BLANK = 0,          // Empty/void space
    PATH = 1,           // Walkable path (with pellet)
    PATHBLANK = 2,      // Walkable path (no pellet, tunnel area)
    WALL = 3,           // Solid wall
    GHOSTWALL = 4,      // Wall that ghosts can pass through
    ENERGIZER = 5,      // Power pellet location
    GHOSTSPACE = 6      // Ghost home/spawn area
}

/// @param _x X coordinate
/// @param _y Y coordinate
/// @returns Tile structure instance
function Tile_create(_x, _y) constructor {
    // Position in tile map
    position = new intTuple_create(_x, _y);
    
    // Current state (default: BLANK)
    state = TileState.BLANK;
    
    // Reference to parent Cell (noone if not assigned)
    cell = noone;
    
    // Instance method to check if tile is walkable
    static isWalkable = function() {
        return (state == TileState.PATH || 
                state == TileState.PATHBLANK || 
                state == TileState.ENERGIZER);
    }
    
    // Instance method to check if tile is a wall
    static isWall = function() {
        return (state == TileState.WALL || state == TileState.GHOSTWALL);
    }
    
    // Instance method to check if tile has a pellet
    static hasPellet = function() {
        return (state == TileState.PATH);
    }
    
    // Instance method to check if tile is an energizer
    static isEnergizer = function() {
        return (state == TileState.ENERGIZER);
    }
    
    // Instance method to check if tile is ghost space
    static isGhostSpace = function() {
        return (state == TileState.GHOSTSPACE);
    }
    
    // Instance method to set state
    static setState = function(newState) {
        state = newState;
    }
    
    // Instance method to get state name
    static getStateName = function() {
        switch (state) {
            case TileState.BLANK: return "BLANK";
            case TileState.PATH: return "PATH";
            case TileState.PATHBLANK: return "PATHBLANK";
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

/// @description Check if tile is walkable
/// @param tile Tile structure
/// @returns true if tile can be walked on
function Tile_isWalkable(tile) {
    return (tile.state == TileState.PATH || 
            tile.state == TileState.PATHBLANK || 
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
        case TileState.WALL: return "WALL";
        case TileState.GHOSTWALL: return "GHOSTWALL";
        case TileState.ENERGIZER: return "ENERGIZER";
        case TileState.GHOSTSPACE: return "GHOSTSPACE";
        default: return "UNKNOWN";
    }
}

