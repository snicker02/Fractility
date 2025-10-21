shader_type canvas_item;

// Color grading controls
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;

// NEW: Symmetry Controls
uniform bool mirror_x = false;
uniform bool mirror_y = false;
uniform bool kaleidoscope_on = false;
uniform float kaleidoscope_slices = 6.0;

void fragment() {
	vec2 p = UV - 0.5; // Center coordinates

	// Kaleidoscope logic
	if (kaleidoscope_on && kaleidoscope_slices > 0.0) {
		float angle = atan(p.y, p.x);
		float r = length(p);
		float slice_angle = PI / kaleidoscope_slices;
		angle = mod(angle, slice_angle * 2.0);
		angle = abs(angle - slice_angle);
		p.x = r * cos(angle);
		p.y = r * sin(angle);
	}

	// Mirror logic
	if (mirror_x) { p.x = abs(p.x); }
	if (mirror_y) { p.y = abs(p.y); }
	
	vec2 final_uv = p + 0.5; // Convert back to 0-1 range
	vec4 final_color = texture(TEXTURE, final_uv);

	// Apply Color Grading
	final_color.rgb *= brightness;
	final_color.rgb = (final_color.rgb - 0.5) * contrast + 0.5;
	float luma = dot(final_color.rgb, vec3(0.299, 0.587, 0.114));
	final_color.rgb = mix(vec3(luma), final_color.rgb, saturation);

	COLOR = final_color;
}