/// @description Generate a new procedural maze
/// This is the main entry point for maze generation. It uses a trial-and-error
/// approach: generate a maze, check if it meets quality criteria, and retry if not.
/// The generation process involves multiple phases:
/// 1. Reset and create cell map structure
/// 2. Generate cell connections (maze paths)
/// 3. Check if maze is desirable (meets quality criteria)
/// 4. Setup tile coordinates from cell coordinates
/// 5. Join walls for better structure
/// 6. Create tunnels (wrap-around connections)
/// The loop continues until a valid maze is generated.
function pacman_map_generate() {
    
    // Keep trying until we generate a valid maze
    while (true) {
        // Reset the cell map and all generation state
        pacman_map_reset();
        
        // Attempt to generate the maze structure (cell connections)
        pacman_map_attempt_generate();
        
        // Check if the generated maze meets quality criteria
        // If not, restart the generation process
        if (!pacman_map_is_desirable()) {
            continue;
        }
        
        // Calculate tile positions and sizes from cell positions
        // This accounts for tall rows and narrow columns
        pacman_map_setup_scale_coords();
        
        // Join walls together for better maze structure
        // This creates more cohesive wall patterns
        pacman_map_join_walls();
        
        // Create tunnels (wrap-around connections at left/right edges)
        // If tunnel creation fails, restart generation
        if (!pacman_map_create_tunnels()) {
            continue;
        }
        
		// set the location for PACMAN, and the GHOSTs
		pacman_map_set_character_location();
		
        // Successfully generated a valid maze - exit loop
        break;
    }
}

/// @description Reset the cell map for new generation
/// Creates a fresh cell map structure and initializes all cells with their neighbors.
/// Also sets up the ghost space area (ghost home) with pre-defined connections.
/// This must be called before each generation attempt to ensure a clean state.
function pacman_map_reset() {
    // Reset the static counter that tracks filled cells
    Cell_create.numFilled = 0;
    
    // Initialize cell map as a 2D array (CELL_MAP_SIZE_X × CELL_MAP_SIZE_Y)
    var _cellMap = array_create(CELL_MAP_SIZE_X);
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        // Create array for each column
        _cellMap[i] = array_create(CELL_MAP_SIZE_Y);
        for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
            // Create a new Cell at position (i, j)
            _cellMap[i][j] = new Cell_create(i, j);
        }
    }
    
    // Set up cell neighbor references (bidirectional connections)
    // Each cell needs to know which cells are adjacent in each direction
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = _cellMap[i][j];
            
            // Set LEFT neighbor (if not at left edge)
            c.next[CellDirection.LEFT] = (i > 0) ? _cellMap[i-1][j] : noone;
            
            // Set RIGHT neighbor (if not at right edge)
            c.next[CellDirection.RIGHT] = (i < CELL_MAP_SIZE_X - 1) ? _cellMap[i+1][j] : noone;
            
            // Set UP neighbor (if not at top edge)
            c.next[CellDirection.UP] = (j > 0) ? _cellMap[i][j-1] : noone;
            
            // Set DOWN neighbor (if not at bottom edge)
            c.next[CellDirection.DOWN] = (j < CELL_MAP_SIZE_Y - 1) ? _cellMap[i][j+1] : noone;
        }
    }
    
    // Set up ghost space (ghost home area)
    // The ghost space is a 2x2 area at the bottom-left of the maze (cells [0-1][3-4])
    // These cells are pre-filled and have special connection rules to create the ghost house
    
    // Top-left ghost space cell (0, 3)
    _cellMap[0][3].isGhostSpace = true;
    _cellMap[0][3].filled = true;  // Pre-filled, won't be part of generation
    _cellMap[0][3].connections[CellDirection.LEFT] = true;   // Connects to left edge
    _cellMap[0][3].connections[CellDirection.RIGHT] = true;  // Connects to right neighbor
    _cellMap[0][3].connections[CellDirection.DOWN] = true;   // Connects down to (0, 4)
    
    // Top-right ghost space cell (1, 3)
    _cellMap[1][3].isGhostSpace = true;
    _cellMap[1][3].filled = true;
    _cellMap[1][3].connections[CellDirection.LEFT] = true;   // Connects to left neighbor
    _cellMap[1][3].connections[CellDirection.DOWN] = true;   // Connects down to (1, 4)
    
    // Bottom-left ghost space cell (0, 4)
    _cellMap[0][4].isGhostSpace = true;
    _cellMap[0][4].filled = true;
    _cellMap[0][4].connections[CellDirection.LEFT] = true;   // Connects to left edge
    _cellMap[0][4].connections[CellDirection.RIGHT] = true;  // Connects to right neighbor
    _cellMap[0][4].connections[CellDirection.UP] = true;     // Connects up to (0, 3)
    
    // Bottom-right ghost space cell (1, 4)
    _cellMap[1][4].isGhostSpace = true;
    _cellMap[1][4].filled = true;
    _cellMap[1][4].connections[CellDirection.LEFT] = true;  // Connects to left neighbor
    _cellMap[1][4].connections[CellDirection.UP] = true;     // Connects up to (1, 3)
    
    // Reset tallRows and narrowCols arrays
    // These track which cells have been selected for size variation
    tallRows = array_create(CELL_MAP_SIZE_X);
    narrowCols = array_create(CELL_MAP_SIZE_Y);
    
    // Initialize all tallRows to -1 (no tall rows selected yet)
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        tallRows[i] = -1;
    }
    
    // Initialize all narrowCols to -1 (no narrow columns selected yet)
    for (var i = 0; i < CELL_MAP_SIZE_Y; i++) {
        narrowCols[i] = -1;
    }
    
    // Store the cell map in the global variable
    cellMap = _cellMap;
}


/// @description Get leftmost empty cells for generation
/// Finds all unfilled cells in the leftmost column that has any empty cells.
/// This is used during maze generation to ensure we always start from the left
/// and work our way right, creating a consistent generation pattern.
/// @returns Array of Cell structures that are unfilled and in the leftmost column with empty cells
function pacman_map_get_leftmost_empty_cells() {
    var result = [];
    
    // Safety check: ensure cellMap exists
    if (is_undefined(cellMap)) {
        show_debug_message("ERROR: cellMap is undefined in pacman_map_get_leftmost_empty_cells");
        return result;
    }
    
    // Search columns from left to right
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        // Search all rows in this column
        for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
            var c = cellMap[i][j];
            // If cell exists and is not filled, add it to results
            if (c != noone && !c.filled) {
                array_push(result, c);
            }
        }
        // If we found any empty cells in this column, stop searching
        // (we only want the leftmost column with empty cells)
        if (array_length(result) > 0) {
            break;
        }
    }
    
    return result;
}

