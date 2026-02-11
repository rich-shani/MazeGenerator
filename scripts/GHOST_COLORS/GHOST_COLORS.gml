/// ===============================================================================
/// GHOST COLOR SYSTEM
/// ===============================================================================
/// Purpose: Define ghost colors and provide functions for sprite rendering
/// Usage: Use color functions instead of hardcoding color values
///
/// Benefits:
/// - Centralized color definitions (change all Blinky colors in one place)
/// - Easy to adjust RGB values
/// - Readable code (ghost_color_blinky() vs make_color_rgb(255,0,0))
/// - Supports theme changes (dark mode, accessibility colors, etc.)
/// ===============================================================================

/// ===============================================================================
/// GHOST COLOR DEFINITIONS
/// ===============================================================================

/// @function ghost_color_blinky()
/// @description Get the primary color for Blinky (Red Ghost - Shadow)
/// @return {real} - Color value in GML color format
/// Standard Pac-Man: Bright red (255, 0, 0)
/// This is Blinky's primary chase/scatter color

function ghost_color_blinky() {
    return make_color_rgb(255, 0, 0);  // Bright Red
}

/// @function ghost_color_pinky()
/// @description Get the primary color for Pinky (Pink Ghost - Speedy)
/// @return {real} - Color value in GML color format
/// Standard Pac-Man: Pink (255, 184, 255)
/// This is Pinky's primary chase/scatter color

function ghost_color_pinky() {
    return make_color_rgb(255, 184, 255);  // Pink
}

/// @function ghost_color_inky()
/// @description Get the primary color for Inky (Cyan Ghost - Bashful)
/// @return {real} - Color value in GML color format
/// Standard Pac-Man: Cyan/Light Blue (0, 255, 255)
/// This is Inky's primary chase/scatter color

function ghost_color_inky() {
    return make_color_rgb(0, 255, 255);  // Cyan
}

/// @function ghost_color_clyde()
/// @description Get the primary color for Clyde (Orange Ghost - Pokey)
/// @return {real} - Color value in GML color format
/// Standard Pac-Man: Orange (255, 184, 82)
/// This is Clyde's primary chase/scatter color

function ghost_color_clyde() {
    return make_color_rgb(255, 184, 82);  // Orange
}

/// ===============================================================================
/// SPECIAL STATE COLORS
/// ===============================================================================

/// @function ghost_color_frightened()
/// @description Get the color for frightened/vulnerable ghosts
/// @return {real} - Color value in GML color format
/// All ghosts turn blue when a power pellet is active
/// This color fades to white near the end of the power pellet duration

function ghost_color_frightened() {
    return make_color_rgb(33, 33, 222);  // Dark Blue
}

/// @function ghost_color_frightened_flash()
/// @description Get the color for frightened ghosts near end of power pellet
/// @return {real} - Color value in GML color format
/// Ghosts flash between dark blue and white to signal danger is ending

function ghost_color_frightened_flash() {
    return make_color_rgb(255, 255, 255);  // White
}

/// @function ghost_color_eyes()
/// @description Get the color for ghost eyes (both normal and vulnerable modes)
/// @return {real} - Color value in GML color format
/// Eyes are always white regardless of ghost color or state

function ghost_color_eyes() {
    return make_color_rgb(255, 255, 255);  // White
}

/// ===============================================================================
/// UTILITY FUNCTIONS
/// ===============================================================================

/// @function ghost_get_color(_ghost_name)
/// @description Get the color for any ghost by name
/// @param {string} _ghost_name - Ghost name ("Blinky", "Pinky", "Inky", or "Clyde")
/// @return {real} - Color value in GML color format
/// @example
///   draw_color = ghost_get_color("Blinky");
///   draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, draw_color, 1);

function ghost_get_color(_ghost_name) {
    switch (_ghost_name) {
        case "Blinky":
            return ghost_color_blinky();
        case "Pinky":
            return ghost_color_pinky();
        case "Inky":
            return ghost_color_inky();
        case "Clyde":
            return ghost_color_clyde();
        default:
            return c_white;  // Fallback to white if unknown
    }
}

/// @function ghost_get_color_by_object(_obj)
/// @description Get the color for a ghost object instance
/// @param {object} _obj - Ghost object instance (Blinky, Pinky, Inky, or Clyde)
/// @return {real} - Color value in GML color format
/// Works with object type checking or name property
/// @example
///   draw_color = ghost_get_color_by_object(Blinky);

function ghost_get_color_by_object(_obj) {
    if (_obj == Blinky) return ghost_color_blinky();
    if (_obj == Pinky) return ghost_color_pinky();
    if (_obj == Inky) return ghost_color_inky();
    if (_obj == Clyde) return ghost_color_clyde();
    return c_white;  // Fallback
}

/// ===============================================================================
/// COLOR RENDERING HELPERS
/// ===============================================================================

/// @function draw_ghost_sprite(_sprite, _subimg, _x, _y, _state)
/// @description Draw a ghost sprite with appropriate coloring based on state
/// @param {real} _sprite - Sprite index
/// @param {real} _subimg - Subimage/animation frame
/// @param {real} _x - X position to draw at
/// @param {real} _y - Y position to draw at
/// @param {real} _state - Ghost state (GHOST_STATE enum)
/// @param {real} _color - Ghost's primary color
/// @param {real} _flash - Flash counter (for frightened flashing effect)
///
/// This function handles all the color logic for different ghost states:
/// - CHASE: Draw with ghost's primary color
/// - FRIGHTENED: Draw with blue, flash white near end
/// - EYES: Only draw eyes (handled separately in object)

function draw_ghost_sprite(_sprite, _subimg, _x, _y, _state, _color, _flash) {
    var _draw_color = _color;
    var _alpha = 1;

    switch (_state) {
        case GHOST_STATE.CHASE:
            // Normal mode: draw with ghost's natural color
            _draw_color = _color;
            break;

        case GHOST_STATE.FRIGHTENED:
            // Frightened mode: blue with white flashing
            if (_flash > 15) {
                _draw_color = ghost_color_frightened();
            } else {
                _draw_color = ghost_color_frightened_flash();
            }
            break;

        case GHOST_STATE.EYES:
            // Eyes only: drawn separately, skip body
            return;  // Don't draw body in eyes mode
            //break;

        case GHOST_STATE.IN_HOUSE:
            // In house: draw with normal color while exiting
            _draw_color = _color;
            break;
    }

    // Draw the sprite with calculated color
    draw_sprite_ext(
        _sprite,           // Sprite index
        _subimg,           // Animation frame
        _x,                // X position
        _y,                // Y position
        1,                 // X scale (1 = normal size)
        1,                 // Y scale (1 = normal size)
        0,                 // Rotation (0 = no rotation)
        _draw_color,       // Color tint
        _alpha             // Alpha (1 = fully opaque)
    );
}

/// ===============================================================================
/// END GHOST COLOR SYSTEM
/// ===============================================================================
