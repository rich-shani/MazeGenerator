/// PACMAN_MAZE_TILE_MAP - Tile grid build and helpers
///
/// TILE MAP BUILDING PHASE:
/// This module converts the high-level 5×9 Cell Map into the final ~34×31 Tile Map.
/// The tile map is the actual grid used for gameplay (walls, paths, dots, character positions).
///
/// CONVERSION PROCESS:
/// 1. CALCULATE DIMENSIONS:
///    - Each cell becomes 3×3 tiles by default (or 2×3 if narrow, 3×4 if tall)
///    - Add padding for borders and ghost house
///    - Mirror left half to create symmetric full maze (~34 tiles wide, ~31 tall)
///
/// 2. FILL GHOST SPACE:
///    - Mark tiles inside cells with isGhostSpace=true as GHOSTSPACE
///    - This creates the ghost house in the center
///
/// 3. GENERATE PATHS:
///    - For each pair of adjacent cells with a connection, draw PATH tiles between them
///    - Paths run through the "seams" between cells
///    - Paths are marked as PATH, but blank cells remain BLANK
///
/// 4. PLACE ENERGIZERS:
///    - Identify valid positions in top and bottom rows for power pills
///    - Place 2 energizers total (1 top, 1 bottom) using get_top/bot_energizer_range()
///
/// 5. GHOST HOUSE PATHS:
///    - Mark path from ghost house exit to main maze
///    - Set tiles as PATHBLANK (walkable by ghosts but no dots)
///    - Erase path until it hits an intersection (connects to main paths)
///
/// 6. MARK TUNNELS:
///    - Identify tunnel entrance/exit tiles on left/right edges
///    - Mark continuous tunnel path as PATHTUNNEL (wrap-around tunnels)
///
/// 7. SET CHARACTER SPAWNS:
///    - Place PACMAN, BLINKY, PINKY, INKY, CLYDE spawn markers
///    - Based on specific tile positions calculated from cell layout
///
/// 8. MIRROR & FINALIZE:
///    - All operations use pacman_map_set_tile() which automatically mirrors
///    - Left half → right half symmetry (except ghost house center region)
///
/// Responsibility: get_tile_map, set_tile, get_tile_state, get_tile_from_map, print_ascii, etc.
/// Globals: tileMap (written by get_tile_map).


