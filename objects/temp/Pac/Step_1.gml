/// ===============================================================================
/// PAC STEP_1 - ANIMATION UPDATES, INPUT HANDLING, & COLLISION DETECTION
/// ===============================================================================
/// Purpose: Handle keyboard input, manage collisions, and update animations
/// Called: SECOND each frame (after Step_0 direction sync)
///
/// Main Responsibilities:
/// 1. Execute support scripts (beginstep)
/// 2. Manage animation frame updates (Pac mouth opening/closing)
/// 3. Handle keyboard input for movement direction changes
/// 4. Detect and process dot collection
/// 5. Detect and process power pellet collection
/// 6. Detect and process fruit collection
/// 7. Detect ghost collisions (eating or being eaten)
/// 8. Check level completion (all dots collected)
/// 9. Manage background audio/ambience based on game state
///
/// This is a large event (1000+ lines) - eventually should be split into
/// multiple script functions for better maintainability.
/// ===============================================================================

// ===== EXECUTE SUPPORT SCRIPTS =====
/// Run external step functions for specialized logic
script_execute(beginstep);    // Handle player 1 startup logic

// ===== AUDIO & AMBIENCE MANAGEMENT =====
/// Control background music based on game state
if (global.lvl > 0) {

    /// Stop all ambience when not playing
    if (Pac.dead > PAC_STATE.ALIVE || Pac.finish > 0 || global.start == 1) {
        sound_stop(Ghost1);
        sound_stop(Ghost2);
        sound_stop(Ghost3);
        sound_stop(Ghost4);
        sound_stop(Ghost5);
        sound_stop(Blue);
        sound_stop(Flee);

        sound_stop(MsGhost1);
        sound_stop(MsGhost2);
        sound_stop(MsGhost3);
        sound_stop(MsGhost4);
        sound_stop(MsGhost5);
        sound_stop(MsBlue);
        sound_stop(MsFlee);

        sound_stop(JrGhost1);
        sound_stop(JrGhost2);
        sound_stop(JrGhost3);
        sound_stop(JrGhost4);
        sound_stop(JrGhost5);
        sound_stop(JrBlue);
        sound_stop(JrFlee);
    }

    /// Only manage ambience during active gameplay
    if (Pac.dead == PAC_STATE.ALIVE && Pac.finish == 0 && global.start == 0) {

        /// ===== SIREN PROGRESSION =====
        /// Update siren level based on remaining dot count
        /// Different thresholds for different level sizes
        if (room_width == 448) {
            /// Small level (classic Pacman)
            if (siren == 0 && Pac.dotcount > 111) {
                siren = 1;
            }
            if (siren == 1 && Pac.dotcount > 179) {
                siren = 2;
            }
            if (siren == 2 && Pac.dotcount > 211) {
                siren = 3;
            }
            if (siren == 3 && Pac.dotcount > 227) {
                siren = 4;
            }
        }
        else {
            /// Large level
            if (siren == 0 && Pac.dotcount > 229) {
                siren = 1;
            }
            if (siren == 1 && Pac.dotcount > 357) {
                siren = 2;
            }
            if (siren == 2 && Pac.dotcount > 421) {
                siren = 3;
            }
            if (siren == 3 && Pac.dotcount > 453) {
                siren = 4;
            }
        }

        /// ===== AUDIO PLAYBACK =====
        /// Select appropriate music based on game state and game variant
        if (global.game == 0) {
            /// STANDARD PACMAN SOUNDS

            /// Check if any ghost is in flee (frightened) mode
            if (Blinky.state == GHOST_STATE.EYES || Pinky.state == GHOST_STATE.EYES ||
                Inky.state == GHOST_STATE.EYES || Clyde.state == GHOST_STATE.EYES) {

                if (ambience != 6) {
                    sound_loop(Flee);
                    ambience = 6;
                    exit;
                }
            }
            else {          
				/// No ghosts in EYES state - stop Flee sound if it's playing
                if (ambience == 6) {
                    sound_stop(Flee);
                    ambience = -1;  // Reset to allow normal sounds to play
                }
				
                /// Check fright mode
                if (fright == PAC_FRIGHT.ACTIVE) {
                    if (ambience != 5) {
                        sound_loop(Blue);
                        ambience = 5;
                        exit;
                    }
                }
                else {
					if (ambience == 5) { sound_stop(Blue); ambience = -1; }
					
                    /// Play siren based on dot progression
                    if (siren == 4) {
                        if (ambience != SIREN_LEVEL.LEVEL_4) {
                            stop_siren_sound();
							sound_loop(Ghost5);
                            ambience = SIREN_LEVEL.LEVEL_4;
                            exit;
                        }
                    }
                    else if (siren == 3) {
                        if (ambience != SIREN_LEVEL.LEVEL_3) {
                            stop_siren_sound();
							sound_loop(Ghost4);
                            ambience = SIREN_LEVEL.LEVEL_3;
                            exit;
                        }
                    }
                    else if (siren == 2) {
                        if (ambience != SIREN_LEVEL.LEVEL_2) {
                            stop_siren_sound();
							sound_loop(Ghost3);
                            ambience = SIREN_LEVEL.LEVEL_2;
                            exit;
                        }
                    }
                    else if (siren == 1) {
                        if (ambience != SIREN_LEVEL.LEVEL_1) {
                            stop_siren_sound();
							sound_loop(Ghost2);
                            ambience = SIREN_LEVEL.LEVEL_1;
                            exit;
                        }
                    }
                    else {
                        if (ambience != SIREN_LEVEL.LEVEL_0) {
                            stop_siren_sound();
							sound_loop(Ghost1);
                            ambience = SIREN_LEVEL.LEVEL_0;
                            exit;
                        }
                    }
                }
            }
        }

        if (global.game == 1) {
            /// MS. PACMAN SOUNDS

            if (global.otto == 0 && (Blinky.state == GHOST_STATE.EYES || Pinky.state == GHOST_STATE.EYES ||
                Inky.state == GHOST_STATE.EYES || Clyde.state == GHOST_STATE.EYES)) {

                if (ambience != 6) {
                    sound_loop(MsFlee);
                    ambience = 6;
                    exit;
                }
            }
            else {
                if (fright == PAC_FRIGHT.ACTIVE) {
                    if (ambience != 5) {
                        sound_loop(MsBlue);
                        ambience = 5;
                        exit;
                    }
                }
                else {
                    if (siren == 4) {
                        if (ambience != SIREN_LEVEL.LEVEL_4) {
                            sound_loop(MsGhost5);
                            ambience = SIREN_LEVEL.LEVEL_4;
                            exit;
                        }
                    }
                    else if (siren == 3) {
                        if (ambience != SIREN_LEVEL.LEVEL_3) {
                            sound_loop(MsGhost4);
                            ambience = SIREN_LEVEL.LEVEL_3;
                            exit;
                        }
                    }
                    else if (siren == 2) {
                        if (ambience != SIREN_LEVEL.LEVEL_2) {
                            sound_loop(MsGhost3);
                            ambience = SIREN_LEVEL.LEVEL_2;
                            exit;
                        }
                    }
                    else if (siren == 1) {
                        if (ambience != SIREN_LEVEL.LEVEL_1) {
                            sound_loop(MsGhost2);
                            ambience = SIREN_LEVEL.LEVEL_1;
                            exit;
                        }
                    }
                    else {
                        if (ambience != SIREN_LEVEL.LEVEL_0) {
                            sound_loop(MsGhost1);
                            ambience = SIREN_LEVEL.LEVEL_0;
                            exit;
                        }
                    }
                }
            }
        }

        if (global.game == 2) {
            /// JR. PACMAN SOUNDS

            if (Blinky.state == GHOST_STATE.EYES || Pinky.state == GHOST_STATE.EYES ||
                Inky.state == GHOST_STATE.EYES || Clyde.state == GHOST_STATE.EYES) {

                if (ambience != 6) {
                    sound_loop(JrFlee);
                    ambience = 6;
                    exit;
                }
            }
            else {
                if (fright == PAC_FRIGHT.ACTIVE) {
                    if (ambience != 5) {
                        sound_loop(JrBlue);
                        ambience = 5;
                        exit;
                    }
                }
                else {
                    if (siren == 4) {
                        if (ambience != SIREN_LEVEL.LEVEL_4) {
                            sound_loop(JrGhost5);
                            ambience = SIREN_LEVEL.LEVEL_4;
                            exit;
                        }
                    }
                    else if (siren == 3) {
                        if (ambience != SIREN_LEVEL.LEVEL_3) {
                            sound_loop(JrGhost4);
                            ambience = SIREN_LEVEL.LEVEL_3;
                            exit;
                        }
                    }
                    else if (siren == 2) {
                        if (ambience != SIREN_LEVEL.LEVEL_2) {
                            sound_loop(JrGhost3);
                            ambience = SIREN_LEVEL.LEVEL_2;
                            exit;
                        }
                    }
                    else if (siren == 1) {
                        if (ambience != SIREN_LEVEL.LEVEL_1) {
                            sound_loop(JrGhost2);
                            ambience = SIREN_LEVEL.LEVEL_1;
                            exit;
                        }
                    }
                    else {
                        if (ambience != SIREN_LEVEL.LEVEL_0) {
                            sound_loop(JrGhost1);
                            ambience = SIREN_LEVEL.LEVEL_0;
                            exit;
                        }
                    }
                }
            }
        }
    }
}

