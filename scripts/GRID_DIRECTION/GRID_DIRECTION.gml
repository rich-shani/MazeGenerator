/// ===============================================================================
/// GRID_DIRECTION - Unified direction system for maze generation and ghost AI
/// ===============================================================================
/// Single direction enum used everywhere: maze cell logic, ghost pathfinding,
/// and ghost movement. Replaces both the old CellDirection (UP=0…) and the
/// old GHOST_DIRECTION (RIGHT=0…) enums, eliminating all conversion functions.
///
/// The game uses a 16-pixel tile grid with 4 cardinal directions.
///
/// CARDINAL format: 0=RIGHT, 1=UP, 2=LEFT, 3=DOWN (stored in variable 'dir')
/// GML physics 'direction' variable (degrees) is set from 'dir' at one conversion
/// point in ghost movement (see oGhost Step_2). All internal logic uses GRID_DIRECTION.
///
/// Opposite pairs: RIGHT(0) <-> LEFT(2), UP(1) <-> DOWN(3)
/// Formula (dir + 2) mod 4 gives the opposite direction.
/// ===============================================================================

enum GRID_DIRECTION {
    /// RIGHT = 0  |  Degree: 0°   |  Movement: +X
    RIGHT = 0,

    /// UP = 1     |  Degree: 90°  |  Movement: -Y (screen Y increases downward)
    UP = 1,

    /// LEFT = 2   |  Degree: 180° |  Movement: -X
    LEFT = 2,

    /// DOWN = 3   |  Degree: 270° |  Movement: +Y
    DOWN = 3
}

/// ===============================================================================
/// DIRECTION HELPERS
/// ===============================================================================

/// @function direction_opposite(_dir)
/// @description Return the opposite of a GRID_DIRECTION (180° rotation).
/// RIGHT<->LEFT, UP<->DOWN. Equivalent to (dir + 2) mod 4.
function direction_opposite(_dir) {
    switch (_dir) {
        case GRID_DIRECTION.RIGHT: return GRID_DIRECTION.LEFT;
        case GRID_DIRECTION.UP:    return GRID_DIRECTION.DOWN;
        case GRID_DIRECTION.LEFT:  return GRID_DIRECTION.RIGHT;
        case GRID_DIRECTION.DOWN:  return GRID_DIRECTION.UP;
        default:                   return GRID_DIRECTION.RIGHT;
    }
}

/// @function direction_name(_dir)
/// @description Return a string name for a GRID_DIRECTION (for debugging).
function direction_name(_dir) {
    switch (_dir) {
        case GRID_DIRECTION.RIGHT: return "RIGHT";
        case GRID_DIRECTION.UP:    return "UP";
        case GRID_DIRECTION.LEFT:  return "LEFT";
        case GRID_DIRECTION.DOWN:  return "DOWN";
        default:                   return "UNKNOWN";
    }
}

/// @function grid_direction_to_vector(_dir)
/// @description Convert a GRID_DIRECTION to a unit movement vector {dx, dy}.
function grid_direction_to_vector(_dir) {
    switch (_dir) {
        case GRID_DIRECTION.RIGHT: return { dx:  1, dy:  0 };
        case GRID_DIRECTION.UP:    return { dx:  0, dy: -1 };
        case GRID_DIRECTION.LEFT:  return { dx: -1, dy:  0 };
        case GRID_DIRECTION.DOWN:  return { dx:  0, dy:  1 };
        default:                   return { dx:  0, dy:  0 };
    }
}

/// ===============================================================================
/// END GRID_DIRECTION
/// ===============================================================================
