/// ===============================================================================
/// PAC STEP_2 - CORNER COMPLETION, MOVEMENT UPDATES, & MISC LOGIC (REFACTORED)
/// ===============================================================================
/// Purpose: Complete corner transitions, handle pause states, manage depth/direction
/// Called: THIRD each frame (after Step_0 and Step_1)
///
/// Responsibilities:
/// 1. Execute support scripts (endstep)
/// 2. Complete corner transitions (8 different corner types)
/// 3. Apply appropriate speed to exiting corners (normal vs fright)
/// 4. Handle pause/suspension states and eating direction
/// 5. Manage level-specific rules (speed, turning, grid snapping)
/// 6. Control instance visibility and deactivation for performance
/// 7. Update game state based on level completion
/// 8. Manage audio playback for ambience
/// 9. Handle Pac.plus mode visibility toggling
/// 10. Manage viewport/camera positioning for 2-player modes
/// 11. Update depth and direction target helpers
/// 12. Handle ghost release timing and cycle progression
/// ===============================================================================

script_execute(endstep);

// ===== CORNER COMPLETION LOGIC =====
/// When in a corner transition, snap to grid and apply appropriate speed
var _spd = sp;

if (fright == PAC_FRIGHT.ACTIVE) {
	// override speed if we're in FRIGHT active mode
    _spd = spfright;
}

