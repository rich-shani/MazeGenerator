/// ===============================================================================
/// PAC-MAN OBJECT - DRAW_0 EVENT (PLAYER 1 RENDERING)
/// ===============================================================================
/// Purpose: Render Pac-Man sprite with state-aware animations and effects
/// Called: Every frame during draw phase
///
/// Rendering Features:
/// 1. Death animation (when Pac dies)
/// 2. Prohibit state (frozen/invincible sprite)
/// 3. Normal movement animation (mouth chomping)
/// 4. Boost mode effects (speed lines)
/// 5. Ghost eating animation (chomp sprite)
/// 6. Wraparound rendering (for tall rooms with vertical wrapping)
/// 7. Game variant support (Pac-Man, Ms. Pac-Man, Jr. Pac-Man, Otto)
///
/// Sprite Selection:
/// - spr_Man: Standard Pac-Man sprite
/// - spr_MsMan: Ms. Pac-Man sprite (with bow)
/// - spr_OttoMan: Otto sprite variant
/// - spr_JrMan: Jr. Pac-Man sprite
/// - spr_Dead: Death animation sprite
/// - spr_Chomp: Ghost eating animation sprite
/// - spr_boostlines: Speed boost visual effect
///
/// Animation Frame Calculation:
/// - Normal: (floor(im/2)) + (4*dir) - cycles through 2 frames per direction
/// - Death: floor(deadanim) - death animation frame
/// - Chomp: chompcount-1+Pac.pluseat - ghost eating animation
/// ===============================================================================

