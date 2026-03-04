shader_type spatial;

#include "res://fractal_globals.gdshaderinc"

render_mode unshaded, cull_disabled;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 ro = CAMERA_POSITION_WORLD;
	vec2 p_ndc = SCREEN_UV * 2.0 - 1.0;
	p_ndc.x *= VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(p_ndc, -1.0, 0.0)).xyz);
	
	// TEST 1: Show camera is working - visualize ray direction
	ALBEDO = abs(rd); // Should show colorful gradient based on view angle
	
	// TEST 2: Add a simple sphere at origin to verify ray marching works
	vec3 sphere_pos = vec3(0.0, 0.0, 0.0);
	float sphere_radius = 2.0;
	
	float t = 0.0;
	for (int i = 0; i < 100; i++) {
		vec3 p = ro + rd * t;
		float d = length(p - sphere_pos) - sphere_radius;
		
		if (d < 0.001) {
			// Hit the sphere - show it in white
			ALBEDO = vec3(1.0);
			break;
		}
		
		t += d;
		if (t > 100.0) break;
	}
}
