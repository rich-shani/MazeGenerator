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
    PATHTUNNEL = 7,      // Tunnel path - special path connecting left and right edges
	
	// used to mark the start locations for Pacman, and each of the Ghosts
	PACMAN = 8,
	BLINKY = 9,
	PINKY = 10,
	INKY = 11,
	CLYDE = 12,
	FRUIT = 13
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
 
     static isTunnel = function() {
        return (state == TileState.PATHTUNNEL);
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
  
	// Instance method to check if tile is ghost space
    // Returns true if this tile is part of the ghost home/spawn area
    static isPacman = function() {
        return (state == TileState.PACMAN);
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
