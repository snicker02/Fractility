shader_type spatial;

// A gradient to map our 0.0 - 1.0 value to colors
uniform sampler2D color_gradient : source_color; 

void vertex() {
    // We saved the color value in the RED channel of Custom Data
    float color_val = INSTANCE_CUSTOM.r;
    
    // Pass it to fragment
    COLOR.rgb = vec3(color_val);
}

void fragment() {
    // Look up the color in the gradient texture
    vec3 gradient_color = texture(color_gradient, vec2(COLOR.r, 0.0)).rgb;
    
    ALBEDO = gradient_color;
    EMISSION = gradient_color * 0.5; // Make it glow slightly
}