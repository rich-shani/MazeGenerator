/// ===============================================================================
/// GHOST_HOUSE - Ghost house state machine (bounce and exit)
/// ===============================================================================
/// Called from oGhost Step_2. Runs in calling instance context; updates house,
/// housestate, x, y, hspeed, vspeed, dir, state, newtile, tilex, tiley as needed.
/// ===============================================================================

/// @description Run one frame of ghost house logic (eyes arrival, bounce down, bounce up, exit).
/// Call from ghost Step_2 when Pac is alive. Uses calling instance's variables.
function ghost_house_step() {
    if (oPacman.dead != 0 || oPacman.finish != 0) return;

    if (house == 1) {
        tilex = (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_ENTRANCE_Y;
        tiley = (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y;
    }

    if (house == 0 && state == GHOST_STATE.EYES &&
        x > (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_EYES_X_MIN && x < (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_EYES_X_MAX &&
        y == (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y) {
        housestate = 0;
        x = (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X;
        y = (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y;
        hspeed = 0;
        vspeed = speyes;
        house = 1;
        dir = GHOST_DIRECTION.DOWN;
    }

    if (house == 1 && state == GHOST_STATE.EYES &&
        x == (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X && y > (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_BOTTOM_OFFSET) {
        housestate = 1;
        x = (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X;
        y = (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_BOTTOM_OFFSET;
        hspeed = 0;
        vspeed = -spslow;
        state = GHOST_STATE.CHASE;
        dir = GHOST_DIRECTION.UP;
    }

    if (housestate == 1) {
        hspeed = 0;
        vspeed = -spslow;
    }

    if (house == 1 && state < GHOST_STATE.EYES &&
        x == (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X && y < (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y) {
        housestate = 0;
        x = (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X;
        y = (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y;
        hspeed = sp;
        vspeed = 0;
        house = 0;
        newtile = 0;
        dir = GHOST_DIRECTION.LEFT;
    }
}
