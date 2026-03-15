/// ===============================================================================
/// PACMAN_MOVEMENT - Movement Helper Functions
/// ===============================================================================

/// @function pacman_update_tile_position()
/// @description Updates grid-aligned tile coordinates and manages corner tracking
/// NOTE: Tile positions use boundaries (0, 16, 32, ...) with sprite origins at centers (16, 16)
function pacman_update_tile_position() {
    if (corner == PAC_CORNER.NONE) {
        // Not in corner: snap to grid (tile center) normally
        tilex = pacman_utils_get_grid_position(x);
        tiley = pacman_utils_get_grid_position(y);
    }
    else {
        // In corner: track alignment progress
        var _grid_x = pacman_utils_get_grid_position(x);
        var _grid_y = pacman_utils_get_grid_position(y);

        if (tilex != _grid_x) {
            cornercheck = cornercheck + 1;
        }
        if (tiley != _grid_y) {
            cornercheck = cornercheck + 1;
        }
    }
}

/// @function pacman_get_speed()
/// @description Returns appropriate movement speed based on fright mode
/// @return {real} Current speed value (sp or spfright)
function pacman_get_speed() {
    return (fright == PAC_FRIGHT.ACTIVE) ? spfright : sp;
}

/// @function pacman_update_direction_sync()
/// @description Sync GML direction variable with velocity
function pacman_update_direction_sync() {
    if (hspeed > 0 && vspeed == 0) {
        direction = 0;    // Moving right
    }
    else if (hspeed < 0 && vspeed == 0) {
        direction = 180;  // Moving left
    }
    else if (hspeed == 0 && vspeed < 0) {
        direction = 90;   // Moving up
    }
    else if (hspeed == 0 && vspeed > 0) {
        direction = 270;  // Moving down
    }
}
