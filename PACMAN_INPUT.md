# oPacman Movement and Cornering Implementation Plan

## Overview

Add keyboard-controlled movement and 16-state corner-turning logic to oPacman by extracting and refactoring core logic from `objects/temp/Pac`. This creates a clean, function-based architecture focused solely on **movement + cornering** (no dots, ghosts, audio, or other game logic).

---

## User Requirements

✅ **Scope**: Movement + cornering ONLY
✅ **Approach**: Refactor into functions (not monolithic Step events)
✅ **Speed Init**: Self-contained values in Create (sp=2, spfright=2.5)

---

## Files to Modify/Create

### 1. Modify Existing File

**`objects/oPacman/Create_0.gml`** (lines 221-222)
- Add 4 missing variables for movement tracking
- Update speed initialization from 0 to real values

### 2. Create New Script Files

**`scripts/PACMAN_MOVEMENT/PACMAN_MOVEMENT.gml`** (NEW)
- 3 helper functions for position tracking and speed management

**`scripts/PACMAN_CORNER/PACMAN_CORNER.gml`** (NEW)
- 1 function handling all 16 corner completion states

**`scripts/PACMAN_INPUT_SIMPLE/PACMAN_INPUT_SIMPLE.gml`** (NEW)
- 2 functions for keyboard input and wall collision checking

### 3. Create New Event Files

**`objects/oPacman/Step_1.gml`** (NEW)
- Input processing and position tracking (~15 lines)

**`objects/oPacman/Step_2.gml`** (NEW)
- Corner completion and pause/stoppy handling (~30 lines)

---

## Implementation Steps

### STEP 1: Update Create_0.gml Variables

**File**: `objects/oPacman/Create_0.gml`

**Changes**:

1. **Add 4 missing variables** (insert after line 135, before `// Note: Game mode variables...`):

```gml
/// Animation frame index for Pac sprite (0-7 for mouth animation)
im = 0;

/// Direction Pac was eating in (0-7 = 8-way direction, -1 = not set)
/// Used during pause/stoppy states to restore movement direction
eatdir = -1;

/// Corner alignment counter
/// Tracks frames in corner transition to determine re-entry window
cornercheck = 0;

/// New tile flag for grid tracking
/// Set to 1 when entering new tile, 0 when aligned
newtile = 0;
```

2. **Update speed values** (lines 221-222):

```gml
sp = 2;          // Normal movement speed (2 pixels/frame)
spfright = 2.5;  // Fright mode speed (slightly faster)
```

**Rationale**:
- `im`, `eatdir`, `cornercheck`, `newtile` are used in movement logic but missing from current Create
- Speed values allow testing without oGameManager dependency
- Uses standard Pac-Man speeds (SP_NORMAL=2, SP_FRIGHT~3 from PACMAN_STATE.gml:95-98)

---

### STEP 2: Create PACMAN_MOVEMENT Script

**File**: `scripts/PACMAN_MOVEMENT/PACMAN_MOVEMENT.gml` (NEW)

**Purpose**: Helper functions for movement tracking

**Code**:

```gml
/// ===============================================================================
/// PACMAN_MOVEMENT - Movement Helper Functions
/// ===============================================================================

/// @function pacman_update_tile_position()
/// @description Updates grid-aligned tile coordinates and manages corner tracking
function pacman_update_tile_position() {
    if (corner == PAC_CORNER.NONE) {
        // Not in corner: snap to grid normally
        tilex = 16 * (round(x / 16));
        tiley = 16 * (round(y / 16));
    }
    else {
        // In corner: track alignment progress
        if (tilex != 16 * (round(x / 16))) {
            cornercheck = cornercheck + 1;
        }
        if (tiley != 16 * (round(y / 16))) {
            cornercheck = cornercheck + 1;
        }
    }
}

/// @function pacman_get_speed()
/// @description Returns appropriate movement speed based on fright mode
/// @return {real} Current speed value (sp or spfright)
function pacman_get_speed() {
    return (fright == PAC_FRIGHT.ACTIVE) ? spfright : sp;
}

/// @function pacman_update_direction_sync()
/// @description Sync GML direction variable with velocity
function pacman_update_direction_sync() {
    if (hspeed > 0 && vspeed == 0) {
        direction = 0;    // Moving right
    }
    else if (hspeed < 0 && vspeed == 0) {
        direction = 180;  // Moving left
    }
    else if (hspeed == 0 && vspeed < 0) {
        direction = 90;   // Moving up
    }
    else if (hspeed == 0 && vspeed > 0) {
        direction = 270;  // Moving down
    }
}
```

