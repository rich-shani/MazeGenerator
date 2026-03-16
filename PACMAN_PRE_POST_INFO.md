## Pac-Man Corner PRE vs POST States

This document explains how the 16 Pac-Man corner states are used in this project, and why both **PRE** and **POST** variants are needed to faithfully match the arcade cornering behavior.

### 1. Corner state overview

Corner states are defined in `scripts/PACMAN_STATE/PACMAN_STATE.gml`:

- `PAC_CORNER.NONE` – no corner in progress
- `*_PRE` – early / pre-centerline corner state
- `*_POST` – late / post-centerline corner state

The full set:

- `UP_TO_RIGHT_PRE` / `UP_TO_RIGHT_POST`
- `RIGHT_TO_UP_PRE` / `RIGHT_TO_UP_POST`
- `DOWN_TO_LEFT_PRE` / `DOWN_TO_LEFT_POST`
- `LEFT_TO_DOWN_PRE` / `LEFT_TO_DOWN_POST`
- `DOWN_TO_RIGHT_PRE` / `DOWN_TO_RIGHT_POST`
- `RIGHT_TO_DOWN_PRE` / `RIGHT_TO_DOWN_POST`
- `UP_TO_LEFT_PRE` / `UP_TO_LEFT_POST`
- `LEFT_TO_UP_PRE` / `LEFT_TO_UP_POST`

All corner completion logic lives in `scripts/PACMAN_CORNER/PACMAN_CORNER.gml` in `pacman_complete_corners()`.

### 2. High-level behavior (arcade-aligned)

From the Pac-Man Dossier and our scaling:

- Pac moves on a grid and can **start a turn slightly before or slightly after** the intersection centerline.
- During a corner, Pac moves diagonally at 45°: 1px new direction per 1px old direction (here, `|hspeed| == |vspeed|`).
- The turn **completes** when Pac reaches the centerline of the new direction’s path (scaled to a 16×16 grid), at which point:
  - Position snaps exactly to the intersection center `(tilex, tiley)`.
  - Velocity becomes pure cardinal (only one axis non-zero).
  - The facing direction (`direction`) is set to 0 / 90 / 180 / 270.

The PRE and POST states are two ways to reach that same centerline, depending on when the player pressed the new direction.

### 3. PRE states – early/ideal turns

**PRE states** handle the classic “early turn”:

- The player presses a perpendicular direction **before or very near** the centerline of the intersection.
- Input handler logic (in `PACMAN_DIRECTION_HANDLER.gml`) checks:
  - Current `direction` (old movement),
  - New desired direction (`dir`),
  - Whether Pac is **before** the grid centerline using `pacman_utils_is_before_grid(...)`,
  - Whether he is in the pre-turn zone using `pacman_utils_is_in_pre_turn_zone(...)`.
- If those checks pass, a `*_PRE` corner is set and diagonal movement begins:
  - Example: UP→RIGHT (`UP_TO_RIGHT_PRE`) sets `hspeed = +spd`, `vspeed = -spd`.

In `pacman_complete_corners()`, PRE states now use conditions that:

- Require Pac to **reach** the centerline for the axis aligned with the new direction.
- Allow a small tolerance on the orthogonal axis via `CORNER_SNAP_TOLERANCE` so we don’t wait for a perfect pixel and cause a visible snap.

For example, for **DOWN→RIGHT PRE**:

- New direction is RIGHT, so the **new path’s centerline is horizontal (Y)** at `tiley`.
- PRE completion condition:

```gml
// DOWN_TO_RIGHT transitions (reach horizontal centerline, advance on X)
if (corner == PAC_CORNER.DOWN_TO_RIGHT_PRE) {
    if (y >= tiley && x >= tilex + _tol) {
        x = tilex;
        y = tiley;
        hspeed = _spd;
        vspeed = 0;
        direction = 0; // RIGHT
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        return true;
    }
}
```

Interpretation:

- While `corner == DOWN_TO_RIGHT_PRE`, Pac moves diagonally down-right.
- As soon as his Y reaches the new path’s centerline (`y >= tiley`) and his X has advanced at least `_tol` pixels in the new direction (`x >= tilex + _tol`), we:
  - Snap to `(tilex, tiley)`,
  - Switch to pure RIGHT (`hspeed = _spd`, `vspeed = 0`),
  - Set `direction = 0`,
  - Clear the corner state.

