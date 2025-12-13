// Render the map
// This event runs every frame to draw the generated maze on screen.
// It iterates through the sprite map data and draws each tile sprite.

// Top 3 rows are reserved for UI elements (1UP, HIGHSCORE text)
// Offset the maze rendering down by 96 pixels (3 rows × 32 pixels per row)
var offset = 96;

// Iterate through each row of the map
for (var row = 0; row < mapHeight; row++) {
    // Iterate through each column of the map
    for (var col = 0; col < mapWidth; col++) {
        // Calculate 1D array index from 2D coordinates (row-major order)
        // Formula: index = row * width + col
        var index = row * mapWidth + col;
        
        // Get sprite index from the layer data
        // The sprite index corresponds to which sprite frame to draw from the tileset
        // Note: Tiled uses 1-based indexing, but our data uses 0-based
        var spriteIndex = layerData[index];
        
        // Only draw if sprite index is valid (>= 0)
        // Negative indices indicate empty tiles that shouldn't be drawn
        if (spriteIndex >= 0) {
            // Draw the sprite at the calculated screen position
            // maze_blue_red: the sprite/tileset containing all maze tile graphics
            // spriteIndex: which frame from the tileset to draw
            // col * 32: X position (each tile is 32 pixels wide)
            // offset + (row * 32): Y position (each tile is 32 pixels tall, offset for UI)
            draw_sprite(maze_blue_red, spriteIndex, col * 32, offset + (row * 32));
        }
    }
}