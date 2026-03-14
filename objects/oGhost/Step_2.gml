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
/// Structure: House logic → Speed → Turning → Special checks → Visibility
/// ===============================================================================

// ===== HOUSE STATE MACHINE =====
/// Handle ghosts inside the ghost house (bouncing and exiting)
/// This system manages the complex behavior of ghosts bouncing up/down inside the house
/// and exiting to roam the maze
///
/// House system overview:
/// - house == 0: Ghost is FREE, roaming the maze
/// - house == 1: Ghost is INSIDE house, in exit sequence
/// - housestate: Variable state machine (0-4) tracking progress within house
/// - Different ghosts may override this event with custom house logic
///
/// Ghost house location (standard): xstart=216, ystart=224 (center of house)
/// House zones:
///   - Entrance: (216, 224) - where eyes arrive
///   - Middle: (216, 240-272) - bounce zone
///   - Exit: Top of house, leading to maze

if (oPacman.dead == 0 && oPacman.finish == 0) {
    /// Only process house logic when Pac is alive and game not finished

    // ===== HOUSE: TILE ALIGNMENT WHEN INSIDE =====
    /// Keep ghost position aligned to grid while in house
    /// House movement uses fixed coordinates, not pathfinding

    if (house == 1) {
        /// Ghost is inside house: keep it grid-aligned for consistent behavior
        /// Calculate grid position relative to house center
        tilex = (xstart - 216) + 224;  /// Align X to house center
        tiley = (ystart - 224) + 224;  /// Align Y to house center
    }

    // ===== HOUSE: EYES ARRIVAL & ENTRY =====
    /// When ghost eyes reach house entrance, transform back into full ghost
    /// Eyes float to position (216±8, 224) then enter house

    if (house == 0 && state == GHOST_STATE.EYES &&
        x > (xstart - 216) + 212 && x < (xstart - 216) + 220 &&
        y == (ystart - 224) + 224) {
        /// Eyes reached entrance (x within ±8, y exact match)

        // Snap position and set up house entry
        housestate = 0;  /// Start house state machine (phase 0)
        x = (xstart - 216) + 216;  /// Snap to house center X
        y = (ystart - 224) + 224;  /// Snap to entrance Y
        hspeed = 0;  /// Stop horizontal movement
        vspeed = speyes;  /// Move down at eyes speed
        house = 1;  /// Now in house
        dir = GHOST_DIRECTION.DOWN;  /// Face down to begin bounce sequence
    }

    // ===== HOUSE: PHASE 1 - DOWN BOUNCE =====
    /// Eyes move down into house, reaching the bounce floor
    /// Once reached, begin moving back up toward exit

    if (house == 1 && state == GHOST_STATE.EYES &&
        x == (xstart - 216) + 216 && y > (ystart - 224) + 272 + 8) {
        /// Reached bottom of house bounce zone (y > 280)

        // Transition to phase 2: exit sequence
        housestate = 1;  /// Phase 1 complete, moving to phase 2
        x = (xstart - 216) + 216;  /// Maintain center X
        y = (ystart - 224) + 272 + 8;  /// Snap to bottom position
        hspeed = 0;  /// Stop horizontal movement
        vspeed = -spslow;  /// Move up slowly (standard slow speed)
        state = GHOST_STATE.CHASE;  /// Resume normal ghost behavior (not just eyes)
        dir = GHOST_DIRECTION.UP;  /// Face up to exit
    }

    // ===== HOUSE: PHASE 2 - UP EXIT =====
    /// Ghost moves up through house from bounce zone toward entrance
    /// Continues until reaching entrance (y < 224)

    if (housestate == 1) {
        /// Phase 2 active: continuously move up at slow speed
        /// This persists every frame until ghost reaches entrance

        hspeed = 0;  /// Stay centered horizontally
        vspeed = -spslow;  /// Move up slowly
    }

    // ===== HOUSE: COMPLETE EXIT =====
    /// Ghost successfully exits house and becomes free
    /// Position is snapped to entrance and movement begins

    if (house == 1 && state < GHOST_STATE.EYES &&
        x == (xstart - 216) + 216 && y < (ystart - 224) + 224) {
        /// Ghost reached entrance (y < 224) while not in eyes state
        /// This means full ghost (not eyes) is at exit point

        // Finalize exit and release ghost
        housestate = 0;  /// Reset house state (no longer in house)
        x = (xstart - 216) + 216;  /// Snap to entrance X
        y = (ystart - 224) + 224;  /// Snap to entrance Y
        hspeed = sp;  /// Begin moving left (at normal speed)
        vspeed = 0;  /// No vertical movement
        house = 0;  /// RELEASED - now free to roam maze
        newtile = 0;  /// Reset intersection flag for pathfinding
        dir = GHOST_DIRECTION.LEFT;  /// Face left to exit maze
    }

}  // End Pac alive check

