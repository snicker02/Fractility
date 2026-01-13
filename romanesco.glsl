#[compute]
#version 450

// We generate 64 points per workgroup
layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

// Output buffer: xyz = position, w = color (packed float)
layout(set = 0, binding = 0, std430) buffer PointBuffer {
    vec4 points[];
};

// --- UNIFORMS (Matching JWildfire Parameters) ---
layout(push_constant) uniform Params {
    float size;
    int recursion_depth;
    
    int num_arms;
    float arm_spread;
    float arm_elevation;
    float arm_twist;
    
    int floret_count;
    float floret_scale;
    float pattern_spread;
    float spiral_twist;
    float cone_steepness;
    float floret_detail_size;
    int floret_shape;
    
    float pitch;
    float yaw;
    float roll;
    
    int color_mode;
    float solid_color_idx;
    float color_range_min;
    float color_range_max;
    
    float total_points; // Helper to normalize global ID
    float time_seed;    // For randomness
} p;

// --- CONSTANTS ---
const float PI = 3.14159265359;
const float GOLDEN_ANGLE = 2.399963229728653; // PI * (3.0 - sqrt(5.0))

// --- RANDOM FUNCTIONS ---
// High-quality hash for randomness based on thread ID
uint hash(uint x) {
    x += (x << 10u);
    x ^= (x >> 6u);
    x += (x << 3u);
    x ^= (x >> 11u);
    x += (x << 15u);
    return x;
}

// Returns a float between 0.0 and 1.0
float random_float(inout uint state) {
    state = hash(state);
    return float(state & 0x00FFFFFFu) / float(0x00FFFFFFu);
}

