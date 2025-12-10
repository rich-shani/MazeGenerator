/// @description Shuffle array using Fisher-Yates algorithm
/// @param arr Array to shuffle
/// @returns Shuffled array (modifies original)
function array_shuffle(arr) {
    var len = array_length(arr);
    for (var i = len - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
    return arr;
}

/// @description Create a copy of a 2D array
/// @param source 2D array to copy
/// @returns New 2D array with copied values
function array_2d_copy(source) {
    var width = array_length(source);
    var result = array_create(width);
    for (var i = 0; i < width; i++) {
        var height = array_length(source[i]);
        result[i] = array_create(height);
        for (var j = 0; j < height; j++) {
            result[i][j] = source[i][j];
        }
    }
    return result;
}