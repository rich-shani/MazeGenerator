/// ===============================================================================
/// GHOST_SPEED - Speed selection by state and location (tunnel, Elroy)
/// ===============================================================================
/// Called from oGhost Step_2. Runs in calling instance context; sets speed.
/// ===============================================================================

/// @description Set ghost speed for current frame (tunnel vs chase vs frightened vs eyes, Elroy).
/// Call from ghost Step_2 when Pac is alive. Uses calling instance's variables.
function ghost_speed_step() {
    if (oPacman.dead != 0 || oPacman.finish != 0) return;

    if (house != 0) return;

    var _in_slow_area = collision_point(tilex, tiley, Slow, false, true);

    if (state == GHOST_STATE.CHASE) {
        if (_in_slow_area) {
            speed = spslow;
        } else {
            if (elroy == 2) {
                speed = spelroy2;
            } else if (elroy == 1) {
                speed = spelroy;
            } else {
                speed = sp;
            }
        }
    } else if (state == GHOST_STATE.FRIGHTENED) {
        if (_in_slow_area) {
            speed = spslow;
        } else {
            speed = spfright;
        }
    } else if (state == GHOST_STATE.EYES) {
        speed = speyes;
    }
}
