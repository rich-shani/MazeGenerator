/// ===============================================================================
/// ALARM_10 - LEVEL INITIALIZATION AND GAME START SEQUENCE
/// ===============================================================================
/// Purpose: Initialize level on game start, manage ghost releases, setup fruits
/// Called: After introductory pause (alarm[10] triggers after Pac.countdown )
///
/// Major Sections:
/// 1. Game Start Flag & Level Completion Check
/// 2. Keyboard Input & Player Direction Setup
/// 3. Ghost Release Signatures & Timing
/// 4. Scatter/Chase Mode Initialization
/// 5. Fruit Setup & Level-Specific Configuration
/// 6. Game State Readiness
/// ===============================================================================

/// ===============================================================================
/// SECTION 1: GAME START FLAG & LEVEL COMPLETION CHECK
/// ===============================================================================
/// Clear the start delay flag so gameplay can begin
global.start = 0;

/// Check if level is complete (all dots eaten)
/// Conditions: level exists, start completed, Pac alive, all dots eaten, level not already finishing
if (global.lvl > 0 && global.start == 0 && dead == PAC_STATE.ALIVE && Pac.dotcount == global.dottotal && Pac.finish == 0) {
    /// Level completed - trigger Pac.finish sequence
    Pac.finish = 1;
    alarm[11] = 60;  /// Trigger level completion handler in 60 frames

    /// Stop all ghosts
    Blinky.aboutface = 0;
    Pinky.aboutface = 0;
    Inky.aboutface = 0;
    Clyde.aboutface = 0;

    /// Freeze all actors (ghosts and Pac)
    Blinky.speed = 0;
    Pinky.speed = 0;
    Inky.speed = 0;
    Clyde.speed = 0;
    Pac.speed = 0;
} else {
    /// ===============================================================================
    /// SECTION 2: KEYBOARD INPUT & PLAYER DIRECTION SETUP
    /// ===============================================================================
    /// Initialize ambience sound
    ambience = -1;

    /// PLAYER 1 INPUT
    if (keyboard_check(vk_right) == true) {
        dir = PAC_DIRECTION.RIGHT;
        hspeed = sp;
    } else {
        dir = PAC_DIRECTION.LEFT;
        hspeed = -sp;
    }
    vspeed = 0;


    /// Set Blinky (red ghost) initial movement
    with (Blinky) {
        hspeed = -sp;
        vspeed = 0;
    }

    /// Reset power pellet timers
    with (Power) {
        alarm[0] = 10;
    }

    /// ===============================================================================
    /// SECTION 3: GHOST RELEASE SIGNATURES & TIMING
    /// ===============================================================================
    /// On first startup, calculate ghost release timers based on level and game variant
    if (started == 0) {
        if (global.game < 2) {
            /// STANDARD PAC-MAN / MS. PAC-MAN
            /// Check if standard maze (height < 672) or extended maze
            if ((global.game < 2 && room_height < 672 && collision_point(0, 512, Wall, false, true)) ||
                (global.game == 2 && (room_width == 864 || room_width == 496))) {
                /// Standard maze: use base release times
                psig = 0;      /// Pinky released immediately
                isig = 30;     /// Inky released at 30 dots eaten
                csig = 90;     /// Clyde released at 90 dots eaten

                /// Level 2 and Plus Level 1: Inky and Clyde release together
                if (global.lvl == 2 || (global.plus == PAC_PLUS_MODE.ACTIVE && global.lvl == 1)) {
                    psig = 0;
                    isig = 0;
                    csig = 50;  /// Both release at 50 dots
                }

                /// Level 3+ and Plus Level 2+: All ghosts released immediately
                if (global.lvl > 2 || (global.plus == PAC_PLUS_MODE.ACTIVE && global.lvl > 1)) {
                    psig = 0;
                    isig = 0;
                    csig = 0;
                }
            } else {
                /// Extended maze: same logic but adjust for initial dot count
                psig = 0;
                isig = 30;
                csig = 90;

                if (global.lvl == 2 || (global.plus == PAC_PLUS_MODE.ACTIVE && global.lvl == 1)) {
                    psig = 0;
                    isig = 0;
                    csig = 50;
                }

                if (global.lvl > 2 || (global.plus == PAC_PLUS_MODE.ACTIVE && global.lvl > 1)) {
                    psig = 0;
                    isig = 0;
                    csig = 0;
                }

                /// Adjust for dots already eaten
                psig = psig + Pac.dotcount;
                isig = isig + Pac.dotcount;
                csig = csig + Pac.dotcount;
            }
        } else {
            /// JR. PAC-MAN (game == 2)
            psig = 0 + Pac.dotcount;      /// Pinky released immediately
            isig = 0 + Pac.dotcount;      /// Inky released immediately
            csig = 50 + Pac.dotcount;     /// Clyde released at 50 dots

            /// Level 2+: All ghosts released immediately
            if (global.lvl > 1 || global.plus == PAC_PLUS_MODE.ACTIVE) {
                psig = 0 + Pac.dotcount;
                isig = 0 + Pac.dotcount;
                csig = 0 + Pac.dotcount;
            }
        }

        /// Mark startup complete so this only runs once per level
        started = 1;
    }

    /// ===============================================================================
    /// SECTION 4: SCATTER/CHASE MODE INITIALIZATION
    /// ===============================================================================
    /// Begin first scatter mode phase with calculated duration
    alarm[1] = scatter1 * 60;

    /// ===============================================================================
    /// SECTION 5: SLOWDOWN EFFECT CLEANUP (MS. PAC-MAN SPECIFIC)
    /// ===============================================================================
    /// In Ms. Pac-Man, destroy slowdown effects after level 3
    if (global.game == 1 && global.lvl > 3) {
        with (Slow) {
            instance_destroy();
        }
    }

    /// ===============================================================================
    /// SECTION 6: FRUIT SETUP BY LEVEL & GAME VARIANT
    /// ===============================================================================
    /// Initialize fruit sprite, position, and point values
    with (Fruit) {
        /// Reset fruit state variables
        points = 0;
        x = -32;
        y = -32;
        dir = 0;
        exopt = -1;
        state = -1;
        newtile = 0;
        tilex = 16 * (round(x / 16));
        tiley = 16 * (round(y / 16));
        resdir = -1;
        up = 1;
        bounce = 0;
        chasex = 0;
        chasey = 0;
        explosion = 0;
        im = 0;
        expx = 0;
        expy = 0;
        image_speed = 0;

        /// ===============================================================================
        /// FRUIT ASSIGNMENT: STANDARD MODE (global.plus = 0)
        /// ===============================================================================
        if (global.plus == PAC_PLUS_MODE.INACTIVE) {
            /// ===============================================================================
            /// STANDARD PAC-MAN FRUITS (game = 0)
            /// ===============================================================================
            if (global.game == 0) {
                if (global.lvl == 0) { image_index = 0; value = 0; }
                if (global.lvl == 1) { image_index = 0; value = 0; }           /// Cherry
                if (global.lvl == 2) { image_index = 1; value = 1; }           /// Strawberry
                if (global.lvl == 3) { image_index = 2; value = 2; }           /// Peach
                if (global.lvl == 4) { image_index = 2; value = 2; }           /// Peach
                if (global.lvl == 5) { image_index = 3; value = 3; }           /// Pretzel
                if (global.lvl == 6) { image_index = 3; value = 3; }           /// Pretzel
                if (global.lvl == 7) { image_index = 4; value = 4; }           /// Apple
                if (global.lvl == 8) { image_index = 4; value = 4; }           /// Apple
                if (global.lvl == 9) { image_index = 5; value = 5; }           /// Pineapple
                if (global.lvl == 10) { image_index = 5; value = 5; }          /// Pineapple
                if (global.lvl == 11) { image_index = 6; value = 6; }          /// Galaxian
                if (global.lvl == 12) { image_index = 6; value = 6; }          /// Galaxian
                if (global.lvl > 12) { image_index = 7; value = 7; }           /// Bell (levels 13+)
            }

            /// ===============================================================================
            /// MS. PAC-MAN FRUITS (game = 1) - STANDARD MODE
            /// ===============================================================================
            if (global.game == 1) {
                if (global.lvl == 0) { image_index = 0; value = 0; }
                if (global.lvl == 1) { image_index = 0; value = 0; }           /// Cherry
                if (global.lvl == 2) { image_index = 1; value = 1; }           /// Strawberry
                if (global.lvl == 3) { image_index = 2; value = 2; }           /// Orange
                if (global.lvl == 4) { image_index = 8; value = 3; }           /// Pretzel
                if (global.lvl == 5) { image_index = 3; value = 4; }           /// Apple
                if (global.lvl == 6) { image_index = 9; value = 5; }           /// Pear
                if (global.lvl == 7) { image_index = 10; value = 6; }          /// Banana
            }

            /// ===============================================================================
            /// JR. PAC-MAN FRUITS (game = 2) - STANDARD MODE
            /// ===============================================================================
            if (global.game == 2) {
                if (global.lvl == 0) { image_index = 17; value = 0; }
                if (global.lvl == 1) { image_index = 17; value = 0; }
                if (global.lvl == 2) { image_index = 18; value = 1; }
                if (global.lvl == 3) { image_index = 19; value = 2; }
                if (global.lvl == 4) { image_index = 20; value = 3; }
                if (global.lvl == 5) { image_index = 21; value = 4; }
                if (global.lvl == 6) { image_index = 22; value = 5; }
                if (global.lvl > 6) { image_index = 23; value = 6; }
            }
        } else {
            /// ===============================================================================
            /// FRUIT ASSIGNMENT: PLUS MODE (global.plus = 1)
            /// ===============================================================================
            /// STANDARD PAC-MAN PLUS FRUITS (game = 0)
            if (global.game == 0) {
                if (global.lvl == 0) { image_index = 11; value = 0; }
                if (global.lvl == 1) { image_index = 11; value = 0; }          /// Cherry
                if (global.lvl == 2) { image_index = 12; value = 1; }          /// Strawberry
                if (global.lvl == 3) { image_index = 13; value = 2; }          /// Peach
                if (global.lvl == 4) { image_index = 13; value = 2; }          /// Peach
                if (global.lvl == 5) { image_index = 3; value = 3; }           /// Pretzel
                if (global.lvl == 6) { image_index = 3; value = 3; }           /// Pretzel
                if (global.lvl == 7) { image_index = 14; value = 4; }          /// Apple
                if (global.lvl == 8) { image_index = 14; value = 4; }          /// Apple
                if (global.lvl == 9) { image_index = 5; value = 5; }           /// Pineapple
                if (global.lvl == 10) { image_index = 5; value = 5; }          /// Pineapple
                if (global.lvl == 11) { image_index = 16; value = 6; }         /// Galaxian
                if (global.lvl == 12) { image_index = 16; value = 6; }         /// Galaxian
                if (global.lvl > 12) { image_index = 17; value = 7; }          /// Bell (levels 13+)
            }

            /// ===============================================================================
            /// MS. PAC-MAN PLUS FRUITS (game = 1)
            /// ===============================================================================
            if (global.game == 1) {
                if (global.lvl == 0) { image_index = 24; value = 0; }
                if (global.lvl == 1) { image_index = 24; value = 0; }          /// Cherry
                if (global.lvl == 2) { image_index = 25; value = 1; }          /// Strawberry
                if (global.lvl == 3) { image_index = 26; value = 2; }          /// Orange
                if (global.lvl == 4) { image_index = 27; value = 3; }          /// Pretzel
                if (global.lvl == 5) { image_index = 28; value = 4; }          /// Apple
                if (global.lvl == 6) { image_index = 29; value = 5; }          /// Pear
                if (global.lvl == 7) { image_index = 30; value = 6; }          /// Banana
            }

            /// ===============================================================================
            /// JR. PAC-MAN PLUS FRUITS (game = 2)
            /// ===============================================================================
            if (global.game == 2) {
                if (global.lvl == 0) { image_index = 31; value = 0; }
                if (global.lvl == 1) { image_index = 31; value = 0; }
                if (global.lvl == 2) { image_index = 32; value = 1; }
                if (global.lvl == 3) { image_index = 33; value = 2; }
                if (global.lvl == 4) { image_index = 34; value = 3; }
                if (global.lvl == 5) { image_index = 35; value = 4; }
                if (global.lvl == 6) { image_index = 36; value = 5; }
                if (global.lvl > 6) { image_index = 37; value = 6; }
            }
        }
    }
}
