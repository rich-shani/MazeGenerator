/// @description Create an integer tuple structure
/// A simple data structure to hold two integer coordinates (x, y) and optionally
/// a direction value. Used throughout the maze generator for position tracking.
/// @param _x X coordinate (integer)
/// @param _y Y coordinate (integer)
/// @param _direction Optional direction value (0-3, default: -1 for no direction)
/// @returns intTuple structure instance with x, y, and direction properties
function intTuple_create(_x, _y, _direction = -1) constructor {
    // Store the X coordinate
    x = _x;
    
    // Store the Y coordinate
    y = _y;
    
    // Store the optional direction (used for pathfinding and movement tracking)
    direction = _direction;
    
    // Instance method for equality comparison
    // Checks if two intTuples have the same x and y coordinates
    static equals = function(other) {
        return (other.x == x && other.y == y);
    }
    
    // Instance method to get opposite direction
    // Returns the direction 180 degrees opposite to the stored direction
    static getOppositeDirection = function() {
        // Only calculate if direction is valid (0-3)
        if (direction >= 0 && direction < 4) {
            // Opposite direction is current + 2 (mod 4)
            return (direction + 2) mod 4;
        }
        // Return -1 if no valid direction is stored
        return -1;
    }
    
    // Instance method to convert to string representation
    // Useful for debugging and logging
    static toString = function() {
        return "(" + string(x) + ", " + string(y) + ")";
    }
}

/// @description Check if two intTuples are equal
/// Compares two intTuple structures to see if they represent the same coordinates.
/// Only compares x and y values, ignoring direction.
/// @param tuple1 First intTuple to compare
/// @param tuple2 Second intTuple to compare
/// @returns true if both tuples have the same x and y coordinates
function intTuple_equals(tuple1, tuple2) {
    return (tuple1.x == tuple2.x && tuple1.y == tuple2.y);
}

