/// ===============================================================================
/// PACMAN_CORNER - Corner Completion Logic
/// ===============================================================================
/// NOTE: Tile positions use boundaries (0, 16, 32, ...) with sprite origins at centers

/// @function pacman_complete_corners()
/// @description Complete corner transitions when grid alignment is reached
/// @return {bool} True if corner was completed this frame
function pacman_complete_corners() {
    var _spd = pacman_get_speed();

    // UP_TO_RIGHT transitions
    if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
        var _grid_y = pacman_utils_get_grid_position(y);
        if (y <= _grid_y) {
            y = _grid_y;
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.UP_TO_RIGHT_POST) {
        var _grid_y = pacman_utils_get_grid_position(y);
        if (y >= _grid_y) {
            y = _grid_y;
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // RIGHT_TO_UP transitions
    if (corner == PAC_CORNER.RIGHT_TO_UP_PRE) {
        var _grid_x = pacman_utils_get_grid_position(x);
        if (x >= _grid_x) {
            x = _grid_x;
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.RIGHT_TO_UP_POST) {
        var _grid_x = pacman_utils_get_grid_position(x);
        if (x <= _grid_x) {
            x = _grid_x;
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // DOWN_TO_LEFT transitions
    if (corner == PAC_CORNER.DOWN_TO_LEFT_PRE) {
        var _grid_y = pacman_utils_get_grid_position(y);
        if (y >= _grid_y) {
            y = _grid_y;
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.DOWN_TO_LEFT_POST) {
        var _grid_y = pacman_utils_get_grid_position(y);
        if (y <= _grid_y) {
            y = _grid_y;
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // LEFT_TO_DOWN transitions
    if (corner == PAC_CORNER.LEFT_TO_DOWN_PRE) {
        var _grid_x = pacman_utils_get_grid_position(x);
        if (x <= _grid_x) {
            x = _grid_x;
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.LEFT_TO_DOWN_POST) {
        var _grid_x = pacman_utils_get_grid_position(x);
        if (x >= _grid_x) {
            x = _grid_x;
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // DOWN_TO_RIGHT transitions
    if (corner == PAC_CORNER.DOWN_TO_RIGHT_PRE) {
        var _grid_y = pacman_utils_get_grid_position(y);
        if (y >= _grid_y) {
            y = _grid_y;
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.DOWN_TO_RIGHT_POST) {
        var _grid_y = pacman_utils_get_grid_position(y);
        if (y <= _grid_y) {
            y = _grid_y;
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // RIGHT_TO_DOWN transitions
    if (corner == PAC_CORNER.RIGHT_TO_DOWN_PRE) {
        var _grid_x = pacman_utils_get_grid_position(x);
        if (x >= _grid_x) {
            x = _grid_x;
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.RIGHT_TO_DOWN_POST) {
        var _grid_x = pacman_utils_get_grid_position(x);
        if (x <= _grid_x) {
            x = _grid_x;
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // UP_TO_LEFT transitions
    if (corner == PAC_CORNER.UP_TO_LEFT_PRE) {
        var _grid_y = pacman_utils_get_grid_position(y);
        if (y <= _grid_y) {
            y = _grid_y;
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.UP_TO_LEFT_POST) {
        var _grid_y = pacman_utils_get_grid_position(y);
        if (y >= _grid_y) {
            y = _grid_y;
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // LEFT_TO_UP transitions
    if (corner == PAC_CORNER.LEFT_TO_UP_PRE) {
        var _grid_x = pacman_utils_get_grid_position(x);
        if (x <= _grid_x) {
            x = _grid_x;
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.LEFT_TO_UP_POST) {
        var _grid_x = pacman_utils_get_grid_position(x);
        if (x >= _grid_x) {
            x = _grid_x;
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    return false;  // No corner completed this frame
}