// ===== MAIN RENDERING (CURRENT POSITION) =====
/// Only render if not in death sequence (alarm[9] controls death timing)
if (alarm[9] == -1) {
    
    // ===== DEATH ANIMATION =====
    /// Draw death animation when Pac is dying
    if (dead > 1) {
        /// Pac is in death state (dead > 1 means death animation active)
        
        if (deader == 1) {
            /// Death animation phase 1: Full death sequence
            
            if (room_width == 448) {
                /// Standard maze size (448 pixels wide)
                /// Select appropriate death sprite based on game variant
                
                if (global.ex1 == 0) {
                    /// Standard Pac-Man death animation
                    draw_sprite(spr_Dead, floor(deadanim), x, y);
                } else {
                    /// Ms. Pac-Man or Otto variant
                    if (global.otto == 0) {
                        /// Ms. Pac-Man death animation
                        draw_sprite(spr_MsDead, floor(deadanim), x, y);
                    } else {
                        /// Otto death animation
                        draw_sprite(spr_OttoDead, floor(deadanim), x, y);
                    }
                }
            } else {
                /// Large maze (Jr. Pac-Man style)
                /// Only draw if death animation hasn't completed (dead < 3)
                if (dead < 3) {
                    draw_sprite(spr_JrDead, floor(deadanim), round(x), round(y));
                }
            }
        }
    } else {
        // ===== PROHIBIT STATE (FROZEN/INVINCIBLE) =====
        /// Draw frozen sprite when Pac is in prohibit state
        /// Prohibit state occurs during certain game events (e.g., level start)
        if (Pac.prohibit == 1) {
            /// Pac is frozen/invincible: draw static sprite (frame 16 = closed mouth)
            
            if (room_width == 448) {
                /// Standard maze size
                if (global.ex1 == 0) {
                    /// Standard Pac-Man frozen sprite
                    draw_sprite_ext(spr_Man, 16, x, y, 1, 1, 0, c_white, 1);
                } else {
                    /// Ms. Pac-Man or Otto variant
                    if (global.otto == 0) {
                        /// Ms. Pac-Man frozen sprite
                        draw_sprite_ext(spr_MsMan, 16, x, y, 1, 1, 0, c_white, 1);
                    } else {
                        /// Otto frozen sprite
                        draw_sprite_ext(spr_OttoMan, 16, x, y, 1, 1, 0, c_white, 1);
                    }
                }
            } else {
                /// Large maze (Jr. Pac-Man style)
                draw_sprite_ext(spr_JrMan, 16, round(x), round(y), 1, 1, 0, c_white, 1);
            }
        } else {
            // ===== NORMAL MOVEMENT ANIMATION =====
            /// Draw normal Pac-Man sprite with movement animation
            /// Check if not eating ghost (chomp == 0) or chomp animation complete (chomper == 2)
            if (chomp == 0 || chomper == 2) {
                /// Normal movement or ghost eating animation complete
                
                if (global.start == false) {
                    /// Game has started (not in intro sequence)
                    
                    // ===== BOOST MODE EFFECTS =====
                    /// Draw speed boost visual effect when boost mode is active
                    if (global.boost > 0) {
                        /// Boost mode active: draw speed lines behind Pac
                        
                        if (global.otto == 1) {
                            /// Otto variant: special boost line handling
                            if (dir == 1) {
                                /// Moving UP: use frame 5 (special up sprite)
                                draw_sprite_ext(spr_boostlines, 5, x, y, 1, 1, 0, c_yellow, 1);
                            } else {
                                if (dir == 3) {
                                    /// Moving DOWN: use frame 6 (special down sprite)
                                    draw_sprite_ext(spr_boostlines, 6, x, y, 1, 1, 0, c_yellow, 1);
                                } else {
                                    /// Moving LEFT or RIGHT: use direction as frame index
                                    draw_sprite_ext(spr_boostlines, dir, x, y, 1, 1, 0, c_yellow, 1);
                                }
                            }
                        } else {
                            /// Standard boost lines
                            if (global.game == 2 && dir == 1) {
                                /// Jr. Pac-Man moving UP: use frame 4
                                draw_sprite_ext(spr_boostlines, 4, x, y, 1, 1, 0, c_yellow, 1);
                            } else {
                                /// Standard: use direction as frame index
                                draw_sprite_ext(spr_boostlines, dir, x, y, 1, 1, 0, c_yellow, 1);
                            }
                        }
                    }
                    
                    // ===== MAIN PAC-MAN SPRITE =====
                    /// Draw Pac-Man sprite with animation based on direction
                    /// Animation frame = (floor(im/2)) + (4*dir)
                    /// - floor(im/2): Cycles 0-1 (2 frames per animation cycle)
                    /// - 4*dir: Adds 0, 4, 8, or 12 based on direction (0=right, 1=up, 2=left, 3=down)
                    /// Result: 16 frames total (4 directions × 2 animation frames × 2 subframes)
                    
                    if (room_width == 448) {
                        /// Standard maze size
                        if (global.ex1 == 0) {
                            /// Standard Pac-Man sprite
                            draw_sprite_ext(spr_Man, (floor(im / 2)) + (4 * dir), x, y, 1, 1, 0, c_white, 1);
                        } else {
                            /// Ms. Pac-Man or Otto variant
                            if (global.otto == 0) {
                                /// Ms. Pac-Man sprite
                                draw_sprite_ext(spr_MsMan, (floor(im / 2)) + (4 * dir), x, y, 1, 1, 0, c_white, 1);
                            } else {
                                /// Otto sprite
                                draw_sprite_ext(spr_OttoMan, (floor(im / 2)) + (4 * dir), x, y, 1, 1, 0, c_white, 1);
                            }
                        }
                    } else {
                        /// Large maze (Jr. Pac-Man style)
                        draw_sprite_ext(spr_JrMan, (floor(im / 2)) + (4 * dir), round(x), round(y), 1, 1, 0, c_white, 1);
                    }
                } else {
                    // ===== GAME START STATE (FROZEN SPRITE) =====
                    /// Draw frozen sprite during game start sequence
                    /// Frame 8 = closed mouth (standard), Frame 9 = closed mouth (Ms. Pac-Man)
                    
                    if (room_width == 448) {
                        /// Standard maze size
                        if (global.ex1 == 0) {
                            /// Standard Pac-Man frozen sprite (frame 8)
                            draw_sprite_ext(spr_Man, 8, x, y, 1, 1, 0, c_white, 1);
                        } else {
                            /// Ms. Pac-Man or Otto variant
                            if (global.otto == 0) {
                                /// Ms. Pac-Man frozen sprite (frame 9)
                                draw_sprite_ext(spr_MsMan, 9, x, y, 1, 1, 0, c_white, 1);
                            } else {
                                /// Otto frozen sprite (frame 8)
                                draw_sprite_ext(spr_OttoMan, 8, x, y, 1, 1, 0, c_white, 1);
                            }
                        }
                    } else {
                        /// Large maze (Jr. Pac-Man style)
                        draw_sprite_ext(spr_JrMan, 9, round(x), round(y), 1, 1, 0, c_white, 1);
                    }
                }
            } else {
                // ===== GHOST EATING ANIMATION =====
                /// Draw ghost eating animation when Pac eats a ghost
                /// chompcount tracks animation frame, pluseat adds offset for plus mode
                /// Scale adjusts sprite size based on current scale value
                
                if (global.plus == 0) {
                    /// Normal mode: cyan color for chomp animation
                    draw_sprite_ext(
                        spr_Chomp,
                        chompcount - 1 + Pac.pluseat,
                        round(x) - (8 * (scale - 1)),
                        round(y) - (8 * (scale - 1)),
                        scale,
                        scale,
                        0,
                        make_color_rgb(0, 255, 255),  // Cyan
                        1
                    );
                } else {
                    /// Plus mode: yellow color for chomp animation
                    draw_sprite_ext(
                        spr_Chomp,
                        chompcount - 1 + Pac.pluseat,
                        round(x) - (8 * (scale - 1)),
                        round(y) - (8 * (scale - 1)),
                        scale,
                        scale,
                        0,
                        make_color_rgb(255, 255, 0),  // Yellow
                        1
                    );
                }
            }
        }
    }
}

