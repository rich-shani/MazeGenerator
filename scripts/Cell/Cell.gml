/// @description Cell direction constants
/// These constants represent the four cardinal directions used in the cell-based
/// maze generation algorithm. Each cell can connect to neighbors in these directions.
enum CellDirection {
    UP = 0,     // Move up (decrease Y coordinate)
    RIGHT = 1,  // Move right (increase X coordinate)
    DOWN = 2,   // Move down (increase Y coordinate)
    LEFT = 3    // Move left (decrease X coordinate)
}

/// @description Create a new Cell structure
/// A Cell represents a single unit in the high-level cell map (5x9 grid).
/// Cells are connected together to form the maze structure, then converted into
/// the detailed tile map. Each cell tracks its connections, neighbors, and various
/// generation flags used during the maze creation process.
/// @param _x X coordinate in cell map (0 to CELL_MAP_SIZE_X-1)
/// @param _y Y coordinate in cell map (0 to CELL_MAP_SIZE_Y-1)
/// @returns Cell structure instance with all properties initialized
function Cell_create(_x, _y) constructor {
    // Static counter for filled cells - tracks total number of cells filled during generation
    // This is shared across all Cell instances and increments each time a cell is filled
    static numFilled = 0;
    
    // Position in cell map - stored as intTuple for coordinate access
    position = new intTuple_create(_x, _y);
    
    // Filled state - true if this cell has been processed during maze generation
    filled = false;
    
    // Filled order number - sequence number when this cell was filled (for debugging)
    number = -1;
    
    // Group ID for connected cells - cells with the same group ID are connected
    // Used to track which cells form continuous paths
    group = -1;
    
    // Connection flags: [UP, RIGHT, DOWN, LEFT]
    // Each boolean indicates if there's a connection (open path) in that direction
    // True means this cell connects to its neighbor in that direction
    connections = [false, false, false, false];
    
    // Neighbor cell references: [UP, RIGHT, DOWN, LEFT]
    // Pointers to adjacent cells in each direction (or noone if at map edge)
    // Set during cell map initialization
    next = [noone, noone, noone, noone];
    
    // Ghost space flag - true if this cell is part of the ghost home area
    // Ghost space cells are pre-filled and have special connection rules
    isGhostSpace = false;
    
    // Resize candidates - flags used during maze refinement
    // isRaiseHeightCandidate: cell could be made taller (4 tiles instead of 3)
    // raiseHeight: cell was selected to be raised
    // isShrinkWidthCandidate: cell could be made narrower (2 tiles instead of 3)
    // shrinkWidth: cell was selected to be shrunk
    isRaiseHeightCandidate = false;
    raiseHeight = false;
    isShrinkWidthCandidate = false;
    shrinkWidth = false;
    
    // Join candidate - flag indicating this cell could join with adjacent walls
    // Used during wall joining phase to create better maze structure
    isJoinCandidate = false;
    
    // Tunnel candidates - flags for different types of tunnel connections
    // Tunnels connect the left and right edges of the maze (Pacman wrap-around)
    // isEdgeTunnelCandidate: cell at right edge could form a tunnel
    // isVoidTunnelCandidate: cell could form a tunnel through void space
    // isSingleDeadEndCandidate: cell has a single dead end that could tunnel
    // singleDeadEndDir: direction of the dead end (UP or DOWN)
    // isDoubleDeadEndCandidate: cell has dead ends above and below
    // topTunnel: this cell was selected to have a tunnel connection
    isEdgeTunnelCandidate = false;
    isVoidTunnelCandidate = false;
    isSingleDeadEndCandidate = false;
    singleDeadEndDir = -1;
    isDoubleDeadEndCandidate = false;
    topTunnel = false;
    
    // Tile positioning (calculated during generation)
    // tilePosition: where this cell's tiles start in the tile map (x, y)
    // tileSize: dimensions of this cell in tiles (width, height)
    // These are calculated after cell connections are established
    tilePosition = new intTuple_create(0, 0);
    tileSize = new intTuple_create(0, 0);
    
    // Instance method: Check if direction is open
    // Determines if this cell can connect to its neighbor in the given direction.
    // Used during maze generation to find valid paths for extending the maze.
    // @param dir Direction to check (CellDirection.UP, RIGHT, DOWN, or LEFT)
    // @param prevDir Previous direction moved (optional, used to prevent backtracking)
    // @param size Current piece size (optional, used for special size-2 logic)
    // @returns true if the direction is valid for connection
    static isOpen = function(dir, prevDir = -1, size = -1) {
        // Store instance variables in local scope for closure access
        var _position = position;
        var _next = next;
        var _filled = filled;
        
        // Special case: prevent connection at ghost space boundary
        // The ghost space area (cells at x=0, y=3-4) has special connection rules
        // This prevents creating paths that would break the ghost house structure
        if ((_position.y == 6 && _position.x == 0 && dir == CellDirection.DOWN) ||
            (_position.y == 7 && _position.x == 0 && dir == CellDirection.UP)) {
            return false;
        }
        
        // Prevent backtracking for size 2 pieces
        // When building a 2-cell piece, don't allow going back the way we came
        // or going in the opposite direction (would create a loop)
        if (size == 2 && (dir == prevDir || ((dir + 2) mod 4) == prevDir)) {
            return false;
        }
        
        // Check if neighbor exists and is not filled
        if (_next[dir] != noone && !_next[dir].filled) {
            // Check if neighbor's left neighbor is not open (prevents wide paths)
            // This prevents creating 2-cell-wide corridors, keeping paths narrow
            // The maze should have single-cell-wide paths for authentic Pacman feel
            if (!(_next[dir].next[CellDirection.LEFT] != noone && 
                  !_next[dir].next[CellDirection.LEFT].filled)) {
                return true;
            }
        }
        
        // Direction is not open (neighbor doesn't exist, is filled, or would create wide path)
        return false;
    }
    
    // Instance method: Get all open directions
    // Returns an array of all directions (0-3) that are currently open for connection.
    // Used during maze generation to find all possible paths from the current cell.
    // @param prevDir Previous direction moved (optional, for backtracking prevention)
    // @param size Current piece size (optional, for size-specific logic)
    // @returns Array of direction indices that are open
    static getOpenCells = function(prevDir = -1, size = -1) {
        var openCells = [];
        // Check all four directions
        for (var i = 0; i < 4; i++) {
            if (isOpen(i, prevDir, size)) {
                array_push(openCells, i);
            }
        }
        return openCells;
    }
    
    // Instance method: Connect to neighbor
    // Creates a bidirectional connection between this cell and its neighbor in the given direction.
    // Connections are symmetric - if A connects to B, then B connects to A.
    // @param dir Direction to connect (CellDirection.UP, RIGHT, DOWN, or LEFT)
    static connect = function(dir) {
        // Mark this direction as connected
        connections[dir] = true;
        
        // If neighbor exists, mark the opposite direction on the neighbor
        if (next[dir] != noone) {
            // Set opposite connection on neighbor (dir + 2 mod 4 gives opposite)
            next[dir].connections[(dir + 2) mod 4] = true;
        }
        
        // Special case: left edge connects to itself
        // The left edge (x=0) wraps around to the right edge for tunnel connections
        // This allows the maze to have wrap-around tunnels like classic Pacman
        if (position.x == 0 && dir == CellDirection.RIGHT) {
            connections[CellDirection.LEFT] = true;
        }
    }
    
    // Instance method: Fill cell
    // Marks this cell as filled during maze generation and assigns it to a group.
    // Filled cells are part of the generated maze structure.
    // @param numGroup Group ID to assign this cell to (cells in same group are connected)
    static fill = function(numGroup) {
        filled = true;
        // Assign sequential number based on fill order (for debugging)
        number = Cell_create.numFilled++;
        // Assign to group (all cells in same group form a connected path)
        group = numGroup;
    }
    
    // Instance method: Check if cell is a cross center (all directions connected)
    // Returns true if this cell has connections in all four directions.
    // Cross centers are important during maze refinement as they create intersections.
    // @returns true if cell connects in UP, RIGHT, DOWN, and LEFT directions
    static isCrossCenter = function() {
        return connections[CellDirection.UP] && 
               connections[CellDirection.RIGHT] && 
               connections[CellDirection.DOWN] && 
               connections[CellDirection.LEFT];
    }
    
    // Instance method: Get connection count
    // Returns the number of directions this cell is connected in.
    // Useful for determining cell type: 0=isolated, 1=dead end, 2=corridor, 3=T-junction, 4=cross
    // @returns Number of connected directions (0-4)
    static getConnectionCount = function() {
        var count = 0;
        // Count all true connections
        for (var i = 0; i < 4; i++) {
            if (connections[i]) count++;
        }
        return count;
    }
    
    // Instance method: Check if connected in direction
    static isConnected = function(dir) {
        return connections[dir];
    }
    
    // Instance method: Get neighbor in direction
    static getNeighbor = function(dir) {
        return next[dir];
    }
    
    // Instance method: Set neighbor in direction
    static setNeighbor = function(dir, neighbor) {
        next[dir] = neighbor;
    }
    
    // Instance method: Convert to string
    static toString = function() {
        var connStr = "";
        if (connections[CellDirection.UP]) connStr += "U";
        if (connections[CellDirection.RIGHT]) connStr += "R";
        if (connections[CellDirection.DOWN]) connStr += "D";
        if (connections[CellDirection.LEFT]) connStr += "L";
        if (connStr == "") connStr = "NONE";
        
        return "Cell(" + string(position.x) + ", " + string(position.y) + 
               ", filled:" + string(filled) + ", conn:" + connStr + 
               ", group:" + string(group) + ")";
    }
}

