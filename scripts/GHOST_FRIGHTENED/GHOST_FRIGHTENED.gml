/// ===============================================================================
/// GHOST_FRIGHTENED() - FRIGHTENED GHOST MOVEMENT
/// ===============================================================================
/// Purpose: Choose a random valid direction at an intersection when ghost is frightened.
/// Called: From oGhost Step_0 (target) and Step_2 (turning) when state == GHOST_STATE.FRIGHTENED.
/// Uses: Calling instance's tilex, tiley (grid position) and dir (GRID_DIRECTION). Sets 'dir'.
///
/// Behavior:
/// - Collects all directions that are open (no wall) via ghost_chase_utils_can_go.
/// - Excludes the reverse of current direction (classic Pac-Man: no 180° turn when frightened).
/// - Picks one of the valid directions at random and sets dir.
/// ===============================================================================

/// @private Pick a frightened direction using weighted probabilities,
/// matching the original "old_frightened.random_direction()" behavior but
/// without repeating code for each current direction.
///
/// - Uses ghost_chase_utils_can_go() to guarantee the chosen neighbor is open.
/// - Never chooses the 180-degree reverse direction (non-reverse set only).
/// - Returns GRID_DIRECTION or -1 if no valid direction exists.
function _ghost_frightened_pick_dir(_objx, _objy, _cur) {
    // Candidate set:
    // Each current direction defines three allowed directions:
    //   - idx1 corresponds to "weight 1" candidate
    //   - idx3 corresponds to "weight 3" candidate
    //   - idx5 corresponds to "weight 5" candidate
    // The old code used these weights to create check values (1/3/5 combinations).
    var d1 = noone;
    var d3 = noone;
    var d5 = noone;

    // Probabilities for 2-open cases:
    // - p4_d1: when check==4 (d1+d3 open), choose d1 with this probability
    // - p6_d1: when check==6 (d1+d5 open), choose d1 with this probability
    // - p8_d3: when check==8 (d3+d5 open), choose d3 with this probability
    var p4_d1 = 0;
    var p6_d1 = 0;
    var p8_d3 = 0;

    // Probabilities for 3-open (check==9):
    // - primaryIdx is one of {1,3,5} meaning d1/d3/d5.
    // - secondaryIdx is which of the remaining directions to choose in the else-branch.
    //   i.e. if random >= p_primary, choose secondaryIdx with prob p_secondary else the other.
    var primaryIdx = 1;
    var p_primary = 0;
    var secondaryIdx = 5;
    var p_secondary = 0;

    // Configure mapping/probabilities for the current movement direction.
    if (_cur == GRID_DIRECTION.RIGHT) {
        d1 = GRID_DIRECTION.RIGHT;
        d3 = GRID_DIRECTION.UP;
        d5 = GRID_DIRECTION.DOWN;

        p4_d1 = 0.252;
        p6_d1 = 0.715; // 1 - 0.285
        p8_d3 = 0.463;

        primaryIdx = 1;      // choose RIGHT first
        p_primary = 0.252;   // old: RIGHT with 0.252
        secondaryIdx = 5;    // then choose DOWN with 0.381 else UP
        p_secondary = 0.381;
    } else if (_cur == GRID_DIRECTION.UP) {
        d1 = GRID_DIRECTION.RIGHT;
        d3 = GRID_DIRECTION.UP;
        d5 = GRID_DIRECTION.LEFT;

        p4_d1 = 0.252;
        p6_d1 = 0.415;
        p8_d3 = 0.163;

        primaryIdx = 3;      // choose UP first
        p_primary = 0.163;
        secondaryIdx = 1;    // then choose RIGHT with 0.301 else LEFT
        p_secondary = 0.301;
    } else if (_cur == GRID_DIRECTION.LEFT) {
        d1 = GRID_DIRECTION.LEFT;
        d3 = GRID_DIRECTION.UP;
        d5 = GRID_DIRECTION.DOWN;

        p4_d1 = 0.837; // 1 - 0.163
        p6_d1 = 0.300;
        p8_d3 = 0.463;

        primaryIdx = 3;      // choose UP first
        p_primary = 0.163;
        secondaryIdx = 1;    // then choose LEFT with 0.358 else DOWN
        p_secondary = 0.358;
    } else if (_cur == GRID_DIRECTION.DOWN) {
        d1 = GRID_DIRECTION.RIGHT;
        d3 = GRID_DIRECTION.DOWN;
        d5 = GRID_DIRECTION.LEFT;

        p4_d1 = 0.715; // 1 - 0.285
        p6_d1 = 0.415;
        p8_d3 = 0.700; // 1 - 0.300 (choose DOWN idx3 vs LEFT idx5)

        primaryIdx = 3;      // choose DOWN first
        p_primary = 0.285;
        secondaryIdx = 5;    // then choose LEFT with 0.412 else RIGHT
        p_secondary = 0.412;
    } else {
        return -1;
    }

    // Check open directions using the same wall logic as chase mode.
    var open1 = ghost_chase_utils_can_go(_objx, _objy, d1);
    var open3 = ghost_chase_utils_can_go(_objx, _objy, d3);
    var open5 = ghost_chase_utils_can_go(_objx, _objy, d5);

    var check = 0;
    if (open1) check += 1;
    if (open3) check += 3;
    if (open5) check += 5;

    if (check == 1) return d1;
    if (check == 3) return d3;
    if (check == 5) return d5;

    if (check == 4) {
        if (random(1) < p4_d1) {
            return d1;
        } else {
            return d3;
        }
    }
    if (check == 6) {
        if (random(1) < p6_d1) {
            return d1;
        } else {
            return d5;
        }
    }
    if (check == 8) {
        if (random(1) < p8_d3) {
            return d3;
        } else {
            return d5;
        }
    }

    if (check == 9) {
        // Resolve primary choice
        var primaryDir = noone;
        var secondaryDir = noone;

        if (primaryIdx == 1) primaryDir = d1;
        else if (primaryIdx == 3) primaryDir = d3;
        else primaryDir = d5;

        if (secondaryIdx == 1) secondaryDir = d1;
        else if (secondaryIdx == 3) secondaryDir = d3;
        else secondaryDir = d5;

        if (random(1) < p_primary) {
            return primaryDir;
        }

        // If primary isn't chosen, pick between the remaining two directions.
        // Compute "other" direction: it's whichever one isn't primary and isn't secondary.
        var otherDir = noone;
        if (primaryIdx == 1) {
            // remaining are d3 and d5
            if (secondaryIdx == 3) otherDir = d5;
            else otherDir = d3;
        } else if (primaryIdx == 3) {
            // remaining are d1 and d5
            if (secondaryIdx == 1) otherDir = d5;
            else otherDir = d1;
        } else {
            // primaryIdx == 5: remaining are d1 and d3
            if (secondaryIdx == 1) otherDir = d3;
            else otherDir = d1;
        }

        if (random(1) < p_secondary) {
            return secondaryDir;
        } else {
            return otherDir;
        }
    }

    return -1;
}

function GHOST_FRIGHTENED() {
    // Similar safety bounds as the old frightened code (prevents odd edge cases)
    if (x <= 8 || x >= (room_width - 8)) return;
    if (y <= 8 || y >= (room_height - 8)) return;

    // Use the actually applied movement direction so we forbid the true reverse.
    // (Using `dir` here can be wrong because `dir` is "desired".)
    var _cur = dir_applied; // GRID_DIRECTION

    var _pick = _ghost_frightened_pick_dir(tilex, tiley, _cur);
    if (_pick != -1) dir = _pick;
}