/// @description Generate tile map from cell map
function pacman_map_get_tile_map() {
    // Calculate dimensions for the left half of the maze (before mirroring)
    // sub.x = left half width: (5 cells × 3 tiles) - 1 (overlap) + 2 (border padding) = 16
    // sub.y = full height: (9 cells × 3 tiles) + 1 (top padding) + 3 (bottom padding) = 31
    var sub = new intTuple_create(
        CELL_MAP_SIZE_X * 3 - 1 + 2,
        CELL_MAP_SIZE_Y * 3 + 1 + 3
    );

    // midX = boundary of left half (14), fullX = total width after mirroring (28)
    var midX = sub.x - 2;
    var fullX = (sub.x - 2) * 2;
    
    // Initialize tile map
    var result = array_create(fullX);
    for (var i = 0; i < fullX; i++) {
        result[i] = array_create(sub.y);
        for (var j = 0; j < sub.y; j++) {
            result[i][j] = new Tile_create(i, j);
        }
    }
    
    // Populate from cell map
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = cellMap[i][j];
            
            for (var x0 = 0; x0 < c.tileSize.x; x0++) {
                for (var y0 = 0; y0 < c.tileSize.y; y0++) {
                    var tileX = c.tilePosition.x + x0;
                    var tileY = c.tilePosition.y + 1 + y0;
                    result[tileX][tileY].cell = c; // Store reference
                    
                    if (c.isGhostSpace) {
                        pacman_map_set_tile(result, c.tilePosition.x + x0,
                                           c.tilePosition.y + y0,
                                           TileState.GHOSTSPACE, sub.x, sub.y, midX);
                    }
                }
            }
        }
    }
    
    // Generate paths
    for (var j = 0; j < sub.y; j++) {
        for (var i = 0; i < sub.x; i++) {
            var c = (result[i][j] != noone) ? result[i][j].cell : noone;
            var cl = (i > 0 && result[i-1][j] != noone) ? result[i-1][j].cell : noone;
            var cu = (j > 0 && result[i][j-1] != noone) ? result[i][j-1].cell : noone;
            
            if (c != noone) {
                if ((cl != noone && c.group != cl.group) ||
                    (cu != noone && c.group != cu.group) ||
                    (cu == noone && !c.connections[GRID_DIRECTION.UP])) {
                    pacman_map_set_tile(result, i, j, TileState.PATH, sub.x, sub.y, midX);
                }
            } else {
                if ((cl != noone && (!cl.connections[GRID_DIRECTION.RIGHT] ||
                     pacman_map_get_tile_state(result, i-1, j, sub.x, sub.y, midX) == TileState.PATH)) ||
                    (cu != noone && (!cu.connections[GRID_DIRECTION.DOWN] ||
                     pacman_map_get_tile_state(result, i, j-1, sub.x, sub.y, midX) == TileState.PATH))) {
                    pacman_map_set_tile(result, i, j, TileState.PATH, sub.x, sub.y, midX);
                }
            }
            
            if (pacman_map_get_tile_state(result, i-1, j, sub.x, sub.y, midX) == TileState.PATH &&
                pacman_map_get_tile_state(result, i, j-1, sub.x, sub.y, midX) == TileState.PATH &&
                pacman_map_get_tile_state(result, i-1, j-1, sub.x, sub.y, midX) == TileState.BLANK) {
                pacman_map_set_tile(result, i, j, TileState.PATH, sub.x, sub.y, midX);
            }
        }
    }
    
    // Handle top tunnels
    var c = cellMap[CELL_MAP_SIZE_X - 1][0];
    while (c != noone) {
        if (c.topTunnel) {
            var j = c.tilePosition.y + 1;
            // Mark tunnel exit tile (rightmost edge) as PATHTUNNEL
            pacman_map_set_tile(result, sub.x - 1, j, TileState.PATHTUNNEL, sub.x, sub.y, midX);
            
            // Trace back and mark path leading into tunnel as PATHTUNNEL
            pacman_map_mark_tunnel_path(result, sub.x - 2, j, sub.x, sub.y, midX);
        }
        c = c.next[GRID_DIRECTION.DOWN];
    }
    
    // Generate walls
    for (var j = 0; j < sub.y; j++) {
        for (var i = 0; i < sub.x; i++) {
            var currentState = pacman_map_get_tile_state(result, i, j, sub.x, sub.y, midX);
            if (currentState != TileState.PATH && currentState != TileState.PATHTUNNEL) {
                var isAdjacent = false;
                for (var di = -1; di <= 1; di++) {
                    for (var dj = -1; dj <= 1; dj++) {
                        if (di == 0 && dj == 0) continue;
                        var adjState = pacman_map_get_tile_state(result, i + di, j + dj, sub.x, sub.y, midX);
                        if (adjState == TileState.PATH || adjState == TileState.PATHTUNNEL) {
                            isAdjacent = true;
                            break;
                        }
                    }
                    if (isAdjacent) break;
                }
                if (isAdjacent) {
                    pacman_map_set_tile(result, i, j, TileState.WALL, sub.x, sub.y, midX);
                }
            }
        }
    }
    
    // Set ghost wall
    pacman_map_set_tile(result, GHOST_WALL_HALF_TILE_X, GHOST_WALL_HALF_TILE_Y, TileState.GHOSTWALL, sub.x, sub.y, midX);

    // Place energizers
    var range = pacman_map_get_top_energizer_range(result, sub.x, sub.y, midX);
    if (range != noone) {
        var j = irandom_range(range[0], range[1]);
        var i = sub.x - 2;
        pacman_map_set_tile(result, i, j, TileState.ENERGIZER, sub.x, sub.y, midX);
    }

    range = pacman_map_get_bot_energizer_range(result, sub.x, sub.y, midX);
    if (range != noone) {
        var j = irandom_range(range[0], range[1]);
        var i = sub.x - 2;
        pacman_map_set_tile(result, i, j, TileState.ENERGIZER, sub.x, sub.y, midX);
    }

    // Erase until intersection
    for (var j = 0; j < sub.y; j++) {
        var i = sub.x - 1;
        if (pacman_map_get_tile_state(result, i, j, sub.x, sub.y, midX) == TileState.PATH) {
            pacman_map_erase_until_intersection(result, i, j, sub.x, sub.y, midX);
        }
    }

    // Set Pac-Man path blank
    pacman_map_set_tile(result, 1, sub.y - TILEMAP_PACMAN_ROW_OFFSET, TileState.PATHBLANK, sub.x, sub.y, midX);

    // Empty path around the ghost house location
    for (var i = 0; i < TILEMAP_GHOST_BLANK_COL_COUNT; i++) {
        var j = sub.y - TILEMAP_GHOST_BLANK_BOTTOM_OFFSET;
        pacman_map_set_tile(result, i, j, TileState.PATHBLANK, sub.x, sub.y, midX);
        var jOffset = 1;
        if (pacman_map_get_tile_state(result, i, j + jOffset, sub.x, sub.y, midX) == TileState.PATH &&
               pacman_map_get_tile_state(result, i - 1, j + jOffset, sub.x, sub.y, midX) == TileState.WALL &&
               pacman_map_get_tile_state(result, i + 1, j + jOffset, sub.x, sub.y, midX) == TileState.WALL) {
            pacman_map_set_tile(result, i, j + jOffset, TileState.PATHBLANK, sub.x, sub.y, midX);
            jOffset++;
        }

        j = sub.y - TILEMAP_GHOST_BLANK_TOP_OFFSET;
        pacman_map_set_tile(result, i, j, TileState.PATHBLANK, sub.x, sub.y, midX);
        var j0 = 1;
        if (pacman_map_get_tile_state(result, i, j - j0, sub.x, sub.y, midX) == TileState.PATH &&
               pacman_map_get_tile_state(result, i - 1, j - j0, sub.x, sub.y, midX) == TileState.WALL &&
               pacman_map_get_tile_state(result, i + 1, j - j0, sub.x, sub.y, midX) == TileState.WALL) {
            pacman_map_set_tile(result, i, j - j0, TileState.PATHBLANK, sub.x, sub.y, midX);
            j0++;
        }
    }

    for (var n = 0; n < TILEMAP_GHOST_BLANK_COL_COUNT; n++) {
        var i = TILEMAP_GHOST_BLANK_COL_MAX;
        var j = sub.y - TILEMAP_GHOST_BLANK_BOTTOM_OFFSET - n;
        pacman_map_set_tile(result, i, j, TileState.PATHBLANK, sub.x, sub.y, midX);
        if (pacman_map_get_tile_state(result, i, j, sub.x, sub.y, midX) == TileState.PATH &&
               pacman_map_get_tile_state(result, i-1, j, sub.x, sub.y, midX) == TileState.WALL &&
               pacman_map_get_tile_state(result, i+1, j, sub.x, sub.y, midX) == TileState.WALL) {
            pacman_map_set_tile(result, i, j, TileState.PATHBLANK, sub.x, sub.y, midX);
        }
    }

	// Pac-Man and fruit spawn positions (character placement lives in get_tile_map)
	result[PACMAN_SPAWN_TILE_X][PACMAN_SPAWN_TILE_Y].state = TileState.PACMAN;
	//result[12][11].state = TileState.BLINKY;
	//result[12][14].state = TileState.PINKY;
	//result[13][14].state = TileState.INKY;
	//result[14][14].state = TileState.CLYDE;
	result[FRUIT_SPAWN_TILE_X][FRUIT_SPAWN_TILE_Y].state = TileState.FRUIT;
	
    tileMap = result;
    return result;
}

