/// ===============================================================================
/// oPacman STEP_1 - INPUT HANDLING & POSITION TRACKING
/// ===============================================================================
/// Purpose: Process keyboard input and update grid-aligned position
/// Called: Second each frame
/// ===============================================================================

// Validate current movement - stop if wall ahead
pacman_utils_validate_current_movement();

// Update tile-aligned position for collision detection
pacman_update_tile_position();

// Process keyboard input only when alive and not paused
if (dead == PAC_STATE.ALIVE && stoppy == 0 && pause == 0) {
    pacman_handle_input();
}

// Sync direction variable with velocity
pacman_update_direction_sync();