**Extracted From**:
- `pacman_update_tile_position()`: temp/Pac Step_1.gml lines 356-374
- `pacman_get_speed()`: Pattern from temp/Pac Step_2.gml lines 26-31
- `pacman_update_direction_sync()`: Simplified version of Step_0 direction logic

---

### STEP 3: Create PACMAN_CORNER Script

**File**: `scripts/PACMAN_CORNER/PACMAN_CORNER.gml` (NEW)

**Purpose**: Complete corner transitions when grid alignment reached

**Code**:

```gml
/// ===============================================================================
/// PACMAN_CORNER - Corner Completion Logic
/// ===============================================================================

/// @function pacman_complete_corners()
/// @description Complete corner transitions when grid alignment is reached
/// @return {bool} True if corner was completed this frame
function pacman_complete_corners() {
    var _spd = pacman_get_speed();

    // UP_TO_RIGHT transitions
    if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
        if (y < 16 * (round(y / 16))) {
            y = 16 * (round(y / 16));
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.UP_TO_RIGHT_POST) {
        if (y > 16 * (round(y / 16))) {
            y = 16 * (round(y / 16));
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // RIGHT_TO_UP transitions
    if (corner == PAC_CORNER.RIGHT_TO_UP_PRE) {
        if (x > 16 * (round(x / 16))) {
            x = 16 * (round(x / 16));
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.RIGHT_TO_UP_POST) {
        if (x < 16 * (round(x / 16))) {
            x = 16 * (round(x / 16));
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // DOWN_TO_LEFT transitions
    if (corner == PAC_CORNER.DOWN_TO_LEFT_PRE) {
        if (y > 16 * (round(y / 16))) {
            y = 16 * (round(y / 16));
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.DOWN_TO_LEFT_POST) {
        if (y < 16 * (round(y / 16))) {
            y = 16 * (round(y / 16));
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // LEFT_TO_DOWN transitions
    if (corner == PAC_CORNER.LEFT_TO_DOWN_PRE) {
        if (x < 16 * (round(x / 16))) {
            x = 16 * (round(x / 16));
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.LEFT_TO_DOWN_POST) {
        if (x > 16 * (round(x / 16))) {
            x = 16 * (round(x / 16));
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // DOWN_TO_RIGHT transitions
    if (corner == PAC_CORNER.DOWN_TO_RIGHT_PRE) {
        if (y > 16 * (round(y / 16))) {
            y = 16 * (round(y / 16));
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.DOWN_TO_RIGHT_POST) {
        if (y < 16 * (round(y / 16))) {
            y = 16 * (round(y / 16));
            hspeed = _spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // RIGHT_TO_DOWN transitions
    if (corner == PAC_CORNER.RIGHT_TO_DOWN_PRE) {
        if (x > 16 * (round(x / 16))) {
            x = 16 * (round(x / 16));
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.RIGHT_TO_DOWN_POST) {
        if (x < 16 * (round(x / 16))) {
            x = 16 * (round(x / 16));
            hspeed = 0;
            vspeed = _spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // UP_TO_LEFT transitions
    if (corner == PAC_CORNER.UP_TO_LEFT_PRE) {
        if (y < 16 * (round(y / 16))) {
            y = 16 * (round(y / 16));
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.UP_TO_LEFT_POST) {
        if (y > 16 * (round(y / 16))) {
            y = 16 * (round(y / 16));
            hspeed = -_spd;
            vspeed = 0;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    // LEFT_TO_UP transitions
    if (corner == PAC_CORNER.LEFT_TO_UP_PRE) {
        if (x < 16 * (round(x / 16))) {
            x = 16 * (round(x / 16));
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }
    if (corner == PAC_CORNER.LEFT_TO_UP_POST) {
        if (x > 16 * (round(x / 16))) {
            x = 16 * (round(x / 16));
            hspeed = 0;
            vspeed = -_spd;
            corner = PAC_CORNER.NONE;
            cornercheck = 0;
            return true;
        }
    }

    return false;  // No corner completed this frame
}
```

