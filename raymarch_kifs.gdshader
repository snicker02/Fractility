shader_type spatial;
render_mode unshaded, cull_back, depth_draw_always;

uniform sampler2D fractal_texture : filter_linear_mipmap;

// --- SETTINGS ---
const int MAX_STEPS = 256;       
const float MAX_DIST = 100.0;     
const float SURF_DIST = 0.001;

// --- CORE UNIFORMS ---
uniform float time;
uniform int iterations : hint_range(1, 12) = 8;
uniform float box_size : hint_range(1.0, 50.0) = 25.0;
uniform float step_speed : hint_range(0.1, 1.0) = 0.5;

// --- TRANSFORMATIONS ---
uniform float pre_scale : hint_range(0.0, 5.0) = 1.5;
uniform vec3 plane_rot = vec3(0.0);
uniform vec2 pre_translate = vec2(0.5, 0.5); 

// --- SYMMETRY ---
uniform float kaleidoscope_slices : hint_range(0.0, 20.0) = 6.0;
uniform bool kaleidoscope_on = true;
uniform bool mirror_x = true;
uniform bool mirror_y = true;
uniform bool kaleidoscope_3d = false; // Toggle for 3D Symmetry

// --- VARIATIONS ---
uniform int variation_mode_a;
uniform int variation_mode_b;
uniform float variation_mix : hint_range(0.0, 1.0);

// GENERIC SLOTS (A)
uniform float var_a_scale; 
uniform float var_a_strength; 
uniform float var_a_speed;
uniform float var_a_param1; 
uniform float var_a_param2;
uniform vec2 var_a_center;   // Center X/Y
uniform vec4 var_a_extra;    // Extra slots (Mobius C/D)

// GENERIC SLOTS (B)
uniform float var_b_scale; 
uniform float var_b_strength; 
uniform float var_b_speed;
uniform float var_b_param1; 
uniform float var_b_param2;
uniform vec2 var_b_center;
uniform vec4 var_b_extra;

// --- MOBIQ UNIFORMS (4 Quaternions per Variation) ---
uniform vec4 mobiq_a_A; // qat, qax, qay, qaz
uniform vec4 mobiq_a_B; // qbt, qbx, qby, qbz
uniform vec4 mobiq_a_C; // qct, qcx, qcy, qcz
uniform vec4 mobiq_a_D; // qdt, qdx, qdy, qdz

uniform vec4 mobiq_b_A;
uniform vec4 mobiq_b_B;
uniform vec4 mobiq_b_C;
uniform vec4 mobiq_b_D;

// --- VISUALS ---
uniform float texture_intensity : hint_range(0.0, 2.0) = 0.5;
uniform float texture_scale : hint_range(0.1, 5.0) = 1.0;
uniform vec3 light_direction = vec3(0.5, 1.0, -0.5);
uniform vec3 light_color_val = vec3(1.0);
uniform float light_energy_val = 1.0;
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;
// --- COLORING UNIFORMS ---
uniform int color_mode = 0; // 0 = Texture, 1 = Orbit Trap
uniform vec3 orbit_color_1 = vec3(1.0, 0.5, 0.2); // Core Color (e.g. Orange)
uniform vec3 orbit_color_2 = vec3(0.2, 0.5, 1.0); // Edge Color (e.g. Blue)
uniform float orbit_contrast : hint_range(0.1, 5.0) = 1.0;
uniform float orbit_offset : hint_range(-5.0, 5.0) = 0.0;
uniform int trap_mode = 1; // 0=Sphere, 1=Cylinder, 2=Plane, 3=Cross

varying vec3 camera_origin;
varying mat4 model_view_inv;

// --- ARBITRARY ROTATION ---
// The axis to spin around (e.g. 1,1,1 is a diagonal)
uniform vec3 custom_rot_axis = vec3(0.0, 1.0, 0.0); 
// How much to spin
uniform float custom_rot_angle : hint_range(-180.0, 180.0) = 0.0;

uniform vec3 fold_shift = vec3(0.0);

// --- HELPERS ---

// Rotates a point 'p' around an arbitrary 'axis' by 'angle' (in radians)
vec3 rotAxis(vec3 p, vec3 axis, float angle) {
    // Ensure axis is normalized (length of 1) to prevent scaling artifacts
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    // Rodrigues' Rotation Formula Matrix
    mat3 rot = mat3(
        vec3(c + axis.x * axis.x * oc, axis.x * axis.y * oc - axis.z * s, axis.x * axis.z * oc + axis.y * s),
        vec3(axis.y * axis.x * oc + axis.z * s, c + axis.y * axis.y * oc, axis.y * axis.z * oc - axis.x * s),
        vec3(axis.z * axis.x * oc - axis.y * s, axis.z * axis.y * oc + axis.x * s, c + axis.z * axis.z * oc)
    );
    
    return rot * p;
}




float sqr(float x) { return x*x; }
// --- 3D SYMMETRY HELPER ---
void fold_dodeca(inout vec3 p) {
    // Normal vectors for the Dodecahedron faces
    const float phi = 1.61803398875; // Golden Ratio
    vec3 n1 = normalize(vec3(-1.0, phi - 1.0, phi));
    vec3 n2 = normalize(vec3(phi - 1.0, phi, -1.0));
    
    // Fold space against these planes
    p = abs(p);
    float t;
    
    // Fold 1
    t = dot(p, n1);
    if (t > 0.0) p -= 2.0 * t * n1;
    
    // Fold 2
    t = dot(p, n2);
    if (t > 0.0) p -= 2.0 * t * n2;
    
    // Extra cleanup fold for perfect symmetry
    if (p.x > p.z) p.xz = p.zx;
    if (p.y > p.z) p.yz = p.zy;
}
// --- OCTAHEDRON FOLD (Diamond/Pyramid) ---
void fold_octa(inout vec3 p) {
    p = abs(p);
    if (p.x < p.y) p.xy = p.yx;
    if (p.x < p.z) p.xz = p.zx;
    if (p.y < p.z) p.yz = p.zy;
}
void fold_icosa(inout vec3 p) {
    const float phi = 1.61803398875; 
    
    // The Icosahedron fold relies on different planes than the Dodeca
    // This creates the 20-sided triangular symmetry
    vec3 n = normalize(vec3(1.0, phi, 0.0));
    vec3 n2 = normalize(vec3(-1.0, phi, 0.0));

    // Standard recursive folding logic
    p = abs(p);
    
    // Sort axes to force into fundamental wedge
    if (p.x > p.y) p.xy = p.yx;
    if (p.y > p.z) p.yz = p.zy;
    if (p.x > p.y) p.xy = p.yx;
    
    // Fold against the Golden Ratio planes
    float t = dot(p, n);
    if (t < 0.0) p -= 2.0 * t * n;
    
    t = dot(p, n2);
    if (t < 0.0) p -= 2.0 * t * n2;
}
mat2 rot2D(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(vec2(c, -s), vec2(s, c));
}

bool hit_box(vec3 ro, vec3 rd, vec3 size, out float t_near, out float t_far) {
    vec3 m = 1.0 / rd;
    vec3 n = m * ro;
    vec3 k = abs(m) * size;
    vec3 t1 = -n - k;
    vec3 t2 = -n + k;
    t_near = max(max(t1.x, t1.y), t1.z);
    t_far = min(min(t2.x, t2.y), t2.z);
    return t_near <= t_far && t_far > 0.0;
}

