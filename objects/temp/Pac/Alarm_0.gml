/// ===============================================================================
/// ALARM_0 - FRIGHT MODE TIMER EXPIRATION
/// ===============================================================================
/// Purpose: End fright mode and reset ghost states to chase
/// Called: When fright timer (alarm[0]) reaches 0
///
/// Triggers:
/// - Fright mode automatically expires after duration
/// - All ghosts return to chase mode (not scatter, not frightened)
/// - Ghost speed returned to normal
/// - Chomp counter reset for next fright period
/// ===============================================================================

/// End fright mode
fright = PAC_FRIGHT.OFF;
Pac.prohibit = GHOST_PROHIBIT.ALLOWED;

/// Reset Player 1 speed to normal
if (bonked == 0) {
    if (hspeed > 0) {
        hspeed = sp;
    }
    if (hspeed < 0) {
        hspeed = -sp;
    }
    if (vspeed > 0) {
        vspeed = sp;
    }
    if (vspeed < 0) {
        vspeed = -sp;
    }
}

Pac.chompcount = 0;
Pac.pluseat  = 0;

/// All ghosts return to chase mode
with (Blinky) {
    if (state == GHOST_STATE.FRIGHTENED) {
        state = GHOST_STATE.CHASE;
    }
}

with (Pinky) {
    if (state == GHOST_STATE.FRIGHTENED) {
        state = GHOST_STATE.CHASE;
    }
}

with (Inky) {
    if (state == GHOST_STATE.FRIGHTENED) {
        state = GHOST_STATE.CHASE;
    }
}

with (Clyde) {
    if (state == GHOST_STATE.FRIGHTENED) {
        state = GHOST_STATE.CHASE;
    }
}


