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