/// @description Attempt to generate the maze structure
function pacman_map_attempt_generate() {
    var cell = noone;
    var newCell = noone;
    var firstCell = noone;
    
    var singleCount = [0, 0];
    var probStopGrowingAtSize = [0.0, 0.0, 0.1, 0.5, 0.75, 1.0];
    var probTopAndBotSingleCellJoin = 0.35;
    var probExtendAtSize2 = 0.5;
    var probExtendAtSize3or4 = 0.5;
    var longPieces = 0;
    var MAX_LONG_PIECES = 1;
    var dir = -1;
    
    var numGroups = 0;
    
    while (true) {
        var openCells = pacman_map_get_leftmost_empty_cells();
        var numOpenCells = array_length(openCells);
        
        if (numOpenCells == 0) {
            break;
        }
        
        cell = openCells[floor(random(numOpenCells))];
		firstCell = cell;
        if (cell == noone) {
            show_debug_message("ERROR: cell is noone in pacman_map_attempt_generate");
            break;
        }
        Cell_fill(cell, numGroups);
        
        // Handle single cell join logic
        if (cell.position.x < CELL_MAP_SIZE_X - 1 &&
            (cell.position.y == 0 || cell.position.y == CELL_MAP_SIZE_Y - 1) &&
            random(1.0) < probTopAndBotSingleCellJoin) {
            var singleCountPos = (cell.position.y == 0) ? 0 : 1;
            if (singleCount[singleCountPos] == 0) {
                var dirToConnect = (cell.position.y == 0) ? CellDirection.UP : CellDirection.DOWN;
                cell.connections[dirToConnect] = true;
                singleCount[singleCountPos]++;
                numGroups++;
                continue;
            }
        }
        
        var size = 1;
        
        if (cell.position.x == CELL_MAP_SIZE_X - 1) {
            cell.connections[CellDirection.RIGHT] = true;
            cell.isRaiseHeightCandidate = true;
        } else {
            while (size < 5) {
                var stop = false;
                
                // Size 2 extension logic
                if (size == 2) {
                    var c = firstCell;
                    if (c.position.x > 0 && c.connections[CellDirection.RIGHT] &&
                        c.next[CellDirection.RIGHT] != noone &&
                        c.next[CellDirection.RIGHT].next[CellDirection.RIGHT] != noone) {
                        if (longPieces < MAX_LONG_PIECES &&
                            random(1.0) < probExtendAtSize2) {
                            var chosenDir = -1;
                            c = c.next[CellDirection.RIGHT].next[CellDirection.RIGHT];
                            var dirs = [false, false, false, false];
                            
                            if (c.isOpen(CellDirection.UP)) dirs[CellDirection.UP] = true;
                            if (c.isOpen(CellDirection.DOWN)) dirs[CellDirection.DOWN] = true;
                            
                            if (dirs[CellDirection.UP] && dirs[CellDirection.DOWN]) {
                                chosenDir = (random(1.0) < 0.5) ? CellDirection.UP : CellDirection.DOWN;
                            } else if (dirs[CellDirection.UP]) {
                                chosenDir = CellDirection.UP;
                            } else if (dirs[CellDirection.DOWN]) {
                                chosenDir = CellDirection.DOWN;
                            }
                            
                            if (chosenDir != -1) {
                                c.connect(CellDirection.LEFT);
                                Cell_fill(c, numGroups);
                                c.connect(chosenDir);
                                Cell_fill(c.next[chosenDir], numGroups);
                                longPieces++;
                                size += 2;
                                stop = true;
                            }
                        }
                    }
                }
                
                if (!stop) {
                    var leOpenCells = cell.getOpenCells(dir, size);
                    var numLeOpenCells = array_length(leOpenCells);
                    
                    if (numLeOpenCells == 0 && size == 2 && newCell != noone) {
                        cell = newCell;
                        leOpenCells = cell.getOpenCells(dir, size);
                        numLeOpenCells = array_length(leOpenCells);
                    }
                    
                    if (numLeOpenCells == 0) {
                        stop = true;
                    } else {
                        dir = leOpenCells[floor(random(numLeOpenCells))];
                        newCell = cell.next[dir];
                        
                        cell.connect(dir);
                        Cell_fill(newCell, numGroups);
                        size++;
                        
                        if (firstCell.position.x == 0 && size == 3) {
                            stop = true;
                        }
                        
                        if (size < array_length(probStopGrowingAtSize) &&
                            random(1.0) < probStopGrowingAtSize[size]) {
                            stop = true;
                        }
                    }
                }
                
                if (stop) {
                    // Handle size-based logic
                    if (size == 2) {
                        var c = firstCell;
                        if (c.position.x == CELL_MAP_SIZE_X - 1) {
                            if (c.connections[CellDirection.UP]) {
                                c = c.next[CellDirection.UP];
                            }
                            c.connections[CellDirection.RIGHT] = true;
                            if (c.next[CellDirection.DOWN] != noone) {
                                c.next[CellDirection.DOWN].connections[CellDirection.RIGHT] = true;
                            }
                        }
                    } else if (size == 3 || size == 4) {
                        if (longPieces < MAX_LONG_PIECES &&
                            firstCell.position.x > 0 &&
                            random(1.0) <= probExtendAtSize3or4) {
                            var dirs = [];
                            for (var i = 0; i < 4; i++) {
                                if (cell.connections[i] && cell.next[i] != noone &&
                                    cell.next[i].isOpen(i)) {
                                    array_push(dirs, i);
                                }
                            }
                            
                            if (array_length(dirs) > 0) {
                                var d = dirs[floor(random(array_length(dirs)))];
                                var c = cell.next[d];
                                c.connect(d);
                                Cell_fill(c.next[d], numGroups);
                                longPieces++;
                            }
                        }
                    }
                    
                    break;
                }
            }
        }
        
        numGroups++;
    }
    
    pacman_map_set_resize_candidates();
}

