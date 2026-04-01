with (oGhost) {
 
	if (state == GHOST_STATE.FRIGHTENED) {
		
		state = GHOST_STATE.CHASE;
	}

	// make all Ghosts visible
	// a Ghost could be hidden during the flash of the FRIGHTENED state 
	visible = true;
}