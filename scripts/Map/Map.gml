/// @description Cell map dimensions
#macro CELL_MAP_SIZE_X 5
#macro CELL_MAP_SIZE_Y 9

/// @description Tile map calculation constants
#macro TILE_SCALE_X 3
#macro TILE_SCALE_Y 3
#macro TILE_OFFSET_X 2
#macro TILE_OFFSET_Y 1
#macro TILE_EXTRA_Y 3

/// @description Initialize PacmanMap object variables
function pacman_map_init() {
    // Initialize arrays
    cellMap = undefined;
    tileMap = undefined;
    
    // Initialize tallRows (one per column)
    tallRows = array_create(CELL_MAP_SIZE_X);
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        tallRows[i] = -1;  // -1 means no tall row in this column
    }
    
    // Initialize narrowCols (one per row)
    narrowCols = array_create(CELL_MAP_SIZE_Y);
    for (var i = 0; i < CELL_MAP_SIZE_Y; i++) {
        narrowCols[i] = -1;  // -1 means no narrow column in this row
    }
    
    // Reset generation counter
    genCount = 0;
    
    // Reset Cell static counter
    Cell_create.numFilled = 0;
}

/// @description Get cell map
/// @returns 2D array of cells
function pacman_map_get_cell_map() {
    return cellMap;
}

/// @description Get cell at position
/// @param x X coordinate
/// @param y Y coordinate
/// @returns Cell structure or noone
function pacman_map_get_cell(x, y) {
    if (x < 0 || x >= CELL_MAP_SIZE_X || y < 0 || y >= CELL_MAP_SIZE_Y) {
        return noone;
    }
    return cellMap[x][y];
}

/// @description Get tile at position
/// @param x X coordinate
/// @param y Y coordinate
/// @returns Tile structure or noone
function pacman_map_get_tile(x, y) {
    if (tileMap == undefined) return noone;
    if (x < 0 || x >= array_length(tileMap) || 
        y < 0 || y >= array_length(tileMap[0])) {
        return noone;
    }
    return tileMap[x][y];
}

/// @description Get tile state at position
/// @param x X coordinate
/// @param y Y coordinate
/// @returns Tile state or -1 if invalid
//function pacman_map_get_tile_state(x, y) {
//    var tile = pacman_map_get_tile(x, y);
//    if (tile == noone) return -1;
//    return tile.state;
//}


/// @description Set tile state at position
/// @param x X coordinate
/// @param y Y coordinate
/// @param state New tile state
function pacman_map_set_tile_state(x, y, state) {
    var tile = pacman_map_get_tile(x, y);
    if (tile != noone) {
        Tile_setState(tile, state);
    }
}

/// @description Get tall rows array
/// @returns Array of tall row positions
function pacman_map_get_tall_rows() {
    return tallRows;
}

/// @description Get narrow columns array
/// @returns Array of narrow column positions
function pacman_map_get_narrow_cols() {
    return narrowCols;
}

/// @description Get generation count
/// @returns Number of generation attempts
function pacman_map_get_gen_count() {
    return genCount;
}

