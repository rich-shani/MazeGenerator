/// ===============================================================================
/// ALARM_4 - PLAYER COLLISION RECOVERY
/// ===============================================================================
/// Purpose: Recover from player-player collision knockback state
/// Called: After brief collision duration (10 frames)
///
/// Behavior:
/// - bonked = 1: Currently in collision/knockback
/// - bonked = 2: Collision processed, can move normally again
/// ===============================================================================

if (bonked == 1) {
    bonked = 2;
}

