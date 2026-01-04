shader_type spatial;
render_mode cull_back;

// --- 1. SHARED UNIFORMS ---
uniform sampler2D fractal_texture : filter_linear_mipmap;
uniform vec2 grid_size = vec2(100.0, 100.0);

// --- 2. GRID SETTINGS ---
uniform float height_scale : hint_range(0.0, 10.0) = 2.0;
uniform float cube_scale : hint_range(0.1, 1.0) = 0.9;

// --- 3. TUBE SPECIFIC SETTINGS (These were missing!) ---
uniform float thickness_scale : hint_range(0.1, 5.0) = 1.0;
uniform float tube_length : hint_range(0.1, 20.0) = 3.0;
uniform float flow_time = 0.0;       // Moves the texture along the tube
uniform float flow_smoothness = 1.0; // Blurs the trail

// --- 4. COLOR GRADING (Advanced) ---
uniform float brightness : hint_range(0.0, 3.0) = 1.0;
uniform float contrast : hint_range(0.0, 3.0) = 1.0;
uniform float saturation : hint_range(0.0, 3.0) = 1.0;
uniform float sharpen : hint_range(0.0, 5.0) = 0.0; // NEW
uniform float gamma : hint_range(0.1, 3.0) = 1.0;   // NEW
uniform float vibrance : hint_range(0.0, 3.0) = 1.0; // NEW

// --- 5. ANIMATION ---
uniform vec3 twist = vec3(0.0);
uniform vec3 wave_strength = vec3(0.0);
uniform vec3 wave_frequency = vec3(0.0);
uniform float wave_speed : hint_range(0.0, 10.0) = 1.0;
uniform float time = 0.0;
uniform float emission_energy : hint_range(0.0, 10.0) = 0.0;

// Material Properties
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;

varying vec3 v_color;

// --- HELPERS ---
mat2 rot2D(float a) {
	float c = cos(a), s = sin(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

vec3 apply_grading(vec3 color) {
	// 1. Brightness
	color = color * brightness;
	
	// 2. Contrast
	color = (color - 0.5) * contrast + 0.5;
	
	// 3. Saturation (Luma based)
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(gray), color, saturation);
	
	// 4. Vibrance (Boosts lower saturated colors more)
	float average = (color.r + color.g + color.b) / 3.0;
	float mx = max(color.r, max(color.g, color.b));
	float amt = (mx - average) * (-vibrance * 3.0);
	color = mix(color, vec3(mx), amt);
	
	// 5. Gamma
	color = pow(max(color, vec3(0.0)), vec3(1.0 / gamma));
	
	return color;
}

void vertex() {
	// Retrieve Instance Data (UV is stored in Custom Data)
	vec2 uv = INSTANCE_CUSTOM.xy;
	
	// --- FLOW TUBE LOGIC ---
	// If tube_length is > 0.0, we assume we want to apply tube stretching logic.
	// We offset the UV based on flow_time to make the colors "move" up the tube.
	vec2 lookup_uv = uv;
	if (tube_length > 1.0) { // Assuming tubes are longer than standard cubes
		lookup_uv.y += flow_time * 0.1; // Speed of flow
	}

	// Read Texture & Grade Color
	vec4 tex_data = texture(fractal_texture, lookup_uv);
	vec3 raw_color = tex_data.rgb;
	v_color = apply_grading(raw_color);
	
	// Calculate Height/Intensity from color brightness
	float intensity = (v_color.r + v_color.g + v_color.b) / 3.0;

	// --- GEOMETRY DEFORMATION ---
	
	// 1. WAVE & TWIST (Global Position)
	// We apply this to the MODEL_MATRIX to move the whole instance
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	float wave_x = sin(world_pos.y * wave_frequency.x + time * wave_speed) * wave_strength.x;
	float wave_y = sin(world_pos.z * wave_frequency.y + time * wave_speed) * wave_strength.y;
	float wave_z = sin(world_pos.x * wave_frequency.z + time * wave_speed) * wave_strength.z;
	
	VERTEX.x += wave_x;
	VERTEX.y += wave_y;
	VERTEX.z += wave_z;
	
	// 2. SCALE LOGIC (Grid vs Tubes)
	// We distinguish tubes by checking if thickness_scale is being used
	
	if (tube_length > 0.1 && thickness_scale != 1.0) {
		// --- TUBE MODE ---
		// Stretch Y based on length + intensity
		VERTEX.y *= tube_length * (0.5 + intensity); 
		
		// Scale X/Z (Thickness) based on slider
		VERTEX.x *= thickness_scale;
		VERTEX.z *= thickness_scale;
		
	} else {
		// --- GRID MODE ---
		// Scale all axes uniformly for cubes
		VERTEX *= cube_scale;
		
		// Move UP based on height_scale and intensity
		VERTEX.y += height_scale * intensity;
	}
}

void fragment() {
	ALBEDO = v_color;
	EMISSION = v_color * emission_energy;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}