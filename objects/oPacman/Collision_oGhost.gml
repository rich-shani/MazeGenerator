if (other.state == GHOST_STATE.FRIGHTENED) {
	other.state = GHOST_STATE.EYES;
	
	/// Reset pathfinding
    newtile = 0;
}
else if (other.state == GHOST_STATE.CHASE) {
	// pacman loses a life
}