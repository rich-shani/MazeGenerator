/// ===============================================================================
/// PACMAN_DIRECTION_HANDLER - Direction-Specific Input Logic
/// ===============================================================================
/// Purpose:
/// - Encapsulate input logic for each cardinal direction
/// - Handle corner transition initiation
/// - Validate movement and apply velocities
/// - Centralize direction-specific state changes
/// ===============================================================================

/// @function pacman_handle_direction_right(_spd)
/// @description Process RIGHT arrow key input
/// @param {real} _spd Current movement speed
function pacman_handle_direction_right(_spd) {
    if (!pacman_utils_is_at_vertical_bounds()) return;
    if (!keyboard_check(vk_right)) return;
    if (keyboard_check(vk_up) || keyboard_check(vk_left) || keyboard_check(vk_down)) return;

    var _grid_x = pacman_utils_get_grid_position(x);
    var _grid_y = pacman_utils_get_grid_position(y);

    if (pacman_utils_can_move_direction(_grid_x, _grid_y, PAC_DIRECTION.RIGHT)) {
        dir = PAC_DIRECTION.RIGHT;
        pacman_utils_clear_buffered_input();

        // Corner transition (per Pac-Man Dossier: pre-turn and post-turn zones)
        if (direction == 90 && vspeed != 0) {  // Moving UP
            if (pacman_utils_is_in_pre_turn_zone(y, _grid_y, PAC_DIRECTION.UP)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.UP_TO_RIGHT_PRE;
                hspeed = _spd;
                vspeed = -_spd;
            }
            else if (pacman_utils_is_in_post_turn_zone(y, _grid_y, PAC_DIRECTION.UP)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.UP_TO_RIGHT_POST;
                hspeed = _spd;
                vspeed = _spd;
            }
            else if (!pacman_utils_is_before_grid(y, _grid_y, PAC_DIRECTION.UP)) {
                x = _grid_x; y = _grid_y; hspeed = _spd; vspeed = 0; corner = PAC_CORNER.NONE;
            }
        }
        else if (direction == 270 && vspeed != 0) {  // Moving DOWN
            if (pacman_utils_is_in_pre_turn_zone(y, _grid_y, PAC_DIRECTION.DOWN)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.DOWN_TO_RIGHT_PRE;
                hspeed = _spd;
                vspeed = _spd;
            }
            else if (pacman_utils_is_in_post_turn_zone(y, _grid_y, PAC_DIRECTION.DOWN)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.DOWN_TO_RIGHT_POST;
                hspeed = _spd;
                vspeed = -_spd;
            }
            else if (!pacman_utils_is_before_grid(y, _grid_y, PAC_DIRECTION.DOWN)) {
                x = _grid_x; y = _grid_y; hspeed = _spd; vspeed = 0; corner = PAC_CORNER.NONE;
            }
        }
        else {
            // Not turning, just move right
            hspeed = _spd;
            vspeed = 0;
        }
    }
    else {
        // Wall in the way, buffer the direction
        pacman_utils_buffer_input(PAC_DIRECTION.RIGHT);
    }
}

/// @function pacman_handle_direction_up(_spd)
/// @description Process UP arrow key input
/// @param {real} _spd Current movement speed
function pacman_handle_direction_up(_spd) {
    if (!pacman_utils_is_at_horizontal_bounds()) return;
    if (!keyboard_check(vk_up)) return;
    if (keyboard_check(vk_right) || keyboard_check(vk_left) || keyboard_check(vk_down)) return;

    var _grid_x = pacman_utils_get_grid_position(x);
    var _grid_y = pacman_utils_get_grid_position(y);

    if (pacman_utils_can_move_direction(_grid_x, _grid_y, PAC_DIRECTION.UP)) {
        dir = PAC_DIRECTION.UP;
        pacman_utils_clear_buffered_input();

        if (direction == 0 && hspeed != 0) {  // Moving RIGHT
            if (pacman_utils_is_in_pre_turn_zone(x, _grid_x, PAC_DIRECTION.RIGHT)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.RIGHT_TO_UP_PRE;
                hspeed = _spd;
                vspeed = -_spd;
            }
            else if (pacman_utils_is_in_post_turn_zone(x, _grid_x, PAC_DIRECTION.RIGHT)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.RIGHT_TO_UP_POST;
                hspeed = -_spd;
                vspeed = -_spd;
            }
            else if (!pacman_utils_is_before_grid(x, _grid_x, PAC_DIRECTION.RIGHT)) {
                x = _grid_x; y = _grid_y; hspeed = 0; vspeed = -_spd; corner = PAC_CORNER.NONE;
            }
        }
        else if (direction == 180 && hspeed != 0) {  // Moving LEFT
            if (pacman_utils_is_in_pre_turn_zone(x, _grid_x, PAC_DIRECTION.LEFT)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.LEFT_TO_UP_PRE;
                hspeed = -_spd;
                vspeed = -_spd;
            }
            else if (pacman_utils_is_in_post_turn_zone(x, _grid_x, PAC_DIRECTION.LEFT)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.LEFT_TO_UP_POST;
                hspeed = _spd;
                vspeed = -_spd;
            }
            else if (!pacman_utils_is_before_grid(x, _grid_x, PAC_DIRECTION.LEFT)) {
                x = _grid_x; y = _grid_y; hspeed = 0; vspeed = -_spd; corner = PAC_CORNER.NONE;
            }
        }
        else {
            hspeed = 0;
            vspeed = -_spd;
        }
    }
    else {
        pacman_utils_buffer_input(PAC_DIRECTION.UP);
    }
}

