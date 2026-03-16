switch (direction) {
	case 0:
		draw_sprite(sPacman_Right, image_index, x, y);
		break;
	case 90:
		draw_sprite(sPacman_Up, image_index, x, y);
		break;	
	case 180:
		draw_sprite(sPacman_Left, image_index, x, y);
		break;	
	case 270:
		draw_sprite(sPacman_Down, image_index, x, y);
		break;	
}