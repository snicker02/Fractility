// fractal_globals.gdshaderinc
// Global shader utilities and parameters shared across all fractal shaders
// Note: SCREEN_TEXTURE must be declared in each individual shader, not here

// === RENDERING PARAMETERS ===
group_uniforms Global_Rendering;
uniform float Reflectivity : hint_range(0.0, 1.0) = 0.0;
uniform float FogDensity : hint_range(0.0, 0.2) = 0.0;
uniform int PaletteType : hint_range(0, 4) = 0;
uniform float ColorCycle : hint_range(0.0, 10.0) = 0.15;
uniform float ColorOffset : hint_range(0.0, 1.0) = 0.0;
uniform float OffsetW : hint_range(-5.0, 5.0) = 0.0;

// === SYMMETRY FOLDING ===
group_uniforms Symmetry_Folding;
// Absolute value folds (mirror across origin)
uniform bool F_absX = false;
uniform bool F_absY = false;
uniform bool F_absZ = false;

// Plane symmetry swaps
uniform bool F_X = false;
uniform bool F_Y = false;
uniform bool F_Z = false;

// Symmetry strength (0.5 = full symmetry, 0.0 = no effect)
uniform vec3 SymmetryStrength = vec3(0.5);
// Offset applied before/after folding
uniform vec3 F_offset = vec3(0.0);

uniform float KIFS_Angle_X : hint_range(-3.14, 3.14) = 0.0;
uniform float KIFS_Angle_Y : hint_range(-3.14, 3.14) = 0.0;
uniform float KIFS_Angle_Z : hint_range(-3.14, 3.14) = 0.0;
uniform vec3 KIFS_Axes = vec3(1.0, 1.0, 1.0); // The mask for X, Y, Z planes





// Custom Gradient Colors
uniform vec3 Color1 : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 Color2 : source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 Color3 : source_color = vec3(0.0, 0.0, 1.0);

uniform float Saturation : hint_range(0.0, 2.0) = 1.0;
uniform float Contrast : hint_range(0.0, 2.0) = 1.0;
uniform float Brightness : hint_range(0.0, 2.0) = 1.0;

// === GLOBAL COLORING ===
group_uniforms Global_Coloring;

// === AMAZING SURF ===
group_uniforms Amazing_Surf;
uniform bool EnableSurf = false;
uniform float SurfScale : hint_range(0.0, 20.0) = 0.0;
uniform float SurfStrength : hint_range(0.0, 2.0) = 0.0;
uniform int SurfOctaves : hint_range(1, 8) = 1;
uniform float SurfRoughness : hint_range(0.0, 1.0) = 0.0;
uniform float SurfSpeed : hint_range(0.0, 2.0) = 0.0; 
uniform bool TorusEnabled = false;
uniform float TorusRadius : hint_range(0.1, 10.0) = 2.5;
uniform float TorusTube : hint_range(0.01, 2.0) = 0.4;
uniform vec3 TorusOffset = vec3(0.0, 0.0, 0.0);
uniform float GrainIntensity : hint_range(0.0, 1.0) = 0.0;
uniform float TentacleCount : hint_range(0.0, 50.0) = 0.0;
uniform float TentacleLength : hint_range(0.0, 2.0) = 0.0;
uniform float TentacleTwist : hint_range(-5.0, 5.0) = 0.0;
group_uniforms Global_Shapes;
uniform int ShapeType : hint_range(0, 1) = 0; // 0 = Torus, 1 = Cylinder
uniform bool ShapeEnabled = false;
uniform float ShapeRadius : hint_range(0.1, 5.0) = 1.0;
uniform float ShapeThickness : hint_range(0.01, 2.0) = 0.4;
uniform float ShapeBend : hint_range(0.0, 2.0) = 0.0;
uniform vec3 ShapeOffset = vec3(0.0);





// Global Helper
float sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}