// --- MOBIQ HELPER ---
vec3 mobiq(vec3 p, vec4 Q_a, vec4 Q_b, vec4 Q_c, vec4 Q_d, float amount) {
    float t2 = p.x; float x2 = p.y; float y2 = p.z;
    
    // Unpack Quaternions
    float t1 = Q_a.x; float x1 = Q_a.y; float y1 = Q_a.z; float z1 = Q_a.w;
    float t3 = Q_b.x; float x3 = Q_b.y; float y3 = Q_b.z; float z3 = Q_b.w;
    float t4 = Q_c.x; float x4 = Q_c.y; float y4 = Q_c.z; float z4 = Q_c.w;
    float t5 = Q_d.x; float x5 = Q_d.y; float y5 = Q_d.z; float z5 = Q_d.w;

    // Numerator
    float nt = t1 * t2 - x1 * x2 - y1 * y2 + t3;
    float nx = t1 * x2 + x1 * t2 - z1 * y2 + x3;
    float ny = t1 * y2 + y1 * t2 + z1 * x2 + y3;
    float nz = z1 * t2 + x1 * y2 - y1 * x2 + z3;

    // Denominator
    float dt = t4 * t2 - x4 * x2 - y4 * y2 + t5;
    float dx = t4 * x2 + x4 * t2 - z4 * y2 + x5;
    float dy = t4 * y2 + y4 * t2 + z4 * x2 + y5;
    float dz = z4 * t2 + x4 * y2 - y4 * x2 + z5;

    // Inverse Factor
    float dist_sq = (dt*dt + dx*dx + dy*dy + dz*dz);
    if (dist_sq < 0.0001) dist_sq = 0.0001;
    float ni = amount / dist_sq;

    // Result
    vec3 res;
    res.x = (nt * dt + nx * dx + ny * dy + nz * dz) * ni;
    res.y = (nx * dt - nt * dx - ny * dz + nz * dy) * ni;
    res.z = (ny * dt - nt * dy - nz * dx + nx * dz) * ni;
    
    return res;
}

