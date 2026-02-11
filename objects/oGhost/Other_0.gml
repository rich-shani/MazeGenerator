/// ===============================================================================
/// oGHOST - BASE GHOST OBJECT - OTHER_0 EVENT (TUNNEL WRAPAROUND)
/// ===============================================================================
/// Purpose: Handle horizontal wraparound when ghost enters tunnel
/// Triggered: When ghost moves through left or right edge (wall collision)
/// Other_0 is a special event triggered by wall/collision objects
///
/// Tunnel Wraparound:
/// - Tunnel on left: x < -24 (completely off left edge)
/// - Tunnel on right: x > room_width + 24 (completely off right edge)
/// - Ghost appears on opposite side instantly
/// - Tile position recalculated after wraparound
///
/// This is identical for all ghosts (no child override needed)
/// ===============================================================================

/// ===== LEFT TUNNEL WRAPAROUND =====
/// When ghost exits left side of tunnel, wrap to right side
/// Check if moving LEFT (hspeed < 0) and went past left edge

if (hspeed < 0) {
    /// Moving left and went off left edge
    /// Teleport to right side

    x = (room_width + 24) - (x + 24);
    /// New X = room_width+24 minus how far off we went
    /// Example: if x = -30 (6 pixels past -24), new x = room_width+24 - (6) = room_width+18

    /// Update tile position after wraparound
    tilex = 16 * (round(x / 16));

	/// Clear pathfinding to recalculate path from new position
	newtile = 0;
}

/// ===== RIGHT TUNNEL WRAPAROUND =====
/// When ghost exits right side of tunnel, wrap to left side
/// Check if moving RIGHT (hspeed > 0) and went past right edge

if (hspeed > 0) {
    /// Moving right and went off right edge
    /// Teleport to left side

    x = -24 + (x - (room_width + 24));
    /// New X = -24 Pac.plus how far off we went
    /// Example: if x = room_width+30 (6 pixels past), new x = -24 + 6 = -18

    /// Update tile position after wraparound
    tilex = 16 * (round(x / 16));

	/// Clear pathfinding to recalculate path from new position
	newtile = 0;
}

/// ===============================================================================
/// END oGHOST OTHER_0 EVENT
/// ===============================================================================
