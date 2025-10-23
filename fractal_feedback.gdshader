shader_type canvas_item;

// --- Uniforms ---
uniform sampler2D previous_frame : filter_linear, repeat_enable;
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

// Start Pattern Uniforms
uniform float circle_count = 4.0;
uniform float circle_radius = 0.2;
uniform float circle_softness = 0.05;
uniform vec4 grad_col_tl = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 grad_col_tr = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 grad_col_bl = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec4 grad_col_br = vec4(1.0, 0.0, 0.0, 1.0);

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
uniform float wave_frequency_a = 5.0;
uniform float wave_amplitude_a = 0.1;
uniform float wave_speed_a = 1.0;
uniform int wave_type_a = 0;

// Wave B Variation Uniforms
uniform float wave_frequency_b = 5.0;
uniform float wave_amplitude_b = 0.1;
uniform float wave_speed_b = 1.0;
uniform int wave_type_b = 0;

// Julian2 A Uniforms
uniform float julian_power_a = 2.0;
uniform float julian_dist_a = 1.0;
uniform vec2 julian_mat_a_col1;
uniform vec2 julian_mat_a_col2;
uniform vec2 julian_trans_a = vec2(0.0, 0.0);

// Julian2 B Uniforms
uniform float julian_power_b = -3.0;
uniform float julian_dist_b = 1.0;
uniform vec2 julian_mat_b_col1;
uniform vec2 julian_mat_b_col2;
uniform vec2 julian_trans_b = vec2(0.0, 0.0);

// Fisheye/Polar Uniforms
uniform float fisheye_strength_a = 2.0;
uniform float polar_offset_a = 1.0;
uniform float fisheye_strength_b = 2.0;
uniform float polar_offset_b = 1.0;

// Symmetry Uniforms
uniform bool var_a_mirror_x;
uniform bool var_a_mirror_y;
uniform float var_a_kaleidoscope_slices;

uniform bool var_b_mirror_x;
uniform bool var_b_mirror_y;
uniform float var_b_kaleidoscope_slices;

// For efficiency, we pack Re/Im parts into vec2s
uniform vec2 mobius_a_a; // x=re_a, y=im_a
uniform vec2 mobius_b_a; // x=re_b, y=im_b
uniform vec2 mobius_c_a; // x=re_c, y=im_c
uniform vec2 mobius_d_a; // x=re_d, y=im_d

uniform vec2 mobius_a_b;
uniform vec2 mobius_b_b;
uniform vec2 mobius_c_b;
uniform vec2 mobius_d_b;

// --- Add uniforms for XHeart A and B ---
uniform float cellular_weave_grid_size_a;
uniform float cellular_weave_threshold_a;
uniform float cellular_weave_iterations_a;
uniform float cellular_weave_grid_size_b;
uniform float cellular_weave_threshold_b;
uniform float cellular_weave_iterations_b;

// --- Add uniforms for Heart A and B ---
uniform float heart_scale_a;
uniform float heart_rotation_a;
uniform float heart_strength_a;
uniform float heart_scale_b;
uniform float heart_rotation_b;
uniform float heart_strength_b;

// --- Add uniforms for Blur ---
uniform float blur_amount_a;
uniform float blur_amount_b;


uniform float apollonian_scale_a = 1.5;
uniform vec2 ap_c1_a = vec2(0.0, 0.5);   // <-- ADD Center 1 for Var A
uniform vec2 ap_c2_a = vec2(-0.433, -0.25); // <-- ADD Center 2 for Var A
uniform vec2 ap_c3_a = vec2(0.433, -0.25);  // <-- ADD Center 3 for Var A
uniform float apollonian_scale_b = 1.5;
uniform vec2 ap_c1_b = vec2(0.0, 0.5);   // <-- ADD Center 1 for Var B
uniform vec2 ap_c2_b = vec2(-0.433, -0.25); // <-- ADD Center 2 for Var B
uniform vec2 ap_c3_b = vec2(0.433, -0.25);  // <-- ADD Center 3 for Var B
uniform int custom_tl_a; uniform int custom_tr_a; uniform int custom_bl_a; uniform int custom_br_a;
uniform int custom_tl_b; uniform int custom_tr_b; uniform int custom_bl_b; uniform int custom_br_b;

