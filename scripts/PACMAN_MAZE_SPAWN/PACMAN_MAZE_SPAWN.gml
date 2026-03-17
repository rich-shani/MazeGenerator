/// ===============================================================================
/// PACMAN_MAZE_SPAWN - Spawn game entities from the tile map
/// ===============================================================================
/// Instantiates Wall (with allowsGhost for ghost house), oDot, oPowerPill, Slow, oPacman, Blinky.
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
    instance_create_layer(elementX, elementY, "GameCharacters", oBlinky);
	// TODO: use the x, y parameters to set the Create location x,y 
    instance_create_layer(elementX, elementY, "GameCharacters", oPinky);
    instance_create_layer(elementX, elementY, "GameCharacters", oInky);
    instance_create_layer(elementX, elementY, "GameCharacters", oClyde);
	
    for (var row = 0; row < _mapHeight; row++) {
		
        for (var col = 0; col < _mapWidth; col++) {
            elementX = _x_offset + (col * _gridSize);
            elementY = _y_offset + (row * _gridSize);
            var _tile = _tileMap[col][row];

			if (_tile.isGhostWall() || _tile.isWall()) {
                var _wall = instance_create_layer(elementX, elementY, "GameElements", Wall);
                _wall.allowsGhost = _tile.isGhostWall();
			} else if (_tile.hasPellet()) {
                instance_create_layer(elementX, elementY, "GameElements", oDot);
            } else if (_tile.isEnergizer()) {
                instance_create_layer(elementX, elementY, "GameElements", oPowerPill);
            } else if (_tile.isTunnel()) {
                instance_create_layer(elementX, elementY, "GameElements", Slow);
            } else if (_tile.isPacman()) {
                instance_create_layer(elementX, elementY, "GameCharacters", oPacman);
            }
        }
    }
}

function pacman_map_gen_sprite_index(_tileMap) {
    var _mapWidth = array_length(_tileMap);
    var _mapHeight = array_length(_tileMap[0]);	
	
	for (var row = 0; row < _mapHeight; row++) {
		for (var col = 0; col < _mapWidth; col++) {
			
			if (_tileMap[col][row].isGhostWall()) {       
				_tileMap[col][row].spriteIndex = WALL_SPRITE_GHOST_ENTRANCE;			
			}
			else if (_tileMap[col][row].isWall()) {
	            // This determines the correct wall tile (corner, edge, straight, etc.)
	            // The function analyzes adjacent tiles to pick the right wall graphic
	            _tileMap[col][row].spriteIndex = pacman_map_calculate_wall_tile(_tileMap, col, row, _mapWidth, _mapHeight);          
			}
		}
	}
}