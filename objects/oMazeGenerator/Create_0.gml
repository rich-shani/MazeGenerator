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
mapData = json_parse(spriteMapJson);
layerData = mapData.layers[0].data;
mapWidth = mapData.layers[0].width;
mapHeight = mapData.layers[0].height;

