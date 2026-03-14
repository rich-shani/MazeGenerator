/// ===============================================================================
/// random_direction() - FRIGHTENED GHOST MOVEMENT
/// ===============================================================================
/// Purpose: Choose a random valid direction at an intersection when ghost is frightened.
/// Called: From oGhost Step_0 (target) and Step_2 (turning) when state == GHOST_STATE.FRIGHTENED.
/// Uses: Calling instance's tilex, tiley (grid position) and dir (GRID_DIRECTION). Sets 'dir'.
///
/// Behavior:
/// - Collects all directions that are open (no wall) via ghost_chase_utils_can_go.
/// - Excludes the reverse of current direction (classic Pac-Man: no 180° turn when frightened).
/// - Picks one of the valid directions at random and sets dir.
/// ===============================================================================

function random_direction() {
    // dir is already GRID_DIRECTION; reverse is not allowed when frightened
    var _reverse = direction_opposite(dir);

    var _valid = [];
    if (ghost_chase_utils_can_go(tilex, tiley, GRID_DIRECTION.RIGHT) && GRID_DIRECTION.RIGHT != _reverse) {
        array_push(_valid, GRID_DIRECTION.RIGHT);
    }
    if (ghost_chase_utils_can_go(tilex, tiley, GRID_DIRECTION.UP) && GRID_DIRECTION.UP != _reverse) {
        array_push(_valid, GRID_DIRECTION.UP);
    }
    if (ghost_chase_utils_can_go(tilex, tiley, GRID_DIRECTION.LEFT) && GRID_DIRECTION.LEFT != _reverse) {
        array_push(_valid, GRID_DIRECTION.LEFT);
    }
    if (ghost_chase_utils_can_go(tilex, tiley, GRID_DIRECTION.DOWN) && GRID_DIRECTION.DOWN != _reverse) {
        array_push(_valid, GRID_DIRECTION.DOWN);
    }

    if (array_length(_valid) > 0) {
        dir = _valid[irandom(array_length(_valid) - 1)];
    }
    /// If no valid direction (shouldn't happen), leave dir unchanged
}
