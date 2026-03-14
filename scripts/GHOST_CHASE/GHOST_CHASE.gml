/// ===============================================================================
/// chase_object() - GHOST PATHFINDING ALGORITHM
/// ===============================================================================
/// Purpose: Determine the best direction for a ghost to move toward a target
/// Called: From ghost Step_2 event when at an intersection
/// Parameters:
///   - argument0: Current object X position (tilex)
///   - argument1: Current object Y position (tiley)
///   - argument2: Target X coordinate (chasex/pursuex)
///   - argument3: Target Y coordinate (chasey/pursuey)
/// Returns: 0 (sets global 'dir' variable instead)
///
/// Algorithm:
/// This implements a greedy pathfinding algorithm that:
/// 1. Checks for special collision zones (NoUp, Up, Left, Down, Right)
/// 2. Determines target quadrant relative to current position
/// 3. Calculates which direction is closer (Manhattan distance)
/// 4. Checks for wall collisions before choosing direction
/// 5. Uses codir flag for alternative path selection
///
/// Direction Priority:
/// - Primary: Direction that gets closest to target
/// - Secondary: Alternative direction if primary blocked
/// - Tertiary: Fallback direction if both blocked
///
/// Used by: All ghosts (Blinky, Pinky, Inky, Clyde) and Fruit object
/// ===============================================================================

function chase_object(argument0, argument1, argument2, argument3) {
	
    /// Only process when object is within valid horizontal bounds
    /// Avoids edge cases where wraparound occurs
    if (x > 8 && x < (room_width - 8)) {
        /// Extract parameters into local variables
        var objx   = argument0;   // Current object X (tile position)
        var objy   = argument1;   // Current object Y (tile position)
        var chasex = argument2;   // Target X coordinate
        var chasey = argument3;   // Target Y coordinate
        
        // ===== SPECIAL COLLISION ZONE: NO UP =====
        /// Some areas prohibit upward movement (e.g., ghost house entrance)
        /// If in NoUp zone and not in eyes state, force horizontal movement
        if (ghost_chase_utils_no_up(objx, objy, chasex)) {
            return 0;
        }

        // ===== SPECIAL COLLISION ZONES: FORCED DIRECTIONS =====
        /// Some areas force specific directions (e.g., tunnels, exits)
        /// These take priority over normal pathfinding
        if (ghost_chase_utils_forced_zones(objx, objy)) {
            return 0;
        }

        // ===== NORMAL PATHFINDING =====
        /// No special zones - use data-driven greedy pathfinding algorithm
        ghost_chase_pathfinding(objx, objy, chasex, chasey, codir, direction);
    }
}
