if (!initializeGridElements) {
    pacman_map_spawn_entities(tileMap, x_offset, y_offset, gridSize);
    initializeGridElements = true;
}