/// @description Set tile state (with symmetry)
function pacman_map_set_tile(tM, i, j, state, w, h, midX) {
    if (i < 0 || i >= w || j < 0 || j >= h) {
        return;
    }
    
    i -= 2;
    tM[midX + i][j].state = state;
    tM[midX - 1 - i][j].state = state;
}

/// @description Get tile state
function pacman_map_get_tile_state(tM, i, j, w, h, midX) {
    if (i < 0 || i >= w || j < 0 || j >= h) {
        return -1;
    }
    
    i -= 2;
    return tM[midX + i][j].state;
}

/// @description Get valid range for top energizer placement
function pacman_map_get_top_energizer_range(tM, w, h, midX) {
    var i = w - 2;
    var miny = 0;
    var maxy = h div 2;
    
    for (var j = 1; j < maxy; j++) {
        if (pacman_map_get_tile_state(tM, i, j, w, h, midX) == TileState.PATH &&
            pacman_map_get_tile_state(tM, i, j + 1, w, h, midX) == TileState.PATH) {
            miny = j + 1;
            break;
        }
    }
    
    maxy = min(h div 2, miny + TILEMAP_ENERGIZER_RANGE_SPAN);
    
    for (var j = miny + 1; j < maxy; j++) {
        if (pacman_map_get_tile_state(tM, i - 1, j, w, h, midX) == TileState.PATH) {
            maxy = j;
            break;
        }
    }
    
    return [miny, maxy - 1];
}

