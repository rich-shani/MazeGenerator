/// ===============================================================================
/// PAC-MAN ENUMERATION & CONSTANT DEFINITIONS
/// ===============================================================================
/// Purpose: Define all enums and constants used by the Pac object
/// This ensures consistency and self-documenting code throughout the project
///
/// Enums defined:
/// - PAC_STATE: Pac's life/death states
/// - PAC_FRIGHT: Power pellet mode states
/// - PAC_CORNER: Turn corner transition states (1-8)
/// - PAC_DIRECTION: Cardinal direction values
/// - SIREN_LEVEL: Background music siren levels (0-4)
/// ===============================================================================

// ===== PAC STATE ENUMERATION =====
/// Represents Pac's current state (alive, dying, dead, game over)
/// Used throughout Pac object for state management
enum PAC_STATE {
    ALIVE = 0,          /// Pac is playing normally, moving and eating
    DYING = 1,          /// Pac has been hit, death animation playing
    DEAD = 2,           /// Pac fully dead, transitioning to next life
    DEAD_FINAL = 3      /// Final death state, game over or life lost
}

// ===== PAC FRIGHT MODE ENUMERATION =====
/// Represents whether power pellet is active
/// When ACTIVE, Pac can eat ghosts and moves faster
enum PAC_FRIGHT {
    OFF = 0,            /// Normal mode, ghosts are dangerous
    ACTIVE = 1          /// Power pellet active, ghosts are vulnerable
}

// ===== PAC CORNER TRANSITION ENUMERATION =====
/// Represents which corner direction Pac is transitioning
/// Values 1-8 represent the 8 possible smooth turning scenarios
/// Used to smoothly turn Pac at intersections
enum PAC_CORNER {
    NONE = 0,           /// No corner transition active
    UP_TO_RIGHT_PRE = 1,    /// Coming from UP, turning RIGHT (before alignment)
    UP_TO_RIGHT_POST = 2,   /// Coming from UP, turning RIGHT (after alignment)
    RIGHT_TO_UP_PRE = 3,    /// Coming from RIGHT, turning UP (before alignment)
    RIGHT_TO_UP_POST = 4,   /// Coming from RIGHT, turning UP (after alignment)
	
    DOWN_TO_LEFT_PRE = 5,   /// Coming from DOWN, turning LEFT (before alignment)
    DOWN_TO_LEFT_POST = 6,  /// Coming from DOWN, turning LEFT (after alignment)
    LEFT_TO_DOWN_PRE = 7,   /// Coming from LEFT, turning DOWN (before alignment)
    LEFT_TO_DOWN_POST = 8,   /// Coming from LEFT, turning DOWN (after alignment)
	
	DOWN_TO_RIGHT_PRE = 9,   /// Coming from DOWN, turning RIGHT (before alignment)
    DOWN_TO_RIGHT_POST = 10,  /// Coming from DOWN, turning RIGHT (after alignment)
    RIGHT_TO_DOWN_PRE = 11,   /// Coming from RIGHT, turning DOWN (before alignment)
    RIGHT_TO_DOWN_POST = 12,   /// Coming from RIGHT, turning DOWN (after alignment)
	
	UP_TO_LEFT_PRE = 13,    /// Coming from UP, turning LEFT (before alignment)
    UP_TO_LEFT_POST = 14,   /// Coming from UP, turning LEFT (after alignment)
    LEFT_TO_UP_PRE = 15,    /// Coming from LEFT, turning UP (before alignment)
    LEFT_TO_UP_POST = 16   /// Coming from LEFT, turning UP (after alignment)
}

// ===== PAC DIRECTION ENUMERATION =====
/// Cardinal direction representation (0-3)
/// Used for movement decisions and pathfinding
enum PAC_DIRECTION {
    RIGHT = 0,          /// Moving right (east, positive X)
    UP = 1,             /// Moving up (north, negative Y)
    LEFT = 2,           /// Moving left (west, negative X)
    DOWN = 3            /// Moving down (south, positive Y)
}

/// ===============================================================================
/// PAC_PLUS_MODE - Game variant modes (Pac-Man Plus variant)
/// ===============================================================================
enum PAC_PLUS_MODE {
	INACTIVE = 0,           /// Standard Pac-Man gameplay
	ACTIVE = 1              /// Pac-Man Plus variant with modified mechanics
}

// ===== SIREN LEVEL ENUMERATION =====
/// Represents which siren sound should play (0-4)
/// Siren intensifies as dots are collected (dots remaining decrease)
/// Level increases as Pac gets closer to collecting all dots
enum SIREN_LEVEL {
    LEVEL_0 = 0,        /// Slowest siren (most dots remaining)
    LEVEL_1 = 1,        /// Slow siren
    LEVEL_2 = 2,        /// Medium siren
    LEVEL_3 = 3,        /// Fast siren
    LEVEL_4 = 4         /// Fastest siren (fewest dots remaining)
}

// ===== SPEED CONSTANTS =====
/// Define standard speeds as constants for consistency
/// Using #macro allows compile-time substitution

/// Normal movement speed (pixels per frame) - baseline speed
#macro SP_NORMAL 2

/// Power pellet mode speed (pixels per frame) - faster to escape ghosts
#macro SP_FRIGHT 3

/// Starting speed (for initialization)
#macro SP_INITIAL 0

// ===== GHOST INTERACTION PROHIBITION FLAGS =====
/// Used to track when ghost/Pac interaction should be disabled
/// Sometimes Pac and ghosts shouldn't interact (e.g., during specific power modes)
enum GHOST_PROHIBIT {
    ALLOWED = 0,        /// Normal interaction allowed
    PLAYER1_BLOCKED = 1,    /// Pac (Player 1) blocked from eating ghosts
    PLAYER2_BLOCKED = 2     /// Mac (Player 2) blocked from eating ghosts
}

// ===== ANIMATION STATE CONSTANTS =====
/// Control animation frame progression

/// Maximum animation frame for Pac sprite
#macro PAC_ANIM_MAX_FRAME 7

/// Speed multiplier for animation during boost mode
#macro ANIM_BOOST_MULTIPLIER 2

// ===== TIMING CONSTANTS =====
/// Frames/timers for various game events

/// Default ghost release timer starting value
#macro GHOST_RELEASE_TIMER_START 60

/// Chomp animation duration (frames)
#macro CHOMP_ANIMATION_DURATION 60

/// Level start delay (frames)
#macro LEVEL_START_DELAY 120

// ===== DOT COLLECTION CONSTANTS =====
/// Points and thresholds for dot collection

/// Points for eating a normal dot
#macro POINTS_DOT 10

/// Points for eating a power pellet
#macro POINTS_POWER_PELLET 50

/// Score threshold for extra life
#macro EXTRA_LIFE_THRESHOLD 10000

// ===== GHOST EATING MULTIPLIER =====
/// Points for eating ghosts increase with each consecutive eat
/// Ghost 1 = 200, Ghost 2 = 400, Ghost 3 = 800, Ghost 4 = 1600
/// These can be affected by bonus modes (oPacman.pluseat  multiplier)

#macro CHOMP_1 200
#macro CHOMP_2 400
#macro CHOMP_3 800
#macro CHOMP_4 1600

// ===== BONUS MODE MULTIPLIER =====
/// When bonus multiplier is active (oPacman.pluseat  = 1), all ghost eating scores double
#macro CHOMP_BONUS_MULTIPLIER 2

/// ===============================================================================
/// END PAC ENUMERATION DEFINITIONS
/// ===============================================================================
