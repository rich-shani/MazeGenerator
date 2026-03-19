instance_destroy(other);

dotcount++;
alarm[0] = 240;

with (oGhost) {
	// edge condition to address .. what if the GHOST is still IN_HOUSE
	// we don't want to just set to CHASE as the Ghost will then just leave and ignore the Wall boundaries
	// need to think about whether we need a in-house attribute, as we want to change to FRIGHTENED
	
	state = GHOST_STATE.FRIGHTENED;
}