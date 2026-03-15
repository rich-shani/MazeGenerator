# Grid Alignment Fix Summary

## Problem Statement

oPacman sprite was appearing **shifted slightly to the left** when moving and snapping to grid positions.

## Root Cause

The grid snapping formula was targeting tile **boundaries** (0, 16, 32, 48...) instead of tile **centers** (8, 24, 40, 56...).

**Why?**
- The maze spawning system positions entities at: `_x_offset + (col * 16)` where offset = 8
- This results in sprite centers at: 8, 24, 40, 56, 72... (8-pixel offsets into each tile)
- The old grid formula `16 * round(x / 16)` snapped to boundaries: 0, 16, 32, 48, 64...
- Pac would snap to boundaries instead of centers, appearing off-center

## Solution Applied

### Formula Change

**Old (Incorrect):**
```gml
return 16 * (round(_pixel_pos / 16));
```

**New (Correct):**
```gml
var _tile_index = round((_pixel_pos - 8) / 16);
return (_tile_index * 16) + 8;
```

This accounts for the 8-pixel tile center offset, ensuring snapping to actual tile centers.

## Files Modified

### 1. scripts/PACMAN_INPUT_UTILS/PACMAN_INPUT_UTILS.gml

**Function Updated:** `pacman_utils_get_grid_position()`
- Lines 83-87
- Changed formula to account for tile center offset
- This is the core utility used throughout the system

### 2. scripts/PACMAN_MOVEMENT/PACMAN_MOVEMENT.gml

**Function Updated:** `pacman_update_tile_position()`
- Lines 8-26
- Changed from inline calculations to utility function calls
- `tilex = pacman_utils_get_grid_position(x);`
- `tiley = pacman_utils_get_grid_position(y);`

### 3. scripts/PACMAN_CORNER/PACMAN_CORNER.gml

**Function Updated:** `pacman_complete_corners()`
- Lines 1-205 (complete rewrite)
- Replaced all 32 instances of old grid formula with utility function
- Applied to all 16 corner transition completion states:
  - UP_TO_RIGHT_PRE/POST
  - RIGHT_TO_UP_PRE/POST
  - DOWN_TO_LEFT_PRE/POST
  - LEFT_TO_DOWN_PRE/POST
  - DOWN_TO_RIGHT_PRE/POST
  - RIGHT_TO_DOWN_PRE/POST
  - UP_TO_LEFT_PRE/POST
  - LEFT_TO_UP_PRE/POST

## How It Works

### Example Calculation

**Before Fix (Incorrect):**
```
x = 27 (between grid centers 24 and 40)
grid = 16 * round(27 / 16) = 16 * 2 = 32 ❌ (tile boundary)
```

**After Fix (Correct):**
```
x = 27 (between grid centers 24 and 40)
tile_index = round((27 - 8) / 16) = round(1.1875) = 1
grid = (1 * 16) + 8 = 24 ✅ (tile center)
```

### Grid Position Reference

For a 16×16 pixel tile system with centers at 8-pixel offsets:

| Tile Index | Tile Boundary | Tile Center |
|-----------|---------------|-------------|
| 0 | 0 | 8 |
| 1 | 16 | 24 |
| 2 | 32 | 40 |
| 3 | 48 | 56 |
| 4 | 64 | 72 |
| 5 | 80 | 88 |
| ... | ... | ... |

## Verification Checklist

After running the game, verify the following:

- [ ] Pac sprite appears **centered** in grid tiles when moving (not shifted left)
- [ ] Corner turning still executes smoothly with diagonal transitions
- [ ] Wall collision still properly stops Pac movement
- [ ] Grid snapping feels responsive and correct
- [ ] No visual artifacts or jittering during movement transitions

## Technical Details

### Why 8-Pixel Offset?

The maze generator uses:
```
_x_offset = (room_width - (MAP_WIDTH_IN_PIXELS)) / 2
```

With centered positioning, tiles are placed at regular intervals from this offset. The sprite center (origin point) falls 8 pixels into each 16-pixel tile, creating the 8, 24, 40... pattern.

### Impact on Movement System

This fix affects three critical aspects:
1. **Tile Tracking** - `tilex`/`tiley` now snap to correct centers
2. **Wall Collision** - `pacman_utils_can_move_direction()` uses grid positions for lookahead checks
3. **Corner Completion** - All 16 corner states now snap to correct centers after transition

## Status

✅ All three files have been updated
✅ Formula change is propagated throughout the system
✅ Ready for testing

## Next Steps

1. Run the game (F5 in GameMaker Studio)
2. Use arrow keys to move oPacman around the maze
3. Verify sprite is centered in tiles (not shifted left)
4. Test corner turning for smooth transitions
5. Test wall collision to ensure Pac still stops at boundaries
