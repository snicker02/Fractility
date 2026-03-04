shader_type spatial;

render_mode unshaded;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	// ULTRA SIMPLE TEST - should show a red-green gradient
	ALBEDO = vec3(SCREEN_UV.x, SCREEN_UV.y, 0.0);
}
