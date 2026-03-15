/// ===============================================================================
/// ALARM_9 - DEDUCT LIFE FROM PLAYER(S)
/// ===============================================================================
/// Purpose: Reduce the life count for active players after Pac death
/// Called: When Pac-Man dies and loses a life
///
/// Triggers:
/// - Always deducts one life from Player 1
/// - If two-player mode active, also deducts one life from Player 2
/// ===============================================================================

/// Deduct one life from Player 1
global.p1lives = global.p1lives - 1;

/// If two-player mode, also deduct one life from Player 2
if (global.players > 0) {
    global.p2lives = global.p2lives - 1;
}

