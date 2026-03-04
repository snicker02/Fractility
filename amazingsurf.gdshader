shader_type spatial;

#include "res://fractal_globals.gdshaderinc"
uniform float Time;
render_mode unshaded, cull_disabled;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

group_uniforms AmazingSurf_Main;
uniform float Power : hint_range(0.0, 16.0) = 0.0;
uniform float Scale : hint_range(-5.0, 5.0) = 2.0;
uniform int Iterations : hint_range(1, 150) = 6;
uniform float Bailout : hint_range(1.0, 100.0) = 4.0;
uniform int MaxSteps : hint_range(32, 512) = 64;
uniform float Detail : hint_range(-5.0, -1.0) = -1;
uniform vec2 SliceOffset = vec2(0.0, 0.0);
uniform float ScaleVary : hint_range(-2.0, 2.0) = 0.0;
uniform vec3 EulerRotation = vec3(0.0, 0.0, 0.0); // x=alpha, y=beta, z=gamma
uniform int KIFS_Axis : hint_range(0, 2) = 0; // 0: XY, 1: XZ, 2: YZ
uniform float KIFS_Sides : hint_range(3.0, 24.0) = 6.0;
uniform float KIFS_Twist : hint_range(-3.14, 3.14) = 0.0;
// NEW: Rendering method selector
uniform int RenderingMethod : hint_range(0, 2) = 0;  // 0=Raymarch, 1=Slice, 2=Volume

// NEW: Slice rendering parameters
uniform float SliceW : hint_range(-5.0, 5.0) = 0.0;
uniform bool AnimateSliceW = false;
uniform float SliceWSpeed : hint_range(0.0, 1.0) = 0.1;
uniform float SliceZoom : hint_range(0.5, 5.0) = 2.0;

// NEW: Volume rendering parameters
uniform int VolumeSteps : hint_range(8, 128) = 32;
uniform float VolumeDensity : hint_range(0.1, 5.0) = 1.0;
uniform float VolumeBrightness : hint_range(0.1, 5.0) = 2.0;
uniform float VolumeStartDistance : hint_range(0.1, 5.0) = 0.5;
uniform float VolumeEndDistance : hint_range(1.0, 20.0) = 8.0;


uniform int DEMethod : hint_range(0, 2) = 0;  // 0=Standard, 1=Box, 2=Hybrid
uniform float DEMultiplier : hint_range(0.1, 3.0) = 1.0;

group_uniforms Folding_System;
// Enable 5 independent fold slots
uniform bool FoldSlot1Enabled = true;
uniform bool FoldSlot2Enabled = false;
uniform bool FoldSlot3Enabled = false;
uniform bool FoldSlot4Enabled = false;
uniform bool FoldSlot5Enabled = false;

uniform bool EnableZAxisFold = false;
uniform bool EnableWAxisFold = false;

// Fold type selection (0-5 for each slot) - UPDATED to include box fold
uniform int FoldType1 : hint_range(0, 14) = 0;
uniform int FoldType2 : hint_range(0, 14) = 1;
uniform int FoldType3 : hint_range(0, 14) = 2;
uniform int FoldType4 : hint_range(0, 14) = 3;
uniform int FoldType5 : hint_range(0, 14) = 4;

// Fold parameters
uniform vec4 FoldLimit4D = vec4(1.0, 1.0, 1.0, 1.0);
uniform float FoldingValue : hint_range(0.1, 5.0) = 2.0;
uniform float Offset2 : hint_range(-5.0, 5.0) = 0.0;

uniform float SierpinskiScale : hint_range(1.0, 5.0) = 2.0;
uniform float RippleFrequency : hint_range(0.1, 10.0) = 3.0;
uniform float RippleAmplitude : hint_range(0.0, 2.0) = 0.5;

group_uniforms Sphere_Fold;
uniform bool SphereFoldEnabled = false;
uniform float MinRadius : hint_range(0.0, 2.0) = 0.5;
uniform float FixedRadius : hint_range(0.1, 3.0) = 1.0;
uniform bool ForceCylinderFold = false;
uniform float CylinderWeight : hint_range(0.0, 1.0) = 1.0;

