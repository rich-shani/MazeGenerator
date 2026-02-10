/// @description Draw sprite with two different line colors
/// Uses shader if available, otherwise uses draw_sprite_general for gradient coloring
/// @param sprite Sprite to draw
/// @param subimg Sub-image index
/// @param x X position
/// @param y Y position
/// @param line1Color Color for first line (use make_color_rgb)
/// @param line2Color Color for second line (use make_color_rgb)
/// @param line1Y Y position of first line (0.0 to 1.0, normalized)
/// @param line2Y Y position of second line (0.0 to 1.0, normalized)
/// @param lineWidth Width of lines (0.0 to 1.0, normalized)
function draw_sprite_colored_lines(sprite, subimg, x, y, line1Color, line2Color, line1Y, line2Y, lineWidth) {
    // Try to use shader if it's compiled and has the required uniforms
    // Note: Since shader is currently passthrough, this will use the fallback
    if (shader_is_compiled(shdLineColorer)) {
        // Check if shader has the required uniforms (if not, it's just passthrough)
        var hasUniforms = false;
        try {
            shader_get_uniform(shdLineColorer, "u_line1Color");
            hasUniforms = true;
        } catch(e) {
            hasUniforms = false;
        }
        
        if (hasUniforms) {
            shader_set(shdLineColorer);
            
            // Set shader uniforms
            var c1r = color_get_red(line1Color) / 255.0;
            var c1g = color_get_green(line1Color) / 255.0;
            var c1b = color_get_blue(line1Color) / 255.0;
            shader_set_uniform_f(shader_get_uniform(shdLineColorer, "u_line1Color"), c1r, c1g, c1b, 1.0);
            
            var c2r = color_get_red(line2Color) / 255.0;
            var c2g = color_get_green(line2Color) / 255.0;
            var c2b = color_get_blue(line2Color) / 255.0;
            shader_set_uniform_f(shader_get_uniform(shdLineColorer, "u_line2Color"), c2r, c2g, c2b, 1.0);
            
            shader_set_uniform_f(shader_get_uniform(shdLineColorer, "u_line1Y"), line1Y);
            shader_set_uniform_f(shader_get_uniform(shdLineColorer, "u_line2Y"), line2Y);
            shader_set_uniform_f(shader_get_uniform(shdLineColorer, "u_lineWidth"), lineWidth);
            
            // Draw with shader
            draw_sprite(sprite, subimg, x, y);
            
            // Reset shader
            shader_reset();
            return;
        }
    }
    
    // Fallback: Use draw_sprite_general for gradient coloring
    // This creates a gradient from line1Color (top) to line2Color (bottom)
    // Top corners use line1Color, bottom corners use line2Color
    var spriteWidth = sprite_get_width(sprite);
    var spriteHeight = sprite_get_height(sprite);
    
    draw_sprite_general(sprite, subimg, 
        x, y,                          // Position
        spriteWidth, spriteHeight,      // Scale
        0,                             // Rotation
        line1Color, line1Color,         // Top-left, top-right colors
        line2Color, line2Color,         // Bottom-right, bottom-left colors
        1, 1, 1, 1);                   // Alpha values for each corner
}

