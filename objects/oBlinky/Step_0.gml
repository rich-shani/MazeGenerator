/// ===============================================================================
/// BLINKY GHOST - STEP_0 EVENT (TARGET CALCULATION - DIRECT CHASE)
/// ===============================================================================
/// Purpose: Calculate Blinky's target position using direct chase strategy
/// Called: Every frame (second step event, after Begin_Step animation)
/// Parent: oGhost (inherits base ghost behavior)
///
/// Blinky's Personality: "Shadow" - Direct Chaser (Fearless Leader)
/// Strategy: Blinky directly chases Pac's current position (no prediction)
/// This makes Blinky the most straightforward threat - he's always coming straight at you
///
/// Single-Player Support:
/// Blinky directly chases Pac's current position
///
/// Algorithm:
/// 1. Calculate Player 1 (Pac) grid position
/// 2. Set pursuex/pursuey to Pac's grid position
///
/// This is the simplest ghost AI - just "go toward Pac"
/// ===============================================================================

/// ===== INHERIT BASE GHOST BEHAVIOR =====
/// Call parent Step_0 event to handle animation, flashing, and tile tracking
/// This ensures Blinky gets all the base ghost functionality
event_inherited();

/// ===== CHASE MODE TARGET CALCULATION =====
/// Blinky's chase strategy: Direct pursuit to Pac's current position
/// No prediction, no ambush - just straight-line pursuit
if (state == GHOST_STATE.CHASE) {
    /// CHASE MODE: Hunt Pac using direct chase strategy
    
    /// Calculate Player 1 (Pac) grid position
    /// Snap to 16-pixel grid for pathfinding accuracy
    var _pac_tile_x = 16 * round(oPacman.x / 16);
    var _pac_tile_y = 16 * round(oPacman.y / 16);
    
    /// Set target to Pac's position (direct chase)
    pursuex = _pac_tile_x;
    pursuey = _pac_tile_y;
    
    /// Note: In scatter mode (when Pac.scatter == 1), the pathfinding script
    /// in Step_2 will override this target and chase the scatter corner instead.
    /// This direct chase target is only used during normal chase mode.
}

/// ===============================================================================
/// BLINKY'S BEHAVIOR NOTES
/// ===============================================================================
/// Blinky is the "leader" ghost - he directly chases Pac without prediction.
/// This makes Blinky the most straightforward threat:
/// - No ambush tactics (unlike Pinky)
/// - No geometric calculations (unlike Inky)
/// - No distance-based switching (unlike Clyde)
/// - Just pure, direct pursuit
///
/// Blinky's behavior in other states:
/// - FRIGHTENED mode: Random movement (handled by parent Step_1)
/// - EYES mode: Target house entrance (handled by parent Step_1)
/// - IN_HOUSE mode: House exit sequence (handled by parent Step_2)
///
/// ===============================================================================
/// END BLINKY STEP_0 EVENT
/// ===============================================================================