/// @description Set resize candidates for cells
function pacman_map_set_resize_candidates() {
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = cellMap[i][j];
            var q = c.connections;
            
            // Raise height candidate
            if ((c.position.x == 0 || !q[CellDirection.LEFT]) &&
                (c.position.x == CELL_MAP_SIZE_X - 1 || !q[CellDirection.RIGHT]) &&
                q[CellDirection.UP] != q[CellDirection.DOWN]) {
                c.isRaiseHeightCandidate = true;
            }
            
            // Check pair for raise height
            var c2 = c.next[CellDirection.RIGHT];
            if (c2 != noone) {
                var q2 = c2.connections;
                if (((c.position.x == 0 || !q[CellDirection.LEFT]) && !q[CellDirection.UP] && !q[CellDirection.DOWN]) &&
                    ((c2.position.x == CELL_MAP_SIZE_X - 1 || !q2[CellDirection.RIGHT]) &&
                     !q2[CellDirection.UP] && !q2[CellDirection.DOWN])) {
                    c.isRaiseHeightCandidate = true;
                    c2.isRaiseHeightCandidate = true;
                }
            }
            
            // Shrink width candidate
            if (c.position.x == CELL_MAP_SIZE_X - 1 && q[CellDirection.RIGHT]) {
                c.isShrinkWidthCandidate = true;
            }
            
            if ((c.position.y == 0 || !q[CellDirection.UP]) &&
                (c.position.y == CELL_MAP_SIZE_Y - 1 || !q[CellDirection.DOWN]) &&
                q[CellDirection.LEFT] != q[CellDirection.RIGHT]) {
                c.isShrinkWidthCandidate = true;
            }
        }
    }
}

/// @description Check if generated maze meets quality criteria
function pacman_map_is_desirable() {
    // Check top right corner
    var c = cellMap[CELL_MAP_SIZE_X - 1][0];
    if (c.connections[CellDirection.UP] || c.connections[CellDirection.RIGHT]) {
        return false;
    }
    
    // Check bottom right corner
    c = cellMap[CELL_MAP_SIZE_X - 1][CELL_MAP_SIZE_Y - 1];
    if (c.connections[CellDirection.DOWN] || c.connections[CellDirection.RIGHT]) {
        return false;
    }
    
    // Check for stacked pieces
    for (var j = 0; j < CELL_MAP_SIZE_Y - 1; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X - 1; i++) {
            if ((pacman_map_is_stacked_horizontal(i, j) &&
                 pacman_map_is_stacked_horizontal(i, j + 1)) ||
                (pacman_map_is_stacked_vertical(i, j) &&
                 pacman_map_is_stacked_vertical(i + 1, j))) {
                if (i == 0) {
                    return false;
                }
                
                // Join the stacked pieces
                var g = cellMap[i][j].group;
                cellMap[i][j].connections[CellDirection.DOWN] = true;
                cellMap[i][j].connections[CellDirection.RIGHT] = true;
                cellMap[i + 1][j].connections[CellDirection.DOWN] = true;
                cellMap[i + 1][j].connections[CellDirection.LEFT] = true;
                cellMap[i + 1][j].group = g;
                cellMap[i][j + 1].connections[CellDirection.UP] = true;
                cellMap[i][j + 1].connections[CellDirection.RIGHT] = true;
                cellMap[i][j + 1].group = g;
                cellMap[i + 1][j + 1].connections[CellDirection.UP] = true;
                cellMap[i + 1][j + 1].connections[CellDirection.LEFT] = true;
                cellMap[i + 1][j + 1].group = g;
            }
        }
    }
    
    if (!pacman_map_choose_tall_rows()) {
        return false;
    }
    
    if (!pacman_map_choose_narrow_cols()) {
        return false;
    }
    
    return true;
}

/// @description Check if cells are stacked horizontally
function pacman_map_is_stacked_horizontal(i, j) {
    var q1 = cellMap[i][j].connections;
    var q2 = cellMap[i + 1][j].connections;
    
    return !q1[CellDirection.UP] && !q1[CellDirection.DOWN] && (i == 0 || !q1[CellDirection.LEFT]) &&
           q1[CellDirection.RIGHT] && !q2[CellDirection.UP] && !q2[CellDirection.DOWN] &&
           q2[CellDirection.LEFT] && !q2[CellDirection.RIGHT];
}

/// @description Check if cells are stacked vertically
function pacman_map_is_stacked_vertical(i, j) {
    var q1 = cellMap[i][j].connections;
    var q2 = cellMap[i][j + 1].connections;
    
    if (i == CELL_MAP_SIZE_X - 1) {
        return !q1[CellDirection.LEFT] && !q1[CellDirection.UP] && !q1[CellDirection.DOWN] &&
               !q2[CellDirection.LEFT] && !q2[CellDirection.UP] && !q2[CellDirection.DOWN];
    }
    
    return !q1[CellDirection.LEFT] && !q1[CellDirection.RIGHT] && !q1[CellDirection.UP] &&
           q1[CellDirection.DOWN] && !q2[CellDirection.LEFT] && !q2[CellDirection.RIGHT] &&
           q2[CellDirection.UP] && !q2[CellDirection.DOWN];
}

/// @description Choose tall rows for variation
function pacman_map_choose_tall_rows() {
    for (var j = 0; j < 3; j++) {
        var c = cellMap[0][j];
        if (c.isRaiseHeightCandidate && pacman_map_can_raise_height(0, j)) {
            c.raiseHeight = true;
            tallRows[c.position.x] = c.position.y;
            return true;
        }
    }
    return false;
}

