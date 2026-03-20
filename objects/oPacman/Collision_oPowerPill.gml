instance_destroy(other);

dotcount++;
alarm[0] = 240;

with (oGhost) {
	// Only Ghosts that are active in the Maze are changed to FRIGHTENED
	if (state == GHOST_STATE.CHASE) {
		/// Reverse direction 
		dir = direction_opposite(dir_applied);

	    /// Also reset newtile to force immediate pathfinding update
	    /// This allows ghosts to pick new target right away
	    newtile = 0;	
		
		state = GHOST_STATE.FRIGHTENED;
	}
}