/// @description Convert a GRID_DIRECTION to a movement vector.
/// Returns a struct {x, y} where values are -1, 0, or 1.
/// RIGHT:(1,0), UP:(0,-1), DOWN:(0,1), LEFT:(-1,0)
function direction_to_vector(dir) {
    switch (dir) {
        case GRID_DIRECTION.RIGHT: return { x:  1, y:  0 };
        case GRID_DIRECTION.UP:    return { x:  0, y: -1 };
        case GRID_DIRECTION.DOWN:  return { x:  0, y:  1 };
        case GRID_DIRECTION.LEFT:  return { x: -1, y:  0 };
        default:                   return { x:  0, y:  0 };
    }
}
