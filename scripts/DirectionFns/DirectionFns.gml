/// @description Get opposite direction
/// @param dir Direction (0-3)
/// @returns Opposite direction
function direction_get_opposite(dir) {
    return (dir + 2) mod 4;
}

/// @description Get clockwise direction
/// @param dir Direction (0-3)
/// @returns Clockwise direction
function direction_get_clockwise(dir) {
    return (dir + 1) mod 4;
}

/// @description Get counter-clockwise direction
/// @param dir Direction (0-3)
/// @returns Counter-clockwise direction
function direction_get_counter_clockwise(dir) {
    return (dir + 3) mod 4;
}

/// @description Convert direction to vector
/// @param dir Direction (0-3)
/// @returns Vector2 with x, y components
function direction_to_vector(dir) {
    switch (dir) {
        case CellDirection.UP: return {x: 0, y: -1};
        case CellDirection.RIGHT: return {x: 1, y: 0};
        case CellDirection.DOWN: return {x: 0, y: 1};
        case CellDirection.LEFT: return {x: -1, y: 0};
        default: return {x: 0, y: 0};
    }
}