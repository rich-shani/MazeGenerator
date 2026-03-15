/// ===============================================================================
/// ALARM_11 - DEATH ANIMATION, LIFE LOSS, & LEVEL COMPLETION HANDLER
/// ===============================================================================
/// Purpose: Manage Pac death animation, life loss recovery, level completion sequences,
///          and transitions to cutscenes or next maze
/// Called: On death (alarm[11] = 120), after life loss recovery (alarm[11] = 60/120),
///         and during level completion (alarm[11] = 10)
///
/// Major Sections:
/// 1. Game Over / Final Death Detection
/// 2. Death Animation Sequence (dead = 1)
/// 3. Life Loss Processing (dead = 2/3)
/// 4. Dot Restoration & Ghost Repositioning
/// 5. Level Completion Sequences (Pac.finish > 0)
/// 6. Cutscene & Maze Transitions
/// ===============================================================================

/// ===============================================================================
/// SECTION 1: GAME OVER DETECTION (Both Players Dead or Level 0 Death)
/// ===============================================================================
/// Check if we're in a game-ending state (Pac.finish = 0 means not level completion)
if (Pac.finish == 0) {
    /// Check if level 0 (title screen) or game completely over
    if (global.lvl == 0 || Pac.countdown  == -1) {
        /// Final death state triggers game end
        if (dead == PAC_STATE.DEAD_FINAL) {
            if (global.lvl == 0) {
                /// Reset and advance to next game variant
                global.otto = 0;
                global.p1score = 0;
                global.game = global.game + 1;

                /// Cycle through game variants (0 → 1 → 2 → 0)
                if (global.game == 3) {
                    global.game = 0;
                }

                /// Return to menu or title based on credits
                if (global.credit > 0) {
                    room_goto(rm_Menu);
                } else {
                    room_goto(rm_Title);
                }
            } else {
                /// Both players out of lives - game over
                /// Check if both players have no lives left
                if ((global.p1lives == 0 || global.p1gameover == 1) &&
                    (global.p2lives == 0 || global.p2gameover == 1)) {
                    /// Reset level and scores
                    global.lvl = 0;
                    global.p1score = 0;
                    global.p2score = 0;

                    /// Return to menu or title
                    if (global.credit > 0) {
                        room_goto(rm_Menu);
                    } else {
                        room_goto(rm_Title);
                    }
                } else {
                    /// One player still has lives - mark dead player as game over
                    if (global.p1lives == 0) {
                        global.p1gameover = 1;
                    }
                    if (global.p2lives == 0) {
                        global.p2gameover = 1;
                    }

                    /// Re-trigger this alarm to process life loss
                    alarm[11] = 1;
                    Pac.countdown  = 10;

                    /// Reset Pac.blink animation and pause handler
                    Pac.blink = 0;
                    alarm[8] = 14;
                    Pauser.ignore = 1;
                }
            }
        }
    }
}

/// ===============================================================================
/// SECTION 2: DEATH ANIMATION SEQUENCE (dead = 1 → dead = 2)
/// ===============================================================================
/// First frame of death: play death sound and hide ghosts
if (Pac.finish == 0) {
    if (dead == PAC_STATE.DYING) {
        /// Play game variant-specific death sound
        if (global.lvl > 0) {
            if (global.game == 0) {
                sound_play(Die);
            }
            if (global.game == 1) {
                sound_play(MsDie);
            }
            if (global.game == 2) {
                sound_play(JrDie);
            }
        }

        /// Transition to death animation state
        dead = PAC_STATE.DEAD;

        /// Stop Pac movement
        hspeed = 0;
        vspeed = 0;

        /// Move all ghosts off-screen
        Blinky.x = -5000;
        Blinky.y = -5000;
        Pinky.x = -5000;
        Pinky.y = -5000;
        Inky.x = -5000;
        Inky.y = -5000;
        Clyde.x = -5000;
        Clyde.y = -5000;

        /// Re-trigger in 120 frames to show death animation
        alarm[11] = 120;
        exit;
    }
}

