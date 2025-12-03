shader_type canvas_item;

struct VariationResult {
	vec2 uv;
	float dist; // For Orbit Trap / Escape Time
};
// --- Uniforms ---
uniform sampler2D previous_frame : filter_linear;
uniform int variation_mode_a = 0;
uniform int variation_mode_b = 1;
uniform int start_pattern_mode = 0;
uniform float variation_mix = 0.5;
uniform float time;
uniform float feedback_amount = 0.9;
uniform bool seamless_tiling = true;
uniform bool mirror_tiling;
uniform bool show_grid = false;
uniform bool show_circles = true;
uniform sampler2D background_texture;
uniform bool is_animating = false;
uniform float escape_limit = 4.0; // The "Trap" radius
uniform bool use_escape_time = false; // Toggle
uniform int escape_shape = 0; // 0=Circle, 1=Square, 2=Cross, 3=Diamond
uniform float escape_smoothness : hint_range(0.0, 2.0) = 0.1; // How soft the edge is
uniform bool escape_invert = false; // Toggle tunnel vs island







// Start Pattern Uniforms
uniform float circle_count = 4.0;
uniform float circle_radius = 0.2;
uniform float circle_softness = 0.05;
uniform vec4 grad_col_tl = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 grad_col_tr = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 grad_col_bl = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec4 grad_col_br = vec4(1.0, 0.0, 0.0, 1.0);

uniform float circle_grid_scale = 8.0;
uniform float circle_grid_radius = 0.4;
uniform float circle_grid_softness = 0.05;

// Pre-Transform Uniforms
uniform float pre_scale = 1.0;
uniform float pre_rotation = 0.0;
uniform vec2 pre_translate = vec2(0.0);

// Independent Variation Transforms
uniform vec2 translate_a = vec2(0.0);
uniform vec2 translate_b = vec2(0.0);

// Post-Transform Uniforms
uniform float post_scale = 1.0;
uniform float post_rotation = 0.0;
uniform vec2 post_translate = vec2(0.0);

// Color Grading Uniforms
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;

// Wave A Variation Uniforms
uniform int wave_type_a;
uniform float wave_frequency_a;      // Base frequency
uniform float wave_frequency_a_speed; // Speed to animate frequency
uniform float wave_amplitude_a;      // Base amplitude
uniform float wave_amplitude_a_speed; // Speed to animate amplitude
uniform float wave_phase_a;          // Base phase (renamed from wave_speed_a)
uniform float wave_phase_a_speed;    // Speed to animate phase

// Wave B Variation Uniforms
uniform int wave_type_b;
uniform float wave_frequency_b;
uniform float wave_frequency_b_speed;
uniform float wave_amplitude_b;
uniform float wave_amplitude_b_speed;
uniform float wave_phase_b;
uniform float wave_phase_b_speed;

// Julian2 A Uniforms
uniform float julian_power_a;
uniform float julian_power_a_speed;
uniform float julian_dist_a;
uniform float julian_dist_a_speed;
uniform float julian_a_a;
uniform float julian_a_a_speed;
uniform float julian_b_a;
uniform float julian_b_a_speed;
uniform float julian_c_a;
uniform float julian_c_a_speed;
uniform float julian_d_a;
uniform float julian_d_a_speed;
uniform float julian_e_a;
uniform float julian_e_a_speed;
uniform float julian_f_a;
uniform float julian_f_a_speed;

// Julian2 B Uniforms
uniform float julian_power_b;
uniform float julian_power_b_speed;
uniform float julian_dist_b;
uniform float julian_dist_b_speed;
uniform float julian_a_b;
uniform float julian_a_b_speed;
uniform float julian_b_b;
uniform float julian_b_b_speed;
uniform float julian_c_b;
uniform float julian_c_b_speed;
uniform float julian_d_b;
uniform float julian_d_b_speed;
uniform float julian_e_b;
uniform float julian_e_b_speed;
uniform float julian_f_b;
uniform float julian_f_b_speed;
// Fisheye/Polar Uniforms
uniform float fisheye_strength_a;
uniform float fisheye_strength_a_speed;
uniform float polar_offset_a;
uniform float polar_offset_a_speed;
uniform float fisheye_strength_b;
uniform float fisheye_strength_b_speed;
uniform float polar_offset_b;
uniform float polar_offset_b_speed;

// Symmetry Uniforms

uniform float var_a_mirror_x;
uniform float var_a_mirror_y;
uniform float var_a_mirror_rotation;
uniform float var_a_mirror_rotation_speed;
uniform float var_a_kaleidoscope_slices;
uniform float var_a_kaleidoscope_rotation;
uniform float var_a_kaleidoscope_rotation_speed;

uniform float var_b_mirror_x;
uniform float var_b_mirror_y;
uniform float var_b_mirror_rotation;
uniform float var_b_mirror_rotation_speed;
uniform float var_b_kaleidoscope_slices;
uniform float var_b_kaleidoscope_rotation;
uniform float var_b_kaleidoscope_rotation_speed;

// Mobius A Uniforms
uniform float mobius_re_a_a;
uniform float mobius_re_a_a_speed;
uniform float mobius_im_a_a;
uniform float mobius_im_a_a_speed;
uniform float mobius_re_b_a;
uniform float mobius_re_b_a_speed;
uniform float mobius_im_b_a;
uniform float mobius_im_b_a_speed;
uniform float mobius_re_c_a;
uniform float mobius_re_c_a_speed;
uniform float mobius_im_c_a;
uniform float mobius_im_c_a_speed;
uniform float mobius_re_d_a;
uniform float mobius_re_d_a_speed;
uniform float mobius_im_d_a;
uniform float mobius_im_d_a_speed;

// Mobius B Uniforms
uniform float mobius_re_a_b;
uniform float mobius_re_a_b_speed;
uniform float mobius_im_a_b;
uniform float mobius_im_a_b_speed;
uniform float mobius_re_b_b;
uniform float mobius_re_b_b_speed;
uniform float mobius_im_b_b;
uniform float mobius_im_b_b_speed;
uniform float mobius_re_c_b;
uniform float mobius_re_c_b_speed;
uniform float mobius_im_c_b;
uniform float mobius_im_c_b_speed;
uniform float mobius_re_d_b;
uniform float mobius_re_d_b_speed;
uniform float mobius_im_d_b;
uniform float mobius_im_d_b_speed;

// Cellular Weave A Uniforms
uniform float cellular_weave_grid_size_a;
uniform float cellular_weave_grid_size_a_speed;
uniform float cellular_weave_threshold_a;
uniform float cellular_weave_threshold_a_speed;
uniform float cellular_weave_iterations_a;
uniform float cellular_weave_iterations_a_speed;

// Cellular Weave B Uniforms
uniform float cellular_weave_grid_size_b;
uniform float cellular_weave_grid_size_b_speed;
uniform float cellular_weave_threshold_b;
uniform float cellular_weave_threshold_b_speed;
uniform float cellular_weave_iterations_b;
uniform float cellular_weave_iterations_b_speed;

// --- Heart A Uniforms ---
uniform float heart_scale_a;
uniform float heart_scale_a_speed;
uniform float heart_rotation_a;
uniform float heart_rotation_a_speed;
uniform float heart_strength_a;
uniform float heart_strength_a_speed;

// --- Heart B Uniforms ---
uniform float heart_scale_b;
uniform float heart_scale_b_speed;
uniform float heart_rotation_b;
uniform float heart_rotation_b_speed;
uniform float heart_strength_b;
uniform float heart_strength_b_speed;

// --- Add uniforms for Blur ---
uniform float blur_amount_a;
uniform float blur_amount_b;


// Apollonian A Uniforms
uniform float apollonian_scale_a;
uniform float apollonian_scale_a_speed;
uniform float ap_c1x_a;
uniform float ap_c1x_a_speed;
uniform float ap_c1y_a;
uniform float ap_c1y_a_speed;
uniform float ap_c2x_a;
uniform float ap_c2x_a_speed;
uniform float ap_c2y_a;
uniform float ap_c2y_a_speed;
uniform float ap_c3x_a;
uniform float ap_c3x_a_speed;
uniform float ap_c3y_a;
uniform float ap_c3y_a_speed;

// Apollonian B Uniforms
uniform float apollonian_scale_b;
uniform float apollonian_scale_b_speed;
uniform float ap_c1x_b;
uniform float ap_c1x_b_speed;
uniform float ap_c1y_b;
uniform float ap_c1y_b_speed;
uniform float ap_c2x_b;
uniform float ap_c2x_b_speed;
uniform float ap_c2y_b;
uniform float ap_c2y_b_speed;
uniform float ap_c3x_b;
uniform float ap_c3x_b_speed;
uniform float ap_c3y_b;
uniform float ap_c3y_b_speed;
// ArcTangent A Uniforms
uniform float arctangent_scale_a;
uniform float arctangent_scale_a_speed;
uniform float arctangent_strength_a;
uniform float arctangent_strength_a_speed;

// ArcTangent B Uniforms
uniform float arctangent_scale_b;
uniform float arctangent_scale_b_speed;
uniform float arctangent_strength_b;
uniform float arctangent_strength_b_speed;
uniform int custom_tl_a; uniform int custom_tr_a; uniform int custom_bl_a; uniform int custom_br_a;
uniform int custom_tl_b; uniform int custom_tr_b; uniform int custom_bl_b; uniform int custom_br_b;
// Clifford A Uniforms
uniform float clifford_a_a;
uniform float clifford_a_a_speed;
uniform float clifford_b_a;
uniform float clifford_b_a_speed;
uniform float clifford_c_a;
uniform float clifford_c_a_speed;
uniform float clifford_d_a;
uniform float clifford_d_a_speed;

