/// ===============================================================================
/// PACMAN_MAZE_SPAWN - Spawn game entities from the tile map
/// ===============================================================================
/// Instantiates Wall, oDot, oPowerPill, Slow, oPacman, and Blinky from tile map state.
/// Call once after maze generation (e.g. from oMazeGenerator Step_1 with initializeGridElements guard).
/// ===============================================================================

/// @description Spawn all maze entities (walls, dots, ghosts, Pac-Man) from the tile map.
/// @param _tileMap 2D array of Tile structures
/// @param _x_offset World X offset for spawning
/// @param _y_offset World Y offset for spawning
/// @param _gridSize Pixel size of one tile (use TILE_PIXELS)
function pacman_map_spawn_entities(_tileMap, _x_offset, _y_offset, _gridSize) {
    var _mapWidth = array_length(_tileMap);
    var _mapHeight = array_length(_tileMap[0]);

    var elementX = _x_offset + (BLINKY_SPAWN_COL * _gridSize);
    var elementY = _y_offset + (BLINKY_SPAWN_ROW * _gridSize);
    instance_create_layer(elementX, elementY, "GameElements", oBlinky);

    for (var row = 0; row < _mapHeight; row++) {
        for (var col = 0; col < _mapWidth; col++) {
            elementX = _x_offset + (col * _gridSize);
            elementY = _y_offset + (row * _gridSize);
            var _tile = _tileMap[col][row];

            if (_tile.isWall()) {
                instance_create_layer(elementX, elementY, "GameElements", Wall);
            } else if (_tile.isGhostWall()) {
                instance_create_layer(elementX, elementY, "GameElements", GhostWall);
            } else if (_tile.hasPellet()) {
                instance_create_layer(elementX, elementY, "GameElements", oDot);
            } else if (_tile.isEnergizer()) {
                instance_create_layer(elementX, elementY, "GameElements", oPowerPill);
            } else if (_tile.isTunnel()) {
                instance_create_layer(elementX, elementY, "GameElements", Slow);
            } else if (_tile.isPacman()) {
                instance_create_layer(elementX, elementY, "GameElements", oPacman);
            }
        }
    }
}
