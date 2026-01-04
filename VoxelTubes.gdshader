shader_type spatial;

// --- INPUTS ---
uniform sampler2D fractal_texture : filter_linear_mipmap; 

// --- ANIMATION CONTROL ---
uniform float flow_time = 0.0; // Replaces TIME. Controlled by script.

// --- SLIDERS (Matching your Script Names) ---
uniform float thickness_scale = 1.0; 
uniform float flow_smoothness = 1.0;   // Controls Curl/Wiggle strength
uniform float tube_length = 5.0;       

// --- STYLE SETTINGS ---
uniform float twist_speed = 4.0;       
uniform float curl_frequency = 0.5;    

// --- NEW: COLOR GRADING UNIFORMS ---
uniform float brightness : hint_range(0.0, 3.0) = 1.0;
uniform float contrast : hint_range(0.0, 3.0) = 1.0;
uniform float saturation : hint_range(0.0, 3.0) = 1.0;
uniform float sharpen : hint_range(0.0, 5.0) = 0.0;
uniform float gamma : hint_range(0.1, 3.0) = 1.0;
uniform float vibrance : hint_range(0.0, 3.0) = 1.0;

// --- NEW: LIGHTING UNIFORMS (To prevent errors from script) ---
uniform vec3 light_direction = vec3(0.0, 1.0, 0.0);
uniform vec3 light_color_val = vec3(1.0);
uniform float light_energy_val = 1.0;

// Helper: 3D Rotation Matrix
mat3 axis_angle_matrix(vec3 axis, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return mat3(
        vec3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s),
        vec3(oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.z + c,           oc * axis.y * axis.z - axis.x * s),
        vec3(oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c)
    );
}

vec2 get_contour_dir(vec2 uv) {
    float step = 0.01;
    float h = texture(fractal_texture, uv).r;
    float h_right = texture(fractal_texture, uv + vec2(step, 0.0)).r;
    float h_down = texture(fractal_texture, uv + vec2(0.0, step)).r;
    
    float dx = h_right - h;
    float dy = h_down - h;
    
    vec2 contour = normalize(vec2(-dy, dx));
    if (length(contour) < 0.001) return vec2(1.0, 0.0);
    return contour;
}

// --- NEW: COLOR GRADING FUNCTION ---
vec3 apply_grading(vec3 color) {
    // Brightness
    color = color * brightness;
    // Contrast
    color = (color - 0.5) * contrast + 0.5;
    // Saturation
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(gray), color, saturation);
    // Vibrance
    float average = (color.r + color.g + color.b) / 3.0;
    float mx = max(color.r, max(color.g, color.b));
    float amt = (mx - average) * (-vibrance * 3.0);
    color = mix(color, vec3(mx), amt);
    // Gamma
    color = pow(max(color, vec3(0.0)), vec3(1.0 / gamma));
    return color;
}

void vertex() {
    vec2 cell_uv = INSTANCE_CUSTOM.rg;
    vec4 tex_data = texture(fractal_texture, cell_uv);
    
    // --- APPLY GRADING IMMEDIATELY ---
    tex_data.rgb = apply_grading(tex_data.rgb);
    
    float intensity = tex_data.r; 
    
    // 1. Initial Scale
    float visibility = clamp(intensity * 3.0, 0.0, 1.0);
    VERTEX.x *= thickness_scale * visibility * 0.4; 
    VERTEX.z *= thickness_scale * visibility * 0.4;
    VERTEX.y *= tube_length; 
    
    // 2. THE CURVE (Uses flow_time now)
    float curve = flow_smoothness * 0.5;
    float wiggle = sin(VERTEX.y * curl_frequency + flow_time) * 0.3 * curve;
    float arc = cos(VERTEX.y * 0.5) * curve;
    VERTEX.x += wiggle + arc;

    // 3. BARBER POLE TWIST
    float twist_angle = VERTEX.y * twist_speed * intensity;
    VERTEX = axis_angle_matrix(vec3(0.0, 1.0, 0.0), twist_angle) * VERTEX;
    
    // 4. ORIENTATION
    vec2 flow = get_contour_dir(cell_uv);
    vec3 target_dir = normalize(vec3(flow.x, 0.0, flow.y));
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 axis = normalize(cross(up, target_dir));
    float angle = acos(dot(up, target_dir));
    
    VERTEX = axis_angle_matrix(axis, angle) * VERTEX;
    
    // 5. Height Offset
    VERTEX.y += intensity * 5.0;

    // Pass the GRADED color to the fragment shader
    COLOR = tex_data;
    
    // --- NORMALS FIX ---
    NORMAL = axis_angle_matrix(axis, angle) * NORMAL;
}

void fragment() {
    ALBEDO = COLOR.rgb;
    METALLIC = 0.6;
    ROUGHNESS = 0.2;
    EMISSION = COLOR.rgb * 0.3;
}