/// ===============================================================================
/// GHOST_CHASE_PATHFINDING.gml - Table-driven ghost chase logic
/// ===============================================================================
/// Purpose: Given current tile, target tile, codir, and direction (degrees),
///          choose the best next direction using the data-driven table defined
///          in GHOST_CHASE_UTILS.gml.
/// ===============================================================================

/// @function ghost_chase_pathfinding(_objx, _objy, _chasex, _chasey, _codir, _direction)
/// @description Compute dx/dy, quadrant, and distance case, then use the
///              priority table + try helper to select dir.
function ghost_chase_pathfinding(_objx, _objy, _chasex, _chasey, _codir, _direction) {
    var dx = _chasex - _objx;
    var dy = _chasey - _objy;

    // Derive quadrant index from dx, dy according to the ASCII diagram.
    var _quadrant_index;
    if (dx > 0) {
        // RIGHT side
        if (dy > 0) {
            _quadrant_index = 0; // Q0: RIGHT+DOWN
        } else {
            _quadrant_index = 1; // Q1: RIGHT+UP (dy <= 0)
        }
    } else {
        // LEFT side (dx <= 0)
        if (dy > 0) {
            _quadrant_index = 2; // Q2: LEFT+DOWN
        } else {
            _quadrant_index = 3; // Q3: LEFT+UP (dy <= 0)
        }
    }

    // Derive distance case (vertical vs horizontal dominance).
    var adx = abs(dx);
    var ady = abs(dy);
    var _distance_case;
    if (ady > adx) {
        _distance_case = 0; // VERT_GREATER
    } else if (adx > ady) {
        _distance_case = 1; // HORIZ_GREATER
    } else {
        _distance_case = 2; // EQUAL
    }

    // Fetch priority triple [d1, d2, d3] from the table.
    var _triple = ghost_chase_utils_get_priority_triple(_direction, _quadrant_index, _distance_case);
    var _d1 = _triple[0];
    var _d2 = _triple[1];
    var _d3 = _triple[2];

    // Use shared try helper to select final dir.
    ghost_chase_utils_try_directions(_objx, _objy, _codir, _d1, _d2, _d3);
}

