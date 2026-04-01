if (other.state == GHOST_STATE.FRIGHTENED) {
	other.state = GHOST_STATE.EYES;
	
	/// Reset pathfinding
    other.newtile = 0;
	
	// esnure eyes are visible (as Ghost may not be visible during powerpill)
	other.flash = 0;
	other.visible = true;
}
else if (other.state == GHOST_STATE.CHASE) {
	// pacman loses a life
}