/// @description Check if height can be raised at position
function pacman_map_can_raise_height(i, j) {
    if (i == CELL_MAP_SIZE_X - 1) {
        return true;
    }
    
    var c2 = noone;
    for (var y0 = j; y0 >= 0; y0--) {
        var c = cellMap[i][y0];
        c2 = c.next[CellDirection.RIGHT];
        if ((!c.connections[CellDirection.UP] || c.isCrossCenter()) &&
            (!c2.connections[CellDirection.UP] || c2.isCrossCenter())) {
            break;
        }
    }
    
    var candidates = [];
    while (c2 != noone) {
        if (c2.isRaiseHeightCandidate) {
            array_push(candidates, c2);
        }
        
        if ((!c2.connections[CellDirection.DOWN] || c2.isCrossCenter()) &&
            (!c2.next[CellDirection.LEFT].connections[CellDirection.DOWN] ||
             c2.next[CellDirection.LEFT].isCrossCenter())) {
            break;
        }
        c2 = c2.next[CellDirection.DOWN];
    }
    
    // Shuffle candidates
    for (var c = array_length(candidates); c > 1; c--) {
        var pos = irandom(c - 1);
        var temp = candidates[c - 1];
        candidates[c - 1] = candidates[pos];
        candidates[pos] = temp;
    }
    
    for (var c = 0; c < array_length(candidates); c++) {
        c2 = candidates[c];
        if (pacman_map_can_raise_height(c2.position.x, c2.position.y)) {
            c2.raiseHeight = true;
            tallRows[c2.position.x] = c2.position.y;
            return true;
        }
    }
    
    return false;
}

/// @description Choose narrow columns for variation
function pacman_map_choose_narrow_cols() {
    for (var i = CELL_MAP_SIZE_X - 1; i >= 0; i--) {
        var c = cellMap[i][0];
        if (c.isShrinkWidthCandidate && pacman_map_can_shrink_width(i, 0)) {
            c.shrinkWidth = true;
            narrowCols[c.position.y] = c.position.x;
            return true;
        }
    }
    return false;
}

/// @description Check if width can be shrunk at position
function pacman_map_can_shrink_width(i, j) {
    if (j == CELL_MAP_SIZE_Y - 1) {
        return true;
    }
    
    var c2 = noone;
    for (var x0 = i; x0 < CELL_MAP_SIZE_X; x0++) {
        var c = cellMap[x0][j];
        c2 = c.next[CellDirection.DOWN];
        if ((!c.connections[CellDirection.RIGHT] || c.isCrossCenter()) &&
            (!c2.connections[CellDirection.RIGHT] || c.isCrossCenter())) {
            break;
        }
    }
    
    var candidates = [];
    while (c2 != noone) {
        if (c2.isShrinkWidthCandidate) {
            array_push(candidates, c2);
        }
        
        if ((!c2.connections[CellDirection.LEFT] || c2.isCrossCenter()) &&
            (!c2.next[CellDirection.UP].connections[CellDirection.LEFT] ||
             c2.next[CellDirection.UP].isCrossCenter())) {
            break;
        }
        c2 = c2.next[CellDirection.LEFT];
    }
    
    // Shuffle candidates
    for (var c = array_length(candidates); c > 1; c--) {
        var pos = irandom(c - 1);
        var temp = candidates[c - 1];
        candidates[c - 1] = candidates[pos];
        candidates[pos] = temp;
    }
    
    for (var c = 0; c < array_length(candidates); c++) {
        c2 = candidates[c];
        if (pacman_map_can_shrink_width(c2.position.x, c2.position.y)) {
            c2.shrinkWidth = true;
            narrowCols[c2.position.y] = c2.position.x;
            return true;
        }
    }
    
    return false;
}

/// @description Setup tile coordinates from cell coordinates
function pacman_map_setup_scale_coords() {
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = cellMap[i][j];
            
            c.tilePosition.x = c.position.x * 3;
            if (narrowCols[c.position.y] < c.position.x) {
                c.tilePosition.x--;
            }
            
            c.tilePosition.y = c.position.y * 3;
            if (tallRows[c.position.x] < c.position.y) {
                c.tilePosition.y++;
            }
            
            c.tileSize.x = c.shrinkWidth ? 2 : 3;
            c.tileSize.y = c.raiseHeight ? 4 : 3;
        }
    }
}

/// @description Join walls for better maze structure
function pacman_map_join_walls() {
    // Top row joining
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        var c = cellMap[i][0];
        if (!c.connections[CellDirection.LEFT] && !c.connections[CellDirection.RIGHT] &&
            !c.connections[CellDirection.UP] &&
            (!c.connections[CellDirection.DOWN] || 
             (c.next[CellDirection.DOWN] != noone && !c.next[CellDirection.DOWN].connections[CellDirection.DOWN]))) {
            if ((c.next[CellDirection.LEFT] == noone || !c.next[CellDirection.LEFT].connections[CellDirection.UP]) &&
                (c.next[CellDirection.RIGHT] != noone && !c.next[CellDirection.RIGHT].connections[CellDirection.UP])) {
                if (!(c.next[CellDirection.DOWN] != noone &&
                      c.next[CellDirection.DOWN].connections[CellDirection.RIGHT] &&
                      c.next[CellDirection.DOWN].next[CellDirection.RIGHT] != noone &&
                      c.next[CellDirection.DOWN].next[CellDirection.RIGHT].connections[CellDirection.RIGHT])) {
                    c.isJoinCandidate = true;
                    if (random(1.0) <= 0.25) {
                        c.connections[CellDirection.UP] = true;
                    }
                }
            }
        }
    }
    
    // Bottom row joining
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        var c = cellMap[i][CELL_MAP_SIZE_Y - 1];
        if (!c.connections[CellDirection.LEFT] && !c.connections[CellDirection.RIGHT] &&
            !c.connections[CellDirection.DOWN] &&
            (!c.connections[CellDirection.UP] ||
             (c.next[CellDirection.UP] != noone && !c.next[CellDirection.UP].connections[CellDirection.UP]))) {
            if ((c.next[CellDirection.LEFT] == noone || !c.next[CellDirection.LEFT].connections[CellDirection.DOWN]) &&
                (c.next[CellDirection.RIGHT] != noone && !c.next[CellDirection.RIGHT].connections[CellDirection.DOWN])) {
                if (!(c.next[CellDirection.UP] != noone &&
                      c.next[CellDirection.UP].connections[CellDirection.RIGHT] &&
                      c.next[CellDirection.UP].next[CellDirection.RIGHT] != noone &&
                      c.next[CellDirection.UP].next[CellDirection.RIGHT].connections[CellDirection.RIGHT])) {
                    c.isJoinCandidate = true;
                    if (random(1.0) <= 0.25) {
                        c.connections[CellDirection.DOWN] = true;
                    }
                }
            }
        }
    }
    
    // Right column joining
    for (var j = 1; j < CELL_MAP_SIZE_Y - 1; j++) {
        var c = cellMap[CELL_MAP_SIZE_X - 1][j];
        if (c.raiseHeight) {
            continue;
        }
        
        if (!c.connections[CellDirection.RIGHT] && !c.connections[CellDirection.UP] &&
            !c.connections[CellDirection.DOWN] &&
            (c.next[CellDirection.UP] == noone || !c.next[CellDirection.UP].connections[CellDirection.RIGHT]) &&
            (c.next[CellDirection.DOWN] == noone || !c.next[CellDirection.DOWN].connections[CellDirection.RIGHT])) {
            if (c.connections[CellDirection.LEFT]) {
                var c2 = c.next[CellDirection.LEFT];
                if (!c2.connections[CellDirection.UP] && !c2.connections[CellDirection.DOWN] &&
                    !c2.connections[CellDirection.LEFT]) {
                    c.isJoinCandidate = true;
                    if (random(1.0) <= 0.5) {
                        c.connections[CellDirection.RIGHT] = true;
                    }
                }
            }
        }
    }
}

