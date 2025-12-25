shader_type canvas_item;

// The 3D Viewport Texture
uniform sampler2D foreground_texture : filter_linear;

// Color Grading Uniforms
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;
uniform float sharpen : hint_range(0.0, 5.0) = 0.0; // NEW: Sharpness slider

// Toggle: Should we apply Brightness/Contrast?
// (We will apply Saturation regardless, to handle B&W mode)
uniform bool grade_background = false;

void fragment() {
	// 1. Get the 2D Background (The Fractal)
	vec4 bg_color = texture(TEXTURE, UV);
	vec3 col = bg_color.rgb;

	// --- 1.5 NEW: APPLY SHARPENING ---
	// We do this first to catch the raw details
	if (sharpen > 0.0) {
		// Get the size of one pixel for this texture
		vec2 px = TEXTURE_PIXEL_SIZE;

		// Sample the 4 neighboring pixels (Up, Down, Left, Right)
		vec3 s_up    = texture(TEXTURE, UV + vec2(0.0, -px.y)).rgb;
		vec3 s_down  = texture(TEXTURE, UV + vec2(0.0, px.y)).rgb;
		vec3 s_left  = texture(TEXTURE, UV + vec2(-px.x, 0.0)).rgb;
		vec3 s_right = texture(TEXTURE, UV + vec2(px.x, 0.0)).rgb;

		// Calculate a simple average (blur)
		vec3 blur = (s_up + s_down + s_left + s_right) * 0.25;

		// Subtract blur from original to find edges, then add them back boosted
		col = col + (col - blur) * sharpen;
	}
	// ---------------------------------

	// 2. ALWAYS Apply Saturation
	// (This ensures B&W works even if you want the "Faded" look)
	float gray = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(gray), col, saturation);

	// 3. OPTIONALLY Apply Brightness/Contrast ("Match BG Color")
	if (grade_background) {
		col = col * brightness;
		col = (col - 0.5) * contrast + 0.5;
	}

	bg_color.rgb = col;

	// 4. Get the 3D Foreground
	vec4 fg_color = texture(foreground_texture, UV);

	// 5. Mix them
	COLOR = mix(bg_color, fg_color, fg_color.a);
}