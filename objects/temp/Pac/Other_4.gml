/// ===============================================================================
/// PAC OBJECT - ROOM INITIALIZATION (PLAYER-SPECIFIC)
/// ===============================================================================
/// Purpose: Initialize Pacman character variables when entering a room/level
/// Called: Room Start event (once per level)
///
/// Note: Game-wide state management (level progression, speed configuration,
/// fright timings, ghost AI cycles, etc.) is now handled by oGameManager
///
/// This event only handles Pacman character-specific initialization
/// ===============================================================================

/// ===============================================================================
/// SECTION 1: PLAYER POSITIONING (SINGLE VS TWO-PLAYER)
/// ===============================================================================
/// In two-player mode with both players alive, position them apart
if (global.players > 0 && global.players < 3 && global.p1lives > 0 && global.p2lives > 0) {
    /// Both players alive: position Player 1 left, Player 2 right
    x = xstart - 16;
    y = ystart;

    x2 = xstart + 16;
    y2 = ystart;
} else {
    /// Single player or one player dead
    if (global.p1lives > 0 || global.lvl == 0) {
        /// Player 1 takes center, Player 2 off-screen
        x = xstart;
        y = ystart;
        x2 = -5000;
        y2 = ystart;
    } else {
        /// Player 1 dead, Player 2 takes center
        x2 = xstart;
        y2 = ystart;
        x = -5000;
        y = ystart;
    }
}

/// ===============================================================================
/// SECTION 2: ANIMATION & STATE INITIALIZATION
/// ===============================================================================
/// Reset last player indicator
global.last = 0;

/// Create pause manager instance
instance_create(0, 0, Pauser);

/// Reset corner transition state
cornercheck = 0;

/// Animation scaling
scale = 1;
scaleup = 1;

/// Initial direction (LEFT = 2)
dir = PAC_DIRECTION.LEFT;

/// Park position tracking
park = -1;

/// Eating animation direction
eatdir = -1;

/// Corner state (0 = no corner transition)
corner = 0;

/// Game start flag
started = 0;

/// Stop flag for collisions
stoppy = 0;

/// ===============================================================================
/// SECTION 3: ANIMATION FRAME INITIALIZATION
/// ===============================================================================
/// Animation frame counters
im = 0;     /// Image index for Player 1
im2 = 0;    /// Image index for Player 2

/// Pause state
pause = 0;

/// Chomp sound counter
chomp = 0;

/// ===============================================================================
/// SECTION 4: MOVEMENT INITIALIZATION
/// ===============================================================================
/// Direction tracking for movement
xdir = -32;
ydir = 0;

/// Initial movement (LEFT at normal speed)
/// Note: Speed values (sp, spfright) are managed by oGameManager
hspeed = -sp;
vspeed = 0;

/// Ghost release signatures
psig = 244;
isig = 244;
csig = 244;

/// Direction change timer
timerstart = 240;
timer = timerstart;

/// ===============================================================================
/// SECTION 5: TILE & DEATH STATE INITIALIZATION
/// ===============================================================================
test = 0;

/// Tile-based position tracking (16x16 grid alignment)
newtile = 0;
tilex = 16 * (round(x / 16));
tiley = 16 * (round(y / 16));

/// Death state tracking
dead = PAC_STATE.ALIVE;
deadanim = 0;

/// Set up level initialization timing
alarm[10] = 90;

/// Play game start sound and setup timing based on game variant
if (global.start == true) {
    alarm[9] = 120;

    /// Play appropriate start sound for game variant
    if (global.game == 0) {
        sound_play(Start);
        alarm[10] = 250;
    }
    if (global.game == 1) {
        sound_play(MsStart);
        alarm[10] = 250;
    }
    if (global.game == 2) {
        sound_play(JrStart);
        alarm[10] = 275;
    }
}
/// ===============================================================================
/// GAME MANAGER - ROOM INITIALIZATION
/// ===============================================================================
/// Purpose: Initialize game state variables when entering a room/level
/// Called: Room Start event (once per level)
///
/// Major Sections:
/// 1. Level Progression & Dot Totals
/// 2. Speed Configuration (Level & Game Variant)
/// 3. Fright Mode Timing Tables
/// 4. Ghost Release & Cycle Timings
/// 5. Game State Initialization
/// ===============================================================================

/// ===============================================================================
/// SECTION 1: LEVEL PROGRESSION & DOT TOTALS
/// ===============================================================================
/// Increment level number if player(s) still have lives
if (global.p1lives > 0 || global.p2lives > 0) {
    global.lvl = global.lvl + 1;
}

