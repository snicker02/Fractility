shader_type spatial;
render_mode unshaded, cull_front;

uniform sampler2D fractal_texture : filter_linear_mipmap;
// Performance Settings
uniform float step_speed : hint_range(0.1, 1.0) = 0.25; // Lower = Higher Quality
// Lighting
uniform vec3 light_direction = vec3(0.5, 1.0, -0.5);
uniform vec3 light_color_val = vec3(1.0);
uniform float light_energy_val = 1.0;

// Shape Settings
uniform float power : hint_range(-5.0, 5.0) = -2.0; 
uniform int iterations : hint_range(1, 20) = 12;
uniform float surface_detail : hint_range(0.0001, 0.01) = 0.001;

// Mandelbox Specific Settings
uniform float folding_limit : hint_range(0.0, 2.0) = 1.0;
uniform float min_radius : hint_range(0.0, 1.0) = 0.5;
uniform float fixed_radius : hint_range(0.0, 2.0) = 1.0;

// --- CHAOS MODIFIERS ---
uniform vec3 fold_rotate = vec3(0.0);
uniform vec3 twist = vec3(0.0);
uniform vec3 wave_strength = vec3(0.0);
uniform vec3 wave_frequency = vec3(4.0);
uniform vec3 julia_offset = vec3(0.0);

// Visuals
uniform float texture_intensity : hint_range(0.0, 2.0) = 0.5; 
uniform float displacement_strength : hint_range(0.0, 0.5) = 0.0;
uniform float displacement_smoothness : hint_range(0.0, 5.0) = 0.0;
uniform float texture_scale : hint_range(0.1, 5.0) = 1.0;

// Color Grading
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;

varying vec3 camera_origin;
varying mat4 model_view_inv;

vec3 apply_color_grading(vec3 color) {
	color = color * brightness;
	color = (color - 0.5) * contrast + 0.5;
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(gray), color, saturation);
	return color;
}

// Helpers
mat3 get_rot_matrix(vec3 angles) {
	vec3 rad = radians(angles);
	float cx = cos(rad.x), sx = sin(rad.x);
	float cy = cos(rad.y), sy = sin(rad.y);
	float cz = cos(rad.z), sz = sin(rad.z);
	mat3 rot_x = mat3(vec3(1,0,0), vec3(0,cx,-sx), vec3(0,sx,cx));
	mat3 rot_y = mat3(vec3(cy,0,sy), vec3(0,1,0), vec3(-sy,0,cy));
	mat3 rot_z = mat3(vec3(cz,-sz,0), vec3(sz,cz,0), vec3(0,0,1));
	return rot_z * rot_y * rot_x;
}

