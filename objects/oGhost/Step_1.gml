/// ===============================================================================
/// oGHOST - BASE GHOST OBJECT - BEGIN_STEP EVENT
/// ===============================================================================
/// Purpose: Handle animation updates and common state management
/// Called: Every frame (first step event for ghosts)
/// Parent: oGhost
/// Dependencies: GHOST_STATE enum, flash counter from parent
///
/// This event handles:
/// 1. Animation frame updates (cycling through sprite frames)
/// 2. Frightened mode flashing effect
/// 3. Tile coordinate tracking
/// 4. Visibility management (for flashing effect)
///
/// This event runs BEFORE Step_1 and Step_2, so animation is always in sync
/// ===============================================================================

// ===== ANIMATION FRAME UPDATE =====
/// Animate sprite by cycling through frames 0-15 based on ghost state
/// Creates smooth walking animation for ghostlike movement
///
/// Animation logic:
/// - Frames 0-15 cycle smoothly (16 frames per full cycle)
/// - Cycle repeats every 16 frames (approximately every 267ms at 60fps)
/// - In eyes mode: animation frozen (eyes don't animate like body)
///
/// Technical note: image_speed is set to 0 in Create event
/// This forces MANUAL animation control (im variable) instead of automatic

if (state != GHOST_STATE.EYES) {
    /// Normal states (Chase, Frightened, In_House): Animate
    /// Ghost body walks/moves, so animate the sprite
    im = (im + 1) % 16;  // Increment frame counter, wrap at 16 (0-15 cycle)
}
else {
    /// Eyes mode: Frozen animation
    /// Eyes don't animate (no body to animate)
    /// Keep im at current value (effectively frozen)
}

// ===== FRIGHTENED MODE FLASHING EFFECT =====
/// Create visual warning when power pellet is about to expire
/// Ghost flashes between visible and invisible for visual feedback
///
/// Flashing mechanics:
/// - flash counter cycles 0-29 (30 frames per cycle)
/// - flash 0-14: Ghost visible (blue/dark frightened color)
/// - flash 15-29: Ghost invisible (appears to flash/wink out)
/// - Cycle repeats for continuous flashing effect
///
/// Flashing is only active near the END of power pellet
/// - First ~2 seconds: ghost stays visible (early in power pellet)
/// - Last ~2 seconds: ghost flashes on/off (warning effect)
/// - oPacman.alarm[0] tracks remaining frames (120 frames = ~2 seconds)

if (state == GHOST_STATE.FRIGHTENED) {
    /// Power pellet ACTIVE: Handle flashing

    // Increment flash counter for flashing animation
    flash = (flash + 1) % 30;  // Cycles 0-29 continuously

    // Check if power pellet is near expiration (less than 2 seconds left)
    if (oPacman.alarm[0] != -1 && oPacman.alarm[0] < 121) {
        /// FLASHING PHASE: Power pellet about to expire
        /// Create warning effect: ghost appears/disappears
        visible = (flash < 15);  // Visible for first 15 frames, invisible for next 15
        /// Result: Ghost flashes white/invisible alternating every ~250ms
    } else {
        /// STABLE PHASE: Power pellet has plenty of time left
        /// Ghost stays visible (no flashing) for steadier appearance
        visible = true;  // Always visible when time remaining > 2 seconds
    }
}
//else if (!visible) {
//    /// Non-frightened states (Chase, Eyes, In_House): Always visible
//    /// Ghost is not vulnerable, no need to flash
//    visible = true;
//    flash = 0;  // Reset flash counter when entering non-frightened state
//    /// (Ensures smooth transition when exiting frightened mode)
//}

// ===== TILE COORDINATE TRACKING =====
/// Update grid position for pathfinding and collision detection
/// Converts actual pixel position to 16-pixel grid coordinates
/// This is used by pathfinding scripts to determine valid moves
///
/// Why tile coordinates matter:
/// - Ghosts move on 16x16 pixel grid (standard Pacman maze)
/// - During movement, ghosts drift between grid cells due to speed
/// - Pathfinding needs GRID coordinates to determine directions
/// - tilex/tiley are snapped to grid; x/y are sub-pixel

tilex = TILE_PIXELS * round(x / TILE_PIXELS);
tiley = TILE_PIXELS * round(y / TILE_PIXELS);
/// Example: If x=217.5, tilex becomes 16*round(217.5/16) = 16*14 = 224

/// ===============================================================================
/// END oGHOST STEP_0 EVENT
/// ===============================================================================
