/// ===============================================================================
/// PACMAN_MAP_WALL_TILE - Wall sprite selection from neighbor tile states
/// ===============================================================================
/// Determines which wall sprite to use based on 4 cardinal (and optionally diagonal)
/// neighbors. Uses helpers for state checks and named constants for sprite indices.
/// ===============================================================================

// Named sprite indices (sWall tileset) for readability
#macro WALL_SPRITE_TOPLEFT 7
#macro WALL_SPRITE_TOPRIGHT 6
#macro WALL_SPRITE_BOTLEFT 8
#macro WALL_SPRITE_BOTRIGHT 5
#macro WALL_SPRITE_LEFT_EDGE 1
#macro WALL_SPRITE_RIGHT_EDGE 3
#macro WALL_SPRITE_HORIZ_PATH_ABOVE 4
#macro WALL_SPRITE_HORIZ_PATH_BELOW 2
#macro WALL_SPRITE_INNER_TOPLEFT 36
#macro WALL_SPRITE_INNER_TOPRIGHT 39
#macro WALL_SPRITE_INNER_BOTRIGHT 38
#macro WALL_SPRITE_INNER_BOTLEFT 37
#macro WALL_SPRITE_GHOST_ENTRANCE 50

/// @description True if tile state is path-adjacent (walkable / path type)
function pacman_map_wall_tile_state_is_path_adjacent(_state) {
    return (_state == TileState.PATHBLANK || _state == TileState.PATH || _state == TileState.PATHTUNNEL
        || _state == TileState.ENERGIZER || _state == TileState.PACMAN || _state == TileState.FRUIT);
}

/// @description True if tile state is blank, ghost space, or out of bounds
function pacman_map_wall_tile_state_is_blank_or_out(_state) {
    return (_state == TileState.BLANK || _state == TileState.GHOSTSPACE || _state == -1);
}

/// @description True if tile state is solid wall
function pacman_map_wall_tile_state_is_wall(_state) {
    return (_state == TileState.WALL || _state == TileState.GHOSTWALL);
}

/// @description True if tile state is path for diagonal neighbor checks (narrower than path-adjacent)
function pacman_map_wall_tile_state_is_path_diagonal(_state) {
    return (_state == TileState.PATHBLANK || _state == TileState.PATH || _state == TileState.ENERGIZER);
}

