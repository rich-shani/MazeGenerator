/// ===============================================================================
/// random_direction() - RANDOM DIRECTION SELECTION FOR FRIGHTENED GHOSTS
/// ===============================================================================
/// Purpose: Select random direction at intersections for frightened ghosts
/// Called: When ghost is in frightened state and reaches an intersection
/// Returns: Sets dir variable (0=right, 1=up, 2=left, 3=down)
///
/// Algorithm:
/// Uses weighted probabilities based on current direction to create natural
/// movement patterns. Probabilities are based on classic Pacman behavior.
/// Reference: Retro Game Mechanics Explained (5/29/23)
///
/// The algorithm:
/// 1. Checks available directions (right, up, left, down)
/// 2. Assigns weights to each direction based on current movement
/// 3. Uses weighted random selection to choose direction
/// 4. Prevents reversing direction (ghosts can't turn 180 degrees)
/// ===============================================================================

function random_direction() {
    /// Only process if ghost is within valid horizontal bounds
    if (x > 8 && x < (room_width - 8)) {
        check = 0;  // Counter for available directions
        
        // ===== MOVING RIGHT (direction = 0) =====
        if (direction == 0) {
            /// Check available directions (can't reverse to left)
            /// Right: weight 1
            if (!collision_point(tilex + 16, tiley, Wall, false, true) && 
                !collision_point(tilex + 16, tiley, HanglyWall, false, true)) {
                check = check + 1;  // Right available
            }
            /// Up: weight 3
            if (!collision_point(tilex, tiley - 16, Wall, false, true) && 
                !collision_point(tilex, tiley - 16, HanglyWall, false, true)) {
                check = check + 3;  // Up available
            }
            /// Down: weight 5
            if (!collision_point(tilex, tiley + 16, Wall, false, true) && 
                !collision_point(tilex, tiley + 16, HanglyWall, false, true)) {
                check = check + 5;  // Down available
            }
            
            /// Select direction based on available options
            if (check == 1) { dir = 0; }  // Right alone
            if (check == 3) { dir = 1; }  // Up alone
            if (check == 5) { dir = 3; }  // Down alone
            
            /// Right and Up (25.2% right, 74.8% up)
            if (check == 4) {
                if (random(1) < 0.252) {
                    dir = 0;
                } else {
                    dir = 1;
                }
            }
            
            /// Right and Down (28.5% down, 71.5% right)
            if (check == 6) {
                if (random(1) < 0.285) {
                    dir = 3;
                } else {
                    dir = 0;
                }
            }
            
            /// Up and Down (46.3% up, 53.7% down)
            if (check == 8) {
                if (random(1) < 0.463) {
                    dir = 1;
                } else {
                    dir = 3;
                }
            }
            
            /// Right, Up, and Down (25.2% right, 38.1% down, 36.7% up)
            if (check == 9) {
                if (random(1) < 0.252) {
                    dir = 0;
                } else {
                    if (random(1) < 0.381) {
                        dir = 3;
                    } else {
                        dir = 1;
                    }
                }
            }
            exit;
        }
        
        // ===== MOVING UP (direction = 90) =====
        if (direction == 90) {
            /// Check available directions (can't reverse to down)
            /// Right: weight 1
            if (!collision_point(tilex + 16, tiley, Wall, false, true) && 
                !collision_point(tilex + 16, tiley, HanglyWall, false, true)) {
                check = check + 1;  // Right available
            }
            /// Up: weight 3
            if (!collision_point(tilex, tiley - 16, Wall, false, true) && 
                !collision_point(tilex, tiley - 16, HanglyWall, false, true)) {
                check = check + 3;  // Up available
            }
            /// Left: weight 5
            if (!collision_point(tilex - 16, tiley, Wall, false, true) && 
                !collision_point(tilex - 16, tiley, HanglyWall, false, true)) {
                check = check + 5;  // Left available
            }
            
            /// Select direction based on available options
            if (check == 1) { dir = 0; }  // Right alone
            if (check == 3) { dir = 1; }  // Up alone
            if (check == 5) { dir = 2; }  // Left alone
            
            /// Right and Up (25.2% right, 74.8% up)
            if (check == 4) {
                if (random(1) < 0.252) {
                    dir = 0;
                } else {
                    dir = 1;
                }
            }
            
            /// Right and Left (41.5% right, 58.5% left)
            if (check == 6) {
                if (random(1) < 0.415) {
                    dir = 0;
                } else {
                    dir = 2;
                }
            }
            
            /// Up and Left (16.3% up, 83.7% left)
            if (check == 8) {
                if (random(1) < 0.163) {
                    dir = 1;
                } else {
                    dir = 2;
                }
            }
            
            /// Right, Up, and Left (16.3% up, 30.1% right, 53.6% left)
            if (check == 9) {
                if (random(1) < 0.163) {
                    dir = 1;
                } else {
                    if (random(1) < 0.301) {
                        dir = 0;
                    } else {
                        dir = 2;
                    }
                }
            }
            exit;
        }
        
        // ===== MOVING LEFT (direction = 180) =====
        if (direction == 180) {
            /// Check available directions (can't reverse to right)
            /// Left: weight 1
            if (!collision_point(tilex - 16, tiley, Wall, false, true) && 
                !collision_point(tilex - 16, tiley, HanglyWall, false, true)) {
                check = check + 1;  // Left available
            }
            /// Up: weight 3
            if (!collision_point(tilex, tiley - 16, Wall, false, true) && 
                !collision_point(tilex, tiley - 16, HanglyWall, false, true)) {
                check = check + 3;  // Up available
            }
            /// Down: weight 5
            if (!collision_point(tilex, tiley + 16, Wall, false, true) && 
                !collision_point(tilex, tiley + 16, HanglyWall, false, true)) {
                check = check + 5;  // Down available
            }
            
            /// Select direction based on available options
            if (check == 1) { dir = 2; }  // Left alone
            if (check == 3) { dir = 1; }  // Up alone
            if (check == 5) { dir = 3; }  // Down alone
            
            /// Left and Up (16.3% up, 83.7% left)
            if (check == 4) {
                if (random(1) < 0.163) {
                    dir = 1;
                } else {
                    dir = 2;
                }
            }
            
            /// Left and Down (30.0% left, 70.0% down)
            if (check == 6) {
                if (random(1) < 0.300) {
                    dir = 2;
                } else {
                    dir = 3;
                }
            }
            
            /// Up and Down (46.3% up, 53.7% down)
            if (check == 8) {
                if (random(1) < 0.463) {
                    dir = 1;
                } else {
                    dir = 3;
                }
            }
            
            /// Left, Up, and Down (16.3% up, 35.8% left, 47.9% down)
            if (check == 9) {
                if (random(1) < 0.163) {
                    dir = 1;
                } else {
                    if (random(1) < 0.358) {
                        dir = 2;
                    } else {
                        dir = 3;
                    }
                }
            }
            exit;
        }
        
        // ===== MOVING DOWN (direction = 270) =====
        if (direction == 270) {
            /// Check available directions (can't reverse to up)
            /// Right: weight 1
            if (!collision_point(tilex + 16, tiley, Wall, false, true) && 
                !collision_point(tilex + 16, tiley, HanglyWall, false, true)) {
                check = check + 1;  // Right available
            }
            /// Down: weight 3
            if (!collision_point(tilex, tiley + 16, Wall, false, true) && 
                !collision_point(tilex, tiley + 16, HanglyWall, false, true)) {
                check = check + 3;  // Down available
            }
            /// Left: weight 5
            if (!collision_point(tilex - 16, tiley, Wall, false, true) && 
                !collision_point(tilex - 16, tiley, HanglyWall, false, true)) {
                check = check + 5;  // Left available
            }
            
            /// Select direction based on available options
            if (check == 1) { dir = 0; }  // Right alone
            if (check == 3) { dir = 3; }  // Down alone
            if (check == 5) { dir = 2; }  // Left alone
            
            /// Right and Down (28.5% down, 71.5% right)
            if (check == 4) {
                if (random(1) < 0.285) {
                    dir = 3;
                } else {
                    dir = 0;
                }
            }
            
            /// Right and Left (41.5% right, 58.5% left)
            if (check == 6) {
                if (random(1) < 0.415) {
                    dir = 0;
                } else {
                    dir = 2;
                }
            }
            
            /// Down and Left (30.0% left, 70.0% down)
            if (check == 8) {
                if (random(1) < 0.300) {
                    dir = 2;
                } else {
                    dir = 3;
                }
            }
            
            /// Right, Down, and Left (28.5% down, 41.2% left, 30.3% right)
            if (check == 9) {
                if (random(1) < 0.285) {
                    dir = 3;
                } else {
                    if (random(1) < 0.412) {
                        dir = 2;
                    } else {
                        dir = 0;
                    }
                }
            }
            exit;
        }
    }
}