/// @description Get valid range for bottom energizer placement
function pacman_map_get_bot_energizer_range(tM, w, h, midX) {
    var i = w - 2;
    var miny = h div 2;
    var maxy = 0;
    
    for (var j = h - 3; j >= miny; j--) {
        if (pacman_map_get_tile_state(tM, i, j, w, h, midX) == TileState.PATH &&
            pacman_map_get_tile_state(tM, i, j + 1, w, h, midX) == TileState.PATH) {
            maxy = j;
            break;
        }
    }
    
    miny = max(h div 2, maxy - TILEMAP_ENERGIZER_RANGE_SPAN);
    
    for (var j = maxy - 1; j > miny; j--) {
        if (pacman_map_get_tile_state(tM, i - 1, j, w, h, midX) == TileState.PATH) {
            miny = j + 1;
            break;
        }
    }
    
    return [miny, maxy - 1];
}

/// @description Mark path leading into tunnel as PATHTUNNEL
function pacman_map_mark_tunnel_path(tM, startI, j, w, h, midX) {
    var i = startI;
    
    // Trace left from tunnel, marking PATH tiles as PATHTUNNEL
    while (i >= 0) {
      
        // Check if we've reached an intersection (vertical paths indicate intersection)
        var hasVerticalPath = false;
        var upState = pacman_map_get_tile_state(tM, i, j - 1, w, h, midX);
        var downState = pacman_map_get_tile_state(tM, i, j + 1, w, h, midX);
        
        if ((upState == TileState.PATH) || (downState == TileState.PATH)) {
            hasVerticalPath = true;
			
			break;
        }
        
        var currentState = pacman_map_get_tile_state(tM, i, j, w, h, midX);
		
        // If current tile is PATH, mark it as PATHTUNNEL
        if (currentState == TileState.PATH || currentState == TileState.PATHBLANK) {
            pacman_map_set_tile(tM, i, j, TileState.PATHTUNNEL, w, h, midX);
        } else if (currentState != TileState.PATHTUNNEL) {
            // Stop if we hit a non-path tile
            break;
        }
		
        //// Check next tile to the left
        //var nextState = pacman_map_get_tile_state(tM, i - 1, j, w, h, midX);
        //if (nextState != TileState.PATHBLANK && nextState != TileState.PATHTUNNEL) {
        //    // No more path to the left, stop
        //    break;
        //}
        
        // Move left
        i--;
    }
}