// Helper: Capped Cylinder
// Standard Y-Axis Cylinder
float sdCylinder(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

// Your preferred Z-Axis Cylinder for "Amazing Surf"
float sdCylinderZ(vec3 p, float h, float r) {
    vec2 d = abs(vec2(length(p.xy), p.z)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}


vec3 applyUBendZ(vec3 p, float k) {
    if (abs(k) < 0.001) return p;
    // We bend the XY plane based on the square of Z to create the "U" arc
    float bend_factor = k * p.z * p.z;
    return vec3(p.x, p.y + bend_factor, p.z);
}



vec3 palette(float t) {
    if (PaletteType == 4) { // This MUST match the Index in your PaletteSelector
        float factor = fract(t + ColorOffset);
        if (factor < 0.5) return mix(Color1, Color2, factor * 2.0);
        return mix(Color2, Color3, (factor - 0.5) * 2.0);
    }
    
    // Existing palettes (0, 1, 2, 3)
    vec3 a, b, c, d;
    if (PaletteType == 0) { a = vec3(0.5); b = vec3(0.5); c = vec3(1.0); d = vec3(0.0, 0.33, 0.67); }
    else if (PaletteType == 1) { a = vec3(0.5); b = vec3(0.5); c = vec3(0.5); d = vec3(0.5, 0.2, 0.25); }
    else if (PaletteType == 2) { a = vec3(0.5); b = vec3(0.5); c = vec3(0.8, 0.5, 0.4); d = vec3(0.2, 0.4, 0.2); }
    else if (PaletteType == 3) { a = vec3(0.8, 0.5, 0.4); b = vec3(0.2, 0.4, 0.2); c = vec3(2.0, 1.0, 1.0); d = vec3(0.0, 0.25, 0.25); }
    
    return a + b * cos(6.28318 * (c * t + d + ColorOffset));
}


// === SYMMETRY FOLDING FUNCTION ===
// Applies various geometric symmetries to create complex fractal patterns
// This function modifies the input point 'p' in place
float apply_symmetry(inout vec3 p) {
	// Apply offset BEFORE any folding
	p += F_offset;
	
	// Step 1: Absolute Value Folds (mirror across coordinate planes)
	if (F_absX) p.x = abs(p.x);
	if (F_absY) p.y = abs(p.y);
	if (F_absZ) p.z = abs(p.z);
	
	// Step 2: Plane Symmetry Folding
	float t = 0.0;
	
	if (F_X) {
		t = p.x - p.z;
		t = SymmetryStrength.x * (t - abs(t));
		p.x = p.x - t;
		p.z = p.z + t;
	}
	
	if (F_Y) {
		t = p.x - p.y;
		t = SymmetryStrength.y * (t - abs(t));
		p.x = p.x - t;
		p.y = p.y + t;
	}
	
	if (F_Z) {
		t = p.y - p.z;
		t = SymmetryStrength.z * (t - abs(t));
		p.y = p.y - t;
		p.z = p.z + t;
	}
	
	// Remove offset after folding
	p -= F_offset;
	
	return 1.0;
}





// === UTILITY FUNCTIONS ===

// Smooth minimum function for distance field blending
float smin(float a, float b, float k) {
	float h = max(k - abs(a - b), 0.0) / k;
	return min(a, b) - h * h * k * 0.25;
}

// Rotation matrix helper (2D rotation)
mat2 rot2D(float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return mat2(vec2(c, -s), vec2(s, c));
}

// Hash function for procedural variation
float hash(vec3 p) {
	p = fract(p * vec3(443.897, 441.423, 437.195));
	p += dot(p, p.yzx + 19.19);
	return fract((p.x + p.y) * p.z);
}


// 3D noise function for Amazing Surf
float noise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // Smoothstep
    
    float n = i.x + i.y * 157.0 + 113.0 * i.z;
    return mix(
        mix(mix(hash(vec3(n + 0.0)), hash(vec3(n + 1.0)), f.x),
            mix(hash(vec3(n + 157.0)), hash(vec3(n + 158.0)), f.x), f.y),
        mix(mix(hash(vec3(n + 113.0)), hash(vec3(n + 114.0)), f.x),
            mix(hash(vec3(n + 270.0)), hash(vec3(n + 271.0)), f.x), f.y),
        f.z
    );
}

// Fractal Brownian Motion for layered detail
float fbm(vec3 p, int octaves, float roughness) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise3D(p * frequency);
        frequency *= 2.0;
        amplitude *= roughness;
    }
    
    return value;
}



vec3 apply_art_controls(vec3 color) {
    // Apply Brightness
    color *= Brightness;
    
    // Apply Contrast (centered at 0.5)
    color = (color - 0.5) * Contrast + 0.5;
    
    // Apply Saturation using standard luminance weights
    float luma = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luma), color, Saturation);
    
    return clamp(color, 0.0, 1.0);
}

// KIFS Rotation Logic
void kifs_fold(inout vec4 p, float angle_x, float angle_y, float angle_z) {
    // XY plane rotation
    if (abs(angle_x) > 0.001) {
        float s = sin(angle_x);
        float c = cos(angle_x);
        mat2 rot = mat2(vec2(c, -s), vec2(s, c));
        p.xy = rot * p.xy;
        p.xy = abs(p.xy);
    }
    
    // YZ plane rotation
    if (abs(angle_y) > 0.001) {
        float s = sin(angle_y);
        float c = cos(angle_y);
        mat2 rot = mat2(vec2(c, -s), vec2(s, c));
        p.yz = rot * p.yz;
        p.yz = abs(p.yz);
    }
    
    // XZ plane rotation
    if (abs(angle_z) > 0.001) {
        float s = sin(angle_z);
        float c = cos(angle_z);
        mat2 rot = mat2(vec2(c, -s), vec2(s, c));
        p.xz = rot * p.xz;
        p.xz = abs(p.xz);
    }
}
