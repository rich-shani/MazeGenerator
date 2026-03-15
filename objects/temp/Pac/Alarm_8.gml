/// ===============================================================================
/// ALARM_8 - BLINK ANIMATION TIMER FOR LEVEL TRANSITIONS
/// ===============================================================================
/// Purpose: Cycle level transition Pac.blink animation frame every 14 frames
/// Called: During level transitions (every game frame after initial setup)
///
/// Triggers:
/// - Automatically re-triggers every 14 frames
/// - Increments Pac.blink counter to alternate animation state
/// - Resets counter after reaching maximum (2 frames)
/// ===============================================================================

if (global.lvl > 0) {
    /// Re-trigger this alarm in 14 frames for animation cycle
    alarm[8] = 14;

    /// Increment Pac.blink animation frame counter (0 or 1)
    Pac.blink = Pac.blink + 1;

    /// Reset to 0 when counter reaches 2 (wraps: 0 → 1 → 0 → 1...)
    if (Pac.blink == 2) {
        Pac.blink = 0;
    }
}

