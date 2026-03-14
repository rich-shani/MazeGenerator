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
tileMap = pacman_map_get_tile_map();

mapHeight = array_length(tileMap[0]);
mapWidth = array_length(tileMap);

// Print ASCII representation of the maze to debug output
// Useful for debugging and visualizing the generated maze structure
pacman_map_print_ascii(tileMap);

initializeGridElements = false;

x_offset = 0;
y_offset = 0;
gridSize = TILE_PIXELS;