// ===== ANIMATION FRAME UPDATES =====
/// Update Pac's mouth animation (im = image index for sprite animation)
/// Only animate when Pac is alive or dying (not dead yet)

if (dead < PAC_STATE.DEAD && Pac.finish >= 0) {

    if (global.start == 1) {
        /// Level starting: reset animation frame
        /// Different reset based on game mode
        if (global.game == 0) {
            im = 0;  // Standard Pacman
        }
        else {
            im = 1;  // Ms. Pacman or other variant
        }
    }
    else {
        /// Normal animation progression
        /// Only animate if moving or eating (not stopped)
        if ((hspeed != 0 || vspeed != 0) && chomp != 1) {
            // Increment animation frame
            if (global.boost == 0) {
                im = im + 1;  // Normal speed
            }
            else {
                im = im + ANIM_BOOST_MULTIPLIER;  // Faster during boost
            }
            // Loop animation (0-7)
            if (im > PAC_ANIM_MAX_FRAME) {
                im = 0;
            }
        }
    }
}

// ===== DEATH ANIMATION PROGRESSION =====
/// When Pac is fully dead (eaten), play dissolution animation
if (dead == PAC_STATE.DEAD) {
    /// Advance death animation frame (0 to ~12)
    if (deadanim < 12) {
        deadanim = deadanim + 0.125;
    }
}

// ===== LEVEL INTERMISSION ANIMATION =====
/// When level starts or finishes, show blinking effect
if (global.start == 0 && Pac.finish == 0) {
    im2 = im2 + 0.5;  // Slow Pac.blink animation
    if (im2 >= 4) {
        im2 = 0;  // Loop Pac.blink
    }
}

// ===== GLOBAL COLOR CYCLING =====
/// Color effect for visual polish (cycles through palette)
global.color = global.color + 2;
if (global.color > 239) {
    global.color = 0;  // Loop color cycling
}


// ===== TILE COORDINATE TRACKING =====
/// Update grid-aligned position for collision and pathfinding
if (global.lvl > 0) {

    if (corner == PAC_CORNER.NONE) {
        /// Not in corner transition: snap to grid normally
        tilex = 16 * (round(x / 16));
        tiley = 16 * (round(y / 16));
    }
    else {
        /// In corner transition: track if position is aligning to grid
        /// Increment counter for each axis that hasn't aligned yet
        if (tilex != 16 * (round(x / 16))) {
            cornercheck = cornercheck + 1;
        }
        if (tiley != 16 * (round(y / 16))) {
            cornercheck = cornercheck + 1;
        }
    }
}

// ===== INPUT & COLLISION PROCESSING =====
/// Only process input and collisions when:
/// - Pac is alive (not dead or in death animation)
/// - Level has started (not in intro delay)
/// - Level not finished (not waiting for level completion)
/// - Pac not stopped (not paused from dot collection)
/// - Not collided with Player 2

