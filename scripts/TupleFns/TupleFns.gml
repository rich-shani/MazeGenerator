/// @param _x X coordinate
/// @param _y Y coordinate
/// @param _direction Optional direction value (default: -1)
/// @returns intTuple structure instance
function intTuple_create(_x, _y, _direction = -1) constructor {
    x = _x;
    y = _y;
    direction = _direction;
    
    // Instance method for equality comparison
    static equals = function(other) {
        return (other.x == x && other.y == y);
    }
    
    // Instance method to get opposite direction
    static getOppositeDirection = function() {
        if (direction >= 0 && direction < 4) {
            return (direction + 2) mod 4;
        }
        return -1;
    }
    
    // Instance method to convert to string
    static toString = function() {
        return "(" + string(x) + ", " + string(y) + ")";
    }
}

/// @description Check if two intTuples are equal
/// @param tuple1 First intTuple
/// @param tuple2 Second intTuple
/// @returns true if coordinates match
function intTuple_equals(tuple1, tuple2) {
    return (tuple1.x == tuple2.x && tuple1.y == tuple2.y);
}

/// @description Create a copy of an intTuple
/// @param source Source intTuple
/// @returns New intTuple with same values
function intTuple_copy(source) {
    return new intTuple_create(source.x, source.y, source.direction);
}

/// @description Get distance between two intTuples
/// @param tuple1 First intTuple
/// @param tuple2 Second intTuple
/// @returns Manhattan distance
function intTuple_distance(tuple1, tuple2) {
    return abs(tuple1.x - tuple2.x) + abs(tuple1.y - tuple2.y);
}