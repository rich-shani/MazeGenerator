/// ===============================================================================
/// PACMAN_MAZE_RESET - Cell map init and ghost space setup
/// ===============================================================================
/// Responsibility: Reset the 5×9 cell grid and leftmost-empty helper for generation.
/// Called by: pacman_map_generate() at start of each attempt.
/// Globals used: cellMap, tallRows, narrowCols (written); Cell_create.numFilled (read).
/// ===============================================================================

/// @description Reset the cell map for new generation
function pacman_map_reset() {
    Cell_create.numFilled = 0;
    
    var _cellMap = array_create(CELL_MAP_SIZE_X);
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        _cellMap[i] = array_create(CELL_MAP_SIZE_Y);
        for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
            _cellMap[i][j] = new Cell_create(i, j);
        }
    }
    
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = _cellMap[i][j];
            c.next[CellDirection.LEFT] = (i > 0) ? _cellMap[i-1][j] : noone;
            c.next[CellDirection.RIGHT] = (i < CELL_MAP_SIZE_X - 1) ? _cellMap[i+1][j] : noone;
            c.next[CellDirection.UP] = (j > 0) ? _cellMap[i][j-1] : noone;
            c.next[CellDirection.DOWN] = (j < CELL_MAP_SIZE_Y - 1) ? _cellMap[i][j+1] : noone;
        }
    }
    
    _cellMap[0][3].isGhostSpace = true;
    _cellMap[0][3].filled = true;
    _cellMap[0][3].connections[CellDirection.LEFT] = true;
    _cellMap[0][3].connections[CellDirection.RIGHT] = true;
    _cellMap[0][3].connections[CellDirection.DOWN] = true;
    
    _cellMap[1][3].isGhostSpace = true;
    _cellMap[1][3].filled = true;
    _cellMap[1][3].connections[CellDirection.LEFT] = true;
    _cellMap[1][3].connections[CellDirection.DOWN] = true;
    
    _cellMap[0][4].isGhostSpace = true;
    _cellMap[0][4].filled = true;
    _cellMap[0][4].connections[CellDirection.LEFT] = true;
    _cellMap[0][4].connections[CellDirection.RIGHT] = true;
    _cellMap[0][4].connections[CellDirection.UP] = true;
    
    _cellMap[1][4].isGhostSpace = true;
    _cellMap[1][4].filled = true;
    _cellMap[1][4].connections[CellDirection.LEFT] = true;
    _cellMap[1][4].connections[CellDirection.UP] = true;
    
    tallRows = array_create(CELL_MAP_SIZE_X);
    narrowCols = array_create(CELL_MAP_SIZE_Y);
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) tallRows[i] = -1;
    for (var i = 0; i < CELL_MAP_SIZE_Y; i++) narrowCols[i] = -1;
    
    cellMap = _cellMap;
}

/// @description Get leftmost empty cells for generation
function pacman_map_get_leftmost_empty_cells() {
    var result = [];
    if (is_undefined(cellMap)) {
        show_debug_message("ERROR: cellMap is undefined in pacman_map_get_leftmost_empty_cells");
        return result;
    }
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
            var c = cellMap[i][j];
            if (c != noone && !c.filled) array_push(result, c);
        }
        if (array_length(result) > 0) break;
    }
    return result;
}