function pacman_map_set_character_location() {
	
}

/// @description Create tunnel connections
function pacman_map_create_tunnels() {
    var singleDeadEndCells = [];
    var topSingleDeadEndCells = [];
    var botSingleDeadEndCells = [];
    var voidTunnelCells = [];
    var topVoidTunnelCells = [];
    var botVoidTunnelCells = [];
    var edgeTunnelCells = [];
    var topEdgeTunnelCells = [];
    var botEdgeTunnelCells = [];
    var doubleDeadEndCells = [];
    
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        var c = cellMap[CELL_MAP_SIZE_X - 1][j];
        
        if (c.connections[CellDirection.UP]) {
            continue;
        }
        
        if (c.position.y > 1 && c.position.y < CELL_MAP_SIZE_Y - 2) {
            c.isEdgeTunnelCandidate = true;
            array_push(edgeTunnelCells, c);
            if (c.position.y <= 2) {
                array_push(topEdgeTunnelCells, c);
            } else if (c.position.y >= CELL_MAP_SIZE_Y - 4) {
                array_push(botEdgeTunnelCells, c);
            }
        }
        
        var upDead = (c.next[CellDirection.UP] == noone || c.next[CellDirection.UP].connections[CellDirection.RIGHT]);
        var downDead = (c.next[CellDirection.DOWN] == noone || c.next[CellDirection.DOWN].connections[CellDirection.RIGHT]);
        
        if (c.connections[CellDirection.RIGHT]) {
            if (upDead) {
                c.isVoidTunnelCandidate = true;
                array_push(voidTunnelCells, c);
                if (c.position.y <= 2) {
                    array_push(topVoidTunnelCells, c);
                } else if (c.position.y >= CELL_MAP_SIZE_Y - 3) {
                    array_push(botVoidTunnelCells, c);
                }
            }
        } else {
            if (c.connections[CellDirection.DOWN]) {
                continue;
            }
            
            if (upDead != downDead) {
                if (!c.raiseHeight && c.position.y < CELL_MAP_SIZE_Y - 1 &&
                    c.next[CellDirection.LEFT] != noone && !c.next[CellDirection.LEFT].connections[CellDirection.LEFT]) {
                    array_push(singleDeadEndCells, c);
                    c.isSingleDeadEndCandidate = true;
                    c.singleDeadEndDir = upDead ? CellDirection.UP : CellDirection.DOWN;
                    var offset = upDead ? 1 : 0;
                    if (c.position.y <= 1 + offset) {
                        array_push(topSingleDeadEndCells, c);
                    } else if (c.position.y >= CELL_MAP_SIZE_Y - 4 + offset) {
                        array_push(botSingleDeadEndCells, c);
                    }
                }
            } else if (upDead && downDead) {
                if (j > 0 && j < CELL_MAP_SIZE_Y - 1) {
                    if (c.next[CellDirection.LEFT] != noone &&
                        c.next[CellDirection.LEFT].connections[CellDirection.UP] &&
                        c.next[CellDirection.LEFT].connections[CellDirection.DOWN]) {
                        c.isDoubleDeadEndCandidate = true;
                        if (c.position.y >= 2 && c.position.y <= CELL_MAP_SIZE_Y - 4) {
                            array_push(doubleDeadEndCells, c);
                        }
                    }
                }
            }
        }
    }
    
    // Random decision: 1 or 2 tunnels (45% chance of 2)
    var numTunnelsDesired = (random(1.0) <= 0.45) ? 2 : 1;
    
    if (numTunnelsDesired == 1) {
        if (array_length(voidTunnelCells) > 0) {
            voidTunnelCells[floor(random(array_length(voidTunnelCells)))].topTunnel = true;
        } else if (array_length(singleDeadEndCells) > 0) {
            pacman_map_select_single_dead_end(
                singleDeadEndCells[floor(random(array_length(singleDeadEndCells)))]
            );
        } else if (array_length(edgeTunnelCells) > 0) {
            edgeTunnelCells[floor(random(array_length(edgeTunnelCells)))].topTunnel = true;
        } else {
            return false;
        }
    } else if (numTunnelsDesired == 2) {
        if (array_length(doubleDeadEndCells) > 0) {
            var c = doubleDeadEndCells[floor(random(array_length(doubleDeadEndCells)))];
            c.connections[CellDirection.RIGHT] = true;
            c.topTunnel = true;
            if (c.next[CellDirection.DOWN] != noone) {
                c.next[CellDirection.DOWN].topTunnel = true;
            }
        } else {
            var numTunnelsCreated = 1;
            
            // Top tunnel
            if (array_length(topVoidTunnelCells) > 0) {
                topVoidTunnelCells[floor(random(array_length(topVoidTunnelCells)))].topTunnel = true;
            } else if (array_length(topSingleDeadEndCells) > 0) {
                pacman_map_select_single_dead_end(
                    topSingleDeadEndCells[floor(random(array_length(topSingleDeadEndCells)))]
                );
            } else if (array_length(topEdgeTunnelCells) > 0) {
                topEdgeTunnelCells[floor(random(array_length(topEdgeTunnelCells)))].topTunnel = true;
            } else {
                numTunnelsCreated = 0;
            }
            
            // Bottom tunnel
            if (array_length(botVoidTunnelCells) > 0) {
                botVoidTunnelCells[floor(random(array_length(botVoidTunnelCells)))].topTunnel = true;
            } else if (array_length(botSingleDeadEndCells) > 0) {
                pacman_map_select_single_dead_end(
                    botSingleDeadEndCells[floor(random(array_length(botSingleDeadEndCells)))]
                );
            } else if (array_length(botEdgeTunnelCells) > 0) {
                botEdgeTunnelCells[floor(random(array_length(botEdgeTunnelCells)))].topTunnel = true;
            } else {
                if (numTunnelsCreated == 0) {
                    return false;
                }
            }
        }
    }
    
    // Check for exit condition
    var _exit = false;
    var topy = -1;
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        var c = cellMap[CELL_MAP_SIZE_X - 1][j];
        if (c.topTunnel) {
            _exit = true;
            topy = c.tilePosition.y;
            var tempC = c;
            while (tempC.next[CellDirection.LEFT] != noone) {
                tempC = tempC.next[CellDirection.LEFT];
                if (!tempC.connections[CellDirection.UP] && tempC.tilePosition.y == topy) {
                    continue;
                } else {
                    _exit = false;
                    break;
                }
            }
            if (_exit) {
                return false;
            }
        }
    }
    
    // Connect void tunnels
    var len = array_length(voidTunnelCells);
    for (var i = 0; i < len; i++) {
        var c = voidTunnelCells[i];
        if (!c.topTunnel) {
            pacman_map_replace_group(c.group, c.next[CellDirection.UP].group);
            c.connections[CellDirection.UP] = true;
            if (c.next[CellDirection.UP] != noone) {
                c.next[CellDirection.UP].connections[CellDirection.DOWN] = true;
            }
        }
    }
    
    return true;
}

