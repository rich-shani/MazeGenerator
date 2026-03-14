/// @description Cell map dimensions
/// The maze is generated at a high level using a 5x9 grid of cells.
/// Each cell is then expanded into a 3x3 (or variable size) grid of tiles.
/// This two-level approach allows for complex maze generation while maintaining
/// the classic Pacman maze structure.
#macro CELL_MAP_SIZE_X 5  // Width of cell map (5 cells)
#macro CELL_MAP_SIZE_Y 9  // Height of cell map (9 cells)

/// @description Ghost space cell positions in the 5x9 cell grid
#macro GHOST_SPACE_X0 0   // Left X of ghost space (columns 0-1)
#macro GHOST_SPACE_X1 1
#macro GHOST_SPACE_Y0 3   // Top Y of ghost space (rows 3-4)
#macro GHOST_SPACE_Y1 4

/// @description Cell rows where connections at x=0 are blocked to preserve the Pac-Man corridor
#macro CELL_BOUNDARY_ROW_A 6   // cell y=6: cannot connect DOWN at x=0
#macro CELL_BOUNDARY_ROW_B 7   // cell y=7: cannot connect UP at x=0

/// @description Tile map layout constants
/// Row offsets are from the bottom of the tile map (sub.y - OFFSET).
#macro TILEMAP_PACMAN_ROW_OFFSET         8   // Pac-Man path-blank row offset from bottom
#macro TILEMAP_GHOST_BLANK_BOTTOM_OFFSET 14  // Ghost house blank row (bottom side)
#macro TILEMAP_GHOST_BLANK_TOP_OFFSET    20  // Ghost house blank row (top side)
#macro TILEMAP_GHOST_BLANK_COL_COUNT      7  // Number of columns to apply ghost path blanks
#macro TILEMAP_GHOST_BLANK_COL_MAX        6  // Max column index for ghost path blanks
#macro TILEMAP_ENERGIZER_RANGE_SPAN       7  // Max row span for energizer placement search

/// @description Ghost wall tile position (in the half-width pre-symmetry coordinate space)
#macro GHOST_WALL_HALF_TILE_X  2
#macro GHOST_WALL_HALF_TILE_Y 12

/// @description Spawn tile positions in the full (mirrored) tile map
/// PACMAN_SPAWN_TILE_X = midX = CELL_MAP_SIZE_X*TILE_SCALE_X - 1 = 14
/// PACMAN_SPAWN_TILE_Y = sub.y - TILEMAP_PACMAN_ROW_OFFSET = 31 - 8 = 23
/// FRUIT_SPAWN_TILE_Y  = sub.y - TILEMAP_GHOST_BLANK_TOP_OFFSET + 3 = 17
#macro PACMAN_SPAWN_TILE_X 14
#macro PACMAN_SPAWN_TILE_Y 23
#macro FRUIT_SPAWN_TILE_X  14
#macro FRUIT_SPAWN_TILE_Y  17

/// @description Tile map calculation constants
/// These constants define how cells are scaled into tiles.
/// Each cell typically becomes a 3x3 block of tiles, but can be resized
/// during generation for variation (tall rows, narrow columns).
#macro TILE_SCALE_X 3     // Default tiles per cell width
#macro TILE_SCALE_Y 3     // Default tiles per cell height
#macro TILE_OFFSET_X 2    // X offset for tile positioning calculations
#macro TILE_OFFSET_Y 1    // Y offset for tile positioning calculations
#macro TILE_EXTRA_Y 3     // Extra tiles added to tile map height

/// @description Initialize PacmanMap object variables
/// Sets up all the global variables used for maze generation.
/// This should be called before generating a new maze to ensure clean state.
function pacman_map_init() {
    // Initialize arrays to undefined (will be created during generation)
    cellMap = undefined;  // 2D array of Cell structures (5x9)
    tileMap = undefined;  // 2D array of Tile structures (final rendered map)
    
    // Initialize tallRows array (one entry per column)
    // tallRows[i] stores the row index where column i has a "tall" cell (4 tiles high instead of 3)
    // -1 means no tall row in that column
    tallRows = array_create(CELL_MAP_SIZE_X);
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        tallRows[i] = -1;  // -1 means no tall row in this column
    }
    
    // Initialize narrowCols array (one entry per row)
    // narrowCols[j] stores the column index where row j has a "narrow" cell (2 tiles wide instead of 3)
    // -1 means no narrow column in that row
    narrowCols = array_create(CELL_MAP_SIZE_Y);
    for (var i = 0; i < CELL_MAP_SIZE_Y; i++) {
        narrowCols[i] = -1;  // -1 means no narrow column in this row
    }
    
    // Reset generation counter (tracks how many generation attempts were made)
    genCount = 0;
    
    // Reset Cell static counter (tracks total cells filled across all generations)
    Cell_create.numFilled = 0;
}

/// @description Get cell map
/// Returns the 2D array of Cell structures representing the high-level maze structure.
/// @returns 2D array of cells (cellMap[x][y]) or undefined if not initialized
function pacman_map_get_cell_map() {
    return cellMap;
}

/// @description Get cell at position
/// Retrieves a specific Cell from the cell map at the given coordinates.
/// Returns noone if coordinates are out of bounds.
/// @param x X coordinate in cell map (0 to CELL_MAP_SIZE_X-1)
/// @param y Y coordinate in cell map (0 to CELL_MAP_SIZE_Y-1)
/// @returns Cell structure at position (x, y) or noone if invalid
function pacman_map_get_cell(x, y) {
    // Check bounds before accessing array
    if (x < 0 || x >= CELL_MAP_SIZE_X || y < 0 || y >= CELL_MAP_SIZE_Y) {
        return noone;
    }
    return cellMap[x][y];
}

/// @description Get tile at position
/// Retrieves a specific Tile from the tile map at the given coordinates.
/// The tile map is the final rendered maze with all tiles in their final states.
/// @param x X coordinate in tile map (0-based)
/// @param y Y coordinate in tile map (0-based)
/// @returns Tile structure at position (x, y) or noone if invalid or map not created
function pacman_map_get_tile(x, y) {
    // Check if tile map exists
    if (tileMap == undefined) return noone;
    
    // Check bounds before accessing array
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
/// Changes the state of a tile in the tile map (e.g., from BLANK to PATH or WALL).
/// This is used during tile map generation to mark tiles appropriately.
/// @param x X coordinate in tile map
/// @param y Y coordinate in tile map
/// @param state New TileState value to assign
function pacman_map_set_tile_state(x, y, state) {
    var tile = pacman_map_get_tile(x, y);
    if (tile != noone) {
        tile.setState(state);
    }
}

/// @description Get tall rows array
/// Returns the array tracking which columns have "tall" cells (4 tiles high).
/// tallRows[i] = row index where column i has a tall cell, or -1 if none.
/// @returns Array of tall row positions (one per column, -1 if no tall row)
function pacman_map_get_tall_rows() {
    return tallRows;
}

/// @description Get narrow columns array
/// Returns the array tracking which rows have "narrow" cells (2 tiles wide).
/// narrowCols[j] = column index where row j has a narrow cell, or -1 if none.
/// @returns Array of narrow column positions (one per row, -1 if no narrow column)
function pacman_map_get_narrow_cols() {
    return narrowCols;
}

/// @description Get generation count
/// Returns the number of generation attempts made. This can be useful for
/// debugging or understanding how many attempts were needed to find a valid maze.
/// @returns Number of generation attempts (incremented each time generation is attempted)
function pacman_map_get_gen_count() {
    return genCount;
}

