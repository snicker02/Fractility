shader_type spatial;
render_mode cull_back;

uniform sampler2D fractal_texture : filter_linear_mipmap;
uniform float height_scale : hint_range(0.0, 10.0) = 2.0;
uniform float cube_scale : hint_range(0.1, 1.0) = 0.9;
uniform vec2 grid_size = vec2(100.0, 100.0);

// Material Properties
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float emission_energy : hint_range(0.0, 10.0) = 0.0;

// Color Grading
uniform float brightness : hint_range(0.0, 3.0) = 1.0;
uniform float contrast : hint_range(0.0, 3.0) = 1.0;
uniform float saturation : hint_range(0.0, 3.0) = 1.0;

// --- NEW: TWIST AND WAVE UNIFORMS ---
uniform vec3 twist = vec3(0.0);           // Bend the grid
uniform vec3 wave_strength = vec3(0.0);   // Amplitude
uniform vec3 wave_frequency = vec3(0.0);  // Speed/Density of wave
uniform float wave_speed : hint_range(0.0, 10.0) = 1.0;
uniform float time = 0.0;                 // For animating waves

// Helper: 2D Rotation Matrix
mat2 rot2D(float a) {
	float c = cos(a), s = sin(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

vec3 apply_grading(vec3 color) {
	color = color * brightness;
	color = (color - 0.5) * contrast + 0.5;
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(gray), color, saturation);
	return color;
}

void vertex() {
	vec2 uv = INSTANCE_CUSTOM.xy;
	
	// 1. Get Base Height & Color
	float val = textureLod(fractal_texture, uv, 0.0).r;
	float h = max(0.01, val * height_scale);
	
	// 2. Apply Standard Scaling
	VERTEX.y *= h;
	VERTEX.x *= cube_scale;
	VERTEX.z *= cube_scale;
	
	COLOR = textureLod(fractal_texture, uv, 0.0);
	
	// --- 3. APPLY TWIST & WAVE ---
	// We need to move the *Instance Position*, not just the vertex shape.
	// We extract the World Position of this cube instance.
	vec3 p = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 original_p = p;
	
	// A. Twist Logic (Rotates position based on distance)
	if (abs(twist.y) > 0.001) {
		float dist = length(p.xz);
		p.xz *= rot2D(dist * twist.y);
	}
	if (abs(twist.x) > 0.001) p.yz *= rot2D(p.x * twist.x);
	if (abs(twist.z) > 0.001) p.xy *= rot2D(p.z * twist.z);
	
	// B. Wave Logic (Offsets position based on Sine waves)
	// We use 'time' to make them ripple if desired
	if (length(wave_strength) > 0.001) {
		// Calculate Speed-Adjusted Time
		float t = time * wave_speed; 
		
		// Use 't' instead of 'time' below:
		float phase_x = p.x * wave_frequency.x + t;
		float phase_z = p.z * wave_frequency.z + t;
		float phase_y = p.y * wave_frequency.y + t;
		
		p.x += sin(phase_z + phase_y) * wave_strength.x;
		p.z += sin(phase_x + phase_y) * wave_strength.z;
		p.y += sin(p.x * wave_frequency.x + p.z * wave_frequency.z + p.x * wave_frequency.y + t) * wave_strength.y;
	}
	
	// C. Apply the difference to the Vertex
	// This shifts the cube to its new warped location
	VERTEX += (p - original_p);
}

void fragment() {
	vec3 graded_col = apply_grading(COLOR.rgb);
	ALBEDO = graded_col;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	EMISSION = graded_col * emission_energy;
}