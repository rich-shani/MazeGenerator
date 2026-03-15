# PACMAN_INPUT_UTILS & PACMAN_DIRECTION_HANDLER - API Reference

## PACMAN_INPUT_UTILS.gml

Centralized utilities for wall checking, boundary validation, and grid math.

### Wall & Collision Functions

#### `pacman_utils_can_move_to(tile_x, tile_y)`
Check if a specific tile position is free of Wall objects.

**Parameters:**
- `tile_x` (real): X coordinate to check (grid-aligned, typically 16px increments)
- `tile_y` (real): Y coordinate to check (grid-aligned, typically 16px increments)

**Returns:** `bool` - `true` if position is clear of walls, `false` if blocked

**Usage:**
```gml
if (pacman_utils_can_move_to(176, 208)) {
    // Safe to move to this tile
}
```

**Implementation:**
```gml
return !collision_point(tile_x, tile_y, Wall, false, true);
```

---

#### `pacman_utils_can_move_direction(current_x, current_y, direction)`
Check if Pac can move in a specific cardinal direction from current position.

**Parameters:**
- `current_x` (real): Current grid-aligned X position
- `current_y` (real): Current grid-aligned Y position
- `direction` (PAC_DIRECTION enum): Direction to check
  - `PAC_DIRECTION.RIGHT` (0) - Check tile to the right
  - `PAC_DIRECTION.UP` (1) - Check tile above
  - `PAC_DIRECTION.LEFT` (2) - Check tile to the left
  - `PAC_DIRECTION.DOWN` (3) - Check tile below

**Returns:** `bool` - `true` if next tile in direction is clear, `false` if blocked

**Usage:**
```gml
var _grid_x = pacman_utils_get_grid_position(x);
var _grid_y = pacman_utils_get_grid_position(y);

if (pacman_utils_can_move_direction(_grid_x, _grid_y, PAC_DIRECTION.UP)) {
    // Tile above is clear - safe to move up
}
```

**Algorithm:**
```gml
1. Calculate next tile position based on direction
   - RIGHT: next_x = current_x + 16
   - UP: next_y = current_y - 16
   - LEFT: next_x = current_x - 16
   - DOWN: next_y = current_y + 16
2. Call pacman_utils_can_move_to(next_x, next_y)
3. Return result
```

---

### Boundary Validation Functions

#### `pacman_utils_is_at_vertical_bounds()`
Check if Pac is within the valid Y range for UP/DOWN movement.

**Parameters:** None

**Returns:** `bool` - `true` if within bounds, `false` if at edge

**Valid Range:** `y > 48 && y < room_height - 48`

**Usage:**
```gml
if (pacman_utils_is_at_vertical_bounds()) {
    // Can safely move up or down
}
```

---

#### `pacman_utils_is_at_horizontal_bounds()`
Check if Pac is within the valid X range for LEFT/RIGHT movement.

**Parameters:** None

**Returns:** `bool` - `true` if within bounds, `false` if at edge

**Valid Range:** `x > 8 && x < room_width - 8`

**Usage:**
```gml
if (pacman_utils_is_at_horizontal_bounds()) {
    // Can safely move left or right
}
```

---

### State Validation Functions

#### `pacman_utils_is_in_valid_state()`
Check if Pac is in a state where movement input should be processed.

**Parameters:** None

**Returns:** `bool` - `true` if can accept input, `false` if blocked

**Conditions Checked:**
- `dead == PAC_STATE.ALIVE` (not dead/dying/gone)
- `chomp == 0` (not eating a ghost)
- `pause == 0` (not paused)
- `stoppy == 0` (not suspended - e.g., eating dot)

**Usage:**
```gml
if (!pacman_utils_is_in_valid_state()) {
    return;  // Don't process input
}
// Safe to process movement commands
```

---

#### `pacman_utils_is_at_intersection()`
Check if Pac is at a grid intersection (ready for new movement direction).

**Parameters:** None

**Returns:** `bool` - `true` if at intersection (`corner == NONE`), `false` if in corner transition

**Usage:**
```gml
if (!pacman_utils_is_at_intersection()) {
    return;  // In corner transition, skip input
}
// Safe to process new direction input
```

---

### Grid Math Functions

#### `pacman_utils_get_grid_position(pixel_pos)`
Convert pixel coordinate to grid-aligned position.

