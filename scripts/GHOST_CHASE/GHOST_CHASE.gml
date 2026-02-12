/// ===============================================================================
/// chase_object() - GHOST PATHFINDING ALGORITHM
/// ===============================================================================
/// Purpose: Determine the best direction for a ghost to move toward a target
/// Called: From ghost Step_2 event when at an intersection
/// Parameters:
///   - argument0: Current object X position (tilex)
///   - argument1: Current object Y position (tiley)
///   - argument2: Target X coordinate (chasex/pursuex)
///   - argument3: Target Y coordinate (chasey/pursuey)
/// Returns: 0 (sets global 'dir' variable instead)
///
/// Algorithm:
/// This implements a greedy pathfinding algorithm that:
/// 1. Checks for special collision zones (NoUp, Up, Left, Down, Right)
/// 2. Determines target quadrant relative to current position
/// 3. Calculates which direction is closer (Manhattan distance)
/// 4. Checks for wall collisions before choosing direction
/// 5. Uses codir flag for alternative path selection
///
/// Direction Priority:
/// - Primary: Direction that gets closest to target
/// - Secondary: Alternative direction if primary blocked
/// - Tertiary: Fallback direction if both blocked
///
/// Used by: All ghosts (Blinky, Pinky, Inky, Clyde) and Fruit object
/// ===============================================================================

