/// ===============================================================================
/// oGHOST - BASE GHOST OBJECT - END_STEP EVENT (MOVEMENT & TURNING)
/// ===============================================================================
/// Purpose: Handle movement, turning, house logic, and speed management
/// Called: Every frame (third step event, after Step_0 and Step_1)
/// Parent: oGhost
///
/// This is the MOST COMPLEX event, handling:
/// 1. House state machine (getting out of ghost house)
/// 2. Speed determination (based on state and position)
/// 3. Turning at intersections (pathfinding to target)
/// 4. Wraparound handling (tunnel teleport)
/// 5. Elroy mode (faster pursuit when dots low)
/// 6. Direction reversal (for power pellet)
///
/// Structure: House logic → Elroy → Speed → Turning → Special checks → Visibility
/// ===============================================================================

if (state == GHOST_STATE.IN_HOUSE || state == GHOST_STATE.LEAVING_HOUSE) {
	ghost_house_step();
}

// ===== ELROY MODE INDICATOR =====
/// Update elroy variable (used by Draw for visual effects and by ghost_speed_step for speed).
/// Must run before ghost_speed_step() so the correct speed tier is applied this frame.
///
/// Elroy threshold logic:
/// - elroydots2: Ultra-aggressive threshold (2nd speed boost)
/// - elroydots: Initial aggressive threshold (1st speed boost)
/// - Both require oPacman.csig condition (ghosts released from house) or oClyde free

if (oPacman.dotcount >= elroydots2 && (oPacman.dotcount >= oPacman.csig || oClyde.house == 0)) {
    elroy = 2;
} else if (oPacman.dotcount >= elroydots && (oPacman.dotcount >= oPacman.csig || oClyde.house == 0)) {
    elroy = 1;
} else {
    elroy = 0;
}

ghost_speed_step();

// ===== PATHFINDING AT INTERSECTIONS =====
/// Core ghost pathfinding logic: when ghost reaches a new tile, decide next direction
/// This is the MAIN DECISION POINT for ghost turning and movement
///
/// Process:
/// 1. Check if in playable area (avoid edges with wrapping)
/// 2. Check if ghost is free (not in house)
/// 3. Check if Pac is moving (not eating/paused)
/// 4. On new tile: Make turning decision based on state
/// 5. Apply pathfinding script based on behavior mode

