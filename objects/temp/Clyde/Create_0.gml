/// ===============================================================================
/// CLYDE GHOST OBJECT - CREATE EVENT
/// ===============================================================================
/// Description: Initializes Clyde (Pokey/Orange Ghost)
/// Personality: Cowardly/Random - chases Pac normally unless close, then flees
/// Scatter Corner: Bottom-left (32, 416)
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
xstart = 248;
ystart = 272;

// ===== PATHFINDING & BEHAVIOR =====
/// Target pursuit X coordinate (Pac when far, scatter when close)
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
/// Elroy threshold: when dots <= this value, Clyde enters faster "Elroy" pursuit mode
elroydots = 244;
/// Corner X for scatter mode (bottom-left corner)
cornerx = 32;
/// Corner Y for scatter mode (bottom-left corner)
cornery = 416;

// ===== DIRECTION TRACKING =====
/// Current direction in degrees (0=right, 90=up, 180=left, 270=down)
direction = 0;
/// Cardinal direction: 0=right, 1=up, 2=left, 3=down (used for pathfinding)
dir = 0;
/// Fruit-related direction tracking (used during fruit chase modes)
fruity = 0;
/// Co-direction (secondary direction used in pathfinding logic)
codir = 0;