/// @description Select and configure single dead end tunnel
function pacman_map_select_single_dead_end(c) {
    c.connections[CellDirection.RIGHT] = true;
    if (c.singleDeadEndDir == CellDirection.UP) {
        c.topTunnel = true;
    } else {
        if (c.next[CellDirection.DOWN] != noone) {
            c.next[CellDirection.DOWN].topTunnel = true;
        }
    }
}

/// @description Replace all cells of one group with another
function pacman_map_replace_group(oldGroup, newGroup) {
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = cellMap[i][j];
            if (c.group == oldGroup) {
                c.group = newGroup;
            }
        }
    }
}

/// @description Generate tile map from cell map
function pacman_map_get_tile_map() {
    var sub = new intTuple_create(
        CELL_MAP_SIZE_X * 3 - 1 + 2,
        CELL_MAP_SIZE_Y * 3 + 1 + 3
    );
    
    var midX = sub.x - 2;
    var fullX = (sub.x - 2) * 2;
    
    // Initialize tile map
    var result = array_create(fullX);
    for (var i = 0; i < fullX; i++) {
        result[i] = array_create(sub.y);
        for (var j = 0; j < sub.y; j++) {
            result[i][j] = new Tile_create(i, j);
        }
    }
    
    // Populate from cell map
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = cellMap[i][j];
            
            for (var x0 = 0; x0 < c.tileSize.x; x0++) {
                for (var y0 = 0; y0 < c.tileSize.y; y0++) {
                    var tileX = c.tilePosition.x + x0;
                    var tileY = c.tilePosition.y + 1 + y0;
                    result[tileX][tileY].cell = c; // Store reference
                    
                    if (c.isGhostSpace) {
                        pacman_map_set_tile(result, c.tilePosition.x + x0,
                                           c.tilePosition.y + y0,
                                           TileState.GHOSTSPACE, sub.x, sub.y, midX);
                    }
                }
            }
        }
    }
    
    // Generate paths
    for (var j = 0; j < sub.y; j++) {
        for (var i = 0; i < sub.x; i++) {
            var c = (result[i][j] != noone) ? result[i][j].cell : noone;
            var cl = (i > 0 && result[i-1][j] != noone) ? result[i-1][j].cell : noone;
            var cu = (j > 0 && result[i][j-1] != noone) ? result[i][j-1].cell : noone;
            
            if (c != noone) {
                if ((cl != noone && c.group != cl.group) ||
                    (cu != noone && c.group != cu.group) ||
                    (cu == noone && !c.connections[CellDirection.UP])) {
                    pacman_map_set_tile(result, i, j, TileState.PATH, sub.x, sub.y, midX);
                }
            } else {
                if ((cl != noone && (!cl.connections[CellDirection.RIGHT] ||
                     pacman_map_get_tile_state(result, i-1, j, sub.x, sub.y, midX) == TileState.PATH)) ||
                    (cu != noone && (!cu.connections[CellDirection.DOWN] ||
                     pacman_map_get_tile_state(result, i, j-1, sub.x, sub.y, midX) == TileState.PATH))) {
                    pacman_map_set_tile(result, i, j, TileState.PATH, sub.x, sub.y, midX);
                }
            }
            
            if (pacman_map_get_tile_state(result, i-1, j, sub.x, sub.y, midX) == TileState.PATH &&
                pacman_map_get_tile_state(result, i, j-1, sub.x, sub.y, midX) == TileState.PATH &&
                pacman_map_get_tile_state(result, i-1, j-1, sub.x, sub.y, midX) == TileState.BLANK) {
                pacman_map_set_tile(result, i, j, TileState.PATH, sub.x, sub.y, midX);
            }
        }
    }
    
    // Handle top tunnels
    var c = cellMap[CELL_MAP_SIZE_X - 1][0];
    while (c != noone) {
        if (c.topTunnel) {
            var j = c.tilePosition.y + 1;
            // Mark tunnel exit tile (rightmost edge) as PATHTUNNEL
            pacman_map_set_tile(result, sub.x - 1, j, TileState.PATHTUNNEL, sub.x, sub.y, midX);
            
            // Trace back and mark path leading into tunnel as PATHTUNNEL
            pacman_map_mark_tunnel_path(result, sub.x - 2, j, sub.x, sub.y, midX);
        }
        c = c.next[CellDirection.DOWN];
    }
    
    // Generate walls
    for (var j = 0; j < sub.y; j++) {
        for (var i = 0; i < sub.x; i++) {
            var currentState = pacman_map_get_tile_state(result, i, j, sub.x, sub.y, midX);
            if (currentState != TileState.PATH && currentState != TileState.PATHTUNNEL) {
                var isAdjacent = false;
                for (var di = -1; di <= 1; di++) {
                    for (var dj = -1; dj <= 1; dj++) {
                        if (di == 0 && dj == 0) continue;
                        var adjState = pacman_map_get_tile_state(result, i + di, j + dj, sub.x, sub.y, midX);
                        if (adjState == TileState.PATH || adjState == TileState.PATHTUNNEL) {
                            isAdjacent = true;
                            break;
                        }
                    }
                    if (isAdjacent) break;
                }
                if (isAdjacent) {
                    pacman_map_set_tile(result, i, j, TileState.WALL, sub.x, sub.y, midX);
                }
            }
        }
    }
    
    // Set ghost wall
    pacman_map_set_tile(result, 2, 12, TileState.GHOSTWALL, sub.x, sub.y, midX);
    
    // Place energizers
    var range = pacman_map_get_top_energizer_range(result, sub.x, sub.y, midX);
    if (range != noone) {
        var j = irandom_range(range[0], range[1]);
        var i = sub.x - 2;
        pacman_map_set_tile(result, i, j, TileState.ENERGIZER, sub.x, sub.y, midX);
    }
    
    range = pacman_map_get_bot_energizer_range(result, sub.x, sub.y, midX);
    if (range != noone) {
        var j = irandom_range(range[0], range[1]);
        var i = sub.x - 2;
        pacman_map_set_tile(result, i, j, TileState.ENERGIZER, sub.x, sub.y, midX);
    }
    
    // Erase until intersection
    for (var j = 0; j < sub.y; j++) {
        var i = sub.x - 1;
        if (pacman_map_get_tile_state(result, i, j, sub.x, sub.y, midX) == TileState.PATH) {
            pacman_map_erase_until_intersection(result, i, j, sub.x, sub.y, midX);
        }
    }
    
    // Set path blanks (Pacman)
    pacman_map_set_tile(result, 1, sub.y - 8, TileState.PATHBLANK, sub.x, sub.y, midX);
    
    // Additional path blank logic (simplified - see original for full implementation)
	// this is the empty path around the GHOST house location
    for (var i = 0; i < 7; i++) {
        var j = sub.y - 14;
        pacman_map_set_tile(result, i, j, TileState.PATHBLANK, sub.x, sub.y, midX);
        var jOffset = 1;
        if (pacman_map_get_tile_state(result, i, j + jOffset, sub.x, sub.y, midX) == TileState.PATH &&
               pacman_map_get_tile_state(result, i - 1, j + jOffset, sub.x, sub.y, midX) == TileState.WALL &&
               pacman_map_get_tile_state(result, i + 1, j + jOffset, sub.x, sub.y, midX) == TileState.WALL) {
            pacman_map_set_tile(result, i, j + jOffset, TileState.PATHBLANK, sub.x, sub.y, midX);
            jOffset++;
        }
        
        j = sub.y - 20;
        pacman_map_set_tile(result, i, j, TileState.PATHBLANK, sub.x, sub.y, midX);
        var j0 = 1;
        if (pacman_map_get_tile_state(result, i, j - j0, sub.x, sub.y, midX) == TileState.PATH &&
               pacman_map_get_tile_state(result, i - 1, j - j0, sub.x, sub.y, midX) == TileState.WALL &&
               pacman_map_get_tile_state(result, i + 1, j - j0, sub.x, sub.y, midX) == TileState.WALL) {
            pacman_map_set_tile(result, i, j - j0, TileState.PATHBLANK, sub.x, sub.y, midX);
            j0++;
        }
    }
    
    for (var n = 0; n < 7; n++) {
        var i = 6;
        var j = sub.y - 14 - n;
        pacman_map_set_tile(result, i, j, TileState.PATHBLANK, sub.x, sub.y, midX);
        var j0 = 1;
        if (pacman_map_get_tile_state(result, i, j, sub.x, sub.y, midX) == TileState.PATH &&
               pacman_map_get_tile_state(result, i-1, j, sub.x, sub.y, midX) == TileState.WALL &&
               pacman_map_get_tile_state(result, i+1, j, sub.x, sub.y, midX) == TileState.WALL) {
            pacman_map_set_tile(result, i, j, TileState.PATHBLANK, sub.x, sub.y, midX);
        }
    }
    
	// set the Pacman, and Ghost locations
	result[14][23].state = TileState.PACMAN;
	//result[12][11].state = TileState.BLINKY;
	//result[12][14].state = TileState.PINKY;
	//result[13][14].state = TileState.INKY;
	//result[14][14].state = TileState.CLYDE;
	result[14][17].state = TileState.FRUIT;
	
    tileMap = result;
    return result;
}

