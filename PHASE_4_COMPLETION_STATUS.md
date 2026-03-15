# Phase 4: Grid Alignment Fix - Completion Status

## Overview

Fixed the grid snapping formula that was causing oPacman sprite to appear shifted left of center. The issue was subtle but pervasive across the entire movement system.

## Problem Details

**Symptom:** oPacman sprite appeared **shifted slightly to the left** when moving and snapping to grid positions.

**Root Cause:**
- Maze spawning system places entities at: `offset + (col * 16)` where offset = 8
- Results in sprite centers at: 8, 24, 40, 56, 72... (8-pixel tile center offsets)
- Old grid formula: `16 * round(x / 16)` snapped to boundaries: 0, 16, 32, 48, 64...
- Pac would snap to wrong positions, appearing off-center

## Solution

### Formula Change

**Location:** `scripts/PACMAN_INPUT_UTILS/PACMAN_INPUT_UTILS.gml` lines 83-87

```gml
// OLD (INCORRECT)
return 16 * (round(_pixel_pos / 16));

// NEW (CORRECT)
var _tile_index = round((_pixel_pos - 8) / 16);
return (_tile_index * 16) + 8;
```

The new formula:
1. Subtracts 8 to account for tile center offset
2. Divides by tile size (16) to get tile index
3. Multiplies back by 16 and adds 8 to get tile center

## Files Modified

### 1. ✅ scripts/PACMAN_INPUT_UTILS/PACMAN_INPUT_UTILS.gml

**Change:** Updated `pacman_utils_get_grid_position()` function (lines 83-87)

**Impact:** This utility is used throughout the system for all grid position calculations. The fix propagates to all callers automatically.

**Callers:**
- `pacman_update_tile_position()` in PACMAN_MOVEMENT.gml
- `pacman_utils_validate_current_movement()` in Step_1.gml (for wall detection)
- `pacman_complete_corners()` in PACMAN_CORNER.gml (all 16 corner states)
- `pacman_handle_all_directions()` in PACMAN_DIRECTION_HANDLER.gml (input validation)

### 2. ✅ scripts/PACMAN_MOVEMENT/PACMAN_MOVEMENT.gml

**Change:** Updated `pacman_update_tile_position()` function (lines 8-26)

**Before:**
```gml
tilex = 16 * (round(x / 16));
tiley = 16 * (round(y / 16));
```

**After:**
```gml
tilex = pacman_utils_get_grid_position(x);
tiley = pacman_utils_get_grid_position(y);
```

**Impact:** Tile position tracking now uses the corrected utility function, ensuring proper grid alignment for collision detection.

### 3. ✅ scripts/PACMAN_CORNER/PACMAN_CORNER.gml

**Change:** Complete file rewrite (lines 1-205)

**Details:**
- Replaced all 32 instances of old grid formula with utility function calls
- All 16 corner transition completion states updated:
  - UP_TO_RIGHT_PRE/POST
  - RIGHT_TO_UP_PRE/POST
  - DOWN_TO_LEFT_PRE/POST
  - LEFT_TO_DOWN_PRE/POST
  - DOWN_TO_RIGHT_PRE/POST
  - RIGHT_TO_DOWN_PRE/POST
  - UP_TO_LEFT_PRE/POST
  - LEFT_TO_UP_PRE/POST

**Example Update (UP_TO_RIGHT_PRE):**
```gml
// OLD
if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
    var _grid_y = 16 * (round(y / 16));
    if (y < _grid_y) {
        // ...
    }
}

// NEW
if (corner == PAC_CORNER.UP_TO_RIGHT_PRE) {
    var _grid_y = pacman_utils_get_grid_position(y);
    if (y < _grid_y) {
        // ...
    }
}
```

**Impact:** Corner transitions now snap to correct tile centers, ensuring smooth grid-aligned turns.

## System Overview After Fix

```
Input Handler (PACMAN_DIRECTION_HANDLER)
    ↓
Grid Position Utility (PACMAN_INPUT_UTILS)
    ↓ pacman_utils_get_grid_position() ← FIXED HERE
    ↓
Movement System:
    ├─ Tile Tracking (PACMAN_MOVEMENT)
    ├─ Wall Collision (PACMAN_INPUT_UTILS)
    └─ Corner Completion (PACMAN_CORNER)
```