group_uniforms Transforms;
uniform vec3 PreOffset = vec3(0.0, 0.0, 0.0);
uniform vec3 PostOffset = vec3(0.0, 0.0, 0.0);
uniform float RotationAngle : hint_range(0.0, 6.28) = 0.0;

// 4D Rotation options (NEW!)
uniform float RotationXW : hint_range(0.0, 6.28) = 0.0;
uniform float RotationYW : hint_range(0.0, 6.28) = 0.0;
uniform float RotationZW : hint_range(0.0, 6.28) = 0.0;








group_uniforms Rendering;

group_uniforms Fractal_Modes;
uniform bool JuliaMode = false;
uniform vec3 JuliaSeed = vec3(0.0, 0.0, 0.0);

uniform float WarpStrength; 
uniform float WarpFrequency;
uniform float RibbonTwist;


group_uniforms KIFS_Symmetry;


group_uniforms Torus_Settings;





void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

// Rotation helper
vec4 rotateZ(vec4 v, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec4(
		v.x * c - v.y * s,
		v.x * s + v.y * c,
		v.z,
		v.w
	);
}

// Apply one fold based on type
// Apply one fold based on type (NOW WITH 12 FOLD TYPES!)
void applyFold(inout vec4 z, int foldType, inout vec4 oldZ, bool includeZ, bool includeW, inout float dr) {
	switch(foldType) {
		case 0: // TGlad fold (Now with Offset2 shift)
        z.xyz += Offset2; // Shift before mirroring
        z.x = abs(z.x + FoldLimit4D.x) - abs(z.x - FoldLimit4D.x) - z.x;
        z.y = abs(z.y + FoldLimit4D.y) - abs(z.y - FoldLimit4D.y) - z.y;
        if (includeZ) z.z = abs(z.z + FoldLimit4D.z) - abs(z.z - FoldLimit4D.z) - z.z;
        z.xyz -= Offset2; // Shift back
        break;

		case 1: // Reverse fold
			z.x = FoldLimit4D.x - abs(abs(z.x) - FoldLimit4D.x);
			z.y = FoldLimit4D.y - abs(abs(z.y) - FoldLimit4D.y);
			if (includeZ) {
				z.z = FoldLimit4D.z - abs(abs(z.z) - FoldLimit4D.z);
			}
			if (includeW) {
				z.w = FoldLimit4D.w - abs(abs(z.w) - FoldLimit4D.w);
			}
			break;

		case 2: // Simple abs fold
			z.x = abs(z.x + FoldLimit4D.x);
			z.y = abs(z.y + FoldLimit4D.y);
			if (includeZ) {
				z.z = abs(z.z + FoldLimit4D.z);
			}
			if (includeW) {
				z.w = abs(z.w + FoldLimit4D.w);
			}
			break;

		case 3: // Conditional fold
			if (abs(z.x) > FoldLimit4D.x) {
				z.x = sign(z.x) * FoldingValue - z.x;
			}
			if (abs(z.y) > FoldLimit4D.y) {
				z.y = sign(z.y) * FoldingValue - z.y;
			}
			if (includeZ && abs(z.z) > FoldLimit4D.z) {
				z.z = sign(z.z) * FoldingValue - z.z;
			}
			if (includeW && abs(z.w) > FoldLimit4D.w) {
				z.w = sign(z.w) * FoldingValue - z.w;
			}
			break;

		case 4: // Darkbeam fold
			z.x = Offset2 - abs(abs(z.x + FoldLimit4D.x) - Offset2) - FoldLimit4D.x;
			z.y = Offset2 - abs(abs(z.y + FoldLimit4D.y) - Offset2) - FoldLimit4D.y;
			if (includeZ) {
				z.z = Offset2 - abs(abs(z.z + FoldLimit4D.z) - Offset2) - FoldLimit4D.z;
			}
			if (includeW) {
				z.w = Offset2 - abs(abs(z.w + FoldLimit4D.w) - Offset2) - FoldLimit4D.w;
			}
			break;

		case 5: // Box fold (Now uses FoldingValue for intensity)
        // FoldingValue now acts as a 'multiplier' for the box clamp
        z.x = clamp(z.x, -FoldLimit4D.x, FoldLimit4D.x) * FoldingValue - z.x;
        z.y = clamp(z.y, -FoldLimit4D.y, FoldLimit4D.y) * FoldingValue - z.y;
        if (includeZ) z.z = clamp(z.z, -FoldLimit4D.z, FoldLimit4D.z) * FoldingValue - z.z;
        break;

		case 6: // Tetrahedral fold
			z.xyz = abs(z.xyz);
			if (z.x - z.y < 0.0) { float t = z.x; z.x = z.y; z.y = t; }
			if (z.x - z.z < 0.0) { float t = z.x; z.x = z.z; z.z = t; }
			if (z.y - z.z < 0.0) { float t = z.y; z.y = z.z; z.z = t; }
			if (includeW && z.x - z.w < 0.0) { float t = z.x; z.x = z.w; z.w = t; }
			break;

		case 7: // Octahedral fold
			z = abs(z);
			if (z.x < z.y) { float t = z.x; z.x = z.y; z.y = t; }
			if (z.x < z.z) { float t = z.x; z.x = z.z; z.z = t; }
			if (z.y < z.z) { float t = z.y; z.y = z.z; z.z = t; }
			if (includeW) {
				if (z.x < z.w) { float t = z.x; z.x = z.w; z.w = t; }
			}
			break;

		case 8: // Cubic fold
			z.xyz = abs(z.xyz);
			if (z.x < z.y) { float t = z.x; z.x = z.y; z.y = t; }
			if (z.x < z.z) { float t = z.x; z.x = z.z; z.z = t; }
			if (z.y < z.z) { float t = z.y; z.y = z.z; z.z = t; }
			z.xyz = clamp(z.xyz, vec3(0.0), FoldLimit4D.xyz) * 2.0 - z.xyz;
			break;

		case 9: // Kaleidoscopic Twist (3D Axis Support)
    // 1. Setup step based on number of sides
    float angle_step = 6.2831853 / max(3.0, KIFS_Sides); 
    
    // 2. Select Axis Plane
    vec2 p_kifs;
    if (KIFS_Axis == 0) p_kifs = z.xy;
    else if (KIFS_Axis == 1) p_kifs = z.xz;
    else p_kifs = z.yz;
    
    // 3. Polar Fold Logic
    float r_kifs = length(p_kifs);
    float phi = atan(p_kifs.y, p_kifs.x) + KIFS_Twist;
    
    // Repeat space around the circle (The "Kaleidoscope")
    phi = mod(phi + angle_step * 0.5, angle_step) - angle_step * 0.5;
    phi = abs(phi); 
    
    p_kifs.x = r_kifs * cos(phi);
    p_kifs.y = r_kifs * sin(phi);
    
    // 4. Re-apply to the main Z vector and apply Mirror
    if (KIFS_Axis == 0) z.xy = abs(p_kifs);
    else if (KIFS_Axis == 1) z.xz = abs(p_kifs);
    else z.yz = abs(p_kifs);
    
    break;

		case 10: // Ripple fold
			z.x += sin(z.y * RippleFrequency) * RippleAmplitude;
			z.y += sin(z.x * RippleFrequency) * RippleAmplitude;
			if (includeZ) {
				z.z += sin(z.x * RippleFrequency) * RippleAmplitude;
			}
			if (includeW) {
				z.w += sin(z.z * RippleFrequency) * RippleAmplitude;
			}
			break;

		case 11: // Parabolic fold
			z.x = z.x - z.x * z.x * sign(z.x) * FoldLimit4D.x * 0.1;
			z.y = z.y - z.y * z.y * sign(z.y) * FoldLimit4D.y * 0.1;
			if (includeZ) {
				z.z = z.z - z.z * z.z * sign(z.z) * FoldLimit4D.z * 0.1;
			}
			if (includeW) {
				z.w = z.w - z.w * z.w * sign(z.w) * FoldLimit4D.w * 0.1;
			}
			break;
			
		case 12: // RFold (Spheroid + Offset2)
        // Offset2 allows you to move the center of the sphere fold!
        vec3 center_p = z.xyz - vec3(Offset2); 
        vec3 shape_modifier = vec3(1.0, max(0.01, FoldLimit4D.y), max(0.01, FoldLimit4D.z));
        float r_warped = length(center_p * shape_modifier);
        float limit = FoldLimit4D.x;
        
        if (r_warped > limit) {
            float m = (FoldingValue * limit - r_warped) / r_warped; 
            z.xyz = center_p * m + vec3(Offset2);
        }
        break;

   case 13: // Amazing Spherical Inversion
    vec3 relative_z = z.xyz - vec3(Offset2);
    float r2 = dot(relative_z, relative_z);
    float R2 = FoldLimit4D.x * FoldLimit4D.x;
    
    if (r2 < R2) {
        float m = (R2 / max(1e-5, r2)) * FoldingValue;
        z.xyz = relative_z * m + vec3(Offset2);
        
        // --- THE CRITICAL ADDITION ---
        // This keeps the Distance Estimator accurate during the warp
        dr *= m; 
    }
    break;
	case 14: // Box Inversion (Mandelbox Logic)
    float boxLimit = FoldLimit4D.x; // Using X as the primary radius
    z.xyz = clamp(z.xyz, -FoldLimit4D.xyz, FoldLimit4D.xyz) * 2.0 - z.xyz;
    float r2_box = dot(z.xyz, z.xyz);
    float R2_box = boxLimit * boxLimit;
    if (r2_box < R2_box) {
        float m = (R2_box / max(1e-5, r2_box)) * FoldingValue;
        z.xyz *= m;
        dr *= m; // In applyFoldNoDerivative, this hits temp_dr and is safely discarded
    }
    break;

case 15: // Organic Ribbon/Tentacle Fold
    // Tentacle Path Warp
    z.xy += vec2(sin(z.z * WarpFrequency), cos(z.z * WarpFrequency)) * WarpStrength;

    // Polar "Tube" Transformation
    float angle = atan(z.y, z.x);
    float radius = length(z.xy);
    
    // Ribbon Thickness Logic
    radius = abs(radius - 1.0) * 1.5; 
    
    // Spiral Twist
    float spiral = angle + (z.z * RibbonTwist);
    z.xy = vec2(cos(spiral), sin(spiral)) * radius;
    
    z *= 1.1; // Escape scaling
    break;
	}
}




