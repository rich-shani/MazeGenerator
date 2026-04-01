/// ===============================================================================
/// PACMAN_MAP_SPRITE_INDEX - Sprite map index (JSON) and tile-to-sprite mapping
/// ===============================================================================
/// Converts the tile map into JSON / sprite indices for export and wall tile lookup.
/// pacman_map_calculate_wall_tile lives in PACMAN_MAP_WALL_TILE.
///
/// SPRITE INDEX LEGEND:
/// These are the hardcoded sprite indices used in the tile-to-sprite mapping.
/// Each TileState maps to a specific sprite index for rendering:
///
///   0  = Blank/Empty tile (BLANK, PATHBLANK, GHOSTSPACE)
///   19 = Ghost house wall (GHOSTWALL)
///   28 = Pac-Man spawn marker (PACMAN)
///   29 = Power pill / Energizer (ENERGIZER)
///   30 = Normal path with dot (PATH)
///   31 = Tunnel path (PATHTUNNEL)
///   32 = Fruit spawn marker (FRUIT)
///   33 = Inky spawn marker (INKY)
///   34 = Clyde spawn marker (CLYDE)
///   35 = Pinky spawn marker (PINKY)
///   36 = Blinky spawn marker (BLINKY)
///   1-18, 20-27 = Wall tiles (calculated by pacman_map_calculate_wall_tile based on neighbors)
///
/// NOTE: These indices should eventually be replaced with named constants in TILE_SPRITE_INDICES.gml
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
                spriteMap[i][j] = SPRITE_DOT;
                n = string(SPRITE_DOT) + ",";
            } else if (t11 == TileState.PATHBLANK) {
                spriteMap[i][j] = SPRITE_BLANK;
                n = string(SPRITE_BLANK) + ",";
            } else if (t11 == TileState.PATHTUNNEL) {
                spriteMap[i][j] = SPRITE_TUNNEL;
                n = string(SPRITE_TUNNEL) + ",";
            } else if (t11 == TileState.BLANK || t11 == TileState.GHOSTSPACE) {
                spriteMap[i][j] = SPRITE_BLANK;
                n = string(SPRITE_BLANK) + ",";
            } else if (t11 == TileState.ENERGIZER) {
                spriteMap[i][j] = SPRITE_ENERGIZER;
                n = string(SPRITE_ENERGIZER) + ",";
            } else if (t11 == TileState.GHOSTWALL) {
                spriteMap[i][j] = SPRITE_GHOSTWALL;
                n = string(SPRITE_BLANK) + ",";
            } else if (t11 == TileState.WALL) {
                var tileDrawn = pacman_map_calculate_wall_tile(tileMap, i, j, mapWidth, mapHeight);
                spriteMap[i][j] = tileDrawn;
                n = string(tileDrawn) + ",";
            } else if (t11 == TileState.PACMAN) {
                spriteMap[i][j] = SPRITE_PACMAN;
                n = string(SPRITE_PACMAN) + ",";
            } else if (t11 == TileState.BLINKY) {
                spriteMap[i][j] = SPRITE_BLINKY;
                n = string(SPRITE_BLINKY) + ",";
            } else if (t11 == TileState.PINKY) {
                spriteMap[i][j] = SPRITE_PINKY;
                n = string(SPRITE_PINKY) + ",";
            } else if (t11 == TileState.INKY) {
                spriteMap[i][j] = SPRITE_INKY;  // Fixed: was 36 (BLINKY), now SPRITE_INKY (33)
                n = string(SPRITE_INKY) + ",";
            } else if (t11 == TileState.CLYDE) {
                spriteMap[i][j] = SPRITE_CLYDE;
                n = string(SPRITE_CLYDE) + ",";
            } else if (t11 == TileState.FRUIT) {
                spriteMap[i][j] = SPRITE_FRUIT;
                n = string(SPRITE_FRUIT) + ",";
            }
            
            s += n;
        }
    }
    
    s += "],\n\t\"height\":31,\n\t\"width\":28\n\t}]\n}";
    return s;
}
