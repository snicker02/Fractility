shader_type canvas_item;

// This uniform receives the 3D Viewport Texture
uniform sampler2D foreground_texture : source_color;
// The 2D background comes from the TextureRect's built-in 'TEXTURE' uniform

void fragment() {
	vec4 bg_color = texture(TEXTURE, UV); // Sample the background
	vec4 fg_color = texture(foreground_texture, UV); // Sample the foreground

	// Simple alpha blending: Draw foreground over background based on foreground's alpha
	COLOR = mix(bg_color, fg_color, fg_color.a);
}