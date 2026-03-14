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
                var dirToConnect = (cell.position.y == 0) ? GRID_DIRECTION.UP : GRID_DIRECTION.DOWN;
                cell.connections[dirToConnect] = true;
                singleCount[singleCountPos]++;
                numGroups++;
                continue;
            }
        }
        
        var size = 1;
        
        if (cell.position.x == CELL_MAP_SIZE_X - 1) {
            cell.connections[GRID_DIRECTION.RIGHT] = true;
            cell.isRaiseHeightCandidate = true;
        } else {
            while (size < 5) {
                var stop = false;
                
                // Size 2 extension logic
                if (size == 2) {
                    var c = firstCell;
                    if (c.position.x > 0 && c.connections[GRID_DIRECTION.RIGHT] &&
                        c.next[GRID_DIRECTION.RIGHT] != noone &&
                        c.next[GRID_DIRECTION.RIGHT].next[GRID_DIRECTION.RIGHT] != noone) {
                        if (longPieces < MAX_LONG_PIECES &&
                            random(1.0) < probExtendAtSize2) {
                            var chosenDir = -1;
                            c = c.next[GRID_DIRECTION.RIGHT].next[GRID_DIRECTION.RIGHT];
                            var dirs = [false, false, false, false];
                            
                            if (c.isOpen(GRID_DIRECTION.UP)) dirs[GRID_DIRECTION.UP] = true;
                            if (c.isOpen(GRID_DIRECTION.DOWN)) dirs[GRID_DIRECTION.DOWN] = true;
                            
                            if (dirs[GRID_DIRECTION.UP] && dirs[GRID_DIRECTION.DOWN]) {
                                chosenDir = (random(1.0) < 0.5) ? GRID_DIRECTION.UP : GRID_DIRECTION.DOWN;
                            } else if (dirs[GRID_DIRECTION.UP]) {
                                chosenDir = GRID_DIRECTION.UP;
                            } else if (dirs[GRID_DIRECTION.DOWN]) {
                                chosenDir = GRID_DIRECTION.DOWN;
                            }
                            
                            if (chosenDir != -1) {
                                c.connect(GRID_DIRECTION.LEFT);
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
                            if (c.connections[GRID_DIRECTION.UP]) {
                                c = c.next[GRID_DIRECTION.UP];
                            }
                            c.connections[GRID_DIRECTION.RIGHT] = true;
                            if (c.next[GRID_DIRECTION.DOWN] != noone) {
                                c.next[GRID_DIRECTION.DOWN].connections[GRID_DIRECTION.RIGHT] = true;
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
            if ((c.position.x == 0 || !q[GRID_DIRECTION.LEFT]) &&
                (c.position.x == CELL_MAP_SIZE_X - 1 || !q[GRID_DIRECTION.RIGHT]) &&
                q[GRID_DIRECTION.UP] != q[GRID_DIRECTION.DOWN]) {
                c.isRaiseHeightCandidate = true;
            }
            
            // Check pair for raise height
            var c2 = c.next[GRID_DIRECTION.RIGHT];
            if (c2 != noone) {
                var q2 = c2.connections;
                if (((c.position.x == 0 || !q[GRID_DIRECTION.LEFT]) && !q[GRID_DIRECTION.UP] && !q[GRID_DIRECTION.DOWN]) &&
                    ((c2.position.x == CELL_MAP_SIZE_X - 1 || !q2[GRID_DIRECTION.RIGHT]) &&
                     !q2[GRID_DIRECTION.UP] && !q2[GRID_DIRECTION.DOWN])) {
                    c.isRaiseHeightCandidate = true;
                    c2.isRaiseHeightCandidate = true;
                }
            }
            
            // Shrink width candidate
            if (c.position.x == CELL_MAP_SIZE_X - 1 && q[GRID_DIRECTION.RIGHT]) {
                c.isShrinkWidthCandidate = true;
            }
            
            if ((c.position.y == 0 || !q[GRID_DIRECTION.UP]) &&
                (c.position.y == CELL_MAP_SIZE_Y - 1 || !q[GRID_DIRECTION.DOWN]) &&
                q[GRID_DIRECTION.LEFT] != q[GRID_DIRECTION.RIGHT]) {
                c.isShrinkWidthCandidate = true;
            }
        }
    }
}

/// @description Check if generated maze meets quality criteria
function pacman_map_is_desirable() {
    // Check top right corner
    var c = cellMap[CELL_MAP_SIZE_X - 1][0];
    if (c.connections[GRID_DIRECTION.UP] || c.connections[GRID_DIRECTION.RIGHT]) {
        return false;
    }
    
    // Check bottom right corner
    c = cellMap[CELL_MAP_SIZE_X - 1][CELL_MAP_SIZE_Y - 1];
    if (c.connections[GRID_DIRECTION.DOWN] || c.connections[GRID_DIRECTION.RIGHT]) {
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
                cellMap[i][j].connections[GRID_DIRECTION.DOWN] = true;
                cellMap[i][j].connections[GRID_DIRECTION.RIGHT] = true;
                cellMap[i + 1][j].connections[GRID_DIRECTION.DOWN] = true;
                cellMap[i + 1][j].connections[GRID_DIRECTION.LEFT] = true;
                cellMap[i + 1][j].group = g;
                cellMap[i][j + 1].connections[GRID_DIRECTION.UP] = true;
                cellMap[i][j + 1].connections[GRID_DIRECTION.RIGHT] = true;
                cellMap[i][j + 1].group = g;
                cellMap[i + 1][j + 1].connections[GRID_DIRECTION.UP] = true;
                cellMap[i + 1][j + 1].connections[GRID_DIRECTION.LEFT] = true;
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
    
    return !q1[GRID_DIRECTION.UP] && !q1[GRID_DIRECTION.DOWN] && (i == 0 || !q1[GRID_DIRECTION.LEFT]) &&
           q1[GRID_DIRECTION.RIGHT] && !q2[GRID_DIRECTION.UP] && !q2[GRID_DIRECTION.DOWN] &&
           q2[GRID_DIRECTION.LEFT] && !q2[GRID_DIRECTION.RIGHT];
}

/// @description Check if cells are stacked vertically
function pacman_map_is_stacked_vertical(i, j) {
    var q1 = cellMap[i][j].connections;
    var q2 = cellMap[i][j + 1].connections;
    
    if (i == CELL_MAP_SIZE_X - 1) {
        return !q1[GRID_DIRECTION.LEFT] && !q1[GRID_DIRECTION.UP] && !q1[GRID_DIRECTION.DOWN] &&
               !q2[GRID_DIRECTION.LEFT] && !q2[GRID_DIRECTION.UP] && !q2[GRID_DIRECTION.DOWN];
    }
    
    return !q1[GRID_DIRECTION.LEFT] && !q1[GRID_DIRECTION.RIGHT] && !q1[GRID_DIRECTION.UP] &&
           q1[GRID_DIRECTION.DOWN] && !q2[GRID_DIRECTION.LEFT] && !q2[GRID_DIRECTION.RIGHT] &&
           q2[GRID_DIRECTION.UP] && !q2[GRID_DIRECTION.DOWN];
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
        c2 = c.next[GRID_DIRECTION.RIGHT];
        if ((!c.connections[GRID_DIRECTION.UP] || c.isCrossCenter()) &&
            (!c2.connections[GRID_DIRECTION.UP] || c2.isCrossCenter())) {
            break;
        }
    }
    
    var candidates = [];
    while (c2 != noone) {
        if (c2.isRaiseHeightCandidate) {
            array_push(candidates, c2);
        }
        
        if ((!c2.connections[GRID_DIRECTION.DOWN] || c2.isCrossCenter()) &&
            (!c2.next[GRID_DIRECTION.LEFT].connections[GRID_DIRECTION.DOWN] ||
             c2.next[GRID_DIRECTION.LEFT].isCrossCenter())) {
            break;
        }
        c2 = c2.next[GRID_DIRECTION.DOWN];
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
        c2 = c.next[GRID_DIRECTION.DOWN];
        if ((!c.connections[GRID_DIRECTION.RIGHT] || c.isCrossCenter()) &&
            (!c2.connections[GRID_DIRECTION.RIGHT] || c.isCrossCenter())) {
            break;
        }
    }
    
    var candidates = [];
    while (c2 != noone) {
        if (c2.isShrinkWidthCandidate) {
            array_push(candidates, c2);
        }
        
        if ((!c2.connections[GRID_DIRECTION.LEFT] || c2.isCrossCenter()) &&
            (!c2.next[GRID_DIRECTION.UP].connections[GRID_DIRECTION.LEFT] ||
             c2.next[GRID_DIRECTION.UP].isCrossCenter())) {
            break;
        }
        c2 = c2.next[GRID_DIRECTION.LEFT];
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