void main() {
    uint id = gl_GlobalInvocationID.x;
    if (id >= uint(p.total_points)) return;

    // Initialize RNG state
    uint rng_state = hash(id + uint(p.time_seed * 10000.0));

    // Initialize Transformation State (IFS)
    float current_scale = p.size;
    vec3 pos = vec3(0.0);
    
    // Manual basis vectors (JWF style)
    vec3 axis_x = vec3(1.0, 0.0, 0.0);
    vec3 axis_y = vec3(0.0, 1.0, 0.0);
    vec3 axis_z = vec3(0.0, 0.0, 1.0);

    // --- 1. ARM PLACEMENT ---
    if (p.num_arms > 1) {
        int arm_index = int(random_float(rng_state) * float(p.num_arms));
        float arm_base_angle = float(arm_index) / float(p.num_arms) * 2.0 * PI;

        pos.x = p.arm_spread * cos(arm_base_angle);
        pos.y = p.arm_spread * sin(arm_base_angle);
        pos.z = 0.0;

        float elevation_rad = radians(p.arm_elevation);
        float twist_rad = pos.y * p.arm_twist; // Twist based on Y dist
        float arm_angle = arm_base_angle + twist_rad;

        // Calculate new Z axis based on arm orientation
        vec3 temp_z;
        temp_z.x = cos(arm_angle) * cos(elevation_rad);
        temp_z.y = sin(arm_angle) * cos(elevation_rad);
        temp_z.z = sin(elevation_rad);
        axis_z = temp_z;

        // Re-orthogonalize basis
        vec3 up_vec = vec3(0.0, 0.0, 1.0);
        if (abs(axis_z.z) > 0.999) {
            up_vec = vec3(1.0, 0.0, 0.0);
        }
        
        axis_x = normalize(cross(axis_z, up_vec));
        axis_y = normalize(cross(axis_z, axis_x));
    }

    // --- 2. RECURSIVE LOOP ---
    for (int i = 0; i < p.recursion_depth; i++) {
        // Pick a random floret index (biased towards outer edges)
        float r_rnd = random_float(rng_state);
        int floret_index = int(pow(r_rnd, 1.5) * float(p.floret_count));
        
        float spiral_angle = float(floret_index) * GOLDEN_ANGLE * p.spiral_twist;
        float r = p.pattern_spread * sqrt(float(floret_index));

        // Local position in the spiral
        float local_x = r * cos(spiral_angle);
        float local_y = r * sin(spiral_angle);
        float local_z = r * p.cone_steepness;

        // Update global position based on current basis
        pos += (axis_x * local_x + axis_y * local_y + axis_z * local_z) * current_scale;

        // Calculate Normal for the new orientation
        vec3 normal;
        normal.x = -p.cone_steepness * cos(spiral_angle);
        normal.y = -p.cone_steepness * sin(spiral_angle);
        normal.z = 1.0;
        normal = normalize(normal);

        // Update Basis Vectors
        vec3 new_axis_z = axis_x * normal.x + axis_y * normal.y + axis_z * normal.z;
        axis_z = normalize(new_axis_z);

        vec3 up_vec = vec3(0.0, 1.0, 0.0);
        if (abs(axis_z.y) > 0.999) {
            up_vec = vec3(1.0, 0.0, 0.0);
        }

        axis_x = normalize(cross(up_vec, axis_z));
        axis_y = normalize(cross(axis_z, axis_x));

        current_scale *= p.floret_scale;
    }

    // --- 3. GENERATE FLORET GEOMETRY ---
    vec3 local_final = vec3(0.0);
    float shape_size = p.floret_detail_size * current_scale;

    if (p.floret_shape == 0) { // Sphere
        vec3 rand_vec = vec3(random_float(rng_state)-0.5, random_float(rng_state)-0.5, random_float(rng_state)-0.5);
        if (length(rand_vec) > 0.00001) {
            local_final = normalize(rand_vec) * (shape_size * random_float(rng_state));
        }
    } 
    else if (p.floret_shape == 1) { // Cube
        local_final = vec3(
            (random_float(rng_state) - 0.5) * shape_size,
            (random_float(rng_state) - 0.5) * shape_size,
            (random_float(rng_state) - 0.5) * shape_size
        );
    }
    else if (p.floret_shape == 2) { // Spike
        local_final.z = shape_size * random_float(rng_state);
    }
    else if (p.floret_shape == 3) { // Ring
        float ring_angle = random_float(rng_state) * 2.0 * PI;
        local_final.x = shape_size * cos(ring_angle);
        local_final.y = shape_size * sin(ring_angle);
    }

    // Apply final basis transform
    vec3 final_pos = pos + (axis_x * local_final.x + axis_y * local_final.y + axis_z * local_final.z);

    // --- 4. GLOBAL ROTATION (Pitch, Yaw, Roll) ---
    // Doing Y-axis (Yaw)
    float rad_y = radians(p.yaw);
    float cy = cos(rad_y); float sy = sin(rad_y);
    float tx = final_pos.x * cy - final_pos.z * sy;
    float tz = final_pos.x * sy + final_pos.z * cy;
    final_pos.x = tx; final_pos.z = tz;

    // Doing X-axis (Pitch)
    float rad_p = radians(p.pitch);
    float cp = cos(rad_p); float sp = sin(rad_p);
    float ty = final_pos.y * cp - final_pos.z * sp;
          tz = final_pos.y * sp + final_pos.z * cp;
    final_pos.y = ty; final_pos.z = tz;

    // Doing Z-axis (Roll)
    float rad_r = radians(p.roll);
    float cr = cos(rad_r); float sr = sin(rad_r);
          tx = final_pos.x * cr - final_pos.y * sr;
          ty = final_pos.x * sr + final_pos.y * cr;
    final_pos.x = tx; final_pos.y = ty;

    // --- 5. COLORING ---
    float color_val = 0.5;
    float range = p.color_range_max - p.color_range_min;
    
    if (p.color_mode == 0) { // Solid
        color_val = p.solid_color_idx;
    } else if (p.color_mode == 1) { // Dist from center
        float dist = length(final_pos);
        if (range > 0.000001) color_val = (dist - p.color_range_min) / range;
    } else if (p.color_mode == 2) { // Radius (XY plane)
        float rad = length(final_pos.xy);
        if (range > 0.000001) color_val = (rad - p.color_range_min) / range;
    } else if (p.color_mode == 3) { // Z axis
        if (range > 0.000001) color_val = (final_pos.z - p.color_range_min) / range;
    }
    
    color_val = clamp(color_val, 0.0, 1.0);

    // Output
    points[id] = vec4(final_pos, color_val);
}