// --- VARIATION MATH (MASTER LIST) ---
vec3 apply_variation(vec3 p, int mode, float scale, float strength, float speed, float p1, float p2, vec2 center, vec4 extra, vec4 qA, vec4 qB, vec4 qC, vec4 qD) {
    float t = time * speed; 
    
    // 0: Sinusoidal
    if (mode == 0) return p + vec3(sin(p.x * scale + t), sin(p.y * scale + t), sin(p.z * scale + t)) * strength * 0.1;

    // 1: Spherical
    if (mode == 1) { 
        vec3 offset = vec3(center.x, center.y, 0.0); 
        vec3 p_centered = p - offset;
        float r2 = dot(p_centered, p_centered); 
        float s = strength * (1.0 + sin(t)*0.2); 
        return (p_centered / (r2 + 0.01) * s) + offset; 
    }

    // 2: Hyper-Swirl (TRUE 3D UPGRADE)
    if (mode == 2) { 
        // We use full 3D distance 'length(p)' instead of 2D 'length(p.xy)'
        float r = length(p); 
        float effective_r = (abs(p1) < 0.001) ? 1.0 : p1; 
        float effective_ang = (abs(p2) < 0.001) ? 1.0 : p2;
        
        // Calculate rotation angle based on 3D distance
        float angle = (r * effective_r * strength * effective_ang) + t;
        
        // Rotate X/Y (Standard Swirl)
        vec3 q = p;
        q.xy *= rot2D(angle);
        
        // NEW: Rotate Y/Z (The 3D Twist)
        // We offset the angle slightly so it doesn't just rotate diagonally
        q.yz *= rot2D(angle * 0.7);
        
        return q;
    }

    // 3: Ripple
    if (mode == 3) { 
        float freq = scale;
        float amp = strength * 0.1; // Scale down for 3D sanity
        float phase = p2;
        float wave_t = t + phase; // Combine time + phase offset

        // TYPE 0: HELICAL WAVE (Twists X and Z based on Y)
        if (p1 < 0.5) {
            float s = sin(p.y * freq + wave_t);
            float c = cos(p.y * freq + wave_t);
            // Shift X and Z perpendicularly to create a spiral twist
            return p + vec3(s * amp, 0.0, c * amp); 
        } 
        // TYPE 1: RADIAL PULSE (3D Onion Layers)
        else if (p1 < 1.5) { 
            float r = length(p); // 3D Distance
            // Modulate scale based on distance from center
            float pulse = 1.0 + sin(r * freq + wave_t) * amp;
            return p * pulse; 
        } 
        // TYPE 2: SQUARE/VOXEL (Digital Glitch)
        else { 
            // Hard steps based on Y height
            float step_val = sign(sin(p.y * freq + wave_t)) * amp;
            // Shift layers abruptly
            return p + vec3(step_val, 0.0, -step_val); 
        }
    }
    // 5: Polar
    if (mode == 5) { 
        float r = length(p.xy); 
        float a = atan(p.y, p.x); 
        return vec3(a, r - strength - (p1 + t), p.z); 
    }

    // 6: Fisheye
    if (mode == 6) { float r = length(p); float s = strength * (1.0 + sin(t)*0.3); return p * (s / (r + 1.0)); }

    // 9: Mobius (Full A/B/C/D)
    if (mode == 9) {
        vec2 z = p.xy;
        vec2 a = vec2(p1, p2);
        vec2 b = center;
        vec2 c = extra.xy;
        vec2 d = extra.zw;
        vec2 az = vec2(a.x*z.x - a.y*z.y, a.x*z.y + a.y*z.x);
        vec2 num = az + b;
        vec2 cz = vec2(c.x*z.x - c.y*z.y, c.x*z.y + c.y*z.x);
        vec2 den = cz + d;
        float den2 = dot(den, den);
        if (den2 < 0.001) den2 = 0.001; 
        vec2 res;
        res.x = (num.x * den.x + num.y * den.y) / den2;
        res.y = (num.y * den.x - num.x * den.y) / den2;
        float z_warp = p.z + sin(length(p.xy) * 5.0 + t) * strength * 0.2;
        return mix(p, vec3(res, z_warp), strength);
    }
// 13: APOLLONIAN (3D Bubble Packing)
    if (mode == 13) {
        // 1. Unpack the 3 centers (Z is assumed 0.0)
        vec3 c1 = vec3(center.x, center.y, 0.0);
        vec3 c2 = vec3(extra.x, extra.y, 0.0);
        vec3 c3 = vec3(extra.z, extra.w, 0.0);
        
        // 2. Find the closest center (Voronoi Logic)
        // We use full 3D length() so it creates spheres, not cylinders
        float d1 = length(p - c1);
        float d2 = length(p - c2);
        float d3 = length(p - c3);
        
        vec3 best_c = c1;
        if (d2 < d1 && d2 < d3) best_c = c2;
        if (d3 < d1 && d3 < d2) best_c = c3;
        
        // 3. Apply IFS Scaling
        // Formula: p = center + (vector_to_center) / scale
        float s = scale;
        if (abs(s) < 0.001) s = 0.001; // Safety check
        
        // Optional: Add Time/Strength to animate the "Breathing" of the cells
        // s += sin(t) * strength * 0.1; 
        
        return best_c + (p - best_c) / s;
    }
	
	// 16: ARCTANGENT (Organic Warp)
    // scale = Frequency of the warp
    // strength = Amount of distortion
    // p1 = Offset/Shift
    if (mode == 16) {
        // Calculate the warp based on position + time
        vec3 shift = p * scale + (t + p1);
        
        // Apply ArcTan (Squashes space into a -1.57 to 1.57 range)
        vec3 warp = atan(shift);
        
        // Distort the original point
        return p + warp * strength * 0.5;
    }
	
	
	// 45: CANVAS (Weave Texture)
    // scale    = Thread Density
    // strength = Depth of weave
    // p1       = Flow (Slide speed)
    // p2       = Style (0=Smooth Sine, 1=Sharp Zigzag)
    // extra.r  = Chaos (Noise)
    if (mode == 45) {
        float flow = t * 0.5 + p1;
        vec3 s = p * scale + vec3(flow);

        // Chaos Injection
        if (extra.r > 0.01) {
             s += vec3(sin(p.z*10.0), cos(p.x*10.0), sin(p.y*10.0)) * extra.r;
        }

        vec3 weave;
        
        // STYLE 0: SMOOTH (Sine)
        if (p2 < 0.5) {
            weave.x = sin(s.y) * cos(s.z);
            weave.y = sin(s.z) * cos(s.x);
            weave.z = sin(s.x) * cos(s.y);
        } 
        // STYLE 1: SHARP (Triangle/ZigZag)
        else if (p2 < 1.5) {
            weave.x = asin(sin(s.y)) * acos(cos(s.z));
            weave.y = asin(sin(s.z)) * acos(cos(s.x));
            weave.z = asin(sin(s.x)) * acos(cos(s.y));
        }
        // STYLE 2: BASKET (Square/Step)
        else if (p2 < 2.5) {
            weave.x = sign(sin(s.y)) * sign(cos(s.z));
            weave.y = sign(sin(s.z)) * sign(cos(s.x));
            weave.z = sign(sin(s.x)) * sign(cos(s.y));
        }
        // STYLE 3: DIAGONAL (Twill)
        else {
            vec3 s2 = s * 0.707; // Rotate 45 deg approximation
            weave.x = sin(s2.y + s2.z) * cos(s2.y - s2.z);
            weave.y = sin(s2.z + s2.x) * cos(s2.z - s2.x);
            weave.z = sin(s2.x + s2.y) * cos(s2.x - s2.y);
        }

        return p + weave * strength * 0.1;
    }
	
	
	// 14: COSINE (Ripples)
    // scale    = Frequency (Tightness of waves)
    // strength = Amplitude (Height of waves)
    // p1       = Phase Shift (Slide the waves)
    if (mode == 14) {
        // Calculate the wave phase
        // We add Time (t) automatically for animation
        vec3 phase = p * scale + vec3(t + p1);
        
        // Calculate Cosine distortion
        vec3 wave = cos(phase) * strength * 0.1;
        
        // Apply to position
        return p + wave;
    }
	
	
	// 4: JULIAN (3D Julia Set Injection)
    // scale    = Power (Exponent). Usually 2.0 to 5.0.
    // strength = Distortion Amount (Mix factor).
    // center   = Seed A, B (The "Julia Constant" Real/Imaginary parts).
    // extra    = Seed C, D, E, F (Extra dimensions for 3D warping).
    if (mode == 4) {
        float power = (abs(scale) < 0.1) ? 2.0 : scale;
        
        // --- STABILITY FIX ---
        // If 'p' is too far out, the power rule makes it infinite.
        // We clamp 'r' to keep the math inside the box.
        float r = length(p);
        if (r > 2.0) r = 2.0; 
        
        float a = atan(p.y, p.x);
        float phi = atan(p.z, length(p.xy));
        
        // Apply Power Rule
        float r_new = pow(r, power);
        float a_new = a * power;
        float phi_new = phi * power;
        
        // Back to Cartesian
        vec3 q;
        q.x = r_new * cos(phi_new) * cos(a_new);
        q.y = r_new * cos(phi_new) * sin(a_new);
        q.z = r_new * sin(phi_new);
        
        // --- APPLY VARIABLES A-F ---
        // A & B: The standard Julia Constant
        q.x += center.x; 
        q.y += center.y; 
        
        // C, D, E: Offset the shape in 3D space
        q.x += extra.r; // Julian C
        q.y += extra.g; // Julian D
        q.z += extra.b; // Julian E
        
        // F: Rotate the result slightly (Twist)
        if (abs(extra.a) > 0.01) { // Julian F
             float s = sin(extra.a);
             float c = cos(extra.a);
             float old_x = q.x;
             q.x = old_x * c - q.y * s;
             q.y = old_x * s + q.y * c;
        }
        
        return mix(p, q, strength * 0.5);
    }
	
	
	// 40: GNARL FRANKENSTEIN (Direct Port to 3D)
    // scale    = Scale X
    // extra.r  = Scale Y
    // extra.g  = Distort Amount
    // extra.b  = Freq X2
    // extra.a  = Freq Y2
    // center   = Freq X1 / Y1
    // p2       = C1 (Phase)
    // p1       = Mode
    if (mode == 40) {
        // --- 1. SETUP VARIABLES ---
        // Map inputs to the names used in your script for clarity
        float sx = (abs(scale) < 0.001) ? 1.0 : scale;
        float sy = (abs(extra.r) < 0.001) ? sx : extra.r; // Default to SX if 0
        float sz = sx; // Z follows X

        float fx1 = center.x;
        float fy1 = center.y;
        float fz1 = center.x; // Z follows X
        
        float fx2 = extra.b;
        float fy2 = extra.a;
        float fz2 = extra.b;

        // Auto-generate Freq3 since we ran out of slots
        float fx3 = fx1 * 2.0; 
        float fy3 = fy1 * 2.0;
        float fz3 = fx1 * 2.0;

        float c1 = p2;
        float c2 = p2; // Mirror C1
        float dist_amt = extra.g;

        float x0 = p.x;
        float y0 = p.y;
        float z0 = p.z;
        
        float x1 = 0.0;
        float y1 = 0.0;
        float z1 = 0.0;
        
        int m = int(p1);
        if (m == 0) m = 1; // Default to Mode 1

        // --- MODE 9: VIBRATION MONSTER ---
        if (m == 9) {
             float dir = c1;
             float angle = c2; 
             // Wave 1
             float d_along = x0 * cos(dir) + y0 * sin(dir);
             float dirL = dir + (fx2 * sin(d_along)); // Modulate approx
             float angleL = angle + (fy2 * sin(d_along));
             float local_amp = sx * sin((d_along * fx1 * 6.28));
             
             x1 = local_amp * cos(angleL + dirL);
             y1 = local_amp * sin(angleL + dirL);
             z1 = local_amp * sin(angleL); // 3D extension

             p += vec3(x1, y1, z1);
             return p; // Skip standard mixing
        }
        // --- MODE 10: LIGHTNING (Exponential) ---
        else if (m == 10) {
             x1 = exp(sin(fx1 * y0)) * cos(fx2 * x0) * sx * 0.5;
             y1 = exp(sin(fy1 * x0)) * cos(fy2 * y0) * sy * 0.5;
             z1 = exp(sin(fz1 * y0)) * cos(fz2 * z0) * sz * 0.5;
             
             p += vec3(x1, y1, z1);
             // Fall through to mixing...
             x0 = p.x; y0 = p.y; z0 = p.z;
        }
        // --- MODES 1-8: DC GNARLY ---
        else {
             float t_anim = 0.0; // Internal animation if needed
             
             // We use a macro-style switch for the math functions
             // 3D Logic: Z usually mirrors X or combines X/Y
             if (m == 1) { // COS
                 x1 = cos(fx1*y0 + sin(fx2*(y0 + sin(fx3*y0))));
                 y1 = cos(fy1*x0 + sin(fy2*(x0 + sin(fy3*x0))));
                 z1 = cos(fz1*x0 + sin(fz2*(z0 + sin(fz3*z0))));
             }
             else if (m == 2) { // SIN
                 x1 = sin(fx1*y0 + sin(fx2*(y0 + cos(fx3*y0))));
                 y1 = sin(fy1*x0 + sin(fy2*(x0 + cos(fy3*x0))));
                 z1 = sin(fz1*y0 + sin(fz2*(z0 + cos(fz3*z0))));
             }
             else if (m == 3) { // COS/SIN MIX
                 x1 = cos(fx1*y0 + sin(fx2*(x0 + sin(fx3*y0))));
                 y1 = cos(fy1*x0 + sin(fy2*(y0 + sin(fy3*x0))));
                 z1 = cos(fz1*x0 + sin(fz2*(z0 + sin(fz3*z0))));
             }
             // ... (Skipping complex 4-6 for brevity, mapping 7/8)
             else if (m >= 4) { // SQR (Mode 7/8 logic)
                 x1 = sin(fx1*y0 + sin(sqr(fx2*(y0 + cos(fx3*y0)))));
                 y1 = sin(fy1*x0 + sin(sqr(fy2*(x0 + cos(fy3*x0)))));
                 z1 = sin(fz1*y0 + sin(sqr(fz2*(z0 + cos(fz3*z0)))));
             }
        }
        
        // APPLY SCALES
        x1 *= sx; y1 *= sy; z1 *= sz;
        
        // --- STEP 1: BASIC SHAPE MIX ---
        p.x = (x0 + x1) * 0.5;
        p.y = (y0 + y1) * 0.5;
        p.z = (z0 + z1) * 0.5;
        
        // --- STEP 2: CALCULATE S1 (Log Radius) ---
        float s1 = 0.0;
        float r2 = x1*x1 + y1*y1 + z1*z1; // 3D radius squared
        if (r2 > 0.0001) s1 = log(sqrt(r2));
        
        // --- STEP 3: APPLY LOG DISTORTION ---
        if (abs(dist_amt) > 0.001) {
            p += vec3(s1 * dist_amt) * 0.5;
        }
        
        // --- STEP 4: PHASE WARPING ---
        if (abs(c1) > 0.001) {
            float final_s1 = s1 * dist_amt;
            // 3D Phase logic
            float phase_val = abs(cos(x0 + x1*c1 + final_s1) + sin(y0 + y1*c2 + final_s1));
            p += vec3(sin(phase_val), cos(phase_val), sin(phase_val*0.5)) * 0.1;
        }

        return p;
    }
	// 32: CLIFFORD ATTRACTOR
    // center.x = a (Default -1.4)
    // center.y = b (Default 1.6)
    // extra.r  = c (Default 1.0)
    // extra.g  = d (Default 0.7)
    // strength = Mix Amount
    if (mode == 32) {
        // Use standard Clifford defaults if sliders are near zero
        float a = (abs(center.x) < 0.001) ? -1.4 : center.x;
        float b = (abs(center.y) < 0.001) ? 1.6 : center.y;
        float c = (abs(extra.r) < 0.001) ? 1.0 : extra.r;
        float d = (abs(extra.g) < 0.001) ? 0.7 : extra.g;

        // The Clifford Formula
        // x' = sin(a * y) + c * cos(a * x)
        // y' = sin(b * x) + d * cos(b * y)
        vec3 q;
        q.x = sin(a * p.y) + c * cos(a * p.x);
        q.y = sin(b * p.x) + d * cos(b * p.y);
        
        // Z behavior: We pass Z through, but perhaps warped by X to create volume
        q.z = p.z; 

        // Apply distortion
        return mix(p, q, strength);
    }
	
	
	// 33: DEJONG ATTRACTOR
    // center.x = a (Default 1.4)
    // center.y = b (Default -2.3)
    // extra.r  = c (Default 2.4)
    // extra.g  = d (Default -2.1)
    if (mode == 33) {
        // Defaults to ensure a visible shape if vars are 0
        float a = (abs(center.x) < 0.001) ? 1.4 : center.x;
        float b = (abs(center.y) < 0.001) ? -2.3 : center.y;
        float c = (abs(extra.r) < 0.001) ? 2.4 : extra.r;
        float d = (abs(extra.g) < 0.001) ? -2.1 : extra.g;

        // The DeJong Formula:
        // x' = sin(a * y) - cos(b * x)
        // y' = sin(c * x) - cos(d * y)
        vec3 q;
        q.x = sin(a * p.y) - cos(b * p.x);
        q.y = sin(c * p.x) - cos(d * p.y);
        
        // Z Pass-through (Extruded shape)
        q.z = p.z; 

        return mix(p, q, strength);
    }
	
	
	
	
	
	
	// 42: FROSTBYTE (Snowflake KIFS)
    // scale    = Zoom (s_scale)
    // strength = Mix Amount (s_strength)
    // p1       = Branch Angle (s_branch)
    // p2       = Thickness/Spacing (s_thick)
    // extra.r  = Chaos/Twist (s_chaos)
    if (mode == 42) {
        // 1. Setup Parameters
        // Defaults to ensure it looks like a snowflake immediately
        float branch_angle = 0.523598 + (p1 * 0.2); // ~30 degrees base
        float thickness = 1.0 + (p2 * 10.0);        // Spacing
        float chaos = extra.r;
        
        // 2. Center and Scale
        // Apply initial zoom
        float zoom = max(0.1, scale);
        vec3 q = p * zoom;

        // 3. FRACTAL LOOP (4 Iterations)
        vec2 n = vec2(sin(branch_angle), cos(branch_angle));
        
        for (int i = 0; i < 4; i++) {
            // A. Symmetry Fold (Kaleidoscope on X)
            q.x = abs(q.x);
            
            // B. Hexagonal Fold
            // We fold space along the normal 'n' to create 6-sided symmetry
            q.xy -= 2.0 * min(0.0, dot(q.xy, n)) * n;

            // C. Shift (Thickness)
            q.y -= thickness;
            
            // D. Rotation (Chaos)
            // If chaos is active, we rotate the XY plane per iteration
            if (abs(chaos) > 0.01) {
                float ang = chaos * float(i);
                float c = cos(ang);
                float s = sin(ang);
                mat2 rot = mat2(vec2(c, -s), vec2(s, c));
                q.xy = rot * q.xy;
            }

            // E. Scale down for next layer
            // We scale Z too, to create 3D fractal detail
            q *= 1.4;
            q.z *= 1.4; 
        }

        // 4. Mix
        // Blend between original space 'p' and fractal space 'q'
        return mix(p, q, strength);
    }
	
	
	// 10: CELLULAR WEAVE (Chainmail / Reptile Skin)
    // scale    = Cell Density (Size of the links)
    // strength = Inflate/Deflate amount
    // p1       = Offset (Shift the grid)
    if (mode == 10) {
        // 1. Create the grid space
        vec3 s = p * scale + vec3(p1);
        
        // 2. Identify Cell ID and Local Coordinate
        vec3 cell = floor(s);
        vec3 local = fract(s) - 0.5; // Range -0.5 to 0.5
        
        // 3. Distance to the center of the cell
        float d = length(local);
        
        // 4. Checkerboard Logic
        // Determine if this cell is "Even" or "Odd"
        // This makes neighbors do opposite things (The "Weave")
        float check = mod(cell.x + cell.y + cell.z, 2.0) * 2.0 - 1.0;
        
        // 5. Apply Distortion
        // We push points away from the cell center, flipped by the checkerboard
        return p + local * (0.8 - d) * strength * check;
    }
	
	
    // 15: Tangent
    if (mode == 15) { 
        vec3 t_val = clamp(tan(vec3(p.y, p.z, p.x) * scale + t), -3.0, 3.0); 
        return p + t_val * strength * 0.1; 
    }

    // 34: Truchet
    if (mode == 34) {
        float s = max(0.1, scale);
        vec3 p_rot = p;
        float rot_angle = p2 + (t * 50.0);
        if (abs(rot_angle) > 0.01) p_rot.xy *= rot2D(radians(rot_angle));
        vec3 ip = floor(p_rot * s);
        vec3 fp = fract(p_rot * s) - 0.5;
        float rnd = fract(sin(dot(ip, vec3(12.9898, 78.233, 45.543))) * 43758.5453);
        if (p1 < 0.5) { 
            vec3 disp = (rnd > 0.5) ? vec3(fp.y, fp.x, 0.0) : vec3(-fp.y, fp.x, 0.0);
            return p + disp * strength * 0.2;
        } else { 
             if (rnd > 0.5) fp.xy = vec2(fp.y, -fp.x);
             return (ip + fp + 0.5) / s;
        }
    }

    // 37: GLYNNSIM (Granular Tearing)
    // scale    = Radius (Inner)
    // strength = Thickness
    // p1       = Contrast (Density)
    // p2       = Power
    // extra.r  = Ring Mode (0=Empty, 1=Tex, 2=Stripes, 3=Checkers, 4=Dots, 5=Plasma, 6=Spiral)
    if (mode == 37) {
        // 1. Defaults
        float radius = max(0.001, scale);
        float thickness = max(0.0, strength);
        float g_contrast = clamp(p1, 0.0, 1.0);
        float power = p2;
        int ring_mode = int(extra.r);

        float r = length(p);
        float inner_edge = radius;
        float outer_edge = radius + thickness;

        // --- ZONE 1: INSIDE (Hole) ---
        if (r < inner_edge) {
            // Map hole to source (Magnify)
            return p * (1.0 / inner_edge);
        }

        // --- ZONE 2: THE RING ---
        else if (r < outer_edge) {
            // If mode 0 (Empty) or logic hits, we "delete" space by blowing it up
            bool delete_pixel = false;

            if (ring_mode == 0) delete_pixel = true;
            else if (ring_mode == 1) return p * (inner_edge / r); // Texture
            else if (ring_mode == 2) { // STRIPES
                 if (sin(r * 50.0 + t * 5.0) > 0.0) delete_pixel = true;
            }
            else if (ring_mode == 3) { // CHECKERS (3D)
                 // Checkers on a sphere surface approx
                 float a = atan(p.y, p.x); 
                 float b = atan(p.z, length(p.xy));
                 if (sin(r * 20.0) * sin(a * 10.0 + b * 10.0) > 0.0) delete_pixel = true;
            }
            else if (ring_mode == 4) { // DOTS
                 vec3 grid = fract(p * 10.0) - 0.5;
                 if (length(grid) < 0.3) delete_pixel = true;
            }
            else if (ring_mode == 5) { // PLASMA
                 float v = sin(p.x * 20.0 + t) + sin(p.y * 20.0 + t) + sin(p.z * 20.0);
                 if (v > 0.0) delete_pixel = true;
            }
            else if (ring_mode == 6) { // SPIRAL
                 float a = atan(p.y, p.x) + p.z; // Helix
                 if (sin(a * 10.0 + r * 40.0) > 0.0) delete_pixel = true;
            }

            if (delete_pixel) return p * 1000.0; // "Empty" space
            return p * (inner_edge / r); // Default ring background
        }

        // --- ZONE 3: OUTSIDE (Tearing) ---
        else {
            // 1. Shift Space
            float shifted_r = r - thickness;
            vec3 p_shifted = p * (shifted_r / r);

            // 2. Glynn Math
            float alpha = inner_edge / max(0.0001, shifted_r);

            // 3. Probabilistic Tearing (3D Noise approximation)
            // We use a simple hash based on position
            vec3 p3 = fract(p * 500.0);
            float rnd = fract(dot(p3, vec3(12.9898, 78.233, 45.164)));

            float threshold = g_contrast * pow(alpha, abs(power));

            if (rnd > threshold) {
                // Option A: Solid
                return p_shifted;
            } else {
                // Option B: Torn (Stretched)
                return p_shifted / (alpha * alpha);
            }
        }
    }


	
	
	
	// 12: HEART (Extruded 3D Heart Tube)
    // scale    = Size (heart_scale)
    // strength = Distortion Amount (heart_strength)
    // p1       = Rotation (heart_rotation)
    if (mode == 12) {
        // 1. Setup Parameters
        // Prevent divide by zero on scale
        float anim_scale = (abs(scale) < 0.01) ? 1.0 : scale;
        float anim_rot = radians(p1); // Convert degrees to radians
        float anim_str = strength;

        // 2. Pre-Transformation (Scale & Rotate)
        vec3 q = p;
        q /= anim_scale;
        
        // Basic 2D Rotation on XY plane
        float c = cos(anim_rot);
        float s = sin(anim_rot);
        float nx = c * q.x - s * q.y;
        float ny = s * q.x + c * q.y;
        q.x = nx;
        q.y = ny;

        // 3. Heart Shape Math
        // Formula: (x^2 + y^2 - 1)^3 - x^2 * y^3 = 0
        float x = q.x;
        float y = q.y; // Invert Y if needed, but standard is usually fine here

        float x2 = x * x;
        float y2 = y * y;
        float term1 = x2 + y2 - 1.0;
        float heart_val = (term1 * term1 * term1) - (x2 * (y * y * y));

        // Calculate Displacement Vector (Gradient of the heart field)
        // This pushes pixels towards the heart edge
        vec2 disp;
        disp.x = 3.0 * (term1 * term1) * (2.0 * x) - (2.0 * x * (y * y * y));
        disp.y = 3.0 * (term1 * term1) * (2.0 * y) - (x2 * 3.0 * y2);
        
        // Normalize safely
        float len = length(disp);
        if (len > 0.001) disp /= len;

        // Direction flip based on inside/outside
        if (heart_val < 0.0) {
             disp *= -1.0;
        }

        // 4. Apply
        // We displace X and Y to form the heart
        // Z remains untouched (creating a tube), or we could warp it
        return p + vec3(disp.x, disp.y, 0.0) * anim_str * 0.1;
    }
	
	
	// 17: HYPERBOLIC SINE (Sinh - Clamped)
    // scale    = Zoom
    // strength = Intensity
    if (mode == 17) {
        // 1. Reduce scale sensitivity
        // We multiply by 0.5 internally so the slider isn't so touchy
        vec3 s = p * (scale * 0.5);
        
        // 2. Calculate
        vec3 res = sinh(s) * strength;
        
        // 3. SAFETY CLAMP
        // If the number gets too big, the raymarcher breaks.
        // We clamp it to a safe range (e.g., -50 to 50)
        return clamp(res, -50.0, 50.0);
    }

    // 18: HYPERBOLIC COSINE (Cosh - Clamped)
    // scale    = Zoom
    // strength = Intensity
    if (mode == 18) {
        vec3 s = p * (scale * 0.5);
        
        vec3 res = cosh(s) * strength;
        
        // SAFETY CLAMP
        return clamp(res, -50.0, 50.0);
    }
	
	
	// 7: MIRROR (User Defined Logic)
    // p1       = Rotation (Degrees)
    // extra.r  = Mirror X (if > 0.5)
    // extra.g  = Mirror Y (if > 0.5)
    if (mode == 7) {
        // 1. Rotation (XY Plane)
        float ang = radians(p1);
        float c = cos(ang);
        float s = sin(ang);
        mat2 rot = mat2(vec2(c, -s), vec2(s, c));
        
        vec3 q = p;
        q.xy = rot * q.xy;

        // 2. Mirror Logic
        // We check the boolean flags passed in extra.r/g
        if (extra.r > 0.5) q.x = abs(q.x);
        if (extra.g > 0.5) q.y = abs(q.y);

        return mix(p, q, strength);
    }

    // 8: KALEIDOSCOPE (User Defined Logic)
    // p1       = Rotation
    // p2       = Slices
    if (mode == 8) {
        // 1. Rotation
        float ang_rot = radians(p1);
        float c = cos(ang_rot);
        float s = sin(ang_rot);
        mat2 rot = mat2(vec2(c, -s), vec2(s, c));
        
        vec3 q = p;
        q.xy = rot * q.xy;

        // 2. Kaleidoscope Logic
        float slices = p2;
        
        // Safety check to prevent division by zero
        if (slices >= 1.0) {
            float angle = atan(q.y, q.x);
            float r = length(q.xy);
            float slice_angle = 3.14159 / slices;
            
            // The folding math
            angle = mod(angle, slice_angle * 2.0);
            angle = abs(angle - slice_angle);
            
            q.x = r * cos(angle);
            q.y = r * sin(angle);
        }

        return mix(p, q, strength);
    }
	
	
	// 36: LAZY MEGA (Planetary Lens)
    // scale    = Radius (Amount)
    // strength = Ring Thickness (Space)
    // p1       = Twist
    // p2       = Spin
    // extra.r  = Ring Spin
    // extra.g  = Ring Mode
    // extra.b  = Inside Mode
    // extra.a  = Outside Mode
    // center.x = Shape (0=Sphere, 1=Box)
    if (mode == 36) {
        float radius = max(0.01, scale);
        float thickness = max(0.0, strength);
        float twist = p1;
        float spin = p2;
        float ring_spin = extra.r;
        
        // INTEGER FIX: Add 0.1 safety tolerance for float sliders
        int ring_mode = int(extra.g + 0.1);
        int inside_mode = int(extra.b + 0.1);
        int outside_mode = int(extra.a + 0.1);
        int shape = int(center.x + 0.1);
        
        float soft = 0.05;

        // Shape Logic
        float d = 0.0;
        if (shape == 1) d = max(abs(p.x), max(abs(p.y), abs(p.z))); // Box
        else d = length(p); // Sphere (Default)

        float inner_edge = radius;
        float outer_edge = radius + thickness;

        // Masks
        float mask_inside = 1.0 - smoothstep(inner_edge - soft, inner_edge, d);
        float mask_outside = smoothstep(outer_edge, outer_edge + soft, d);
        float mask_ring = 1.0 - mask_inside - mask_outside;

        vec3 res = vec3(0.0);

        // --- ZONE 1: INSIDE ---
        if (mask_inside > 0.001) {
            vec3 p_in = p;
            
            if (inside_mode == 0) { // Standard Twist
                if (abs(twist) > 0.01) {
                    // Increased multiplier from 5.0 to 10.0 for visibility
                    float angle = spin + twist * (inner_edge - d) * 10.0;
                    float c = cos(angle); float s = sin(angle);
                    p_in.xy = mat2(vec2(c,-s), vec2(s,c)) * p_in.xy;
                }
            } 
            else if (inside_mode == 1) { // Travis (Warp)
                p_in += sin(p.zxy * 10.0 + spin) * 0.1 * twist;
            }
            
            res += p_in * mask_inside;
        }

        // --- ZONE 2: RING ---
        if (mask_ring > 0.001) {
            vec3 p_ring = p;
            
            if (abs(ring_spin) > 0.01) {
                float c = cos(ring_spin); float s = sin(ring_spin);
                p_ring.xy = mat2(vec2(c,-s), vec2(s,c)) * p_ring.xy;
            }

            bool delete_pixel = false;
            
            if (ring_mode == 0) delete_pixel = true; // Empty
            else if (ring_mode == 1) { // Solid
                 p_ring *= (inner_edge / max(0.001, d)); 
            }
            else if (ring_mode == 2) { // Stripes
                 if (sin(d * 50.0) > 0.0) delete_pixel = true;
            }
            else if (ring_mode == 3) { // Checkers
                 float a = atan(p_ring.y, p_ring.x);
                 float b = atan(p_ring.z, length(p_ring.xy));
                 if (sin(d * 20.0) * sin(a * 10.0 + b * 10.0) > 0.0) delete_pixel = true;
            }
            else if (ring_mode == 4) { // Dots
                 if (length(fract(p_ring * 10.0) - 0.5) < 0.3) delete_pixel = true;
            }
            else if (ring_mode == 5) { // Plasma
                 float v = sin(p_ring.x * 20.0) + sin(p_ring.y * 20.0) + sin(p_ring.z * 20.0);
                 if (v > 0.0) delete_pixel = true;
            }
            else if (ring_mode == 6) { // Spiral
                 float a = atan(p_ring.y, p_ring.x) + p_ring.z;
                 if (sin(a * 10.0 + d * 40.0) > 0.0) delete_pixel = true;
            }

            if (delete_pixel) res += p_ring * 1000.0 * mask_ring;
            else res += p_ring * mask_ring;
        }

        // --- ZONE 3: OUTSIDE ---
        if (mask_outside > 0.001) {
            vec3 p_out = p;
            
            if (outside_mode == 0) { // Inverse (Lens)
                float r_new = radius * (1.0 + thickness / max(0.001, d));
                p_out = p * (r_new / d);
            }
            else if (outside_mode == 1) { // Travis (Warp)
                p_out += cos(p.zxy * 5.0 + spin) * 0.1;
            }
            
            res += p_out * mask_outside;
        }

        return res;
    }
	
	// 35: POPCORN (Trig Distortion)
    // scale    = Zoom (popcorn_scale)
    // strength = Distortion Amount (popcorn_strength)
    // p1       = Density (popcorn_density)
    // 35: POPCORN (Fixed Center & Scale)
    if (mode == 35) {
        float s = (abs(scale) < 0.001) ? 1.0 : scale;
        float dens = (abs(p1) < 0.001) ? 3.0 : p1;
        
        // 1. Apply Center Offset FIRST (Pan the texture)
        vec3 q = p - vec3(center.x, center.y, 0.0);
        
        // 2. Apply Scale
        q /= s;
        
        // 3. Popcorn Math
        vec3 shift;
        shift.x = strength * sin(q.y + tan(dens * q.y));
        shift.y = strength * sin(q.z + tan(dens * q.z));
        shift.z = strength * sin(q.x + tan(dens * q.x));
        
        q -= shift;
        
        // 4. Return (Restore scale, but keep offset shift)
        return q * s; 
    }
	
	
    // 38: Nebula (TRUE 3D UPGRADE)
    if (mode == 38) { 
        float detail = (p1 < 0.001 ? 1.0 : p1); 
        float sw = p2 * 2.0; 
        vec3 p_warp = p;
        
        // Rotate XY (Standard)
        p_warp.xy *= rot2D(sw); 
        // NEW: Rotate YZ (3D Twist)
        p_warp.yz *= rot2D(sw * 0.5);
        
        // Sine distortion applied to all 3 axes using mixed coordinates
        return p + vec3(
            sin(p_warp.y * scale * detail + t), 
            cos(p_warp.z * scale * detail + t), 
            sin(p_warp.x * scale * detail + t)
        ) * strength * 0.2; 
    }

	// --- REP-TILES GROUP (IDs 19-31) ---
    // Adapts 2D Tiling logic to 3D Space (Extruded along Z)
    if (mode >= 19 && mode <= 31) {
        
        // 1. Setup Parameters
        // Scale affects the tile size
        float anim_scale = max(0.01, scale); 
        
        // Strength controls Rotation (just like in 2D)
        float anim_rot = strength; 

        // 2. Rotate XY Plane
        float ang = radians(anim_rot);
        float c = cos(ang);
        float s = sin(ang);
        mat2 rot = mat2(vec2(c, -s), vec2(s, c));
        
        // Isolate XY for processing
        vec2 q = p.xy;
        q = rot * q;

        // 3. Apply Shape Logic
        
        // ID 19: L-Tromino
        if (mode == 19) {
            q *= 2.0 * anim_scale;
            if (q.x >= 0.0 && q.y >= 0.0) { q = vec2(q.y, -q.x) + vec2(-1.0, 1.0); }
            else if (q.x < 0.0 && q.y >= 0.0) { q = q + vec2(1.0, -1.0); }
            else if (q.x < 0.0 && q.y < 0.0) { q = q + vec2(1.0, 1.0); }
            else { q = vec2(-q.y, q.x) + vec2(-1.0, -1.0); }
            q /= 2.0;
        }
        
        // ID 20: Custom 2x2
        else if (mode == 20) {
            vec2 t = q * 2.0;
            // Placeholder for custom corner logic if you port the 
            // 'apply_quad_transform' function to this shader later.
            q = (t / 2.0) * anim_scale;
        }

        // ID 21: Sphinx
        else if (mode == 21) {
            q *= 2.0 * anim_scale;
            mat2 R90 = mat2(vec2(0.0, 1.0), vec2(-1.0, 0.0));
            if (q.x + q.y > 0.0) {
                if (q.x - q.y > 0.0) { q = R90 * q + vec2(0.0, 1.0); }
                else { q = q + vec2(-1.0, 0.0); }
            } else {
                if (q.x - q.y > 0.0) { q = q + vec2(1.0, 0.0); }
                else { q = R90 * q + vec2(0.0, -1.0); }
            }
            q /= 2.0;
        }

        // ID 22: T-Tetromino
        else if (mode == 22) {
            q *= 2.0 * anim_scale;
            mat2 R90 = mat2(vec2(0.0, 1.0), vec2(-1.0, 0.0));
            if (q.x >= 0.0 && q.y >= 0.0) { q = R90 * q + vec2(0.0, 1.0); }
            else if (q.x < 0.0 && q.y >= 0.0) { q = R90 * q + vec2(0.0, -1.0); }
            else if (q.x < 0.0 && q.y < 0.0) { q = -q; }
            else { q = q + vec2(-1.0, 1.0); }
            q /= 2.0;
        }

        // ID 23: Sierpinski Carpet
        else if (mode == 23) {
            q = (q * anim_scale + 0.5) * 3.0;
            vec2 i = floor(q);
            if (i.x == 1.0 && i.y == 1.0) { return p; } // Gap
            q = fract(q) - 0.5;
        }
        
        // ID 24: Gosper Island
        else if (mode == 24) {
             // Basic scaling without the hex helper for now
             q *= anim_scale; 
        }

        // ID 25: Carpet Corners
        else if (mode == 25) {
            q = (q * anim_scale + 0.5) * 3.0;
            vec2 i = floor(q);
            if ( (i.x == 0.0 || i.x == 2.0) && (i.y == 0.0 || i.y == 2.0) ) { 
                q = fract(q) - 0.5; 
            } else {
                return p;
            }
        }

        // ID 26: Carpet Cross
        else if (mode == 26) {
            q = (q * anim_scale + 0.5) * 3.0;
            vec2 i = floor(q);
            if (i.x == 1.0 || i.y == 1.0) { 
                q = fract(q) - 0.5; 
            } else {
                return p;
            }
        }

        // ID 27: Pentagonal
        else if (mode == 27) {
            float s = 1.618034 * anim_scale;
            vec2 c1=vec2(0.0,0.5); vec2 c2=vec2(0.4755,0.1545); vec2 c3=vec2(0.2939,-0.4045);
            vec2 c4=vec2(-0.2939,-0.4045); vec2 c5=vec2(-0.4755,0.1545);
            float d1=distance(q,c1); float d2=distance(q,c2); float d3=distance(q,c3);
            float d4=distance(q,c4); float d5=distance(q,c5);
            vec2 closest=c1; float min_d=d1;
            if(d2<min_d){min_d=d2;closest=c2;} if(d3<min_d){min_d=d3;closest=c3;}
            if(d4<min_d){min_d=d4;closest=c4;} if(d5<min_d){closest=c5;}
            q = closest + (q - closest) / s;
        }

        // ID 28: Diagonal Carpet
        else if (mode == 28) {
            q = (q * anim_scale + 0.5) * 3.0;
            vec2 i = floor(q);
            if ( (i.x == 1.0 && i.y != 1.0) || (i.y == 1.0 && i.x != 1.0) ) { 
               return p;
            }
            q = fract(q) - 0.5;
        }
        
        // ID 29: Penrose Star
        else if (mode == 29) {
            float s = 1.8 * anim_scale;
            vec2 c1=vec2(0.0,0.5); vec2 c2=vec2(0.4755,0.1545); vec2 c3=vec2(0.2939,-0.4045);
            vec2 c4=vec2(-0.2939,-0.4045); vec2 c5=vec2(-0.4755,0.1545);
            float d1=distance(q,c1); float d2=distance(q,c2); float d3=distance(q,c3);
            float d4=distance(q,c4); float d5=distance(q,c5);
            vec2 closest=c1; float min_d=d1;
            if(d2<min_d){min_d=d2;closest=c2;} if(d3<min_d){min_d=d3;closest=c3;}
            if(d4<min_d){min_d=d4;closest=c4;} if(d5<min_d){closest=c5;}
            q = closest + (q - closest) / s;
        }

        // ID 30: Hex Tile
        else if (mode == 30) {
            q *= 3.0 * anim_scale; 
        }

        // ID 31: Twindragon
        else if (mode == 31) {
            q *= 2.0 * anim_scale;
            mat2 R90 = mat2(vec2(0.0, 1.0), vec2(-1.0, 0.0));
            if (q.x < 0.0) { q = R90 * q + vec2(0.0, 1.0); }
            else { q = q + vec2(-1.0, 0.0); }
            q /= 2.0;
        }
        
        // 4. Recombine and Return
        // We modify XY, keep Z intact
        return vec3(q.x, q.y, p.z);
    }



    // 41: Constructivist
    if (mode == 41) {
        float density = max(1.0, p1); 
        vec3 ip = floor(p * density);
        vec3 fp = fract(p * density) - 0.5;
        float seed_shift = floor(t * 5.0); 
        float rnd = fract(sin(dot(ip + seed_shift, vec3(12.9898, 78.233, 54.632))) * 43758.5453);
        if (rnd > (1.0 - strength * 0.5)) return p * 0.9; 
        float gap = 1.0;
        if (p2 > 0.1) gap = 1.0 - (p2 * 0.1); 
        return (ip + 0.5 + (fp * gap)) / density;
    }

    // 43: Portal
    if (mode == 43) {
        vec3 p_centered = p - vec3(center.x, center.y, 0.0);
        float r = length(p_centered.xy);
        float a = atan(p_centered.y, p_centered.x);
        float shift_x = p1 + t;
        float shift_y = p2 + t;
        float z_warp = p_centered.z + sin(r * scale + shift_x + shift_y) * strength;
        return vec3(r * cos(a), r * sin(a), z_warp) + vec3(center.x, center.y, 0.0);
    }

    // 44: Janus
    if (mode == 44) {
        vec3 p_centered = p - vec3(center.x, center.y, 0.0);
        float r = length(p_centered.xy);
        float a = atan(p_centered.y, p_centered.x);
        float zoom = max(0.1, p2); 
        vec3 q = vec3(log(r) * scale * zoom, a + (p1 * 3.14) + t, p_centered.z);
        return mix(p_centered, q, strength) + vec3(center.x, center.y, 0.0);
    }

    // 46/50: MOBIQ
    if (mode == 46 || mode == 50) {
        // Create copies of the Quaternions so we can animate them
        vec4 anim_qA = qA;
        vec4 anim_qC = qC;
        
        // Inject Time (t) into the Real/Time component (.x)
        // This spins the 4D rotation continuously
        anim_qA.x += t; 
        anim_qC.x += t;

        // Use the animated quaternions
        vec3 q = mobiq(p, anim_qA, qB, anim_qC, qD, 1.0);
        return mix(p, q, strength);
    }

    return p;
}

