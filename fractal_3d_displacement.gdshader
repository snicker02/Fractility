shader_type spatial;

uniform sampler2D fractal_texture : filter_linear;

// --- Visuals (Added these back so sliders work) ---
//uniform float texture_intensity : hint_range(0.0, 1.0) = 0.5;
//uniform float texture_scale : hint_range(0.1, 5.0) = 1.0;

// Settings
uniform float displacement_strength : hint_range(-2.0, 2.0) = 0.5;
uniform float displacement_offset : hint_range(-1.0, 1.0) = -0.5;
uniform float displacement_smoothness : hint_range(0.0, 5.0) = 0.0;

// Toggles
uniform bool use_dynamic_material = false;
uniform bool use_terrain_mode = false;
uniform bool limit_displacement_to_top = false; // <-- This was missing logic!

// Materials
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float emission_energy : hint_range(0.0, 10.0) = 0.0;

// Grading
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;

varying vec3 v_final_color;

vec3 apply_color_grading(vec3 color) {
	color = color * brightness;
	color = (color - 0.5) * contrast + 0.5;
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(gray), color, saturation);
	return color;
}

// Manual Blur Helper
vec3 get_blurred_color(sampler2D tex, vec2 uv, float smoothness) {
	vec2 tex_size = vec2(textureSize(tex, 0));
	vec2 one_pixel = 1.0 / tex_size;

	// Boosted spread for better smoothing
	float spread = max(0.0, smoothness * 2.0);

	vec3 c  = texture(tex, uv).rgb;
	vec3 n  = texture(tex, uv + vec2(0.0, -one_pixel.y) * spread).rgb;
	vec3 s  = texture(tex, uv + vec2(0.0, one_pixel.y) * spread).rgb;
	vec3 e  = texture(tex, uv + vec2(one_pixel.x, 0.0) * spread).rgb;
	vec3 w  = texture(tex, uv + vec2(-one_pixel.x, 0.0) * spread).rgb;
	vec3 ne = texture(tex, uv + vec2(one_pixel.x, -one_pixel.y) * spread).rgb;
	vec3 nw = texture(tex, uv + vec2(-one_pixel.x, -one_pixel.y) * spread).rgb;
	vec3 se = texture(tex, uv + vec2(one_pixel.x, one_pixel.y) * spread).rgb;
	vec3 sw = texture(tex, uv + vec2(-one_pixel.x, one_pixel.y) * spread).rgb;

	return (c + n + s + e + w + ne + nw + se + sw) / 9.0;
}

vec3 get_triplanar_color(vec3 pos, vec3 normal) {
	vec3 blending = abs(normal);
	blending = normalize(max(blending, 0.00001));
	float b = (blending.x + blending.y + blending.z);
	blending /= b;

	vec2 uvx = (pos.zy / 2.0) + 0.5;
	vec2 uvy = (pos.xz / 2.0) + 0.5;
	vec2 uvz = (pos.xy / 2.0) + 0.5;

	vec3 xaxis = get_blurred_color(fractal_texture, uvx, displacement_smoothness);
	vec3 yaxis = get_blurred_color(fractal_texture, uvy, displacement_smoothness);
	vec3 zaxis = get_blurred_color(fractal_texture, uvz, displacement_smoothness);

	return xaxis * blending.x + yaxis * blending.y + zaxis * blending.z;
}

void vertex() {
	vec3 raw_color;
	float height;

	if (use_terrain_mode) {
		// --- TERRAIN MODE (For Quad) ---
		vec2 planar_uv = (VERTEX.xz / 2.0) + 0.5;
		raw_color = get_blurred_color(fractal_texture, planar_uv, displacement_smoothness);
		v_final_color = apply_color_grading(raw_color);
		height = v_final_color.r;

		float final_displacement = (height + displacement_offset) * displacement_strength;

		// LOGIC: If limiting to top, only move vertices with Y > 0.
		// If NOT limiting, the bottom vertices (Y < 0) will also move.
		float mask = 1.0;
		if (limit_displacement_to_top) {
			mask = step(0.0, VERTEX.y);
		}

		VERTEX.y += final_displacement * mask;

	} else {
		// --- TRIPLANAR MODE (For Cube/Prism) ---
		raw_color = get_triplanar_color(VERTEX, NORMAL);
		v_final_color = apply_color_grading(raw_color);
		height = v_final_color.r;

		float final_displacement = (height + displacement_offset) * displacement_strength;

		// LOGIC: If limiting to top, force displacement to 0 if Normal is not UP.
		if (limit_displacement_to_top && NORMAL.y < 0.1) {
			final_displacement = 0.0;
		}

		VERTEX += NORMAL * final_displacement;
	}
}

void fragment() {
	ALBEDO = v_final_color;
	EMISSION = v_final_color * emission_energy;

	if (use_dynamic_material) {
		float val = v_final_color.r;
		ROUGHNESS = mix(0.1, 1.0, val);
		METALLIC = mix(1.0, 0.0, val);
	} else {
		ROUGHNESS = roughness;
		METALLIC = metallic;
	}
}