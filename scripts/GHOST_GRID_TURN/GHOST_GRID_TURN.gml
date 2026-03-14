/// ===============================================================================
/// GHOST_GRID_TURN - Data-driven grid-aligned turning at intersections
/// ===============================================================================
/// Returns applied flag and new (x, y, direction) for the current (dir, direction).
/// Called from oGhost Step_2 when newtile == 1. Table: desired_dir (0-3) x current
/// direction (0°, 90°, 180°, 270°) -> condition + correction.
/// ===============================================================================

/// @description Apply grid turn: check condition for (desired_dir, current_direction) and return new position/angle.
/// @param _dir Desired cardinal direction (GHOST_DIRECTION)
/// @param _direction Current direction in degrees (0, 90, 180, 270)
/// @param _tilex Grid X of intersection
/// @param _tiley Grid Y of intersection
/// @param _px Current ghost x
/// @param _py Current ghost y
/// @returns Struct { applied: bool, x, y, direction } or applied=false if condition not met
function ghost_apply_grid_turn(_dir, _direction, _tilex, _tiley, _px, _py) {
    var _cur = (_direction == 0) ? 0 : ((_direction == 90) ? 1 : ((_direction == 180) ? 2 : 3));
    var _key = _dir * 4 + _cur;
    var _applied = false;
    var _nx = _px;
    var _ny = _py;
    var _ndir = _direction;

    switch (_key) {
        case 0:  if (_px > _tilex) { _applied = true; _ndir = 0; } break;  // RIGHT, cur RIGHT: straight
        case 1:  if (_py < _tiley) { _applied = true; _ndir = 0; _nx = _tilex + (_tiley - _py); _ny = _tiley; } break;  // RIGHT, cur UP
        case 2:  if (_px < _tilex) { _applied = true; _ndir = 0; _nx = _tilex; } break;  // RIGHT, cur LEFT
        case 3:  if (_py > _tiley) { _applied = true; _ndir = 0; _nx = _tilex + (_py - _tiley); _ny = _tiley; } break;  // RIGHT, cur DOWN
        case 4:  if (_px > _tilex) { _applied = true; _ndir = 90; _nx = _tilex; _ny = _tiley - (_px - _tilex); } break;  // UP, cur RIGHT
        case 5:  if (_py < _tiley) { _applied = true; _ndir = 90; } break;  // UP, cur UP: straight
        case 6:  if (_px < _tilex) { _applied = true; _ndir = 90; _nx = _tilex; _ny = _tiley - (_tilex - _px); } break;  // UP, cur LEFT
        case 7:  if (_py > _tiley) { _applied = true; _ndir = 90; _ny = _tiley; } break;  // UP, cur DOWN
        case 8:  if (_px > _tilex) { _applied = true; _ndir = 180; _nx = _tilex; } break;  // LEFT, cur RIGHT
        case 9:  if (_py < _tiley) { _applied = true; _ndir = 180; _nx = _tilex - (_tiley - _py); _ny = _tiley; } break;  // LEFT, cur UP
        case 10: if (_px < _tilex) { _applied = true; _ndir = 180; } break;  // LEFT, cur LEFT: straight
        case 11: if (_py > _tiley) { _applied = true; _ndir = 180; _nx = _tilex - (_py - _tiley); _ny = _tiley; } break;  // LEFT, cur DOWN
        case 12: if (_px > _tilex) { _applied = true; _ndir = 270; _nx = _tilex; _ny = _tiley + (_px - _tilex); } break;  // DOWN, cur RIGHT
        case 13: if (_py < _tiley) { _applied = true; _ndir = 270; _ny = _tiley; } break;  // DOWN, cur UP
        case 14: if (_px < _tilex) { _applied = true; _ndir = 270; _nx = _tilex; _ny = _tiley + (_tilex - _px); } break;  // DOWN, cur LEFT
        case 15: if (_py > _tiley) { _applied = true; _ndir = 270; } break;  // DOWN, cur DOWN: straight
        default: break;
    }

    return { applied: _applied, x: _nx, y: _ny, direction: _ndir };
}
