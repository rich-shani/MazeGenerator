/// ===============================================================================
/// PACMAN_MAP_SPRITE_INDEX - Sprite map index (JSON) and tile-to-sprite mapping
/// ===============================================================================
/// Converts the tile map into JSON / sprite indices for export and wall tile lookup.
/// pacman_map_calculate_wall_tile lives in PACMAN_MAP_WALL_TILE.
/// ===============================================================================

/// @description Generate sprite map index string (JSON format)
function pacman_map_get_sprite_map_index(tileMap) {
    var spriteMap = array_create(array_length(tileMap));
    for (var i = 0; i < array_length(tileMap); i++) {
        spriteMap[i] = array_create(array_length(tileMap[0]));
    }
    
    var s = "{\n\"layers\":[\n\t{\n\t\"data\":[";
    var mapHeight = array_length(tileMap[0]);
    var mapWidth = array_length(tileMap);
    
    for (var j = 0; j < mapHeight; j++) {
        for (var i = 0; i < mapWidth; i++) {
            var t11 = pacman_map_get_tile_from_map(tileMap, i, j);
            var n = "";
            
            if (t11 == TileState.PATH) {
                spriteMap[i][j] = 30;
                n = "30,";
            } else if (t11 == TileState.PATHBLANK) {
                spriteMap[i][j] = 0;
                n = "0,";
            } else if (t11 == TileState.PATHTUNNEL) {
                spriteMap[i][j] = 31;
                n = "31,";
            } else if (t11 == TileState.BLANK || t11 == TileState.GHOSTSPACE) {
                spriteMap[i][j] = 0;
                n = "0,";
            } else if (t11 == TileState.ENERGIZER) {
                spriteMap[i][j] = 29;
                n = "29,";
            } else if (t11 == TileState.GHOSTWALL) {
                spriteMap[i][j] = 19;
                n = "0,";
            } else if (t11 == TileState.WALL) {
                var tileDrawn = pacman_map_calculate_wall_tile(tileMap, i, j, mapWidth, mapHeight);
                spriteMap[i][j] = tileDrawn;
                n = string(tileDrawn) + ",";
            } else if (t11 == TileState.PACMAN) {
                spriteMap[i][j] = 28;
                n = "28,";
            } else if (t11 == TileState.BLINKY) {
                spriteMap[i][j] = 36;
                n = "36,";
            } else if (t11 == TileState.PINKY) {
                spriteMap[i][j] = 35;
                n = "35,";
            } else if (t11 == TileState.INKY) {
                spriteMap[i][j] = 36;
                n = "33,";
            } else if (t11 == TileState.CLYDE) {
                spriteMap[i][j] = 34;
                n = "34,";
            } else if (t11 == TileState.FRUIT) {
                spriteMap[i][j] = 32;
                n = "32,";
            }
            
            s += n;
        }
    }
    
    s += "],\n\t\"height\":31,\n\t\"width\":28\n\t}]\n}";
    return s;
}
