/// @description Get opposite direction
/// Returns the direction that is 180 degrees opposite to the given direction.
/// Directions are: 0=UP, 1=RIGHT, 2=DOWN, 3=LEFT
/// @param dir Direction (0-3) representing UP, RIGHT, DOWN, or LEFT
/// @returns Opposite direction (0-3): UP<->DOWN, RIGHT<->LEFT
function direction_get_opposite(dir) {
    // Adding 2 and using modulo 4 gives the opposite direction
    // UP(0) + 2 = DOWN(2), RIGHT(1) + 2 = LEFT(3), etc.
    return (dir + 2) mod 4;
}

/// @description Get clockwise direction
/// Returns the direction that is 90 degrees clockwise from the given direction.
/// @param dir Direction (0-3) representing UP, RIGHT, DOWN, or LEFT
/// @returns Clockwise direction: UP->RIGHT->DOWN->LEFT->UP
function direction_get_clockwise(dir) {
    // Adding 1 and using modulo 4 rotates clockwise
    // UP(0) -> RIGHT(1) -> DOWN(2) -> LEFT(3) -> UP(0)
    return (dir + 1) mod 4;
}

/// @description Get counter-clockwise direction
/// Returns the direction that is 90 degrees counter-clockwise from the given direction.
/// @param dir Direction (0-3) representing UP, RIGHT, DOWN, or LEFT
/// @returns Counter-clockwise direction: UP->LEFT->DOWN->RIGHT->UP
function direction_get_counter_clockwise(dir) {
    // Adding 3 is equivalent to subtracting 1 (mod 4), which rotates counter-clockwise
    // UP(0) -> LEFT(3) -> DOWN(2) -> RIGHT(1) -> UP(0)
    return (dir + 3) mod 4;
}

/// @description Convert direction to vector
/// Converts a direction constant to a 2D vector representing movement in that direction.
/// Useful for position calculations and movement logic.
/// @param dir Direction (0-3) representing UP, RIGHT, DOWN, or LEFT
/// @returns Vector2 object with x, y components:
///          UP: (0, -1), RIGHT: (1, 0), DOWN: (0, 1), LEFT: (-1, 0)
///          Invalid direction returns (0, 0)
function direction_to_vector(dir) {
    switch (dir) {
        case CellDirection.UP:
            // Moving up decreases Y coordinate
            return {x: 0, y: -1};
        case CellDirection.RIGHT:
            // Moving right increases X coordinate
            return {x: 1, y: 0};
        case CellDirection.DOWN:
            // Moving down increases Y coordinate
            return {x: 0, y: 1};
        case CellDirection.LEFT:
            // Moving left decreases X coordinate
            return {x: -1, y: 0};
        default:
            // Invalid direction - return zero vector (no movement)
            return {x: 0, y: 0};
    }
}