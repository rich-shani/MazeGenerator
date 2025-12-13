/// @description Shuffle array using Fisher-Yates algorithm
/// This is an in-place shuffle that randomizes the order of elements in the array.
/// The algorithm works by iterating backwards through the array and swapping each
/// element with a randomly selected element from the unshuffled portion.
/// @param arr Array to shuffle (will be modified in place)
/// @returns Shuffled array (same reference as input, but with randomized order)
function array_shuffle(arr) {
    // Get the length of the array once for efficiency
    var len = array_length(arr);
    
    // Iterate backwards from the last element to the second element
    // (no need to swap the first element with itself)
    for (var i = len - 1; i > 0; i--) {
        // Select a random index from 0 to i (inclusive)
        // This ensures we only swap with elements that haven't been shuffled yet
        var j = irandom(i);
        
        // Swap the current element with the randomly selected element
        var temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
    
    // Return the modified array (same reference)
    return arr;
}

/// @description Create a deep copy of a 2D array
/// This function creates a completely new 2D array structure with the same dimensions
/// and values as the source array. Useful when you need to modify an array without
/// affecting the original.
/// @param source 2D array to copy (first dimension is width, second is height)
/// @returns New 2D array with copied values (independent copy, not a reference)
function array_2d_copy(source) {
    // Get the width (first dimension length)
    var width = array_length(source);
    
    // Create a new array with the same width
    var result = array_create(width);
    
    // Iterate through each column
    for (var i = 0; i < width; i++) {
        // Get the height of this column (second dimension length)
        var height = array_length(source[i]);
        
        // Create a new array for this column with the same height
        result[i] = array_create(height);
        
        // Copy each value from source to result
        for (var j = 0; j < height; j++) {
            result[i][j] = source[i][j];
        }
    }
    
    // Return the new independent copy
    return result;
}