// --- SDF GEOMETRY ---
float map(vec3 p) {
    float s = 1.0;
    float scale_factor = max(1.2, pre_scale); 
    vec3 offset = vec3(pre_translate.x, pre_translate.y, pre_translate.x);

    for (int i = 0; i < iterations; i++) {
        if (mirror_x) {
            p = abs(p + fold_shift) - fold_shift;
        }
        
        // --- KALEIDOSCOPE LOGIC (With Auto-Centering) ---
        if (kaleidoscope_on) {
            if (kaleidoscope_3d) {
                
                // ZONE 1: DODECAHEDRON (Slices 1-6)
                // (Usually looks good by default, no rotation needed)
                if (kaleidoscope_slices <= 6.0) {
                    int fold_iter = int(clamp(kaleidoscope_slices, 1.0, 6.0));
                    for(int k=0; k<fold_iter; k++) {
                         fold_dodeca(p);
                    }
                }
                // ZONE 2: OCTAHEDRON (Slices 7-13)
                else if (kaleidoscope_slices <= 13.0) {
                    // FIX: Rotate view 45 degrees (0.78 rad) so the shape faces camera
                    p.xz *= rot2D(0.785); 
                    p.xy *= rot2D(0.6); // Slight tilt up
                    
                    int fold_iter = int(clamp(kaleidoscope_slices - 6.0, 1.0, 7.0));
                    for(int k=0; k<fold_iter; k++) {
                         fold_octa(p);
                         p.xy *= rot2D(0.3); 
                         p.xz *= rot2D(0.1);
                    }
                }
                // ZONE 3: ICOSAHEDRON (Slices 14-20)
                else {
                    // FIX: Rotate view to align with Golden Ratio vector
                    p.yz *= rot2D(-0.5); 
                    p.xz *= rot2D(0.4);
                    
                    int fold_iter = int(clamp(kaleidoscope_slices - 13.0, 1.0, 7.0));
                    for(int k=0; k<fold_iter; k++) {
                         fold_icosa(p);
                         p.xy *= rot2D(0.2);
                    }
                }
                
            } else {
                // 2D Pizza Slices
                if (kaleidoscope_slices > 0.1) {
                    float angle = 3.14159 / kaleidoscope_slices;
                    float r = length(p.xy);
                    float a = atan(p.y, p.x);
                    a = mod(a, 2.0 * angle) - angle; 
                    a = abs(a);
                    p.xy = vec2(cos(a), sin(a)) * r;
                }
            }
        }

        // Apply Variations
        vec3 p_a = apply_variation(p, variation_mode_a, var_a_scale, var_a_strength, var_a_speed, var_a_param1, var_a_param2, var_a_center, var_a_extra, mobiq_a_A, mobiq_a_B, mobiq_a_C, mobiq_a_D);
        vec3 p_b = apply_variation(p, variation_mode_b, var_b_scale, var_b_strength, var_b_speed, var_b_param1, var_b_param2, var_b_center, var_b_extra, mobiq_b_A, mobiq_b_B, mobiq_b_C, mobiq_b_D);
        
        vec3 mixed_p = mix(p_a, p_b, variation_mix);
        p = mix(p, mixed_p, 0.2);

        // Plane Rotations
        if (abs(plane_rot.x) > 0.01) p.yz *= rot2D(radians(plane_rot.x));
        if (abs(plane_rot.y) > 0.01) p.xz *= rot2D(radians(plane_rot.y));
        if (abs(plane_rot.z) > 0.01) p.xy *= rot2D(radians(plane_rot.z));
		
		if (abs(custom_rot_angle) > 0.01) {
            // Use a default axis (Y) if the user sets 0,0,0 to prevent NaN errors
            vec3 axis = length(custom_rot_axis) < 0.001 ? vec3(0.0, 1.0, 0.0) : custom_rot_axis;
            p = rotAxis(p, axis, radians(custom_rot_angle));
        }

        p -= offset;
        p *= scale_factor;
        s *= scale_factor;
    }
    
    vec3 d = abs(p) - vec3(1.0);
    return 0.8 * (min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0))) / s;
}

