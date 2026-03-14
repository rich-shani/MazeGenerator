/// ===============================================================================
/// GHOST_CHASE_UTILS.gml - Helper functions for ghost chase pathfinding
/// ===============================================================================
/// Purpose:
/// - Centralize wall checks and movement availability
/// - Encapsulate NoUp and forced-direction zones
/// - Provide a shared "try three directions" helper
/// - Define a data-driven table mapping (direction, quadrant, distance case)
///   to a priority triple of directions, with heavy commentary and ASCII diagram
/// ===============================================================================

/// @function ghost_chase_utils_free(_x, _y)
/// @description Return true if the given point is free of solid maze walls.
/// NOTE: This intentionally only checks against `Wall` – `HanglyWall` is no longer used.
function ghost_chase_utils_free(_x, _y) {
    return !collision_point(_x, _y, Wall, false, true);
}

/// @function ghost_chase_utils_can_go(_objx, _objy, _dir)
/// @description Return true if the neighbor tile in direction `_dir` is open.
/// `_dir` is a cardinal GHOST_DIRECTION (0=RIGHT,1=UP,2=LEFT,3=DOWN).
function ghost_chase_utils_can_go(_objx, _objy, _dir) {
    var _nx = _objx;
    var _ny = _objy;

    switch (_dir) {
        case GHOST_DIRECTION.RIGHT:
            _nx = _objx + 16;
            _ny = _objy;
            break;
        case GHOST_DIRECTION.UP:
            _nx = _objx;
            _ny = _objy - 16;
            break;
        case GHOST_DIRECTION.LEFT:
            _nx = _objx - 16;
            _ny = _objy;
            break;
        case GHOST_DIRECTION.DOWN:
            _nx = _objx;
            _ny = _objy + 16;
            break;
    }

    return ghost_chase_utils_free(_nx, _ny);
}

/// @function ghost_chase_utils_no_up(_objx, _objy, _chasex)
/// @description Encapsulate the NoUp-zone behavior from chase_object.
/// Returns true if it sets `dir` and handles the move, false otherwise.
function ghost_chase_utils_no_up(_objx, _objy, _chasex) {
    if (collision_point(_objx, _objy, NoUp, false, true) && state < 2) {
        if (direction == 0) {
            dir = GHOST_DIRECTION.RIGHT;
            return true;
        }
        if (direction == 180) {
            dir = GHOST_DIRECTION.LEFT;
            return true;
        }
        if (direction == 270) {
            if ((_chasex - _objx) > 0) {
                dir = GHOST_DIRECTION.RIGHT;
                return true;
            } else {
                dir = GHOST_DIRECTION.LEFT;
                return true;
            }
        }
    }
    return false;
}

/// @function ghost_chase_utils_forced_zones(_objx, _objy)
/// @description Encapsulate the Up/Left/Down/Right forced-direction zones.
/// Returns true if it sets `dir` and handles the move, false otherwise.
function ghost_chase_utils_forced_zones(_objx, _objy) {
    // Force UP direction
    if (fruity == 0 && collision_point(_objx, _objy, Up, false, true) &&
        state == 2 && direction < 270) {
        dir = GHOST_DIRECTION.UP;
        return true;
    }

    // Force LEFT direction
    if (fruity == 0 && collision_point(_objx, _objy, Left, false, true) &&
        state == 2 && direction > 0) {
        dir = GHOST_DIRECTION.LEFT;
        return true;
    }

    // Force DOWN direction
    if (fruity == 0 && collision_point(_objx, _objy, Down, false, true) &&
        state == 2 && (direction > 90 || direction < 90)) {
        dir = GHOST_DIRECTION.DOWN;
        return true;
    }

    // Force RIGHT direction
    if (fruity == 0 && collision_point(_objx, _objy, Right, false, true) &&
        state == 2 && (direction > 180 || direction < 180)) {
        dir = GHOST_DIRECTION.RIGHT;
        return true;
    }

    return false;
}

