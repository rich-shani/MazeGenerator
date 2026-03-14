/// @description Generate a new procedural maze
/// Entry point for maze generation. Calls phase scripts in order.
/// See CLAUDE.md for pipeline; logic lives in PACMAN_MAZE_RESET, PACMAN_MAZE_GENERATION,
/// PACMAN_MAZE_WALLS_TUNNELS, PACMAN_MAZE_TILE_MAP.
function pacman_map_generate() {
    while (true) {
        pacman_map_reset();
        pacman_map_attempt_generate();
        if (!pacman_map_is_desirable()) continue;
        pacman_map_setup_scale_coords();
        pacman_map_join_walls();
        if (!pacman_map_create_tunnels()) continue;
        pacman_map_set_character_location();
        break;
    }
}
