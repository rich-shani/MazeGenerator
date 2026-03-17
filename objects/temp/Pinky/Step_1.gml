/// ===============================================================================
/// PINKY GHOST - STEP_1 EVENT (TARGET CALCULATION - AMBUSH PREDATOR)
/// ===============================================================================
/// Purpose: Calculate Pinky's target position using ambush/predictive strategy
/// Called: Every frame (second step event, after Step_0 animation)
/// Parent: oGhost (inherits base ghost behavior)
///
/// Pinky's Personality: "Speedy" - Ambush Predator
/// Strategy: Pinky tries to AMBUSH Pac by targeting 2 tiles ahead of Pac's movement
/// This makes Pinky appear to "cut off" Pac's path rather than directly chase
///
/// Single-Player Support:
/// Pinky targets 2 tiles ahead of Pac's movement direction
///
/// Algorithm:
/// 1. Calculate target for Player 1: 2 tiles ahead of Pac's movement direction
/// 2. Set pursuex/pursuey to Pac's predicted position
/// ===============================================================================

// ===== ANIMATION UPDATE =====
/// Increment animation frame counter
/// Cycles 0-15 continuously for walking animation
im = im + 1;
if (im == 16) {
    im = 0;  // Wrap back to 0 after reaching 15
}

// ===== FRIGHTENED MODE FLASHING EFFECT =====
/// Handle flashing effect when power pellet is active
/// Flash timing matches original arcade behavior
if (Pac.alarm[0] > 120) {
    flash = 0;  // No flashing when plenty of time remains
}
if (Pac.alarm[0] == 120) {
    flash = 1;  // Start flashing
}
if (Pac.alarm[0] == 106) {
    flash = 0;
}
if (Pac.alarm[0] == 92) {
    flash = 1;
}
if (Pac.alarm[0] == 78) {
    flash = 0;
}
if (Pac.alarm[0] == 64) {
    flash = 1;
}
if (Pac.alarm[0] == 60) {
    flash = 1;
}
if (Pac.alarm[0] == 50) {
    flash = 0;
}
if (Pac.alarm[0] == 36) {
    flash = 1;
}
if (Pac.alarm[0] == 22) {
    flash = 0;
}
if (Pac.alarm[0] == 8) {
    flash = 1;
}
if (Pac.alarm[0] == 0) {
    flash = 0;  // Stop flashing when power pellet expires
}

// ===== TARGET CALCULATION - TWO PLAYER SUPPORT =====
/// Calculate target positions for both players
/// Pinky chooses which player to target based on proximity

/// Calculate Player 1 (Pac) target: 2 tiles ahead of movement direction
/// Pac.xdir and Pac.ydir are unit vectors (-1, 0, or 1) indicating direction
/// Multiply by 2 to get 2 tiles ahead, then multiply by 16 to convert to pixels
var _pac_target_x = 16 * (round(Pac.x / 16)) + (2 * Pac.xdir);
var _pac_target_y = 16 * (round(Pac.y / 16)) + (2 * Pac.ydir);

/// Set target to Pac's predicted position (2 tiles ahead)
pursuex = _pac_target_x;
pursuey = _pac_target_y;

// ===== PATHFINDING AT INTERSECTIONS =====
/// Handle pathfinding when ghost reaches a new tile
/// This logic determines which direction Pinky should turn
if (y > 48 && y < room_height - 48) {
    /// Keep ghost in vertical bounds (avoids room edges where wrapping occurs)
    
    if (house == 0) {
        /// Only pathfind when ghost is FREE (not in house bouncing)
        
        if (Pac.chomp == 0 || state == 2) {
            /// Only turn when Pac is moving (chomp==0) OR in eyes mode (always pathfind)
            
            if (newtile == 0) {
                /// newtile=0 means ghost has NOT reached intersection yet
                /// Check if we're aligned to grid
                
                if (tilex == (16 * (round(x / 16))) && tiley == (16 * (round(y / 16)))) {
                    /// Already aligned: no action needed
                } else {
                    /// Ghost has JUST reached a new tile (position changed since last frame)
                    /// Update newtile flag and calculate new tile coordinates
                    
                    newtile = 1;  // Mark that we hit intersection
                    tilex = (16 * (round(x / 16)));
                    tiley = (16 * (round(y / 16)));
                    
                    /// ===== DIRECTION DECISION LOGIC =====
                    /// Now decide which direction to turn based on state and behavior
                    
                    if (aboutface == 0) {
                        /// No reversal needed: make normal pathfinding decision
                        
                        if (state == 0) {
                            /// CHASE MODE: Hunt target using Pinky's ambush strategy
                            
                            if (Pac.scatter == 1) {
                                /// Scatter mode active: ghosts avoid Pac, go to corners
                                
                                if (global.ex1 == 0 && room_width == 448) {
                                    /// Standard mode: Chase to scatter corner
                                    script_execute(chase_object, tilex, tiley, cornerx, cornery);
                                } else {
                                    /// Exception mode: Random movement
                                    script_execute(random_direction);
                                }
                            } else {
                                /// Normal chase: Hunt target using Pinky's ambush strategy
                                /// pursuex/pursuey already set above (2 tiles ahead of chosen player)
                                script_execute(chase_object, tilex, tiley, pursuex, pursuey);
                            }
                        }
                        
                        if (state == 1) {
                            /// FRIGHTENED MODE: Random movement (power pellet active)
                            script_execute(random_direction);
                        }
                        
                        if (state == 2) {
                            /// EYES MODE: Chase house entrance to resurrect
                            /// Target is always house entrance (xstart, ystart)
                            script_execute(chase_object, tilex, tiley, (xstart - 184) + 208, (ystart - 272) + 224);
                        }
                    } else {
                        /// ABOUT-FACE: Ghost needs to reverse direction (power pellet eaten)
                        /// Convert current direction (angle) to cardinal direction
                        dir = (direction / 90) + 2;  // Rotate 180 degrees
                        if (dir > 3) {
                            dir = dir - 4;  // Wrap around (0-3 range)
                        }
                        aboutface = 0;  // Clear flag, reversal complete
                    }
                }
            }
        }
    }
}

/// ===============================================================================
/// END PINKY STEP_1 EVENT
/// ===============================================================================