/// ===============================================================================
/// SECTION 3: LIFE LOSS PROCESSING (dead = 2 or 3)
/// ===============================================================================
if (dead == PAC_STATE.DEAD || dead == PAC_STATE.DEAD_FINAL) {
    /// Deduct life from the appropriate player
    if (deader == 1) {
        /// Player 1 died
        if (global.p1lives > 0) {
            global.p1lives = global.p1lives - 1;
        }
    } else {
        /// Player 2 died
        if (global.p2lives > 0) {
            global.p2lives = global.p2lives - 1;
        }
    }

    /// Check if remaining player(s) have lives
    if ((global.p1lives == 0 && global.p1gameover == 0) ||
        (global.p2lives == 0 && global.p2gameover == 0)) {
        /// At least one player out of lives
        dead = PAC_STATE.DEAD_FINAL;

        /// Hide Pac based on game variant
        if (global.game == 2) {
            /// Jr. Pac-Man: hide vertically
            y = -5000;
        } else {
            /// Standard/Ms. Pac: hide horizontally
            x = -5000;
            y = ystart;
        }

        /// Reset power pellet state
		with (Power) {
			alarm[0] = 0;
			alarm[1] = 0;
		}
		
        Pac.blink = 0;
        alarm[8] = -1;

        /// Countdown for next state
        Pac.countdown  = Pac.countdown  - 1;

        /// Determine next alarm timing
        if (Pac.countdown  == -1 || global.lvl == 0) {
            alarm[11] = 120;  /// Longer pause for game over
        } else {
            alarm[11] = 60;  /// Shorter pause for next player

            /// Play dot collection sound for next level ready
            if (global.game == 0) {
                sound_play(Dot0);
            }
            if (global.game == 1) {
                sound_play(MsDot);
            }
            if (global.game == 2) {
                sound_play(JrDot);
            }
        }
    } else {
        /// ===============================================================================
        /// SECTION 4: DOT RESTORATION & GHOST REPOSITIONING (Life Recovery)
        /// ===============================================================================
        /// Restore all destroyed dots (for eaten dots to respawn)
        instance_activate_object(Dot);
        with (Dot) {
            /// Check if dot was eaten (smashed = 1)
            if (smashed == 1) {
                if (global.smashno == (global.dottotal - Pac.Pac.dotcount)) {
                    /// Restore the dot to map layer
                    smashed = 0;
                    tile_add(tile3, 0, 0, 16, 16, x, y, depth);
                    tile_set_blend(tile_layer_find(depth, x, y),
                        make_color_hsv(Drawless.dh, Drawless.ds, Drawless.dv));
                    tile_delete(tile_layer_find(depth - 1, x, y));
                    tile_delete(tile_layer_find(depth + 1, x, y));
                } else {
                    /// Remove orphaned dots
                    instance_destroy();
                }
            }
        }

        /// Restore power pellets to map
        with (Power) {
            alarm[0] = -1;
            alarm[1] = -1;
            visible = true;
        }

        /// Reset ghost release signatures for new life
        Pac.psig = Pac.dotcount + 7;
        Pac.isig = Pac.dotcount + 17;
        Pac.csig = Pac.dotcount + 32;
        Pac.timer = Pac.timerstart;

        /// Add power pellets to tile layer
        with (Power) {
            tile_layer_delete_at(depth, x, y);
            vis = 1;
            tile_add(tile3, 16, 0, 16, 16, x, y, depth);
            tile_set_blend(tile_layer_find(depth, x, y),
                make_color_hsv(Drawless.dh, Drawless.ds, Drawless.dv));
        }

        /// ===============================================================================
        /// SECTION 5: GHOST REPOSITIONING TO STARTING POSITIONS
        /// ===============================================================================
        /// Reset Blinky (red ghost) to home
        with (Blinky) {
            aboutface = 0;
            state = GHOST_STATE.CHASE;
            house = 0;
            housestate = 0;
            dir = PAC_DIRECTION.LEFT;
            resdir = -1;
            x = xstart;
            y = ystart;
            newtile = 0;
            tilex = 16 * (round(x / 16));
            tiley = 16 * (round(y / 16));
        }

        /// Reset Pinky (pink ghost) to home
        with (Pinky) {
            aboutface = 0;
            state = GHOST_STATE.CHASE;
            house = 1;
            housestate = 1;
            up = 0;
            dir = PAC_DIRECTION.DOWN;
            resdir = -1;
            x = xstart;
            y = ystart;
            newtile = 0;
            tilex = 16 * (round(x / 16));
            tiley = 16 * (round(y / 16));
        }

        /// Reset Inky (cyan ghost) to home
        with (Inky) {
            aboutface = 0;
            state = GHOST_STATE.CHASE;
            house = 1;
            housestate = 2;
            up = 1;
            dir = PAC_DIRECTION.UP;
            resdir = -1;
            x = xstart;
            y = ystart;
            newtile = 0;
            tilex = 16 * (round(x / 16));
            tiley = 16 * (round(y / 16));
        }

        /// Reset Clyde (orange ghost) to home
        with (Clyde) {
            aboutface = 0;
            state = GHOST_STATE.CHASE;
            house = 1;
            housestate = 2;
            up = 1;
            dir = PAC_DIRECTION.UP;
            resdir = -1;
            x = xstart;
            y = ystart;
            newtile = 0;
            tilex = 16 * (round(x / 16));
            tiley = 16 * (round(y / 16));
        }

        /// Reset fruit
        with (Fruit) {
            alarm[0] = -1;
            x = -32;
            y = -32;
            dir = -1;
            exopt = -1;
            state = -1;
            newtile = 0;
            tilex = 16 * (round(x / 16));
            tiley = 16 * (round(y / 16));
            resdir = -1;

            /// Jr. Pac-Man fruit spawn tracking
            if (global.game == 2) {
                if (spawn == 1 && ((Drawless.c64 == 1 && Pac.Pac.dotcount > 323) ||
                    (Pac.Pac.dotcount > 207))) {
                    spawn = 2;
                }
                if (spawn == 2 && ((Drawless.c64 == 1 && Pac.Pac.dotcount > 400) ||
                    (Pac.Pac.dotcount > 301))) {
                    spawn = 3;
                }
                if (spawn == 3 && ((Drawless.c64 == 1 && Pac.Pac.dotcount > 477) ||
                    (Pac.Pac.dotcount > 413))) {
                    spawn = 4;
                }
            }
        }

        /// ===============================================================================
        /// SECTION 6: PAC STATE RESET FOR NEW LIFE
        /// ===============================================================================
        alarm[0] = -1;
        alarm[1] = -1;
        cycle = 0;
        scatter = 1;
        pause = 0;
        park = -1;
        eatdir = -1;
        corner = 0;
        dead = PAC_STATE.ALIVE;
        dir = PAC_DIRECTION.LEFT;
        deadanim = 0;
        fright = PAC_FRIGHT.OFF;

        /// Reset player state
        newtile = 0;
        corner = 0;
        cornercheck = 0;
        bonked = 0;

        /// Reposition player
        if (global.p1lives > 0) {
            x = xstart;
            y = ystart;
        } else {
            x = -5000;
            y = ystart;
        }

        /// Update tile positions
        tilex = 16 * (round(x / 16));
        tiley = 16 * (round(y / 16));
        eatdir = -1;

        /// Trigger level initialization
        global.start = 1;
        alarm[10] = 90;

        /// Adjust view for Jr. Pac-Man if needed
        if (global.game == 2) {
            if (room_height == 980) {
                __view_set(e__VW.XView, 0, 24);
                __view_set(e__VW.YView, 0, 184);
            } else {
                __view_set(e__VW.XView, 0, 208 - (Drawless.c64 * 144));
            }
        }

        /// Resume normal pause handling
        Pauser.ignore = 0;
        global.smashno = 0;
    }
}