if (dead == PAC_STATE.ALIVE && global.start == 0 && Pac.finish == 0 && stoppy == 0 && bonked == 0) {

    if (global.lvl > 0) {

        if (corner == PAC_CORNER.NONE && chomp == 0) {
            /// Only accept input when:
            /// - Not in corner transition (one direction at a time)
            /// - Not currently eating ghost (chomp animation in progress)
            /// Process input through dedicated function
            /// This handles all 4 directions with corner mechanics
            handle_pac_input();

    }

    // ===== CORNER RE-ENTRY DURING TRANSITION =====
    /// Allow re-input while already in a corner transition (first 2 frames only)
    /// This enables quick direction changes mid-turn if path is clear
    if (corner > PAC_CORNER.NONE && chomp == 0 && cornercheck < 2) {

        /// Attempting to continue RIGHT during corner transition
        if (keyboard_check(vk_right) == true && keyboard_check(vk_up) == false &&
            keyboard_check(vk_left) == false && keyboard_check(vk_down) == false) {

            if (!collision_point(16 * (round((x) / 16)) + 17, 16 * (round((y) / 16)), Wall, false, true)) {
                /// Path to right is clear - flip direction vectors based on current corner state

                if (corner == PAC_CORNER.LEFT_TO_DOWN_POST) {
                    corner = PAC_CORNER.DOWN_TO_RIGHT_PRE;
                    hspeed = -hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.RIGHT;
                    exit;
                }
                if (corner == PAC_CORNER.RIGHT_TO_UP_POST) {
                    corner = PAC_CORNER.UP_TO_RIGHT_PRE;
                    hspeed = -hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.RIGHT;
                    exit;
                }
                if (corner == PAC_CORNER.LEFT_TO_UP_PRE) {
                    corner = PAC_CORNER.UP_TO_RIGHT_PRE;
                    hspeed = hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.RIGHT;
                    exit;
                }
                if (corner == PAC_CORNER.RIGHT_TO_DOWN_PRE) {
                    corner = PAC_CORNER.DOWN_TO_RIGHT_PRE;
                    hspeed = hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.RIGHT;
                    exit;
                }
                if (corner == PAC_CORNER.DOWN_TO_LEFT_PRE) {
                    corner = PAC_CORNER.DOWN_TO_RIGHT_PRE;
                    hspeed = -hspeed;
                    vspeed = vspeed;
                    dir = PAC_DIRECTION.RIGHT;
                    exit;
                }
                if (corner == PAC_CORNER.UP_TO_LEFT_POST) {
                    corner = PAC_CORNER.UP_TO_RIGHT_POST;
                    hspeed = -hspeed;
                    vspeed = vspeed;
                    dir = PAC_DIRECTION.RIGHT;
                    exit;
                }
            }
        }

        /// Attempting to continue UP during corner transition
        if (keyboard_check(vk_up) == true && keyboard_check(vk_right) == false &&
            keyboard_check(vk_left) == false && keyboard_check(vk_down) == false) {

            if (!collision_point(16 * (round((x) / 16)), 16 * (round((y) / 16)) - 1, Wall, false, true)) {
                /// Path upward is clear

                if (corner == PAC_CORNER.UP_TO_LEFT_POST) {
                    corner = PAC_CORNER.RIGHT_TO_UP_PRE;
                    hspeed = -hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.UP;
                    exit;
                }
                if (corner == PAC_CORNER.DOWN_TO_RIGHT_POST) {
                    corner = PAC_CORNER.RIGHT_TO_UP_POST;
                    hspeed = -hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.UP;
                    exit;
                }
                if (corner == PAC_CORNER.DOWN_TO_LEFT_PRE) {
                    corner = PAC_CORNER.LEFT_TO_UP_PRE;
                    hspeed = -hspeed;
                    vspeed = vspeed;
                    dir = PAC_DIRECTION.UP;
                    exit;
                }
                if (corner == PAC_CORNER.DOWN_TO_RIGHT_PRE) {
                    corner = PAC_CORNER.RIGHT_TO_UP_POST;
                    hspeed = -hspeed;
                    vspeed = vspeed;
                    dir = PAC_DIRECTION.UP;
                    exit;
                }
                if (corner == PAC_CORNER.LEFT_TO_DOWN_PRE) {
                    corner = PAC_CORNER.LEFT_TO_UP_PRE;
                    hspeed = hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.UP;
                    exit;
                }
                if (corner == PAC_CORNER.RIGHT_TO_DOWN_POST) {
                    corner = PAC_CORNER.RIGHT_TO_UP_POST;
                    hspeed = hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.UP;
                    exit;
                }
            }
        }

        /// Attempting to continue LEFT during corner transition
        if (keyboard_check(vk_left) == true && keyboard_check(vk_up) == false &&
            keyboard_check(vk_right) == false && keyboard_check(vk_down) == false) {

            if (!collision_point(16 * (round((x) / 16)) - 1, 16 * (round((y) / 16)), Wall, false, true)) {
                /// Path to left is clear

                if (corner == PAC_CORNER.LEFT_TO_DOWN_PRE) {
                    corner = PAC_CORNER.DOWN_TO_LEFT_PRE;
                    hspeed = -hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.LEFT;
                    exit;
                }
                if (corner == PAC_CORNER.RIGHT_TO_UP_PRE) {
                    corner = PAC_CORNER.UP_TO_LEFT_PRE;
                    hspeed = -hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.LEFT;
                    exit;
                }
                if (corner == PAC_CORNER.RIGHT_TO_DOWN_POST) {
                    corner = PAC_CORNER.DOWN_TO_LEFT_POST;
                    hspeed = hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.LEFT;
                    exit;
                }
                if (corner == PAC_CORNER.RIGHT_TO_UP_POST) {
                    corner = PAC_CORNER.UP_TO_LEFT_POST;
                    hspeed = hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.LEFT;
                    exit;
                }
                if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
                    corner = PAC_CORNER.UP_TO_LEFT_PRE;
                    hspeed = -hspeed;
                    vspeed = vspeed;
                    dir = PAC_DIRECTION.LEFT;
                    exit;
                }
                if (corner == PAC_CORNER.DOWN_TO_RIGHT_POST) {
                    corner = PAC_CORNER.DOWN_TO_LEFT_POST;
                    hspeed = -hspeed;
                    vspeed = vspeed;
                    dir = PAC_DIRECTION.LEFT;
                    exit;
                }
            }
        }

        /// Attempting to continue DOWN during corner transition
        if (keyboard_check(vk_down) == true && keyboard_check(vk_right) == false &&
            keyboard_check(vk_left) == false && keyboard_check(vk_up) == false) {

            if (!collision_point(16 * (round((x) / 16)), 16 * (round((y) / 16)) + 17, Wall, false, true)) {
                /// Path downward is clear

                if (corner == PAC_CORNER.DOWN_TO_LEFT_PRE) {
                    corner = PAC_CORNER.LEFT_TO_DOWN_PRE;
                    hspeed = -hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.DOWN;
                    exit;
                }
                if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
                    corner = PAC_CORNER.RIGHT_TO_DOWN_PRE;
                    hspeed = -hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.DOWN;
                    exit;
                }
                if (corner == PAC_CORNER.UP_TO_LEFT_POST) {
                    corner = PAC_CORNER.LEFT_TO_DOWN_POST;
                    hspeed = -hspeed;
                    vspeed = vspeed;
                    dir = PAC_DIRECTION.DOWN;
                    exit;
                }
                if (corner == PAC_CORNER.DOWN_TO_RIGHT_POST) {
                    corner = PAC_CORNER.RIGHT_TO_DOWN_POST;
                    hspeed = -hspeed;
                    vspeed = vspeed;
                    dir = PAC_DIRECTION.DOWN;
                    exit;
                }
                if (corner == PAC_CORNER.RIGHT_TO_UP_PRE) {
                    corner = PAC_CORNER.UP_TO_RIGHT_PRE;
                    hspeed = hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.DOWN;
                    exit;
                }
                if (corner == PAC_CORNER.RIGHT_TO_UP_POST) {
                    corner = PAC_CORNER.RIGHT_TO_DOWN_POST;
                    hspeed = hspeed;
                    vspeed = -vspeed;
                    dir = PAC_DIRECTION.DOWN;
                    exit;
                }
            }
        }
    }
}

}

