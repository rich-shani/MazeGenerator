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

    // Wire up neighbor pointers using GRID_DIRECTION indices
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = _cellMap[i][j];
            c.next[GRID_DIRECTION.LEFT]  = (i > 0)                    ? _cellMap[i-1][j] : noone;
            c.next[GRID_DIRECTION.RIGHT] = (i < CELL_MAP_SIZE_X - 1)  ? _cellMap[i+1][j] : noone;
            c.next[GRID_DIRECTION.UP]    = (j > 0)                    ? _cellMap[i][j-1] : noone;
            c.next[GRID_DIRECTION.DOWN]  = (j < CELL_MAP_SIZE_Y - 1)  ? _cellMap[i][j+1] : noone;
        }
    }

    // Pre-fill ghost space cells and set their connections
    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y0].isGhostSpace = true;
    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y0].filled = true;
    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y0].connections[GRID_DIRECTION.LEFT]  = true;
    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y0].connections[GRID_DIRECTION.RIGHT] = true;
    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y0].connections[GRID_DIRECTION.DOWN]  = true;

    _cellMap[GHOST_SPACE_X1][GHOST_SPACE_Y0].isGhostSpace = true;
    _cellMap[GHOST_SPACE_X1][GHOST_SPACE_Y0].filled = true;
    _cellMap[GHOST_SPACE_X1][GHOST_SPACE_Y0].connections[GRID_DIRECTION.LEFT] = true;
    _cellMap[GHOST_SPACE_X1][GHOST_SPACE_Y0].connections[GRID_DIRECTION.DOWN] = true;

    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y1].isGhostSpace = true;
    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y1].filled = true;
    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y1].connections[GRID_DIRECTION.LEFT]  = true;
    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y1].connections[GRID_DIRECTION.RIGHT] = true;
    _cellMap[GHOST_SPACE_X0][GHOST_SPACE_Y1].connections[GRID_DIRECTION.UP]    = true;

    _cellMap[GHOST_SPACE_X1][GHOST_SPACE_Y1].isGhostSpace = true;
    _cellMap[GHOST_SPACE_X1][GHOST_SPACE_Y1].filled = true;
    _cellMap[GHOST_SPACE_X1][GHOST_SPACE_Y1].connections[GRID_DIRECTION.LEFT] = true;
    _cellMap[GHOST_SPACE_X1][GHOST_SPACE_Y1].connections[GRID_DIRECTION.UP]   = true;

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
