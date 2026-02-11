/// ===============================================================================
/// oGHOST - BASE GHOST OBJECT - DRAW_0 EVENT
/// ===============================================================================
/// Purpose: Render ghost sprite with state-aware coloring
/// Called: Every frame during draw phase
/// Parent: oGhost
///
/// Rendering features:
/// 1. State-aware coloring (chase/frightened/eyes modes)
/// 2. Animation frame support (using 'im' variable from Step_0)
/// 3. Sprite selection based on game mode and effects
/// 4. Wraparound rendering (ghost drawn at multiple Y positions if wrapped)
/// 5. Eyes separate from body
/// 6. Flashing effect in frightened mode
///
/// Child ghosts override this to set their own colors via ghost_get_color()
/// ===============================================================================

// ===== DETERMINE DRAW COLOR BASED ON STATE =====
/// Color depends on current ghost state
var _draw_color = c_white;

switch (state) {
    case GHOST_STATE.CHASE:
        /// Normal mode: use ghost's primary color
        /// Child objects set this color (Blinky=red, Pinky=pink, etc.)
        _draw_color = ghost_get_color(ghost_name);
        break;

    case GHOST_STATE.FRIGHTENED:
        /// Power pellet mode: blue with white flashing
        if (!visible) {
            _draw_color = c_white;  // White (flashing)
        } else {
            _draw_color = ghost_color_frightened();  // Dark blue
        }
        break;

    case GHOST_STATE.EYES:
        /// Eyes mode: only draw eyes (white), skip body
        /// Body rendering skipped below
        _draw_color = ghost_color_eyes();
        break;

    case GHOST_STATE.IN_HOUSE:
        /// In house: draw with normal color while exiting
        _draw_color = draw_color;
        break;

    default:
        _draw_color = draw_color;
}

// ===== DETERMINE SPRITE INDEX =====
/// Different sprites for different game modes
/// Game mode affects which sprite set is used

var _spr = spr_Ghost;  // Default placeholder

/// Child ghosts override draw event to set correct sprite

// ===== DRAW MAIN BODY (Skip in EYES mode) =====
if (state != GHOST_STATE.EYES) {
    /// Draw ghost body sprite
    /// Position: x, y (already set by physics)
    /// Sprite frame: im (animation frame from Step_0)
    /// Color: based on state (calculated above)
    /// Scale: 1x (normal size)
    /// Rotation: 0 (no rotation)

    // Draw at current position
    draw_sprite_ext(
        _spr,              // Sprite index
        floor(im/8),		// Animation frame (0-15)
        x, y,              // Position
        1, 1,              // Scale (1x = normal)
        0,                 // Rotation
        _draw_color,       // Color tint
        1                  // Alpha (1 = fully opaque)
    );
}

if (state == GHOST_STATE.FRIGHTENED) {
	// ===== DRAW EYES =====
	/// Eyes are drawn separately from body
	/// Eyes use dedicated sprite with white color
	var eye_offset = (visible ? 0:1);
	draw_sprite(spr_Eyes, 4+eye_offset, x, y);	
}
else {
	// ===== DRAW EYES =====
	/// Eyes are drawn separately from body
	/// Eyes use dedicated sprite with white color
	draw_sprite(spr_Eyes, dir, x, y);
}

//var _eye_spr = spr_Eyes;  // Eyes sprite (same for all ghosts)

//// Draw eyes at current position
//draw_sprite_ext(
//    _eye_spr,          // Eyes sprite
//    im,                // Animation frame (same as body)
//    x, y,              // Position
//    1, 1,              // Scale
//    0,                 // Rotation
//    ghost_color_eyes(), // Always white
//    1                  // Alpha
//);

//// Wraparound rendering for eyes
//if (y < 64) {
//    draw_sprite_ext(_eye_spr, im, x, y + 512, 1, 1, 0, ghost_color_eyes(), 1);
//}

//if (y > room_height - 64) {
//    draw_sprite_ext(_eye_spr, im, x, y - 512, 1, 1, 0, ghost_color_eyes(), 1);
//}

// ===== ELROY INDICATOR (Optional Debug/Visual) =====
/// Show visual indicator when in Elroy mode (faster pursuit)
/// This can be:
/// - Changed eye color (red instead of white)
/// - Additional sprite overlay
/// - Or completely omitted (set show_debug_messages = false)

if (elroy > 0 && state == GHOST_STATE.CHASE) {
    /// Ghost in Elroy mode: optionally draw indicator
    /// Could draw red eyes, glow effect, etc.
    /// For now, this is handled by eye color change in actual sprites
}

/// ===============================================================================
/// HOW CHILD GHOSTS OVERRIDE THIS EVENT
/// ===============================================================================
/// Each child ghost overrides to set the correct color and sprites.
///
/// Example - Blinky's Draw_0.gml override:
/// ────────────────────────────────────────────────────────────────────
/// _draw_color = ghost_color_blinky();  // Red
/// _spr = spr_BlinkyGhost;               // Blinky sprite
/// event_inherited();                    // Call parent draw logic
///
/// Example - Pinky's Draw_0.gml override:
/// ────────────────────────────────────────────────────────────────────
/// _draw_color = ghost_color_pinky();   // Pink
/// _spr = spr_PinkyGhost;                // Pinky sprite
/// event_inherited();                    // Call parent draw logic
///
/// ===============================================================================

/// ===============================================================================
/// END oGHOST DRAW_0 EVENT
/// ===============================================================================
