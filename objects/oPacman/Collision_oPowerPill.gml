instance_destroy(other);

dotcount++;
alarm[0] = 240;

with (oGhost) {
	// Only Ghosts that are active in the Maze are changed to FRIGHTENED
	if (state == GHOST_STATE.CHASE) {
		/// Reverse direction
		dir_applied = direction_opposite(dir_applied);
		dir = dir_applied;

		/// Immediately apply the reversed direction to GML physics so the ghost
		/// stops moving toward the edge. Without this, hspeed/vspeed keep the
		/// ghost moving in the original direction until the grid-turn fires at the
		/// next tile midpoint — which may never happen if the ghost is near a tunnel.
		switch (dir_applied) {
		    case GRID_DIRECTION.RIGHT: direction = 0;   break;
		    case GRID_DIRECTION.UP:    direction = 90;  break;
		    case GRID_DIRECTION.LEFT:  direction = 180; break;
		    case GRID_DIRECTION.DOWN:  direction = 270; break;
		}

	    /// Also reset newtile to force immediate pathfinding update
	    /// This allows ghosts to pick new target right away
	    newtile = 0;

		state = GHOST_STATE.FRIGHTENED;
	}
}