/// ===============================================================================
/// GHOST_CHASE_PATHFINDING.gml - Table-driven ghost chase logic
/// ===============================================================================
/// Purpose: Given current tile, target tile, codir, and current dir (GRID_DIRECTION),
///          choose the best next direction using the data-driven table in GHOST_CHASE_UTILS.
/// ===============================================================================

/// @function ghost_chase_pathfinding(_objx, _objy, _chasex, _chasey, _codir, _dir)
/// @description Compute dx/dy, quadrant, and distance case, then use the
///              priority table + try helper to select dir.
/// @param _dir Current movement direction (GRID_DIRECTION)
function ghost_chase_pathfinding(_objx, _objy, _chasex, _chasey, _codir, _dir) {
    var dx = _chasex - _objx;
    var dy = _chasey - _objy;

    // Derive quadrant index from dx, dy
    var _quadrant_index;
    if (dx > 0) {
        _quadrant_index = (dy > 0) ? 0 : 1; // Q0: RIGHT+DOWN, Q1: RIGHT+UP
    } else {
        _quadrant_index = (dy > 0) ? 2 : 3; // Q2: LEFT+DOWN,  Q3: LEFT+UP
    }

    // Derive distance case
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

    // Fetch priority triple and try directions
    var _triple = ghost_chase_utils_get_priority_triple(_dir, _quadrant_index, _distance_case);
    ghost_chase_utils_try_directions(_objx, _objy, _codir, _triple[0], _triple[1], _triple[2]);
}