// ===== DOT COLLECTION LOGIC =====
/// Detect when Pac moves to a new grid tile during menu navigation
/// (This section only runs when not in an active level)
if (dead == PAC_STATE.ALIVE) {
    if (global.lvl == 0) {
        if (speed > 0 && Pac.chomp == 0) {
            /// Check if we've reached a new tile
            if (newtile == 0) {
                if (tilex == (16 * (round(x / 16))) && tiley == (16 * (round(y / 16)))) {
                    // Already aligned with grid
                }
                else {
                    /// Moving to new tile - set flag and choose new direction
                    newtile = 1;
                    tilex = (16 * (round(x / 16)));
                    tiley = (16 * (round(y / 16)));
                    script_execute(random_direction);
                }
            }
        }
    }
}

// ===== DOT COLLECTION (ACTIVE LEVEL) =====
/// Detect collision with dot pellets during gameplay
/// Only triggers when Pac is alive, level has started, and not currently eating ghost
if (dead == PAC_STATE.ALIVE && global.start == 0 && (Pac.prohibit == GHOST_PROHIBIT.ALLOWED || Pac.prohibit == GHOST_PROHIBIT.PLAYER2_BLOCKED)) {

    if (place_meeting((16 * (round(x / 16))), (16 * (round(y / 16))), Dot)) {

        with (Dot) {
            if (place_meeting(x, y, Pac)) {

                /// Check if dot is a smashed power dot (jr mode)
                if (smashed == true) {
                    global.smashno = global.smashno - 1;
                    if (global.boost == 0) {
                        Pac.pause = 1;
                        Pac.stoppy = 1;
                    }
                    if (global.lvl > 0) {
                        global.p1score = global.p1score + 40;
                        sound_play(JrDot2);
                    }
                }
                else {
                    if (global.game == 2 && global.lvl > 0) {
                        sound_play(JrDot);
                    }
                }
                instance_destroy();
            }
        }

        /// Handle dot eating state
        if (global.boost == 0) {
            eatdir = direction / 45;
            direction = direction;
            speed = 0;
        }
        if (global.lvl > 0) {
            global.p1score = global.p1score + 10;
        }

        if (global.boost == 0) {
            Pac.timer = Pac.timerstart + 1;
        }

        bonked = 0;

        /// Play appropriate eating sound based on game variant
        if (global.lvl > 0) {

            if (global.game == 1) {
                sound_play(MsDot);
                exit;
            }

            if (global.game == 0) {
                if (dot == 0) {
                    sound_play(Dot0);
                    dot = 1;
                    exit;
                }

                if (dot == 1) {
                    sound_play(Dot1);
                    dot = 0;
                    exit;
                }
            }
        }
    }
}