/// @description Set tile state (with symmetry)
function pacman_map_set_tile(tM, i, j, state, w, h, midX) {
    if (i < 0 || i >= w || j < 0 || j >= h) {
        return;
    }
    
    i -= 2;
    tM[midX + i][j].state = state;
    tM[midX - 1 - i][j].state = state;
}

/// @description Get tile state
function pacman_map_get_tile_state(tM, i, j, w, h, midX) {
    if (i < 0 || i >= w || j < 0 || j >= h) {
        return -1;
    }
    
    i -= 2;
    return tM[midX + i][j].state;
}

/// @description Get valid range for top energizer placement
function pacman_map_get_top_energizer_range(tM, w, h, midX) {
    var i = w - 2;
    var miny = 0;
    var maxy = h div 2;
    
    for (var j = 1; j < maxy; j++) {
        if (pacman_map_get_tile_state(tM, i, j, w, h, midX) == TileState.PATH &&
            pacman_map_get_tile_state(tM, i, j + 1, w, h, midX) == TileState.PATH) {
            miny = j + 1;
            break;
        }
    }
    
    maxy = min(h div 2, miny + 7);
    
    for (var j = miny + 1; j < maxy; j++) {
        if (pacman_map_get_tile_state(tM, i - 1, j, w, h, midX) == TileState.PATH) {
            maxy = j;
            break;
        }
    }
    
    return [miny, maxy - 1];
}

