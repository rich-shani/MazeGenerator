/// ===============================================================================
/// GHOST_HOUSE - Ghost house state machine (bounce and exit)
/// ===============================================================================
/// Called from oGhost Step_2. Runs in calling instance context; updates house,
/// housestate, x, y, hspeed, vspeed, dir, state, newtile, tilex, tiley as needed.
/// ===============================================================================

function ghost_house_idle() {
	//  move up and down waiting ...
	if (dir == GRID_DIRECTION.UP) {
		if (y > (ystart - 8)) move_towards_point(x, ystart - 12, spslow);
		else dir = GRID_DIRECTION.DOWN;
	}
	else {
		if (y < (ystart + 8)) move_towards_point(x, ystart + 12, spslow);
		else dir = GRID_DIRECTION.UP;
	}	
}

/// @description Run one frame of ghost house logic.
/// Handles two major flows for the calling ghost instance:
/// 1) HOUSE_READY / IN_HOUSE release logic (dot-gated exit from ghost house)
/// 2) EYES return flow (eyes returning to house and resurrecting)
/// Call from ghost Step_2 when Pac is alive. Uses calling instance's variables.
function ghost_house_step() {
    if (oPacman.dead != 0 || oPacman.finish != 0) return;

    // -------------------------------------------------------------------------
    // HOUSE_READY → IN_HOUSE/CHASE: dot-gated release for Pinky / Inky / Clyde
    // -------------------------------------------------------------------------
    /// When a ghost starts in HOUSE_READY, it waits inside the house until
    /// Pac has eaten enough dots (per-ghost threshold on oPacman).
    /// Once the threshold is reached, we transition into an in-house state
    /// (house = 1) and let a small house-specific state machine move the
    /// ghost up to and through the ghost-door barrier before marking
    /// house = 0 (free in maze). This mirrors the legacy temp ghost logic.
    if (state == GHOST_STATE.IN_HOUSE) {
        // Keep the ghost roughly at its spawn location while waiting.
        // We do not move it horizontally/vertically here; movement begins
        // once the release condition is met and housestate is set.

        var _name = ghost_name;

        // Pinky release: uses oPacman.psig threshold.
        if (_name == "Pinky") {
            if (oPacman.dotcount >= oPacman.psig) {
                state      = GHOST_STATE.LEAVING_HOUSE;

                hspeed     = 0;
                vspeed     = -spslow;
                dir        = GRID_DIRECTION.UP;
            }
			else ghost_house_idle();
        }
        // Inky release: uses oPacman.isig threshold.
        else if (_name == "Inky") {
            if (oPacman.dotcount >= oPacman.isig) {
                state      = GHOST_STATE.LEAVING_HOUSE;
               
                hspeed     = spslow;
                vspeed     = 0;
                dir        = GRID_DIRECTION.RIGHT;
            }
			else ghost_house_idle();
        }
        // Clyde release: uses oPacman.csig threshold.
        else if (_name == "Clyde") {
            if (oPacman.dotcount >= oPacman.csig) {
                state      = GHOST_STATE.LEAVING_HOUSE;
				
				hspeed     = -spslow;
                vspeed     = 0;
                dir        = GRID_DIRECTION.LEFT;
            }
			else ghost_house_idle();
        }
    }

    //if (house == 1) {
    //    tilex = (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_ENTRANCE_X;
    //    tiley = (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y;
    //}

    // -------------------------------------------------------------------------
    // EYES → IN_HOUSE: eyes arrive at house entrance and drop into center
    // -------------------------------------------------------------------------
    //if (house == 0 && state == GHOST_STATE.EYES &&
    //    x > (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_EYES_X_MIN && x < (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_EYES_X_MAX &&
    //    y == (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y) {
    //    housestate = 0;
    //    x = (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X;
    //    y = (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y;
    //    hspeed = 0;
    //    vspeed = speyes;
    //    house = 1;
    //    dir = GRID_DIRECTION.DOWN;
    //}

    // -------------------------------------------------------------------------
    // IN_HOUSE bounce + exit logic (shared skeleton + per-ghost flavor)
    // -------------------------------------------------------------------------
    //if (house == 1 && state == GHOST_STATE.EYES &&
    //    x == (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X && y > (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_BOTTOM_OFFSET) {
    //    // Eyes have reached the bottom of the house: resurrect into CHASE
    //    housestate = 1;
    //    x = (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X;
    //    y = (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_BOTTOM_OFFSET;
    //    hspeed = 0;
    //    vspeed = -spslow;
    //    state = GHOST_STATE.CHASE;
    //    dir = GRID_DIRECTION.UP;
    //}

	// GHost has triggered to LEAVE the HOUSE ...
    if (state == GHOST_STATE.LEAVING_HOUSE) {

		// check if we've left the house ...
		if (y < GHOST_HOUSE_ENTRANCE_Y-16) {
			// change state to CHASE
			state = GHOST_STATE.CHASE;
			house = 0;
			hspeed     = -sp;
			vspeed     = 0;
			dir        = GRID_DIRECTION.LEFT;
			newtile = 0;
		}
		else if (abs(x - (GHOST_HOUSE_ENTRANCE_X-8)) > 2) move_towards_point(GHOST_HOUSE_ENTRANCE_X-8, y, spslow);
		else {
			move_towards_point(x, GHOST_HOUSE_ENTRANCE_Y-32, spslow);
		}
    }

    // When leaving the house (any ghost) once above the entrance line, snap to
    // the doorway, clear house flag, and hand control back to normal movement.
    //if (house == 1 && state < GHOST_STATE.EYES &&
    //    x == (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X && y < (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y) {
    //    housestate = 0;
    //    x = (xstart - GHOST_HOUSE_CENTER_X) + GHOST_HOUSE_CENTER_X;
    //    y = (ystart - GHOST_HOUSE_ENTRANCE_Y) + GHOST_HOUSE_ENTRANCE_Y;
    //    hspeed = sp;
    //    vspeed = 0;
    //    house = 0;
    //    newtile = 0;
    //    dir = GRID_DIRECTION.LEFT;
    //}
}
