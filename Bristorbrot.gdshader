shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;
#include "res://fractal_globals.gdshaderinc"
// --- Performance & Quality ---


// --- Uniforms (Mapped to your Save/Load System) ---


uniform float time_speed : hint_range(0.0, 2.0) = 0.5;
uniform bool draw_parallel = true;
uniform float zoom : hint_range(0.1, 10.0) = 4.5;
uniform float WarpStrength : hint_range(0.0, 2.0) = 0.0;
uniform float WarpFrequency : hint_range(0.1, 10.0) = 1.0;
uniform float WOffset : hint_range(-3.0, 3.0) = 0.0;
// --- Constants ---
const float Epsilon = 0.002;
const float RenderDistance = 100.0;

// --- Math Helpers ---
mat3 rotate_y(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(vec3(c, 0, s), vec3(0, 1, 0), vec3(-s, 0, c));
}


vec3 fractal_palette(float val) {
    val = fract(val * 0.3 + 0.5);
    vec3 a = (Color1 + Color2) * 0.5;
    vec3 b = (Color1 - Color2) * 0.5;
    vec3 c = vec3(1.0);
    vec3 d = vec3(0.0, 0.33, 0.67);
    return a + b * cos(6.28318 * (c * val + d));
}

vec3 domain_warp(vec3 p, float t) {
    if (WarpStrength == 0.0) return p;
    float wx = sin(p.y * WarpFrequency + t) * WarpStrength;
    float wy = sin(p.z * WarpFrequency + t) * WarpStrength;
    float wz = sin(p.x * WarpFrequency + t) * WarpStrength;
    return p + vec3(wx, wy, wz);
}


// --- BristorBrot 4D Distance Function ---
float distanceEstimation(vec3 pos3d, float t) {
    vec4 pos = draw_parallel ? vec4(pos3d.x, sin(t) * pos3d.y, cos(t) * pos3d.y, pos3d.z) : vec4(pos3d, WOffset);
    vec4 z = pos;
    float dr = 1.0;
    float d_recursive_shape = 1e10;

    for (int i = 0; i < 25; i++) {
        float r = length(z);
        if (r > 4.0) break; 

        if (ShapeEnabled) {
            vec3 p = z.xyz - ShapeOffset;
            float d_base;
            if (ShapeType == 0) {
                d_base = sdTorus(p, vec2(ShapeRadius, ShapeThickness));
            } else if (ShapeType == 1) {
                if (abs(ShapeBend) > 0.001) p.y += ShapeBend * 0.1 * p.z * p.z;
                d_base = sdCylinderZ(p, 10.0, ShapeRadius);
                float angle = atan(p.y, p.x);
                float tentacle_wave = sin(angle * TentacleCount + (p.z * TentacleTwist));
                d_base -= max(0.0, tentacle_wave) * TentacleLength;
            }
            d_recursive_shape = min(d_recursive_shape, d_base / dr);
        }

        vec4 z_next = vec4(z.x*z.x - z.y*z.y - z.z*z.z - z.w*z.w, 
                           z.y*(2.0*z.x - z.z - z.w), 
                           z.z*(2.0*z.x + z.y - z.w), 
                           z.w*(2.0*z.x + z.y + z.z));
        dr = dr * 2.0 * r + 1.0;
        z = z_next + pos;
    } 
    
    float d_fractal = 0.5 * log(length(z)) * length(z) / dr;
    if (ShapeEnabled && d_recursive_shape < 1e9) {
        float k = 0.1;
        float h = clamp(0.5 + 0.5 * (d_fractal - d_recursive_shape) / k, 0.0, 1.0);
        return mix(d_fractal, d_recursive_shape, h) - k * h * (1.0 - h);
    }
    return d_fractal;
}

// --- Normal Calculation (Fixed Syntax) ---
vec3 get_normal(vec3 p, float t) {
    float epsilon = 0.001;
    vec2 e = vec2(epsilon, 0.0);
    
    // We pass 'p' modified by 'e', but we keep 't' the same for all samples
    return normalize(vec3(
        distanceEstimation(p + e.xyy, t) - distanceEstimation(p - e.xyy, t),
        distanceEstimation(p + e.yxy, t) - distanceEstimation(p - e.yxy, t),
        distanceEstimation(p + e.yyx, t) - distanceEstimation(p - e.yyx, t)
    ));
}

void fragment() {
    // Correcting for the 3D Spatial aspect
    // We use SCREEN_UV because this shader acts like a post-process effect on a mesh
float t = TIME * time_speed;
    
vec3 camPos = CAMERA_POSITION_WORLD * 0.5;
    vec2 p_ndc = SCREEN_UV * 2.0 - 1.0;
    p_ndc.x *= VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
    vec3 rayDir = normalize((INV_VIEW_MATRIX * vec4(p_ndc, -1.0, 0.0)).xyz);
    
    // Raymarching Loop
    float total_dist = 0.0;
    vec3 p = camPos;
    bool hit = false;
    
    int i = 0;
for (; i < 128; i++) {
        float d = distanceEstimation(p, t);
        if (d < Epsilon) {
            hit = true;
            break;
        }
        p += rayDir * d;
        total_dist += d;
        if (total_dist > RenderDistance) break;
    }

    vec3 final_color = Color3; // Background

if (hit) {
        vec3 normal = get_normal(p, t);
        vec3 lightDir = normalize(vec3(1.0, 1.0, -1.0));
        float diff = max(dot(normal, lightDir), 0.0);
        
        // Gradient coloring based on distance and position
        float color_val = (total_dist * ColorCycle) + length(p) * 0.2;
        vec3 grad_color = palette(color_val);
        
        // Mix gradient with lighting
        vec3 surface = grad_color * (diff * 0.7 + 0.3);
        
        float fog = 1.0 - clamp(total_dist / RenderDistance, 0.0, 1.0);
        float ao = 1.0 - float(i) / 128.0;
        final_color = surface * fog * (0.7 + 0.3 * ao);
    }

      if (hit) {
        ALBEDO = final_color;
        ALPHA = 1.0;
    } else {
        ALBEDO = vec3(0.0);
        ALPHA = 0.0;
    }
    EMISSION = final_color;  // ADD THIS
    ROUGHNESS = 1.0;
    METALLIC = 0.0;

}
void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}