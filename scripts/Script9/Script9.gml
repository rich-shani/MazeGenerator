/// @description Calculate which wall sprite to use based on neighbors
/// This function determines which wall sprite graphic to use for a wall tile based on
/// the states of its four cardinal neighbors (up, down, left, right). This creates
/// proper wall connections, corners, and edges that look correct in the final maze.
/// The algorithm checks patterns of adjacent tiles to select the appropriate wall sprite
/// from the tileset (corner pieces, straight walls, T-junctions, etc.).
/// @param tileMap 2D array of Tile structures representing the maze
/// @param i X coordinate of the wall tile
/// @param j Y coordinate of the wall tile
/// @param mapWidth Width of the tile map
/// @param mapHeight Height of the tile map
/// @returns Sprite index (0-31) corresponding to the correct wall graphic
function pacman_map_calculate_wall_tile(tileMap, i, j, mapWidth, mapHeight) {
	
//	4,9,6,17,30,29,24,26,

//0-==0
//4==1
//6==3
//9==2 if path below, 22 if path above
//17 == 11 if left, and 13 if right
//24==21
//26==23

//ghost house wall == 19
    // Get the states of the four cardinal neighbors
    // Naming convention: t[horizontal][vertical] where 0=left/up, 1=center, 2=right/down
    var t01 = pacman_map_get_tile_from_map(tileMap, i-1, j);  // Left neighbor
    var t21 = pacman_map_get_tile_from_map(tileMap, i+1, j);  // Right neighbor
    var t10 = pacman_map_get_tile_from_map(tileMap, i, j-1);  // Top neighbor
    var t12 = pacman_map_get_tile_from_map(tileMap, i, j+1);  // Bottom neighbor
    
    // Check if neighbors are path tiles (walkable areas)
    // bp = "border path" - true if neighbor is a path type (path, tunnel, energizer)
    // Used to determine if wall should have an edge facing that direction
    var bp01 = (t01 == TileState.PATHBLANK || t01 == TileState.PATH || t01 == TileState.PATHTUNNEL || t01 == TileState.ENERGIZER || t01 == TileState.PACMAN || t01 == TileState.FRUIT);
    var bp21 = (t21 == TileState.PATHBLANK || t21 == TileState.PATH || t21 == TileState.PATHTUNNEL || t21 == TileState.ENERGIZER || t21 == TileState.PACMAN || t21 == TileState.FRUIT);
    var bp10 = (t10 == TileState.PATHBLANK || t10 == TileState.PATH || t10 == TileState.PATHTUNNEL || t10 == TileState.ENERGIZER || t10 == TileState.PACMAN || t10 == TileState.FRUIT);
    var bp12 = (t12 == TileState.PATHBLANK || t12 == TileState.PATH || t12 == TileState.PATHTUNNEL || t12 == TileState.ENERGIZER || t12 == TileState.PACMAN || t12 == TileState.FRUIT);
    
    // Check if neighbors are blank/void tiles (empty space)
    // bgo = "border ghost/blank/out" - true if neighbor is blank, ghost space, or out of bounds
    // Used to determine if wall should face void space
    var bgo01 = (t01 == TileState.BLANK || t01 == TileState.GHOSTSPACE || t01 == -1);
    var bgo21 = (t21 == TileState.BLANK || t21 == TileState.GHOSTSPACE || t21 == -1);
    var bgo10 = (t10 == TileState.BLANK || t10 == TileState.GHOSTSPACE || t10 == -1);
    var bgo12 = (t12 == TileState.BLANK || t12 == TileState.GHOSTSPACE || t12 == -1);
    
    // Check if neighbors are wall tiles (solid walls)
    // w = "wall" - true if neighbor is also a wall (for wall-to-wall connections)
    var w01 = (t01 == TileState.WALL || t01 == TileState.GHOSTWALL);
    var w21 = (t21 == TileState.WALL || t21 == TileState.GHOSTWALL);
    var w10 = (t10 == TileState.WALL || t10 == TileState.GHOSTWALL);
    var w12 = (t12 == TileState.WALL || t12 == TileState.GHOSTWALL);
    
    // Sprite index to return (will be set based on neighbor patterns)
    var tileDrawn = -1;
    
    // Border column handling - check corners first, then borders
    // Corner tiles have special sprites since they're at map edges
    
    // Top-left corner (0, 0)
    // Uses sprite 4 - outer corner piece facing down and right
    if (i == 0 && j == 0) {
        tileDrawn = 1; //4;
    }
    // Top-right corner (mapWidth-1, 0)
    // Uses sprite 6 - outer corner piece facing down and left
    else if (i == mapWidth - 1 && j == 0) {
        tileDrawn = 3;//6;
    }
    // Bottom-left corner (0, mapHeight-1)
    // Uses sprite 24 - outer corner piece facing up and right
    else if (i == 0 && j == mapHeight - 1) {
        tileDrawn = 21;//24;
    }
    // Bottom-right corner (mapWidth-1, mapHeight-1)
    // Uses sprite 26 - outer corner piece facing up and left
    else if (i == mapWidth - 1 && j == mapHeight - 1) {
        tileDrawn = 23;//26;
    }
    // Left border (not corner) - tiles at x=0 but not at corners
    else if (i == 0) {
        // Pattern: wall right, wall above, wall below
        // Check if wall above has looped from left and is returning
        // This handles special cases where walls curve around paths
        if (w21 && w10 && w12) {
            // Check diagonal neighbor to see if wall has looped
            // This means checking if there's a wall to the right of the path above
            var t20 = pacman_map_get_tile_from_map(tileMap, i+1, j-1);
            var w20 = (t20 == TileState.WALL || t20 == TileState.GHOSTWALL);
            if (w20) {
                // Wall has looped from left and is returning, connect down
                // Use sprite 4 - corner piece connecting the loop
                tileDrawn = 1;//4;
            } else {
                // Normal horizontal wall connection
                // Use sprite 24 - vertical wall edge
                tileDrawn = 21;//24;
            }
        }
        // Pattern: wall right, wall above, path/void below
        // Wall continues vertically, path below means edge facing down
        else if (w21 && w10 && bgo12) {
            tileDrawn = 21;//24;
        }
        // Pattern: wall right, path/void above, wall below
        // Wall continues vertically, path above means edge facing up
        else if (w21 && w12 && bgo10) {
            tileDrawn = 1;//4;
        }
        // Pattern: wall right with path above or below
        // Horizontal wall connection - wall extends right, path on top or bottom
        // Use sprite 9 - horizontal wall edge
        else if (w21 && (bp10 || bp12)) {
            tileDrawn = 2;//9;
        }
        // Default left border (no wall connection to right)
        // Isolated wall piece or edge case
        // Use sprite 17 - standalone wall piece
        else {
            tileDrawn = 11;//17;
        }
    }
    // Right border (not corner) - tiles at x=mapWidth-1 but not at corners
    else if (i == mapWidth - 1) {
        // Pattern: wall left, wall above, wall below
        // Check if wall above has looped from right and is returning
        // Similar logic to left border but mirrored
        if (w01 && w10 && w12) {
            // Check diagonal neighbor to see if wall has looped
            var t00 = pacman_map_get_tile_from_map(tileMap, i-1, j-1);
            var w00 = (t00 == TileState.WALL || t00 == TileState.GHOSTWALL);
            if (w00) {
                // Wall has looped from right and is returning, connect down
                // Use sprite 6 - corner piece connecting the loop
                tileDrawn = 3;//6;
            } else {
                // Normal horizontal wall connection
                // Use sprite 26 - vertical wall edge
                tileDrawn = 23;//26;
            }
        }
        // Pattern: wall left, wall above, path/void below
        else if (w01 && w10 && bgo12) {
            tileDrawn = 23;//26;
        }
        // Pattern: wall left, path/void above, wall below
        else if (w01 && w12 && bgo10) {
            tileDrawn = 3;//6;
        }
        // Pattern: wall left with path above or below
        // Horizontal wall connection - wall extends left, path on top or bottom
        // Use sprite 9 - horizontal wall edge
        else if (w01 && (bp10 || bp12)) {
            tileDrawn = 2;//9;
        }
        // Default right border (no wall connection to left)
        // Use sprite 17 - standalone wall piece
        else {
            tileDrawn = 14;//17;
        }
    } else {
        // Interior tile logic - tiles not on map edges
        // These tiles can have walls on any side, so we need more complex pattern matching
        
        // Pattern: walls left and right, path above, wall/void below
        // Horizontal wall with path on top
        if (w01 && w21 && bp10 && (bgo12 || w12)) {
            tileDrawn = 22;//9;  // Horizontal wall edge
        }
        // Pattern: walls left and right, wall/void above, path below
        // Horizontal wall with path on bottom
        else if (w01 && w21 && (bgo10 || w10) && bp12) {
            tileDrawn = 2;//9;  // Horizontal wall edge
        }
        // Pattern: wall/void left, path right, walls above and below
        // Vertical wall with path on right
        else if ((bgo01 || w01) && bp21 && w10 && w12) {
            tileDrawn = 11;//17;  // Vertical wall edge
        }
        // Pattern: path left, wall/void right, walls above and below
        // Vertical wall with path on left
        else if (bp01 && (bgo21 || w21) && w10 && w12) {
            tileDrawn = 13;//17;  // Vertical wall edge
        }
        // Pattern: path left, wall right, path above, wall below
        // Top-left inner corner (path in top-left, walls elsewhere)
        else if (bp01 && w21 && bp10 && w12) {
            tileDrawn = 1;//4;  // Inner corner (top-left)
        }
        // Pattern: wall left, path right, path above, wall below
        // Top-right inner corner (path in top-right, walls elsewhere)
        else if (w01 && bp21 && bp10 && w12) {
            tileDrawn = 3;//6;  // Inner corner (top-right)
        }
        // Pattern: wall left, path right, wall above, path below
        // Bottom-right inner corner (path in bottom-right, walls elsewhere)
        else if (w01 && bp21 && w10 && bp12) {
            tileDrawn = 23;//26;  // Inner corner (bottom-right)
        }
        // Pattern: path left, wall right, wall above, path below
        // Bottom-left inner corner (path in bottom-left, walls elsewhere)
        else if (bp01 && w21 && w10 && bp12) {
            tileDrawn = 21;//24;  // Inner corner (bottom-left)
        } else {
            // Check diagonal neighbors for inverse corners
            // These are corners where the path is diagonal to the wall tile
            // Get all four diagonal neighbors
            var t00 = pacman_map_get_tile_from_map(tileMap, i-1, j-1);  // Top-left diagonal
            var t20 = pacman_map_get_tile_from_map(tileMap, i+1, j-1);  // Top-right diagonal
            var t02 = pacman_map_get_tile_from_map(tileMap, i-1, j+1);  // Bottom-left diagonal
            var t22 = pacman_map_get_tile_from_map(tileMap, i+1, j+1);  // Bottom-right diagonal
            
            // Check if diagonals are paths
            var bp00 = (t00 == TileState.PATHBLANK || t00 == TileState.PATH || t00 == TileState.ENERGIZER);
            var bp20 = (t20 == TileState.PATHBLANK || t20 == TileState.PATH || t20 == TileState.ENERGIZER);
            var bp02 = (t02 == TileState.PATHBLANK || t02 == TileState.PATH || t02 == TileState.ENERGIZER);
            var bp22 = (t22 == TileState.PATHBLANK || t22 == TileState.PATH || t22 == TileState.ENERGIZER);
            
            // Check if diagonals are walls, blanks, or out of bounds
            var wbgo00 = (t00 == TileState.WALL || t00 == TileState.BLANK || t00 == TileState.GHOSTSPACE || t00 == -1);
            var wbgo20 = (t20 == TileState.WALL || t20 == TileState.BLANK || t20 == TileState.GHOSTSPACE || t20 == -1);
            var wbgo02 = (t02 == TileState.WALL || t02 == TileState.BLANK || t02 == TileState.GHOSTSPACE || t02 == -1);
            var wbgo22 = (t22 == TileState.WALL || t22 == TileState.BLANK || t22 == TileState.GHOSTSPACE || t22 == -1);
            
            // Pattern: path top-left diagonal, walls/voids elsewhere
            // Inverse corner - path approaches from top-left
            if (bp00 && wbgo20 && wbgo02 && wbgo22) {
                tileDrawn = 23;//26;  // Outer corner (bottom-right)
            }
            // Pattern: path bottom-left diagonal, walls/voids elsewhere
            // Inverse corner - path approaches from bottom-left
            else if (wbgo00 && wbgo20 && bp02 && wbgo22) {
                tileDrawn = 3;//6;  // Outer corner (top-right)
            }
            // Pattern: path bottom-right diagonal, walls/voids elsewhere
            // Inverse corner - path approaches from bottom-right
            else if (wbgo00 && wbgo20 && wbgo02 && bp22) {
                tileDrawn = 1;//4;  // Outer corner (top-left)
            }
            // Pattern: path top-right diagonal, walls/voids elsewhere
            // Inverse corner - path approaches from top-right
            else if (wbgo00 && bp20 && wbgo02 && wbgo22) {
                tileDrawn = 21;//24;  // Outer corner (bottom-left)
            }
            // Default case: no clear pattern matches
            // Use default horizontal wall sprite
            else {
                tileDrawn = 2;//9;  // Default horizontal wall
            }
        }
    }
    
    // Return the calculated sprite index
    return tileDrawn;
}