if (( y > 8 && y < room_height - 8)) {
    /// Keep ghost in vertical bounds (avoids room edges where wrapping occurs)
    /// Top: y > 48 (below top of screen)
    /// Bottom: y < room_height - 48 (above bottom of screen)

    if (house == 0) {
        /// Only pathfind when ghost is FREE (not in house bouncing)
        /// When house == 1, movement is controlled by house state machine above

        if (oPacman.chomp == 0 || state == GHOST_STATE.EYES) {
            /// Only turn when Pac is moving (chomp==0) OR in eyes mode (always pathfind)
            /// oPacman.chomp pauses ghost turning when Pac is eating (maintains sync)

            if (newtile == 0) {
                /// newtile=0 means ghost has NOT reached intersection yet
                /// Keep checking if we're aligned to grid

                // Check if ghost position matches grid (no offset)
                var _is_grid_aligned = (tilex == (TILE_PIXELS * round(x / TILE_PIXELS)) && tiley == (TILE_PIXELS * round(y / TILE_PIXELS)));

                if (!_is_grid_aligned) {
                    /// Ghost has JUST reached a new tile (position changed since last frame)
                    /// Update newtile flag and calculate new tile coordinates

                    newtile = 1;  // Mark that we hit intersection
                    tilex = (TILE_PIXELS * round(x / TILE_PIXELS));
                    tiley = (TILE_PIXELS * round(y / TILE_PIXELS));

                    /// ===== DIRECTION DECISION LOGIC =====
                    /// Now decide which direction to turn based on state and behavior

                    if (aboutface == 0) {
                        /// No reversal needed: make normal pathfinding decision

                        if (state == GHOST_STATE.CHASE) {
                            /// CHASE MODE: Hunt Pac using ghost-specific strategy
                            /// (overridden by child ghosts with unique behavior)
 
                            if (oPacman.scatter == 1) {
								/// Scatter mode active: ghosts avoid Pac, go to corners
          
                                if (oPacman.dotcount >= elroydots && (oPacman.dotcount >= oPacman.csig || Clyde.house == 0)) {
                                    /// Elroy mode 1+: Chase Pac even in scatter
                                    script_execute(chase_object, tilex, tiley, pursuex, pursuey);
                                } else {
                                    /// Normal scatter: Go to scatter corner (or random if exception)
                                        /// Standard mode: Chase to corner
                                        script_execute(chase_object, tilex, tiley, cornerx, cornery);   
                                }
                            } else {
                                /// Normal chase: Hunt Pac using this ghost's strategy
                                script_execute(chase_object, tilex, tiley, pursuex, pursuey);
                            }
                        }
                        //else if (state == GHOST_STATE.FRIGHTENED) {
                        //    /// FRIGHTENED MODE: Random movement (power pellet active)
                        //    /// Same for all ghosts - no special behavior
                        //    script_execute(GHOST_FRIGHTENED);
                        //}
                        else if (state == GHOST_STATE.EYES) {
                            /// EYES MODE: Chase house entrance to resurrect
                            /// Ghost is just eyes, returning home at high speed
                            /// Target is always house entrance (xstart, ystart)
                            var _house_x = (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_ENTRANCE_X;
                            var _house_y = (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y;
                            script_execute(chase_object, tilex, tiley, _house_x, _house_y);
                        }
                    }
                    else {
                        /// ABOUT-FACE: Reverse the actual current movement direction
                        dir = direction_opposite(dir_applied);
                        aboutface = 0;
                    }
                }
            }
        }
    }
}

// ===== GRID-ALIGNED TURNING AT INTERSECTIONS =====
/// Apply direction to position with grid alignment corrections
/// This section handles the physics of turning smoothly at intersections
///
/// The pathfinding logic above (chase_object/random_direction) sets the DESIRED direction (dir)
/// This section applies that direction while keeping the ghost perfectly aligned to the 16-pixel grid
///
/// Why grid alignment matters:
/// - Ghosts move on a 16x16 pixel grid
/// - During movement, ghosts can drift slightly off grid (sub-pixel movement)
/// - When turning, we need to snap back to grid while moving perpendicular
/// - The math: apply offset equal to drift amount in perpendicular direction

if ((oPacman.dead == 0 && oPacman.finish == 0)) {

    if (oPacman.chomp == 0 || state == GHOST_STATE.EYES) {
        /// Turn only when Pac is not eating (not paused) OR in eyes mode
        /// This keeps ghost movement synchronized with Pac

        if (newtile == 1) {
            /// Data-driven grid turn: one lookup (desired dir, current dir) -> apply correction and clear newtile
            var _r = ghost_apply_grid_turn(dir, dir_applied, tilex, tiley, x, y);
            if (_r.applied) {
                x         = _r.x;
                y         = _r.y;
                dir_applied = _r.dir;
                // Convert GRID_DIRECTION → GML physics degrees (single conversion point)
                switch (dir_applied) {
                    case GRID_DIRECTION.RIGHT: direction = 0;   break;
                    case GRID_DIRECTION.UP:    direction = 90;  break;
                    case GRID_DIRECTION.LEFT:  direction = 180; break;
                    case GRID_DIRECTION.DOWN:  direction = 270; break;
                }
                newtile = 0;
            }
        }
    }
}  // End Pac alive check

// ===== VISIBILITY FLASHING (FRIGHTENED MODE) =====
/// Manage ghost visibility during power pellet mode
/// Flashing effect (white flashing) is handled in Step_0 event
/// This just ensures visibility state is correct
///
/// Visibility logic:
/// - Frightened mode with <121 frames left: Flash on/off (warning effect)
/// - Normal modes or plenty of time left: Always visible

//if (state == GHOST_STATE.FRIGHTENED) {
//    /// Power pellet active: ghost is vulnerable
//    if (oPacman.alarm[0] < 121) {
//        /// Near end of power pellet: apply flashing effect (handled in Step_0)
//        /// Keep visible (Step_0 controls the actual flashing)
//        visible = true;
//    }
//} else {
//    /// Normal states (Chase, Eyes, In_House): always visible
//    visible = true;
//}

/// ===============================================================================
/// END oGHOST STEP_2 EVENT
/// ===============================================================================