// 4D Rotation functions
vec4 rotateXW(vec4 v, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec4(
		v.x * c - v.w * s,
		v.y,
		v.z,
		v.x * s + v.w * c
	);
}

vec4 rotateYW(vec4 v, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec4(
		v.x,
		v.y * c - v.w * s,
		v.z,
		v.y * s + v.w * c
	);
}

vec4 rotateZW(vec4 v, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec4(
		v.x,
		v.y,
		v.z * c - v.w * s,
		v.z * s + v.w * c
	);
}

// Fold without derivative tracking (for Delta DE position calculation)
void applyFoldNoDerivative(inout vec4 z, int foldType, inout vec4 oldZ, bool includeZ, bool includeW) {
    float temp_dr = 1.0; 
    applyFold(z, foldType, oldZ, includeZ, includeW, temp_dr);
}

// Position-only evaluation for Delta DE
vec4 iterate_position(vec3 p3d) {
	vec4 z = vec4(p3d, OffsetW);
	vec4 c = JuliaMode ? vec4(JuliaSeed, 0.0) : z;

	for (int i = 0; i < Iterations; i++) {
		vec4 oldZ = z;

		// Early bailout
		float r2 = dot(z, z);
		if (r2 > Bailout * Bailout * 100.0) break;

		z += vec4(PreOffset, 0.0);

		// Apply folds
		if (FoldSlot1Enabled) applyFoldNoDerivative(z, FoldType1, oldZ, EnableZAxisFold, EnableWAxisFold);
		if (FoldSlot2Enabled) applyFoldNoDerivative(z, FoldType2, oldZ, EnableZAxisFold, EnableWAxisFold);
		if (FoldSlot3Enabled) applyFoldNoDerivative(z, FoldType3, oldZ, EnableZAxisFold, EnableWAxisFold);
		if (FoldSlot4Enabled) applyFoldNoDerivative(z, FoldType4, oldZ, EnableZAxisFold, EnableWAxisFold);
		if (FoldSlot5Enabled) applyFoldNoDerivative(z, FoldType5, oldZ, EnableZAxisFold, EnableWAxisFold);

		z += vec4(PostOffset, 0.0);

		// Surface distortion
		if (SurfStrength > 0.001) {
			vec3 animated_p = z.xyz + vec3(Time * SurfSpeed * 0.1);
			float surfNoise = fbm(animated_p * SurfScale, SurfOctaves, SurfRoughness);
			vec3 displacement = normalize(z.xyz) * surfNoise * SurfStrength * 0.1;
			z.xyz += displacement;
		}

		// Sphere fold
		if (SphereFoldEnabled) {
			float r2_fold = dot(z, z);
			if (ForceCylinderFold) {
				r2_fold -= z.z * z.z * CylinderWeight;
			}
			float sqrtMinR = sqrt(MinRadius);
			float fixedR2 = FixedRadius * FixedRadius;
			if (r2_fold < sqrtMinR) {
				float factor = fixedR2 / sqrtMinR;
				z *= factor;
			}
			else if (r2_fold < fixedR2) {
				float factor = fixedR2 / r2_fold;
				z *= factor;
			}
		}

		z *= Scale;

		// Rotations
		if (abs(RotationAngle) > 0.001) {
			z = rotateZ(z, RotationAngle * Power);
		}
		if (abs(RotationXW) > 0.001) {
			z = rotateXW(z, RotationXW * Power);
		}
		if (abs(RotationYW) > 0.001) {
			z = rotateYW(z, RotationYW * Power);
		}
		if (abs(RotationZW) > 0.001) {
			z = rotateZW(z, RotationZW * Power);
		}

		if (JuliaMode) {
			z += c;
		}

		if (dot(z, z) > Bailout * Bailout) break;
	}

	return z;
}

