/// ===============================================================================
/// ALARM_1 - SCATTER/CHASE MODE CYCLE MANAGEMENT
/// ===============================================================================
/// Purpose: Cycle through 7 different scatter/chase mode timing phases
/// Called: Every time a scatter/chase phase expires
///
/// Triggers:
/// - Advance to next cycle phase (1-7)
/// - Signal all ghosts to reverse direction (aboutface = 1)
/// - Switch between SCATTER and CHASE modes based on cycle phase
/// - Set duration for next phase based on timing tables (scatter1, chase1, etc)
/// - Reset to chase mode indefinitely after cycle 7
///
/// Cycle Phases:
/// 1 = Chase Mode 1 (chase1 duration)
/// 2 = Scatter Mode 2 (scatter2 duration, conditional on non-extended maze)
/// 3 = Chase Mode 2 (chase2 duration)
/// 4 = Scatter Mode 3 (scatter3 duration)
/// 5 = Chase Mode 3 (chase3 duration)
/// 6 = Scatter Mode 4 (scatter4 duration)
/// 7+ = Chase Mode (indefinite)
/// ===============================================================================

/// Advance to next cycle phase
cycle = cycle + 1;

/// Signal all ghosts to reverse direction and pick new targets
with (Blinky) {
    aboutface = 1;
}

with (Pinky) {
    aboutface = 1;
}

with (Inky) {
    aboutface = 1;
}

with (Clyde) {
    aboutface = 1;
}

/// PHASE 1: First Chase Mode
if (cycle == 1) {
    alarm[1] = chase1 * 60;
    scatter = 0;
    exit;
}

/// PHASE 2: Scatter Mode 2 (conditional on standard maze)
if (cycle == 2) {
    if (global.ex1 == 0 && room_width == 448) {
        alarm[1] = scatter2 * 60;
        scatter = 1;
    }
    exit;
}

/// PHASE 3: Second Chase Mode
if (cycle == 3) {
    alarm[1] = chase2 * 60;
    scatter = 0;
    exit;
}

/// PHASE 4: Third Scatter Mode
if (cycle == 4) {
    alarm[1] = scatter3 * 60;
    scatter = 1;
    exit;
}

/// PHASE 5: Third Chase Mode
if (cycle == 5) {
    alarm[1] = chase3 * 60;
    scatter = 0;
    exit;
}

/// PHASE 6: Fourth Scatter Mode
if (cycle == 6) {
    alarm[1] = scatter4 * 60;
    scatter = 1;
    exit;
}

/// PHASE 7+: Indefinite Chase Mode
if (cycle == 7) {
    scatter = 0;
    exit;
}