**Extracted From**: temp/Pac Step_2.gml lines 33-192 (direct copy with function wrapper)

---

### STEP 4: Create PACMAN_INPUT_SIMPLE Script

**File**: `scripts/PACMAN_INPUT_SIMPLE/PACMAN_INPUT_SIMPLE.gml` (NEW)

**Purpose**: Keyboard input handling focused on movement only

**Code**:

```gml
/// ===============================================================================
/// PACMAN_INPUT_SIMPLE - Movement Input Handling
/// ===============================================================================

/// @function pacman_check_wall_collision(check_x, check_y)
/// @description Check if there's a wall at the specified position
/// @param {real} check_x X coordinate to check
/// @param {real} check_y Y coordinate to check
/// @return {bool} True if wall collision detected
function pacman_check_wall_collision(check_x, check_y) {
    return collision_point(check_x, check_y, Wall, false, true);
}

/// @function pacman_handle_input()
/// @description Process keyboard input and manage corner turning
function pacman_handle_input() {
    // Skip if dead, in chomp animation, or paused
    if (dead >= PAC_STATE.DEAD || chomp > 0 || pause > 0 || stoppy > 0) {
        return;
    }

    // Skip if already in corner transition
    if (corner != PAC_CORNER.NONE) {
        return;
    }

    var _at_vertical_bounds = (y > 48 && y < room_height - 48);
    var _at_horizontal_bounds = (x > 8 && x < room_width - 8);
    var _spd = pacman_get_speed();

    // ===== RIGHT INPUT =====
    if (_at_vertical_bounds && keyboard_check(vk_right) &&
        !keyboard_check(vk_up) && !keyboard_check(vk_left) && !keyboard_check(vk_down)) {

        if (!pacman_check_wall_collision(16 * (round(x / 16)) + 17, 16 * (round(y / 16)))) {
            dir = PAC_DIRECTION.RIGHT;
            park = -1;

            // Check if we're currently moving vertically (need corner transition)
            if (direction == 90 && vspeed != 0) {  // Moving UP
                if (y > 16 * round(y / 16)) {
                    corner = PAC_CORNER.UP_TO_RIGHT_PRE;
                    hspeed = _spd;
                    vspeed = -_spd;
                }
                else {
                    corner = PAC_CORNER.UP_TO_RIGHT_POST;
                    hspeed = _spd;
                    vspeed = _spd;
                }
            }
            else if (direction == 270 && vspeed != 0) {  // Moving DOWN
                if (y < 16 * round(y / 16)) {
                    corner = PAC_CORNER.DOWN_TO_RIGHT_PRE;
                    hspeed = _spd;
                    vspeed = _spd;
                }
                else {
                    corner = PAC_CORNER.DOWN_TO_RIGHT_POST;
                    hspeed = _spd;
                    vspeed = -_spd;
                }
            }
            else {
                // Not turning, just move right
                hspeed = _spd;
                vspeed = 0;
            }
        }
        else {
            park = PAC_DIRECTION.RIGHT;  // Buffer input
        }
    }

    // ===== UP INPUT =====
    if (_at_horizontal_bounds && keyboard_check(vk_up) &&
        !keyboard_check(vk_right) && !keyboard_check(vk_left) && !keyboard_check(vk_down)) {

        if (!pacman_check_wall_collision(16 * (round(x / 16)), 16 * (round(y / 16)) - 1)) {
            dir = PAC_DIRECTION.UP;
            park = -1;

            if (direction == 0 && hspeed != 0) {  // Moving RIGHT
                if (x < 16 * round(x / 16)) {
                    corner = PAC_CORNER.RIGHT_TO_UP_PRE;
                    hspeed = _spd;
                    vspeed = -_spd;
                }
                else {
                    corner = PAC_CORNER.RIGHT_TO_UP_POST;
                    hspeed = -_spd;
                    vspeed = -_spd;
                }
            }
            else if (direction == 180 && hspeed != 0) {  // Moving LEFT
                if (x > 16 * round(x / 16)) {
                    corner = PAC_CORNER.LEFT_TO_UP_PRE;
                    hspeed = -_spd;
                    vspeed = -_spd;
                }
                else {
                    corner = PAC_CORNER.LEFT_TO_UP_POST;
                    hspeed = _spd;
                    vspeed = -_spd;
                }
            }
            else {
                hspeed = 0;
                vspeed = -_spd;
            }
        }
        else {
            park = PAC_DIRECTION.UP;
        }
    }

    // ===== LEFT INPUT =====
    if (_at_vertical_bounds && keyboard_check(vk_left) &&
        !keyboard_check(vk_up) && !keyboard_check(vk_right) && !keyboard_check(vk_down)) {

        if (!pacman_check_wall_collision(16 * (round(x / 16)) - 1, 16 * (round(y / 16)))) {
            dir = PAC_DIRECTION.LEFT;
            park = -1;

            if (direction == 90 && vspeed != 0) {  // Moving UP
                if (y > 16 * round(y / 16)) {
                    corner = PAC_CORNER.UP_TO_LEFT_PRE;
                    hspeed = -_spd;
                    vspeed = -_spd;
                }
                else {
                    corner = PAC_CORNER.UP_TO_LEFT_POST;
                    hspeed = -_spd;
                    vspeed = _spd;
                }
            }
            else if (direction == 270 && vspeed != 0) {  // Moving DOWN
                if (y < 16 * round(y / 16)) {
                    corner = PAC_CORNER.DOWN_TO_LEFT_PRE;
                    hspeed = -_spd;
                    vspeed = _spd;
                }
                else {
                    corner = PAC_CORNER.DOWN_TO_LEFT_POST;
                    hspeed = -_spd;
                    vspeed = -_spd;
                }
            }
            else {
                hspeed = -_spd;
                vspeed = 0;
            }
        }
        else {
            park = PAC_DIRECTION.LEFT;
        }
    }

    // ===== DOWN INPUT =====
    if (_at_horizontal_bounds && keyboard_check(vk_down) &&
        !keyboard_check(vk_right) && !keyboard_check(vk_left) && !keyboard_check(vk_up)) {

        if (!pacman_check_wall_collision(16 * (round(x / 16)), 16 * (round(y / 16)) + 17)) {
            dir = PAC_DIRECTION.DOWN;
            park = -1;

            if (direction == 0 && hspeed != 0) {  // Moving RIGHT
                if (x < 16 * round(x / 16)) {
                    corner = PAC_CORNER.RIGHT_TO_DOWN_PRE;
                    hspeed = _spd;
                    vspeed = _spd;
                }
                else {
                    corner = PAC_CORNER.RIGHT_TO_DOWN_POST;
                    hspeed = -_spd;
                    vspeed = _spd;
                }
            }
            else if (direction == 180 && hspeed != 0) {  // Moving LEFT
                if (x > 16 * round(x / 16)) {
                    corner = PAC_CORNER.LEFT_TO_DOWN_PRE;
                    hspeed = -_spd;
                    vspeed = _spd;
                }
                else {
                    corner = PAC_CORNER.LEFT_TO_DOWN_POST;
                    hspeed = _spd;
                    vspeed = _spd;
                }
            }
            else {
                hspeed = 0;
                vspeed = _spd;
            }
        }
        else {
            park = PAC_DIRECTION.DOWN;
        }
    }
}
```