/// @description Check if cell direction is open
/// @param cell Cell structure
/// @param dir Direction to check
/// @param prevDir Previous direction (optional, default: -1)
/// @param size Current size (optional, default: -1)
/// @returns true if direction is open
function Cell_isOpen(cell, dir, prevDir = -1, size = -1) {
    // Special case check
    if ((cell.position.y == 6 && cell.position.x == 0 && dir == CellDirection.DOWN) ||
        (cell.position.y == 7 && cell.position.x == 0 && dir == CellDirection.UP)) {
        return false;
    }
    
    // Prevent backtracking for size 2
    if (size == 2 && (dir == prevDir || ((dir + 2) mod 4) == prevDir)) {
        return false;
    }
    
    // Check neighbor
    if (cell.next[dir] != noone && !cell.next[dir].filled) {
        if (!(cell.next[dir].next[CellDirection.LEFT] != noone && 
              !cell.next[dir].next[CellDirection.LEFT].filled)) {
            return true;
        }
    }
    
    return false;
}

/// @description Get all open directions for cell
/// @param cell Cell structure
/// @param prevDir Previous direction (optional)
/// @param size Current size (optional)
/// @returns Array of open direction indices
function Cell_getOpenCells(cell, prevDir = -1, size = -1) {
    var openCells = [];
    for (var i = 0; i < 4; i++) {
        if (Cell_isOpen(cell, i, prevDir, size)) {
            array_push(openCells, i);
        }
    }
    return openCells;
}