/// Calculate total dots/pellets in this level for completion detection
global.dottotal = (instance_number(Dot) + instance_number(Power));

/// ===============================================================================
/// SECTION 2: SPEED CONFIGURATION (LEVEL & GAME VARIANT)
/// ===============================================================================

/// PLUS MODE SPEEDS (Ms. Pac-Man Plus / Jr. Pac-Man)
if (global.plus == PAC_PLUS_MODE.ACTIVE) {
    sp = 2.5;
    spfright = 2.5;

    if (global.game < 2 && global.lvl > 15) {
        sp = 2.25;
        spfright = 2.375;
    }
    if (global.game == 2 && global.lvl > 12) {
        sp = 2.25;
        spfright = 2.375;
    }
} else {
    /// STANDARD MODE SPEEDS
    if (global.game < 2) {
        sp = 2.00001;
        spfright = 2.25;

        if (global.lvl > 1) {
            sp = 2.25;
            spfright = 2.375;
        }
        if (global.lvl > 4) {
            sp = 2.5;
            spfright = 2.5;
        }
        if (global.lvl > 20) {
            sp = 2.25;
            spfright = 2.375;
        }
    } else {
        /// Jr. Pac-Man standard mode
        sp = 2.25;
        spfright = 2.375;

        if (global.lvl > 2) {
            sp = 2.5;
            spfright = 2.5;
        }
        if (global.lvl > 15) {
            sp = 2.25;
            spfright = 2.375;
        }
    }
}

/// BOOST MODE OVERRIDE
if (global.boost > 0) {
    sp = 4;
    spfright = 4;
}

/// ===============================================================================
/// SECTION 3: FRIGHT MODE TIMING TABLES
/// ===============================================================================
fright = PAC_FRIGHT.OFF;

/// STANDARD AND MS. PAC-MAN FRIGHT TIMINGS
if (global.plus == PAC_PLUS_MODE.INACTIVE) {
    if (global.game < 2) {
        Pac.frighttime = 360;

        if (global.lvl == 2) Pac.frighttime = 300;
        if (global.lvl == 3) Pac.frighttime = 240;
        if (global.lvl == 4) Pac.frighttime = 180;
        if (global.lvl == 5) Pac.frighttime = 120;
        if (global.lvl == 6) Pac.frighttime = 300;
        if (global.lvl == 7) Pac.frighttime = 120;
        if (global.lvl == 8) Pac.frighttime = 120;
        if (global.lvl == 9) Pac.frighttime = 60;
        if (global.lvl == 10) Pac.frighttime = 300;
        if (global.lvl == 11) Pac.frighttime = 120;
        if (global.lvl == 12) Pac.frighttime = 60;
        if (global.lvl == 13) Pac.frighttime = 60;
        if (global.lvl == 14) Pac.frighttime = 180;
        if (global.lvl == 15) Pac.frighttime = 60;
        if (global.lvl == 16) Pac.frighttime = 60;
        if (global.lvl == 17) Pac.frighttime = 0;
        if (global.lvl == 18) Pac.frighttime = 60;
        if (global.lvl > 18) Pac.frighttime = 0;
    } else {
        /// Jr. Pac-Man
        Pac.frighttime = 360;

        if (global.lvl == 2) Pac.frighttime = 180;
        if (global.lvl == 3) Pac.frighttime = 120;
        if (global.lvl == 4) Pac.frighttime = 120;
        if (global.lvl == 5) Pac.frighttime = 120;
        if (global.lvl == 6) Pac.frighttime = 60;
        if (global.lvl == 7) Pac.frighttime = 60;
        if (global.lvl == 8) Pac.frighttime = 120;
        if (global.lvl == 9) Pac.frighttime = 60;
        if (global.lvl == 10) Pac.frighttime = 60;
        if (global.lvl == 11) Pac.frighttime = 60;
        if (global.lvl == 12) Pac.frighttime = 60;
        if (global.lvl == 13) Pac.frighttime = 60;
        if (global.lvl == 14) Pac.frighttime = 0;
        if (global.lvl == 15) Pac.frighttime = 60;
        if (global.lvl > 15) Pac.frighttime = 0;
    }
}