// ===== SPEED DETERMINATION =====
/// Calculate ghost movement speed based on current state and map location
/// This determines how fast the ghost moves each frame
///
/// Speed hierarchy:
/// 1. Location check: Is ghost in slow area (tunnel)?
/// 2. State check: What is ghost doing (Chase/Frightened/Eyes)?
/// 3. Dot check: For chase mode, is Elroy mode active?
///
/// Speeds available:
/// - sp: Normal speed (1.875 pixels/frame)
/// - spslow: Tunnel speed (1.0 pixels/frame)
/// - spfright: Frightened speed (1.25 pixels/frame)
/// - spelroy: Elroy mode 1 (2.0 pixels/frame)
/// - spelroy2: Elroy mode 2 (2.125 pixels/frame)
/// - speyes: Eyes return speed (4.0 pixels/frame)

if (oPacman.dead == 0 && oPacman.finish == 0) {
    /// Only process speed when Pac is alive

    if (house == 0) {
        /// Ghost is FREE (not in house bouncing/exiting)
        /// Calculate appropriate speed for current situation

        // ===== LOCATION CHECK =====
        /// Check if ghost is in slow area (tunnel or special zone)
        /// Uses collision_point with "Slow" collision object
        var _in_slow_area = collision_point(tilex, tiley, Slow, false, true);

        // ===== SPEED BY STATE =====
        /// Determine base speed based on ghost's behavioral state

        if (state == GHOST_STATE.CHASE) {
            /// CHASE MODE: Hunt Pac using pathfinding
            /// Speed depends on location and dot count (Elroy mode)

            if (_in_slow_area) {
                /// In tunnel or slow zone: reduce to tunnel speed
                speed = spslow;
            } else {
                /// Normal maze area: check Elroy mode activation
                /// Elroy makes ghosts faster when dots are nearly gone

                if (oPacman.dotcount >= elroydots2 && (oPacman.dotcount >= oPacman.csig || Clyde.house == 0)) {
                    /// ELROY MODE 2: Dots at ultra-low threshold
                    /// Ghost at maximum hunting speed
                    speed = spelroy2;  // 2.125 pixels/frame (fastest)
                }
                else if (oPacman.dotcount >= elroydots && (oPacman.dotcount >= oPacman.csig || Clyde.house == 0)) {
                    /// ELROY MODE 1: Dots at first low threshold
                    /// Ghost noticeably faster
                    speed = spelroy;   // 2.0 pixels/frame (fast)
                }
                else {
                    /// NORMAL SPEED: Plenty of dots remain
                    /// Standard hunt speed
                    speed = sp;        // 1.875 pixels/frame (normal)
                }
            }
        }
        else if (state == GHOST_STATE.FRIGHTENED) {
            /// FRIGHTENED MODE: Power pellet active, ghost is vulnerable
            /// Ghost moves slower when power pellet is active

            if (_in_slow_area) {
                /// In tunnel: use slow tunnel speed (already slow enough)
                speed = spslow;
            } else {
                /// Normal maze: use frightened speed (reduced from normal)
                speed = spfright;  // 1.25 pixels/frame (slower)
            }
        }
        else if (state == GHOST_STATE.EYES) {
            /// EYES MODE: Ghost was eaten, eyes returning to house
            /// Eyes move very fast to resurrect quickly

            speed = speyes;  // 4.0 pixels/frame (very fast)
            /// Note: Tunnel speed doesn't apply to eyes (they go straight to house)
        }
    }

}  // End Pac alive check

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

