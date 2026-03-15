/// ===============================================================================
/// COLLISION_WALL - PAC-MAN WALL COLLISION HANDLER
/// ===============================================================================
/// Purpose: Handle Pac's collision with walls during normal gameplay
/// Called: When Pac collides with a Wall object
///
/// Triggers:
/// - Stop Pac movement and snap to grid (16x16)
/// - Restore intended direction if queued (via park variable)
/// - Clear bonk (collision) state for next frame
/// ===============================================================================

/// Only process collision during active gameplay
if (global.lvl > 0) {
    /// If not in corner transition, stop movement and snap to grid
    if (corner == 0) {
        /// Stop Pac's movement
        hspeed = 0;
        vspeed = 0;

        /// Snap to 16x16 grid alignment for pixel-perfect positioning
        x = 16 * (round(x / 16));
        y = 16 * (round(y / 16));
    }

    /// If player has queued a direction change (park != -1), apply it now
    if (park > -1) {
        dir = park;
    }

    /// Clear bonk state so Pac can move again on next frame
    bonked = 0;
}