// ===== POWER PELLET COLLECTION =====
/// Detect collision with power pellets - activates fright mode
/// Allows Pac to eat ghosts and gives speed boost
if (dead == PAC_STATE.ALIVE) {

    if (place_meeting((16 * (round(x / 16))), (16 * (round(y / 16))), Power)) {

        /// Destroy the power pellet sprite
        with (Power) {
            if (place_meeting(x, y, Pac)) {
                instance_destroy();
            }
        }

        /// Handle Pac's animation state
        if (global.boost == 0) {
            eatdir = direction / 45;
            direction = direction;
            speed = 0;
        }

        /// Activate fright mode if timer is set
        if (global.boost == 0) {
            pause = 1;
            stoppy = 1;
        }
        if (Pac.frighttime > 0) {
            /// In 2-player mode, toggle which player can eat ghosts
            if (global.players == 2) {
                if (Pac.prohibit == GHOST_PROHIBIT.PLAYER1_BLOCKED) {
                    Pac.prohibit = GHOST_PROHIBIT.ALLOWED;
                }
                else {
                    Pac.prohibit = GHOST_PROHIBIT.PLAYER2_BLOCKED;
                }
            }
            /// Activate fright mode and set duration
            fright = PAC_FRIGHT.ACTIVE;
            alarm[0] = Pac.frighttime;
            Pac.chompcount = 0;
        }

        /// Make all ghosts visible again
        Blinky.visible = true;
        Pinky.visible = true;
        Inky.visible = true;
        Clyde.visible = true;
        Pac.pluseat  = 0;

        Pac.plus = -1;

        Pac.timer = Pac.timerstart + 1;
        if (global.plus == 1) {
            Pac.plus = irandom(7);
        }

        /// All ghosts reverse direction
        with (Blinky) {
            aboutface = 1;
            if (state < GHOST_STATE.EYES && Pac.frighttime > 0) {
                if (Pac.plus == 0) {
                    if (state == GHOST_STATE.FRIGHTENED) {
                        state = GHOST_STATE.CHASE;
                    }
                }
                else {
                    state = GHOST_STATE.FRIGHTENED;
                }
            }
        }

        with (Pinky) {
            aboutface = 1;
            if (state < GHOST_STATE.EYES && Pac.frighttime > 0) {
                if (Pac.plus == 1) {
                    if (state == GHOST_STATE.FRIGHTENED) {
                        state = GHOST_STATE.CHASE;
                    }
                }
                else {
                    state = GHOST_STATE.FRIGHTENED;
                }
            }
        }

        with (Inky) {
            aboutface = 1;
            if (state < GHOST_STATE.EYES && Pac.frighttime > 0) {
                if (Pac.plus == 2) {
                    if (state == GHOST_STATE.FRIGHTENED) {
                        state = GHOST_STATE.CHASE;
                    }
                }
                else {
                    state = GHOST_STATE.FRIGHTENED;
                }
            }
        }

        with (Clyde) {
            aboutface = 1;
            if (state < GHOST_STATE.EYES && Pac.frighttime > 0) {
                if (Pac.plus == 3) {
                    if (state == GHOST_STATE.FRIGHTENED) {
                        state = GHOST_STATE.CHASE;
                    }
                }
                else {
                    state = GHOST_STATE.FRIGHTENED;
                }
            }
        }

        Pac.plus = -1;
        bonked = 0;

        /// Award points and play sound
        if (global.lvl > 0) {
            global.p1score = global.p1score + 50;

            if (global.game == 2) {
                sound_play(JrDot2);
            }

            if (global.game == 1) {
                sound_play(MsDot);
            }

            if (global.game == 0) {
                if (dot == 0) {
                    sound_play(Dot0);
                    dot = 1;
                    exit;
                }

                if (dot == 1) {
                    sound_play(Dot1);
                    dot = 0;
                    exit;
                }
            }
        }
    }
}


// ===== LEVEL COMPLETION CHECK =====
/// Detect when all dots have been collected
/// If so, trigger level completion sequence
if (global.lvl > 0 && global.start == 0 && dead == PAC_STATE.ALIVE) {

    if ((Pac.dotcount == global.dottotal || Pac.dotcount > global.dottotal) && Pac.finish == 0) {
        /// All dots collected - level complete!
        Pac.finish = 1;
        alarm[11] = 60;  // Level completion sequence timer
        alarm[1] = -1;   // Cancel fright alarm

        /// Stop all ghosts from moving
        Blinky.aboutface = 0;
        Pinky.aboutface = 0;
        Inky.aboutface = 0;
        Clyde.aboutface = 0;

        Blinky.speed = 0;
        Pinky.speed = 0;
        Inky.speed = 0;
        Clyde.speed = 0;
        Pac.speed = 0;
    }
}


// ===== FRUIT COLLECTION =====
/// Detect collision with bonus fruits during gameplay
/// Fruits award varying points based on level
if (dead == PAC_STATE.ALIVE && (Pac.prohibit == GHOST_PROHIBIT.ALLOWED || Pac.prohibit == GHOST_PROHIBIT.PLAYER2_BLOCKED)) {

    if (place_meeting((16 * (round(x / 16))), (16 * (round(y / 16))), Fruit) && speed > 0) {

        with (Fruit) {
            if (place_meeting(x, y, Pac)) {
                points = true;
                alarm[1] = 60;  // Fruit point display timer
                if (global.lvl > 0) {
                    sound_play(snd_Fruit);
                }

                /// Move fruit off-screen and reset state
                if (state > -1) {
                    xstart = x;
                    ystart = y;
                }
                x = -32;
                y = -32;
                tilex = 16 * (round(x / 16));
                tiley = 16 * (round(y / 16));
                newtile = 0;
                alarm[0] = -1;
                state = -1;
                direction = 0;
                speed = 0;
                dir = -1;

                /// Award points based on fruit type (value) and game mode
                if (global.lvl > 0) {

                    if (global.game == 0) {
                        /// Standard Pacman point values
                        if (value == 0) { global.p1score = global.p1score + 100; }
                        if (value == 1) { global.p1score = global.p1score + 300; }
                        if (value == 2) { global.p1score = global.p1score + 500; }
                        if (value == 3) { global.p1score = global.p1score + 700; }
                        if (value == 4) { global.p1score = global.p1score + 1000; }
                        if (value == 5) { global.p1score = global.p1score + 2000; }
                        if (value == 6) { global.p1score = global.p1score + 3000; }
                        if (value == 7) { global.p1score = global.p1score + 5000; }
                    }
                    else {
                        /// Ms. Pacman / Jr. Pacman point values (slightly different)
                        if (value == 0) { global.p1score = global.p1score + 100; }
                        if (value == 1) { global.p1score = global.p1score + 200; }
                        if (value == 2) { global.p1score = global.p1score + 500; }
                        if (value == 3) { global.p1score = global.p1score + 700; }
                        if (value == 4) { global.p1score = global.p1score + 1000; }
                        if (value == 5) { global.p1score = global.p1score + 2000; }
                        if (value == 6) { global.p1score = global.p1score + 5000; }
                    }
                }

                /// Check if bonus power fruit (grants extended fright mode)
                if (global.plus == true) {

                    if (bonustime > 0) {
                        /// In 2-player mode, toggle which player can eat ghosts
                        if (global.players == 2) {
                            if (Pac.prohibit == GHOST_PROHIBIT.PLAYER1_BLOCKED) {
                                Pac.prohibit = GHOST_PROHIBIT.ALLOWED;
                            }
                            else {
                                Pac.prohibit = GHOST_PROHIBIT.PLAYER2_BLOCKED;
                            }
                        }

                        /// Activate extended fright mode
                        fright = PAC_FRIGHT.ACTIVE;
                        Pac.alarm[0] = bonustime;
                        Pac.chompcount = 0;
                        Pac.pluseat  = 1;

                        /// Hide ghosts during bonus fright period
                        with (Blinky) {
                            if (state < GHOST_STATE.EYES) {
                                visible = false;
                            }
                        }

                        with (Pinky) {
                            if (state < GHOST_STATE.EYES) {
                                visible = false;
                            }
                        }

                        with (Inky) {
                            if (state < GHOST_STATE.EYES) {
                                visible = false;
                            }
                        }

                        with (Clyde) {
                            if (state < GHOST_STATE.EYES) {
                                visible = false;
                            }
                        }
                    }

                    Pac.timer = Pac.timerstart + 1;

                    /// All ghosts reverse and go frightened
                    with (Blinky) {
                        aboutface = 1;
                        if (state < GHOST_STATE.EYES && bonustime > 0) {
                            state = GHOST_STATE.FRIGHTENED;
                        }
                    }

                    with (Pinky) {
                        aboutface = 1;
                        if (state < GHOST_STATE.EYES && bonustime > 0) {
                            state = GHOST_STATE.FRIGHTENED;
                        }
                    }

                    with (Inky) {
                        aboutface = 1;
                        if (state < GHOST_STATE.EYES && bonustime > 0) {
                            state = GHOST_STATE.FRIGHTENED;
                        }
                    }

                    with (Clyde) {
                        aboutface = 1;
                        if (state < GHOST_STATE.EYES && bonustime > 0) {
                            state = GHOST_STATE.FRIGHTENED;
                        }
                    }
                }

                exit;
            }
        }
    }
}


