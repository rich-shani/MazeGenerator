/// ===============================================================================
/// KEYPRESS_16 (SHIFT KEY) - ADD CREDIT & MENU ACCESS
/// ===============================================================================
/// Purpose: Add one credit and return to menu (with special handling for ongoing games)
/// Called: When Shift key is pressed
///
/// Triggers:
/// - Increment credit counter
/// - Play credit sound effect
/// - If ongoing game with one player dead, trigger recovery Pac.countdown 
/// - At level 0, reset game mode and return to menu
/// ===============================================================================

/// Add one credit
global.credit += 1;

/// Play credit addition sound
action_sound(Credit, 0);

/// Check if one player is dead and game is in progress
if (((global.p1lives == 0 && global.p2gameover == 1) ||
     (global.p1gameover == 1 && global.p2lives == 0)) &&
    global.lvl > 0 && Pac.countdown  > -1) {
    /// Trigger recovery Pac.countdown 
    Pac.countdown  = 10;
    alarm[11] = 1;
}

/// Return to menu if at level 0 (title screen)
if (global.lvl == 0) {
    /// Reset all game modes and settings to defaults
    global.game = 0;        /// Standard Pac-Man
    global.plus = 0;        /// Standard mode (not Plus)
    global.rand = 0;        /// Fixed mazes (not random)
    global.mode = 0;        /// Default mode
    room_goto(rm_Menu);
}