/// @function ghost_chase_utils_try_directions(_objx, _objy, _codir, _dir1, _dir2, _dir3)
/// @description Try up to three directions in order, respecting codir and walls.
/// If a direction is chosen, sets `dir` and returns true; otherwise returns false.
function ghost_chase_utils_try_directions(_objx, _objy, _codir, _dir1, _dir2, _dir3) {
    if (_codir == 0 && ghost_chase_utils_can_go(_objx, _objy, _dir1)) {
        dir = _dir1;
        return true;
    }

    if (ghost_chase_utils_can_go(_objx, _objy, _dir2)) {
        dir = _dir2;
        return true;
    }

    if (ghost_chase_utils_can_go(_objx, _objy, _dir3)) {
        dir = _dir3;
        return true;
    }

    return false;
}

/// ===============================================================================
/// DATA-DRIVEN PRIORITY TABLE
/// ===============================================================================
///
/// Each original pathfinding block in GHOST_CHASE.gml can be described by:
///   - Current movement direction (degrees): 0, 90, 180, 270
///   - Target quadrant relative to ghost (based on dx, dy)
///   - Distance case (which axis has greater absolute distance)
///   - A priority triple [d1, d2, d3] of cardinal directions
///
/// QUADRANT & DISTANCE MAP (for table indices)
///
///      dy < 0 (UP)
///          ┌───────────────┬───────────────┐
///          │ Q1: RIGHT+UP  │ Q3: LEFT+UP   │
///          │ dx > 0        │ dx <= 0       │
///          ├───────────────┼───────────────┤
///          │ Q0: RIGHT+DOWN│ Q2: LEFT+DOWN │
///          │ dx > 0        │ dx <= 0       │
///          └───────────────┴───────────────┘
///              dx > 0           dx <= 0
///
/// Distance cases per quadrant:
///   0 = VERT_GREATER   (abs(dy) > abs(dx))
///   1 = HORIZ_GREATER  (abs(dx) > abs(dy))
///   2 = EQUAL          (abs(dx) == abs(dy))
///
/// Table index pattern:
///   dir_index  = direction (0,90,180,270) mapped to 0..3
///   quad_index = 0..3 as above
///   dist_case  = 0..2 as above
///   entry      = [d1, d2, d3] (try d1, else d2, else d3)
///
/// Example:
///   - direction = 0 (RIGHT)
///   - dx > 0, dy > 0  → quadrant Q0 (RIGHT+DOWN)
///   - abs(dy) > abs(dx) → VERT_GREATER (0)
///   - PRIORITY[0][0][0] = [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.UP]
///     → "Down > Right > Up" (matches original comment).

