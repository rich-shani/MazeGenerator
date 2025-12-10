// Object: oMazeGenerator
// Event: Create

// Generate maze when object is created
// Generate a new maze
pacman_map_generate();

// Get the tile map
var tileMap = pacman_map_get_tile_map();
pacman_map_print_ascii(tileMap);

// Get the sprite map JSON string
var spriteMapJson = pacman_map_get_sprite_map_index(tileMap);

// Parse and use the sprite map
var mapData = json_parse(spriteMapJson);
var layerData = mapData.layers[0].data;
var mapWidth = mapData.layers[0].width;
var mapHeight = mapData.layers[0].height;

// Render the map
for (var row = 0; row < mapHeight; row++) {
    for (var col = 0; col < mapWidth; col++) {
        var index = row * mapWidth + col;
        var spriteIndex = layerData[index] - 1; // Tiled uses 1-based indexing
        
        if (spriteIndex >= 0) {
            // Draw sprite at position (col, row)
            draw_sprite(spr_tileset, spriteIndex, col * TILE_SIZE, row * TILE_SIZE);
        }
    }
}