// Clifford B Uniforms
uniform float clifford_a_b;
uniform float clifford_a_b_speed;
uniform float clifford_b_b;
uniform float clifford_b_b_speed;
uniform float clifford_c_b;
uniform float clifford_c_b_speed;
uniform float clifford_d_b;
uniform float clifford_d_b_speed;

// Cosine A Uniforms
uniform float cosine_scale_a;
uniform float cosine_scale_a_speed;
uniform float cosine_strength_a;
uniform float cosine_strength_a_speed;

// Cosine B Uniforms
uniform float cosine_scale_b;
uniform float cosine_scale_b_speed;
uniform float cosine_strength_b;
uniform float cosine_strength_b_speed;

uniform float dejong_a_a;
uniform float dejong_a_a_speed;
uniform float dejong_b_a;
uniform float dejong_b_a_speed;
uniform float dejong_c_a;
uniform float dejong_c_a_speed;
uniform float dejong_d_a;
uniform float dejong_d_a_speed;

// DeJong B Uniforms
uniform float dejong_a_b;
uniform float dejong_a_b_speed;
uniform float dejong_b_b;
uniform float dejong_b_b_speed;
uniform float dejong_c_b;
uniform float dejong_c_b_speed;
uniform float dejong_d_b;
uniform float dejong_d_b_speed;
// Truchet A Uniforms
uniform float truchet_scale_a;
uniform float truchet_scale_a_speed;
uniform float truchet_rotate_a;
uniform float truchet_rotate_a_speed;
uniform float truchet_strength_a;
uniform float truchet_strength_a_speed;
uniform float truchet_mode_a;

// Truchet B Uniforms
uniform float truchet_scale_b;
uniform float truchet_scale_b_speed;
uniform float truchet_rotate_b;
uniform float truchet_rotate_b_speed;
uniform float truchet_strength_b;
uniform float truchet_strength_b_speed;
uniform float truchet_mode_b;
// Hyperbolic Cosine A Uniforms
uniform float hyperbolic_cosine_scale_a;
uniform float hyperbolic_cosine_scale_a_speed;
uniform float hyperbolic_cosine_strength_a;
uniform float hyperbolic_cosine_strength_a_speed;

// Hyperbolic Cosine B Uniforms
uniform float hyperbolic_cosine_scale_b;
uniform float hyperbolic_cosine_scale_b_speed;
uniform float hyperbolic_cosine_strength_b;
uniform float hyperbolic_cosine_strength_b_speed;

// Hyperbolic Sine A Uniforms
uniform float hyperbolic_sine_scale_a;
uniform float hyperbolic_sine_scale_a_speed;
uniform float hyperbolic_sine_strength_a;
uniform float hyperbolic_sine_strength_a_speed;

// Hyperbolic Sine B Uniforms
uniform float hyperbolic_sine_scale_b;
uniform float hyperbolic_sine_scale_b_speed;
uniform float hyperbolic_sine_strength_b;
uniform float hyperbolic_sine_strength_b_speed;

// Sinusoidal A Uniforms
uniform float sinusoidal_scale_a;
uniform float sinusoidal_scale_a_speed;
uniform float sinusoidal_strength_a;
uniform float sinusoidal_strength_a_speed;

// Sinusoidal B Uniforms
uniform float sinusoidal_scale_b;
uniform float sinusoidal_scale_b_speed;
uniform float sinusoidal_strength_b;
uniform float sinusoidal_strength_b_speed;

// Spherical A Uniforms
uniform float spherical_strength_a;
uniform float spherical_strength_a_speed;
uniform float spherical_center_x_a;
uniform float spherical_center_x_a_speed;
uniform float spherical_center_y_a;
uniform float spherical_center_y_a_speed;

// Spherical B Uniforms
uniform float spherical_strength_b;
uniform float spherical_strength_b_speed;
uniform float spherical_center_x_b;
uniform float spherical_center_x_b_speed;
uniform float spherical_center_y_b;
uniform float spherical_center_y_b_speed;

// Swirl A Uniforms
uniform float swirl_radius_scale_a;
uniform float swirl_radius_scale_a_speed;
uniform float swirl_angle_scale_a;
uniform float swirl_angle_scale_a_speed;

// Swirl B Uniforms
uniform float swirl_radius_scale_b;
uniform float swirl_radius_scale_b_speed;
uniform float swirl_angle_scale_b;
uniform float swirl_angle_scale_b_speed;

// Tangent A Uniforms
uniform float tangent_scale_a;
uniform float tangent_scale_a_speed;
uniform float tangent_strength_a;
uniform float tangent_strength_a_speed;

// Rep-Tile A Uniforms
uniform float reptile_scale_a;
uniform float reptile_scale_a_speed;
uniform float reptile_rotate_a;
uniform float reptile_rotate_a_speed;

// Rep-Tile B Uniforms
uniform float reptile_scale_b;
uniform float reptile_scale_b_speed;
uniform float reptile_rotate_b;
uniform float reptile_rotate_b_speed;

// Tangent B Uniforms
uniform float tangent_scale_b;
uniform float tangent_scale_b_speed;
uniform float tangent_strength_b;
uniform float tangent_strength_b_speed;

// Popcorn A Uniforms
uniform float popcorn_scale_a;
uniform float popcorn_scale_a_speed;
uniform float popcorn_strength_a;
uniform float popcorn_strength_a_speed;
uniform float popcorn_density_a; // Controls the "grain" size
uniform float popcorn_density_a_speed;

// Popcorn B Uniforms
uniform float popcorn_scale_b;
uniform float popcorn_scale_b_speed;
uniform float popcorn_strength_b;
uniform float popcorn_strength_b_speed;
uniform float popcorn_density_b;
uniform float popcorn_density_b_speed;

// Lazy Mega A
uniform int lazy_shape_a;
uniform int lazy_inside_mode_a;
uniform int lazy_outside_mode_a;
uniform float lazy_amount_a; uniform float lazy_amount_a_speed;
uniform float lazy_twist_a; uniform float lazy_twist_a_speed;
uniform float lazy_spin_a; uniform float lazy_spin_a_speed;
uniform float lazy_space_a; uniform float lazy_space_a_speed;
uniform float lazy_offset_x_a;
uniform float lazy_offset_y_a;
uniform int lazy_ring_mode_a;
uniform float lazy_ring_spin_a; uniform float lazy_ring_spin_a_speed;
uniform float lazy_edge_softness_a;

// Lazy Mega B
uniform int lazy_shape_b;
uniform int lazy_inside_mode_b;
uniform int lazy_outside_mode_b;
uniform float lazy_amount_b; uniform float lazy_amount_b_speed;
uniform float lazy_twist_b; uniform float lazy_twist_b_speed;
uniform float lazy_spin_b; uniform float lazy_spin_b_speed;
uniform float lazy_space_b; uniform float lazy_space_b_speed;
uniform float lazy_offset_x_b;
uniform float lazy_offset_y_b;
uniform int lazy_ring_mode_b;
uniform float lazy_ring_spin_b;
uniform float lazy_ring_spin_b_speed;
uniform float lazy_edge_softness_b;

// GlynnSim A
uniform float glynn_radius_a; uniform float glynn_radius_a_speed;
uniform float glynn_thickness_a; uniform float glynn_thickness_a_speed;
uniform float glynn_contrast_a; uniform float glynn_contrast_a_speed;
uniform float glynn_pow_a; uniform float glynn_pow_a_speed;
uniform float glynn_phi1_a; uniform float glynn_phi1_a_speed;
uniform float glynn_phi2_a; uniform float glynn_phi2_a_speed;
uniform int glynn_ring_mode_a;

// GlynnSim B (Copy A variables but with _b suffix)
uniform float glynn_radius_b; uniform float glynn_radius_b_speed;
uniform float glynn_thickness_b; uniform float glynn_thickness_b_speed;
uniform float glynn_contrast_b; uniform float glynn_contrast_b_speed;
uniform float glynn_pow_b; uniform float glynn_pow_b_speed;
uniform float glynn_phi1_b; uniform float glynn_phi1_b_speed;
uniform float glynn_phi2_b; uniform float glynn_phi2_b_speed;
uniform int glynn_ring_mode_b;

// --- Helper Functions ---
mat2 rotate(float angle) {
	return mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}
// Simple pseudo-random number function
float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}



// --- ADD THIS HELPER FUNCTION ---
// Skews square coordinates into hexagonal-style coordinates
vec2 to_hex_grid(vec2 p) {
	// Constants for hexagonal grid math
	float SQRT_3 = 1.7320508;
	vec2 p_skew = mat2(vec2(1.0, 0.0), vec2(0.5, SQRT_3 / 2.0)) * p;
	return p_skew;
}

