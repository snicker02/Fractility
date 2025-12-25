shader_type canvas_item;

// Color grading controls
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;
uniform float sharpen : hint_range(0.0, 5.0) = 0.0;
uniform float gamma : hint_range(0.1, 3.0) = 1.0;
uniform float vibrance : hint_range(-1.0, 1.0) = 0.0;
// Symmetry Controls
uniform bool mirror_x = false;
uniform bool mirror_y = false;
uniform bool kaleidoscope_on = false;
uniform float kaleidoscope_slices = 6.0;

void fragment() {
	vec2 p = UV - 0.5; // Center coordinates

	// 1. KALEIDOSCOPE LOGIC
	if (kaleidoscope_on && kaleidoscope_slices > 0.0) {
		float angle = atan(p.y, p.x);
		float r = length(p);
		float slice_angle = PI / kaleidoscope_slices;
		angle = mod(angle, slice_angle * 2.0);
		angle = abs(angle - slice_angle);
		p.x = r * cos(angle);
		p.y = r * sin(angle);
	}

	// 2. MIRROR LOGIC
	if (mirror_x) { p.x = abs(p.x); }
	if (mirror_y) { p.y = abs(p.y); }

	vec2 final_uv = p + 0.5; // Convert back to 0-1 range

	// 3. SAMPLE TEXTURE (With Sharpening)
	vec4 final_color = texture(TEXTURE, final_uv);

	// --- SHARPENING LOGIC ---
	if (sharpen > 0.0) {
		vec2 px = TEXTURE_PIXEL_SIZE; // Size of one pixel

		// Sample 4 neighbors using the same warped 'final_uv'
		vec3 s_up    = texture(TEXTURE, final_uv + vec2(0.0, -px.y)).rgb;
		vec3 s_down  = texture(TEXTURE, final_uv + vec2(0.0, px.y)).rgb;
		vec3 s_left  = texture(TEXTURE, final_uv + vec2(-px.x, 0.0)).rgb;
		vec3 s_right = texture(TEXTURE, final_uv + vec2(px.x, 0.0)).rgb;

		// Blur average
		vec3 blur = (s_up + s_down + s_left + s_right) * 0.25;

		// Apply Unsharp Mask
		final_color.rgb = final_color.rgb + (final_color.rgb - blur) * sharpen;
	}

	// --- DEBUG: RED SCREEN TEST ---
	// Uncomment the 3 lines below to confirm the shader is active!
	// if (sharpen > 0.5) {
	//    final_color.rgb = vec3(1.0, 0.0, 0.0);
	// }
	// ------------------------------

	// 4. COLOR GRADING

	// --- NEW: GAMMA CORRECTION ---
	// We use 1.0 / gamma so that:
	// Higher Value (> 1.0) = Brighter shadows (Lifts detail)
	// Lower Value (< 1.0) = Darker, richer shadows
	final_color.rgb = max(vec3(0.0), final_color.rgb); // Safety: prevent negative colors from breaking pow()
	final_color.rgb = pow(final_color.rgb, vec3(1.0 / gamma));
	// -----------------------------

	final_color.rgb *= brightness;
	final_color.rgb = (final_color.rgb - 0.5) * contrast + 0.5;
	float luma = dot(final_color.rgb, vec3(0.299, 0.587, 0.114));

    // 2. Calculate current saturation of the pixel
    float max_color = max(final_color.r, max(final_color.g, final_color.b));
    float min_color = min(final_color.r, min(final_color.g, final_color.b));
    float current_sat = max_color - min_color;

    // 3. Apply Vibrance
    // The formula (1.0 - current_sat) ensures we boost DULL colors more than bright ones.
    if (vibrance != 0.0) {
        final_color.rgb = mix(vec3(luma), final_color.rgb, 1.0 + (vibrance * (1.0 - current_sat)));
    }
    // ----------------------

    // Apply Standard Saturation (Global boost)
    final_color.rgb = mix(vec3(luma), final_color.rgb, saturation);

    COLOR = final_color;
}