mat2 rot2D(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

vec3 get_triplanar_color(vec3 p, vec3 n) {
	vec3 p_s = p * texture_scale;
	vec3 w = abs(n);
	w = pow(w, vec3(4.0));
	w /= (w.x + w.y + w.z);
	vec3 col_x = texture(fractal_texture, p_s.yz).rgb;
	vec3 col_y = texture(fractal_texture, p_s.xz).rgb;
	vec3 col_z = texture(fractal_texture, p_s.xy).rgb;
	return col_x * w.x + col_y * w.y + col_z * w.z;
}

float get_displacement_height(vec3 p) {
	vec3 p_s = p * texture_scale;
	float h_xy = texture(fractal_texture, p_s.xy * 0.5 + 0.5).r;
	float h_xz = texture(fractal_texture, p_s.xz * 0.5 + 0.5).r;
	float h_yz = texture(fractal_texture, p_s.yz * 0.5 + 0.5).r;
	return (h_xy + h_xz + h_yz) / 3.0;
}

// --- FRACTAL MATH (Mandelbox) ---
void sphereFold(inout vec3 z, inout float dz) {
	float r2 = dot(z, z);
	if (r2 < min_radius * min_radius) {
		float temp = (fixed_radius * fixed_radius) / (min_radius * min_radius);
		z *= temp;
		dz *= temp;
	} else if (r2 < fixed_radius * fixed_radius) {
		float temp = (fixed_radius * fixed_radius) / r2;
		z *= temp;
		dz *= temp;
	}
}

void boxFold(inout vec3 z, inout float dz) {
	z = clamp(z, -folding_limit, folding_limit) * 2.0 - z;
}

vec2 map(vec3 p) {
	vec3 offset = p;
	float dr = 1.0;
	float scale = power; 
	float trap = 1e10;
	
	mat3 rot = get_rot_matrix(fold_rotate);

	for (int n = 0; n < iterations; n++) {
		boxFold(p, dr);
		sphereFold(p, dr);
		
		// --- APPLY MODIFIERS ---
		p *= rot;
		
		if (length(twist) > 0.001) {
			if (abs(twist.x) > 0.001) p.yz *= rot2D(p.x * twist.x);
			if (abs(twist.y) > 0.001) p.xz *= rot2D(p.y * twist.y);
			if (abs(twist.z) > 0.001) p.xy *= rot2D(p.z * twist.z);
		}
		
		if (length(wave_strength) > 0.001) {
			p += sin(p.yzx * wave_frequency) * wave_strength;
		}

		p = p * scale + offset + julia_offset;
		dr = dr * abs(scale) + 1.0;
		
		trap = min(trap, length(p));
	}

	float r = length(p);
	float d = r / abs(dr);

	if (displacement_strength > 0.001) {
		float h = get_displacement_height(offset);
		d -= h * displacement_strength;
	}

	return vec2(d, trap);
}

vec3 calc_normal(vec3 p, float t) {
	float e_val = 0.005 + (t * 0.001);
	vec2 e = vec2(e_val, 0.0);
	return normalize(vec3(
		map(p + e.xyy).x - map(p - e.xyy).x,
		map(p + e.yxy).x - map(p - e.yxy).x,
		map(p + e.yyx).x - map(p - e.yyx).x
	));
}

void vertex() {
	model_view_inv = inverse(MODELVIEW_MATRIX);
	camera_origin = (model_view_inv * vec4(0, 0, 0, 1)).xyz;
}

void fragment() {
	vec3 ro = camera_origin;
	vec3 obj_pos = (model_view_inv * vec4(VERTEX, 1.0)).xyz;
	vec3 rd = normalize(obj_pos - ro);

	float t = 0.0;
	float d = 0.0;
	bool hit = false;
	int steps = 0;

	// Loop max stays high (500) so Ultra mode works, 
	// but Low mode will hit the distance limit much faster and break early.
	for(int i = 0; i < 500; i++) {
		vec3 p = ro + rd * t;
		d = map(p).x;
		
		// DYNAMIC QUALITY CONTROL
		t += d * step_speed; 
		
		if(d < surface_detail) { hit = true; steps = i; break; }
		if(t > 80.0) break;
	}

	if(hit) {
		vec3 p = ro + rd * t;
		vec3 n = calc_normal(p, t);
		
		vec3 L = normalize(light_direction);
		float diff = max(dot(n, L), 0.0);
		float spec = pow(max(dot(reflect(-L, n), -rd), 0.0), 16.0);
		float rim = pow(1.0 - max(dot(n, -rd), 0.0), 4.0);

		vec3 white_clay = vec3(0.9);
		vec3 frac_col = get_triplanar_color(p, n);
		
		vec3 albedo = mix(white_clay, frac_col, texture_intensity);
		float ao = clamp(1.0 - (float(steps) / 200.0), 0.2, 1.0);

		vec3 ambient = vec3(0.1); 
		
		vec3 final_col = albedo * (light_color_val * diff * light_energy_val + ambient);
		final_col += (light_color_val * spec * 0.5);
		final_col += (vec3(0.5) * rim);

		final_col *= ao;
		
		float fog = smoothstep(20.0, 80.0, t);
		final_col = mix(final_col, vec3(0.0), fog);
		
		ALBEDO = apply_color_grading(final_col);
	} else {
		discard;
	}
}