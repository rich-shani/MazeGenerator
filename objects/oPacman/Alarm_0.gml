with (oGhost) {
 
	if (state == GHOST_STATE.FRIGHTENED) {
		
		state = GHOST_STATE.CHASE;
	}

	// make all Ghosts visible
	// edge condition catch; a Ghost could be hidden in flash 
	visible = true;
}