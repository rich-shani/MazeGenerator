/// @description Cell direction constants
enum CellDirection {
    UP = 0,
    RIGHT = 1,
    DOWN = 2,
    LEFT = 3
}

// @param _x X coordinate in cell map
/// @param _y Y coordinate in cell map
/// @returns Cell structure instance
function Cell_create(_x, _y) constructor {
    // Static counter for filled cells
    static numFilled = 0;
    
    // Position in cell map
    position = new intTuple_create(_x, _y);
    
    // Filled state
    filled = false;
    number = -1;        // Filled order number
    group = -1;         // Group ID for connected cells
    
    // Connection flags: [UP, RIGHT, DOWN, LEFT]
    connections = [false, false, false, false];
    
    // Neighbor cell references: [UP, RIGHT, DOWN, LEFT]
    next = [noone, noone, noone, noone];
    
    // Ghost space flag
    isGhostSpace = false;
    
    // Resize candidates
    isRaiseHeightCandidate = false;
    raiseHeight = false;
    isShrinkWidthCandidate = false;
    shrinkWidth = false;
    
    // Join candidate
    isJoinCandidate = false;
    
    // Tunnel candidates
    isEdgeTunnelCandidate = false;
    isVoidTunnelCandidate = false;
    isSingleDeadEndCandidate = false;
    singleDeadEndDir = -1;
    isDoubleDeadEndCandidate = false;
    topTunnel = false;
    
    // Tile positioning (calculated during generation)
    tilePosition = new intTuple_create(0, 0);
    tileSize = new intTuple_create(0, 0);
    
    // Instance method: Check if direction is open
    static isOpen = function(dir, prevDir = -1, size = -1) {
        var _position = position;
        var _next = next;
        var _filled = filled;
        
        // Special case: prevent connection at ghost space boundary
        if ((_position.y == 6 && _position.x == 0 && dir == CellDirection.DOWN) ||
            (_position.y == 7 && _position.x == 0 && dir == CellDirection.UP)) {
            return false;
        }
        
        // Prevent backtracking for size 2 pieces
        if (size == 2 && (dir == prevDir || ((dir + 2) mod 4) == prevDir)) {
            return false;
        }
        
        // Check if neighbor exists and is not filled
        if (_next[dir] != noone && !_next[dir].filled) {
            // Check if neighbor's left neighbor is not open (prevents wide paths)
            if (!(_next[dir].next[CellDirection.LEFT] != noone && 
                  !_next[dir].next[CellDirection.LEFT].filled)) {
                return true;
            }
        }
        
        return false;
    }
    
    // Instance method: Get all open directions
    static getOpenCells = function(prevDir = -1, size = -1) {
        var openCells = [];
        for (var i = 0; i < 4; i++) {
            if (isOpen(i, prevDir, size)) {
                array_push(openCells, i);
            }
        }
        return openCells;
    }
    
    // Instance method: Connect to neighbor
    static connect = function(dir) {
        connections[dir] = true;
        if (next[dir] != noone) {
            // Set opposite connection on neighbor
            next[dir].connections[(dir + 2) mod 4] = true;
        }
        
        // Special case: left edge connects to itself
        if (position.x == 0 && dir == CellDirection.RIGHT) {
            connections[CellDirection.LEFT] = true;
        }
    }
    
    // Instance method: Fill cell
    static fill = function(numGroup) {
        filled = true;
        number = Cell_create.numFilled++;
        group = numGroup;
    }
    
    // Instance method: Check if cell is a cross center (all directions connected)
    static isCrossCenter = function() {
        return connections[CellDirection.UP] && 
               connections[CellDirection.RIGHT] && 
               connections[CellDirection.DOWN] && 
               connections[CellDirection.LEFT];
    }
    
    // Instance method: Get connection count
    static getConnectionCount = function() {
        var count = 0;
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

