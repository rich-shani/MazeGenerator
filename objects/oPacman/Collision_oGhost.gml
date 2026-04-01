if (other.state == GHOST_STATE.FRIGHTENED) {
	other.state = GHOST_STATE.EYES;
	
	// ensure the EYES are visible
	// as Ghost may have been hidden during flash
	visible = true;
	
	/// Reset pathfinding
    newtile = 0;
}
else if (other.state == GHOST_STATE.CHASE) {
	// pacman loses a life
}