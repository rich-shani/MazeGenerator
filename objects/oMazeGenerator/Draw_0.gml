// Render the map

// top 3 rows are for the 1UP, HIGHSCORE
var offset = 96; // 3 rows of 32 sprites in height

for (var row = 0; row < mapHeight; row++) {
    for (var col = 0; col < mapWidth; col++) {
        var index = row * mapWidth + col;
        var spriteIndex = layerData[index]; // Tiled uses 1-based indexing
        
        if (spriteIndex >= 0) {
            // Draw sprite at position (col, row)
            draw_sprite(maze_blue_red, spriteIndex, col * 32, offset+(row * 32));
        }
    }
}