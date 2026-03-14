/// PACMAN_MAZE_WALLS_TUNNELS - Walls and tunnels
/// Responsibility: setup_scale_coords, join_walls, create_tunnels, replace_group, etc.
/// Globals: cellMap, tallRows, narrowCols.

/// @description Setup tile coordinates from cell coordinates
function pacman_map_setup_scale_coords() {
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = cellMap[i][j];
            
            c.tilePosition.x = c.position.x * 3;
            if (narrowCols[c.position.y] < c.position.x) {
                c.tilePosition.x--;
            }
            
            c.tilePosition.y = c.position.y * 3;
            if (tallRows[c.position.x] < c.position.y) {
                c.tilePosition.y++;
            }
            
            c.tileSize.x = c.shrinkWidth ? 2 : 3;
            c.tileSize.y = c.raiseHeight ? 4 : 3;
        }
    }
}

/// @description Join walls for better maze structure
function pacman_map_join_walls() {
    // Top row joining
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        var c = cellMap[i][0];
        if (!c.connections[CellDirection.LEFT] && !c.connections[CellDirection.RIGHT] &&
            !c.connections[CellDirection.UP] &&
            (!c.connections[CellDirection.DOWN] || 
             (c.next[CellDirection.DOWN] != noone && !c.next[CellDirection.DOWN].connections[CellDirection.DOWN]))) {
            if ((c.next[CellDirection.LEFT] == noone || !c.next[CellDirection.LEFT].connections[CellDirection.UP]) &&
                (c.next[CellDirection.RIGHT] != noone && !c.next[CellDirection.RIGHT].connections[CellDirection.UP])) {
                if (!(c.next[CellDirection.DOWN] != noone &&
                      c.next[CellDirection.DOWN].connections[CellDirection.RIGHT] &&
                      c.next[CellDirection.DOWN].next[CellDirection.RIGHT] != noone &&
                      c.next[CellDirection.DOWN].next[CellDirection.RIGHT].connections[CellDirection.RIGHT])) {
                    c.isJoinCandidate = true;
                    if (random(1.0) <= 0.25) {
                        c.connections[CellDirection.UP] = true;
                    }
                }
            }
        }
    }
    
    // Bottom row joining
    for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
        var c = cellMap[i][CELL_MAP_SIZE_Y - 1];
        if (!c.connections[CellDirection.LEFT] && !c.connections[CellDirection.RIGHT] &&
            !c.connections[CellDirection.DOWN] &&
            (!c.connections[CellDirection.UP] ||
             (c.next[CellDirection.UP] != noone && !c.next[CellDirection.UP].connections[CellDirection.UP]))) {
            if ((c.next[CellDirection.LEFT] == noone || !c.next[CellDirection.LEFT].connections[CellDirection.DOWN]) &&
                (c.next[CellDirection.RIGHT] != noone && !c.next[CellDirection.RIGHT].connections[CellDirection.DOWN])) {
                if (!(c.next[CellDirection.UP] != noone &&
                      c.next[CellDirection.UP].connections[CellDirection.RIGHT] &&
                      c.next[CellDirection.UP].next[CellDirection.RIGHT] != noone &&
                      c.next[CellDirection.UP].next[CellDirection.RIGHT].connections[CellDirection.RIGHT])) {
                    c.isJoinCandidate = true;
                    if (random(1.0) <= 0.25) {
                        c.connections[CellDirection.DOWN] = true;
                    }
                }
            }
        }
    }
    
    // Right column joining
    for (var j = 1; j < CELL_MAP_SIZE_Y - 1; j++) {
        var c = cellMap[CELL_MAP_SIZE_X - 1][j];
        if (c.raiseHeight) {
            continue;
        }
        
        if (!c.connections[CellDirection.RIGHT] && !c.connections[CellDirection.UP] &&
            !c.connections[CellDirection.DOWN] &&
            (c.next[CellDirection.UP] == noone || !c.next[CellDirection.UP].connections[CellDirection.RIGHT]) &&
            (c.next[CellDirection.DOWN] == noone || !c.next[CellDirection.DOWN].connections[CellDirection.RIGHT])) {
            if (c.connections[CellDirection.LEFT]) {
                var c2 = c.next[CellDirection.LEFT];
                if (!c2.connections[CellDirection.UP] && !c2.connections[CellDirection.DOWN] &&
                    !c2.connections[CellDirection.LEFT]) {
                    c.isJoinCandidate = true;
                    if (random(1.0) <= 0.5) {
                        c.connections[CellDirection.RIGHT] = true;
                    }
                }
            }
        }
    }
}

