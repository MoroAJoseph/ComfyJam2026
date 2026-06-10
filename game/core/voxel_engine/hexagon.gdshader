shader_type spatial;
uniform sampler2D atlas : source_color, filter_nearest;

void fragment() {
    // UVs are passed directly from the mesh vertex arrays
    vec4 tex = texture(atlas, UV);
    if (tex.a < 0.5) discard;
    ALBEDO = tex.rgb;
}