**Extracted From**: PACMAN_INPUT.gml lines 50-268, simplified to remove dots/ghosts/audio logic

---

### STEP 5: Create Step_1.gml Event

**File**: `objects/oPacman/Step_1.gml` (NEW)

**Purpose**: Input processing and position tracking

**Code**:

```gml
/// ===============================================================================
/// oPacman STEP_1 - INPUT HANDLING & POSITION TRACKING
/// ===============================================================================
/// Purpose: Process keyboard input and update grid-aligned position
/// Called: Second each frame
/// ===============================================================================

// Update tile-aligned position for collision detection
pacman_update_tile_position();

// Process keyboard input only when alive and not paused
if (dead == PAC_STATE.ALIVE && stoppy == 0 && pause == 0) {
    pacman_handle_input();
}

// Sync direction variable with velocity
pacman_update_direction_sync();
```

---

### STEP 6: Create Step_2.gml Event

**File**: `objects/oPacman/Step_2.gml` (NEW)

**Purpose**: Corner completion and pause handling

**Code**:

```gml
/// ===============================================================================
/// oPacman STEP_2 - CORNER COMPLETION
/// ===============================================================================
/// Purpose: Complete corner transitions when grid alignment is reached
/// Called: Third each frame
/// ===============================================================================

// Complete any active corner transitions
if (corner != PAC_CORNER.NONE) {
    pacman_complete_corners();
}

// Handle pause state countdown
if (pause > 0) {
    pause = pause - 1;
}

// Restore movement after stoppy state (eating direction recovery)
if (stoppy > 0 && pause == 0 && chomp == 0) {
    var _spd = pacman_get_speed();

    // Restore movement based on eatdir (8-way direction)
    if (eatdir == 0) { hspeed = _spd; vspeed = 0; eatdir = -1; }          // Right
    else if (eatdir == 2) { hspeed = 0; vspeed = -_spd; eatdir = -1; }    // Up
    else if (eatdir == 4) { hspeed = -_spd; vspeed = 0; eatdir = -1; }    // Left
    else if (eatdir == 6) { hspeed = 0; vspeed = _spd; eatdir = -1; }     // Down

    stoppy = 0;
}
```

