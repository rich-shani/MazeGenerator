/// ===============================================================================
/// oGHOST - BASE GHOST OBJECT - ALARM_0 EVENT
/// ===============================================================================
/// Purpose: Handle response when Pac eats a power pellet
/// Triggered: When Pac.alarm[0] is set (in Pac object)
/// Logic: Reverse direction for all non-in-house ghosts
///
/// When Pac eats a power pellet:
/// 1. Alarm_0 is triggered for all ghosts
/// 2. Ghosts not in house (house=0) reverse direction (180°)
/// 3. Ghosts in states CHASE or FRIGHTENED are affected
/// 4. Eyes and IN_HOUSE ghosts are NOT affected (already fleeing/returning)
///
/// The reversal creates the illusion of ghosts being "startled" by power pellet
/// and is a key part of Pac-Man AI behavior
/// ===============================================================================

/// ===== HANDLE TWO SCENARIOS =====
/// 1. Power pellet eaten: reverse direction for all free ghosts
/// 2. Ghost eaten: set eaten ghost to Eyes state (state=2)

/// Check if this ghost was just eaten
if (chomped == 1) {
    /// This ghost was just eaten by Pac
    /// Transition to Eyes state so ghost returns to house
    Pac.chomp = 0;  /// Reset Pac's chomp animation flag (eaten ghost - animation done)
    state = GHOST_STATE.EYES;

    /// Reverse direction by 180° (running away)
    direction = resdir * 90;

    /// Reset pathfinding
    newtile = 0;

    /// Clear chomped flag
    chomped = 0;
}
else if (house == 0 && state < GHOST_STATE.EYES) {
    /// Power pellet eaten: reverse direction for free ghosts
    /// Ghost is free (not in house) and not already dead
    /// CHASE (0) and FRIGHTENED (1) states are affected
    /// EYES (2) and higher are NOT affected

    /// Reverse direction by 180°
    direction = resdir * 90;
    /// resdir starts at 2 (LEFT), multiplied by 90 = 180
    /// This flips direction exactly 180°

    /// Also reset newtile to force immediate pathfinding update
    /// This allows ghosts to pick new target right away
    newtile = 0;
}

/// Note: This event is called for every ghost instance when Pac eats power pellet
/// See Pac object for the trigger: "with oGhost { alarm[0] = <value>; }"

/// ===============================================================================
/// END oGHOST ALARM_0 EVENT
/// ===============================================================================