/// @description Erase path until intersection
function pacman_map_erase_until_intersection(tM, i, j, w, h, midX) {
    while (true) {
        var adj = [];
        
        if (pacman_map_get_tile_state(tM, i - 1, j, w, h, midX) == TileState.PATH) {
            array_push(adj, new intTuple_create(i - 1, j));
        }
        if (pacman_map_get_tile_state(tM, i + 1, j, w, h, midX) == TileState.PATH) {
            array_push(adj, new intTuple_create(i + 1, j));
        }
        if (pacman_map_get_tile_state(tM, i, j - 1, w, h, midX) == TileState.PATH) {
            array_push(adj, new intTuple_create(i, j - 1));
        }
        if (pacman_map_get_tile_state(tM, i, j + 1, w, h, midX) == TileState.PATH) {
            array_push(adj, new intTuple_create(i, j + 1));
        }
        
        if (array_length(adj) == 1) {
            pacman_map_set_tile(tM, i, j, TileState.PATHBLANK, w, h, midX);
            i = adj[0].x;
            j = adj[0].y;
        } else {
            break;
        }
    }
}

/// @description Get tile state from tile map
function pacman_map_get_tile_from_map(tM, i, j) {
    if (i < 0 || i >= array_length(tM) || j < 0 || j >= array_length(tM[0])) {
        return -1;
    }
    return tM[i][j].state;
}



/// @description Print ASCII representation of the generated maze map
/// @param tileMap 2D array of Tile structures
function pacman_map_print_ascii(tileMap) {
    if (is_undefined(tileMap) || array_length(tileMap) == 0) {
        show_debug_message("ERROR: tileMap is undefined or empty");
        return;
    }
    
    var mapWidth = array_length(tileMap);
    var mapHeight = array_length(tileMap[0]);
    
    show_debug_message("=== PACMAN MAZE (ASCII) ===");
    show_debug_message("Width: " + string(mapWidth) + " tiles");
    show_debug_message("Height: " + string(mapHeight) + " tiles");
    show_debug_message("");
    
    // Build the ASCII representation row by row
    var asciiMap = "";
    var nPills = 0;
	
    for (var j = 0; j < mapHeight; j++) {
        var row = "";
        for (var i = 0; i < mapWidth; i++) {
            var tile = tileMap[i][j];
            var char = "?";
            
            switch (tile.state) {
                case TileState.BLANK:
                    char = " ";  // Space for blank/void
                    break;
                case TileState.PATH:
                    char = ".";  // Dot for pellet path
					nPills++;
                    break;
                case TileState.PATHBLANK:
                    char = " ";  // Space for empty path/tunnel
                    break;
				case TileState.PATHTUNNEL:
                    char = "T";  // Space for empty path/tunnel
                    break;
                case TileState.WALL:
                    char = "#";  // Hash for wall
                    break;
                case TileState.GHOSTWALL:
                    char = "=";  // Equals for ghost wall
                    break;
                case TileState.ENERGIZER:
                    char = "O";  // O for energizer
                    break;
                case TileState.GHOSTSPACE:
                    char = "G";  // G for ghost space
                    break;
				case TileState.PACMAN:
					char = "M";
					break;
				case TileState.BLINKY:
					char = "B";
					break;
				case TileState.PINKY:
					char = "P";
					break;
				case TileState.INKY:
					char = "I";
					break;
				case TileState.CLYDE:
					char = "C";
					break;
				case TileState.FRUIT:
					char = "F";
					break;
                default:
                    char = "?";
                    break;
            }
            
            row += char;
        }
        asciiMap += row + "\n";
    }
    
    // Print the ASCII map
    show_debug_message(asciiMap);
    
    // Print legend
	show_debug_message("number of power pills: " + string(nPills));
    show_debug_message("Legend:");
    show_debug_message("  [ ] = Blank/Void");
    show_debug_message("  [.] = Path (pellet)");
    show_debug_message("  [ ] = Path (empty/tunnel)");
    show_debug_message("  [#] = Wall");
    show_debug_message("  [=] = Ghost Wall");
    show_debug_message("  [O] = Energizer");
    show_debug_message("  [G] = Ghost Space");
    show_debug_message("============================");
}