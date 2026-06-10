shader_type spatial;

uniform sampler2DArray atlas_array;

varying flat int texture_index;

void vertex() {
    // We store our layer index in the x-component of the TANGENT 
    // vector when we build the mesh surface arrays.
    texture_index = int(TANGENT.x);
}

void fragment() {
    // Use the index passed from the vertex shader to sample the array
    vec4 tex = texture(atlas_array, vec3(UV.xy, float(texture_index)));
    if (tex.a < 0.5) discard;
    ALBEDO = tex.rgb;
}