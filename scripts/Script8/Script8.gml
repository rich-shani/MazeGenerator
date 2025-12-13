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
            
            //// Special case: first tile (left tunnel prefix)
            //if (i == 0) {
            //    s += (t11 == TileState.PATHBLANK) ? "31,33,33," : "0,0,0,";
            //}
            
            var n = "";
            
            if (t11 == TileState.PATH) {
                spriteMap[i][j] = 30; // was 36
                n = "30,";
            } else if (t11 == TileState.PATHBLANK) {
                spriteMap[i][j] = 0; //32;
                n = "0,";
            } else if (t11 == TileState.PATHTUNNEL) {
                spriteMap[i][j] = 31;
                n = "31,";				
			} else if (t11 == TileState.BLANK || t11 == TileState.GHOSTSPACE) {
                spriteMap[i][j] = 0;
                n = "0,";
            } else if (t11 == TileState.ENERGIZER) {
                spriteMap[i][j] = 29; // 37
                n = "29,";
            } else if (t11 == TileState.GHOSTWALL) {
                spriteMap[i][j] = 19;
                n = "19,";
            } else if (t11 == TileState.WALL) {
                var tileDrawn = pacman_map_calculate_wall_tile(tileMap, i, j, mapWidth, mapHeight);
                spriteMap[i][j] = tileDrawn;
                n = string(tileDrawn) + ",";
            }
            
            s += n;
            
            //// Special case: last tile (right tunnel suffix)
            //if (i == mapWidth - 1) {
            //    s += (t11 == TileState.PATHBLANK) ? "33,33,31" : "0,0,0";
            //    s += (j == mapHeight - 1) ? "" : ",";
            //}
        }
    }
    
    s += "],\n\t\"height\":31,\n\t\"width\":28\n\t}]\n}";
    
    return s;
}