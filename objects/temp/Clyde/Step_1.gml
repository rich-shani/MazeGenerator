/// ===============================================================================
/// CLYDE GHOST - STEP_1 EVENT (TARGET CALCULATION - AMBIGUOUS PURSUER)
/// ===============================================================================
/// Purpose: Calculate Clyde's target position using distance-based switching strategy
/// Called: Every frame (second step event, after Step_0 animation)
/// Parent: oGhost (inherits base ghost behavior)
///
/// Clyde's Personality: "Pokey" - Ambiguous/Shy Behavior
/// Strategy: Clyde changes behavior based on distance to Pac
/// - Close (< 128 pixels): Flee to scatter corner (shy behavior)
/// - Far (>= 128 pixels): Chase Pac directly (like Blinky)
///
/// Single-Player Support:
/// Clyde chooses behavior based on distance to Pac
///
/// Algorithm:
/// 1. Calculate Manhattan distance from Clyde to Player 1 (Pac)
/// 2. If Pac is close (< 128 pixels): Target scatter corner (flee)
/// 3. If Pac is far (>= 128 pixels): Target Pac directly (chase)
/// 4. Set pursuex/pursuey to chosen target
///
/// This creates unpredictable behavior: Clyde appears to "change his mind"
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

// ===== TARGET CALCULATION - DISTANCE-BASED SWITCHING =====
/// Calculate target positions using distance-based personality
/// Clyde chooses which player to target, then decides whether to chase or flee

/// Calculate Player 1 (Pac) grid position
var _pac_tile_x = 16 * (round(Pac.x / 16));
var _pac_tile_y = 16 * (round(Pac.y / 16));

/// ===== DISTANCE-BASED BEHAVIOR SWITCHING =====
/// Clyde's personality: close = flee, far = chase
/// Threshold: 128 pixels (8 tiles) Manhattan distance

/// Check if Pac is within flee distance
/// Use collision_circle to check if player is within 128 pixel radius
var _player_close = collision_circle(_pac_tile_x + 8, _pac_tile_y + 8, 128, Clyde, false, false);

if (_player_close) {
    /// Player is TOO CLOSE (< 128 pixels): Flee to scatter corner
    /// Clyde's shy behavior: when threatened, run away instead of chase
    pursuex = cornerx;
    pursuey = cornery;
} else {
    /// Player is SAFE DISTANCE (>= 128 pixels): Chase directly
    /// Clyde's normal behavior: pursue like Blinky when not threatened
    pursuex = _pac_tile_x;
    pursuey = _pac_tile_y;
}

// ===== PATHFINDING AT INTERSECTIONS =====
/// Handle pathfinding when ghost reaches a new tile
/// This logic determines which direction Clyde should turn
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
                            /// CHASE MODE: Hunt target using Clyde's distance-based strategy
                            
                            if (Pac.scatter == 1) {
                                /// Scatter mode active: always go to scatter corner
                                script_execute(chase_object, tilex, tiley, cornerx, cornery);
                            } else {
                                /// Normal chase: Check if player is close (flee) or far (chase)
                                /// This check uses collision_circle to determine if player is within 128 pixels
                                
                                if (collision_circle(_pac_tile_x + 8, _pac_tile_y + 8, 128, Clyde, false, false)) {
                                    /// Player too close: Flee to scatter corner
                                    script_execute(chase_object, tilex, tiley, cornerx, cornery);
                                } else {
                                    /// Player at safe distance: Chase directly
                                    /// pursuex/pursuey already set above (Pac position)
                                    script_execute(chase_object, tilex, tiley, pursuex, pursuey);
                                }
                            }
                        }
                        
                        if (state == 1) {
                            /// FRIGHTENED MODE: Random movement (power pellet active)
                            script_execute(random_direction);
                        }
                        
                        if (state == 2) {
                            /// EYES MODE: Chase house entrance to resurrect
                            /// Target is always house entrance (xstart, ystart)
                            script_execute(chase_object, tilex, tiley, (xstart - 248) + 208, (ystart - 272) + 224);
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
/// END CLYDE STEP_1 EVENT
/// ===============================================================================