vec3 get_triplanar_color(vec3 p, vec3 n) {
    vec3 p_s = p * texture_scale;
    vec3 w = abs(n);
    w /= (w.x + w.y + w.z);
    vec3 col_x = texture(fractal_texture, p_s.yz * 0.5 + 0.5).rgb;
    vec3 col_y = texture(fractal_texture, p_s.xz * 0.5 + 0.5).rgb;
    vec3 col_z = texture(fractal_texture, p_s.xy * 0.5 + 0.5).rgb;
    return col_x * w.x + col_y * w.y + col_z * w.z;
}

vec3 calc_normal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
    ));
}

vec3 apply_color_grading(vec3 color) {
	color = color * brightness;
	color = (color - 0.5) * contrast + 0.5;
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(gray), color, saturation);
	return color;
}

void vertex() {
    model_view_inv = inverse(MODELVIEW_MATRIX);
    camera_origin = (model_view_inv * vec4(0, 0, 0, 1)).xyz;
}


// --- ORBIT TRAP COLORING ---
vec3 get_orbit_color(vec3 p) {
    vec3 orbit_p = p;
    float scale_factor = max(1.2, pre_scale); 
    vec3 offset = vec3(pre_translate.x, pre_translate.y, pre_translate.x);
    
    // "Trap" variables to store the geometry info
    // We start with a huge number and find the smallest distance to center
    float min_dist = 1000.0;
    
    for (int i = 0; i < iterations; i++) {
        if (mirror_x) {
            orbit_p = abs(orbit_p + fold_shift) - fold_shift;
        }

        // --- KALEIDOSCOPE LOGIC (Must match Map) ---
        if (kaleidoscope_on) {
            if (kaleidoscope_3d) {
                if (kaleidoscope_slices <= 6.0) {
                    int fold_iter = int(clamp(kaleidoscope_slices, 1.0, 6.0));
                    for(int k=0; k<fold_iter; k++) fold_dodeca(orbit_p);
                }
                else if (kaleidoscope_slices <= 13.0) {
                    orbit_p.xz *= rot2D(0.785); orbit_p.xy *= rot2D(0.6);
                    int fold_iter = int(clamp(kaleidoscope_slices - 6.0, 1.0, 7.0));
                    for(int k=0; k<fold_iter; k++) {
                         fold_octa(orbit_p);
                         orbit_p.xy *= rot2D(0.3); orbit_p.xz *= rot2D(0.1);
                    }
                }
                else {
                    orbit_p.yz *= rot2D(-0.5); orbit_p.xz *= rot2D(0.4);
                    int fold_iter = int(clamp(kaleidoscope_slices - 13.0, 1.0, 7.0));
                    for(int k=0; k<fold_iter; k++) {
                         fold_icosa(orbit_p);
                         orbit_p.xy *= rot2D(0.2);
                    }
                }
            } else {
                 if (kaleidoscope_slices > 0.1) {
                    float angle = 3.14159 / kaleidoscope_slices;
                    float r = length(orbit_p.xy);
                    float a = atan(orbit_p.y, orbit_p.x);
                    a = mod(a, 2.0 * angle) - angle; 
                    a = abs(a);
                    orbit_p.xy = vec2(cos(a), sin(a)) * r;
                }
            }
        }

        // Apply Variations
        vec3 p_a = apply_variation(orbit_p, variation_mode_a, var_a_scale, var_a_strength, var_a_speed, var_a_param1, var_a_param2, var_a_center, var_a_extra, mobiq_a_A, mobiq_a_B, mobiq_a_C, mobiq_a_D);
        vec3 p_b = apply_variation(orbit_p, variation_mode_b, var_b_scale, var_b_strength, var_b_speed, var_b_param1, var_b_param2, var_b_center, var_b_extra, mobiq_b_A, mobiq_b_B, mobiq_b_C, mobiq_b_D);
        vec3 mixed_p = mix(p_a, p_b, variation_mix);
        orbit_p = mix(orbit_p, mixed_p, 0.2);

        // Plane Rotations
        if (abs(plane_rot.x) > 0.01) orbit_p.yz *= rot2D(radians(plane_rot.x));
        if (abs(plane_rot.y) > 0.01) orbit_p.xz *= rot2D(radians(plane_rot.y));
        if (abs(plane_rot.z) > 0.01) orbit_p.xy *= rot2D(radians(plane_rot.z));

        orbit_p -= offset;
        orbit_p *= scale_factor;
        
        // --- TRAP CAPTURE ---
        // This measures "How close is the point to the center right now?"
        // Different shapes give different colors.
// --- TRAP CAPTURE (NEW SHAPES) ---
        float d = 1000.0;
        
        if (trap_mode == 0) {
            // SPHERE (Distance to 0,0,0)
            d = length(orbit_p);
        } 
        else if (trap_mode == 1) {
            // CYLINDER (Distance to Z-axis - Default)
            d = length(orbit_p.xy);
        } 
        else if (trap_mode == 2) {
            // PLANE (Distance to Y-plane - Glowing floor/ceiling)
            d = abs(orbit_p.y);
        } 
        else if (trap_mode == 3) {
            // CROSS (Distance to nearest Axis)
            // Creates a grid-like structure
            d = min(length(orbit_p.xy), min(length(orbit_p.yz), length(orbit_p.xz)));
        }
        
        min_dist = min(min_dist, d);    }
    
    // Calculate Color Factor
    // We map the trap value to a 0.0 - 1.0 range
    float t = min_dist * orbit_contrast + orbit_offset;
    t = clamp(t, 0.0, 1.0);
    
    // Mix the two chosen colors
    return mix(orbit_color_1, orbit_color_2, t);
}




