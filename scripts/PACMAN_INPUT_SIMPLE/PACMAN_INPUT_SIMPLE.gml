/// ===============================================================================
/// PACMAN_INPUT_SIMPLE - Movement Input Handler (Refactored)
/// ===============================================================================
/// Purpose:
/// - Orchestrate input handling using utils and direction handlers
/// - Validate game state before processing input
/// - Delegate direction-specific logic to specialized functions
/// - Maintain clean separation of concerns
/// ===============================================================================

/// @function pacman_handle_input()
/// @description Process keyboard input and manage corner turning
/// Uses utility functions for validation and direction handlers for logic
function pacman_handle_input() {
    // ===== VALIDATION CHECKS =====

    // Skip if Pac is not in a valid state for movement
    if (!pacman_utils_is_in_valid_state()) {
        return;
    }

    // Skip if already in corner transition (not at intersection)
    if (!pacman_utils_is_at_intersection()) {
        return;
    }

    // ===== GET CURRENT STATE =====
    var _spd = pacman_get_speed();

    // ===== PROCESS ALL DIRECTIONS =====
    // Delegate to specialized direction handlers
    // Each handler:
    //  1. Checks appropriate boundary conditions
    //  2. Validates keyboard input (single direction key only)
    //  3. Checks wall collision at next position
    //  4. Initiates movement or buffers input
    pacman_handle_all_directions(_spd);
}
