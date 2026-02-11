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
///     pursuex = 16 * round(Pac.x / 16);
///     pursuey = 16 * round(Pac.y / 16);
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
    script_execute(random_direction);
    /// See scripts/random_direction/random_direction.gml for implementation details
}

// ===== EYES MODE TARGET CALCULATION =====
/// Ghost was eaten by Pac, now only eyes remain
/// Eyes have one mission: return to ghost house entrance to resurrect

else if (state == GHOST_STATE.EYES) {
    /// EYES MODE: Ghost eaten, eyes pursuing resurrection
    /// Always target the ghost house entrance (fixed location)
    /// Eyes move directly toward this point at high speed

    /// Ghost house location (standard Pacman maze):
    /// - X = 216 (centered horizontally in house)
    /// - Y = 240 (entrance point, just below house boundary)
    /// This position is same for all ghosts (universal house entrance)

    pursuex = 216;  /// House center X coordinate
    pursuey = 240;  /// House entrance Y coordinate
}

// ===== IN_HOUSE MODE - NO TARGET NEEDED =====
/// Ghost is inside ghost house, bouncing/exiting
/// Movement is controlled entirely by house state machine in Step_2
/// No pathfinding target needed

else if (state == GHOST_STATE.IN_HOUSE) {
    /// IN_HOUSE: Ghost inside house, in exit sequence
    /// House state machine (in Step_2) handles all movement directly
    /// Not using pathfinding, so no pursuex/pursuey calculation needed
    ///
    /// House exit sequence:
    /// 1. Eyes enter house
    /// 2. Body reconstitutes
    /// 3. Ghost bounces down
    /// 4. Ghost bounces back up
    /// 5. Ghost exits through top of house
}

// ===== HOUSE_READY MODE - NO TARGET NEEDED =====
/// Ghost waiting in house, waiting for release condition
/// Once release condition met, transitions to IN_HOUSE state

else if (state == GHOST_STATE.HOUSE_READY) {
    /// HOUSE_READY: Ghost waiting in house
    /// Not yet released to roam the maze
    /// Release condition checked elsewhere (when dot count thresholds met)
    /// No movement until state transition occurs
}

/// ===============================================================================
/// HOW CHILD GHOSTS OVERRIDE THIS EVENT WITH UNIQUE TARGETING
/// ===============================================================================
/// Each of the four ghost children (Blinky, Pinky, Inky, Clyde) completely
/// overrides this event with their own Step_1 code implementing unique AI
///
/// They keep the FRIGHTENED, EYES, and house mode logic identical
/// But provide their own CHASE mode targeting algorithm
///
/// ───────────────────────────────────────────────────────────────────────────
/// EXAMPLE 1: PINKY'S OVERRIDE (Ambush Predator)
/// ───────────────────────────────────────────────────────────────────────────
/// Purpose: Pinky tries to AMBUSH Pac by targeting ahead of movement
///
/// if state == GHOST_STATE.CHASE {
///     // Anticipation: Target 4 tiles ahead of Pac in direction he's moving
///     // If Pac moving right, target is 4 tiles to his right
///     // Pac.xdir and Pac.ydir are his unit movement directions
///
///     var _ahead_x = 2 * Pac.xdir;  // 2 tiles ahead (4x multiplier in some versions)
///     var _ahead_y = 2 * Pac.ydir;
///
///     pursuex = 16 * round((Pac.x + _ahead_x * 16) / 16);
///     pursuey = 16 * round((Pac.y + _ahead_y * 16) / 16);
/// }
/// else if state == GHOST_STATE.FRIGHTENED {
///     script_execute(random_direction);  // Same as base
/// }
/// else if state == GHOST_STATE.EYES {
///     pursuex = 216;  // Same as base
///     pursuey = 240;
/// }
///
/// ───────────────────────────────────────────────────────────────────────────
/// EXAMPLE 2: CLYDE'S OVERRIDE (Ambiguous/Shy Behavior)
/// ───────────────────────────────────────────────────────────────────────────
/// Purpose: Clyde changes behavior based on distance to Pac
/// Close = flee, far = chase (ambiguous personality)
///
/// if state == GHOST_STATE.CHASE {
///     // Calculate distance from Clyde to Pac
///     var _distance = point_distance(x, y, Pac.x, Pac.y);
///
///     if (_distance < 128) {
///         // Too close! Pac is threatening, flee to scatter corner
///         // Scatter corner for Clyde is bottom-right of maze
///         pursuex = cornerx;  // Set in Clyde's Create event
///         pursuey = cornery;
///     }
///     else {
///         // Safe distance, pursue normally like Blinky
///         pursuex = 16 * round(Pac.x / 16);
///         pursuey = 16 * round(Pac.y / 16);
///     }
/// }
/// else if state == GHOST_STATE.FRIGHTENED {
///     script_execute(random_direction);  // Same as base
/// }
/// else if state == GHOST_STATE.EYES {
///     pursuex = 216;  // Same as base
///     pursuey = 240;
/// }
///
/// ───────────────────────────────────────────────────────────────────────────
/// EXAMPLE 3: INKY'S OVERRIDE (Geometric Ambush)
/// ───────────────────────────────────────────────────────────────────────────
/// Purpose: Inky uses Blinky's position to calculate a geometric "double vector"
/// Creates triangle geometry: Pac -> Blinky -> Target (extension beyond Blinky)
///
/// if state == GHOST_STATE.CHASE {
///     // Vector from Pac to Blinky
///     var _vec_x = Blinky.x - Pac.x;
///     var _vec_y = Blinky.y - Pac.y;
///
///     // Extend vector from Blinky in same direction
///     var _target_x = Blinky.x + _vec_x;
///     var _target_y = Blinky.y + _vec_y;
///
///     // Snap to grid
///     pursuex = 16 * round(_target_x / 16);
///     pursuey = 16 * round(_target_y / 16);
/// }
/// else if state == GHOST_STATE.FRIGHTENED {
///     script_execute(random_direction);  // Same as base
/// }
/// else if state == GHOST_STATE.EYES {
///     pursuex = 216;  // Same as base
///     pursuey = 240;
/// }
///
/// ===============================================================================

/// ===============================================================================
/// END oGHOST STEP_1 EVENT
/// ===============================================================================
