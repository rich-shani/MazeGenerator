/// ===============================================================================
/// PACMAN_CORNER - Corner Completion Logic
/// ===============================================================================
/// NOTE: Tile positions use boundaries (0, 16, 32, ...) with sprite origins at centers
/// Snaps to (tilex, tiley) - the intersection when we entered the turn.
/// Only completes when Pac has passed the intersection by CORNER_SNAP_TOLERANCE
/// in both axes, so the diagonal corner cut feels fluid and consistent.

/// @function pacman_complete_corners()
/// @description Complete corner transitions when grid alignment is reached
/// @return {bool} True if corner was completed this frame
function pacman_complete_corners() {
    var _spd = pacman_get_speed();
    var _tol = CORNER_SNAP_TOLERANCE;

    // UP_TO_RIGHT transitions (must pass intersection: y past tiley, x past tilex)
    if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
        if (y <= tiley - _tol && x >= tilex + _tol) {
            x = tilex;
            y = tiley;
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.UP_TO_RIGHT_POST) {
        if (y >= tiley && x >= tilex) {  // POST: correcting overshoot, snap when reached
            x = tilex;
            y = tiley;
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // RIGHT_TO_UP transitions
    if (corner == PAC_CORNER.RIGHT_TO_UP_PRE) {
        if (x >= tilex + _tol && y <= tiley - _tol) {
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.RIGHT_TO_UP_POST) {
        if (x <= tilex && y <= tiley) {  // POST: correcting overshoot
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // DOWN_TO_LEFT transitions
    if (corner == PAC_CORNER.DOWN_TO_LEFT_PRE) {
        if (y >= tiley + _tol && x <= tilex - _tol) {
            x = tilex;
            y = tiley;
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.DOWN_TO_LEFT_POST) {
        if (y <= tiley && x <= tilex) {  // POST: correcting overshoot
            x = tilex;
            y = tiley;
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // LEFT_TO_DOWN transitions
    if (corner == PAC_CORNER.LEFT_TO_DOWN_PRE) {
        if (x <= tilex - _tol && y >= tiley + _tol) {
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.LEFT_TO_DOWN_POST) {
        if (x >= tilex && y >= tiley) {  // POST: correcting overshoot
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // DOWN_TO_RIGHT transitions
    if (corner == PAC_CORNER.DOWN_TO_RIGHT_PRE) {
        if (y >= tiley + _tol && x >= tilex + _tol) {
            x = tilex;
            y = tiley;
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.DOWN_TO_RIGHT_POST) {
        if (y <= tiley && x >= tilex) {  // POST: correcting overshoot
            x = tilex;
            y = tiley;
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // RIGHT_TO_DOWN transitions
    if (corner == PAC_CORNER.RIGHT_TO_DOWN_PRE) {
        if (x >= tilex + _tol && y >= tiley + _tol) {
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.RIGHT_TO_DOWN_POST) {
        if (x <= tilex && y >= tiley) {  // POST: correcting overshoot
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // UP_TO_LEFT transitions
    if (corner == PAC_CORNER.UP_TO_LEFT_PRE) {
        if (y <= tiley - _tol && x <= tilex - _tol) {
            x = tilex;
            y = tiley;
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.UP_TO_LEFT_POST) {
        if (y >= tiley && x <= tilex) {  // POST: correcting overshoot
            x = tilex;
            y = tiley;
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // LEFT_TO_UP transitions
    if (corner == PAC_CORNER.LEFT_TO_UP_PRE) {
        if (x <= tilex - _tol && y <= tiley - _tol) {
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.LEFT_TO_UP_POST) {
        if (x >= tilex && y <= tiley) {  // POST: correcting overshoot
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    return false;  // No corner completed this frame
}
