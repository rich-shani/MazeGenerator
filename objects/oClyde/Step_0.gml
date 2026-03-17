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
	/// CHASE: Clyde changes behavior based on distance to Pac
	/// Close = flee, far = chase (ambiguous personality)

	// Calculate distance from Clyde to Pac
	var _distance = point_distance(x, y, oPacman.x, oPacman.y);

	if (_distance < 128) {
		// Too close! Pac is threatening, flee to scatter corner
		// Scatter corner for Clyde is bottom-right of maze
		pursuex = cornerx;  // Set in Clyde's Create event
		pursuey = cornery;
	}
	else {
		// Safe distance, pursue normally like Blinky
		pursuex = 16 * round(oPacman.x / 16);
		pursuey = 16 * round(oPacman.y / 16);
	}
}

/// ===============================================================================
/// PINKY'S BEHAVIOR NOTES
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
