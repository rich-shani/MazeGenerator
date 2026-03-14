/// ===============================================================================
/// GHOST_DIRECTION - Single conversion layer for directions
/// ===============================================================================
/// All degree/cardinal conversion for ghost movement should use this script.
/// Do not use ad-hoc math (e.g. round(direction/90)+2); use cardinal_from_direction,
/// direction_from_cardinal, direction_opposite instead.
///
/// Purpose: Define cardinal directions for ghost movement (4-directional grid)
/// Usage: Replaces numeric 0-3 values with meaningful direction names
///
/// The game uses a 16-pixel tile grid with 4 cardinal directions.
/// Ghosts can move in only these 4 directions (no diagonals).
///
/// Two representations are used:
/// 1. DEGREE format: 0°=RIGHT, 90°=UP, 180°=LEFT, 270°=DOWN (stored in variable 'direction')
/// 2. CARDINAL format: 0=RIGHT, 1=UP, 2=LEFT, 3=DOWN (stored in variable 'dir')
///
/// This enum represents the CARDINAL format (simpler for calculations)
/// ===============================================================================

enum GHOST_DIRECTION {
    /// RIGHT = 0
    /// Degree value: 0°
    /// Movement: +X (east on grid, toward right side of screen)
    /// Pixel change per frame: +speed in x-axis
    RIGHT = 0,

    /// UP = 1
    /// Degree value: 90°
    /// Movement: -Y (north on grid, toward top of screen)
    /// Pixel change per frame: -speed in y-axis
    /// Note: Grid Y increases downward (screen coordinates)
    UP = 1,

    /// LEFT = 2
    /// Degree value: 180°
    /// Movement: -X (west on grid, toward left side of screen)
    /// Pixel change per frame: -speed in x-axis
    LEFT = 2,

    /// DOWN = 3
    /// Degree value: 270°
    /// Movement: +Y (south on grid, toward bottom of screen)
    /// Pixel change per frame: +speed in y-axis
    DOWN = 3
}

/// ===============================================================================
// CONVERSION FUNCTIONS
/// ===============================================================================

/// @function direction_from_cardinal(_dir)
/// @description Convert cardinal direction (0-3) to degree format (0/90/180/270)
/// @param {real} _dir - Cardinal direction (GHOST_DIRECTION enum)
/// @return {real} - Degree value (0, 90, 180, or 270)
/// @example
///   direction = direction_from_cardinal(GHOST_DIRECTION.UP);  // Returns 90
///   direction = direction_from_cardinal(GHOST_DIRECTION.LEFT); // Returns 180

function direction_from_cardinal(_dir) {
    switch (_dir) {
        case GHOST_DIRECTION.RIGHT:
            return 0;
        case GHOST_DIRECTION.UP:
            return 90;
        case GHOST_DIRECTION.LEFT:
            return 180;
        case GHOST_DIRECTION.DOWN:
            return 270;
        default:
            return 0;  // Default to RIGHT if invalid
    }
}

/// @function cardinal_from_direction(_direction)
/// @description Convert degree format (0/90/180/270) to cardinal direction (0-3)
/// @param {real} _direction - Degree value (0, 90, 180, or 270)
/// @return {real} - Cardinal direction (GHOST_DIRECTION enum value)
/// @example
///   dir = cardinal_from_direction(90);   // Returns GHOST_DIRECTION.UP (1)
///   dir = cardinal_from_direction(180);  // Returns GHOST_DIRECTION.LEFT (2)

function cardinal_from_direction(_direction) {
    switch (_direction) {
        case 0:
            return GHOST_DIRECTION.RIGHT;
        case 90:
            return GHOST_DIRECTION.UP;
        case 180:
            return GHOST_DIRECTION.LEFT;
        case 270:
            return GHOST_DIRECTION.DOWN;
        default:
            return GHOST_DIRECTION.RIGHT;  // Default to RIGHT
    }
}

/// @function direction_name(_dir)
/// @description Get string name of cardinal direction (useful for debugging)
/// @param {real} _dir - Cardinal direction (GHOST_DIRECTION enum)
/// @return {string} - Direction name ("RIGHT", "UP", "LEFT", or "DOWN")
/// @example
///   show_debug_message("Moving " + direction_name(GHOST_DIRECTION.UP));

function direction_name(_dir) {
    switch (_dir) {
        case GHOST_DIRECTION.RIGHT:
            return "RIGHT";
        case GHOST_DIRECTION.UP:
            return "UP";
        case GHOST_DIRECTION.LEFT:
            return "LEFT";
        case GHOST_DIRECTION.DOWN:
            return "DOWN";
        default:
            return "UNKNOWN";
    }
}

/// @function direction_opposite(_dir)
/// @description Get the opposite direction (180° rotation)
/// @param {real} _dir - Cardinal direction (GHOST_DIRECTION enum)
/// @return {real} - Opposite cardinal direction
/// @example
///   new_dir = direction_opposite(GHOST_DIRECTION.RIGHT);  // Returns LEFT (2)
///   new_dir = direction_opposite(GHOST_DIRECTION.UP);     // Returns DOWN (3)

function direction_opposite(_dir) {
    switch (_dir) {
        case GHOST_DIRECTION.RIGHT:
            return GHOST_DIRECTION.LEFT;
        case GHOST_DIRECTION.UP:
            return GHOST_DIRECTION.DOWN;
        case GHOST_DIRECTION.LEFT:
            return GHOST_DIRECTION.RIGHT;
        case GHOST_DIRECTION.DOWN:
            return GHOST_DIRECTION.UP;
        default:
            return GHOST_DIRECTION.RIGHT;
    }
}

/// ===============================================================================
// MOVEMENT HELPER FUNCTIONS
/// ===============================================================================

/// @function ghost_direction_to_vector(_dir)
/// @description Convert cardinal direction to unit vector (for movement calculations)
/// @param {real} _dir - Cardinal direction (GHOST_DIRECTION enum)
/// @return {struct} - Structure with dx and dy values ({dx: -1..1, dy: -1..1})
/// @example
///   vec = ghost_direction_to_vector(GHOST_DIRECTION.UP);
///   x += vec.dx * speed;  // Apply direction to movement
///   y += vec.dy * speed;

function ghost_direction_to_vector(_dir) {
    switch (_dir) {
        case GHOST_DIRECTION.RIGHT:
            return { dx: 1, dy: 0 };
        case GHOST_DIRECTION.UP:
            return { dx: 0, dy: -1 };
        case GHOST_DIRECTION.LEFT:
            return { dx: -1, dy: 0 };
        case GHOST_DIRECTION.DOWN:
            return { dx: 0, dy: 1 };
        default:
            return { dx: 0, dy: 0 };  // No movement if invalid
    }
}

/// ===============================================================================
// END GHOST_DIRECTION ENUM
/// ===============================================================================
