shader_type spatial;

uniform sampler2DArray atlas_array : filter_nearest;
uniform bool use_uniform_index = false;
uniform int manual_texture_index = 0;
uniform float inset : hint_range(0.0, 0.1) = 0.015;

varying flat int texture_index;

void vertex() {
    // Only set the varying if we aren't using the uniform override
    if (!use_uniform_index) {
        texture_index = int(TANGENT.x);
    }
}

void fragment() {
    // Determine the index to use
    int final_index = use_uniform_index ? manual_texture_index : texture_index;
	
	// Calculate inset UVs
    // Maps [0, 1] to [inset, 1-inset]
    vec2 inset_uv = mix(vec2(inset), vec2(1.0 - inset), UV.xy);
    vec4 tex = texture(atlas_array, vec3(inset_uv, float(final_index)));
    if (tex.a < 0.5) discard;
    ALBEDO = tex.rgb;
}