/// @description Calculate which wall sprite to use based on neighbors
function pacman_map_calculate_wall_tile(tileMap, i, j, mapWidth, mapHeight) {
    var t01 = pacman_map_get_tile_from_map(tileMap, i-1, j);
    var t21 = pacman_map_get_tile_from_map(tileMap, i+1, j);
    var t10 = pacman_map_get_tile_from_map(tileMap, i, j-1);
    var t12 = pacman_map_get_tile_from_map(tileMap, i, j+1);
    
    var bp01 = pacman_map_wall_tile_state_is_path_adjacent(t01);
    var bp21 = pacman_map_wall_tile_state_is_path_adjacent(t21);
    var bp10 = pacman_map_wall_tile_state_is_path_adjacent(t10);
    var bp12 = pacman_map_wall_tile_state_is_path_adjacent(t12);
    
    var bgo01 = pacman_map_wall_tile_state_is_blank_or_out(t01);
    var bgo21 = pacman_map_wall_tile_state_is_blank_or_out(t21);
    var bgo10 = pacman_map_wall_tile_state_is_blank_or_out(t10);
    var bgo12 = pacman_map_wall_tile_state_is_blank_or_out(t12);
    
    var w01 = pacman_map_wall_tile_state_is_wall(t01);
    var w21 = pacman_map_wall_tile_state_is_wall(t21);
    var w10 = pacman_map_wall_tile_state_is_wall(t10);
    var w12 = pacman_map_wall_tile_state_is_wall(t12);
    
    var tileDrawn = -1;
    
    if (i == 0 && j == 0) {
        tileDrawn = WALL_SPRITE_TOPLEFT;
    } else if (i == mapWidth - 1 && j == 0) {
        tileDrawn = WALL_SPRITE_TOPRIGHT;
    } else if (i == 0 && j == mapHeight - 1) {
        tileDrawn = WALL_SPRITE_BOTLEFT;
    } else if (i == mapWidth - 1 && j == mapHeight - 1) {
        tileDrawn = WALL_SPRITE_BOTRIGHT;
    } else if (i == 0) {
        if (w21 && w10 && w12) {
            var t20 = pacman_map_get_tile_from_map(tileMap, i+1, j-1);
            var w20 = pacman_map_wall_tile_state_is_wall(t20);
            tileDrawn = w20 ? WALL_SPRITE_TOPLEFT : WALL_SPRITE_LEFT_EDGE;
        } else if (w21 && w10 && bgo12) {
            tileDrawn = WALL_SPRITE_LEFT_EDGE;
        } else if (w21 && w12 && bgo10) {
            tileDrawn = WALL_SPRITE_TOPLEFT;
        } else if (w21 && (bp10 || bp12)) {
            tileDrawn = bp10 ? WALL_SPRITE_HORIZ_PATH_ABOVE : WALL_SPRITE_HORIZ_PATH_BELOW;
        } else {
            tileDrawn = WALL_SPRITE_LEFT_EDGE;
        }
    } else if (i == mapWidth - 1) {
        if (w01 && w10 && w12) {
            var t00 = pacman_map_get_tile_from_map(tileMap, i-1, j-1);
            var w00 = pacman_map_wall_tile_state_is_wall(t00);
            tileDrawn = w00 ? WALL_SPRITE_TOPRIGHT : WALL_SPRITE_BOTRIGHT;
        } else if (w01 && w10 && bgo12) {
            tileDrawn = WALL_SPRITE_BOTRIGHT;
        } else if (w01 && w12 && bgo10) {
            tileDrawn = WALL_SPRITE_TOPRIGHT;
        } else if (w01 && (bp10 || bp12)) {
            tileDrawn = bp10 ? WALL_SPRITE_HORIZ_PATH_ABOVE : WALL_SPRITE_HORIZ_PATH_BELOW;
        } else {
            tileDrawn = WALL_SPRITE_RIGHT_EDGE;
        }
    } else {
        if (w01 && w21 && bp10 && (bgo12 || w12)) {
            tileDrawn = WALL_SPRITE_HORIZ_PATH_ABOVE;
        } else if (w01 && w21 && (bgo10 || w10) && bp12) {
            tileDrawn = WALL_SPRITE_HORIZ_PATH_BELOW;
        } else if ((bgo01 || w01) && bp21 && w10 && w12) {
            tileDrawn = WALL_SPRITE_LEFT_EDGE;
        } else if (bp01 && (bgo21 || w21) && w10 && w12) {
            tileDrawn = WALL_SPRITE_RIGHT_EDGE;
        } else if (bp01 && w21 && bp10 && w12) {
            tileDrawn = WALL_SPRITE_INNER_TOPLEFT;
        } else if (w01 && bp21 && bp10 && w12) {
            tileDrawn = WALL_SPRITE_INNER_TOPRIGHT;
        } else if (w01 && bp21 && w10 && bp12) {
            tileDrawn = WALL_SPRITE_INNER_BOTRIGHT;
        } else if (bp01 && w21 && w10 && bp12) {
            tileDrawn = WALL_SPRITE_INNER_BOTLEFT;
        } else {
            var t00 = pacman_map_get_tile_from_map(tileMap, i-1, j-1);
            var t20 = pacman_map_get_tile_from_map(tileMap, i+1, j-1);
            var t02 = pacman_map_get_tile_from_map(tileMap, i-1, j+1);
            var t22 = pacman_map_get_tile_from_map(tileMap, i+1, j+1);
            var bp00 = pacman_map_wall_tile_state_is_path_diagonal(t00);
            var bp20 = pacman_map_wall_tile_state_is_path_diagonal(t20);
            var bp02 = pacman_map_wall_tile_state_is_path_diagonal(t02);
            var bp22 = pacman_map_wall_tile_state_is_path_diagonal(t22);
            var wbgo00 = pacman_map_wall_tile_state_is_wall(t00) || pacman_map_wall_tile_state_is_blank_or_out(t00);
            var wbgo20 = pacman_map_wall_tile_state_is_wall(t20) || pacman_map_wall_tile_state_is_blank_or_out(t20);
            var wbgo02 = pacman_map_wall_tile_state_is_wall(t02) || pacman_map_wall_tile_state_is_blank_or_out(t02);
            var wbgo22 = pacman_map_wall_tile_state_is_wall(t22) || pacman_map_wall_tile_state_is_blank_or_out(t22);
            
            if (bp00 && wbgo20 && wbgo02 && wbgo22) tileDrawn = WALL_SPRITE_BOTRIGHT;
            else if (wbgo00 && wbgo20 && bp02 && wbgo22) tileDrawn = WALL_SPRITE_TOPRIGHT;
            else if (wbgo00 && wbgo20 && wbgo02 && bp22) tileDrawn = WALL_SPRITE_TOPLEFT;
            else if (wbgo00 && bp20 && wbgo02 && wbgo22) tileDrawn = WALL_SPRITE_BOTLEFT;
            else tileDrawn = WALL_SPRITE_HORIZ_PATH_BELOW;
        }
    }
    
    return tileDrawn;
}
