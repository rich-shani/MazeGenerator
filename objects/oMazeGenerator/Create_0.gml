// Object: oMazeGenerator
// Event: Create
// This event runs when the maze generator object is first created in the room.
// It generates a new procedural Pacman-style maze and prepares it for rendering.

// Generate a new procedural maze
// This function uses a complex algorithm to create a maze that matches
// the style and structure of classic Pacman mazes. It may attempt multiple
// generations until it finds one that meets quality criteria.
pacman_map_generate();

// Get the tile map (2D array of Tile structures)
// The tile map represents the final rendered maze with all tiles in their
// final states (walls, paths, pellets, etc.)
var tileMap = pacman_map_get_tile_map();

// Print ASCII representation of the maze to debug output
// Useful for debugging and visualizing the generated maze structure
pacman_map_print_ascii(tileMap);

// Get the sprite map JSON string
// Converts the tile map into a JSON format compatible with tile map editors
// (like Tiled). The JSON contains sprite indices for each tile position.
var spriteMapJson = pacman_map_get_sprite_map_index(tileMap);

// Parse and use the sprite map
// Parse the JSON string into a data structure we can use for rendering
mapData = json_parse(spriteMapJson);

// Extract layer data - the actual tile indices array
// This is a 1D array of sprite indices, row-major order
layerData = mapData.layers[0].data;

// Extract map dimensions from the JSON data
mapWidth = mapData.layers[0].width;   // Width in tiles (typically 28)
mapHeight = mapData.layers[0].height;  // Height in tiles (typically 31)