float get_cell_value(vec2 p, vec2 offset) {
    // A simple hash to get a pseudo-random value for a cell
    p += offset;
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec2 apply_quad_transform(vec2 p, int transform_id) {
	// Transform IDs: 0:Identity, 1:R+90, 2:R180, 3:R-90, 4:FlipX, 5:FlipY
	if (transform_id == 1) { // Rotate +90
		p = vec2(-p.y, p.x);
	} else if (transform_id == 2) { // Rotate 180
		p = -p;
	} else if (transform_id == 3) { // Rotate -90
		p = vec2(p.y, -p.x);
	} else if (transform_id == 4) { // Flip X
		p = vec2(-p.x, p.y);
	} else if (transform_id == 5) { // Flip Y
		p = vec2(p.x, -p.y);
	}
	// Default (transform_id == 0) is Identity (return p)
	return p;
}

// --- REVISED: The function signature is now back to its original, simpler form ---
vec2 apply_variation(vec2 uv, int variation_id,
	// Sinusoidal
	float sinusoidal_scale, float sinusoidal_scale_speed,
	float sinusoidal_strength, float sinusoidal_strength_speed,
	// Spherical
	float spherical_strength, float spherical_strength_speed,
	float spherical_center_x, float spherical_center_x_speed,
	float spherical_center_y, float spherical_center_y_speed,
	// Swirl
	float swirl_radius_scale, float swirl_radius_scale_speed,
	float swirl_angle_scale, float swirl_angle_scale_speed,
	// Tangent
	float tangent_scale, float tangent_scale_speed,
	float tangent_strength, float tangent_strength_speed,
	// Wave
	int wave_type, float wave_frequency, float wave_frequency_speed, float wave_amplitude, float wave_amplitude_speed, float wave_phase, float wave_phase_speed,
	// Julian
	float julian_power, float julian_power_speed, float julian_dist, float julian_dist_speed,
	float julian_a, float julian_a_speed, float julian_b, float julian_b_speed,
	float julian_c, float julian_c_speed, float julian_d, float julian_d_speed,
	float julian_e, float julian_e_speed, float julian_f, float julian_f_speed,
	// Fisheye / Polar
	float fisheye_strength, float fisheye_strength_speed, float polar_offset, float polar_offset_speed,
	// Symmetry
	float mirror_x, float mirror_y, float mirror_rotation, float mirror_rotation_speed,
	float kaleidoscope_slices, float kaleidoscope_rotation, float kaleidoscope_rotation_speed,
	// Mobius
	float mobius_re_a, float mobius_re_a_speed, float mobius_im_a, float mobius_im_a_speed,
	float mobius_re_b, float mobius_re_b_speed, float mobius_im_b, float mobius_im_b_speed,
	float mobius_re_c, float mobius_re_c_speed, float mobius_im_c, float mobius_im_c_speed,
	float mobius_re_d, float mobius_re_d_speed, float mobius_im_d, float mobius_im_d_speed,
	// Cellular Weave
	float cellular_grid_size, float cellular_grid_size_speed,
	float cellular_threshold, float cellular_threshold_speed,
	float cellular_iterations, float cellular_iterations_speed,
	// Blur
	float blur_amount,
	// Heart
	float heart_scale, float heart_scale_speed,
	float heart_rotation, float heart_rotation_speed,
	float heart_strength, float heart_strength_speed,
	// Apollonian
	float apollonian_scale, float apollonian_scale_speed,
	float ap_c1x, float ap_c1x_speed, float ap_c1y, float ap_c1y_speed,
	float ap_c2x, float ap_c2x_speed, float ap_c2y, float ap_c2y_speed,
	float ap_c3x, float ap_c3x_speed, float ap_c3y, float ap_c3y_speed,
	// ArcTangent
	float arctangent_scale, float arctangent_scale_speed,
	float arctangent_strength, float arctangent_strength_speed,
	// Cosine
	float cosine_scale, float cosine_scale_speed,
	float cosine_strength, float cosine_strength_speed,
	// Hyperbolic Cosine
	float hyperbolic_cosine_scale, float hyperbolic_cosine_scale_speed,
	float hyperbolic_cosine_strength, float hyperbolic_cosine_strength_speed,
	// Hyperbolic Sine
	float hyperbolic_sine_scale, float hyperbolic_sine_scale_speed,
	float hyperbolic_sine_strength, float hyperbolic_sine_strength_speed,
	// Custom 2x2
	int custom_tl, int custom_tr, int custom_bl, int custom_br,
	// Clifford
	float clifford_a, float clifford_a_speed, float clifford_b, float clifford_b_speed,
	float clifford_c, float clifford_c_speed, float clifford_d, float clifford_d_speed,
	// DeJong
	float dejong_a, float dejong_a_speed, float dejong_b, float dejong_b_speed,
	float dejong_c, float dejong_c_speed, float dejong_d, float dejong_d_speed,
	// Truchet
	float truchet_scale, float truchet_scale_speed,
	float truchet_rotate, float truchet_rotate_speed,
	float truchet_strength, float truchet_strength_speed,
	float truchet_mode,
	// Reptile
	float reptile_scale, float reptile_scale_speed, float reptile_rotate, float reptile_rotate_speed,
	// Popcorn
	float popcorn_scale, float popcorn_scale_speed,
	float popcorn_strength, float popcorn_strength_speed,
	float popcorn_density, float popcorn_density_speed,
	// GlynnSim
    float glynn_radius, float glynn_thickness, float glynn_contrast,
	float glynn_pow, float glynn_phi1, float glynn_phi2,
	float glynn_radius_speed, float glynn_thickness_speed, float glynn_contrast_speed,
	float glynn_pow_speed, float glynn_phi1_speed, float glynn_phi2_speed,
	int glynn_ring_mode,
	// Lazy Mega
	int lazy_shape, int lazy_inside_mode, int lazy_outside_mode,
	float lazy_amount, float lazy_amount_speed,
	float lazy_twist, float lazy_twist_speed,
	float lazy_spin, float lazy_spin_speed,
	float lazy_space, float lazy_space_speed,
	float lazy_offset_x, float lazy_offset_y,
	int lazy_ring_mode,
	float lazy_ring_spin, float lazy_ring_spin_speed,
	float lazy_edge_softness,

) {
	if (variation_id == 0) { // Sinusoidal
    // 1. Calculate animated values
    float anim_scale = sinusoidal_scale + sin(time * sinusoidal_scale_speed);
    float anim_strength = sinusoidal_strength + sin(time * sinusoidal_strength_speed);

    // 2. Apply parameters
    return sin(uv * anim_scale) * anim_strength;
}
	else if (variation_id == 1) { // Spherical
    // 1. Calculate animated values
    float anim_strength = spherical_strength + sin(time * spherical_strength_speed);
    float anim_center_x = spherical_center_x + sin(time * spherical_center_x_speed);
    float anim_center_y = spherical_center_y + sin(time * spherical_center_y_speed);

    // 2. Reconstruct center vec2
    vec2 center = vec2(anim_center_x, anim_center_y);

    // 3. Apply logic
    vec2 p = uv - center;
    float r2 = dot(p, p);
    if (r2 > 1e-9) { // Avoid divide by zero
        return center + (p / r2) * anim_strength;
    }
    return uv; // Return original uv if at center
} else if (variation_id == 2) { // Swirl
    // 1. Calculate animated values
    float anim_radius_scale = swirl_radius_scale + sin(time * swirl_radius_scale_speed);
    float anim_angle_scale = swirl_angle_scale + sin(time * swirl_angle_scale_speed);

    // 2. Apply logic
    float r = length(uv);
    float angle = atan(uv.y, uv.x);
    float s = sin(r * anim_radius_scale - angle * anim_angle_scale);
    float c = cos(r * anim_radius_scale - angle * anim_angle_scale);
    return vec2(s, c) * r;
} else if (variation_id == 3) { // Wave
    // 1. Calculate the animated values
    float freq = wave_frequency + sin(time * wave_frequency_speed);
    float amp = wave_amplitude + sin(time * wave_amplitude_speed);
    float phase = wave_phase + sin(time * wave_phase_speed);

    // 2. The rest of the logic uses these new animated values
    float offset = 0.0;
    if (wave_type == 0) { // Vertical
        offset = sin(uv.y * freq + phase) * amp;
        return uv + vec2(offset, 0.0);
    } else if (wave_type == 1) { // Radial
        float r = length(uv);
        offset = sin(r * freq + phase) * amp;
        return uv * (1.0 + offset);
    } else { // Square
        offset = sign(sin(uv.y * freq + phase)) * amp;
        return uv + vec2(offset, 0.0);
    }
} else if (variation_id == 4) { // Julian2
		// 1. Calculate all animated values first
		float anim_power = julian_power + sin(time * julian_power_speed);
		float anim_dist = julian_dist + sin(time * julian_dist_speed);
		float anim_a = julian_a + sin(time * julian_a_speed);
		float anim_b = julian_b + sin(time * julian_b_speed);
		float anim_c = julian_c + sin(time * julian_c_speed);
		float anim_d = julian_d + sin(time * julian_d_speed);
		float anim_e = julian_e + sin(time * julian_e_speed);
		float anim_f = julian_f + sin(time * julian_f_speed);

		// 2. Re-create the matrix and vector
		mat2 julian_mat = mat2(vec2(anim_a, anim_c), vec2(anim_b, anim_d));
		vec2 julian_trans = vec2(anim_e, anim_f);

		// 3. Call the julian function with the animated values
		if (anim_power == 0.0) { return uv; }
		float _cN = anim_dist / anim_power * 0.5;
		vec2 p = uv * julian_mat + julian_trans;
		float angle = atan(p.y, p.x) / anim_power;
		float r = pow(dot(p, p), _cN);
		return vec2(r * cos(angle), r * sin(angle));
	} else if (variation_id == 5) { // Polar
    // 1. Calculate animated value
    float anim_offset = polar_offset + sin(time * polar_offset_speed);

    // 2. Apply logic
    float r = length(uv);
    float theta = atan(uv.y, uv.x);
    return vec2(theta / PI, r - anim_offset);
} else if (variation_id == 6) { // Fisheye
		float anim_strength = fisheye_strength + sin(time * fisheye_strength_speed);
		float r = length(uv);
		return (anim_strength / (r + 1.0)) * uv;
	} else if (variation_id == 7) { // Mirror
    // 1. Calculate and apply animated rotation
    float anim_rotation = mirror_rotation + (time * mirror_rotation_speed);
    vec2 p = uv * rotate(radians(anim_rotation));

    // 2. Apply mirror logic (check if float is > 0.5)
    if (mirror_x > 0.5) { p.x = abs(p.x); }
    if (mirror_y > 0.5) { p.y = abs(p.y); }
    return p;
	} else if (variation_id == 8) { // Kaleidoscope
		// 1. Calculate animated rotation
    float anim_rotation = kaleidoscope_rotation + (time * kaleidoscope_rotation_speed);

    // 2. Apply rotation to the coordinate system (using your 'vec * mat' syntax)
    vec2 p = uv * rotate(radians(anim_rotation));

    // 3. Apply kaleidoscope logic to the rotated coordinates
    // Note: We use the non-animated 'kaleidoscope_slices' for stability
    if (kaleidoscope_slices <= 0.0) { return p; } // Return just the rotated UVs

    float angle = atan(p.y, p.x);
    float r = length(p);
    float slice_angle = PI / kaleidoscope_slices;
    angle = mod(angle, slice_angle * 2.0);
    angle = abs(angle - slice_angle);
    p.x = r * cos(angle);
    p.y = r * sin(angle);

    // 4. Return the sliced, rotated coordinates
    return p;
}    else if (variation_id == 9) { // Mobius
        // 1. Calculate all 8 animated values
        float anim_re_a = mobius_re_a + sin(time * mobius_re_a_speed);
        float anim_im_a = mobius_im_a + sin(time * mobius_im_a_speed);
        float anim_re_b = mobius_re_b + sin(time * mobius_re_b_speed);
        float anim_im_b = mobius_im_b + sin(time * mobius_im_b_speed);
        float anim_re_c = mobius_re_c + sin(time * mobius_re_c_speed);
        float anim_im_c = mobius_im_c + sin(time * mobius_im_c_speed);
        float anim_re_d = mobius_re_d + sin(time * mobius_re_d_speed);
        float anim_im_d = mobius_im_d + sin(time * mobius_im_d_speed);

        // 2. Reconstruct the complex numbers (a, b, c, d) as vec2s
        vec2 m_a = vec2(anim_re_a, anim_im_a);
        vec2 m_b = vec2(anim_re_b, anim_im_b);
        vec2 m_c = vec2(anim_re_c, anim_im_c);
        vec2 m_d = vec2(anim_re_d, anim_im_d);

        // 3. Run the original Mobius logic with the new vec2s
        // u = a*z + b
        vec2 u = vec2(m_a.x * uv.x - m_a.y * uv.y, m_a.x * uv.y + m_a.y * uv.x) + m_b;

        // v = c*z + d
        vec2 v = vec2(m_c.x * uv.x - m_c.y * uv.y, m_c.x * uv.y + m_c.y * uv.x) + m_d;

        // Calculate 1 / |v|^2, and protect from division by zero
        float d = dot(v, v);
        if (d < 1e-9) { return uv; } // Return original if denominator is too small
        float inv_d = 1.0 / d;

        // Return u / v, which is (u * conjugate(v)) / |v|^2
        return vec2(u.x * v.x + u.y * v.y, u.y * v.x - u.x * v.y) * inv_d;
    } else if (variation_id == 10) { // Cellular Weave
    // 1. Calculate animated values
    // Use max() to ensure grid size never goes below 2.0 (or any small number)
    float anim_grid = max(2.0, cellular_grid_size + sin(time * cellular_grid_size_speed));
    // Use clamp() to keep the threshold between 0 and 8 (the max neighbors)
    float anim_thresh = clamp(cellular_threshold + sin(time * cellular_threshold_speed), 0.0, 8.0);
    // This one is already correct
    float anim_iter = max(1.0, abs(cellular_iterations + sin(time * cellular_iterations_speed)));

    // 2. Run logic with animated values
    vec2 p = uv;
    for (int i = 0; i < int(anim_iter); i++) {
        vec2 grid_p = floor(p * anim_grid); // Use anim_grid
        float neighbor_sum = 0.0;
        neighbor_sum += get_cell_value(grid_p, vec2(-1.0, -1.0)) > 0.5 ? 1.0 : 0.0;
        neighbor_sum += get_cell_value(grid_p, vec2( 0.0, -1.0)) > 0.5 ? 1.0 : 0.0;
        neighbor_sum += get_cell_value(grid_p, vec2( 1.0, -1.0)) > 0.5 ? 1.0 : 0.0;
        neighbor_sum += get_cell_value(grid_p, vec2(-1.0,  0.0)) > 0.5 ? 1.0 : 0.0;
        neighbor_sum += get_cell_value(grid_p, vec2( 1.0,  0.0)) > 0.5 ? 1.0 : 0.0;
        neighbor_sum += get_cell_value(grid_p, vec2(-1.0,  1.0)) > 0.5 ? 1.0 : 0.0;
        neighbor_sum += get_cell_value(grid_p, vec2( 0.0,  1.0)) > 0.5 ? 1.0 : 0.0;
        neighbor_sum += get_cell_value(grid_p, vec2( 1.0,  1.0)) > 0.5 ? 1.0 : 0.0;

        // 1. Define both possible outcomes
        float angle = neighbor_sum * 0.1;
        vec2 twisted_p = mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle))) * p;

        vec2 cell_center = (grid_p + 0.5) / anim_grid;
        vec2 pulled_p = mix(p, cell_center, 0.1);

        // 2. Create a "soft" threshold instead of a hard "if"
        // This will smoothly blend from 0.0 to 1.0 as the neighbor_sum crosses the threshold
        float softness = 0.5; // Controls how wide the blend is
        float mix_factor = smoothstep(anim_thresh - softness, anim_thresh + softness, neighbor_sum);

        // 3. Mix between the two outcomes using the mix_factor
        p = mix(pulled_p, twisted_p, mix_factor);
    }
    return p;
}	else if (variation_id == 11) { // Blur
        float angle = rand(uv) * 2.0 * PI;
        float radius = rand(uv + vec2(5.2, 3.1)) * blur_amount;
        return uv + vec2(cos(angle), sin(angle)) * radius;
    }else if (variation_id == 12) { // Heart
    // 1. Calculate animated values
    // Use max(0.01, ...) for scale to prevent divide-by-zero
    float anim_scale = max(0.01, heart_scale + sin(time * heart_scale_speed));
    float anim_rotation = heart_rotation + sin(time * heart_rotation_speed);
    float anim_strength = heart_strength + sin(time * heart_strength_speed);

    // 2. Apply scale and rotation
    vec2 p = uv;
    p /= anim_scale;
    p.y *= -1.0;
    p = vec2(cos(radians(anim_rotation)) * p.x - sin(radians(anim_rotation)) * p.y,
               sin(radians(anim_rotation)) * p.x + cos(radians(anim_rotation)) * p.y);

    // --- Heart Shape Formula ---
    float x = p.x;
    float y = p.y;

    float heart_val = pow(x*x + y*y - 1.0, 3.0) - x*x * pow(y, 3.0);

    vec2 displacement = normalize(vec2(
        3.0 * pow(x*x + y*y - 1.0, 2.0) * (2.0*x) - 2.0*x*pow(y, 3.0),
        3.0 * pow(x*x + y*y - 1.0, 2.0) * (2.0*y) - x*x * 3.0*pow(y, 2.0)
    ));

    if (heart_val < 0.0) {
        displacement *= -1.0;
    }

    // 3. Apply animated strength
    return uv + displacement * anim_strength * 0.1; // *0.1 to keep it subtle
}
else if (variation_id == 13) { // Apollonian Gasket (Iterative Approximation)
    vec2 p = uv;

    // 1. Calculate all animated values
    float anim_scale = apollonian_scale + sin(time * apollonian_scale_speed);
    float anim_c1x = ap_c1x + sin(time * ap_c1x_speed);
    float anim_c1y = ap_c1y + sin(time * ap_c1y_speed);
    float anim_c2x = ap_c2x + sin(time * ap_c2x_speed);
    float anim_c2y = ap_c2y + sin(time * ap_c2y_speed);
    float anim_c3x = ap_c3x + sin(time * ap_c3x_speed);
    float anim_c3y = ap_c3y + sin(time * ap_c3y_speed);

    // 2. Reconstruct the vec2 centers
    vec2 c1 = vec2(anim_c1x, anim_c1y);
    vec2 c2 = vec2(anim_c2x, anim_c2y);
    vec2 c3 = vec2(anim_c3x, anim_c3y);

    // 3. Find the closest center
    float d1 = distance(p, c1);
    float d2 = distance(p, c2);
    float d3 = distance(p, c3);

    vec2 closest_center;
    if (d1 < d2 && d1 < d3) {
        closest_center = c1;
    } else if (d2 < d3) {
        closest_center = c2;
    } else {
        closest_center = c3;
    }

    // 4. Map the point
    if (abs(anim_scale) < 1e-6) { return p; } // Protect from divide by zero
    p = closest_center + (p - closest_center) / anim_scale;

    return p;
}
	// --- END APOLLONIAN GASKET ---
	else if (variation_id == 14) {
	// 1. Calculate animated values
    float anim_scale = cosine_scale + sin(time * cosine_scale_speed);
    float anim_strength = cosine_strength + sin(time * cosine_strength_speed);

    // 2. Apply parameters
    return cos(uv * anim_scale) * anim_strength;
	}
	// --- ADD TANGENT (Mode 15) ---
	else if (variation_id == 15) { // Tangent
    // 1. Calculate animated values
    float anim_scale = tangent_scale + sin(time * tangent_scale_speed);
    float anim_strength = tangent_strength + sin(time * tangent_strength_speed);

    // 2. Apply parameters
    // We simply multiply uv by scale. If the user sets scale to ~1.57 (PI/2),
    // they will get the extreme stretching effect.
    return tan(uv * anim_scale) * anim_strength;
}
	// --- ADD ARCTANGENT (Mode 16) ---
	else if (variation_id == 16) { // ArcTangent
    // 1. Calculate animated values
    float anim_scale = arctangent_scale + sin(time * arctangent_scale_speed);
    float anim_strength = arctangent_strength + sin(time * arctangent_strength_speed);

    // 2. Apply parameters
    return atan(uv * anim_scale) * anim_strength;
}
	// --- ADD HYPERBOLIC SINE (Mode 17) ---
	else if (variation_id == 17) { // Hyperbolic Sine
    // 1. Calculate animated values
    float anim_scale = hyperbolic_sine_scale + sin(time * hyperbolic_sine_scale_speed);
    float anim_strength = hyperbolic_sine_strength + sin(time * hyperbolic_sine_strength_speed);

    // 2. Apply parameters
    return sinh(uv * anim_scale) * anim_strength;
}
	// --- ADD HYPERBOLIC COSINE (Mode 18) ---
	else if (variation_id == 18) { // Hyperbolic Cosine
    // 1. Calculate animated values
    float anim_scale = hyperbolic_cosine_scale + sin(time * hyperbolic_cosine_scale_speed);
    float anim_strength = hyperbolic_cosine_strength + sin(time * hyperbolic_cosine_strength_speed);

    // 2. Apply parameters
    return cosh(uv * anim_scale) * anim_strength;
	}
	// --- ADD L-TROMINO (Mode 19) ---
	// --- REP-TILES GROUP ---
    // Now INCLUDES ID 20 (Custom 2x2)
    if (variation_id >= 19 && variation_id <= 31) {

        // 1. Calculate Animated Transforms
        float anim_scale = max(0.01, reptile_scale + sin(time * reptile_scale_speed));
        float anim_rot = reptile_rotate + sin(time * reptile_rotate_speed);

        // 2. Apply global rotation to UV
        vec2 p = uv * rotate(radians(anim_rot));

        // L-Tromino (19)
        if (variation_id == 19) {
            p *= 2.0 * anim_scale;
            if (p.x >= 0.0 && p.y >= 0.0) { p = vec2(p.y, -p.x) + vec2(-1.0, 1.0); }
            else if (p.x < 0.0 && p.y >= 0.0) { p = p + vec2(1.0, -1.0); }
            else if (p.x < 0.0 && p.y < 0.0) { p = p + vec2(1.0, 1.0); }
            else { p = vec2(-p.y, p.x) + vec2(-1.0, -1.0); }
            return p / 2.0;
        }
        // Custom 2x2 (20) - NEWLY ADDED HERE
        else if (variation_id == 20) {
            // For ID 20, we apply scale at the END to preserve the 0.5 offsets
            vec2 q = p * 2.0;

            if (q.x > 0.0 && q.y > 0.0) { // TR
                 q = (apply_quad_transform(q - vec2(0.5, 0.5), custom_tr) * 0.5) + vec2(0.5, 0.5);
            } else if (q.x <= 0.0 && q.y > 0.0) { // TL
                 q = (apply_quad_transform(q - vec2(-0.5, 0.5), custom_tl) * 0.5) + vec2(-0.5, 0.5);
            } else if (q.x <= 0.0 && q.y <= 0.0) { // BL
                 q = (apply_quad_transform(q - vec2(-0.5, -0.5), custom_bl) * 0.5) + vec2(-0.5, -0.5);
            } else { // BR
                 q = (apply_quad_transform(q - vec2(0.5, -0.5), custom_br) * 0.5) + vec2(0.5, -0.5);
            }

            // Apply the global zoom/scale here
            return (q / 2.0) * anim_scale;
        }
        // Sphinx (21)
        else if (variation_id == 21) {
            p *= 2.0 * anim_scale;
            mat2 R90 = mat2(vec2(0.0, 1.0), vec2(-1.0, 0.0));
            if (p.x + p.y > 0.0) {
                if (p.x - p.y > 0.0) { p = R90 * p + vec2(0.0, 1.0); }
                else { p = p + vec2(-1.0, 0.0); }
            } else {
                if (p.x - p.y > 0.0) { p = p + vec2(1.0, 0.0); }
                else { p = R90 * p + vec2(0.0, -1.0); }
            }
            return p / 2.0;
        }
        // T-Tetromino (22)
        else if (variation_id == 22) {
            p *= 2.0 * anim_scale;
            mat2 R90 = mat2(vec2(0.0, 1.0), vec2(-1.0, 0.0));
            if (p.x >= 0.0 && p.y >= 0.0) { p = R90 * p + vec2(0.0, 1.0); }
            else if (p.x < 0.0 && p.y >= 0.0) { p = R90 * p + vec2(0.0, -1.0); }
            else if (p.x < 0.0 && p.y < 0.0) { p = -p; }
            else { p = p + vec2(-1.0, 1.0); }
            return p / 2.0;
        }
        // Sierpinski Carpet (23)
        else if (variation_id == 23) {
            p = (p * anim_scale + 0.5) * 3.0;
            vec2 i = floor(p);
            if (i.x == 1.0 && i.y == 1.0) { return uv; }
            return fract(p) - 0.5;
        }
        // Gosper Island (24)
        else if (variation_id == 24) {
            p = p + 0.5;
            float GOSPER_SCALE = 2.64575 * anim_scale;
            mat2 R60 = mat2(vec2(0.5, 0.866025), vec2(-0.866025, 0.5));
            vec2 p_hex = to_hex_grid(p);
            vec2 p_scaled = p_hex * GOSPER_SCALE;
            vec2 f = fract(p_scaled);
            vec2 i = floor(p_scaled);
            vec2 i_sq = vec2(i.x - floor(i.y / 2.0), i.y);
            int tile_index = int(mod(i_sq.x + i_sq.y * 2.0, 7.0));
            vec2 c_offset = vec2(0.0);
            if (tile_index == 1) { c_offset = vec2(1.0, 0.0); }
            else if (tile_index == 2) { c_offset = vec2(0.0, 1.0); }
            else if (tile_index == 3) { c_offset = vec2(-1.0, 1.0); }
            else if (tile_index == 4) { c_offset = vec2(-1.0, 0.0); }
            else if (tile_index == 5) { c_offset = vec2(0.0, -1.0); }
            else if (tile_index == 6) { c_offset = vec2(1.0, -1.0); }
            vec2 f_unskew = mat2(vec2(1.0, 0.0), vec2(-0.5 / 0.866025, 1.0 / 0.866025)) * f;
            vec2 result = (R60 * f_unskew) + c_offset;
            result = result / GOSPER_SCALE;
            return result - 0.5;
        }
        // Carpet Corners (25)
        else if (variation_id == 25) {
            p = (p * anim_scale + 0.5) * 3.0;
            vec2 i = floor(p);
            if ( (i.x == 0.0 || i.x == 2.0) && (i.y == 0.0 || i.y == 2.0) ) { return fract(p) - 0.5; }
            return uv;
        }
        // Carpet Cross (26)
        else if (variation_id == 26) {
            p = (p * anim_scale + 0.5) * 3.0;
            vec2 i = floor(p);
            if (i.x == 1.0 || i.y == 1.0) { return fract(p) - 0.5; }
            return uv;
        }
        // Pentagonal (27)
        else if (variation_id == 27) {
            float scale = 1.618034 * anim_scale;
            vec2 c1 = vec2(0.0, 0.5); vec2 c2 = vec2(0.4755, 0.1545); vec2 c3 = vec2(0.2939, -0.4045);
            vec2 c4 = vec2(-0.2939, -0.4045); vec2 c5 = vec2(-0.4755, 0.1545);
            float d1 = distance(p, c1); float d2 = distance(p, c2); float d3 = distance(p, c3);
            float d4 = distance(p, c4); float d5 = distance(p, c5);
            vec2 closest = c1; float min_d = d1;
            if (d2 < min_d) { min_d = d2; closest = c2; }
            if (d3 < min_d) { min_d = d3; closest = c3; }
            if (d4 < min_d) { min_d = d4; closest = c4; }
            if (d5 < min_d) { closest = c5; }
            return closest + (p - closest) / scale;
        }
        // Diagonal Carpet (28)
        else if (variation_id == 28) {
            p = (p * anim_scale + 0.5) * 3.0;
            vec2 i = floor(p);
            if ( (i.x == 1.0 && i.y != 1.0) || (i.y == 1.0 && i.x != 1.0) ) { return uv; }
            return fract(p) - 0.5;
        }
        // Penrose Star (29)
        else if (variation_id == 29) {
            float scale = 1.8 * anim_scale;
            vec2 c1 = vec2(0.0, 0.5); vec2 c2 = vec2(0.4755, 0.1545); vec2 c3 = vec2(0.2939, -0.4045);
            vec2 c4 = vec2(-0.2939, -0.4045); vec2 c5 = vec2(-0.4755, 0.1545);
            float d1 = distance(p, c1); float d2 = distance(p, c2); float d3 = distance(p, c3);
            float d4 = distance(p, c4); float d5 = distance(p, c5);
            vec2 closest = c1; float min_d = d1;
            if (d2 < min_d) { min_d = d2; closest = c2; }
            if (d3 < min_d) { min_d = d3; closest = c3; }
            if (d4 < min_d) { min_d = d4; closest = c4; }
            if (d5 < min_d) { closest = c5; }
            return closest + (p - closest) / scale;
        }
        // Hex Tile (30)
        else if (variation_id == 30) {
            float SCALE = 3.0 * anim_scale;
            vec2 p_hex = to_hex_grid(p);
            p_hex *= SCALE;
            vec2 f = fract(p_hex);
            vec2 i = floor(p_hex);
            vec2 i_sq = vec2(i.x - floor(i.y / 2.0), i.y);
            int tile_index = int(mod(i_sq.x + i_sq.y * 2.0, 7.0));
            if (tile_index == 0) { return uv * SCALE; }
            vec2 f_unskew = mat2(vec2(1.0, 0.0), vec2(-0.5 / 0.866025, 1.0 / 0.866025)) * f;
            return f_unskew - 0.5;
        }
        // Twindragon (31)
        else if (variation_id == 31) {
            p *= 2.0 * anim_scale;
            mat2 R90 = mat2(vec2(0.0, 1.0), vec2(-1.0, 0.0));
            if (p.x < 0.0) { p = R90 * p + vec2(0.0, 1.0); }
            else { p = p + vec2(-1.0, 0.0); }
            return p / 2.0;
        }
    }
    // --- END REP-TILES GROUP ---

    // IMPORTANT: You must REMOVE the standalone "else if (variation_id == 20)" block
    // that was below this, because it is now handled inside the group above!
	else if (variation_id == 32) { // Clifford
        // 1. Calculate animated values
        float anim_a = clifford_a + sin(time * clifford_a_speed);
        float anim_b = clifford_b + sin(time * clifford_b_speed);
        float anim_c = clifford_c + sin(time * clifford_c_speed);
        float anim_d = clifford_d + sin(time * clifford_d_speed);

        // 2. Apply formula
        return vec2(sin(anim_a * uv.y) + anim_c * cos(anim_a * uv.x),
                    sin(anim_b * uv.x) + anim_d * cos(anim_b * uv.y));
    }
	else if (variation_id == 33) { // DeJong
    // 1. Calculate all animated values
    float anim_a = dejong_a + sin(time * dejong_a_speed);
    float anim_b = dejong_b + sin(time * dejong_b_speed);
    float anim_c = dejong_c + sin(time * dejong_c_speed);
    float anim_d = dejong_d + sin(time * dejong_d_speed);

    // 2. Apply parameters
    return vec2(sin(anim_a * uv.y) - cos(anim_b * uv.x),
                sin(anim_c * uv.x) - cos(anim_d * uv.y));
}
	else if (variation_id == 34) { // Truchet (Multi-Mode)
        // 1. Calculate animated values
        float anim_scale = max(0.1, truchet_scale + sin(time * truchet_scale_speed));
        float anim_rotate = truchet_rotate + sin(time * truchet_rotate_speed);
        float anim_strength = truchet_strength + sin(time * truchet_strength_speed);

        int mode = int(truchet_mode);

        // --- Mode 0: Displacement ---
        if (mode == 0) {
            vec2 p = uv;
            p = p * rotate(radians(anim_rotate));
            p = p * anim_scale;

            vec2 i = floor(p);
            vec2 f = fract(p);

            float r = rand(i);

            vec2 c1, c2;
            if (r > 0.5) { c1 = vec2(0.0, 1.0); c2 = vec2(1.0, 0.0); }
            else { c1 = vec2(0.0, 0.0); c2 = vec2(1.0, 1.0); }

            vec2 g = normalize(f - c1) - normalize(f - c2);
            vec2 displacement = g * rotate(radians(anim_rotate)) * anim_strength;

            return uv + displacement;
        }
        // --- Mode 1: 90-degree rotate ---
        else if (mode == 1) {
            vec2 p = uv;
            p = p * rotate(radians(anim_rotate));
            p = p * anim_scale;

            vec2 i = floor(p);
            vec2 f = fract(p);

            float r = rand(i);
            if (r > 0.5) {
                f = vec2(f.y, 1.0 - f.x);
            }

            // Calculate the final result
            vec2 result = (i + f) / anim_scale * rotate(radians(-anim_rotate));

            // Mix between original and result based on strength
            return mix(uv, result, anim_strength);
        }
        // --- Mode 2: Swap ---
        else if (mode == 2) {
            vec2 p = uv;
            p = p * rotate(radians(anim_rotate));
            p = p * anim_scale;

            vec2 i = floor(p);
            vec2 f = fract(p);

            float r = rand(i);
            if (r > 0.5) {
                f.x = 1.0 - f.x;
            }
            if (f.x > f.y) {
                f.xy = f.yx;
            }

            // Calculate the final result
            vec2 result = (i + f) / anim_scale * rotate(radians(-anim_rotate));

            // Mix between original and result based on strength
            return mix(uv, result, anim_strength);
        }
        return uv;
			}
	else if (variation_id == 35) { // Popcorn
		// 1. Calculate animated values
		float anim_scale = max(0.01, popcorn_scale + sin(time * popcorn_scale_speed));
		float anim_strength = popcorn_strength + sin(time * popcorn_strength_speed);
		float anim_density = popcorn_density + sin(time * popcorn_density_speed);

		// 2. Apply Scale
		vec2 p = uv / anim_scale;

		// 3. Popcorn Formula
		// x = x - c * sin(y + tan(3 * y))
		// y = y - c * sin(x + tan(3 * x))
		// We use 'anim_density' instead of the hardcoded 3.0

		float dx = anim_strength * sin(p.y + tan(anim_density * p.y));
		float dy = anim_strength * sin(p.x + tan(anim_density * p.x));

		p.x -= dx;
		p.y -= dy;

		return p * anim_scale;
	}
		else if (variation_id == 36) { // Lazy Mega (Soft Edges + Ring Spin)
        // 1. Animate Variables
        float anim_amt = max(0.01, lazy_amount + sin(time * lazy_amount_speed));
        float anim_space = max(0.0, lazy_space + sin(time * lazy_space_speed));
        float anim_twist = lazy_twist + sin(time * lazy_twist_speed);
        float anim_spin = lazy_spin + sin(time * lazy_spin_speed);
        float anim_ring_spin = lazy_ring_spin + (time * lazy_ring_spin_speed); // Continuous spin

        // 2. Center
        vec2 offset = vec2(lazy_offset_x, lazy_offset_y);
        vec2 p = uv - offset;

        // 3. Distance
        float dist = 0.0;
        if (lazy_shape == 0) dist = length(p);
        else if (lazy_shape == 1) dist = max(abs(p.x), abs(p.y));
        else dist = abs(p.x) + abs(p.y);

        // Boundaries
        float inner_edge = anim_amt;
        float outer_edge = anim_amt + anim_space;
        float soft = max(0.001, lazy_edge_softness); // Avoid div by zero

        // --- BLENDING MASKS ---
        // We calculate a blend factor for each zone transition
        float mask_inside = 1.0 - smoothstep(inner_edge - soft, inner_edge, dist);
        float mask_ring = smoothstep(inner_edge - soft, inner_edge, dist) * (1.0 - smoothstep(outer_edge, outer_edge + soft, dist));
        float mask_outside = smoothstep(outer_edge, outer_edge + soft, dist);

        vec2 result = vec2(0.0);

        // --- ZONE 1: INSIDE ---
        if (mask_inside > 0.01) {
            vec2 p_in = p;
            if (lazy_inside_mode == 0) { // Twist
                float a = atan(p.y, p.x) + anim_spin + anim_twist * (inner_edge - dist);
                p_in = vec2(cos(a), sin(a)) * dist;
            } else if (lazy_inside_mode == 1) { // Travis
                p_in += sin(p.yx * 10.0 + anim_spin) * 0.1 * anim_twist;
            }
            result += p_in * mask_inside;
        }

        // --- ZONE 2: RING ---
        if (mask_ring > 0.01) {
            vec2 p_ring = p;
            // Apply independent Ring Spin
            p_ring = p_ring * rotate(anim_ring_spin);

            if (lazy_ring_mode == 0) p_ring = vec2(10000.0); // Empty
            else if (lazy_ring_mode == 1) p_ring = p_ring * (inner_edge / max(0.001, dist));
            else if (lazy_ring_mode == 2) { // Stripes
                 if (sin(dist * 50.0 + anim_spin) > 0.0) p_ring = vec2(10000.0);
            }
            else if (lazy_ring_mode == 3) { // Checkers
                 float a = atan(p.y, p.x);
                 if (sin(dist * 20.0) * sin(a * 10.0) > 0.0) p_ring = vec2(10000.0);
            }// --- NEW PATTERNS ---
			else if (lazy_ring_mode == 4) { // DOTS
				// Create a grid of circles
				vec2 grid = fract(p_ring * 10.0) - 0.5;
				if (length(grid) < 0.3) return vec2(10000.0);
			}
			else if (lazy_ring_mode == 5) { // PLASMA
				// Organic blobs using sine waves
				float v = sin(p_ring.x * 20.0 + time) + sin(p_ring.y * 20.0 + time);
				if (v > 0.0) return vec2(10000.0);
			}
			else if (lazy_ring_mode == 6) { // SPIRAL
				// Twisting stripes
				float a = atan(p_ring.y, p_ring.x);
				// Combine angle and distance to create a spiral
				if (sin(a * 10.0 + dist * 40.0) > 0.0) return vec2(10000.0);
			}
            result += p_ring * mask_ring;
        }

        // --- ZONE 3: OUTSIDE ---
        if (mask_outside > 0.01) {
            vec2 p_out = p;
            if (lazy_outside_mode == 0) { // Inverse
                float r = anim_amt * (1.0 + anim_space / max(0.001, dist));
                p_out = p * (r / dist);
            }
            else if (lazy_outside_mode == 1) { // Travis
                p_out += cos(p.xy * 5.0 + anim_spin) * 0.1;
            }
            result += p_out * mask_outside;
        }

        return result + offset;
    }
	else if (variation_id == 37) { // GlynnSim (Tuned Granular)
		// 1. Animate Variables
		float anim_radius = max(0.001, glynn_radius + sin(time * glynn_radius_speed));
		float anim_thickness = max(0.0, glynn_thickness + sin(time * glynn_thickness_speed));
		// Contrast controls the "density" of the tears (0.0 = All Stretch, 1.0 = No Stretch)
		float anim_contrast = clamp(glynn_contrast + sin(time * glynn_contrast_speed), 0.0, 1.0);
		float anim_pow = glynn_pow + sin(time * glynn_pow_speed);

		// 2. Distance & Zones
		// Use the centered UV for distance to ensure ring is circular
		vec2 p = uv; // You can add an offset here later if you want moveable center
		float r = length(p);

		float inner_edge = anim_radius;
		float outer_edge = anim_radius + anim_thickness;

		// --- ZONE 1: INSIDE (Hole) ---
		if (r < inner_edge) {
			// Map hole to source
			return uv * (1.0 / inner_edge);
		}

		// --- ZONE 2: THE RING ---
		else if (r < outer_edge) {
            // Use the passed argument 'glynn_ring_mode'
			if (glynn_ring_mode == 0) return vec2(10000.0); // EMPTY

			else if (glynn_ring_mode == 1) return uv * (inner_edge / r); // TEXTURE

			else if (glynn_ring_mode == 2) { // STRIPES
                if (sin(r * 50.0 + time) > 0.0) return vec2(10000.0);
            }
			else if (glynn_ring_mode == 3) { // CHECKERS
				float a = atan(uv.y, uv.x);
				if (sin(r * 20.0) * sin(a * 10.0) > 0.0) return vec2(10000.0);
			}
            else if (glynn_ring_mode == 4) { // DOTS
				vec2 grid = fract(uv * 10.0) - 0.5;
				if (length(grid) < 0.3) return vec2(10000.0);
			}
            else if (glynn_ring_mode == 5) { // PLASMA
				float v = sin(uv.x * 20.0 + time) + sin(uv.y * 20.0 + time);
				if (v > 0.0) return vec2(10000.0);
			}
            else if (glynn_ring_mode == 6) { // SPIRAL
				float a = atan(uv.y, uv.x);
				if (sin(a * 10.0 + r * 40.0) > 0.0) return vec2(10000.0);
			}

            return uv * (inner_edge / r); // Default
		}

		// --- ZONE 3: OUTSIDE (The GlynnSim Effect) ---
		else {
			// 1. Shift Space (Push outside away to make room for ring)
			// Map current radius 'r' back to where it starts after the thickness
			float shifted_r = r - anim_thickness;
			vec2 p_shifted = uv * (shifted_r / r);

			// 2. Glynn Math
			// Alpha gets smaller as you go further out
			float alpha = inner_edge / max(0.0001, shifted_r);

			// 3. Probabilistic Tearing (The "Glynn" Look)
			// We use a very high multiplier (500.0) to get fine "sand" grain
			float rnd = rand(uv * 500.0);

			// Calculate threshold based on distance and power
			float threshold = anim_contrast * pow(alpha, abs(anim_pow));

			if (rnd > threshold) {
				// Option A: The "Solid" part (Pass through)
				return p_shifted;
			} else {
				// Option B: The "Torn" part (Stretched)
				// This pulls pixels from far away into the gap
				return p_shifted / (alpha * alpha);
			}
		}
	}
	return uv;
}
vec2 random(vec2 st) {
    st = vec2(dot(st, vec2(127.1,311.7)),
              dot(st, vec2(269.5,183.3)));
    return -1.0 + 2.0 * fract(sin(st) * 43758.5453123);
}
float perlin_noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f*f*(3.0-2.0*f);
    return mix( mix( dot( random(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                     dot( random(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                     dot( random(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

// --- Main Shader Logic ---
// --- Main Shader Logic ---
// --- Main Shader Logic ---
void fragment() {
	vec4 final_color;
	vec4 start_pattern_color;

	// --- STEP 1: Calculate the Start Pattern ---
	if (start_pattern_mode == 0) { // Gradient + Grid
		vec4 top_mix = mix(grad_col_tl, grad_col_tr, UV.x);
		vec4 bottom_mix = mix(grad_col_bl, grad_col_br, UV.x);
		start_pattern_color = mix(top_mix, bottom_mix, UV.y);
		if (show_grid) {
			vec2 pixel_coords = UV / TEXTURE_PIXEL_SIZE;
			float line_width = 1.5;
			if (mod(pixel_coords.x, 50.0) < line_width || mod(pixel_coords.y, 50.0) < line_width) {
				start_pattern_color *= 1.5;
			}
		}
	}
	else if (start_pattern_mode == 1) { // Circles
		vec4 top_mix = mix(grad_col_tl, grad_col_tr, UV.x);
		vec4 bottom_mix = mix(grad_col_bl, grad_col_br, UV.x);
		vec4 gradient_color = mix(top_mix, bottom_mix, UV.y);
		start_pattern_color = gradient_color;
		if (show_circles) {
			vec2 grid_uv = fract(UV * circle_count);
			float dist = distance(grid_uv, vec2(0.5));
			float circle = 1.0 - smoothstep(circle_radius, circle_radius + circle_softness, dist);
			start_pattern_color = vec4(vec3(circle), 1.0) * gradient_color;
		}
	}
	else if (start_pattern_mode == 2) { // Image Input
		if (textureSize(background_texture, 0).x > 1) {
			start_pattern_color = texture(background_texture, UV);
		} else {
			start_pattern_color = vec4(0.0, 0.0, 0.0, 1.0);
		}
	}
	else if (start_pattern_mode == 3) { // Perlin Noise
		float n = perlin_noise(UV * 10.0);
		n = (n + 1.0) * 0.5;
		start_pattern_color = vec4(vec3(n), 1.0);
	}
	else if (start_pattern_mode == 4) { // Concentric Rings
		vec4 top_mix_A = mix(grad_col_tl, grad_col_tr, UV.x);
		vec4 bottom_mix_A = mix(grad_col_bl, grad_col_br, UV.x);
		vec4 gradient_color_A = mix(top_mix_A, bottom_mix_A, UV.y);
		vec4 top_mix_B = mix(grad_col_br, grad_col_bl, UV.x);
		vec4 bottom_mix_B = mix(grad_col_tr, grad_col_tl, UV.x);
		vec4 gradient_color_B = mix(top_mix_B, bottom_mix_B, UV.y);
		float d = distance(UV, vec2(0.5)) * 2.0;
		float v = fract(d * circle_grid_scale);
		float half_width = circle_grid_radius * 0.5;
		float ring_value = smoothstep(0.5 - half_width - circle_grid_softness, 0.5 - half_width, v) -
						   smoothstep(0.5 + half_width, 0.5 + half_width + circle_grid_softness, v);
		start_pattern_color = mix(gradient_color_B, gradient_color_A, ring_value);
	}
	else {
		vec4 top_mix = mix(grad_col_tl, grad_col_tr, UV.x);
		vec4 bottom_mix = mix(grad_col_bl, grad_col_br, UV.x);
		start_pattern_color = mix(top_mix, bottom_mix, UV.y);
	}

	// --- STEP 2: Calculate Feedback ---
	if (time < 0.1) {
		final_color = start_pattern_color;
	}
	else {
		vec2 transformed_uv = UV - vec2(0.5);
		transformed_uv *= rotate(pre_rotation);
		transformed_uv /= pre_scale;
		transformed_uv += pre_translate;

		// --- APPLY VARIATION A ---
		vec2 uv_a = apply_variation(transformed_uv + translate_a, variation_mode_a,
			sinusoidal_scale_a, sinusoidal_scale_a_speed, sinusoidal_strength_a, sinusoidal_strength_a_speed,
			spherical_strength_a, spherical_strength_a_speed, spherical_center_x_a, spherical_center_x_a_speed, spherical_center_y_a, spherical_center_y_a_speed,
			swirl_radius_scale_a, swirl_radius_scale_a_speed, swirl_angle_scale_a, swirl_angle_scale_a_speed,
			tangent_scale_a, tangent_scale_a_speed, tangent_strength_a, tangent_strength_a_speed,
			wave_type_a, wave_frequency_a, wave_frequency_a_speed, wave_amplitude_a, wave_amplitude_a_speed, wave_phase_a, wave_phase_a_speed,
			julian_power_a, julian_power_a_speed, julian_dist_a, julian_dist_a_speed, julian_a_a, julian_a_a_speed, julian_b_a, julian_b_a_speed, julian_c_a, julian_c_a_speed, julian_d_a, julian_d_a_speed, julian_e_a, julian_e_a_speed, julian_f_a, julian_f_a_speed,
			fisheye_strength_a, fisheye_strength_a_speed, polar_offset_a, polar_offset_a_speed,
			var_a_mirror_x, var_a_mirror_y, var_a_mirror_rotation, var_a_mirror_rotation_speed, var_a_kaleidoscope_slices, var_a_kaleidoscope_rotation, var_a_kaleidoscope_rotation_speed,
			mobius_re_a_a, mobius_re_a_a_speed, mobius_im_a_a, mobius_im_a_a_speed, mobius_re_b_a, mobius_re_b_a_speed, mobius_im_b_a, mobius_im_b_a_speed, mobius_re_c_a, mobius_re_c_a_speed, mobius_im_c_a, mobius_im_c_a_speed, mobius_re_d_a, mobius_re_d_a_speed, mobius_im_d_a, mobius_im_d_a_speed,
			cellular_weave_grid_size_a, cellular_weave_grid_size_a_speed, cellular_weave_threshold_a, cellular_weave_threshold_a_speed, cellular_weave_iterations_a, cellular_weave_iterations_a_speed,
			blur_amount_a,
			heart_scale_a, heart_scale_a_speed, heart_rotation_a, heart_rotation_a_speed, heart_strength_a, heart_strength_a_speed,
			apollonian_scale_a, apollonian_scale_a_speed, ap_c1x_a, ap_c1x_a_speed, ap_c1y_a, ap_c1y_a_speed, ap_c2x_a, ap_c2x_a_speed, ap_c2y_a, ap_c2y_a_speed, ap_c3x_a, ap_c3x_a_speed, ap_c3y_a, ap_c3y_a_speed,
			arctangent_scale_a, arctangent_scale_a_speed, arctangent_strength_a, arctangent_strength_a_speed,
			cosine_scale_a, cosine_scale_a_speed, cosine_strength_a, cosine_strength_a_speed,
			hyperbolic_cosine_scale_a, hyperbolic_cosine_scale_a_speed, hyperbolic_cosine_strength_a, hyperbolic_cosine_strength_a_speed,
			hyperbolic_sine_scale_a, hyperbolic_sine_scale_a_speed, hyperbolic_sine_strength_a, hyperbolic_sine_strength_a_speed,
			custom_tl_a, custom_tr_a, custom_bl_a, custom_br_a,
			clifford_a_a, clifford_a_a_speed, clifford_b_a, clifford_b_a_speed, clifford_c_a, clifford_c_a_speed, clifford_d_a, clifford_d_a_speed,
			dejong_a_a, dejong_a_a_speed, dejong_b_a, dejong_b_a_speed, dejong_c_a, dejong_c_a_speed, dejong_d_a, dejong_d_a_speed,
			truchet_scale_a, truchet_scale_a_speed, truchet_rotate_a, truchet_rotate_a_speed, truchet_strength_a, truchet_strength_a_speed, truchet_mode_a,
			reptile_scale_a, reptile_scale_a_speed, reptile_rotate_a, reptile_rotate_a_speed,
			popcorn_scale_a, popcorn_scale_a_speed, popcorn_strength_a, popcorn_strength_a_speed, popcorn_density_a, popcorn_density_a_speed,
			// --- GLYNNSIM A ---
    glynn_radius_a, glynn_thickness_a, glynn_contrast_a, glynn_pow_a, glynn_phi1_a, glynn_phi2_a,
    glynn_radius_a_speed, glynn_thickness_a_speed, glynn_contrast_a_speed, glynn_pow_a_speed, glynn_phi1_a_speed, glynn_phi2_a_speed, glynn_ring_mode_a,

    // --- LAZY MEGA A ---
    lazy_shape_a, lazy_inside_mode_a, lazy_outside_mode_a, lazy_amount_a, lazy_amount_a_speed, lazy_twist_a, lazy_twist_a_speed, lazy_spin_a, lazy_spin_a_speed, lazy_space_a, lazy_space_a_speed, lazy_offset_x_a, lazy_offset_y_a,
    lazy_ring_mode_a, lazy_ring_spin_a, lazy_ring_spin_a_speed, lazy_edge_softness_a
);

		// --- APPLY VARIATION B ---
		vec2 uv_b = apply_variation(transformed_uv + translate_b, variation_mode_b,
			sinusoidal_scale_b, sinusoidal_scale_b_speed, sinusoidal_strength_b, sinusoidal_strength_b_speed,
			spherical_strength_b, spherical_strength_b_speed, spherical_center_x_b, spherical_center_x_b_speed, spherical_center_y_b, spherical_center_y_b_speed,
			swirl_radius_scale_b, swirl_radius_scale_b_speed, swirl_angle_scale_b, swirl_angle_scale_b_speed,
			tangent_scale_b, tangent_scale_b_speed, tangent_strength_b, tangent_strength_b_speed,
			wave_type_b, wave_frequency_b, wave_frequency_b_speed, wave_amplitude_b, wave_amplitude_b_speed, wave_phase_b, wave_phase_b_speed,
			julian_power_b, julian_power_b_speed, julian_dist_b, julian_dist_b_speed, julian_a_b, julian_a_b_speed, julian_b_b, julian_b_b_speed, julian_c_b, julian_c_b_speed, julian_d_b, julian_d_b_speed, julian_e_b, julian_e_b_speed, julian_f_b, julian_f_b_speed,
			fisheye_strength_b, fisheye_strength_b_speed, polar_offset_b, polar_offset_b_speed,
			var_b_mirror_x, var_b_mirror_y, var_b_mirror_rotation, var_b_mirror_rotation_speed, var_b_kaleidoscope_slices, var_b_kaleidoscope_rotation, var_b_kaleidoscope_rotation_speed,
			mobius_re_a_b, mobius_re_a_b_speed, mobius_im_a_b, mobius_im_a_b_speed, mobius_re_b_b, mobius_re_b_b_speed, mobius_im_b_b, mobius_im_b_b_speed, mobius_re_c_b, mobius_re_c_b_speed, mobius_im_c_b, mobius_im_c_b_speed, mobius_re_d_b, mobius_re_d_b_speed, mobius_im_d_b, mobius_im_d_b_speed,
			cellular_weave_grid_size_b, cellular_weave_grid_size_b_speed, cellular_weave_threshold_b, cellular_weave_threshold_b_speed, cellular_weave_iterations_b, cellular_weave_iterations_b_speed,
			blur_amount_b,
			heart_scale_b, heart_scale_b_speed, heart_rotation_b, heart_rotation_b_speed, heart_strength_b, heart_strength_b_speed,
			apollonian_scale_b, apollonian_scale_b_speed, ap_c1x_b, ap_c1x_b_speed, ap_c1y_b, ap_c1y_b_speed, ap_c2x_b, ap_c2x_b_speed, ap_c2y_b, ap_c2y_b_speed, ap_c3x_b, ap_c3x_b_speed, ap_c3y_b, ap_c3y_b_speed,
			arctangent_scale_b, arctangent_scale_b_speed, arctangent_strength_b, arctangent_strength_b_speed,
			cosine_scale_b, cosine_scale_b_speed, cosine_strength_b, cosine_strength_b_speed,
			hyperbolic_cosine_scale_b, hyperbolic_cosine_scale_b_speed, hyperbolic_cosine_strength_b, hyperbolic_cosine_strength_b_speed,
			hyperbolic_sine_scale_b, hyperbolic_sine_scale_b_speed, hyperbolic_sine_strength_b, hyperbolic_sine_strength_b_speed,
			custom_tl_b, custom_tr_b, custom_bl_b, custom_br_b,
			clifford_a_b, clifford_a_b_speed, clifford_b_b, clifford_b_b_speed, clifford_c_b, clifford_c_b_speed, clifford_d_b, clifford_d_b_speed,
			dejong_a_b, dejong_a_b_speed, dejong_b_b, dejong_b_b_speed, dejong_c_b, dejong_c_b_speed, dejong_d_b, dejong_d_b_speed,
			truchet_scale_b, truchet_scale_b_speed, truchet_rotate_b, truchet_rotate_b_speed, truchet_strength_b, truchet_strength_b_speed, truchet_mode_b,
			reptile_scale_b, reptile_scale_b_speed, reptile_rotate_b, reptile_rotate_b_speed,
			popcorn_scale_b, popcorn_scale_b_speed, popcorn_strength_b, popcorn_strength_b_speed, popcorn_density_b, popcorn_density_b_speed,
			// --- GLYNNSIM B ---
    glynn_radius_b, glynn_thickness_b, glynn_contrast_b, glynn_pow_b, glynn_phi1_b, glynn_phi2_b,
    glynn_radius_b_speed, glynn_thickness_b_speed, glynn_contrast_b_speed, glynn_pow_b_speed, glynn_phi1_b_speed, glynn_phi2_b_speed, glynn_ring_mode_b,

    // --- LAZY MEGA B ---
    lazy_shape_b, lazy_inside_mode_b, lazy_outside_mode_b, lazy_amount_b, lazy_amount_b_speed, lazy_twist_b, lazy_twist_b_speed, lazy_spin_b, lazy_spin_b_speed, lazy_space_b, lazy_space_b_speed, lazy_offset_x_b, lazy_offset_y_b,
    lazy_ring_mode_b, lazy_ring_spin_b, lazy_ring_spin_b_speed, lazy_edge_softness_b
);

		vec2 mixed_uv = mix(uv_a, uv_b, variation_mix);

		// --- ORBIT TRAP SHAPE LOGIC ---
		float dist = 0.0;
		vec2 p_centered = mixed_uv;

		if (escape_shape == 0) { // Circle
			dist = length(p_centered);
		}
		else if (escape_shape == 1) { // Square
			dist = max(abs(p_centered.x), abs(p_centered.y));
		}
		else if (escape_shape == 2) { // Cross
			dist = min(abs(p_centered.x), abs(p_centered.y));
		}
		else if (escape_shape == 3) { // Diamond
			dist = (abs(p_centered.x) + abs(p_centered.y)) * 0.7;
		}

		// Apply Post-Transforms
		mixed_uv *= rotate(post_rotation);
		mixed_uv /= post_scale;
		mixed_uv += post_translate;

		vec2 final_uv = mixed_uv + vec2(0.5);

		// --- TILING LOGIC ---
		if (mirror_tiling) {
			vec2 i = floor(final_uv);
			vec2 f = fract(final_uv);
			if (mod(i.x, 2.0) == 1.0) { f.x = 1.0 - f.x; }
			if (mod(i.y, 2.0) == 1.0) { f.y = 1.0 - f.y; }
			final_uv = f;
		} else if (seamless_tiling) {
			final_uv = fract(final_uv);
		}

		// --- FINAL MIXING ---
		vec4 transformed_color = texture(previous_frame, final_uv);

		if (use_escape_time) {
			float mask = smoothstep(escape_limit, escape_limit + escape_smoothness, dist);
			if (escape_invert) { mask = 1.0 - mask; }
			vec4 feedback_result = mix(start_pattern_color, transformed_color, feedback_amount);
			final_color = mix(feedback_result, start_pattern_color, mask);
		} else {
			final_color = mix(start_pattern_color, transformed_color, feedback_amount);
		}
	}

	COLOR = final_color;
}