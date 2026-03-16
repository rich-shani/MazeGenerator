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

// ================== DEBUG CORNER INSTRUMENTATION (Step_1) ==================
// Capture state before input/direction sync so we can see how input changes things
if (pac_debug_corners) {
    pac_debug_frame += 1;

    var _grid_x = pacman_utils_get_grid_position(x);
    var _grid_y = pacman_utils_get_grid_position(y);

    // If we're in a corner or actively tracking a corner window, keep capturing
    if (corner != PAC_CORNER.NONE || pac_debug_corner_frames > 0) {
        if (pac_debug_corner_frames > 0) {
            pac_debug_corner_frames -= 1;
        }

        // Compact single-line snapshot for console debugging
        show_debug_message(
            "PAC DBG f=" + string(pac_debug_frame)
            + " x=" + string(x) + " y=" + string(y)
            + " gx=" + string(_grid_x) + " gy=" + string(_grid_y)
            + " tx=" + string(tilex) + " ty=" + string(tiley)
            + " hs=" + string(hspeed) + " vs=" + string(vspeed)
            + " dir=" + string(direction) + " d=" + string(dir)
            + " corner=" + string(corner) + " chk=" + string(cornercheck)
        );
    }
}

// Process keyboard input only when alive and not paused
pacman_handle_input();

// Sync direction variable with velocity
pacman_update_direction_sync();