/// @function pacman_handle_direction_left(_spd)
/// @description Process LEFT arrow key input
/// @param {real} _spd Current movement speed
function pacman_handle_direction_left(_spd) {
    if (!pacman_utils_is_at_vertical_bounds()) return;
    if (!keyboard_check(vk_left)) return;
    if (keyboard_check(vk_up) || keyboard_check(vk_right) || keyboard_check(vk_down)) return;

    var _grid_x = pacman_utils_get_grid_position(x);
    var _grid_y = pacman_utils_get_grid_position(y);

    if (pacman_utils_can_move_direction(_grid_x, _grid_y, PAC_DIRECTION.LEFT)) {
        dir = PAC_DIRECTION.LEFT;
        pacman_utils_clear_buffered_input();

        if (direction == 90 && vspeed != 0) {  // Moving UP
            if (pacman_utils_is_in_pre_turn_zone(y, _grid_y, PAC_DIRECTION.UP)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.UP_TO_LEFT_PRE;
                hspeed = -_spd;
                vspeed = -_spd;
            }
            else if (pacman_utils_is_in_post_turn_zone(y, _grid_y, PAC_DIRECTION.UP)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.UP_TO_LEFT_POST;
                hspeed = -_spd;
                vspeed = _spd;
            }
            else if (!pacman_utils_is_before_grid(y, _grid_y, PAC_DIRECTION.UP)) {
                x = _grid_x; y = _grid_y; hspeed = -_spd; vspeed = 0; corner = PAC_CORNER.NONE;
            }
        }
        else if (direction == 270 && vspeed != 0) {  // Moving DOWN
            if (pacman_utils_is_in_pre_turn_zone(y, _grid_y, PAC_DIRECTION.DOWN)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.DOWN_TO_LEFT_PRE;
                hspeed = -_spd;
                vspeed = _spd;
            }
            else if (pacman_utils_is_in_post_turn_zone(y, _grid_y, PAC_DIRECTION.DOWN)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.DOWN_TO_LEFT_POST;
                hspeed = -_spd;
                vspeed = -_spd;
            }
            else if (!pacman_utils_is_before_grid(y, _grid_y, PAC_DIRECTION.DOWN)) {
                x = _grid_x; y = _grid_y; hspeed = -_spd; vspeed = 0; corner = PAC_CORNER.NONE;
            }
        }
        else {
            hspeed = -_spd;
            vspeed = 0;
        }
    }
    else {
        pacman_utils_buffer_input(PAC_DIRECTION.LEFT);
    }
}

/// @function pacman_handle_direction_down(_spd)
/// @description Process DOWN arrow key input
/// @param {real} _spd Current movement speed
function pacman_handle_direction_down(_spd) {
    if (!pacman_utils_is_at_horizontal_bounds()) return;
    if (!keyboard_check(vk_down)) return;
    if (keyboard_check(vk_right) || keyboard_check(vk_left) || keyboard_check(vk_up)) return;

    var _grid_x = pacman_utils_get_grid_position(x);
    var _grid_y = pacman_utils_get_grid_position(y);

    if (pacman_utils_can_move_direction(_grid_x, _grid_y, PAC_DIRECTION.DOWN)) {
        dir = PAC_DIRECTION.DOWN;
        pacman_utils_clear_buffered_input();

        if (direction == 0 && hspeed != 0) {  // Moving RIGHT
            if (pacman_utils_is_in_pre_turn_zone(x, _grid_x, PAC_DIRECTION.RIGHT)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.RIGHT_TO_DOWN_PRE;
                hspeed = _spd;
                vspeed = _spd;
            }
            else if (pacman_utils_is_in_post_turn_zone(x, _grid_x, PAC_DIRECTION.RIGHT)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.RIGHT_TO_DOWN_POST;
                hspeed = -_spd;
                vspeed = _spd;
            }
            else if (!pacman_utils_is_before_grid(x, _grid_x, PAC_DIRECTION.RIGHT)) {
                x = _grid_x; y = _grid_y; hspeed = 0; vspeed = _spd; corner = PAC_CORNER.NONE;
            }
        }
        else if (direction == 180 && hspeed != 0) {  // Moving LEFT
            if (pacman_utils_is_in_pre_turn_zone(x, _grid_x, PAC_DIRECTION.LEFT)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.LEFT_TO_DOWN_PRE;
                hspeed = -_spd;
                vspeed = _spd;
            }
            else if (pacman_utils_is_in_post_turn_zone(x, _grid_x, PAC_DIRECTION.LEFT)) {
                tilex = _grid_x;
                tiley = _grid_y;
                corner = PAC_CORNER.LEFT_TO_DOWN_POST;
                hspeed = _spd;
                vspeed = _spd;
            }
            else if (!pacman_utils_is_before_grid(x, _grid_x, PAC_DIRECTION.LEFT)) {
                x = _grid_x; y = _grid_y; hspeed = 0; vspeed = _spd; corner = PAC_CORNER.NONE;
            }
        }
        else {
            hspeed = 0;
            vspeed = _spd;
        }
    }
    else {
        pacman_utils_buffer_input(PAC_DIRECTION.DOWN);
    }
}

/// @function pacman_handle_all_directions(_spd)
/// @description Process all four cardinal directions in sequence
/// @param {real} _spd Current movement speed
function pacman_handle_all_directions(_spd) {
    pacman_handle_direction_right(_spd);
    pacman_handle_direction_up(_spd);
    pacman_handle_direction_left(_spd);
    pacman_handle_direction_down(_spd);
}