**Parameters:**
- `pixel_pos` (real): Pixel coordinate (x or y, doesn't matter)

**Returns:** `real` - Grid-aligned coordinate (rounded to nearest 16px multiple)

**Formula:** `16 * (round(pixel_pos / 16))`

**Usage:**
```gml
var _grid_x = pacman_utils_get_grid_position(x);  // e.g., 147 → 144
var _grid_y = pacman_utils_get_grid_position(y);  // e.g., 210 → 208
```

**Grid Points:** 0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, ...

---

#### `pacman_utils_get_offset(pixel_pos, grid_pos)`
Calculate offset (distance) from grid center.

**Parameters:**
- `pixel_pos` (real): Current pixel position
- `grid_pos` (real): Grid center position

**Returns:** `real` - Offset in pixels
  - Negative values: before grid line
  - Positive values: after grid line
  - Zero: exactly at grid line

**Usage:**
```gml
var _offset = pacman_utils_get_offset(y, 208);
if (_offset < 0) {
    // Below grid center (approaching)
}
else if (_offset > 0) {
    // Above grid center (past)
}
```

---

#### `pacman_utils_is_before_grid(pixel_pos, grid_pos, direction)`
Check if position is before the grid line in a given direction.

**Parameters:**
- `pixel_pos` (real): Current position
- `grid_pos` (real): Grid center position
- `direction` (PAC_DIRECTION enum): Movement direction
  - `PAC_DIRECTION.RIGHT` or `DOWN` - Check if `<` center
  - `PAC_DIRECTION.UP` or `LEFT` - Check if `>` center

**Returns:** `bool` - `true` if before grid line, `false` if after

**Usage (Corner Turning):**
```gml
// Moving UP, turning RIGHT
var _grid_y = pacman_utils_get_grid_position(y);

if (pacman_utils_is_before_grid(y, _grid_y, PAC_DIRECTION.UP)) {
    // Below grid line (y < 208) → approaching center
    corner = PAC_CORNER.UP_TO_RIGHT_PRE;   // PRE state
    vspeed = -2;  // Move toward grid
}
else {
    // Above grid line (y > 208) → past center
    corner = PAC_CORNER.UP_TO_RIGHT_POST;  // POST state
    vspeed = 2;   // Move away from grid (wrapping)
}
```

---

### Input Buffering Functions

#### `pacman_utils_clear_buffered_input()`
Clear any queued direction input.

**Parameters:** None

**Returns:** Nothing

**Effect:** Sets `park = -1`

**Usage:**
```gml
// Movement successful
dir = PAC_DIRECTION.RIGHT;
pacman_utils_clear_buffered_input();  // park = -1
```

---

#### `pacman_utils_buffer_input(direction)`
Store a direction for later execution.

**Parameters:**
- `direction` (PAC_DIRECTION enum): Direction to buffer

**Returns:** Nothing

**Effect:** Sets `park = direction`

**Usage:**
```gml
// Movement blocked by wall
if (!pacman_utils_can_move_direction(grid_x, grid_y, PAC_DIRECTION.LEFT)) {
    pacman_utils_buffer_input(PAC_DIRECTION.LEFT);  // park = 2
}
```

---

## PACMAN_DIRECTION_HANDLER.gml

Direction-specific input processing with corner turning logic.

### Individual Direction Handlers

#### `pacman_handle_direction_right(spd)`
Process RIGHT arrow key input and initiate movement or corner turning.

**Parameters:**
- `spd` (real): Current movement speed (typically from `pacman_get_speed()`)

**Behavior:**
1. Check vertical bounds (must be in `y in [48, room_height-48)`)
2. Check RIGHT key is pressed (and UP/LEFT/DOWN are not)
3. Check for wall at next tile (to the right)
4. If clear:
   - Set `dir = PAC_DIRECTION.RIGHT`
   - Clear buffered input
   - Check for corner transition (if moving vertically):
     - UP→RIGHT: Set corner state (PRE or POST), apply diagonal velocity
     - DOWN→RIGHT: Set corner state (PRE or POST), apply diagonal velocity
   - Else: Set pure right movement (`hspeed = spd`, `vspeed = 0`)
5. If blocked: Buffer input for later

**Returns:** Nothing (modifies oPacman variables)

**Usage:**
```gml
var _spd = pacman_get_speed();
pacman_handle_direction_right(_spd);  // Process if conditions met
```

---

#### `pacman_handle_direction_up(spd)`
Process UP arrow key input and initiate movement or corner turning.

**Parameters:**
- `spd` (real): Current movement speed

**Behavior:**
- Checks horizontal bounds: `x in [8, room_width-8)`
- Checks UP key only (no diagonals)
- Checks wall above
- Handles RIGHT→UP and LEFT→UP corner transitions
- Buffers input if blocked

---

#### `pacman_handle_direction_left(spd)`
Process LEFT arrow key input and initiate movement or corner turning.

**Parameters:**
- `spd` (real): Current movement speed

**Behavior:**
- Checks vertical bounds: `y in [48, room_height-48)`
- Checks LEFT key only (no diagonals)
- Checks wall to the left
- Handles UP→LEFT and DOWN→LEFT corner transitions
- Buffers input if blocked

---

#### `pacman_handle_direction_down(spd)`
Process DOWN arrow key input and initiate movement or corner turning.

**Parameters:**
- `spd` (real): Current movement speed

**Behavior:**
- Checks horizontal bounds: `x in [8, room_width-8)`
- Checks DOWN key only (no diagonals)
- Checks wall below
- Handles RIGHT→DOWN and LEFT→DOWN corner transitions
- Buffers input if blocked

---

### Master Handler

#### `pacman_handle_all_directions(spd)`
Orchestrate input processing for all four cardinal directions.

**Parameters:**
- `spd` (real): Current movement speed

**Behavior:**
```gml
pacman_handle_direction_right(spd);
pacman_handle_direction_up(spd);
pacman_handle_direction_left(spd);
pacman_handle_direction_down(spd);
```

**Returns:** Nothing

**Usage (from PACMAN_INPUT_SIMPLE):**
```gml
function pacman_handle_input() {
    if (!pacman_utils_is_in_valid_state()) return;
    if (!pacman_utils_is_at_intersection()) return;

    var _spd = pacman_get_speed();
    pacman_handle_all_directions(_spd);
}
```

---

## Complete Input Flow Example

### Scenario: Moving UP, Press RIGHT (Corner Turn)

```
Initial State:
├─ Position: (144, 203)
├─ Direction: UP (90°)
├─ Velocity: hspeed=0, vspeed=-2
├─ Grid center: (144, 208)
└─ Offset: 203 < 208 (before grid)

Frame 1: Player Presses RIGHT
├─ pacman_handle_input() called
├─ pacman_utils_is_in_valid_state() → true
├─ pacman_utils_is_at_intersection() → true ✓
├─
├─ pacman_handle_direction_right(2):
│  ├─ pacman_utils_is_at_vertical_bounds() → true ✓
│  ├─ keyboard_check(vk_right) → true ✓
│  ├─ direction == 90 && vspeed != 0 → true ✓ (moving UP)
│  │
│  ├─ Grid positions:
│  │  ├─ grid_x = 16 * round(144/16) = 144
│  │  └─ grid_y = 16 * round(203/16) = 208
│  │
│  ├─ pacman_utils_can_move_direction(144, 208, RIGHT)
│  │  └─ Check: collision_point(160, 208, Wall) → false ✓
│  │
│  ├─ pacman_utils_is_before_grid(203, 208, UP)
│  │  └─ 203 > 208? No → Before center (PRE) ✓
│  │
│  ├─ Set corner = PAC_CORNER.UP_TO_RIGHT_PRE
│  ├─ Set hspeed = 2 (move right)
│  ├─ Set vspeed = -2 (continue up - diagonal)
│  ├─ Set dir = PAC_DIRECTION.RIGHT
│  └─ pacman_utils_clear_buffered_input() → park = -1

Physics Step:
├─ x += hspeed → x = 144 + 2 = 146
└─ y += vspeed → y = 203 + (-2) = 201

Frame 2 (in Step_2):
├─ corner == PAC_CORNER.UP_TO_RIGHT_PRE → true
├─ Check: y < grid_y?
│  └─ 201 < 208? → true ✓
├─ Grid alignment not yet reached
└─ Continue with same velocity

...

Frame 4 (in Step_2):
├─ y is now ~195 (still < 208)
└─ Continue

Frame 5 (in Step_2):
├─ y has reached 208 or crossed it
├─ y = 16 * round(195/16) = 192 (snap)
├─ But condition is y < 208, and current y is ~195
└─ Still not completed

Frame 6 (in Step_2):
├─ After physics: y ~ 201
├─ if (y < 16 * (round(y / 16)))
│  └─ if (201 < 208) → true ✓
├─ y = 208 (force snap)
├─ hspeed = 2 (pure right)
├─ vspeed = 0 (stop vertical)
├─ corner = PAC_CORNER.NONE
└─ Turn complete! Now moving pure RIGHT

Result: Smooth diagonal arc from UP to RIGHT, ending with perfect grid alignment
```

---

## Common Patterns

### Pattern 1: Check Then Move

```gml
var _grid_x = pacman_utils_get_grid_position(x);
var _grid_y = pacman_utils_get_grid_position(y);

if (pacman_utils_can_move_direction(_grid_x, _grid_y, PAC_DIRECTION.UP)) {
    dir = PAC_DIRECTION.UP;
    pacman_utils_clear_buffered_input();
    hspeed = 0;
    vspeed = -speed;
}
else {
    pacman_utils_buffer_input(PAC_DIRECTION.UP);
}
```

### Pattern 2: Corner Transition

```gml
var _grid_x = pacman_utils_get_grid_position(x);
var _grid_y = pacman_utils_get_grid_position(y);

if (direction == 180 && hspeed != 0) {  // Moving LEFT
    if (!pacman_utils_is_before_grid(y, _grid_y, PAC_DIRECTION.UP)) {
        corner = PAC_CORNER.LEFT_TO_UP_PRE;
        hspeed = -_spd;
        vspeed = -_spd;  // Diagonal
    }
    else {
        corner = PAC_CORNER.LEFT_TO_UP_POST;
        hspeed = _spd;
        vspeed = -_spd;  // Diagonal (opposite X)
    }
}
```

### Pattern 3: Validation Chain

```gml
if (!pacman_utils_is_in_valid_state()) return;
if (!pacman_utils_is_at_intersection()) return;
if (!pacman_utils_is_at_vertical_bounds()) return;
if (!keyboard_check(vk_up)) return;

// Safe to process UP movement
```

---

## Troubleshooting

### Pac Passes Through Walls
**Cause:** `pacman_utils_can_move_direction()` not called before velocity applied
**Solution:** Always validate before setting `hspeed`/`vspeed`

### Corner Transitions Jerky
**Cause:** Grid alignment check timing issue
**Solution:** Verify `corner` state is set before Step_2, check snapping conditions

### Input Buffer Not Working
**Cause:** `park` variable not checked/applied at intersections
**Solution:** Verify Step_2 includes corner completion which clears corner state and allows new input

### Boundary Teleportation
**Cause:** Boundary checks using wrong variables (x vs y)
**Solution:** Remember:
- LEFT/RIGHT movement needs: `y in bounds`
- UP/DOWN movement needs: `x in bounds`

---

## Performance Notes

- **Grid calculations** use simple integer math (16px multiples)
- **Collision checks** are single-tile lookups (not expensive)
- **No pathfinding** (unlike ghosts) - simple if/else logic
- **Early returns** prevent unnecessary computation
- **Overall impact**: Negligible (< 1% CPU at 60fps)

---

## Integration Checklist

Before using these utilities:

- [ ] PACMAN_STATE.gml loaded (enums: PAC_DIRECTION, PAC_CORNER, etc.)
- [ ] Wall object exists and is accessible
- [ ] GAME_CONSTANTS.gml loaded (TILE_PIXELS = 16)
- [ ] PACMAN_MOVEMENT.gml loaded (pacman_get_speed function)
- [ ] Step_1 and Step_2 events call the main functions
- [ ] Create_0.gml initializes all variables (sp, spfright, corner, etc.)

---

## Related Functions (Other Files)

From **PACMAN_MOVEMENT.gml**:
- `pacman_get_speed()` - Returns `sp` or `spfright`
- `pacman_update_tile_position()` - Updates `tilex`/`tiley`
- `pacman_update_direction_sync()` - Keeps sprite facing correct way

From **PACMAN_CORNER.gml**:
- `pacman_complete_corners()` - Completes all 16 corner transitions