function pacman_map_set_character_location() {
	
}

/// @description Create tunnel connections
function pacman_map_create_tunnels() {
    var singleDeadEndCells = [];
    var topSingleDeadEndCells = [];
    var botSingleDeadEndCells = [];
    var voidTunnelCells = [];
    var topVoidTunnelCells = [];
    var botVoidTunnelCells = [];
    var edgeTunnelCells = [];
    var topEdgeTunnelCells = [];
    var botEdgeTunnelCells = [];
    var doubleDeadEndCells = [];
    
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        var c = cellMap[CELL_MAP_SIZE_X - 1][j];
        
        if (c.connections[CellDirection.UP]) {
            continue;
        }
        
        if (c.position.y > 1 && c.position.y < CELL_MAP_SIZE_Y - 2) {
            c.isEdgeTunnelCandidate = true;
            array_push(edgeTunnelCells, c);
            if (c.position.y <= 2) {
                array_push(topEdgeTunnelCells, c);
            } else if (c.position.y >= CELL_MAP_SIZE_Y - 4) {
                array_push(botEdgeTunnelCells, c);
            }
        }
        
        var upDead = (c.next[CellDirection.UP] == noone || c.next[CellDirection.UP].connections[CellDirection.RIGHT]);
        var downDead = (c.next[CellDirection.DOWN] == noone || c.next[CellDirection.DOWN].connections[CellDirection.RIGHT]);
        
        if (c.connections[CellDirection.RIGHT]) {
            if (upDead) {
                c.isVoidTunnelCandidate = true;
                array_push(voidTunnelCells, c);
                if (c.position.y <= 2) {
                    array_push(topVoidTunnelCells, c);
                } else if (c.position.y >= CELL_MAP_SIZE_Y - 3) {
                    array_push(botVoidTunnelCells, c);
                }
            }
        } else {
            if (c.connections[CellDirection.DOWN]) {
                continue;
            }
            
            if (upDead != downDead) {
                if (!c.raiseHeight && c.position.y < CELL_MAP_SIZE_Y - 1 &&
                    c.next[CellDirection.LEFT] != noone && !c.next[CellDirection.LEFT].connections[CellDirection.LEFT]) {
                    array_push(singleDeadEndCells, c);
                    c.isSingleDeadEndCandidate = true;
                    c.singleDeadEndDir = upDead ? CellDirection.UP : CellDirection.DOWN;
                    var offset = upDead ? 1 : 0;
                    if (c.position.y <= 1 + offset) {
                        array_push(topSingleDeadEndCells, c);
                    } else if (c.position.y >= CELL_MAP_SIZE_Y - 4 + offset) {
                        array_push(botSingleDeadEndCells, c);
                    }
                }
            } else if (upDead && downDead) {
                if (j > 0 && j < CELL_MAP_SIZE_Y - 1) {
                    if (c.next[CellDirection.LEFT] != noone &&
                        c.next[CellDirection.LEFT].connections[CellDirection.UP] &&
                        c.next[CellDirection.LEFT].connections[CellDirection.DOWN]) {
                        c.isDoubleDeadEndCandidate = true;
                        if (c.position.y >= 2 && c.position.y <= CELL_MAP_SIZE_Y - 4) {
                            array_push(doubleDeadEndCells, c);
                        }
                    }
                }
            }
        }
    }
    
    // Random decision: 1 or 2 tunnels (45% chance of 2)
    var numTunnelsDesired = (random(1.0) <= 0.45) ? 2 : 1;
    
    if (numTunnelsDesired == 1) {
        if (array_length(voidTunnelCells) > 0) {
            voidTunnelCells[floor(random(array_length(voidTunnelCells)))].topTunnel = true;
        } else if (array_length(singleDeadEndCells) > 0) {
            pacman_map_select_single_dead_end(
                singleDeadEndCells[floor(random(array_length(singleDeadEndCells)))]
            );
        } else if (array_length(edgeTunnelCells) > 0) {
            edgeTunnelCells[floor(random(array_length(edgeTunnelCells)))].topTunnel = true;
        } else {
            return false;
        }
    } else if (numTunnelsDesired == 2) {
        if (array_length(doubleDeadEndCells) > 0) {
            var c = doubleDeadEndCells[floor(random(array_length(doubleDeadEndCells)))];
            c.connections[CellDirection.RIGHT] = true;
            c.topTunnel = true;
            if (c.next[CellDirection.DOWN] != noone) {
                c.next[CellDirection.DOWN].topTunnel = true;
            }
        } else {
            var numTunnelsCreated = 1;
            
            // Top tunnel
            if (array_length(topVoidTunnelCells) > 0) {
                topVoidTunnelCells[floor(random(array_length(topVoidTunnelCells)))].topTunnel = true;
            } else if (array_length(topSingleDeadEndCells) > 0) {
                pacman_map_select_single_dead_end(
                    topSingleDeadEndCells[floor(random(array_length(topSingleDeadEndCells)))]
                );
            } else if (array_length(topEdgeTunnelCells) > 0) {
                topEdgeTunnelCells[floor(random(array_length(topEdgeTunnelCells)))].topTunnel = true;
            } else {
                numTunnelsCreated = 0;
            }
            
            // Bottom tunnel
            if (array_length(botVoidTunnelCells) > 0) {
                botVoidTunnelCells[floor(random(array_length(botVoidTunnelCells)))].topTunnel = true;
            } else if (array_length(botSingleDeadEndCells) > 0) {
                pacman_map_select_single_dead_end(
                    botSingleDeadEndCells[floor(random(array_length(botSingleDeadEndCells)))]
                );
            } else if (array_length(botEdgeTunnelCells) > 0) {
                botEdgeTunnelCells[floor(random(array_length(botEdgeTunnelCells)))].topTunnel = true;
            } else {
                if (numTunnelsCreated == 0) {
                    return false;
                }
            }
        }
    }
    
    // Check for exit condition
    var _exit = false;
    var topy = -1;
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        var c = cellMap[CELL_MAP_SIZE_X - 1][j];
        if (c.topTunnel) {
            _exit = true;
            topy = c.tilePosition.y;
            var tempC = c;
            while (tempC.next[CellDirection.LEFT] != noone) {
                tempC = tempC.next[CellDirection.LEFT];
                if (!tempC.connections[CellDirection.UP] && tempC.tilePosition.y == topy) {
                    continue;
                } else {
                    _exit = false;
                    break;
                }
            }
            if (_exit) {
                return false;
            }
        }
    }
    
    // Connect void tunnels
    var len = array_length(voidTunnelCells);
    for (var i = 0; i < len; i++) {
        var c = voidTunnelCells[i];
        if (!c.topTunnel) {
            pacman_map_replace_group(c.group, c.next[CellDirection.UP].group);
            c.connections[CellDirection.UP] = true;
            if (c.next[CellDirection.UP] != noone) {
                c.next[CellDirection.UP].connections[CellDirection.DOWN] = true;
            }
        }
    }
    
    return true;
}

/// @description Select and configure single dead end tunnel
function pacman_map_select_single_dead_end(c) {
    c.connections[CellDirection.RIGHT] = true;
    if (c.singleDeadEndDir == CellDirection.UP) {
        c.topTunnel = true;
    } else {
        if (c.next[CellDirection.DOWN] != noone) {
            c.next[CellDirection.DOWN].topTunnel = true;
        }
    }
}

/// @description Replace all cells of one group with another
function pacman_map_replace_group(oldGroup, newGroup) {
    for (var j = 0; j < CELL_MAP_SIZE_Y; j++) {
        for (var i = 0; i < CELL_MAP_SIZE_X; i++) {
            var c = cellMap[i][j];
            if (c.group == oldGroup) {
                c.group = newGroup;
            }
        }
    }
}