/// @description Generate sprite map index string (JSON format)
/// Converts the tile map into a JSON string compatible with tile map editors (like Tiled).
/// Each tile state is converted to a sprite index that corresponds to a frame in the tileset.
/// The JSON format includes layer data with tile indices in row-major order.
/// This allows the generated maze to be exported and used in other tools or saved to files.
/// @param tileMap 2D array of Tile structures representing the generated maze
/// @returns JSON string containing tile map data with sprite indices for rendering
function pacman_map_get_sprite_map_index(tileMap) {
    // Create a 2D array to store sprite indices (same dimensions as tileMap)
    // This array will hold the sprite frame numbers for each tile position
    var spriteMap = array_create(array_length(tileMap));
    for (var i = 0; i < array_length(tileMap); i++) {
        spriteMap[i] = array_create(array_length(tileMap[0]));
    }
    
    // Start building the JSON string with layer structure
    // Format matches Tiled map editor JSON format
    var s = "{\n\"layers\":[\n\t{\n\t\"data\":[";
    
    // Get map dimensions
    var mapHeight = array_length(tileMap[0]);  // Height (number of rows)
    var mapWidth = array_length(tileMap);       // Width (number of columns)
    
    // Iterate through each tile and convert state to sprite index
    // Process row by row, left to right (row-major order)
    for (var j = 0; j < mapHeight; j++) {
        for (var i = 0; i < mapWidth; i++) {
            // Get the tile state at this position
            var t11 = pacman_map_get_tile_from_map(tileMap, i, j);
            
            // String to append to JSON (sprite index followed by comma)
            var n = "";
            
            // Convert tile state to sprite index based on tile type
            // Each tile type maps to a specific sprite frame in the tileset
            if (t11 == TileState.PATH) {
                // Regular path tile with pellet - use sprite index 30
                // This is the sprite that shows a path with a small pellet dot
                spriteMap[i][j] = 30;
                n = "30,";
            } else if (t11 == TileState.PATHBLANK) {
                // Empty path (no pellet) - use sprite index 0 (empty/transparent)
                // Used in tunnels and areas where paths exist but no pellets
                spriteMap[i][j] = 0;
                n = "0,";
            } else if (t11 == TileState.PATHTUNNEL) {
                // Tunnel path - use sprite index 31 (tunnel tile graphic)
                // Special graphic for the wrap-around tunnel areas
                spriteMap[i][j] = 31;
                n = "31,";
            } else if (t11 == TileState.BLANK || t11 == TileState.GHOSTSPACE) {
                // Blank space or ghost space - use sprite index 0 (empty)
                // These areas are not rendered (transparent/void)
                spriteMap[i][j] = 0;
                n = "0,";
            } else if (t11 == TileState.ENERGIZER) {
                // Power pellet (energizer) - use sprite index 29
                // Large pellet that makes ghosts vulnerable when collected
                spriteMap[i][j] = 29;
                n = "29,";
            } else if (t11 == TileState.GHOSTWALL) {
                // Ghost wall (ghosts can pass through) - use sprite index 19
                // Special wall sprite for the ghost house entrance
                spriteMap[i][j] = 19;
                n = "19,";
            } else if (t11 == TileState.WALL) {
                // Regular wall - calculate which wall sprite to use based on neighbors
                // This determines the correct wall tile (corner, edge, straight, etc.)
                // The function analyzes adjacent tiles to pick the right wall graphic
                var tileDrawn = pacman_map_calculate_wall_tile(tileMap, i, j, mapWidth, mapHeight);
                spriteMap[i][j] = tileDrawn;
                n = string(tileDrawn) + ",";
            } else if (t11 == TileState.PACMAN) {
				// Pacman start location
				spriteMap[i][j] = 28;
				n = "28,";
			} 
			else if (t11 == TileState.BLINKY) {
				// Blinky start location
				spriteMap[i][j] = 36;
				n = "36,";
			}
			else if (t11 == TileState.PINKY) {
				// Pinky start location
				spriteMap[i][j] = 35;
				n = "35,";				
			}
			else if (t11 == TileState.INKY) {
				// Inky start location
				spriteMap[i][j] = 36;
				n = "33,";				
			}
			else if (t11 == TileState.CLYDE) {
				// Clyde start location
				spriteMap[i][j] = 34;
				n = "34,";			
			}
			else if (t11 == TileState.FRUIT) {
				// Fruit location
				spriteMap[i][j] = 32;
				n = "32,";					
			}
            
            // Append sprite index to JSON string
            s += n;
        }
    }
    
    // Complete the JSON string with dimensions and closing braces
    // Note: dimensions are hardcoded to 28x31 (standard Pacman maze size)
    // The data array is in row-major order (all tiles from row 0, then row 1, etc.)
    s += "],\n\t\"height\":31,\n\t\"width\":28\n\t}]\n}";
    
    return s;
}