function chase_object(argument0, argument1, argument2, argument3) {
	
    /// Only process when object is within valid horizontal bounds
    /// Avoids edge cases where wraparound occurs
    if (x > 8 && x < (room_width - 8)) {
        /// Extract parameters into local variables
        objx = argument0;   // Current object X (tile position)
        objy = argument1;   // Current object Y (tile position)
        chasex = argument2; // Target X coordinate
        chasey = argument3; // Target Y coordinate
        
        // ===== SPECIAL COLLISION ZONE: NO UP =====
        /// Some areas prohibit upward movement (e.g., ghost house entrance)
        /// If in NoUp zone and not in eyes state, force horizontal movement
        if (collision_point(objx, objy, NoUp, false, true) && state < 2) {
            /// Currently moving horizontally - continue in same direction
            if (direction == 0) {
                dir = 0;  // Continue right
                return 0;
            }
            if (direction == 180) {
                dir = 2;  // Continue left
                return 0;
            } 
            /// Currently moving down - choose horizontal direction toward target
            if (direction == 270) {
                if ((chasex - objx) > 0) {
                    dir = 0;  // Target is to the right
                    return 0;
                }
                if ((chasex - objx) <= 0) {
                    dir = 2;  // Target is to the left
                    return 0;
                }
            }
        } else {
            // ===== SPECIAL COLLISION ZONES: FORCED DIRECTIONS =====
            /// Some areas force specific directions (e.g., tunnels, exits)
            /// These take priority over normal pathfinding
            
            /// Force UP direction (e.g., tunnel exit)
            if (fruity == 0 && collision_point(objx, objy, Up, false, true) && 
                state == 2 && direction < 270) {
                dir = 1;  // Force up
                return 0;
            } else {
                /// Force LEFT direction
                if (fruity == 0 && collision_point(objx, objy, Left, false, true) && 
                    state == 2 && direction > 0) {
                    dir = 2;  // Force left
                    return 0;
                } else {
                    /// Force DOWN direction
                    if (fruity == 0 && collision_point(objx, objy, Down, false, true) && 
                        state == 2 && (direction > 90 || direction < 90)) {
                        dir = 3;  // Force down
                        return 0;
                    } else {
                        /// Force RIGHT direction
                        if (fruity == 0 && collision_point(objx, objy, Right, false, true) && 
                            state == 2 && (direction > 180 || direction < 180)) {
                            dir = 0;  // Force right
                            return 0;
                        } else {
                            // ===== NORMAL PATHFINDING =====
                            /// No special zones - use greedy pathfinding algorithm
                            /// Algorithm varies based on current movement direction
                            
                            // ===== CURRENT DIRECTION: RIGHT (0°) =====
                            if (direction == 0) {
                                // ===== TARGET QUADRANT: RIGHT AND DOWN =====
                                /// Target is to the right and below current position
                                if ((chasex > objx) && (chasey > objy)) {
                                    /// Calculate which axis has greater distance
                                    if ((chasey - objy) > (chasex - objx)) {
                                        /// Target is farther DOWN than RIGHT
                                        /// Priority: Down > Right > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((chasey - objy) < (chasex - objx)) {
                                        /// Target is farther RIGHT than DOWN
                                        /// Priority: Right > Down > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance - use codir preference
                                        /// Priority: Down > Right > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: RIGHT AND UP =====
                                /// Target is to the right and above current position
                                if ((chasex > objx) && (chasey <= objy)) {
                                    if ((objy - chasey) > (chasex - objx)) {
                                        /// Target is farther UP than RIGHT
                                        /// Priority: Up > Right > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((objy - chasey) < (chasex - objx)) {
                                        /// Target is farther RIGHT than UP
                                        /// Priority: Right > Up > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance - use codir preference
                                        /// Priority: Up > Right > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: LEFT AND DOWN =====
                                /// Target is to the left and below current position
                                if ((chasex <= objx) && (chasey > objy)) {
                                    if ((chasey - objy) > (objx - chasex)) {
                                        /// Target is farther DOWN than LEFT
                                        /// Priority: Down > Right > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((chasey - objy) < (objx - chasex)) {
                                        /// Target is farther LEFT than DOWN
                                        /// Priority: Down > Up > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance - use codir preference
                                        /// Priority: Down > Up > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: LEFT AND UP =====
                                /// Target is to the left and above current position
                                if ((chasex <= objx) && (chasey <= objy)) {
                                    if ((objy - chasey) > (objx - chasex)) {
                                        /// Target is farther UP than LEFT
                                        /// Priority: Up > Right > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((objy - chasey) < (objx - chasex)) {
                                        /// Target is farther LEFT than UP
                                        /// Priority: Up > Down > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance - use codir preference
                                        /// Priority: Up > Down > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // ===== CURRENT DIRECTION: UP (90°) =====
                            /// Similar logic to RIGHT direction, but priorities adjusted for upward movement
                            if (direction == 90) {
                                // ===== TARGET QUADRANT: RIGHT AND DOWN =====
                                if ((chasex > objx) && (chasey > objy)) {
                                    if ((chasey - objy) > (chasex - objx)) {
                                        /// Target farther DOWN than RIGHT
                                        /// Priority: Right > Left > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((chasey - objy) < (chasex - objx)) {
                                        /// Target farther RIGHT than DOWN
                                        /// Priority: Right > Up > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Right > Up > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: RIGHT AND UP =====
                                if ((chasex > objx) && (chasey <= objy)) {
                                    if ((objy - chasey) > (chasex - objx)) {
                                        /// Target farther UP than RIGHT
                                        /// Priority: Up > Right > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((objy - chasey) < (chasex - objx)) {
                                        /// Target farther RIGHT than UP
                                        /// Priority: Right > Up > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Up > Right > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: LEFT AND DOWN =====
                                if ((chasex <= objx) && (chasey > objy)) {
                                    if ((chasey - objy) > (objx - chasex)) {
                                        /// Target farther DOWN than LEFT
                                        /// Priority: Left > Right > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((chasey - objy) < (objx - chasex)) {
                                        /// Target farther LEFT than DOWN
                                        /// Priority: Left > Up > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Left > Up > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: LEFT AND UP =====
                                if ((chasex <= objx) && (chasey <= objy)) {
                                    if ((objy - chasey) > (objx - chasex)) {
                                        /// Target farther UP than LEFT
                                        /// Priority: Up > Left > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((objy - chasey) < (objx - chasex)) {
                                        /// Target farther LEFT than UP
                                        /// Priority: Left > Up > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Up > Left > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // ===== CURRENT DIRECTION: LEFT (180°) =====
                            /// Similar logic to RIGHT direction, mirrored for leftward movement
                            if (direction == 180) {
                                // ===== TARGET QUADRANT: RIGHT AND DOWN =====
                                if ((chasex > objx) && (chasey > objy)) {
                                    if ((chasey - objy) > (chasex - objx)) {
                                        /// Target farther DOWN than RIGHT
                                        /// Priority: Down > Left > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((chasey - objy) < (chasex - objx)) {
                                        /// Target farther RIGHT than DOWN
                                        /// Priority: Down > Up > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Down > Left > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: RIGHT AND UP =====
                                if ((chasex > objx) && (chasey <= objy)) {
                                    if ((objy - chasey) > (chasex - objx)) {
                                        /// Target farther UP than RIGHT
                                        /// Priority: Up > Left > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((objy - chasey) < (chasex - objx)) {
                                        /// Target farther RIGHT than UP
                                        /// Priority: Up > Down > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Up > Left > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: LEFT AND DOWN =====
                                if ((chasex <= objx) && (chasey > objy)) {
                                    if ((chasey - objy) > (objx - chasex)) {
                                        /// Target farther DOWN than LEFT
                                        /// Priority: Down > Left > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((chasey - objy) < (objx - chasex)) {
                                        /// Target farther LEFT than DOWN
                                        /// Priority: Left > Down > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Down > Left > Up
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                    dir = 1;  // Move Up
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: LEFT AND UP =====
                                if ((chasex <= objx) && (chasey <= objy)) {
                                    if ((objy - chasey) > (objx - chasex)) {
                                        /// Target farther UP than LEFT
                                        /// Priority: Up > Left > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((objy - chasey) < (objx - chasex)) {
                                        /// Target farther LEFT than UP
                                        /// Priority: Left > Up > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy - 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                                dir = 1;  // Move Up
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Up > Left > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy - 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy - 16, HanglyWall, false, true))) {
                                            dir = 1;  // Move Up
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // ===== CURRENT DIRECTION: DOWN (270°) =====
                            /// Similar logic to UP direction, mirrored for downward movement
                            if (direction == 270) {
                                // ===== TARGET QUADRANT: RIGHT AND DOWN =====
                                if ((chasex > objx) && (chasey > objy)) {
                                    if ((chasey - objy) > (chasex - objx)) {
                                        /// Target farther DOWN than RIGHT
                                        /// Priority: Down > Right > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((chasey - objy) < (chasex - objx)) {
                                        /// Target farther RIGHT than DOWN
                                        /// Priority: Right > Down > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Down > Right > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: RIGHT AND UP =====
                                if ((chasex > objx) && (chasey <= objy)) {
                                    if ((objy - chasey) > (chasex - objx)) {
                                        /// Target farther UP than RIGHT
                                        /// Priority: Right > Left > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((objy - chasey) < (chasex - objx)) {
                                        /// Target farther RIGHT than UP
                                        /// Priority: Right > Down > Left
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                    dir = 2;  // Move Left
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Right > Left > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx + 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                            dir = 0;  // Move Right
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: LEFT AND DOWN =====
                                if ((chasex <= objx) && (chasey > objy)) {
                                    if ((chasey - objy) > (objx - chasex)) {
                                        /// Target farther DOWN than LEFT
                                        /// Priority: Down > Left > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx, objy + 16, Wall, false, true)) && 
                                            (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                            dir = 3;  // Move Down
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx - 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                                dir = 2;  // Move Left
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((chasey - objy) < (objx - chasex)) {
                                        /// Target farther LEFT than DOWN
                                        /// Priority: Left > Down > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Down > Left > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // ===== TARGET QUADRANT: LEFT AND UP =====
                                if ((chasex <= objx) && (chasey <= objy)) {
                                    if ((objy - chasey) > (objx - chasex)) {
                                        /// Target farther UP than LEFT
                                        /// Priority: Left > Right > Down
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                dir = 0;  // Move Right
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                    (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                    dir = 3;  // Move Down
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                    if ((objy - chasey) < (objx - chasex)) {
                                        /// Target farther LEFT than UP
                                        /// Priority: Left > Down > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    } else {
                                        /// Equal distance
                                        /// Priority: Left > Down > Right
                                        if (codir == 0 && 
                                            (!collision_point(objx - 16, objy, Wall, false, true)) && 
                                            (!collision_point(objx - 16, objy, HanglyWall, false, true))) {
                                            dir = 2;  // Move Left
                                            return 0;
                                        } else {
                                            if ((!collision_point(objx, objy + 16, Wall, false, true)) && 
                                                (!collision_point(objx, objy + 16, HanglyWall, false, true))) {
                                                dir = 3;  // Move Down
                                                return 0;
                                            } else {
                                                if ((!collision_point(objx + 16, objy, Wall, false, true)) && 
                                                    (!collision_point(objx + 16, objy, HanglyWall, false, true))) {
                                                    dir = 0;  // Move Right
                                                    return 0;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