/// PLUS MODE FRIGHT TIMINGS
if (global.plus == PAC_PLUS_MODE.ACTIVE) {
    if (global.game < 2) {
        Pac.frighttime = 240;
        bonustime = 360;

        if (global.lvl == 2) { Pac.frighttime = 180; bonustime = 360; }
        if (global.lvl == 3) { Pac.frighttime = 120; bonustime = 300; }
        if (global.lvl == 4) { Pac.frighttime = 120; bonustime = 240; }
        if (global.lvl == 5) { Pac.frighttime = 120; bonustime = 180; }
        if (global.lvl == 6) { Pac.frighttime = 240; bonustime = 300; }
        if (global.lvl == 7) { Pac.frighttime = 120; bonustime = 180; }
        if (global.lvl == 8) { Pac.frighttime = 60; bonustime = 180; }
        if (global.lvl == 9) { Pac.frighttime = 60; bonustime = 120; }
        if (global.lvl == 10) { Pac.frighttime = 120; bonustime = 240; }
        if (global.lvl == 11) { Pac.frighttime = 60; bonustime = 120; }
        if (global.lvl == 12) { Pac.frighttime = 0; bonustime = 120; }
        if (global.lvl == 13) { Pac.frighttime = 0; bonustime = 120; }
        if (global.lvl == 14) { Pac.frighttime = 120; bonustime = 240; }
        if (global.lvl == 15) { Pac.frighttime = 0; bonustime = 120; }
        if (global.lvl == 16) { Pac.frighttime = 60; bonustime = 120; }
        if (global.lvl == 17) { Pac.frighttime = 0; bonustime = 120; }
        if (global.lvl == 18) { Pac.frighttime = 120; bonustime = 120; }
        if (global.lvl == 19) { Pac.frighttime = 0; bonustime = 60; }
        if (global.lvl > 19) { Pac.frighttime = 0; bonustime = 0; }
    } else {
        /// Jr. Pac-Man Plus
        Pac.frighttime = 240;
        bonustime = 360;

        if (global.lvl == 2) { Pac.frighttime = 120; bonustime = 240; }
        if (global.lvl == 3) { Pac.frighttime = 120; bonustime = 180; }
        if (global.lvl == 4) { Pac.frighttime = 120; bonustime = 180; }
        if (global.lvl == 5) { Pac.frighttime = 60; bonustime = 120; }
        if (global.lvl == 6) { Pac.frighttime = 60; bonustime = 120; }
        if (global.lvl == 7) { Pac.frighttime = 60; bonustime = 120; }
        if (global.lvl == 8) { Pac.frighttime = 0; bonustime = 60; }
        if (global.lvl == 9) { Pac.frighttime = 0; bonustime = 60; }
        if (global.lvl == 10) { Pac.frighttime = 60; bonustime = 120; }
        if (global.lvl == 11) { Pac.frighttime = 60; bonustime = 60; }
        if (global.lvl == 12) { Pac.frighttime = 0; bonustime = 60; }
        if (global.lvl > 12) { Pac.frighttime = 0; bonustime = 0; }
    }
}

/// ===============================================================================
/// SECTION 4: GAME STATE INITIALIZATION
/// ===============================================================================
dot = 0;
chompcount = 0;
pluseat  = 0;
start = 1;
finish = 0;
siren = 0;
ambience = 0;
plus = -1;
countdown  = 10;
blink = 0;

/// ===============================================================================
/// SECTION 5: GHOST RELEASE & MOVEMENT INITIALIZATION
/// ===============================================================================


/// Scatter/Chase mode cycle tracking
cycle = 0;
scatter = 1;

/// ===============================================================================
/// SECTION 6: SCATTER/CHASE TIMING CONFIGURATION
/// ===============================================================================
if (global.game < 2) {
    /// STANDARD PAC-MAN & MS. PAC-MAN
    scatter1 = 7;
    chase1 = 20;
    scatter2 = 7;
    chase2 = 20;
    scatter3 = 5;
    chase3 = 20;
    scatter4 = 5;

    if (global.lvl > 1) {
        scatter1 = 7;
        chase1 = 20;
        scatter2 = 7;
        chase2 = 20;
        scatter3 = 5;
        chase3 = 1033;
        scatter4 = 1 / 60;
    }

    if (global.lvl > 4 || global.plus == PAC_PLUS_MODE.ACTIVE) {
        scatter1 = 5;
        chase1 = 20;
        scatter2 = 5;
        chase2 = 20;
        scatter3 = 5;
        chase3 = 1037;
        scatter4 = 1 / 60;
    }
} else {
    /// JR. PAC-MAN
    scatter1 = 7;
    chase1 = 20;
    scatter2 = 7;
    chase2 = 20;
    scatter3 = 5;
    chase3 = 1033;
    scatter4 = 1 / 60;

    if (global.lvl > 2 || global.plus == PAC_PLUS_MODE.ACTIVE) {
        scatter1 = 5;
        chase1 = 20;
        scatter2 = 5;
        chase2 = 20;
        scatter3 = 5;
        chase3 = 1037;
        scatter4 = 1 / 60;
    }
}
