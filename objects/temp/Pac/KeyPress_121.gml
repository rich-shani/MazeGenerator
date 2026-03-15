/// ===============================================================================
/// KEYPRESS_121 (F10 KEY) - TOGGLE GAME SPEED
/// ===============================================================================
/// Purpose: Toggle between normal (60 FPS) and slow-motion (10 FPS) game speed
/// Called: When F10 key is pressed
///
/// Triggers:
/// - Toggles room_speed between 60 and 10
/// - Allows debugging and detailed observation of gameplay
/// ===============================================================================

/// Toggle between normal speed and slow-motion
if (room_speed == 60) {
    /// Switch to slow-motion (10 FPS)
    room_speed = 10;
    exit;
} else {
    /// Switch back to normal speed (60 FPS)
    room_speed = 60;
}


