/// ===============================================================================
/// MAZE_GENERATION_CONSTANTS - Probability and limit constants for maze generation
/// ===============================================================================
/// Centralized constants for the maze generation algorithm.
/// These control piece growth, wall joining, and tunnel creation behavior.
/// ===============================================================================

// ============================================================================
// PIECE GROWTH PROBABILITIES
// ============================================================================

/// @description Probability array for stopping growth at each piece size
/// Index = current piece size (0-5), Value = probability to stop growing (0.0-1.0)
/// - Size 0-1: 0% chance to stop (always keep growing)
/// - Size 2: 10% chance to stop (mostly keep growing)
/// - Size 3: 50% chance to stop (medium-sized pieces common)
/// - Size 4: 75% chance to stop (larger pieces less frequent)
/// - Size 5+: 100% chance to stop (enforced maximum)
#macro PROB_STOP_AT_SIZE_0 0.0
#macro PROB_STOP_AT_SIZE_1 0.0
#macro PROB_STOP_AT_SIZE_2 0.1
#macro PROB_STOP_AT_SIZE_3 0.5
#macro PROB_STOP_AT_SIZE_4 0.75
#macro PROB_STOP_AT_SIZE_5 1.0

/// @description Probability that a single top/bottom edge cell creates a stub connection
/// Creates small "nubs" on maze edges for visual variety (0.0-1.0)
#macro PROB_TOP_BOT_SINGLE_CELL_JOIN 0.35

/// @description Probability that a size-2 piece attempts to extend
/// Controls how often small pieces grow into medium pieces (0.0-1.0)
#macro PROB_EXTEND_AT_SIZE_2 0.5

/// @description Probability that a size-3 or size-4 piece attempts to extend
/// Controls how often medium/large pieces continue growing (0.0-1.0)
#macro PROB_EXTEND_AT_SIZE_3_OR_4 0.5

/// @description Maximum number of "long" pieces (4-5 cells in straight line) allowed
/// Limits repetitive long corridors to maintain visual variety
#macro MAX_LONG_PIECES 1

// ============================================================================
// WALL JOINING PROBABILITIES
// ============================================================================

/// @description Probability that an edge cell joins to the outer border (top/bottom rows)
/// Creates more interesting wall structures by connecting isolated cells (0.0-1.0)
#macro PROB_WALL_JOIN_EDGE 0.25

/// @description Probability that a right column cell joins to adjacent walls
/// Controls wall connectivity on the right side of the maze (0.0-1.0)
#macro PROB_WALL_JOIN_RIGHT 0.5

// ============================================================================
// TUNNEL CREATION PROBABILITIES
// ============================================================================

/// @description Probability of creating 2 tunnels instead of 1
/// 0.45 = 45% chance of 2 tunnels, 55% chance of 1 tunnel
#macro PROB_TWO_TUNNELS 0.45