// ===== WRAPAROUND RENDERING (TALL ROOMS) =====
/// For rooms with height = 576, render Pac at multiple Y positions
/// This creates seamless vertical wrapping effect
/// Check if room height supports wraparound
var __b__;
__b__ = action_if_variable(room_height, 576, 0);
if (__b__) {
    // ===== RENDER AT Y-512 (ABOVE CURRENT POSITION) =====
    /// Draw Pac at position 512 pixels above current Y
    /// This handles wraparound when Pac moves up past top edge
    
    if (alarm[9] == -1) {
        /// Only render if not in death sequence
        
        // ===== DEATH ANIMATION (WRAPPED) =====
        if (dead > 1) {
            if (deader == 1) {
                if (room_width == 448) {
                    if (global.ex1 == 0) {
                        draw_sprite(spr_Dead, floor(deadanim), x, (y - 512));
                    } else {
                        if (global.otto == 0) {
                            draw_sprite(spr_MsDead, floor(deadanim), x, (y - 512));
                        } else {
                            draw_sprite(spr_OttoDead, floor(deadanim), x, (y - 512));
                        }
                    }
                } else {
                    if (dead < 3) {
                        draw_sprite(spr_JrDead, floor(deadanim), round(x), round(y - 512));
                    }
                }
            }
        } else {
            // ===== PROHIBIT STATE (WRAPPED) =====
            if (Pac.prohibit == 1) {
                if (room_width == 448) {
                    if (global.ex1 == 0) {
                        draw_sprite_ext(spr_Man, 16, x, (y - 512), 1, 1, 0, c_white, 1);
                    } else {
                        if (global.otto == 0) {
                            draw_sprite_ext(spr_MsMan, 16, x, (y - 512), 1, 1, 0, c_white, 1);
                        } else {
                            draw_sprite_ext(spr_OttoMan, 16, x, (y - 512), 1, 1, 0, c_white, 1);
                        }
                    }
                } else {
                    draw_sprite_ext(spr_JrMan, 16, round(x), round(y - 512), 1, 1, 0, c_white, 1);
                }
            } else {
                // ===== NORMAL MOVEMENT (WRAPPED) =====
                if (chomp == 0 || chomper == 2) {
                    if (global.start == false) {
                        // ===== BOOST MODE EFFECTS (WRAPPED) =====
                        if (global.boost == 1) {
                            if (global.otto == 1) {
                                if (dir == 1) {
                                    draw_sprite_ext(spr_boostlines, 5, x, (y - 512), 1, 1, 0, c_yellow, 1);
                                } else {
                                    if (dir == 3) {
                                        draw_sprite_ext(spr_boostlines, 6, x, (y - 512), 1, 1, 0, c_yellow, 1);
                                    } else {
                                        draw_sprite_ext(spr_boostlines, dir, x, (y - 512), 1, 1, 0, c_yellow, 1);
                                    }
                                }
                            } else {
                                if (global.game == 2 && dir == 1) {
                                    draw_sprite_ext(spr_boostlines, 4, x, (y - 512), 1, 1, 0, c_yellow, 1);
                                } else {
                                    draw_sprite_ext(spr_boostlines, dir, x, (y - 512), 1, 1, 0, c_yellow, 1);
                                }
                            }
                        }
                        
                        // ===== MAIN SPRITE (WRAPPED) =====
                        if (room_width == 448) {
                            if (global.ex1 == 0) {
                                draw_sprite_ext(spr_Man, (floor(im / 2)) + (4 * dir), x, (y - 512), 1, 1, 0, c_white, 1);
                            } else {
                                if (global.otto == 0) {
                                    draw_sprite_ext(spr_MsMan, (floor(im / 2)) + (4 * dir), x, (y - 512), 1, 1, 0, c_white, 1);
                                } else {
                                    draw_sprite_ext(spr_OttoMan, (floor(im / 2)) + (4 * dir), x, (y - 512), 1, 1, 0, c_white, 1);
                                }
                            }
                        } else {
                            draw_sprite_ext(spr_JrMan, (floor(im / 2)) + (4 * dir), round(x), round(y - 512), 1, 1, 0, c_white, 1);
                        }
                    } else {
                        // ===== FROZEN SPRITE (WRAPPED) =====
                        if (room_width == 448) {
                            if (global.ex1 == 0) {
                                draw_sprite_ext(spr_Man, 8, x, (y - 512), 1, 1, 0, c_white, 1);
                            } else {
                                if (global.otto == 0) {
                                    draw_sprite_ext(spr_MsMan, 9, x, (y - 512), 1, 1, 0, c_white, 1);
                                } else {
                                    draw_sprite_ext(spr_OttoMan, 8, x, (y - 512), 1, 1, 0, c_white, 1);
                                }
                            }
                        } else {
                            draw_sprite_ext(spr_JrMan, 9, round(x), round(y - 512), 1, 1, 0, c_white, 1);
                        }
                    }
                } else {
                    // ===== GHOST EATING ANIMATION (WRAPPED) =====
                    if (global.plus == 0) {
                        draw_sprite_ext(
                            spr_Chomp,
                            chompcount - 1 + Pac.pluseat,
                            round(x) - (8 * (scale - 1)),
                            round(y - 512) - (8 * (scale - 1)),
                            scale,
                            scale,
                            0,
                            make_color_rgb(0, 255, 255),  // Cyan
                            1
                        );
                    } else {
                        draw_sprite_ext(
                            spr_Chomp,
                            chompcount - 1 + Pac.pluseat,
                            round(x) - (8 * (scale - 1)),
                            round(y - 512) - (8 * (scale - 1)),
                            scale,
                            scale,
                            0,
                            make_color_rgb(255, 255, 0),  // Yellow
                            1
                        );
                    }
                }
            }
        }
    }
    
    // ===== RENDER AT Y+512 (BELOW CURRENT POSITION) =====
    /// Draw Pac at position 512 pixels below current Y
    /// This handles wraparound when Pac moves down past bottom edge
    
    if (alarm[9] == -1) {
        /// Only render if not in death sequence
        
        // ===== DEATH ANIMATION (WRAPPED) =====
        if (dead > 1) {
            if (deader == 1) {
                if (room_width == 448) {
                    if (global.ex1 == 0) {
                        draw_sprite(spr_Dead, floor(deadanim), x, (y + 512));
                    } else {
                        if (global.otto == 0) {
                            draw_sprite(spr_MsDead, floor(deadanim), x, (y + 512));
                        } else {
                            draw_sprite(spr_OttoDead, floor(deadanim), x, (y + 512));
                        }
                    }
                } else {
                    if (dead < 3) {
                        draw_sprite(spr_JrDead, floor(deadanim), round(x), round(y + 512));
                    }
                }
            }
        } else {
            // ===== PROHIBIT STATE (WRAPPED) =====
            if (Pac.prohibit == 1) {
                if (room_width == 448) {
                    if (global.ex1 == 0) {
                        draw_sprite_ext(spr_Man, 16, x, (y + 512), 1, 1, 0, c_white, 1);
                    } else {
                        if (global.otto == 0) {
                            draw_sprite_ext(spr_MsMan, 16, x, (y + 512), 1, 1, 0, c_white, 1);
                        } else {
                            draw_sprite_ext(spr_OttoMan, 16, x, (y + 512), 1, 1, 0, c_white, 1);
                        }
                    }
                } else {
                    draw_sprite_ext(spr_JrMan, 16, round(x), round(y + 512), 1, 1, 0, c_white, 1);
                }
            } else {
                // ===== NORMAL MOVEMENT (WRAPPED) =====
                if (chomp == 0 || chomper == 2) {
                    if (global.start == false) {
                        // ===== BOOST MODE EFFECTS (WRAPPED) =====
                        if (global.boost == 1) {
                            if (global.otto == 1) {
                                if (dir == 1) {
                                    draw_sprite_ext(spr_boostlines, 5, x, (y + 512), 1, 1, 0, c_yellow, 1);
                                } else {
                                    if (dir == 3) {
                                        draw_sprite_ext(spr_boostlines, 6, x, (y + 512), 1, 1, 0, c_yellow, 1);
                                    } else {
                                        draw_sprite_ext(spr_boostlines, dir, x, (y + 512), 1, 1, 0, c_yellow, 1);
                                    }
                                }
                            } else {
                                if (global.game == 2 && dir == 1) {
                                    draw_sprite_ext(spr_boostlines, 4, x, (y + 512), 1, 1, 0, c_yellow, 1);
                                } else {
                                    draw_sprite_ext(spr_boostlines, dir, x, (y + 512), 1, 1, 0, c_yellow, 1);
                                }
                            }
                        }
                        
                        // ===== MAIN SPRITE (WRAPPED) =====
                        if (room_width == 448) {
                            if (global.ex1 == 0) {
                                draw_sprite_ext(spr_Man, (floor(im / 2)) + (4 * dir), x, (y + 512), 1, 1, 0, c_white, 1);
                            } else {
                                if (global.otto == 0) {
                                    draw_sprite_ext(spr_MsMan, (floor(im / 2)) + (4 * dir), x, (y + 512), 1, 1, 0, c_white, 1);
                                } else {
                                    draw_sprite_ext(spr_OttoMan, (floor(im / 2)) + (4 * dir), x, (y + 512), 1, 1, 0, c_white, 1);
                                }
                            }
                        } else {
                            draw_sprite_ext(spr_JrMan, (floor(im / 2)) + (4 * dir), round(x), round(y + 512), 1, 1, 0, c_white, 1);
                        }
                    } else {
                        // ===== FROZEN SPRITE (WRAPPED) =====
                        if (room_width == 448) {
                            if (global.ex1 == 0) {
                                draw_sprite_ext(spr_Man, 8, x, (y + 512), 1, 1, 0, c_white, 1);
                            } else {
                                if (global.otto == 0) {
                                    draw_sprite_ext(spr_MsMan, 9, x, (y + 512), 1, 1, 0, c_white, 1);
                                } else {
                                    draw_sprite_ext(spr_OttoMan, 8, x, (y + 512), 1, 1, 0, c_white, 1);
                                }
                            }
                        } else {
                            draw_sprite_ext(spr_JrMan, 9, round(x), round(y + 512), 1, 1, 0, c_white, 1);
                        }
                    }
                } else {
                    // ===== GHOST EATING ANIMATION (WRAPPED) =====
                    if (global.plus == 0) {
                        draw_sprite_ext(
                            spr_Chomp,
                            chompcount - 1 + Pac.pluseat,
                            round(x) - (8 * (scale - 1)),
                            round(y + 512) - (8 * (scale - 1)),
                            scale,
                            scale,
                            0,
                            make_color_rgb(0, 255, 255),  // Cyan
                            1
                        );
                    } else {
                        draw_sprite_ext(
                            spr_Chomp,
                            chompcount - 1 + Pac.pluseat,
                            round(x) - (8 * (scale - 1)),
                            round(y + 512) - (8 * (scale - 1)),
                            scale,
                            scale,
                            0,
                            make_color_rgb(255, 255, 0),  // Yellow
                            1
                        );
                    }
                }
            }
        }
    }
}


/// ===============================================================================
/// COMMENTED OUT CODE (LEGACY/UNUSED)
/// ===============================================================================
/// The following code sections are commented out but preserved for reference:
/// - Credit display logic
/// - Title screen rendering
/// - Score display (handled elsewhere)
/// - Lives display (handled elsewhere)
/// - Fruit display (handled elsewhere)
/// - Game over/continue messages (handled elsewhere)
///
/// These features are likely handled by UI objects (Menu, Title, etc.)
/// ===============================================================================

/// ===============================================================================
/// END PAC DRAW_0 EVENT
/// ===============================================================================
