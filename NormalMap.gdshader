shader_type canvas_item;

// This uniform will receive your fractal texture (as a height map)
uniform sampler2D height_map : source_color;

// Controls the "steepness" of the bumps, just like the '1.0'
// you were using in 'bump_map_to_normal_map(1.0)'
uniform float strength : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    // Get the size of one pixel in UV coordinates
    vec2 texel_size = 1.0 / vec2(textureSize(height_map, 0));

    // Sample the height from neighboring pixels.
    // We only need one channel (e.g., .r for red) as a height value.
    float h_left = texture(height_map, UV - vec2(texel_size.x, 0.0)).r;
    float h_right = texture(height_map, UV + vec2(texel_size.x, 0.0)).r;
    float h_up = texture(height_map, UV - vec2(0.0, texel_size.y)).r;
    float h_down = texture(height_map, UV + vec2(0.0, texel_size.y)).r;

    // Calculate the horizontal and vertical slopes
    float slope_x = (h_right - h_left) * strength;
    float slope_y = (h_down - h_up) * strength; // Godot's 2D Y-axis is down

    // Create the normal vector (x, y, z)
    // The Z component is 1.0 (pointing "out" of the flat texture)
    vec3 normal = normalize(vec3(slope_x, slope_y, 1.0));

    // Map the normal vector (which is in the -1.0 to 1.0 range)
    // to a color (the 0.0 to 1.0 range) so it can be stored in a texture.
    vec3 color = (normal * 0.5) + 0.5;

    // Set the final pixel color
    COLOR = vec4(color, 1.0);
}