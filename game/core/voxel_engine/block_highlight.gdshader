shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_always; 

uniform float fresnel_power : hint_range(1.0, 10.0) = 3.0;
uniform float expansion : hint_range(0.0, 0.5) = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 face_color : source_color = vec4(1.0, 1.0, 1.0, 0.2);

void vertex() {
    VERTEX += NORMAL * expansion;
}

void fragment() {
    // Standard Fresnel-like edge detection
    // dot(NORMAL, VIEW) is 1.0 at the center of the face and 0.0 at the edges
    float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
    
    vec4 final_color = mix(face_color, edge_color, fresnel);
    
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
}