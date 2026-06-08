shader_type spatial;

uniform sampler2D atlas : source_color, filter_nearest;

void fragment() {
    vec2 uv_offset = vec2(0.0);
    
    // RED (1,0,0) = Top, GREEN (0,1,0) = Bottom, BLUE (0,0,1) = Side
    if (COLOR.r > 0.5) { 
        uv_offset = vec2(0.0, 0.0); // Top Hex
    } else if (COLOR.b > 0.5) { 
        uv_offset = vec2(0.5, 0.0); // Side Rect
    } else { 
        uv_offset = vec2(0.0, 0.5); // Bottom Hex
    }
    
    // Scale UV to 0.5 to fit your 2x2 grid, then offset
    vec2 final_uv = (UV * 0.5) + uv_offset;
    ALBEDO = texture(atlas, final_uv).rgb;
}