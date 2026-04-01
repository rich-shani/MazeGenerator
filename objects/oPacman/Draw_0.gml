//switch (direction) {
//	case 0:
//		draw_sprite(sPacman_Right, image_index, x, y);
//		break;
//	case 90:
//		draw_sprite(sPacman_Up, image_index, x, y);
//		break;	
//	case 180:
//		draw_sprite(sPacman_Left, image_index, x, y);
//		break;	
//	case 270:
//		draw_sprite(sPacman_Down, image_index, x, y);
//		break;	
//}

switch (dir) {
	case PAC_DIRECTION.RIGHT:
		//draw_sprite(sPacman_Right, 0, x, y);
		draw_sprite_ext(sPacman_Right, image_index, x, y, 1, 1, 0, c_white, 1);
		break;
	case PAC_DIRECTION.UP:
		draw_sprite_ext(sPacman_Up, image_index, x, y,  1, 1, 0, c_white, 1);
		break;	
	case PAC_DIRECTION.LEFT:
		draw_sprite_ext(sPacman_Left, image_index, x, y, 1, 1, 0, c_white, 1);
		break;	
	case PAC_DIRECTION.DOWN:
		draw_sprite_ext(sPacman_Down, image_index, x, y, 1, 1, 0, c_white, 1);
		break;	
}

// ================== DEBUG CORNER OVERLAY ==================
if (pac_debug_corners) {
    // Grid-aligned position based on current tile tracking
    var _grid_x = pacman_utils_get_grid_position(x);
    var _grid_y = pacman_utils_get_grid_position(y);

    // Actual sprite position marker (yellow)
    draw_set_color(c_yellow);
    draw_rectangle(x - 2, y - 2, x + 2, y + 2, false);

    // Grid center marker (cyan) using tilex/tiley
    draw_set_color(c_aqua);
    draw_rectangle(tilex - 2, tiley - 2, tilex + 2, tiley + 2, false);

    // Secondary grid marker based on pacman_utils_get_grid_position (white)
    draw_set_color(c_white);
    draw_rectangle(_grid_x - 1, _grid_y - 1, _grid_x + 1, _grid_y + 1, false);

    // Compact text block with key debug info
    var _text =
        "f=" + string(pac_debug_frame)
        + " dir=" + string(direction)
        + " d=" + string(dir)
        + " c=" + string(corner)
        + " hs=" + string(hspeed)
        + " vs=" + string(vspeed)
        + " x=" + string(x) + " y=" + string(y)
        + " tx=" + string(tilex) + " ty=" + string(tiley);

    draw_set_color(c_white);
    draw_text(x + 12, y - 24, _text);
}