/// PACMAN_MAZE_GENERATION - Fill and validate cell structure
/// Responsibility: attempt_generate, is_desirable, resize/tall/narrow selection.
/// Globals: cellMap, tallRows, narrowCols.

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