# Pac-Man Corner Logic: Original vs This Implementation

## Reference: Pac-Man Dossier (pacman.holenet.info)

### Original Arcade (1980)
- **Grid**: 8×8 pixel tiles, 224×288 screen, 28×36 tiles
- **Pre-turn**: Start diagonal 1+ pixels *before* reaching intersection center
- **Post-turn**: Start diagonal 1+ pixels *after* passing center
- **Asymmetric zones**:
  - Entering from LEFT or TOP: **3 pre-turn pixels**, 4 post-turn
  - Entering from RIGHT or BOTTOM: **4 pre-turn pixels**, 3 post-turn
- **Diagonal movement**: 1 pixel new direction per 1 pixel old direction → 45° angle, √2 effective speed
- **Completion**: When Pac reaches the centerline of the new direction's path → switch to pure cardinal movement
- **Note**: "All eight early turn combinations have different movement methodologies" (some snap extra pixel)

### This Implementation
- **Grid**: 16×16 tiles (2× scale of original)
- **Pre-turn zones**: Scaled asymmetric – NARROW=6px (3×2), WIDE=8px (4×2)
  - RIGHT, DOWN approaches: 6px zone (original 3)
  - LEFT, UP approaches: 8px zone (original 4)
- **Diagonal**: `hspeed ±spd`, `vspeed ±spd` → correct 45° movement
- **Completion**: When passed intersection by `CORNER_SNAP_TOLERANCE` (0) in both axes → snap to `(tilex, tiley)`
- **Post-turn**: Past center → immediate snap and turn (no diagonal)

### Alignment Summary
| Aspect | Original | Ours | Match |
|--------|----------|------|-------|
| Pre-turn zones | 3/4 px asymmetric | 6/8 px scaled | ✓ |
| Diagonal angle | 45°, √2 speed | 45°, √2 speed | ✓ |
| Completion | At centerline | At arrival (tol 0) | ✓ |
| Snap target | Intersection center | (tilex, tiley) | ✓ |
| Per-turn differences | May vary | Uniform | Approx |

### Files Changed
- `GAME_CONSTANTS.gml`: `CORNER_PRE_TURN_NARROW`, `CORNER_PRE_TURN_WIDE`
- `PACMAN_INPUT_UTILS.gml`: `pacman_utils_is_in_pre_turn_zone()`
- `PACMAN_DIRECTION_HANDLER.gml`: Uses pre-turn zone for all 8 corner types
