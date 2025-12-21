shader_type canvas_item;

// --- SETTINGS ---
// Customize these in the Inspector to create your variations
uniform vec4 snowflake_color : source_color = vec4(0.1, 0.35, 0.65, 1.0);
uniform float size : hint_range(0.1, 1.0) = 0.8;
uniform float thickness : hint_range(0.001, 0.1) = 0.015;

// Branch Settings
uniform int branch_count : hint_range(0, 8) = 4;     // How many spikes per arm
uniform float branch_angle : hint_range(0.0, 3.14) = 0.8; // Angle of spikes
uniform float branch_len : hint_range(0.0, 0.5) = 0.2;    // Length of spikes

// Core Math: Signed Distance Function for a Line Segment
float sdLine(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

void fragment() {
    // 1. SETUP COORDINATES
    // Center the UVs at (0,0) and scale to keep aspect ratio square if needed
    vec2 uv = (UV - 0.5) * 2.0;
    
    // 2. KALEIDOSCOPE MATH (The 6-Fold Symmetry)
    // We convert to Polar Coordinates (Angle & Radius)
    float angle = atan(uv.x, uv.y); // Using x,y puts 0 at the top
    float radius = length(uv);
    
    // The Magic: Divide the circle into 6 slices (PI/3)
    float slice = 3.14159 / 3.0;
    
    // 'Mod' wraps the angle so we only have to draw ONE slice
    angle = mod(angle, slice) - 0.5 * slice;
    
    // 'Abs' mirrors the slice down the middle (Bilateral symmetry)
    angle = abs(angle);
    
    // Convert back to Cartesian (X,Y) but now 'p' is inside that single mirrored wedge
    vec2 p = vec2(sin(angle), cos(angle)) * radius;

    // 3. DRAWING THE SHAPES
    // We start with a large distance and carve out shapes
    float dist = 100.0;
    
    // A. The Main Stem (A vertical line in our rotated space)
    dist = min(dist, sdLine(p, vec2(0.0, 0.0), vec2(0.0, size)));
    
    // B. The Branches (The V-shapes)
    // We loop to place multiple branches along the main stem
    for(int i = 1; i <= branch_count; i++) {
        // Calculate position up the stem (0.0 to size)
        float t = float(i) / float(branch_count + 1) * size;
        
        // Define the start and end of the branch line
        vec2 start_pos = vec2(0.0, t);
        
        // Calculate the tip position using the uniform angle
        // We slightly shorten branches as they get further out for a "Christmas Tree" shape
        float taper = 1.0 - (t / size) * 0.3; 
        vec2 tip_pos = start_pos + vec2(sin(branch_angle), cos(branch_angle)) * branch_len * taper;
        
        dist = min(dist, sdLine(p, start_pos, tip_pos));
    }
    
    // 4. RENDERING
    // Smoothstep creates that crisp "vector" edge with Anti-Aliasing
    float shape = 1.0 - smoothstep(thickness, thickness + 0.01, dist);
    
    // Output the color
    COLOR = vec4(snowflake_color.rgb, shape * snowflake_color.a);
}