vec3 rotate3D(vec3 p, vec3 angles) {
    // Convert degrees from Mandelbulber to Radians for GLSL
    vec3 rad = angles * 0.0174533; 
    
    // X Rotation
    float s = sin(rad.x); float c = cos(rad.x);
    p.yz = mat2(vec2(c, -s), vec2(s, c)) * p.yz;
    
    // Y Rotation
    s = sin(rad.y); c = cos(rad.y);
    p.xz = mat2(vec2(c, s), vec2(-s, c)) * p.xz;
    
    // Z Rotation
    s = sin(rad.z); c = cos(rad.z);
    p.xy = mat2(vec2(c, -s), vec2(s, c)) * p.xy;
    
    return p;
}









float map(vec3 p3d, out vec4 orbit) {
    vec4 z = vec4(p3d, OffsetW);
    // Cast JuliaSeed to vec4 to prevent dimension mismatch errors
    vec4 c = JuliaMode ? vec4(JuliaSeed, 0.0) : z;
    orbit = vec4(1e20);
    float dr = 1.0;
    
    // Track the closest point of the recursive shape
    float d_recursive_shape = 1e10; 

    for (int i = 0; i < Iterations; i++) {
        vec4 oldZ = z;
        float r2 = dot(z, z);
        if (r2 > Bailout * Bailout * 100.0) break;

        // --- 1. THE GLOBAL SHAPE SELECTOR (U-Bend Z-Axis) ---
        if (ShapeEnabled) {
            vec3 p = z.xyz - ShapeOffset; 
            float d_base;

            if (ShapeType == 0) {
                // Recursive Torus logic
                d_base = sdTorus(p, vec2(ShapeThickness, ShapeRadius));
            } 
            else if (ShapeType == 1) {
                // Recursive Cylinder/Pole (Z-Axis Oriented with U-Bend)
                
                // NEW: Apply U-Bend specifically along the Z-axis depth
                // Bending p.y based on p.z squared creates the 'U' curve
                if (abs(ShapeBend) > 0.001) {
                    p.y += ShapeBend * 0.1 * p.z * p.z;
                }

                // Call the Z-oriented function from your globals
                d_base = sdCylinderZ(p, ShapeRadius * 5.0, ShapeThickness);


                // Tentacles grow radially from the bent Z-spine
                float angle = atan(p.y, p.x);
                float tentacle_wave = sin(angle * TentacleCount + (p.z * TentacleTwist));
                float growth = max(0.0, tentacle_wave) * TentacleLength;
                d_base -= growth;
            }

            // Apply "Lakel" Surface Grit
            if (SurfStrength > 0.01) {
                float grain = sin((z.x + z.y + z.z) * SurfScale * 5.0);
                d_base += grain * 0.1 * GrainIntensity * SurfStrength;
            }

            // Normalize shape distance by current derivative (dr)
            d_recursive_shape = min(d_recursive_shape, d_base / dr);
        }

        // --- 2. FRACTAL FOLDS & SCALING (Restored all 5 Slots) ---
        float current_scale = Scale + ScaleVary * (dr - 1.0);
        z.xyz += PreOffset;
        
        // Ensure all slots are checked to match your Amazing Surf settings
        if (FoldSlot1Enabled) applyFold(z, FoldType1, oldZ, EnableZAxisFold, EnableWAxisFold, dr);
        if (FoldSlot2Enabled) applyFold(z, FoldType2, oldZ, EnableZAxisFold, EnableWAxisFold, dr);
        if (FoldSlot3Enabled) applyFold(z, FoldType3, oldZ, EnableZAxisFold, EnableWAxisFold, dr);
        if (FoldSlot4Enabled) applyFold(z, FoldType4, oldZ, EnableZAxisFold, EnableWAxisFold, dr);
        if (FoldSlot5Enabled) applyFold(z, FoldType5, oldZ, EnableZAxisFold, EnableWAxisFold, dr);
        
        z.xyz += PostOffset;
        
        // Sphere Fold Logic
        if (SphereFoldEnabled) {
            float rr = dot(z.xyz, z.xyz);
            float m = current_scale;
            if (rr < MinRadius * MinRadius) m /= (MinRadius * MinRadius);
            else if (rr < FixedRadius * FixedRadius) m /= rr;
            z *= m;
            dr = dr * abs(m) + 1.0;
        } else {
            z *= current_scale;
            dr = dr * abs(current_scale) + 1.0;
        }

        // Rotate and apply Julia offset
        if (length(EulerRotation) > 0.001) z.xyz = rotate3D(z.xyz, EulerRotation);
        if (JuliaMode) z += c;
        orbit = min(orbit, abs(z));
    }

    float r = length(z);
    float d_fractal = (DEMethod == 0) ? 0.5 * r * log(r) / dr : max(abs(z.x), max(abs(z.y), abs(z.z))) / dr;
    
    // --- 3. THE SMOOTH BLEND ---
    float final_de = d_fractal;
    if (ShapeEnabled && d_recursive_shape < 1e9) {
        float k = 0.1; // Smoothness factor
        float h = clamp(0.5 + 0.5 * (d_fractal - d_recursive_shape) / k, 0.0, 1.0);
        final_de = mix(d_fractal, d_recursive_shape, h) - k * h * (1.0 - h);
    }

    return clamp(final_de * DEMultiplier, 0.0, 10.0);
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

void fragment() {
    // 1. Setup Shared Screen Coordinates
    vec2 p_ndc = SCREEN_UV * 2.0 - 1.0;
    float aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
    p_ndc.x *= aspect;

    // 2. Setup Shared Camera Info
    vec3 ro = CAMERA_POSITION_WORLD;
    // rd: transforms flat screen coords into a 3D vector pointing out from the camera
    vec3 rd = (INV_VIEW_MATRIX * vec4(normalize(vec3(p_ndc, -2.0)), 0.0)).xyz;

    vec3 final_color = vec3(0.0);
    float final_alpha = 0.0;

    // === METHOD 1: SLICE RENDERING ===
    if (RenderingMethod == 1) {
        vec2 uv = (p_ndc * SliceZoom) + SliceOffset;
        float current_w = AnimateSliceW ? SliceW + Time * SliceWSpeed : SliceW;
        
        vec3 p3d = vec3(uv.x, uv.y, current_w);
        vec4 orbit;
        float d = map(p3d, orbit); 
        
        float edge_glow = exp(-d * 20.0); 
        vec3 base_color = palette(length(orbit.xyz) * ColorCycle);
        
        final_color = (d < 0.01) ? base_color : base_color * edge_glow;
        final_alpha = 1.0;
    }
    // === METHOD 2: VOLUME RENDERING ===
    else if (RenderingMethod == 2) {
        vec3 accumulated_color = vec3(0.0);
        float accumulated_alpha = 0.0;
        float vol_t = VolumeStartDistance;
        float step_size = (VolumeEndDistance - VolumeStartDistance) / float(VolumeSteps);
        vec4 orbit;

        for (int i = 0; i < VolumeSteps; i++) {
            if (accumulated_alpha > 0.95) break;
            vec3 p3d = ro + rd * vol_t;
            float d = map(p3d, orbit);
            
            if (d < 0.5) {
                float density = (0.5 - clamp(d, 0.0, 0.5)) * VolumeDensity;
                vec3 sample_color = palette(length(orbit.xyz) * ColorCycle) * VolumeBrightness;
                float alpha_step = density * 0.3;
                accumulated_color += sample_color * alpha_step * (1.0 - accumulated_alpha);
                accumulated_alpha += alpha_step;
            }
            vol_t += step_size;
        }
        final_color = accumulated_color;
        final_alpha = clamp(accumulated_alpha, 0.0, 1.0);
    }
    // === METHOD 0: STANDARD RAYMARCHING ===
    else {
        float maxDist = 20.0;
        float t = 0.01; // Distance along the ray
        bool hit = false;
        vec4 orbit;
        float precision = pow(10.0, Detail);

        // THE CORE RAYMARCH LOOP
        for (int i = 0; i < MaxSteps; i++) {
            vec3 p = ro + rd * t;
            float d = map(p, orbit);
            
            if (d < min(precision * t, 0.01)) {
                hit = true;
                break;
            }
            t += d * 0.5; // Step cautiously to prevent clipping
            if (t > maxDist) break;
        }

        if (hit) {
            vec3 p = ro + rd * t;
            vec3 n = get_normal(p);
            vec3 col = palette(length(orbit.xyz) * ColorCycle);

            // Simple Lighting
            vec3 light_dir = normalize(vec3(1.0, 1.0, -1.0));
            float diff = max(dot(n, light_dir), 0.0) * 0.7 + 0.3;
            col *= diff;

            // Fog Logic
            if (FogDensity > 0.0) {
                float fog = 1.0 - exp(-t * FogDensity);
                col = mix(col, vec3(0.0), fog); // Mix with black/background
            }

            final_color = col;
            final_alpha = 1.0;
        }
    }
    
    // Apply final output
    ALBEDO = apply_art_controls(final_color);
    ALPHA = final_alpha;
}
vec3 organic_warp(vec3 p) {
    // This creates the "tentacle" curve by offsetting 
    // X and Y based on the sine of Z
    p.xy += vec2(sin(p.z * WarpFrequency), cos(p.z * WarpFrequency)) * WarpStrength;
    return p;
}