function ghost_chase_utils_get_priority_triple(_direction_degrees, _quadrant_index, _distance_case) {
    static _table_initialized = false;
    static _priority = noone;

    if (!_table_initialized) {
        // Build 4 (directions) x 4 (quadrants) x 3 (distance cases) table.
        _priority = array_create(4);

        // Direction index 0: RIGHT (0°)
        _priority[0] = [
            // Q0: RIGHT+DOWN
            [
                // Vert>Horiz: "Down > Right > Up"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.UP],
                // Horiz>Vert: "Right > Down > Up"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.UP],
                // Equal:      "Down > Right > Up"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.UP]
            ],
            // Q1: RIGHT+UP
            [
                // Vert>Horiz: "Up > Right > Down"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.DOWN],
                // Horiz>Vert: "Right > Up > Down"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.UP, GHOST_DIRECTION.DOWN],
                // Equal:      "Up > Right > Down"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.DOWN]
            ],
            // Q2: LEFT+DOWN
            [
                // Vert>Horiz: "Down > Right > Up"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.UP],
                // Horiz>Vert: "Down > Up > Right"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT],
                // Equal:      "Down > Up > Right"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT]
            ],
            // Q3: LEFT+UP
            [
                // Vert>Horiz: "Up > Right > Down"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.DOWN],
                // Horiz>Vert: "Up > Down > Right"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT],
                // Equal:      "Up > Down > Right"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT]
            ]
        ];

        // Direction index 1: UP (90°)
        _priority[1] = [
            // Q0: RIGHT+DOWN
            [
                // Vert>Horiz: "Right > Left > Up"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.UP],
                // Horiz>Vert: "Right > Up > Left"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT],
                // Equal:      "Right > Up > Left"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT]
            ],
            // Q1: RIGHT+UP
            [
                // Vert>Horiz: "Up > Right > Left"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.LEFT],
                // Horiz>Vert: "Right > Up > Left"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT],
                // Equal:      "Up > Right > Left"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.LEFT]
            ],
            // Q2: LEFT+DOWN
            [
                // Vert>Horiz: "Left > Right > Up"
                [GHOST_DIRECTION.LEFT, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.UP],
                // Horiz>Vert: "Left > Up > Right"
                [GHOST_DIRECTION.LEFT, GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT],
                // Equal:      "Left > Up > Right"
                [GHOST_DIRECTION.LEFT, GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT]
            ],
            // Q3: LEFT+UP
            [
                // Vert>Horiz: "Up > Left > Right"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.RIGHT],
                // Horiz>Vert: "Up > Right > Left"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.LEFT],
                // Equal:      "Up > Left > Right"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.RIGHT]
            ]
        ];

        // Direction index 2: LEFT (180°)
        _priority[2] = [
            // Q0: RIGHT+DOWN
            [
                // Vert>Horiz: "Down > Left > Up"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.UP],
                // Horiz>Vert: "Down > Up > Left"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT],
                // Equal:      "Down > Left > Up"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.UP]
            ],
            // Q1: RIGHT+UP
            [
                // Vert>Horiz: "Up > Left > Down"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN],
                // Horiz>Vert: "Up > Down > Left"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.LEFT],
                // Equal:      "Up > Left > Down"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN]
            ],
            // Q2: LEFT+DOWN
            [
                // Vert>Horiz: "Down > Left > Up"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.UP],
                // Horiz>Vert: "Left > Down > Up"
                [GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.UP],
                // Equal:      "Down > Left > Up"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.UP]
            ],
            // Q3: LEFT+UP
            [
                // Vert>Horiz: "Up > Left > Down"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN],
                // Horiz>Vert: "Left > Up > Down"
                [GHOST_DIRECTION.LEFT, GHOST_DIRECTION.UP, GHOST_DIRECTION.DOWN],
                // Equal:      "Up > Left > Down"
                [GHOST_DIRECTION.UP, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN]
            ]
        ];

        // Direction index 3: DOWN (270°)
        _priority[3] = [
            // Q0: RIGHT+DOWN
            [
                // Vert>Horiz: "Down > Right > Left"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.LEFT],
                // Horiz>Vert: "Right > Down > Left"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.LEFT],
                // Equal:      "Down > Right > Left"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.LEFT]
            ],
            // Q1: RIGHT+UP
            [
                // Vert>Horiz: "Right > Left > Down"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN],
                // Horiz>Vert: "Right > Down > Left"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.LEFT],
                // Equal:      "Right > Left > Down"
                [GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN]
            ],
            // Q2: LEFT+DOWN
            [
                // Vert>Horiz: "Down > Left > Right"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.RIGHT],
                // Horiz>Vert: "Left > Down > Right"
                [GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT],
                // Equal:      "Down > Left > Right"
                [GHOST_DIRECTION.DOWN, GHOST_DIRECTION.LEFT, GHOST_DIRECTION.RIGHT]
            ],
            // Q3: LEFT+UP
            [
                // Vert>Horiz: "Left > Right > Down"
                [GHOST_DIRECTION.LEFT, GHOST_DIRECTION.RIGHT, GHOST_DIRECTION.DOWN],
                // Horiz>Vert: "Left > Down > Right"
                [GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT],
                // Equal:      "Left > Down > Right"
                [GHOST_DIRECTION.LEFT, GHOST_DIRECTION.DOWN, GHOST_DIRECTION.RIGHT]
            ]
        ];

        _table_initialized = true;
    }

    var _dir_index;
    switch (_direction_degrees) {
        case 0:
            _dir_index = 0; // RIGHT
            break;
        case 90:
            _dir_index = 1; // UP
            break;
        case 180:
            _dir_index = 2; // LEFT
            break;
        case 270:
            _dir_index = 3; // DOWN
            break;
        default:
            _dir_index = 0;
            break;
    }

    return _priority[_dir_index][_quadrant_index][_distance_case];
}

