/// @description Calculate which wall sprite to use based on neighbors
function pacman_map_calculate_wall_tile(tileMap, i, j, mapWidth, mapHeight) {
    var t01 = pacman_map_get_tile_from_map(tileMap, i-1, j);
    var t21 = pacman_map_get_tile_from_map(tileMap, i+1, j);
    var t10 = pacman_map_get_tile_from_map(tileMap, i, j-1);
    var t12 = pacman_map_get_tile_from_map(tileMap, i, j+1);
    
    var bp01 = (t01 == TileState.PATHBLANK || t01 == TileState.PATH || t01 == TileState.ENERGIZER);
    var bp21 = (t21 == TileState.PATHBLANK || t21 == TileState.PATH || t21 == TileState.ENERGIZER);
    var bp10 = (t10 == TileState.PATHBLANK || t10 == TileState.PATH || t10 == TileState.ENERGIZER);
    var bp12 = (t12 == TileState.PATHBLANK || t12 == TileState.PATH || t12 == TileState.ENERGIZER);
    
    var bgo01 = (t01 == TileState.BLANK || t01 == TileState.GHOSTSPACE || t01 == -1);
    var bgo21 = (t21 == TileState.BLANK || t21 == TileState.GHOSTSPACE || t21 == -1);
    var bgo10 = (t10 == TileState.BLANK || t10 == TileState.GHOSTSPACE || t10 == -1);
    var bgo12 = (t12 == TileState.BLANK || t12 == TileState.GHOSTSPACE || t12 == -1);
    
    var w01 = (t01 == TileState.WALL || t01 == TileState.GHOSTWALL);
    var w21 = (t21 == TileState.WALL || t21 == TileState.GHOSTWALL);
    var w10 = (t10 == TileState.WALL || t10 == TileState.GHOSTWALL);
    var w12 = (t12 == TileState.WALL || t12 == TileState.GHOSTWALL);
    
    var tileDrawn = -1;
    
    // Border column handling - check corners first, then borders
    // Top-left corner
    if (i == 0 && j == 0) {
        tileDrawn = 4;
    }
    // Top-right corner
    else if (i == mapWidth - 1 && j == 0) {
        tileDrawn = 6;
    }
    // Bottom-left corner
    else if (i == 0 && j == mapHeight - 1) {
        tileDrawn = 24;
    }
    // Bottom-right corner
    else if (i == mapWidth - 1 && j == mapHeight - 1) {
        tileDrawn = 26;
    }
    // Left border (not corner)
    else if (i == 0) {
        // Pattern: wall right, wall above, wall below -> sprite 4 (corner)
        if (w21 && w10 && w12) {
            tileDrawn = 24;
        }
        // Pattern: wall right, wall above, path below -> sprite 24
        else if (w21 && w10 && bgo12) {
            tileDrawn = 24;
        }
		else if (w21 && w12 && bgo10) {
			tileDrawn = 4;
		}
        // Pattern: wall right, path above, wall below -> sprite 9 (horizontal wall connection)
        else if (w21 && bp10 && w12) {
            tileDrawn = 9;
        }
        // Pattern: wall right with path above or below -> sprite 9 (horizontal wall connection)
        else if (w21 && (bp10 || bp12)) {
            tileDrawn = 9;
        }
        // Default left border (no wall connection)
        else {
            tileDrawn = 17;
        }
    }
    // Right border (not corner)
    else if (i == mapWidth - 1) {
        tileDrawn = 17;
    } else {
        // Interior tile logic
        if (w01 && w21 && bp10 && (bgo12 || w12)) {
            tileDrawn = 9;
        } else if (w01 && w21 && (bgo10 || w10) && bp12) {
            tileDrawn = 9;
        } else if ((bgo01 || w01) && bp21 && w10 && w12) {
            tileDrawn = 17;
        } else if (bp01 && (bgo21 || w21) && w10 && w12) {
            tileDrawn = 17;
        } else if (bp01 && w21 && bp10 && w12) {
            tileDrawn = 4;
        } else if (w01 && bp21 && bp10 && w12) {
            tileDrawn = 6;
        } else if (w01 && bp21 && w10 && bp12) {
            tileDrawn = 26;
        } else if (bp01 && w21 && w10 && bp12) {
            tileDrawn = 24;
        } else {
            // Check diagonal neighbors for inverse corners
            var t00 = pacman_map_get_tile_from_map(tileMap, i-1, j-1);
            var t20 = pacman_map_get_tile_from_map(tileMap, i+1, j-1);
            var t02 = pacman_map_get_tile_from_map(tileMap, i-1, j+1);
            var t22 = pacman_map_get_tile_from_map(tileMap, i+1, j+1);
            
            var bp00 = (t00 == TileState.PATHBLANK || t00 == TileState.PATH || t00 == TileState.ENERGIZER);
            var bp20 = (t20 == TileState.PATHBLANK || t20 == TileState.PATH || t20 == TileState.ENERGIZER);
            var bp02 = (t02 == TileState.PATHBLANK || t02 == TileState.PATH || t02 == TileState.ENERGIZER);
            var bp22 = (t22 == TileState.PATHBLANK || t22 == TileState.PATH || t22 == TileState.ENERGIZER);
            
            var wbgo00 = (t00 == TileState.WALL || t00 == TileState.BLANK || t00 == TileState.GHOSTSPACE || t00 == -1);
            var wbgo20 = (t20 == TileState.WALL || t20 == TileState.BLANK || t20 == TileState.GHOSTSPACE || t20 == -1);
            var wbgo02 = (t02 == TileState.WALL || t02 == TileState.BLANK || t02 == TileState.GHOSTSPACE || t02 == -1);
            var wbgo22 = (t22 == TileState.WALL || t22 == TileState.BLANK || t22 == TileState.GHOSTSPACE || t22 == -1);
            
            if (bp00 && wbgo20 && wbgo02 && wbgo22) {
                tileDrawn = 26;
            } else if (wbgo00 && wbgo20 && bp02 && wbgo22) {
                tileDrawn = 6;
            } else if (wbgo00 && wbgo20 && wbgo02 && bp22) {
                tileDrawn = 4;
            } else if (wbgo00 && bp20 && wbgo02 && wbgo22) {
                tileDrawn = 24;
            } else {
                tileDrawn = 9;
            }
        }
    }
    
    return tileDrawn;
}