if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
    if (y < 16 * (round(y / 16))) {
        y = 16 * (round(y / 16));
        hspeed = _spd;
        vspeed = 0;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.UP_TO_RIGHT_POST) {
    if (y > 16 * (round(y / 16))) {
        y = 16 * (round(y / 16));
        hspeed = _spd;
        vspeed = 0;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.RIGHT_TO_UP_PRE) {
    if (x > 16 * (round(x / 16))) {
        x = 16 * (round(x / 16));
        hspeed = 0;
        vspeed = -_spd;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.RIGHT_TO_UP_POST) {
    if (x < 16 * (round(x / 16))) {
        x = 16 * (round(x / 16));
        hspeed = 0;
        vspeed = -_spd;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.DOWN_TO_LEFT_PRE) {
    if (y > 16 * (round(y / 16))) {
        y = 16 * (round(y / 16));
        hspeed = -_spd;
        vspeed = 0;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.DOWN_TO_LEFT_POST) {
    if (y < 16 * (round(y / 16))) {
        y = 16 * (round(y / 16));
        hspeed = -_spd;
        vspeed = 0;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.LEFT_TO_DOWN_PRE) {
    if (x < 16 * (round(x / 16))) {
        x = 16 * (round(x / 16));
        hspeed = 0;
        vspeed = _spd;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.LEFT_TO_DOWN_POST) {
    if (x > 16 * (round(x / 16))) {
        x = 16 * (round(x / 16));
        hspeed = 0;
        vspeed = _spd;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.DOWN_TO_RIGHT_PRE) {
    if (y > 16 * (round(y / 16))) {
        y = 16 * (round(y / 16));
        hspeed = _spd;
        vspeed = 0;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.DOWN_TO_RIGHT_POST) {
    if (y < 16 * (round(y / 16))) {
        y = 16 * (round(y / 16));
        hspeed = _spd;
        vspeed = 0;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.RIGHT_TO_DOWN_PRE) {
    if (x > 16 * (round(x / 16))) {
        x = 16 * (round(x / 16));
        hspeed = 0;
        vspeed = _spd;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.RIGHT_TO_DOWN_POST) {
    if (x < 16 * (round(x / 16))) {
        x = 16 * (round(x / 16));
        hspeed = 0;
        vspeed = _spd;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.UP_TO_LEFT_PRE) {
    if (y < 16 * (round(y / 16))) {
        y = 16 * (round(y / 16));
        hspeed = -_spd;
        vspeed = 0;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.UP_TO_LEFT_POST) {
    if (y > 16 * (round(y / 16))) {
        y = 16 * (round(y / 16));
        hspeed = -_spd;
        vspeed = 0;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.LEFT_TO_UP_PRE) {
    if (x < 16 * (round(x / 16))) {
        x = 16 * (round(x / 16));
        hspeed = 0;
        vspeed = -_spd;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}
if (corner == PAC_CORNER.LEFT_TO_UP_POST) {
    if (x > 16 * (round(x / 16))) {
        x = 16 * (round(x / 16));
        hspeed = 0;
        vspeed = -_spd;
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        exit;
    }
}

// ===== EATING DIRECTION RECOVERY =====
/// After eating a dot, resume movement in the direction Pac was facing
if (chomp == 0) {
	if (pause == 0) {
        if (eatdir == 0) { hspeed = _spd; vspeed = 0; eatdir = -1; }
        if (eatdir == 1) { hspeed = _spd; vspeed = -_spd; eatdir = -1; }
        if (eatdir == 2) { hspeed = 0; vspeed = -_spd; eatdir = -1; }
        if (eatdir == 3) { hspeed = -_spd; vspeed = -_spd; eatdir = -1; }
        if (eatdir == 4) { hspeed = -_spd; vspeed = 0; eatdir = -1; }
        if (eatdir == 5) { hspeed = -_spd; vspeed = _spd; eatdir = -1; }
        if (eatdir == 6) { hspeed = 0; vspeed = _spd; eatdir = -1; }
        if (eatdir == 7) { hspeed = _spd; vspeed = _spd; eatdir = -1; }
        stoppy = 0;
    }
    else {
        pause = pause - 1;
    }
}

// ===== INSTANCE ACTIVATION (PERFORMANCE OPTIMIZATION) =====
/// Only activate instances near Pac to improve performance
if (Pauser.pause == 0 && Pac.finish < 1) {

    instance_deactivate_all(true);
    instance_activate_region(Pac.tilex - 32, Pac.tiley - 32, 80, 80, true);

    instance_activate_object(Power);
    instance_activate_object(Pauser);
    instance_activate_object(Scroller);
    instance_activate_object(Drawless);

    instance_activate_object(Blinky);
    instance_activate_region(Blinky.tilex - 32, Blinky.tiley - 32, 80, 80, true);

    instance_activate_object(Pinky);
    instance_activate_region(Pinky.tilex - 32, Pinky.tiley - 32, 80, 80, true);

    instance_activate_object(Inky);
    instance_activate_region(Inky.tilex - 32, Inky.tiley - 32, 80, 80, true);

    instance_activate_object(Clyde);
    instance_activate_region(Clyde.tilex - 32, Clyde.tiley - 32, 80, 80, true);

    instance_activate_object(Fruit);
    instance_activate_region(16 * (round(Fruit.x / 16)) - 32, 16 * (round(Fruit.y / 16)) - 32, 80, 80, true);
}
else {
    instance_activate_all();
}

// ===== MENU MOVEMENT LOGIC =====
/// Handle turning and speed in menu/title screen
if (dead == 0) {
    if (global.lvl == 0) {
        if (Pac.chomp == 0) {

            /// Speed management
            if (speed > 0) {
                if (fright == 0) {
                    speed = sp;
                }
                else {
                    speed = spfright;
                }
            }

            /// Menu turning logic
            if (pause == 0 && speed > 0) {
                if (newtile == 1) {

                    if (dir == 0) {
                        if (direction == 0 && x > tilex) { direction = 0; newtile = 0; exit; }
                        if (direction == 90 && y < tiley) { direction = 0; x = tilex + (tiley - y); y = tiley; newtile = 0; exit; }
                        if (direction == 180 && x < tilex) { x = tilex; direction = 0; newtile = 0; exit; }
                        if (direction == 270 && y > tiley) { direction = 0; x = tilex + (y - tiley); y = tiley; newtile = 0; exit; }
                    }

                    if (dir == 1) {
                        if (direction == 0 && x > tilex) { direction = 90; y = tiley - (x - tilex); x = tilex; newtile = 0; exit; }
                        if (direction == 90 && y < tiley) { direction = 90; newtile = 0; exit; }
                        if (direction == 180 && x < tilex) { direction = 90; y = tiley - (tilex - x); x = tilex; newtile = 0; exit; }
                        if (direction == 270 && y > tiley) { y = tiley; direction = 90; newtile = 0; exit; }
                    }

                    if (dir == 2) {
                        if (direction == 0 && x > tilex) { x = tilex; direction = 180; newtile = 0; exit; }
                        if (direction == 90 && y < tiley) { direction = 180; x = tilex - (tiley - y); y = tiley; newtile = 0; exit; }
                        if (direction == 180 && x < tilex) { direction = 180; newtile = 0; exit; }
                        if (direction == 270 && y > tiley) { direction = 180; x = tilex - (y - tiley); y = tiley; newtile = 0; exit; }
                    }

                    if (dir == 3) {
                        if (direction == 0 && x > tilex) { direction = 270; y = tiley + (x - tilex); x = tilex; newtile = 0; exit; }
                        if (direction == 90 && y < tiley) { y = tiley; direction = 270; newtile = 0; exit; }
                        if (direction == 180 && x < tilex) { direction = 270; y = tiley + (tilex - x); x = tilex; newtile = 0; exit; }
                        if (direction == 270 && y > tiley) { direction = 270; newtile = 0; exit; }
                    }

                }
            }

        }
    }
}

// ===== TALL ROOM CAMERA PANNING =====
/// For large rooms, pan camera to game over position
if (dead == 3 && room_width > 448 && ((global.p1lives == 0 && global.p1gameover == 0) || (global.p2lives == 0 && global.p2gameover == 0))) {
    if (room_height == 576) {
        __view_set(e__VW.XView, 0, 2 * round(__view_get(e__VW.XView, 0) / 2));
        x = (__view_get(e__VW.XView, 0) + 224);
        if (__view_get(e__VW.XView, 0) < 208 - (Drawless.c64 * 144)) {
            __view_set(e__VW.XView, 0, __view_get(e__VW.XView, 0) + 2);
        }
        if (__view_get(e__VW.XView, 0) > 208 - (Drawless.c64 * 144)) {
            __view_set(e__VW.XView, 0, __view_get(e__VW.XView, 0) - 2);
        }
    }
}

// ===== LEVEL COMPLETION FREEZE =====
/// When level complete, freeze all movement
if (Pac.finish > 0) {
    hspeed = 0;
    vspeed = 0;
    alarm[0] = alarm[0] + 1;

    with (Blinky) { hspeed = 0; vspeed = 0; }
    with (Pinky) { hspeed = 0; vspeed = 0; }
    with (Inky) { hspeed = 0; vspeed = 0; }
    with (Clyde) { hspeed = 0; vspeed = 0; }
    with (Fruit) { hspeed = 0; vspeed = 0; }
}  


// ===== DEPTH & TARGET HELPERS =====
if (fright == 1) { depth = 99; }
else { depth = 104; }

/// Target display position for debugging
if (dir == 0) { xdir = 32; ydir = 0; }
if (dir == 1) { xdir = -32; ydir = -32; }
if (dir == 2) { xdir = -32; ydir = 0; }
if (dir == 3) { xdir = 0; ydir = 32; }

// ===== GHOST RELEASE TIMING =====
if (dead == 0 && global.start == 0) {
    if (timer > 0) { timer = timer - 1; }

    if (timer == 0) {
        if (Pinky.housestate == 1) {
            with (Pinky) {
                if (y > (ystart - 272) + 270 && y < (ystart - 272) + 274) {
                    y = (ystart - 272) + 272;
                    housestate = 2;
                    Pac.psig = 0;
                    Pac.timer = Pac.timerstart;
                }
            }
        }
        else {
            if (Inky.housestate == 2) {
                with (Inky) {
                    if (y > (ystart - 272) + 270 && y < (ystart - 272) + 274) {
                        y = (ystart - 272) + 272;
                        housestate = 3;
                        Pac.isig = 0;
                        Pac.timer = Pac.timerstart;
                    }
                }
            }
            else {
                if (Clyde.housestate == 2) {
                    with (Clyde) {
                        if (y > (ystart - 272) + 270 && y < (ystart - 272) + 274) {
                            y = (ystart - 272) + 272;
                            housestate = 3;
                            Pac.csig = 0;
                            Pac.timer = Pac.timerstart;
                        }
                    }
                }
            }
        }
    }
}

/// Pause fright cycle timer during fright mode
if (fright == 1) { alarm[1] = alarm[1] + 1; }