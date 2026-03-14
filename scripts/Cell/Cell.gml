/// @description Create a new Cell structure
/// A Cell represents a single unit in the high-level cell map (5x9 grid).
/// Cells are connected together to form the maze structure, then converted into
/// the detailed tile map. Each cell tracks its connections, neighbors, and various
/// generation flags used during the maze creation process.
///
/// Directions use GRID_DIRECTION (RIGHT=0, UP=1, LEFT=2, DOWN=3) — the same enum
/// used throughout the rest of the codebase. The connections[] and next[] arrays
/// are indexed by GRID_DIRECTION values.
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

    // Connection flags: [RIGHT, UP, LEFT, DOWN] (indexed by GRID_DIRECTION)
    // Each boolean indicates if there's a connection (open path) in that direction
    connections = [false, false, false, false];

    // Neighbor cell references: [RIGHT, UP, LEFT, DOWN] (indexed by GRID_DIRECTION)
    // Pointers to adjacent cells in each direction (or noone if at map edge)
    next = [noone, noone, noone, noone];

    // Ghost space flag - true if this cell is part of the ghost home area
    isGhostSpace = false;

    // Resize candidates - flags used during maze refinement
    isRaiseHeightCandidate = false;
    raiseHeight = false;
    isShrinkWidthCandidate = false;
    shrinkWidth = false;

    // Join candidate - flag indicating this cell could join with adjacent walls
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
    // @param dir Direction to check (GRID_DIRECTION)
    // @param prevDir Previous direction moved (optional)
    // @param size Current piece size (optional)
    // @returns true if the direction is valid for connection
    static isOpen = function(dir, prevDir = -1, size = -1) {
        var _position = position;
        var _next = next;
        var _filled = filled;

        // Prevent connection at the Pac-Man corridor boundary rows (x=0 only)
        if ((_position.y == CELL_BOUNDARY_ROW_A && _position.x == 0 && dir == GRID_DIRECTION.DOWN) ||
            (_position.y == CELL_BOUNDARY_ROW_B && _position.x == 0 && dir == GRID_DIRECTION.UP)) {
            return false;
        }

        // Prevent backtracking for size-2 pieces
        if (size == 2 && (dir == prevDir || ((dir + 2) mod 4) == prevDir)) {
            return false;
        }

        // Check if neighbor exists and is not filled
        if (_next[dir] != noone && !_next[dir].filled) {
            // Prevent 2-cell-wide corridors: reject if neighbor's LEFT neighbor is also unfilled
            if (!(_next[dir].next[GRID_DIRECTION.LEFT] != noone &&
                  !_next[dir].next[GRID_DIRECTION.LEFT].filled)) {
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

    // Instance method: Connect to neighbor in direction (bidirectional)
    static connect = function(dir) {
        connections[dir] = true;
        if (next[dir] != noone) {
            next[dir].connections[(dir + 2) mod 4] = true;
        }
        // Left edge (x=0) wraps: a RIGHT connection also marks LEFT for tunnel logic
        if (position.x == 0 && dir == GRID_DIRECTION.RIGHT) {
            connections[GRID_DIRECTION.LEFT] = true;
        }
    }

    // Instance method: Fill cell and assign group
    static fill = function(numGroup) {
        filled = true;
        number = Cell_create.numFilled++;
        group = numGroup;
    }

    // Instance method: Check if cell is a cross center (all directions connected)
    static isCrossCenter = function() {
        return connections[GRID_DIRECTION.RIGHT] &&
               connections[GRID_DIRECTION.UP] &&
               connections[GRID_DIRECTION.DOWN] &&
               connections[GRID_DIRECTION.LEFT];
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
        if (connections[GRID_DIRECTION.UP])    connStr += "U";
        if (connections[GRID_DIRECTION.RIGHT])  connStr += "R";
        if (connections[GRID_DIRECTION.DOWN])   connStr += "D";
        if (connections[GRID_DIRECTION.LEFT])   connStr += "L";
        if (connStr == "") connStr = "NONE";
        return "Cell(" + string(position.x) + ", " + string(position.y) +
               ", filled:" + string(filled) + ", conn:" + connStr +
               ", group:" + string(group) + ")";
    }
}

/// @description Reset cell to initial state
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

/// @description Get opposite direction (uses GRID_DIRECTION; (dir+2) mod 4)
function Cell_getOppositeDirection(dir) {
    return (dir + 2) mod 4;
}

/// @description Get direction name string (delegates to GRID_DIRECTION helper)
function Cell_getDirectionName(dir) {
    return direction_name(dir);
}