// ===== GHOST COLLISION DETECTION =====
/// Detect collisions between Pac and ghosts
/// Determine whether Pac eats ghost (if ghost is frightened) or Pac dies
/// This section checks all 4 ghosts for collision

if (Pac.finish == 0 && chomp == 0 && dead == PAC_STATE.ALIVE) {

    // ===== BLINKY COLLISION =====
    /// Detect collision with Blinky (Red ghost)
    if (((16 * (round(x / 16)) == Blinky.tilex && 16 * (round(y / 16)) == Blinky.tiley) ||
        (abs(x - Blinky.x) < 5 && abs(y - Blinky.y) < 5)) && Blinky.house == 0) {

        with (Blinky) {
            /// Only process collision if Pac can interact with ghosts
            if (Pac.prohibit != GHOST_PROHIBIT.PLAYER1_BLOCKED) {

                /// Ghost is frightened - Pac eats it!
                if (state == GHOST_STATE.FRIGHTENED && Pac.chomp == 0) {
                    Pac.bonked = 0;
                    Pac.chomper = 1;

                    /// Play eating sound based on game variant
                    if (global.lvl > 0) {
                        if (global.game == 0) {
                            sound_play(Chomp);
                        }
                        if (global.game == 1) {
                            sound_play(MsChomp);
                        }
                        if (global.game == 2) {
                            sound_play(JrChomp);
                        }
                    }

                    with (Pac) {
                        script_execute(sickofit);
                    }

                    Pac.chompcount = Pac.chompcount + 1;
                    Pac.chomp = 1;
                    alarm[0] = 60;  // Eating animation duration
                    chomped = 1;

                    /// Store eating direction for animation
                    if (Pac.speed != 0) {
                        if (Pac.eatdir == -1) {
                            Pac.eatdir = Pac.direction / 45;
                        }
                    }

                    /// All ghosts reverse direction
                    with (Blinky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Pinky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Inky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Clyde) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Fruit) {
                        if (state > -1) {
                            resdir = direction / 90;
                        }
                    }

                    /// Award points based on ghost count eaten
                    if (global.lvl > 0) {
                        if (Pac.chompcount == 1) {
                            global.p1score = global.p1score + (200 + (200 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 2) {
                            global.p1score = global.p1score + (400 + (400 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 3) {
                            global.p1score = global.p1score + (800 + (800 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 4) {
                            global.p1score = global.p1score + (1600 + (1600 * Pac.pluseat ));
                        }
                    }
                }

                /// Ghost is not frightened - Pac dies!
                if (state == GHOST_STATE.CHASE && Pac.dead == PAC_STATE.ALIVE) {
                    Pac.deader = 1;
                    Pac.dead = PAC_STATE.DYING;
                    Pac.alarm[11] = 60;  // Death animation duration
                    bounce = -2;
                    uppity = 1;
                    okidoki = 1;

                    Pac.alarm[1] = -1;  // Cancel fright timer
                    Blinky.aboutface = 0;
                    Pinky.aboutface = 0;
                    Inky.aboutface = 0;
                    Clyde.aboutface = 0;

                    /// Snap all ghosts to grid
                    Blinky.tilex = 16 * (round(Blinky.x / 16));
                    Blinky.tiley = 16 * (round(Blinky.y / 16));

                    Pinky.tilex = 16 * (round(Pinky.x / 16));
                    Pinky.tiley = 16 * (round(Pinky.y / 16));

                    Inky.tilex = 16 * (round(Inky.x / 16));
                    Inky.tiley = 16 * (round(Inky.y / 16));

                    Clyde.tilex = 16 * (round(Clyde.x / 16));
                    Clyde.tiley = 16 * (round(Clyde.y / 16));

                    Blinky.newtile = 0;
                    Pinky.newtile = 0;
                    Inky.newtile = 0;
                    Clyde.newtile = 0;
                }
            }
        }
    }
}

    // ===== PINKY COLLISION =====
    /// Detect collision with Pinky (Pink ghost)
    if (((16 * (round(x / 16)) == Pinky.tilex && 16 * (round(y / 16)) == Pinky.tiley) ||
        (abs(x - Pinky.x) < 5 && abs(y - Pinky.y) < 5)) && Pinky.house == 0) {

        with (Pinky) {
            /// Only process collision if Pac can interact with ghosts
            if (Pac.prohibit != GHOST_PROHIBIT.PLAYER1_BLOCKED) {

                /// Ghost is frightened - Pac eats it!
                if (state == GHOST_STATE.FRIGHTENED && Pac.chomp == 0) {
                    Pac.bonked = 0;
                    Pac.chomper = 1;

                    /// Play eating sound based on game variant
                    if (global.lvl > 0) {
                        if (global.game == 0) {
                            sound_play(Chomp);
                        }
                        if (global.game == 1) {
                            sound_play(MsChomp);
                        }
                        if (global.game == 2) {
                            sound_play(JrChomp);
                        }
                    }

                    with (Pac) {
                        script_execute(sickofit);
                    }

                    Pac.chompcount = Pac.chompcount + 1;
                    Pac.chomp = 1;
                    alarm[0] = 60;  // Eating animation duration
                    chomped = 1;

                    if (Pac.speed != 0) {
                        if (Pac.eatdir == -1) {
                            Pac.eatdir = Pac.direction / 45;
                        }
                    }

                    /// All ghosts reverse direction
                    with (Blinky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Pinky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Inky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Clyde) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Fruit) {
                        if (state > -1) {
                            resdir = direction / 90;
                        }
                    }

                    /// Award points based on ghost count eaten
                    if (global.lvl > 0) {
                        if (Pac.chompcount == 1) {
                            global.p1score = global.p1score + (200 + (200 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 2) {
                            global.p1score = global.p1score + (400 + (400 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 3) {
                            global.p1score = global.p1score + (800 + (800 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 4) {
                            global.p1score = global.p1score + (1600 + (1600 * Pac.pluseat ));
                        }
                    }
                }

                /// Ghost is not frightened - Pac dies!
                if (state == GHOST_STATE.CHASE && Pac.dead == PAC_STATE.ALIVE) {
                    Pac.deader = 1;
                    Pac.dead = PAC_STATE.DYING;
                    Pac.alarm[11] = 60;
                    bounce = -2;
                    uppity = 1;
                    okidoki = 1;

                    Pac.alarm[1] = -1;
                    Blinky.aboutface = 0;
                    Pinky.aboutface = 0;
                    Inky.aboutface = 0;
                    Clyde.aboutface = 0;

                    Blinky.tilex = 16 * (round(Blinky.x / 16));
                    Blinky.tiley = 16 * (round(Blinky.y / 16));

                    Pinky.tilex = 16 * (round(Pinky.x / 16));
                    Pinky.tiley = 16 * (round(Pinky.y / 16));

                    Inky.tilex = 16 * (round(Inky.x / 16));
                    Inky.tiley = 16 * (round(Inky.y / 16));

                    Clyde.tilex = 16 * (round(Clyde.x / 16));
                    Clyde.tiley = 16 * (round(Clyde.y / 16));

                    Blinky.newtile = 0;
                    Pinky.newtile = 0;
                    Inky.newtile = 0;
                    Clyde.newtile = 0;
                }
            }
        }
    }

    // ===== INKY COLLISION =====
    /// Detect collision with Inky (Cyan ghost)
    if (((16 * (round(x / 16)) == Inky.tilex && 16 * (round(y / 16)) == Inky.tiley) ||
        (abs(x - Inky.x) < 5 && abs(y - Inky.y) < 5)) && Inky.house == 0) {

        with (Inky) {
            /// Only process collision if Pac can interact with ghosts
            if (Pac.prohibit != GHOST_PROHIBIT.PLAYER1_BLOCKED) {

                /// Ghost is frightened - Pac eats it!
                if (state == GHOST_STATE.FRIGHTENED && Pac.chomp == 0) {
                    Pac.bonked = 0;
                    Pac.chomper = 1;

                    if (global.lvl > 0) {
                        if (global.game == 0) {
                            sound_play(Chomp);
                        }
                        if (global.game == 1) {
                            sound_play(MsChomp);
                        }
                        if (global.game == 2) {
                            sound_play(JrChomp);
                        }
                    }

                    with (Pac) {
                        script_execute(sickofit);
                    }

                    Pac.chompcount = Pac.chompcount + 1;
                    Pac.chomp = 1;
                    alarm[0] = 60;
                    chomped = 1;

                    if (Pac.speed != 0) {
                        if (Pac.eatdir == -1) {
                            Pac.eatdir = Pac.direction / 45;
                        }
                    }

                    with (Blinky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Pinky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Inky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Clyde) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Fruit) {
                        if (state > -1) {
                            resdir = direction / 90;
                        }
                    }

                    if (global.lvl > 0) {
                        if (Pac.chompcount == 1) {
                            global.p1score = global.p1score + (200 + (200 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 2) {
                            global.p1score = global.p1score + (400 + (400 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 3) {
                            global.p1score = global.p1score + (800 + (800 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 4) {
                            global.p1score = global.p1score + (1600 + (1600 * Pac.pluseat ));
                        }
                    }
                }

                /// Ghost is not frightened - Pac dies!
                if (state == GHOST_STATE.CHASE && Pac.dead == PAC_STATE.ALIVE) {
                    Pac.deader = 1;
                    Pac.dead = PAC_STATE.DYING;
                    Pac.alarm[11] = 60;
                    bounce = -2;
                    uppity = 1;
                    okidoki = 1;

                    Pac.alarm[1] = -1;
                    Blinky.aboutface = 0;
                    Pinky.aboutface = 0;
                    Inky.aboutface = 0;
                    Clyde.aboutface = 0;

                    Blinky.tilex = 16 * (round(Blinky.x / 16));
                    Blinky.tiley = 16 * (round(Blinky.y / 16));

                    Pinky.tilex = 16 * (round(Pinky.x / 16));
                    Pinky.tiley = 16 * (round(Pinky.y / 16));

                    Inky.tilex = 16 * (round(Inky.x / 16));
                    Inky.tiley = 16 * (round(Inky.y / 16));

                    Clyde.tilex = 16 * (round(Clyde.x / 16));
                    Clyde.tiley = 16 * (round(Clyde.y / 16));

                    Blinky.newtile = 0;
                    Pinky.newtile = 0;
                    Inky.newtile = 0;
                    Clyde.newtile = 0;
                }
            }
        }
    }

    // ===== CLYDE COLLISION =====
    /// Detect collision with Clyde (Orange ghost)
    if (((16 * (round(x / 16)) == Clyde.tilex && 16 * (round(y / 16)) == Clyde.tiley) ||
        (abs(x - Clyde.x) < 5 && abs(y - Clyde.y) < 5)) && Clyde.house == 0) {

        with (Clyde) {
            /// Only process collision if Pac can interact with ghosts
            if (Pac.prohibit != GHOST_PROHIBIT.PLAYER1_BLOCKED) {

                /// Ghost is frightened - Pac eats it!
                if (state == GHOST_STATE.FRIGHTENED && Pac.chomp == 0) {
                    Pac.bonked = 0;
                    Pac.chomper = 1;

                    if (global.lvl > 0) {
                        if (global.game == 0) {
                            sound_play(Chomp);
                        }
                        if (global.game == 1) {
                            sound_play(MsChomp);
                        }
                        if (global.game == 2) {
                            sound_play(JrChomp);
                        }
                    }

                    with (Pac) {
                        script_execute(sickofit);
                    }

                    Pac.chompcount = Pac.chompcount + 1;
                    Pac.chomp = 1;
                    alarm[0] = 60;
                    chomped = 1;

                    if (Pac.speed != 0) {
                        if (Pac.eatdir == -1) {
                            Pac.eatdir = Pac.direction / 45;
                        }
                    }

                    with (Blinky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Pinky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Inky) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Clyde) {
                        if (state < GHOST_STATE.EYES) {
                            resdir = direction / 90;
                        }
                    }
                    with (Fruit) {
                        if (state > -1) {
                            resdir = direction / 90;
                        }
                    }

                    if (global.lvl > 0) {
                        if (Pac.chompcount == 1) {
                            global.p1score = global.p1score + (200 + (200 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 2) {
                            global.p1score = global.p1score + (400 + (400 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 3) {
                            global.p1score = global.p1score + (800 + (800 * Pac.pluseat ));
                        }
                        if (Pac.chompcount == 4) {
                            global.p1score = global.p1score + (1600 + (1600 * Pac.pluseat ));
                        }
                    }
                }

                /// Ghost is not frightened - Pac dies!
                if (state == GHOST_STATE.CHASE && Pac.dead == PAC_STATE.ALIVE) {
                    Pac.deader = 1;
                    Pac.dead = PAC_STATE.DYING;
                    Pac.alarm[11] = 60;
                    bounce = -2;
                    uppity = 1;
                    okidoki = 1;

                    Pac.alarm[1] = -1;
                    Blinky.aboutface = 0;
                    Pinky.aboutface = 0;
                    Inky.aboutface = 0;
                    Clyde.aboutface = 0;

                    Blinky.tilex = 16 * (round(Blinky.x / 16));
                    Blinky.tiley = 16 * (round(Blinky.y / 16));

                    Pinky.tilex = 16 * (round(Pinky.x / 16));
                    Pinky.tiley = 16 * (round(Pinky.y / 16));

                    Inky.tilex = 16 * (round(Inky.x / 16));
                    Inky.tiley = 16 * (round(Inky.y / 16));

                    Clyde.tilex = 16 * (round(Clyde.x / 16));
                    Clyde.tiley = 16 * (round(Clyde.y / 16));

                    Blinky.newtile = 0;
                    Pinky.newtile = 0;
                    Inky.newtile = 0;
                    Clyde.newtile = 0;
                }
            }
        }
    }


// ===== MOVEMENT STATE OVERRIDES =====
/// When Pac is eating a ghost (chomp), freeze all movement
if (chomp == true) {
    direction = direction;
    speed = 0;
    alarm[0] = alarm[0] + 1;

    /// Freeze all ghosts except eyes mode
    with (Blinky) {
        if (state < GHOST_STATE.EYES) {
            hspeed = 0;
            vspeed = 0;
        }
    }
    with (Pinky) {
        if (state < GHOST_STATE.EYES) {
            hspeed = 0;
            vspeed = 0;
        }
    }
    with (Inky) {
        if (state < GHOST_STATE.EYES) {
            hspeed = 0;
            vspeed = 0;
        }
    }
    with (Clyde) {
        if (state < GHOST_STATE.EYES) {
            hspeed = 0;
            vspeed = 0;
        }
    }
    with (Fruit) {
        if (state > -1) {
            hspeed = 0;
            vspeed = 0;
        }
    }
}

/// When level is starting, freeze all actors
if (global.start == true) {
    hspeed = 0;
    vspeed = 0;
    alarm[0] = alarm[0] + 1;

    with (Blinky) {
        hspeed = 0;
        vspeed = 0;
    }
    with (Pinky) {
        hspeed = 0;
        vspeed = 0;
    }
    with (Inky) {
        hspeed = 0;
        vspeed = 0;
    }
    with (Clyde) {
        hspeed = 0;
        vspeed = 0;
    }
    with (Fruit) {
        hspeed = 0;
        vspeed = 0;
    }
}

/// When Pac is dead, freeze all actors
if (dead > PAC_STATE.ALIVE) {
    hspeed = 0;
    vspeed = 0;
    alarm[0] = alarm[0] + 1;

    with (Blinky) {
        hspeed = 0;
        vspeed = 0;
    }
    with (Pinky) {
        hspeed = 0;
        vspeed = 0;
    }
    with (Inky) {
        hspeed = 0;
        vspeed = 0;
    }
    with (Clyde) {
        hspeed = 0;
        vspeed = 0;
    }
    with (Fruit) {
        hspeed = 0;
        vspeed = 0;
    }
}

// ===== FRIGHT MODE END CONDITION =====
/// When all ghosts have returned to chase mode, fright ends
if (fright == PAC_FRIGHT.ACTIVE) {
    if (Blinky.state == GHOST_STATE.CHASE && Pinky.state == GHOST_STATE.CHASE &&
        Inky.state == GHOST_STATE.CHASE && Clyde.state == GHOST_STATE.CHASE) {

        /// Fright mode complete - reset to normal
        alarm[0] = -1;
        fright = PAC_FRIGHT.OFF;
        Pac.prohibit = GHOST_PROHIBIT.ALLOWED;

        /// Reset speeds to normal (not boosted)
        if (bonked == 0) {
            if (hspeed > 0) {
                hspeed = sp;
            }
            if (hspeed < 0) {
                hspeed = -sp;
            }
            if (vspeed > 0) {
                vspeed = sp;
            }
            if (vspeed < 0) {
                vspeed = -sp;
            }
        }

        Pac.chompcount = 0;
        Pac.pluseat  = 0;
    }
}


