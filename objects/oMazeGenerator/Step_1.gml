if (!initializeGridElements) {
    pacman_map_spawn_entities(tileMap, x_offset, y_offset, gridSize);
	pacman_map_gen_sprite_index(tileMap);
	
    initializeGridElements = true;
}
