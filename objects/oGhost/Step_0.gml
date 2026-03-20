/// ===============================================================================
/// oGHOST - BASE GHOST OBJECT - STEP EVENT (TARGET CALCULATION)
/// ===============================================================================
/// Purpose: Determine target position for ghost behavior based on current state
/// Called: Every frame (SECOND step event, after Step_0 animation)
/// Parent: oGhost (base ghost object)
/// Children: Blinky, Pinky, Inky, Clyde (each overrides this with unique behavior)
///
/// CRITICAL: This event is called EVERY FRAME and sets the (pursuex, pursuey) target
/// The pathfinding scripts in Step_2 use this target to determine direction
///
/// State-based target logic:
/// - CHASE: Calculate target based on ghost personality
///   (Overridden by each ghost with unique algorithm)
/// - FRIGHTENED: Random movement (same for all ghosts)
/// - EYES: Chase house entrance (same for all ghosts)
/// - IN_HOUSE: No target needed (Step_2 handles movement)
/// - HOUSE_READY: No target needed (waiting for release)
///
/// Architecture:
/// This base event provides FRIGHTENED and EYES logic
/// Each child ghost overrides CHASE logic with their personality:
/// - Blinky: Direct chase to Pac's current position
/// - Pinky: Predictive (target 4 tiles ahead)
/// - Inky: Geometric (double vector from Blinky)
/// - Clyde: Ambush (distance-based switching)
/// ===============================================================================

// ===== CHASE MODE TARGET CALCULATION (OVERRIDDEN BY CHILD GHOSTS) =====
/// Base implementation (commented out - child ghosts override)
/// Each ghost has unique chase behavior, so child objects override this entire event
///
/// This shows the DEFAULT BEHAVIOR (Blinky's direct chase):
///
/// if state == GHOST_STATE.CHASE {
///     /// Direct pursuit: chase Pac's current grid position
///     /// Child ghosts override with their unique targeting strategies
///
///     // Snap Pac's position to 16-pixel grid
///     pursuex = 16 * round(oPacman.x / 16);
///     pursuey = 16 * round(oPacman.y / 16);
///
///     /// Scatter mode handling:
///     /// When Pac is in certain "scatter zones", ghosts ignore Pac and chase corners
///     /// This behavior varies by ghost, handled in pathfinding step
/// }

// ===== FRIGHTENED MODE TARGET CALCULATION =====
/// When power pellet is active, ghost moves randomly
/// Random direction script handles the targeting (same for all ghosts)

if (state == GHOST_STATE.FRIGHTENED) {
    /// FRIGHTENED: Power pellet active, ghost is vulnerable
    /// Movement becomes erratic/random instead of intelligent

    /// Execute random direction script
    /// This script picks a random valid direction at each intersection
    /// The script modifies the 'dir' variable to point in new direction
    /// No pursuex/pursuey needed (pathfinding uses randomness, not target)
    script_execute(GHOST_FRIGHTENED);
    /// See scripts/random_direction/random_direction.gml for implementation details
}

// ===== EYES MODE TARGET CALCULATION =====
/// Ghost was eaten by Pac, now only eyes remain
/// Eyes have one mission: return to ghost house entrance to resurrect

//else if (state == GHOST_STATE.EYES) {
//    /// EYES MODE: Ghost eaten, eyes pursuing resurrection
//    /// Always target the ghost house entrance (fixed location)
//    /// Eyes move directly toward this point at high speed

//    /// Ghost house location (standard Pacman maze):
//    /// - X = 216 (centered horizontally in house)
//    /// - Y = 240 (entrance point, just below house boundary)
//    /// This position is same for all ghosts (universal house entrance)

//    pursuex = GHOST_HOUSE_ENTRANCE_X;
//    pursuey = GHOST_HOUSE_ENTRANCE_Y_EYES;
//}

/// ===============================================================================
/// END oGHOST STEP_1 EVENT
/// ===============================================================================
