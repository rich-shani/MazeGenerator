/// ===============================================================================
/// OTHER_0 - TUNNEL WRAPPING (LEFT/RIGHT EDGES)
/// ===============================================================================
/// Purpose: Handle Pac wrapping through horizontal tunnels at room edges
/// Called: Every frame
///
/// Triggers:
/// - When Pac moves left past x = -24, wraps to right side
/// - When Pac moves right past x = room_width + 24, wraps to left side
/// - Resets tile alignment and bonk state after wrapping
/// - Adjusts speed based on fright mode
/// ===============================================================================

/// ===============================================================================
/// LEFT EDGE WRAP: Pac exits left and re-enters from right
/// ===============================================================================
/// Check if moving LEFT (hspeed < 0) and went past left edge
if (hspeed < 0) {
    /// Wrap x position: calculate distance past edge and place on opposite side
    x = (room_width + 24) - (x + 24);

    /// Re-align to 16x16 grid
    tilex = 16 * (round(x / 16));

    /// Clear bonk state so Pac can move immediately
    bonked = 0;

    /// Re-apply speed based on current direction and fright mode
    if (fright == PAC_FRIGHT.ACTIVE) {
        /// FRIGHT MODE: Faster speeds
        if (dir == PAC_DIRECTION.RIGHT) {
            hspeed = spfright;
            vspeed = 0;
        }
        if (dir == PAC_DIRECTION.UP) {
            hspeed = 0;
            vspeed = -spfright;
        }
        if (dir == PAC_DIRECTION.LEFT) {
            hspeed = -spfright;
            vspeed = 0;
        }
        if (dir == PAC_DIRECTION.DOWN) {
            hspeed = 0;
            vspeed = spfright;
        }
    } else {
        /// NORMAL MODE: Standard speeds
        if (dir == PAC_DIRECTION.RIGHT) {
            hspeed = sp;
            vspeed = 0;
        }
        if (dir == PAC_DIRECTION.UP) {
            hspeed = 0;
            vspeed = -sp;
        }
        if (dir == PAC_DIRECTION.LEFT) {
            hspeed = -sp;
            vspeed = 0;
        }
        if (dir == PAC_DIRECTION.DOWN) {
            hspeed = 0;
            vspeed = sp;
        }
    }
}

/// ===============================================================================
/// RIGHT EDGE WRAP: Pac exits right and re-enters from left
/// ===============================================================================
/// Check if moving RIGHT (hspeed > 0) and went past right edge
if (hspeed > 0) {
    /// Wrap x position: calculate distance past edge and place on opposite side
    x = -24 + (x - (room_width + 24));

    /// Re-align to 16x16 grid
    tilex = 16 * (round(x / 16));

    /// Clear bonk state so Pac can move immediately
    bonked = 0;
	
    /// Re-apply speed based on current direction and fright mode
    if (fright == PAC_FRIGHT.ACTIVE) {
        /// FRIGHT MODE: Faster speeds
        if (dir == PAC_DIRECTION.RIGHT) {
            hspeed = spfright;
            vspeed = 0;
        }
        if (dir == PAC_DIRECTION.UP) {
            hspeed = 0;
            vspeed = -spfright;
        }
        if (dir == PAC_DIRECTION.LEFT) {
            hspeed = -spfright;
            vspeed = 0;
        }
        if (dir == PAC_DIRECTION.DOWN) {
            hspeed = 0;
            vspeed = spfright;
        }
    } else {
        /// NORMAL MODE: Standard speeds
        if (dir == PAC_DIRECTION.RIGHT) {
            hspeed = sp;
            vspeed = 0;
        }
        if (dir == PAC_DIRECTION.UP) {
            hspeed = 0;
            vspeed = -sp;
        }
        if (dir == PAC_DIRECTION.LEFT) {
            hspeed = -sp;
            vspeed = 0;
        }
        if (dir == PAC_DIRECTION.DOWN) {
            hspeed = 0;
            vspeed = sp;
        }
    }
}