/// @description Connect cell to neighbor in direction
/// @param cell Cell structure
/// @param dir Direction to connect
function Cell_connect(cell, dir) {
    cell.connections[dir] = true;
    if (cell.next[dir] != noone) {
        cell.next[dir].connections[(dir + 2) mod 4] = true;
    }
    
    // Special case: left edge
    if (cell.position.x == 0 && dir == CellDirection.RIGHT) {
        cell.connections[CellDirection.LEFT] = true;
    }
}

/// @description Fill cell and assign group
/// @param cell Cell structure
/// @param numGroup Group number to assign
function Cell_fill(cell, numGroup) {
    cell.filled = true;
    cell.number = Cell_create.numFilled++;
    cell.group = numGroup;
}

/// @description Check if cell is a cross center
/// @param cell Cell structure
/// @returns true if all directions are connected
function Cell_isCrossCenter(cell) {
    return cell.connections[CellDirection.UP] && 
           cell.connections[CellDirection.RIGHT] && 
           cell.connections[CellDirection.DOWN] && 
           cell.connections[CellDirection.LEFT];
}

/// @description Get connection count
/// @param cell Cell structure
/// @returns Number of connected directions
function Cell_getConnectionCount(cell) {
    var count = 0;
    for (var i = 0; i < 4; i++) {
        if (cell.connections[i]) count++;
    }
    return count;
}

/// @description Check if cell is connected in direction
/// @param cell Cell structure
/// @param dir Direction to check
/// @returns true if connected
function Cell_isConnected(cell, dir) {
    return cell.connections[dir];
}

/// @description Get neighbor cell in direction
/// @param cell Cell structure
/// @param dir Direction
/// @returns Neighbor cell or noone
function Cell_getNeighbor(cell, dir) {
    return cell.next[dir];
}

/// @description Set neighbor cell in direction
/// @param cell Cell structure
/// @param dir Direction
/// @param neighbor Neighbor cell (or noone)
function Cell_setNeighbor(cell, dir, neighbor) {
    cell.next[dir] = neighbor;
}

/// @description Reset cell to initial state
/// @param cell Cell structure
function Cell_reset(cell) {
    cell.filled = false;
    cell.number = -1;
    cell.group = -1;
    cell.connections = [false, false, false, false];
    cell.isGhostSpace = false;
    cell.isRaiseHeightCandidate = false;
    cell.raiseHeight = false;
    cell.isShrinkWidthCandidate = false;
    cell.shrinkWidth = false;
    cell.isJoinCandidate = false;
    cell.isEdgeTunnelCandidate = false;
    cell.isVoidTunnelCandidate = false;
    cell.isSingleDeadEndCandidate = false;
    cell.singleDeadEndDir = -1;
    cell.isDoubleDeadEndCandidate = false;
    cell.topTunnel = false;
    cell.tilePosition = new intTuple_create(0, 0);
    cell.tileSize = new intTuple_create(0, 0);
}

/// @description Get opposite direction
/// @param dir Direction
/// @returns Opposite direction
function Cell_getOppositeDirection(dir) {
    return (dir + 2) mod 4;
}

/// @description Get direction name
/// @param dir Direction index
/// @returns Direction name string
function Cell_getDirectionName(dir) {
    switch (dir) {
        case CellDirection.UP: return "UP";
        case CellDirection.RIGHT: return "RIGHT";
        case CellDirection.DOWN: return "DOWN";
        case CellDirection.LEFT: return "LEFT";
        default: return "UNKNOWN";
    }
}

