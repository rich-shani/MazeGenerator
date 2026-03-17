/// ===============================================================================
/// PINKY GHOST OBJECT - CREATE EVENT
/// ===============================================================================
/// Description: Initializes Pinky (Speedy/Pink Ghost)
/// Personality: Ambusher - targets 4 tiles ahead of Pac (ambush tactic)
/// Scatter Corner: Top-right (416, 32)
///
/// Features:
/// - AI chase/scatter/frightened behavior
/// - Grid-based pathfinding with tile tracking
/// - Elroy (faster pursuit) mode when dots are low
/// - Power pellet vulnerability
/// - Smooth animation with sprite flashing
/// ===============================================================================

// ===== ANIMATION VARIABLES =====
/// Animation frame index for sprite animation
im = 0;
/// Flash state when frightened (for visibility toggling)
flash = 0;

// ===== POSITION TRACKING =====
/// Current tile coordinates (16-pixel grid aligned)
tilex = 0;
tiley = 0;
/// Starting position (for reset/respawn)
xstart = 216;
ystart = 272;

// ===== PATHFINDING & BEHAVIOR =====
/// Target pursuit X coordinate (4 tiles ahead of Pac)
pursuex = 0;
/// Target pursuit Y coordinate
pursuey = 0;
/// House state: 0=released, 1=in ghost house
house = 0;
/// New tile flag: signals when ghost reaches a new tile for pathfinding update
newtile = 0;
/// About-face flag: when 1, ghost reverses direction (used for power pellet mode)
aboutface = 0;

// ===== AI STATE MACHINE =====
/// Ghost state: 0=chase, 1=frightened, 2=eyes returning to house, 3+=special
state = 0;
/// Elroy threshold: when dots <= this value, Pinky enters faster "Elroy" pursuit mode
elroydots = 244;
/// Corner X for scatter mode (top-right corner)
cornerx = 416;
/// Corner Y for scatter mode (top-right corner)
cornery = 32;

// ===== DIRECTION TRACKING =====
/// Current direction in degrees (0=right, 90=up, 180=left, 270=down)
direction = 0;
/// Cardinal direction: 0=right, 1=up, 2=left, 3=down (used for pathfinding)
dir = 0;
/// Fruit-related direction tracking (used during fruit chase modes)
fruity = 0;
/// Co-direction (secondary direction used in pathfinding logic)
codir = 0;