// --- Helper Functions ---
mat2 rotate(float angle) {
	return mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}
// Simple pseudo-random number function
float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
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
vec2 apply_variation(vec2 uv, int mode,
                     float w_freq, float w_amp, float w_speed, int w_type,      // Wave
                     float j_power, float j_dist, mat2 j_mat, vec2 j_trans,      // Julian2
                     float f_strength, float p_offset,                         // Fisheye/Polar
                     bool m_x, bool m_y, float k_slices,                        // Mirror/Kaleidoscope
                     vec2 m_a, vec2 m_b, vec2 m_c, vec2 m_d,                 // Mobius
                     float cw_grid, float cw_thresh, float cw_iter,            // Cellular Weave
                     float bl_amount,                                          // Blur
                     float h_scale, float h_rotation, float h_strength,         // Heart
					float ap_scale, vec2 ap_c1, vec2 ap_c2, vec2 ap_c3,
					int c_tl, int c_tr, int c_bl, int c_br
                     ) {
	if (mode == 0) { // Sinusoidal
		return sin(uv * 3.14159);
	}
	else if (mode == 1) { // Spherical
		float r2 = dot(uv, uv);
		if (r2 > 0.0) { return uv / r2; }
	} else if (mode == 2) { // Swirl
		float r = length(uv);
		float angle = atan(uv.y, uv.x);
		float s = sin(r * 5.0 - angle * 2.0);
		float c = cos(r * 5.0 - angle * 2.0);
		return vec2(s, c) * r;
	} else if (mode == 3) { // Wave
		float offset = 0.0;
		if (w_type == 0) { offset = sin(uv.y * w_freq + time * w_speed) * w_amp; return uv + vec2(offset, 0.0); } 
		else if (w_type == 1) { float r = length(uv); offset = sin(r * w_freq - time * w_speed) * w_amp; return uv * (1.0 + offset); } 
		else if (w_type == 2) { offset = sign(sin(uv.y * w_freq + time * w_speed)) * w_amp; return uv + vec2(offset, 0.0); }
	} else if (mode == 4) { // Julian2
		if (j_power == 0.0) { return uv; }
		float _cN = j_dist / j_power * 0.5;
		vec2 p = uv * j_mat + j_trans;
		float angle = atan(p.y, p.x) / j_power;
		float r = pow(dot(p, p), _cN);
		return vec2(r * cos(angle), r * sin(angle));
	} else if (mode == 5) { // Polar
		float r = length(uv);
		float theta = atan(uv.y, uv.x);
		return vec2(theta / PI, r - p_offset);
	} else if (mode == 6) { // Fisheye
		float r = length(uv);
		return (f_strength / (r + 1.0)) * uv;
	} else if (mode == 7) { // Mirror
		vec2 p = uv;
		if (m_x) { p.x = abs(p.x); } // Use passed-in parameter
		if (m_y) { p.y = abs(p.y); } // Use passed-in parameter
		return p;
	} else if (mode == 8) { // Kaleidoscope
		if (k_slices <= 0.0) { return uv; }
		vec2 p = uv;
		float angle = atan(p.y, p.x);
		float r = length(p);
		float slice_angle = PI / k_slices; // Use passed-in parameter
		angle = mod(angle, slice_angle * 2.0);
		angle = abs(angle - slice_angle);
		p.x = r * cos(angle);
		p.y = r * sin(angle);
		return p;
	}    else if (mode == 9) { // Mobius
        // This calculates f(z) = (a*z + b) / (c*z + d) using complex numbers
        // z = (uv.x, uv.y)
        // a,b,c,d are the uniform vec2s (m_a, m_b, m_c, m_d)

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
	}else if (mode == 10) { // Cellular Weave
        vec2 p = uv;
        for (int i = 0; i < int(cw_iter); i++) {
            vec2 grid_p = floor(p * cw_grid); // Find which grid cell we're in
            
            float neighbor_sum = 0.0;
            // Check the 8 neighbors
            neighbor_sum += get_cell_value(grid_p, vec2(-1.0, -1.0)) > 0.5 ? 1.0 : 0.0;
            neighbor_sum += get_cell_value(grid_p, vec2( 0.0, -1.0)) > 0.5 ? 1.0 : 0.0;
            neighbor_sum += get_cell_value(grid_p, vec2( 1.0, -1.0)) > 0.5 ? 1.0 : 0.0;
            neighbor_sum += get_cell_value(grid_p, vec2(-1.0,  0.0)) > 0.5 ? 1.0 : 0.0;
            neighbor_sum += get_cell_value(grid_p, vec2( 1.0,  0.0)) > 0.5 ? 1.0 : 0.0;
            neighbor_sum += get_cell_value(grid_p, vec2(-1.0,  1.0)) > 0.5 ? 1.0 : 0.0;
            neighbor_sum += get_cell_value(grid_p, vec2( 0.0,  1.0)) > 0.5 ? 1.0 : 0.0;
            neighbor_sum += get_cell_value(grid_p, vec2( 1.0,  1.0)) > 0.5 ? 1.0 : 0.0;
            
            // If the number of "on" neighbors is over the threshold...
            if (neighbor_sum > cw_thresh) {
                // ...twist the coordinate
                float angle = neighbor_sum * 0.1;
                p = mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle))) * p;
            } else {
                // ...otherwise, pull it towards the center of its cell
                vec2 cell_center = (grid_p + 0.5) / cw_grid;
                p = mix(p, cell_center, 0.1);
            }
        }
        return p;
	}else if (mode == 11) { // Blur
        float angle = rand(uv) * 2.0 * PI;
        float radius = rand(uv + vec2(5.2, 3.1)) * bl_amount;
        return uv + vec2(cos(angle), sin(angle)) * radius;
    }else if (mode == 12) { // Heart
        vec2 p = uv;

        // Apply scale and rotation to the coordinate system for the heart
        p /= h_scale;
		p.y *= -1.0;
        p = vec2(cos(radians(h_rotation)) * p.x - sin(radians(h_rotation)) * p.y,
                 sin(radians(h_rotation)) * p.x + cos(radians(h_rotation)) * p.y);
        
        // --- Heart Shape Formula ---
        // This is a common mathematical heart shape.
        float x = p.x;
        float y = p.y;
        
        // Calculate the value of the implicit heart function
        // (x^2 + y^2 - 1)^3 - x^2 * y^3 = 0  (approximately)
        // We'll use a slightly simplified or modified version for displacement
        float heart_val = pow(x*x + y*y - 1.0, 3.0) - x*x * pow(y, 3.0);
        
        // Normalize heart_val to get a displacement direction
        // When heart_val is negative, we're inside the heart.
        // We want to push coordinates *away* from the center of the heart shape.
        
        // The strength determines how much the heart shape influences the coordinate
        vec2 displacement = normalize(vec2(
            3.0 * pow(x*x + y*y - 1.0, 2.0) * (2.0*x) - 2.0*x*pow(y, 3.0),
            3.0 * pow(x*x + y*y - 1.0, 2.0) * (2.0*y) - x*x * 3.0*pow(y, 2.0)
        ));
        
        // Invert the displacement if we're "inside" the heart's implicit boundary
        if (heart_val < 0.0) {
            displacement *= -1.0;
        }
        
        // Apply displacement, scaled by strength
        return uv + displacement * h_strength * 0.1; // *0.1 to keep it subtle
    }
	else if (mode == 13) { // Apollonian Gasket (Iterative Approximation)
		vec2 p = uv; // Use the incoming coordinate

		// Define 3 circle centers (forming a triangle around the origin)
		// Adjust these positions for different packing looks
		vec2 c1 = vec2(0.0, 0.5);  // Top
		vec2 c2 = vec2(-0.433, -0.25); // Bottom-left
		vec2 c3 = vec2(0.433, -0.25);  // Bottom-right

		// Scaling factor (from uniform) - should probably be > 1.0 for this approach
		float scale = ap_scale; // Use the passed-in scale parameter

		// Find the closest center
		float d1 = distance(p, ap_c1);
		float d2 = distance(p, ap_c2);
		float d3 = distance(p, ap_c3);

		vec2 closest_center;
		if (d1 < d2 && d1 < d3) {
			closest_center = ap_c1;
		} else if (d2 < d3) {
			closest_center = ap_c2;
		} else {
			closest_center = ap_c3;
		}

		// Map the point: Scale it towards the closest center
		// Formula: center + (point - center) * scale
		// We invert the scale here because we are transforming the *lookup* coordinate
		// A scale > 1 shrinks the pattern when used in feedback lookup.
		// A scale < 1 expands the pattern.
		if (abs(ap_scale) < 1e-6) { return p; }
		p = closest_center + (p - closest_center) / ap_scale;

		return p;
	}
	// --- END APOLLONIAN GASKET ---
	else if (mode == 14) {
		return cos(uv * PI);
	}
	// --- ADD TANGENT (Mode 15) ---
	else if (mode == 15) { // Tangent
		// tan() can produce very large values quickly, multiply by a smaller factor
		return tan(uv * (PI / 2.0 - 0.01)); // Avoid exact PI/2 where tan is infinite
	}
	// --- ADD ARCTANGENT (Mode 16) ---
	else if (mode == 16) { // ArcTangent
		// atan(y, x) gives angle, atan(vec2) applies element-wise
		return atan(uv); // Output range is approx -PI/2 to PI/2
	}
	// --- ADD HYPERBOLIC SINE (Mode 17) ---
	else if (mode == 17) { // Hyperbolic Sine
		return sinh(uv); // Grows rapidly away from origin
	}
	// --- ADD HYPERBOLIC COSINE (Mode 18) ---
	else if (mode == 18) { // Hyperbolic Cosine
		return cosh(uv); // Grows rapidly away from origin, always positive-like
	}
	// --- ADD L-TROMINO (Mode 19) ---
	else if (mode == 19) { // L-Tromino Rep-Tile
		vec2 p = uv * 2.0; // Scale up coordinates by 2 initially

		// Determine which of the 4 smaller L-tromino quadrants the point is in
		// and transform it back to the base coordinate space [(-1,-1) to (1,1)]

		if (p.x >= 0.0 && p.y >= 0.0) { // Top-right quadrant -> rotate -90 deg, translate
			p = vec2(p.y, -p.x) + vec2(-1.0, 1.0);
		} else if (p.x < 0.0 && p.y >= 0.0) { // Top-left quadrant -> translate only
			p = p + vec2(1.0, -1.0);
		} else if (p.x < 0.0 && p.y < 0.0) { // Bottom-left quadrant -> translate only
			p = p + vec2(1.0, 1.0);
		} else { // Bottom-right quadrant -> rotate +90 deg, translate
			p = vec2(-p.y, p.x) + vec2(-1.0, -1.0);
		}
		// Return the transformed coordinate (divided by 2 because the base shape is usually [-1,1])
		return p / 2.0;
	}
	// --- END L-TROMINO ---
	
	// --- ADD CUSTOM 2x2 (Mode 20) ---
	else if (mode == 20) {
		vec2 p = uv * 2.0; // Map centered uv from [-0.5, 0.5] to [-1, 1]

		if (p.x > 0.0 && p.y > 0.0) { // Top-Right (TR)
			// Map p from [0,1] to [-1,1], apply transform, map back
			p = (apply_quad_transform(p - vec2(0.5, 0.5), c_tr) * 0.5) + vec2(0.5, 0.5);
		} else if (p.x <= 0.0 && p.y > 0.0) { // Top-Left (TL)
			p = (apply_quad_transform(p - vec2(-0.5, 0.5), c_tl) * 0.5) + vec2(-0.5, 0.5);
		} else if (p.x <= 0.0 && p.y <= 0.0) { // Bottom-Left (BL)
			p = (apply_quad_transform(p - vec2(-0.5, -0.5), c_bl) * 0.5) + vec2(-0.5, -0.5);
		} else { // Bottom-Right (BR)
			p = (apply_quad_transform(p - vec2(0.5, -0.5), c_br) * 0.5) + vec2(0.5, -0.5);
		}
		
		return p / 2.0; // Scale back down
	}
	// --- END CUSTOM 2x2 ---
	// --- ADD SPHINX (Mode 21) ---
	else if (mode == 21) { // Sphinx
		// The Sphinx uses 4 smaller copies, rotated and translated.
		// We divide the plane into 4 triangular regions using two diagonal lines.
		vec2 p = uv; // Input is in [-0.5, 0.5]
		p *= 2.0; // Scale up to [-1, 1] for easier math

		// Define a 90-degree rotation matrix
		mat2 R90 = mat2(vec2(0.0, 1.0), vec2(-1.0, 0.0));

		// Check which triangular region the point is in
		if (p.x + p.y > 0.0) {
			if (p.x - p.y > 0.0) {
				// Top-Right triangle
				p = R90 * p + vec2(0.0, 1.0);
			} else {
				// Top-Left triangle
				p = p + vec2(-1.0, 0.0);
			}
		} else {
			if (p.x - p.y > 0.0) {
				// Bottom-Right triangle
				p = p + vec2(1.0, 0.0);
			} else {
				// Bottom-Left triangle
				p = R90 * p + vec2(0.0, -1.0);
			}
		}
		// Scale the result back down to [-0.5, 0.5]
		return p / 2.0;
	}
	// --- END SPHINX ---
	
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
void fragment() {
	// Reconstruct matrices from their column vectors first
	mat2 julian_mat_a = mat2(julian_mat_a_col1, julian_mat_a_col2);
	mat2 julian_mat_b = mat2(julian_mat_b_col1, julian_mat_b_col2);

	vec4 final_color;

	// This block runs only on the first frame (or after a reset) to create the initial background
	if (time < 0.1) {
		if (start_pattern_mode == 0) { // Gradient + Grid
			vec4 top_mix = mix(grad_col_tl, grad_col_tr, UV.x);
			vec4 bottom_mix = mix(grad_col_bl, grad_col_br, UV.x);
			final_color = mix(top_mix, bottom_mix, UV.y);
			if (show_grid) {
				vec2 pixel_coords = UV / TEXTURE_PIXEL_SIZE;
				float line_width = 1.5;
				if (mod(pixel_coords.x, 50.0) < line_width || mod(pixel_coords.y, 50.0) < line_width) {
					final_color *= 1.5;
				}
			}
		} 
		else if (start_pattern_mode == 1) { // Circles
			vec4 top_mix = mix(grad_col_tl, grad_col_tr, UV.x);
			vec4 bottom_mix = mix(grad_col_bl, grad_col_br, UV.x);
			vec4 gradient_color = mix(top_mix, bottom_mix, UV.y);
			final_color = gradient_color;
			if (show_circles) {
				vec2 grid_uv = fract(UV * circle_count);
				float dist = distance(grid_uv, vec2(0.5));
				float circle = 1.0 - smoothstep(circle_radius, circle_radius + circle_softness, dist);
				final_color = vec4(vec3(circle), 1.0) * gradient_color;
			}
		}
		else if (start_pattern_mode == 2) { // Image Input
			// Check if a valid texture has been loaded before trying to sample it
			if (textureSize(background_texture, 0).x > 1) {
				final_color = texture(background_texture, UV);
			} else {
				final_color = vec4(0.0, 0.0, 0.0, 1.0); // Default to black if no texture is present
			}
		}
		else if (start_pattern_mode == 3) { // Perlin Noise
			// Multiply UV by a number to control the "zoom" of the noise
			float n = perlin_noise(UV * 10.0); 
			// Remap the noise value from [-1, 1] to the visible [0, 1] range
			n = (n + 1.0) * 0.5;
			final_color = vec4(vec3(n), 1.0);
		}
	} 
	// This block runs on every subsequent frame, applying the feedback loop
	else {
		vec2 transformed_uv = UV - vec2(0.5); // Center coordinates for rotation/scaling

		// Apply Pre-Transforms
		transformed_uv *= rotate(pre_rotation);
		transformed_uv /= pre_scale; // Use division for intuitive zoom
		transformed_uv += pre_translate;

		// Apply Variations
		vec2 uv_a = apply_variation(transformed_uv + translate_a, variation_mode_a, wave_frequency_a, wave_amplitude_a, wave_speed_a, wave_type_a, julian_power_a, julian_dist_a, julian_mat_a, julian_trans_a, fisheye_strength_a, polar_offset_a, var_a_mirror_x, var_a_mirror_y, var_a_kaleidoscope_slices, mobius_a_a, mobius_b_a, mobius_c_a, mobius_d_a, cellular_weave_grid_size_a, cellular_weave_threshold_a, cellular_weave_iterations_a, blur_amount_a, heart_scale_a, heart_rotation_a, heart_strength_a, apollonian_scale_a, ap_c1_a, ap_c2_a, ap_c3_a,custom_tl_a, custom_tr_a, custom_bl_a, custom_br_a);
		vec2 uv_b = apply_variation(transformed_uv + translate_b, variation_mode_b, wave_frequency_b, wave_amplitude_b, wave_speed_b, wave_type_b, julian_power_b, julian_dist_b, julian_mat_b, julian_trans_b, fisheye_strength_b, polar_offset_b, var_b_mirror_x, var_b_mirror_y, var_b_kaleidoscope_slices, mobius_a_b, mobius_b_b, mobius_c_b, mobius_d_b, cellular_weave_grid_size_b, cellular_weave_threshold_b, cellular_weave_iterations_b, blur_amount_b, heart_scale_b, heart_rotation_b, heart_strength_b, apollonian_scale_b, ap_c1_b, ap_c2_b, ap_c3_b,custom_tl_b, custom_tr_b, custom_bl_b, custom_br_b);
		
		vec2 mixed_uv = mix(uv_a, uv_b, variation_mix);
		vec2 p_final_centered = mixed_uv;

		// Apply Post-Transforms
		mixed_uv *= rotate(post_rotation);
		mixed_uv /= post_scale; // Use division for intuitive zoom
		mixed_uv += post_translate;

		vec2 final_uv = mixed_uv + vec2(0.5); // De-center coordinates

		if (seamless_tiling) {
			if (mirror_tiling) {
			// Get the integer part to know which tile we're on
			vec2 i = floor(final_uv);
			// Get the fractional part for the position within the tile
			vec2 f = fract(final_uv);
			
			// If the tile's x-index is odd, flip the x-coordinate
			if (mod(i.x, 2.0) == 1.0) {
				f.x = 1.0 - f.x;
			}
			// If the tile's y-index is odd, flip the y-coordinate
			if (mod(i.y, 2.0) == 1.0) {
				f.y = 1.0 - f.y;
			}
			final_uv = f;
		} else {
			// The original standard tiling
			final_uv = fract(final_uv);
		}
		}

		// Mix the transformed frame with the previous frame
		vec4 transformed_color = texture(previous_frame, final_uv);
		vec4 original_color = texture(previous_frame, UV);
		final_color = mix(transformed_color, original_color, feedback_amount);
	}

	COLOR = final_color;
}
