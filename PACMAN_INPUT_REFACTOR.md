# oPacman Input System Refactoring

## Overview

The oPacman input system has been refactored to follow the **GHOST_CHASE** architecture pattern:
- **Modular utilities** for common operations (wall checks, boundary validation)
- **Specialized handlers** for direction-specific logic
- **Clean orchestration** in the main input function
- **Enhanced maintainability** and code readability

## Architecture Pattern

The refactored system mirrors the GHOST_CHASE design:

```
┌─────────────────────────────────────┐
│   pacman_handle_input()             │  ORCHESTRATOR
│   (in PACMAN_INPUT_SIMPLE.gml)      │  - Validates state
└────────────┬────────────────────────┘  - Delegates work
             │
             ├─→ pacman_utils_* functions      UTILITIES
             │   (in PACMAN_INPUT_UTILS.gml)   - Wall checks
             │   - can_move_to()               - Boundary checks
             │   - can_move_direction()        - Grid math
             │   - is_at_vertical_bounds()     - State validation
             │   - is_at_intersection()
             │   - etc.
             │
             └─→ pacman_handle_direction_*()  HANDLERS
                 (in PACMAN_DIRECTION_HANDLER.gml)
                 - RIGHT/UP/LEFT/DOWN
                 - Direction-specific corner logic
                 - Velocity application
```

## File Structure

### 1. PACMAN_INPUT_UTILS.gml
**Purpose**: Centralized validation and wall-checking utilities

**Key Functions**:

| Function | Purpose |
|----------|---------|
| `pacman_utils_can_move_to(x, y)` | Check if tile position is free of walls |
| `pacman_utils_can_move_direction(x, y, dir)` | Check if adjacent tile in direction is clear |
| `pacman_utils_is_at_vertical_bounds()` | Valid for UP/DOWN movement |
| `pacman_utils_is_at_horizontal_bounds()` | Valid for LEFT/RIGHT movement |
| `pacman_utils_is_in_valid_state()` | Pac alive, not paused, not eating |
| `pacman_utils_is_at_intersection()` | Corner state is NONE |
| `pacman_utils_get_grid_position(pixel_pos)` | Convert pixel to grid coordinates |
| `pacman_utils_get_offset(pixel_pos, grid_pos)` | Calculate distance from grid center |
| `pacman_utils_is_before_grid(pixel, grid, dir)` | Check alignment offset |
| `pacman_utils_buffer_input(direction)` | Store input for later |
| `pacman_utils_clear_buffered_input()` | Clear buffered input |

### 2. PACMAN_DIRECTION_HANDLER.gml
**Purpose**: Direction-specific input processing with corner logic

**Key Functions**:

| Function | Handles |
|----------|---------|
| `pacman_handle_direction_right(spd)` | RIGHT arrow key + corners |
| `pacman_handle_direction_up(spd)` | UP arrow key + corners |
| `pacman_handle_direction_left(spd)` | LEFT arrow key + corners |
| `pacman_handle_direction_down(spd)` | DOWN arrow key + corners |
| `pacman_handle_all_directions(spd)` | Orchestrates all 4 directions |

**Each handler**:
1. Checks appropriate boundary conditions
2. Validates single key press (no diagonal)
3. Checks wall collision at next tile
4. Initiates movement with corner state OR buffers input

### 3. PACMAN_INPUT_SIMPLE.gml (Refactored)
**Purpose**: Main input orchestration (now clean and minimal)

```gml
function pacman_handle_input() {
    if (!pacman_utils_is_in_valid_state()) return;
    if (!pacman_utils_is_at_intersection()) return;

    var _spd = pacman_get_speed();
    pacman_handle_all_directions(_spd);
}
```

**Before**: 160+ lines of nested if-statements
**After**: 10 lines of clean orchestration

## Wall Collision Validation

### Collision Detection Pattern

The system validates movement using **grid-based tile checks**:

```gml
// Check if next tile in a direction is free
pacman_utils_can_move_direction(current_x, current_y, direction)
├─ Calculates next tile position based on direction
│  - RIGHT: x + 16
│  - LEFT:  x - 16
│  - UP:    y - 16
│  - DOWN:  y + 16
└─ Calls: collision_point(next_tile_x, next_tile_y, Wall, false, true)
   Returns: true if clear, false if wall present
```

### Boundary Conditions

Movement is restricted based on position:

| Direction | Boundary Check |
|-----------|----------------|
| UP / DOWN | `x > 8 && x < room_width - 8` |
| LEFT / RIGHT | `y > 48 && y < room_height - 48` |

This prevents tunneling through walls at room edges.

### Prevention of Moving Into Wall Tiles

The system ensures Pac **cannot enter a Wall tile** through:

1. **Pre-movement validation** (before velocity is applied):
   ```gml
   if (pacman_utils_can_move_direction(grid_x, grid_y, PAC_DIRECTION.RIGHT)) {
       // Path is clear - apply movement
       hspeed = _spd;
   }
   else {
       // Wall blocks this direction - buffer input instead
       pacman_utils_buffer_input(PAC_DIRECTION.RIGHT);
   }
   ```

2. **Grid-aligned positioning** (in PACMAN_MOVEMENT.gml):
   ```gml
   tilex = 16 * (round(x / 16));  // Always snap to grid boundaries
   tiley = 16 * (round(y / 16));
   ```

3. **Corner completion snapping** (in PACMAN_CORNER.gml):
   ```gml
   if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
       if (y < 16 * (round(y / 16))) {
           y = 16 * (round(y / 16));  // Force exact grid alignment
   ```

## Corner Turning System

### 16-State Corner Logic

When Pac tries to change direction while moving:

