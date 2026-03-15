/// ===============================================================================
/// PACMAN_INPUT_UTILS - Movement Validation Helper Functions
/// ===============================================================================
/// Purpose:
/// - Centralize wall checks and movement validation
/// - Provide utility functions for grid-based movement
/// - Encapsulate boundary and collision detection logic
/// - Create a reusable foundation for Pac-Man input handling
/// ===============================================================================

/// @function pacman_utils_can_move_to(_tile_x, _tile_y)
/// @description Check if the given tile position is valid and free of walls
/// @param {real} _tile_x Tile X coordinate (grid-aligned)
/// @param {real} _tile_y Tile Y coordinate (grid-aligned)
/// @return {bool} True if position is valid and free of Wall objects
function pacman_utils_can_move_to(_tile_x, _tile_y) {
    // Check collision at exact tile position
    return !collision_point(_tile_x, _tile_y, Wall, false, true);
}

/// @function pacman_utils_can_move_direction(_current_x, _current_y, _direction)
/// @description Check if Pac can move in a specific cardinal direction
/// @param {real} _current_x Current X position (tile-aligned)
/// @param {real} _current_y Current Y position (tile-aligned)
/// @param {real} _direction Direction to check (PAC_DIRECTION enum: 0=RIGHT, 1=UP, 2=LEFT, 3=DOWN)
/// @return {bool} True if the next tile in that direction is free of walls
function pacman_utils_can_move_direction(_current_x, _current_y, _direction) {
    var _next_x = _current_x;
    var _next_y = _current_y;

    switch (_direction) {
        case PAC_DIRECTION.RIGHT:
            _next_x = _current_x + 16;  // TILE_PIXELS = 16
            break;
        case PAC_DIRECTION.UP:
            _next_y = _current_y - 16;
            break;
        case PAC_DIRECTION.LEFT:
            _next_x = _current_x - 16;
            break;
        case PAC_DIRECTION.DOWN:
            _next_y = _current_y + 16;
            break;
    }

    return pacman_utils_can_move_to(_next_x, _next_y);
}

/// @function pacman_utils_is_at_vertical_bounds()
/// @description Check if Pac is within horizontal bounds (valid for vertical movement)
/// @return {bool} True if Y is within valid range for movement
function pacman_utils_is_at_vertical_bounds() {
    return (y > 48 && y < room_height - 48);
}

/// @function pacman_utils_is_at_horizontal_bounds()
/// @description Check if Pac is within vertical bounds (valid for horizontal movement)
/// @return {bool} True if X is within valid range for movement
function pacman_utils_is_at_horizontal_bounds() {
    return (x > 8 && x < room_width - 8);
}

/// @function pacman_utils_is_in_valid_state()
/// @description Check if Pac is in a state where input should be processed
/// @return {bool} True if Pac can accept movement input
function pacman_utils_is_in_valid_state() {
    // Cannot move if dead, eating ghost, paused, or suspended
    return (dead == PAC_STATE.ALIVE && chomp == 0 && pause == 0 && stoppy == 0);
}

/// @function pacman_utils_is_at_intersection()
/// @description Check if Pac is at a grid intersection (not in a corner transition)
/// @return {bool} True if corner state is NONE (ready for new movement input)
function pacman_utils_is_at_intersection() {
    return (corner == PAC_CORNER.NONE);
}

/// @function pacman_utils_get_grid_position(_pixel_pos)
/// @description Convert pixel position to grid-aligned position
/// @param {real} _pixel_pos Pixel coordinate (x or y)
/// @return {real} Grid-aligned coordinate (nearest tile boundary)
/// NOTE: Tile positions are at boundaries (0, 16, 32, 48, ...) with sprite origins at tile centers
function pacman_utils_get_grid_position(_pixel_pos) {
    // Round to nearest tile boundary
    return 16 * round(_pixel_pos / 16);
}

/// @function pacman_utils_get_offset(_pixel_pos, _grid_pos)
/// @description Calculate offset from grid alignment
/// @param {real} _pixel_pos Current pixel position
/// @param {real} _grid_pos Grid center position
/// @return {real} Offset in pixels (positive = after center, negative = before center)
function pacman_utils_get_offset(_pixel_pos, _grid_pos) {
    return _pixel_pos - _grid_pos;
}

/// @function pacman_utils_is_before_grid(_pixel_pos, _grid_pos, _direction)
/// @description Check if position is before grid line in given direction
/// @param {real} _pixel_pos Current pixel position
/// @param {real} _grid_pos Grid center position
/// @param {real} _direction Direction (0=RIGHT, 1=UP, 2=LEFT, 3=DOWN)
/// @return {bool} True if before grid alignment in that direction
function pacman_utils_is_before_grid(_pixel_pos, _grid_pos, _direction) {
    switch (_direction) {
        case PAC_DIRECTION.RIGHT:
        case PAC_DIRECTION.DOWN:
            return _pixel_pos < _grid_pos;  // Less than center
        case PAC_DIRECTION.UP:
        case PAC_DIRECTION.LEFT:
            return _pixel_pos > _grid_pos;  // Greater than center
    }
    return false;
}

/// @function pacman_utils_clear_buffered_input()
/// @description Clear any buffered input direction
function pacman_utils_clear_buffered_input() {
    park = -1;
}

/// @function pacman_utils_buffer_input(_direction)
/// @description Store input direction for later execution
/// @param {real} _direction Direction to buffer (PAC_DIRECTION enum)
function pacman_utils_buffer_input(_direction) {
    park = _direction;
}

/// @function pacman_utils_validate_current_movement()
/// @description Check if current movement direction is still clear
/// If wall is ahead, stop Pac at grid boundary
/// @return {bool} True if movement is valid, false if blocked
function pacman_utils_validate_current_movement() {
    // Only validate if actually moving
    if (hspeed == 0 && vspeed == 0) {
        return true;  // Not moving, nothing to validate
    }

    // Skip if in corner transition
    if (corner != PAC_CORNER.NONE) {
        return true;  // Let corner completion handle it
    }

    var _grid_x = pacman_utils_get_grid_position(x);
    var _grid_y = pacman_utils_get_grid_position(y);

    // Determine current direction based on velocity
    var _current_dir = -1;

    if (hspeed > 0 && vspeed == 0) {
        _current_dir = PAC_DIRECTION.RIGHT;
    }
    else if (hspeed < 0 && vspeed == 0) {
        _current_dir = PAC_DIRECTION.LEFT;
    }
    else if (hspeed == 0 && vspeed < 0) {
        _current_dir = PAC_DIRECTION.UP;
    }
    else if (hspeed == 0 && vspeed > 0) {
        _current_dir = PAC_DIRECTION.DOWN;
    }

    // Check if next tile in current direction is clear
    if (_current_dir != -1) {
        if (!pacman_utils_can_move_direction(_grid_x, _grid_y, _current_dir)) {
            // Wall ahead! Stop movement and snap to grid
            hspeed = 0;
            vspeed = 0;

            // Snap to nearest grid position
            x = _grid_x;
            y = _grid_y;

            return false;  // Movement blocked
        }
    }

    return true;  // Movement is valid
}