/// @description Get valid range for bottom energizer placement
function pacman_map_get_bot_energizer_range(tM, w, h, midX) {
    var i = w - 2;
    var miny = h div 2;
    var maxy = 0;
    
    for (var j = h - 3; j >= miny; j--) {
        if (pacman_map_get_tile_state(tM, i, j, w, h, midX) == TileState.PATH &&
            pacman_map_get_tile_state(tM, i, j + 1, w, h, midX) == TileState.PATH) {
            maxy = j;
            break;
        }
    }
    
    miny = max(h div 2, maxy - 7);
    
    for (var j = maxy - 1; j > miny; j--) {
        if (pacman_map_get_tile_state(tM, i - 1, j, w, h, midX) == TileState.PATH) {
            miny = j + 1;
            break;
        }
    }
    
    return [miny, maxy - 1];
}

/// @description Mark path leading into tunnel as PATHTUNNEL
function pacman_map_mark_tunnel_path(tM, startI, j, w, h, midX) {
    var i = startI;
    
    // Trace left from tunnel, marking PATH tiles as PATHTUNNEL
    while (i >= 0) {
      
        // Check if we've reached an intersection (vertical paths indicate intersection)
        var hasVerticalPath = false;
        var upState = pacman_map_get_tile_state(tM, i, j - 1, w, h, midX);
        var downState = pacman_map_get_tile_state(tM, i, j + 1, w, h, midX);
        
        if ((upState == TileState.PATH) || (downState == TileState.PATH)) {
            hasVerticalPath = true;
			
			break;
        }
        
        var currentState = pacman_map_get_tile_state(tM, i, j, w, h, midX);
		
        // If current tile is PATH, mark it as PATHTUNNEL
        if (currentState == TileState.PATH || currentState == TileState.PATHBLANK) {
            pacman_map_set_tile(tM, i, j, TileState.PATHTUNNEL, w, h, midX);
        } else if (currentState != TileState.PATHTUNNEL) {
            // Stop if we hit a non-path tile
            break;
        }
		
        //// Check next tile to the left
        //var nextState = pacman_map_get_tile_state(tM, i - 1, j, w, h, midX);
        //if (nextState != TileState.PATHBLANK && nextState != TileState.PATHTUNNEL) {
        //    // No more path to the left, stop
        //    break;
        //}
        
        // Move left
        i--;
    }
}

/// @description Erase path until intersection
function pacman_map_erase_until_intersection(tM, i, j, w, h, midX) {
    while (true) {
        var adj = [];
        
        if (pacman_map_get_tile_state(tM, i - 1, j, w, h, midX) == TileState.PATH) {
            array_push(adj, new intTuple_create(i - 1, j));
        }
        if (pacman_map_get_tile_state(tM, i + 1, j, w, h, midX) == TileState.PATH) {
            array_push(adj, new intTuple_create(i + 1, j));
        }
        if (pacman_map_get_tile_state(tM, i, j - 1, w, h, midX) == TileState.PATH) {
            array_push(adj, new intTuple_create(i, j - 1));
        }
        if (pacman_map_get_tile_state(tM, i, j + 1, w, h, midX) == TileState.PATH) {
            array_push(adj, new intTuple_create(i, j + 1));
        }
        
        if (array_length(adj) == 1) {
            pacman_map_set_tile(tM, i, j, TileState.PATHBLANK, w, h, midX);
            i = adj[0].x;
            j = adj[0].y;
        } else {
            break;
        }
    }
}

/// @description Get tile state from tile map
function pacman_map_get_tile_from_map(tM, i, j) {
    if (i < 0 || i >= array_length(tM) || j < 0 || j >= array_length(tM[0])) {
        return -1;
    }
    return tM[i][j].state;
}



/// @description Print ASCII representation of the generated maze map
/// @param tileMap 2D array of Tile structures
function pacman_map_print_ascii(tileMap) {
    if (is_undefined(tileMap) || array_length(tileMap) == 0) {
        show_debug_message("ERROR: tileMap is undefined or empty");
        return;
    }
    
    var mapWidth = array_length(tileMap);
    var mapHeight = array_length(tileMap[0]);
    
    show_debug_message("=== PACMAN MAZE (ASCII) ===");
    show_debug_message("Width: " + string(mapWidth) + " tiles");
    show_debug_message("Height: " + string(mapHeight) + " tiles");
    show_debug_message("");
    
    // Build the ASCII representation row by row
    var asciiMap = "";
    var nPills = 0;
	
    for (var j = 0; j < mapHeight; j++) {
        var row = "";
        for (var i = 0; i < mapWidth; i++) {
            var tile = tileMap[i][j];
            var char = "?";
            
            switch (tile.state) {
                case TileState.BLANK:
                    char = " ";  // Space for blank/void
                    break;
                case TileState.PATH:
                    char = ".";  // Dot for pellet path
					nPills++;
                    break;
                case TileState.PATHBLANK:
                    char = " ";  // Space for empty path/tunnel
                    break;
				case TileState.PATHTUNNEL:
                    char = "T";  // Space for empty path/tunnel
                    break;
                case TileState.WALL:
                    char = "#";  // Hash for wall
                    break;
                case TileState.GHOSTWALL:
                    char = "=";  // Equals for ghost wall
                    break;
                case TileState.ENERGIZER:
                    char = "O";  // O for energizer
                    break;
                case TileState.GHOSTSPACE:
                    char = "G";  // G for ghost space
                    break;
				case TileState.PACMAN:
					char = "M";
					break;
				case TileState.BLINKY:
					char = "B";
					break;
				case TileState.PINKY:
					char = "P";
					break;
				case TileState.INKY:
					char = "I";
					break;
				case TileState.CLYDE:
					char = "C";
					break;
				case TileState.FRUIT:
					char = "F";
					break;
                default:
                    char = "?";
                    break;
            }
            
            row += char;
        }
        asciiMap += row + "\n";
    }
    
    // Print the ASCII map
    show_debug_message(asciiMap);
    
    // Print legend
	show_debug_message("number of power pills: " + string(nPills));
    show_debug_message("Legend:");
    show_debug_message("  [ ] = Blank/Void");
    show_debug_message("  [.] = Path (pellet)");
    show_debug_message("  [ ] = Path (empty/tunnel)");
    show_debug_message("  [#] = Wall");
    show_debug_message("  [=] = Ghost Wall");
    show_debug_message("  [O] = Energizer");
    show_debug_message("  [G] = Ghost Space");
    show_debug_message("============================");
}