// Render the map
// This event runs every frame to draw the generated maze on screen.
// It iterates through the sprite map data and draws each tile sprite.

// Top 3 rows are reserved for UI elements (1UP, HIGHSCORE text)
// Offset the maze rendering down by 96 pixels (3 rows × 32 pixels per row)
var x_offset = 352;
var y_offset = 168;
	
for (var row = 0; row < mapHeight; row++) {
	for (var col = 0; col < mapWidth; col++) {
		
		// draw wall components
		if (tileMap[col][row].isWall()) {
            // This determines the correct wall tile (corner, edge, straight, etc.)
            // The function analyzes adjacent tiles to pick the right wall graphic
            var spriteIndex = pacman_map_calculate_wall_tile(tileMap, col, row, mapWidth, mapHeight);			
            // Draw the sprite at the calculated screen position
            // col * 32: X position (each tile is 32 pixels wide)
            // offset + (row * 32): Y position (each tile is 32 pixels tall, offset for UI)
            draw_sprite(maze_green_yellow_dots, spriteIndex, x_offset + (col * 32), y_offset + (row * 32));
		}		
		else if (tileMap[col][row].hasPellet()) {
			instance_create_layer(x_offset + (col * 32), y_offset + (row * 32), "GameElements", oDot);
		}
		else if (tileMap[col][row].isEnergizer()) {
			instance_create_layer(x_offset + (col * 32), y_offset + (row * 32), "GameElements", oPowerPill);			
		}		
		else if (tileMap[col][row].isPacman()) {
			instance_create_layer(x_offset + (col * 32), y_offset + (row * 32), "GameElements", oPacman);			
		}
	}
}

//// Iterate through each row of the map
// using layerData

//for (var row = 0; row < mapHeight; row++) {
//    // Iterate through each column of the map
//    for (var col = 0; col < mapWidth; col++) {
//        // Calculate 1D array index from 2D coordinates (row-major order)
//        // Formula: index = row * width + col
//        var index = row * mapWidth + col;
        
//        // Get sprite index from the layer data
//        // The sprite index corresponds to which sprite frame to draw from the tileset
//        // Note: Tiled uses 1-based indexing, but our data uses 0-based
//        var spriteIndex = layerData[index];
        
//        // Only draw if sprite index is valid (>= 0)
//        // Negative indices indicate empty tiles that shouldn't be drawn
//        if (spriteIndex >= 0) {
//            // Draw the sprite at the calculated screen position
//            // maze_blue_red: the sprite/tileset containing all maze tile graphics
//            // spriteIndex: which frame from the tileset to draw
//            // col * 32: X position (each tile is 32 pixels wide)
//            // offset + (row * 32): Y position (each tile is 32 pixels tall, offset for UI)
//            draw_sprite(maze_green_yellow_dots, spriteIndex, col * 32, offset + (row * 32));
//        }
//    }
//}