/// ===============================================================================
/// SECTION 7: LEVEL COMPLETION SEQUENCE (Pac.finish > 0)
/// ===============================================================================
/// Handle maze completion effects and transitions
if (Pac.finish > 0) {
    Pac.finish = Pac.finish + 1;

    /// Destroy all remaining dots and power pellets
    with (Dot) {
        instance_destroy();
    }
    with (Power) {
        instance_destroy();
    }

    /// Cycle wall blinking animation
    Drawless.blink = Drawless.blink + 1;
    if (Drawless.blink == 2) {
        Drawless.blink = 0;
    }

    /// Keep re-triggering for animation
    alarm[11] = 10;

    /// ===============================================================================
    /// SECTION 8: WALL BLINKING EFFECT DURING LEVEL COMPLETION
    /// ===============================================================================
    with (Drawless) {
        if (Pac.blink == 0) {
            /// Blink on: show colored walls
            with (Wall) {
                /// Special handling for ghost house
                if (id == 314469) {
                    tile_set_blend(tile_layer_find(depth - 1, x, y - 8),
                        make_color_hsv(Drawless.mh, Drawless.ms, Drawless.mv));
                    tile_set_blend(tile_layer_find(depth, x, y),
                        make_color_hsv(Drawless.mh2, Drawless.ms2, Drawless.mv2));
                } else {
                    /// Standard walls
                    if (image_index == 18 && ((room_height < 960 && y == room_height - 48) ||
                        (room_height == 960 && y == room_height - 64))) {
                        tile_set_blend(tile_layer_find(depth - 1, x, y + 8),
                            make_color_hsv(Drawless.mh, Drawless.ms, Drawless.mv));
                        tile_set_blend(tile_layer_find(depth, x, y),
                            make_color_hsv(Drawless.mh2, Drawless.ms2, Drawless.mv2));
                    } else {
                        /// Skip ghost house area and certain regions
                        if (!(global.game == 2 && y == Blinky.ystart + 16 &&
                            x > Blinky.xstart - 17 && x < Blinky.xstart + 17)) {
                            if (!(global.game < 2 && y == (Blinky.ystart - 224) + 240 &&
                                x > (Blinky.xstart - 216) + 207 && x < (Blinky.xstart - 216) + 225)) {
                                tile_set_blend(tile_layer_find(depth - 1, x + (extra * 8), y),
                                    make_color_hsv(Drawless.mh, Drawless.ms, Drawless.mv));
                            }
                        }

                        /// Special handling for start area
                        if (global.game < 2 && y == (Blinky.ystart - 224) + 240 &&
                            x > (Blinky.xstart - 216) + 207 && x < (Blinky.xstart - 216) + 225) {
                            tile_set_blend(tile_layer_find(depth, x, y), c_black);
                        } else {
                            tile_set_blend(tile_layer_find(depth, x, y),
                                make_color_hsv(Drawless.mh2, Drawless.ms2, Drawless.mv2));
                        }
                    }
                }
            }
        } else {
            /// Blink off: show white/black walls
            with (Wall) {
                if (id == 314469) {
                    tile_set_blend(tile_layer_find(depth - 1, x, y - 8), c_white);
                    tile_set_blend(tile_layer_find(depth, x, y), c_black);
                } else {
                    if (image_index == 18 && ((room_height < 960 && y == room_height - 48) ||
                        (room_height == 960 && y == room_height - 64))) {
                        tile_set_blend(tile_layer_find(depth - 1, x, y + 8), c_white);
                        tile_set_blend(tile_layer_find(depth, x, y), c_black);
                    } else {
                        if (!(global.game == 2 && y == Blinky.ystart + 16 &&
                            x > Blinky.xstart - 17 && x < Blinky.xstart + 17)) {
                            if (!(global.game < 2 && y == (Blinky.ystart - 224) + 240 &&
                                x > (Blinky.xstart - 216) + 207 && x < (Blinky.xstart - 216) + 225)) {
                                tile_set_blend(tile_layer_find(depth - 1, x + (extra * 8), y), c_white);
                            }
                        }

                        if (global.game < 2 && y == (Blinky.ystart - 224) + 240 &&
                            x > (Blinky.xstart - 216) + 207 && x < (Blinky.xstart - 216) + 225) {
                            tile_set_blend(tile_layer_find(depth, x, y), c_black);
                        } else {
                            tile_set_blend(tile_layer_find(depth, x, y), c_black);
                        }
                    }
                }
            }
        }
    }

    /// Stop all actors during transition
    hspeed = 0;
    vspeed = 0;

    /// Hide all ghosts
    Blinky.housestate = 0;
    Blinky.house = 0;
    Blinky.x = -5000;
    Blinky.y = -5000;
    Pinky.housestate = 0;
    Pinky.house = 0;
    Pinky.x = -5000;
    Pinky.y = -5000;
    Inky.housestate = 0;
    Inky.house = 0;
    Inky.x = -5000;
    Inky.y = -5000;
    Clyde.housestate = 0;
    Clyde.house = 0;
    Clyde.x = -5000;
    Clyde.y = -5000;
}

