/// ===============================================================================
/// oPacman STEP_2 - CORNER COMPLETION
/// ===============================================================================
/// Purpose: Complete corner transitions when grid alignment is reached
/// Called: Third each frame
/// ===============================================================================

// Complete any active corner transitions
if (corner != PAC_CORNER.NONE) {
    pacman_complete_corners();
}

// Handle pause state countdown
if (pause > 0) {
    pause = pause - 1;
}

// Restore movement after stoppy state (eating direction recovery)
if (stoppy > 0 && pause == 0 && chomp == 0) {
    var _spd = pacman_get_speed();

    // Restore movement based on eatdir (8-way direction)
    if (eatdir == 0) { hspeed = _spd; vspeed = 0; eatdir = -1; }          // Right
    else if (eatdir == 2) { hspeed = 0; vspeed = -_spd; eatdir = -1; }    // Up
    else if (eatdir == 4) { hspeed = -_spd; vspeed = 0; eatdir = -1; }    // Left
    else if (eatdir == 6) { hspeed = 0; vspeed = _spd; eatdir = -1; }     // Down

    stoppy = 0;
}