1. **Detect alignment offset** using `pacman_utils_is_before_grid()`:
   ```gml
   var _grid_y = pacman_utils_get_grid_position(y);
   if (pacman_utils_is_before_grid(y, _grid_y, PAC_DIRECTION.UP)) {
       // Before center = PRE state (approaching grid line)
       corner = PAC_CORNER.UP_TO_RIGHT_PRE;
   }
   else {
       // After center = POST state (passing grid line)
       corner = PAC_CORNER.UP_TO_RIGHT_POST;
   }
   ```

2. **Apply diagonal velocity** during transition:
   ```gml
   hspeed = _spd;   // Horizontal component
   vspeed = -_spd;  // Vertical component (diagonal movement)
   ```

3. **Complete in Step_2** when grid alignment reached:
   ```gml
   if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
       if (y < 16 * (round(y / 16))) {
           y = 16 * (round(y / 16));  // Snap to grid
           hspeed = _spd;
           vspeed = 0;                 // Pure cardinal velocity
           corner = PAC_CORNER.NONE;
       }
   }
   ```

## Input Buffering

When Pac tries to move into a wall, the input is **buffered** and applied at the next valid intersection:

```
Frame 1: Player presses RIGHT
├─ Check RIGHT → Wall blocks → buffer input
└ park = PAC_DIRECTION.RIGHT

Frame 2-N: Continue moving UP
└ (nothing happens with buffered RIGHT)

Frame N+1: Reach intersection, LEFT/RIGHT is clear
├─ Check if buffered input (park != -1)
└ Apply: dir = park, park = -1
```

This creates the **classic Pac-Man feel** where early input doesn't get lost.

## Validation Flow

Every input goes through this validation sequence:

```
pacman_handle_input()
├─ Check: Alive? → if dead/dying/dead_final, exit
├─ Check: No ghost-eating animation? → if chomp > 0, exit
├─ Check: Not paused? → if pause > 0, exit
├─ Check: Not suspended? → if stoppy > 0, exit
├─ Check: At intersection? → if corner != NONE, exit
│
└─ For each direction (RIGHT, UP, LEFT, DOWN):
   ├─ Check: Boundary condition valid?
   │  - RIGHT/LEFT need: y in [48, room_height-48)
   │  - UP/DOWN need: x in [8, room_width-8)
   ├─ Check: Single key pressed? (no diagonal)
   ├─ Check: Wall collision?
   │  - If clear: apply movement & set corner state
   │  - If blocked: buffer input
   └─ Continue to next direction
```

## Key Improvements Over Original

| Aspect | Before | After |
|--------|--------|-------|
| **Lines of code** | 160+ | 10 (main) + 40 (utilities) + 140 (handlers) |
| **Code duplication** | Wall check repeated 4x | Single `can_move_direction()` |
| **Boundary logic** | Inline repeats | Single utility functions |
| **Corner logic** | Nested in each direction | Shared across handlers |
| **Maintainability** | Hard to modify | Change one utility = fixes all |
| **Testability** | Difficult to isolate | Test utilities independently |
| **Readability** | Cognitive load high | Pattern obvious at a glance |

## Testing Checklist

- [x] Movement in all 4 directions
- [x] Wall collision blocks movement
- [x] Buffered input applies at intersections
- [x] Corner turning works (all 8 combinations)
- [x] Boundary conditions prevent tunneling
- [x] Grid alignment always perfect
- [x] Speed respects fright mode
- [x] Pause/dead states block input

## Code Examples

### Example 1: Checking If RIGHT Is Available

```gml
// Utils function
var _grid_x = pacman_utils_get_grid_position(x);
var _grid_y = pacman_utils_get_grid_position(y);

if (pacman_utils_can_move_direction(_grid_x, _grid_y, PAC_DIRECTION.RIGHT)) {
    // Clear to move right
}
```

### Example 2: Handling Corner with Direction Change

```gml
// In pacman_handle_direction_up()
if (direction == 0 && hspeed != 0) {  // Moving RIGHT, pressing UP
    if (pacman_utils_is_before_grid(x, _grid_x, PAC_DIRECTION.RIGHT)) {
        // Before center
        corner = PAC_CORNER.RIGHT_TO_UP_PRE;
        hspeed = _spd;
        vspeed = -_spd;  // Diagonal movement
    }
    else {
        // After center
        corner = PAC_CORNER.RIGHT_TO_UP_POST;
        hspeed = -_spd;
        vspeed = -_spd;
    }
}
```

### Example 3: Buffering Input

```gml
if (pacman_utils_can_move_direction(_grid_x, _grid_y, PAC_DIRECTION.LEFT)) {
    // Path clear - move
    dir = PAC_DIRECTION.LEFT;
    pacman_utils_clear_buffered_input();
    hspeed = -_spd;
    vspeed = 0;
}
else {
    // Path blocked - buffer for later
    pacman_utils_buffer_input(PAC_DIRECTION.LEFT);
}
```

## Related Files

- **PACMAN_MOVEMENT.gml**: Handles tile position tracking and corner completion
- **PACMAN_CORNER.gml**: Completes 16 corner transition states
- **PACMAN_STATE.gml**: Enum definitions (PAC_DIRECTION, PAC_CORNER, etc.)
- **GHOST_CHASE_UTILS.gml**: Similar pattern for ghost AI (reference architecture)

## Conclusion

The refactored input system:
- ✅ Follows proven GHOST_CHASE architecture pattern
- ✅ Validates all wall collisions before movement
- ✅ Prevents Pac from entering Wall tiles
- ✅ Maintains 16-state corner turning smoothness
- ✅ Reduces code duplication significantly
- ✅ Improves readability and maintainability
- ✅ Makes future changes easier and safer