/// ===============================================================================
/// SECTION 9: CUTSCENE & MAZE TRANSITIONS (Pac.finish = 10)
/// ===============================================================================
/// Transition to next level/cutscene after completion animation
if (Pac.finish == 10) {
    /// Choose maze type or show cutscene based on game variant and level
    if (global.rand == 0) {
        /// Random maze generator route
        if (global.game == 0) {
            /// Standard Pac-Man cutscene levels
            if (global.lvl == 2) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 5) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 9) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 13) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 17) {
                room_goto(rm_Cutscene);
            } else {
                script_execute(mazer);
            }
        }

        if (global.game == 1) {
            /// Ms. Pac-Man cutscene levels
            if (global.lvl == 2) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 5) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 9) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 13) {
                room_goto(rm_Cutscene);
                global.loop = 1;
            } else if (global.lvl == 17) {
                room_goto(rm_Cutscene);
            } else {
                script_execute(mazer);
            }
        }

        if (global.game == 2) {
            /// Jr. Pac-Man cutscene levels
            if (global.lvl == 1) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 3) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 5) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 7) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 9) {
                room_goto(rm_Cutscene);
            } else if (global.last == 0) {
                room_goto_next();
            } else {
                /// Game mode variant ending rooms
                if (global.mode == 0) room_goto(JrPacMan4);
                if (global.mode == 1) room_goto(VS4);
                if (global.mode == 2) room_goto(C64_03);
                if (global.mode == 3) room_goto(A2600_4);
                if (global.mode == 4) room_goto(Bleach4);
            }
        }
    } else {
        /// Fixed maze route (non-random)
        if (global.game == 0) {
            if (global.lvl == 2) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 5) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 9) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 13) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 17) {
                room_goto(rm_Cutscene);
            } else {
                script_execute(maze_picker);
            }
        }

        if (global.game == 1) {
            if (global.lvl == 2) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 5) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 9) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 13) {
                room_goto(rm_Cutscene);
                global.loop = 1;
            } else if (global.lvl == 17) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 21) {
                room_goto(MsPacMan3);
                global.loop = 0;
            } else {
                script_execute(maze_picker);
            }
        }

        if (global.game == 2) {
            if (global.lvl == 1) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 3) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 5) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 7) {
                room_goto(rm_Cutscene);
            } else if (global.lvl == 9) {
                room_goto(rm_Cutscene);
            } else {
                script_execute(maze_picker);
            }
        }
    }
}