if (y > 8 && y < room_height - 8) {
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
                var _is_grid_aligned = (tilex == (16 * round(x / 16)) && tiley == (16 * round(y / 16)));

                if (!_is_grid_aligned) {
                    /// Ghost has JUST reached a new tile (position changed since last frame)
                    /// Update newtile flag and calculate new tile coordinates

                    newtile = 1;  // Mark that we hit intersection
                    tilex = (16 * round(x / 16));
                    tiley = (16 * round(y / 16));

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
                        else if (state == GHOST_STATE.FRIGHTENED) {
                            /// FRIGHTENED MODE: Random movement (power pellet active)
                            /// Same for all ghosts - no special behavior
                            script_execute(random_direction);
                        }
                        else if (state == GHOST_STATE.EYES) {
                            /// EYES MODE: Chase house entrance to resurrect
                            /// Ghost is just eyes, returning home at high speed
                            /// Target is always house entrance (xstart, ystart)
                            var _house_x = (xstart - 216) + 208;
                            var _house_y = (ystart - 224) + 224;
                            script_execute(chase_object, tilex, tiley, _house_x, _house_y);
                        }
                    }
                    else {
                        /// ABOUT-FACE: Ghost needs to reverse direction (power pellet eaten)
                        /// Convert current direction (angle) to cardinal direction
                        /// direction is in degrees (0, 90, 180, 270)
                        /// dir is cardinal (0-3)

                        dir = round(direction / 90) + 2;  // Rotate 180 degrees
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

if (oPacman.dead == 0 && oPacman.finish == 0) {

    if (oPacman.chomp == 0 || state == GHOST_STATE.EYES) {
        /// Turn only when Pac is not eating (not paused) OR in eyes mode
        /// This keeps ghost movement synchronized with Pac

        if (newtile == 1) {
            /// Data-driven grid turn: one lookup (dir, direction) -> apply correction and clear newtile
            var _r = ghost_apply_grid_turn(dir, direction, tilex, tiley, x, y);
            if (_r.applied) {
                x = _r.x;
                y = _r.y;
                direction = _r.direction;
                newtile = 0;
            }
        }
    }
}  // End Pac alive check

// ===== ELROY MODE INDICATOR =====
/// Update elroy variable for visual effects (red eyes when in Elroy mode)
/// This is used by the Draw event to show visual effects
/// Elroy mode activates when dots get low, making ghosts faster hunters
///
/// Elroy threshold logic:
/// - elroydots2: Ultra-aggressive threshold (2nd speed boost)
/// - elroydots: Initial aggressive threshold (1st speed boost)
/// - Both require oPacman.csig condition (ghosts released from house) or Clyde free

if (oPacman.dotcount >= elroydots2 && (oPacman.dotcount >= oPacman.csig || Clyde.house == 0)) {
    /// ELROY MODE 2: Ultra-aggressive, fastest speed
    /// Triggers when dot count drops to lowest threshold
    elroy = 2;
} else if (oPacman.dotcount >= elroydots && (oPacman.dotcount >= oPacman.csig || Clyde.house == 0)) {
    /// ELROY MODE 1: Aggressive, fast speed
    /// Triggers when dot count drops to first threshold
    elroy = 1;
} else {
    /// NORMAL: Not in Elroy mode
    /// Ghost moves at standard speed
    elroy = 0;
}

// ===== VISIBILITY FLASHING (FRIGHTENED MODE) =====
/// Manage ghost visibility during power pellet mode
/// Flashing effect (white flashing) is handled in Step_0 event
/// This just ensures visibility state is correct
///
/// Visibility logic:
/// - Frightened mode with <121 frames left: Flash on/off (warning effect)
/// - Normal modes or plenty of time left: Always visible

if (state == GHOST_STATE.FRIGHTENED) {
    /// Power pellet active: ghost is vulnerable
    if (oPacman.alarm[0] < 121) {
        /// Near end of power pellet: apply flashing effect (handled in Step_0)
        /// Keep visible (Step_0 controls the actual flashing)
        visible = true;
    }
} else {
    /// Normal states (Chase, Eyes, In_House): always visible
    visible = true;
}

/// ===============================================================================
/// END oGHOST STEP_2 EVENT
/// ===============================================================================