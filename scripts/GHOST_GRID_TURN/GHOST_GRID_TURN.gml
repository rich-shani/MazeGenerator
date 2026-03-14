/// ===============================================================================
/// GHOST_GRID_TURN - Data-driven grid-aligned turning at intersections
/// ===============================================================================
/// Returns applied flag and new (x, y, dir) for the current (desired_dir,
/// current_dir) pair.  Both direction parameters are GRID_DIRECTION values
/// (RIGHT=0, UP=1, LEFT=2, DOWN=3).
///
/// Table: _key = _dir * 4 + _dir_current  (0..15)
///   Each case checks a positional condition and, if met, snaps ghost position
///   and sets the new direction (_ndir).
///
/// Called from oGhost Step_2 when newtile == 1.
/// ===============================================================================

/// @description Apply grid turn for (desired dir, current dir) → new position/dir.
/// @param _dir           Desired GRID_DIRECTION
/// @param _dir_current   Actual current GRID_DIRECTION (dir_applied)
/// @param _tilex         Grid X of intersection
/// @param _tiley         Grid Y of intersection
/// @param _px            Current ghost x
/// @param _py            Current ghost y
/// @returns Struct { applied: bool, x, y, dir } — dir is GRID_DIRECTION
function ghost_apply_grid_turn(_dir, _dir_current, _tilex, _tiley, _px, _py) {
    var _key     = _dir * 4 + _dir_current;
    var _applied = false;
    var _nx      = _px;
    var _ny      = _py;
    var _ndir    = _dir_current;  // default: unchanged

    switch (_key) {
        // ── Desired RIGHT (0) ────────────────────────────────────────────────
        case 0:  if (_px > _tilex) { _applied = true; _ndir = GRID_DIRECTION.RIGHT; } break;                                                    // RIGHT, cur RIGHT: straight
        case 1:  if (_py < _tiley) { _applied = true; _ndir = GRID_DIRECTION.RIGHT; _nx = _tilex + (_tiley - _py); _ny = _tiley; } break;      // RIGHT, cur UP
        case 2:  if (_px < _tilex) { _applied = true; _ndir = GRID_DIRECTION.RIGHT; _nx = _tilex; } break;                                      // RIGHT, cur LEFT
        case 3:  if (_py > _tiley) { _applied = true; _ndir = GRID_DIRECTION.RIGHT; _nx = _tilex + (_py - _tiley); _ny = _tiley; } break;      // RIGHT, cur DOWN

        // ── Desired UP (1) ───────────────────────────────────────────────────
        case 4:  if (_px > _tilex) { _applied = true; _ndir = GRID_DIRECTION.UP; _nx = _tilex; _ny = _tiley - (_px - _tilex); } break;         // UP, cur RIGHT
        case 5:  if (_py < _tiley) { _applied = true; _ndir = GRID_DIRECTION.UP; } break;                                                       // UP, cur UP: straight
        case 6:  if (_px < _tilex) { _applied = true; _ndir = GRID_DIRECTION.UP; _nx = _tilex; _ny = _tiley - (_tilex - _px); } break;         // UP, cur LEFT
        case 7:  if (_py > _tiley) { _applied = true; _ndir = GRID_DIRECTION.UP; _ny = _tiley; } break;                                         // UP, cur DOWN

        // ── Desired LEFT (2) ─────────────────────────────────────────────────
        case 8:  if (_px > _tilex) { _applied = true; _ndir = GRID_DIRECTION.LEFT; _nx = _tilex; } break;                                       // LEFT, cur RIGHT
        case 9:  if (_py < _tiley) { _applied = true; _ndir = GRID_DIRECTION.LEFT; _nx = _tilex - (_tiley - _py); _ny = _tiley; } break;       // LEFT, cur UP
        case 10: if (_px < _tilex) { _applied = true; _ndir = GRID_DIRECTION.LEFT; } break;                                                     // LEFT, cur LEFT: straight
        case 11: if (_py > _tiley) { _applied = true; _ndir = GRID_DIRECTION.LEFT; _nx = _tilex - (_py - _tiley); _ny = _tiley; } break;       // LEFT, cur DOWN

        // ── Desired DOWN (3) ─────────────────────────────────────────────────
        case 12: if (_px > _tilex) { _applied = true; _ndir = GRID_DIRECTION.DOWN; _nx = _tilex; _ny = _tiley + (_px - _tilex); } break;       // DOWN, cur RIGHT
        case 13: if (_py < _tiley) { _applied = true; _ndir = GRID_DIRECTION.DOWN; _ny = _tiley; } break;                                       // DOWN, cur UP
        case 14: if (_px < _tilex) { _applied = true; _ndir = GRID_DIRECTION.DOWN; _nx = _tilex; _ny = _tiley + (_tilex - _px); } break;       // DOWN, cur LEFT
        case 15: if (_py > _tiley) { _applied = true; _ndir = GRID_DIRECTION.DOWN; } break;                                                     // DOWN, cur DOWN: straight

        default: break;
    }

    return { applied: _applied, x: _nx, y: _ny, dir: _ndir };
}
