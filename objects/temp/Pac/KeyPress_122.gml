/// ===============================================================================
/// KEYPRESS_122 (F11 KEY) - TOGGLE TEST MODE
/// ===============================================================================
/// Purpose: Toggle test/debug mode for game development
/// Called: When F11 key is pressed
///
/// Triggers:
/// - Toggles the test flag for debugging features
/// - Allows enable/disable of test-specific behavior
/// ===============================================================================

/// Toggle test mode on
if (test == 0) {
    test = 1;
    exit;
}

/// Toggle test mode off
if (test == 1) {
    test = 0;
    exit;
}