---

## Testing Strategy

### Test 1: Basic Movement
1. Open MazeGenerator.yyp in GameMaker Studio
2. Press F5 to run
3. Use arrow keys (←↑→↓) to move oPacman
4. **Expected**: Pac moves at 2 pixels/frame in 4 cardinal directions
5. **Expected**: Pac stops when hitting walls

### Test 2: Corner Turning
1. Move horizontally (→ or ←)
2. Press perpendicular arrow key (↑ or ↓) while moving
3. Observe smooth diagonal transition
4. **Expected**: Pac turns smoothly with diagonal movement, then snaps to grid

### Test 3: Buffered Input
1. Move toward a wall
2. Press perpendicular direction key before reaching wall
3. Verify turn executes when oPacman reaches the intersection
4. **Expected**: Direction stored in `park`, applied at next valid turn

### Test 4: All 8 Turn Combinations
Test each turn:
- UP → RIGHT, RIGHT → UP
- UP → LEFT, LEFT → UP
- DOWN → RIGHT, RIGHT → DOWN
- DOWN → LEFT, LEFT → DOWN

**Expected**: All turns smooth with proper diagonal movement

---

## Success Criteria

✅ oPacman responds to arrow key input
✅ Movement blocked by Wall objects
✅ Smooth corner turning with diagonal transitions
✅ Grid-aligned position tracking (tilex/tiley)
✅ Buffered input system works (`park` variable)
✅ Speed adjusts based on fright mode
✅ All 16 corner states function correctly
✅ No errors in GameMaker console
✅ Clean, function-based architecture (<50 lines total in Step events)
