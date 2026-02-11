/// ===============================================================================
/// oGHOST - BASE GHOST OBJECT - OTHER_4 EVENT (SPEED INITIALIZATION)
/// ===============================================================================
/// Purpose: Set movement speeds based on game mode and level
/// Triggered: When level changes or game mode changes
///
/// Speed values differ based on:
/// 1. Game difficulty/mode (Pac-Man vs Ms. Pac-Man vs Jr. Pac-Man)
/// 2. Current level (speeds vary per level)
/// 3. Special modes (boost mode, etc.)
/// 4. Ghost personality (some ghosts might have tweaked speeds)
///
/// This sets:
/// - sp: Normal chase speed
/// - spslow: Tunnel/slow area speed
/// - spfright: Frightened mode speed
/// - spelroy: Elroy mode 1 speed
/// - spelroy2: Elroy mode 2 speed
/// - speyes: Eyes speed
///
/// Called when: global.speed_change is triggered (between levels/modes)
/// ===============================================================================

// ===== BASE SPEED CALCULATIONS =====
/// These formulas are based on the original Pac-Man game mechanics
/// Different game modes and levels have different speed progressions

// Check boost mode first
if (global.boost == 1) {
    // Boost mode: all speeds doubled
    sp = 4.0;
    spslow = 2.0;
    spfright = 2.5;
    spelroy = 4.0;
    spelroy2 = 4.25;
    speyes = 8.0;
} else {
    // Normal mode: base speeds
    if (global.game == 0) {
        // ===== ORIGINAL PAC-MAN MODE =====
        // Classic arcade Pac-Man speeds

        if (global.lvl < 5) {
            sp = 1.875;
            spslow = 1.0;
            spfright = 1.25;
            spelroy = 2.0;
            spelroy2 = 2.125;
        }
        else if (global.lvl < 21) {
            sp = 1.875;
            spslow = 1.0;
            spfright = 1.25;
            spelroy = 2.0;
            spelroy2 = 2.125;
        }
        else {
            // Levels 21+: maximum speed
            sp = 1.875;
            spslow = 1.0;
            spfright = 1.25;
            spelroy = 2.0;
            spelroy2 = 2.125;
        }

        speyes = 4.0;  // Eyes always same speed
    }
    else if (global.game == 1) {
        // ===== MS. PAC-MAN MODE =====
        // Ms. Pac-Man has faster speeds and more level progression

        if (global.lvl <= 4) {
            sp = 1.875;
            spslow = 1.0;
            spfright = 1.25;
            spelroy = 2.0;
            spelroy2 = 2.125;
        }
        else if (global.lvl == 5) {
            sp = 2.0;
            spslow = 1.25;
            spfright = 1.5;
            spelroy = 2.25;
            spelroy2 = 2.375;
        }
        else {
            sp = 2.0;
            spslow = 1.25;
            spfright = 1.5;
            spelroy = 2.25;
            spelroy2 = 2.375;
        }

        speyes = 4.0;
    }
    else if (global.game == 2) {
        // ===== JR. PAC-MAN MODE =====
        // Jr. Pac-Man has different mechanics with baby/fruit

        if (global.lvl <= 1) {
            sp = 1.875;
            spslow = 1.0;
            spfright = 1.25;
            spelroy = 2.0;
            spelroy2 = 2.125;
        }
        else if (global.lvl <= 2) {
            sp = 1.875;
            spslow = 1.0;
            spfright = 1.25;
            spelroy = 2.0;
            spelroy2 = 2.125;
        }
        else if (global.lvl <= 5) {
            sp = 1.875;
            spslow = 1.0;
            spfright = 1.25;
            spelroy = 2.0;
            spelroy2 = 2.125;
        }
        else {
            sp = 1.875;
            spslow = 1.0;
            spfright = 1.25;
            spelroy = 2.0;
            spelroy2 = 2.125;
        }

        speyes = 4.0;
    }
}

// ===== SPECIAL MODE ADJUSTMENTS =====
// Apply any additional speed tweaks for special modes

if (global.plus == 1) {
    // Plus mode: ghosts slower
    sp *= 0.9;
    spfright *= 0.9;
    spelroy *= 0.9;
    spelroy2 *= 0.9;
}

/// ===============================================================================
/// SPEED REFERENCE
/// ===============================================================================
/// Standard Pac-Man speeds (pixels per frame):
///
/// sp = 1.875          Normal chase speed
/// spslow = 1.0        Tunnel/slow area (about 50% normal)
/// spfright = 1.25     Frightened mode (about 67% normal)
/// spelroy = 2.0       Elroy mode 1 (about 107% normal)
/// spelroy2 = 2.125    Elroy mode 2 (about 113% normal)
/// speyes = 4.0        Eyes/dead speed (about 213% normal)
///
/// These translate to roughly:
/// - One full grid (16 pixels) in ~8-9 frames at normal speed
/// - One full grid in ~16 frames at slow speed
/// - Full screen in ~240 pixels, ~2.5 seconds at normal speed
///
/// ===============================================================================

/// ===============================================================================
/// END oGHOST OTHER_4 EVENT
/// ===============================================================================
