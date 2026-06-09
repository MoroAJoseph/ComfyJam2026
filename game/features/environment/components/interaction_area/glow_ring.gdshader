shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 2.0, 1.0);
uniform float emission_strength : hint_range(0.0, 10.0) = 2.0;

uniform float gradient_bottom : hint_range(-1.0, 1.0) = -0.1;
uniform float gradient_top : hint_range(0.0, 1.0) = 0.025;

uniform float ring_bottom : hint_range(-1.0, 1.0) = 0.0;
uniform float ring_top : hint_range(-1.0, 1.0) = 0.05;

// Pass the object's local Y position to the fragment shader
varying float local_y;

void vertex() {
    local_y = VERTEX.y;
}

void fragment() {
    float gradient = smoothstep(gradient_bottom, gradient_top, local_y);
    float final_gradient = 1.0 - gradient;
    
    // Create the ring mask using the preserved local_y
    float ring = step(ring_bottom, local_y) * step(local_y, ring_top);
    
    ALBEDO = glow_color.rgb;
    EMISSION = glow_color.rgb * emission_strength;
    
    ALPHA = clamp(max(ring, final_gradient * 0.5), 0.0, 1.0);
}