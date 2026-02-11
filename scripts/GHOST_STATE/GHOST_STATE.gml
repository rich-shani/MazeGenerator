/// ===============================================================================
/// GHOST_STATE ENUM
/// ===============================================================================
/// Purpose: Define all possible states for ghost behavior
/// Usage: Use instead of numeric values for clearer, self-documenting code
///
/// Example:
///   if state == GHOST_STATE.CHASE { ... }  // Clear and understandable
///   if state == 0 { ... }                   // What does 0 mean? Not clear
///
/// Benefits:
/// - Self-documenting code
/// - Reduces bugs from using wrong numeric value
/// - Easy to refactor (rename state values in one place)
/// - IDE autocomplete support
/// ===============================================================================

enum GHOST_STATE {
    /// CHASE = 0
    /// Description: Normal pursuit mode
    /// Behavior: Ghost chases Pac aggressively (chase) or moves to scatter corner
    /// Animation: Normal sprite animation
    /// Speed: Normal speed (varies by mode/level)
    /// Transitions to: FRIGHTENED (when Pac eats power pellet), EYES (when eaten)
    CHASE = 0,

    /// FRIGHTENED = 1
    /// Description: Power pellet active - ghost is vulnerable
    /// Behavior: Ghost moves randomly, away from Pac
    /// Animation: Blue sprite with flashing effect near end
    /// Speed: Reduced speed (1.25 tiles/frame)
    /// Transitions to: CHASE (when power pellet expires), EYES (when eaten)
    FRIGHTENED = 1,

    /// EYES = 2
    /// Description: Ghost has been eaten - only eyes remain
    /// Behavior: Eyes move directly to ghost house entrance
    /// Animation: Shows only eye sprites, no body
    /// Speed: Very fast (4.0 tiles/frame)
    /// Transitions to: IN_HOUSE (when reaching house entrance)
    EYES = 2,

    /// IN_HOUSE = 3
    /// Description: Ghost is exiting the ghost house
    /// Behavior: Complex bouncing/movement pattern to get out of house
    /// Animation: Normal sprite animation
    /// Speed: Varies based on house logic
    /// Transitions to: CHASE (once fully exited)
    /// Note: House exit logic varies by ghost (Blinky bounces up/down,
    ///       Pinky/Inky/Clyde have more complex patterns)
    IN_HOUSE = 3,

    /// HOUSE_READY = 4
    /// Description: Ghost waiting in house for release condition
    /// Behavior: Waiting for dot count or other trigger to leave
    /// Animation: Normal sprite animation
    /// Speed: 0 (not moving, just waiting)
    /// Transitions to: IN_HOUSE (when release condition met)
    /// Note: Currently not used in codebase, reserved for future use
    HOUSE_READY = 4
}

/// ===============================================================================
/// STATE TRANSITION DIAGRAM
/// ===============================================================================
///
///    CHASE <-----------> FRIGHTENED
///     ^  ^                    |
///     |  |                    |
///     |  +-------- EYES <-----+
///     |                |
///     |                v
///     |            IN_HOUSE
///     |                |
///     +----------------+
///
/// Notes:
/// - Most transitions are in oGhost/Step_2.gml (movement logic)
/// - Power pellet handling triggers CHASE -> FRIGHTENED in parent Pac object
/// - Ghost consumption triggers CHASE/FRIGHTENED -> EYES
/// - EYES -> IN_HOUSE happens at house entrance
/// - IN_HOUSE -> CHASE happens after bouncing out
///
/// ===============================================================================

// ===============================================================================
// HELPER FUNCTION: Get state name for debugging
// ===============================================================================

/// @function ghost_state_name(_state)
/// @description Get the string name of a ghost state (useful for debugging)
/// @param {real} _state - The state value (GHOST_STATE enum value)
/// @return {string} - The name of the state ("CHASE", "FRIGHTENED", etc.)
/// @example
///   show_debug_message("Current state: " + ghost_state_name(state));

function ghost_state_name(_state) {
    switch (_state) {
        case GHOST_STATE.CHASE:
            return "CHASE";
        case GHOST_STATE.FRIGHTENED:
            return "FRIGHTENED";
        case GHOST_STATE.EYES:
            return "EYES";
        case GHOST_STATE.IN_HOUSE:
            return "IN_HOUSE";
        case GHOST_STATE.HOUSE_READY:
            return "HOUSE_READY";
        default:
            return "UNKNOWN";
    }
}

/// ===============================================================================
// END GHOST_STATE ENUM
/// ===============================================================================
