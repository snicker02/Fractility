shader_type spatial;

#include "res://fractal_globals.gdshaderinc"

render_mode unshaded, cull_disabled;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

group_uniforms Mandelbox_Main;
uniform float Scale : hint_range(-5.0, 5.0) = 2.5;
uniform float BoxFoldLimit : hint_range(0.1, 5.0) = 1.0;
uniform int Iterations : hint_range(1, 50) = 17;
uniform float RotationAngle : hint_range(0.0, 6.28) = 0.0;

group_uniforms Inversion_Settings;
uniform int InvType : hint_range(0, 8) = 0;
uniform float InvScale : hint_range(0.01, 5.0) = 2.08;
uniform float InvParamA : hint_range(-6.0, 6.0) = 0.94;
uniform float InvParamB : hint_range(3.0, 20.0) = 4.0;
uniform vec4 InvCenter = vec4(0.0);

group_uniforms Rendering;
uniform float Detail : hint_range(-5.0, -1.0) = -1.5;  // VERY forgiving
uniform int MaxSteps : hint_range(32, 512) = 512;      // LOTS of steps

group_uniforms Fractal_Modes;
uniform bool JuliaMode = false;
uniform vec4 JuliaSeed = vec4(-0.5, 0.2, 0.0, 0.0);

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

vec4 rotate4D(vec4 p, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec4(p.x * c - p.w * s, p.y, p.z, p.x * s + p.w * c);
}

void shapeFold(inout vec4 p, inout float der) {
	float min_r2 = InvParamA * InvParamA;
	float fixed_r2 = InvScale * InvScale;
	float r2 = dot(p - InvCenter, p - InvCenter);
	
	float s2 = fixed_r2;
	if (InvType == 8) {
		if (r2 < min_r2) s2 = fixed_r2 / min_r2;
		else if (r2 < fixed_r2) s2 = fixed_r2 / r2;
		else s2 = 1.0;
	}
	
	if (r2 < s2) {
		float ratio = s2 / r2;
		p *= ratio;
		der *= ratio;
	}
}

void boxFold(inout vec4 p) {
	p = clamp(p, -BoxFoldLimit, BoxFoldLimit) * 2.0 - p;
}

float map(vec3 p3d, out vec4 orbit) {
	float dr = 1.0;
	orbit = vec4(1e20);
	
	vec4 p4d = vec4(p3d, OffsetW);
	vec4 offset = JuliaMode ? JuliaSeed : p4d;
	
	for (int i = 0; i < Iterations; i++) {
		p4d = rotate4D(p4d, RotationAngle);
		apply_symmetry(p4d.xyz);
		boxFold(p4d);
		shapeFold(p4d, dr);
		p4d = (p4d * Scale) + offset;
		dr = (dr * abs(Scale)) + 1.0;
		orbit = min(orbit, abs(p4d));
		if (dot(p4d, p4d) > 1000.0) break;
	}
	
	float box_size = abs(Scale - 1.0);
	vec4 q = abs(p4d) - box_size;
	return (length(max(q, 0.0)) + min(max(q.x, max(q.y, max(q.z, q.w))), 0.0)) / abs(dr);
}

vec3 get_normal(vec3 p) {
	float e = 0.001;
	vec4 dummy;
	return normalize(vec3(
		map(p + vec3(e, 0, 0), dummy) - map(p - vec3(e, 0, 0), dummy),
		map(p + vec3(0, e, 0), dummy) - map(p - vec3(0, e, 0), dummy),
		map(p + vec3(0, 0, e), dummy) - map(p - vec3(0, 0, e), dummy)
	));
}

vec3 palette(float t) {
	vec3 a, b, c, d;
	if (PaletteType == 0) { a = vec3(0.5); b = vec3(0.5); c = vec3(1.0); d = vec3(0.0, 0.33, 0.67); }
	else if (PaletteType == 1) { a = vec3(0.5); b = vec3(0.5); c = vec3(0.5); d = vec3(0.5, 0.2, 0.25); }
	else if (PaletteType == 2) { a = vec3(0.5); b = vec3(0.5); c = vec3(0.8, 0.5, 0.4); d = vec3(0.2, 0.4, 0.2); }
	else { return vec3(0.5 + 0.5 * cos(6.28 * t)); }
	return a + b * cos(6.28318 * (c * t + d + ColorOffset));
}

void fragment() {
	vec3 ro = CAMERA_POSITION_WORLD;
	vec2 p_ndc = SCREEN_UV * 2.0 - 1.0;
	p_ndc.x *= VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(p_ndc, -1.0, 0.0)).xyz);
	
	float t = 0.05;
	bool hit = false;
	vec4 orbit;
	int steps_taken = 0;
	
	for (int i = 0; i < MaxSteps; i++) {
		float d = map(ro + rd * t, orbit);
		steps_taken = i;
		
		// VERY forgiving hit detection
		if (d < pow(10.0, Detail)) {
			hit = true;
			break;
		}
		
		t += d;
		if (t > 100.0) break;  // Increased max distance
	}

	if (hit) {
		vec3 p = ro + rd * t;
		vec3 n = get_normal(p);
		
		// Bright colors for visibility
		vec3 col = palette(length(orbit.xyz) * 0.2);
		
		// Strong lighting
		vec3 light_dir = normalize(vec3(1.0, 1.0, -1.0));
		float diff = max(dot(n, light_dir), 0.0) * 0.8 + 0.2;
		col *= diff;
		
		ALBEDO = col;
	} else {
		// Show step count as debug - helps see if ray marching is working
		// If you see subtle color variations, ray marching works but isn't hitting
		float debug = float(steps_taken) / float(MaxSteps);
		ALBEDO = vec3(debug * 0.1); // Very faint gradient if no hit
	}
}
