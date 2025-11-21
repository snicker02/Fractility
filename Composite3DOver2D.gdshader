shader_type canvas_item;

// The 3D Viewport Texture
uniform sampler2D foreground_texture : filter_linear;

// Color Grading Uniforms
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;

// Toggle: Should we apply Brightness/Contrast?
// (We will apply Saturation regardless, to handle B&W mode)
uniform bool grade_background = false;

void fragment() {
	// 1. Get the 2D Background
	vec4 bg_color = texture(TEXTURE, UV);
	vec3 col = bg_color.rgb;

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