This matches the arcade feel: Pac starts cutting into the corner early, then “locks into” the new corridor as soon as he crosses the new direction’s centerline.

The same pattern is mirrored for all PRE states:

- For **new horizontal directions** (LEFT/RIGHT), we:
  - Check Y against `tiley` (centerline),
  - Use X with `_tol` to ensure some progress in the new direction.
- For **new vertical directions** (UP/DOWN), we:
  - Check X against `tilex` (centerline),
  - Use Y with `_tol` accordingly.

### 4. POST states – late turns and overshoot correction

**POST states** handle:

- Player presses the new direction **slightly after** crossing the centerline.
- Or diagonal movement causes a **small overshoot** beyond the ideal center point.

In those cases, the input handler does not classify the situation as “before grid” and thus chooses a `*_POST` state instead of `*_PRE`.

Example: **DOWN→RIGHT POST** (`DOWN_TO_RIGHT_POST`):

```gml
if (corner == PAC_CORNER.DOWN_TO_RIGHT_POST) {
    if (y <= tiley && x >= tilex) {  // POST: correcting overshoot
        x = tilex;
        y = tiley;
        hspeed = _spd;
        vspeed = 0;
        direction = 0; // RIGHT
        corner = PAC_CORNER.NONE;
        cornercheck = 0;
        return true;
    }
}
```

Interpretation:

- Pac was **already past** the centerline when the player pressed RIGHT while moving DOWN.
- We set a POST corner state and move diagonally in the appropriate quadrant.
- The snap condition is essentially the mirror of PRE:
  - It waits until Pac has **come back to or crossed** the centerline from the far side (`y <= tiley` here),
  - While still moving in the correct quadrant (`x >= tilex`).

This allows:

- Slightly **late turns** that still feel responsive (you can turn a little after the center, like in the arcade).
- Compact **overshoot correction**, keeping Pac glued to the grid by snapping back to `(tilex, tiley)` rather than leaving him misaligned.

Every PRE/POST pair works similarly:

- PRE: “Before centerline” path to the intersection.
- POST: “After centerline” path that bends back and then snaps.

### 5. Why we need both PRE and POST

If we only had PRE states and immediate snap logic:

- **Early turns** would feel correct.
- But:
  - **Late inputs** (keys pressed just after crossing the intersection) would either not turn at all, or would require awkward reclassification as PRE, breaking the nice diagonal path.
  - **Overshoot from speed/step size** (e.g., `_spd = 2` on a 16×16 grid) would result in visible jumps or misaligned positions if we tried to snap from too far away.

Having both PRE and POST:

- Preserves the **arcade’s generous turning window**:
  - You can turn slightly early or slightly late and still get a smooth corner.
- Ensures Pac always ends **exactly** on the intersection centerline after the corner, with:
  - Clean `(tilex, tiley)` alignment,
  - Pure cardinal speed,
  - Correct sprite direction.

### 6. Tolerance and smoothness

We use two key constants from `scripts/GAME_CONSTANTS/GAME_CONSTANTS.gml`:

- `CORNER_PRE_TURN_NARROW` / `CORNER_PRE_TURN_WIDE`:
  - Control how far before the centerline the player can trigger a PRE corner,
  - Scaled from the original 3/4 pixel zones to 16×16 tiles.
- `CORNER_SNAP_TOLERANCE`:
  - Currently set to `1`,
  - Allows the snap to happen once Pac is **within 1 pixel** of the centerline for the non-dominant axis,
  - Reduces visible snapping/flicker while staying faithful to the arcade’s “at centerline” rule.

Together with PRE/POST, this produces:

- Smooth diagonal arcs into the corner.
- Single, clean snap to the new axis at or extremely near the grid center.
- No visible 1–2 pixel “teleport” artifacts at the moment of turn.

### 7. Summary

- **PRE states** = early/ideal turns: diagonal entry into the corner, snap at new direction’s centerline.
- **POST states** = late/overshoot turns: diagonal from the far side, snap back to the centerline.
- Both are required to:
  - Match the arcade’s forgiving turning windows,
  - Keep Pac tightly aligned to the tile grid,
  - Avoid visual flicker or positional jumps at corner completion.

With the recent changes to PRE conditions and `CORNER_SNAP_TOLERANCE`, and with POST states still active for overshoot correction, the current implementation closely tracks classic arcade corner behavior while eliminating visible sprite flicker.

