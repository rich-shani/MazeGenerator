/// ===============================================================================
/// PACMAN_CORNER - Corner Completion Logic (aligned with original Pac-Man arcade)
/// ===============================================================================
/// Per Pac-Man Dossier: Pre-turn = diagonal 1px new per 1px old (45°). Completion
/// when Pac "reaches the centerline of the new direction's path" -> pure cardinal.
/// Snaps to (tilex, tiley) - the intersection at turn entry. CORNER_SNAP_TOLERANCE=0
/// completes at arrival (no overshoot), matching original centerline behavior.

/// @function pacman_complete_corners()
/// @description Complete corner transitions when grid alignment is reached
/// @return {bool} True if corner was completed this frame
function pacman_complete_corners() {
    var _spd = pacman_get_speed();
    var _tol = CORNER_SNAP_TOLERANCE;

    // UP_TO_RIGHT transitions (reach horizontal centerline, advance on X)
    if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
        if (y <= tiley && x >= tilex + _tol) {
            x = tilex;
            y = tiley;
            hspeed = _spd;
            vspeed = 0;
            direction = 0; // RIGHT
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
            direction = 0; // RIGHT
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // RIGHT_TO_UP transitions (reach vertical centerline, advance on Y)
    if (corner == PAC_CORNER.RIGHT_TO_UP_PRE) {
        if (x >= tilex && y <= tiley - _tol) {
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = -_spd;
            direction = 90; // UP
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
            direction = 90; // UP
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // DOWN_TO_LEFT transitions (reach horizontal centerline, advance on X)
    if (corner == PAC_CORNER.DOWN_TO_LEFT_PRE) {
        if (y >= tiley && x <= tilex - _tol) {
            x = tilex;
            y = tiley;
            hspeed = -_spd;
            vspeed = 0;
            direction = 180; // LEFT
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
            direction = 180; // LEFT
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // LEFT_TO_DOWN transitions (reach vertical centerline, advance on Y)
    if (corner == PAC_CORNER.LEFT_TO_DOWN_PRE) {
        if (x <= tilex && y >= tiley + _tol) {
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = _spd;
            direction = 270; // DOWN
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
            direction = 270; // DOWN
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // DOWN_TO_RIGHT transitions (reach horizontal centerline, advance on X)
    if (corner == PAC_CORNER.DOWN_TO_RIGHT_PRE) {
        if (y >= tiley && x >= tilex + _tol) {
            x = tilex;
            y = tiley;
            hspeed = _spd;
            vspeed = 0;
            direction = 0; // RIGHT
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
            direction = 0; // RIGHT
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // RIGHT_TO_DOWN transitions (reach vertical centerline, advance on Y)
    if (corner == PAC_CORNER.RIGHT_TO_DOWN_PRE) {
        if (x >= tilex && y >= tiley + _tol) {
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = _spd;
            direction = 270; // DOWN
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
            direction = 270; // DOWN
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // UP_TO_LEFT transitions (reach horizontal centerline, advance on X)
    if (corner == PAC_CORNER.UP_TO_LEFT_PRE) {
        if (y <= tiley && x <= tilex - _tol) {
            x = tilex;
            y = tiley;
            hspeed = -_spd;
            vspeed = 0;
            direction = 180; // LEFT
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
            direction = 180; // LEFT
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // LEFT_TO_UP transitions (reach vertical centerline, advance on Y)
    if (corner == PAC_CORNER.LEFT_TO_UP_PRE) {
        if (x <= tilex && y <= tiley - _tol) {
            x = tilex;
            y = tiley;
            hspeed = 0;
            vspeed = -_spd;
            direction = 90; // UP
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
            direction = 90; // UP
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    return false;  // No corner completed this frame
}