void fragment() {
    vec3 ro = camera_origin;
    vec3 obj_pos = (model_view_inv * vec4(VERTEX, 1.0)).xyz;
    vec3 rd = normalize(obj_pos - ro);

    float t_near, t_far;
    if (!hit_box(ro, rd, vec3(box_size), t_near, t_far)) {
        discard; 
    }
    
    float t = max(0.0, t_near); 
    float d = 0.0;
    bool hit = false;
    int steps = 0;

    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * t;
        d = map(p); 
        
        if(d < SURF_DIST) { hit = true; steps=i; break; }
        t += d * step_speed; 
        if(t > t_far) break; 
    }

    if(hit) {
        vec3 p = ro + rd * t;
        vec3 n = calc_normal(p);
        
        vec3 L = normalize(light_direction);
        float diff = max(dot(n, L), 0.0);
        float spec = pow(max(dot(reflect(-L, n), -rd), 0.0), 16.0);

        vec3 albedo;
        
        // COLOR MODE SWITCH
        if (color_mode == 0) {
            // Mode 0: Physical Texture
            vec3 frac_col = get_triplanar_color(p, n);
            albedo = mix(vec3(0.9), frac_col, texture_intensity);
        } else {
            // Mode 1: Math Orbit Trap
            albedo = get_orbit_color(p);
        }
        float ao = clamp(1.0 - (float(steps) / float(MAX_STEPS)), 0.0, 1.0);

        vec3 final_col = albedo * (diff * light_energy_val * light_color_val + vec3(0.2));
        final_col += (light_color_val * spec * 0.5);
        final_col *= ao;
        
        ALBEDO = apply_color_grading(final_col);
    } else {
        discard; 
    }
}