/// ===============================================================================
/// KEYPRESS_123 (F12 KEY) - RESET DOT COUNTER
/// ===============================================================================
/// Purpose: Debug function to reset the dot collection counter to total dots
/// Called: When F12 key is pressed
///
/// Triggers:
/// - Sets Pac.dotcount to global.dottotal (effectively resets progress)
/// - Used for testing level completion without eating all dots
/// ===============================================================================

Pac.dotcount = global.dottotal;