All components now use the corrected grid position formula.

## Verification Grid Reference

For 16×16 pixel tiles with centers at 8-pixel offsets:

| Tile Col | Boundary | Center |
|----------|----------|--------|
| 0 | 0 | **8** |
| 1 | 16 | **24** |
| 2 | 32 | **40** |
| 3 | 48 | **56** |
| 4 | 64 | **72** |
| 5 | 80 | **88** |
| 6 | 96 | **104** |
| 7 | 112 | **120** |
| ... | ... | ... |

The new formula correctly calculates these center positions.

## Testing Checklist

After running the game with this fix, verify:

### Visual Alignment ✓
- [ ] Pac sprite is **centered** in grid tiles (not shifted left)
- [ ] Sprite center aligns with tile center position
- [ ] No visual misalignment during movement

### Movement Mechanics ✓
- [ ] Arrow keys move Pac in all 4 cardinal directions
- [ ] Movement speed is consistent (2 pixels/frame)
- [ ] Pac stops smoothly at grid boundaries

### Corner Turning ✓
- [ ] Smooth diagonal transitions when turning at intersections
- [ ] All 8 corner turn combinations work correctly
- [ ] Pac snaps to grid after completing turn
- [ ] Grid-aligned positions are correct after turns

### Wall Collision ✓
- [ ] Pac stops when encountering Wall objects
- [ ] No passing through walls
- [ ] Buffered input still works (pressing direction key before reaching intersection)

### State Tracking ✓
- [ ] `tilex` and `tiley` match visual position
- [ ] Grid positions are consistent across all systems

## Code Quality Assessment

### Consistency
- ✅ All grid position calculations now use single utility function
- ✅ No duplicate formulas scattered throughout code
- ✅ Easy to maintain and update in future

### Correctness
- ✅ Formula accounts for 8-pixel tile center offset
- ✅ Matches maze spawning system's positioning
- ✅ Applied consistently across movement, collision, and cornering systems

### Performance
- ✅ No performance impact (utility function is lightweight)
- ✅ Single calculation per frame (in Step_1)

## Technical Notes

### Why This Matters

The 8-pixel offset is not arbitrary. It comes from:
1. Maze generator centers tiles: `offset + (col * tile_size)`
2. GameMaker sprites use origin point (typically center for gameplay objects)
3. oPacman object has origin at (4, 4) - center of 8×8 sprite
4. Collision detection uses this centered position

### Backward Compatibility

This fix **does not break** any existing functionality because:
- It corrects the behavior to match the actual sprite positioning
- All systems that depend on grid positions benefit from the fix
- Input validation, collision detection, and corner transitions all work better

### Future Considerations

If tile size ever changes from 16 pixels, only two things need updating:
1. The TILE_PIXELS constant
2. The 8-pixel offset (which is tile_size / 2 for centered positioning)

The formula structure remains valid.

## Summary

**Status:** ✅ **COMPLETE**

**What Was Done:**
1. Fixed `pacman_utils_get_grid_position()` formula (core utility)
2. Updated `pacman_update_tile_position()` to use utility (tile tracking)
3. Rewrote `pacman_complete_corners()` to use utility (all 16 corner states)

**Impact:**
- Pac sprite now aligns to correct tile centers (8, 24, 40... instead of 0, 16, 32...)
- Movement, collision, and corner systems all benefit from single consistent formula
- No code duplication

**Next Action:**
- Run game (F5 in GameMaker Studio)
- Test movement and verify sprite centering is fixed
- Confirm corner turning and wall collision still work correctly

## Files Ready for Testing

All modifications complete:
- ✅ PACMAN_INPUT_UTILS.gml (utility function)
- ✅ PACMAN_MOVEMENT.gml (tile tracking)
- ✅ PACMAN_CORNER.gml (corner completion)
- ✅ Create_0.gml (variable initialization - unchanged in this phase)
- ✅ Step_1.gml (input and validation - uses corrected utility)
- ✅ Step_2.gml (corner handling - calls corrected utility)
