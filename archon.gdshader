shader_type spatial;
#include "res://fractal_globals.gdshaderinc"
uniform float Time;
render_mode unshaded, cull_disabled;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// =====================================================================
//  THE ARCHON FRACTAL — An original formula by Hyperion / Claude
//
//  Core concept: Recursive architectural ruins in 4D space.
//  Each iteration performs four operations:
//    1. Angular fold — sharp abs() mirroring creates stone-block edges
//    2. Spin fold   — cross-product rotation builds columnar symmetry
//    3. Arch warp   — sin/cos carves recursive arched openings
//    4. 4D inversion — sphere inversion + XW rotation for impossible geometry
//
//  ArchonType 0 = Organic (original swirling mode)
//  ArchonType 1 = City    (hard box-fold Mandelbox-style architecture)
// =====================================================================

group_uniforms Archon_Main;
// 0 = Organic (original), 1 = City (hard box-fold architecture)
uniform int ArchonType : hint_range(0, 1) = 0;
uniform int WaveType : hint_range(0, 4) = 0;
// 0.0 = pure sine, 1.0 = full selected wave type
uniform float WaveBlend : hint_range(0.0, 1.0) = 1.0;
uniform float Scale : hint_range(0.1, 5.0) = 2.0;
uniform int Iterations : hint_range(1, 120) = 20;
uniform float Bailout : hint_range(1.0, 100.0) = 8.0;

// The constant subtracted each iteration — primary shape driver
// Small changes here create completely different ruins
uniform vec4 ArchonConstant = vec4(1.0, 1.3, 0.8, 0.2);

group_uniforms Spin_Fold;
uniform float SpinStrength : hint_range(0.0, 2.0) = 0.0;
uniform vec3 SpinAxis = vec3(0.0, 1.0, 0.0);

group_uniforms Arch_Warp;
uniform float ArchFrequency : hint_range(0.0, 10.0) = 1.5;
uniform float ArchDepth : hint_range(0.0, 2.0) = 0.4;
uniform int ArchAxis : hint_range(0, 2) = 0;
uniform float TowerBias : hint_range(0.1, 5.0) = 0.0;

group_uniforms Inversion_Settings;
uniform float InvRadius : hint_range(0.1, 5.0) = 1.2;
uniform float InvStrength : hint_range(0.0, 1.0) = 0.8;

group_uniforms Transform_4D;
uniform float RotationAngle : hint_range(0.0, 6.28) = 0.3;
uniform float WRotationSpeed : hint_range(0.0, 2.0) = 0.0;

group_uniforms Rendering;
uniform float Detail : hint_range(-5.0, -1.0) = -1.0;
uniform int MaxSteps : hint_range(32, 512) = 200;

group_uniforms Fractal_Modes;
uniform bool JuliaMode = false;
uniform vec4 JuliaSeed = vec4(1.0, 1.3, 0.8, 0.2);
uniform float JuliaMorph : hint_range(0.0, 1.0) = 0.0;

group_uniforms City_Tiling;
uniform bool CityEnabled = false;
uniform float CellSize : hint_range(0.5, 20.0) = 4.0;
uniform float CellRotVariance : hint_range(0.0, 6.28) = 0.8;
uniform float CellConstantVariance : hint_range(0.0, 1.0) = 0.3;
uniform float CellHeightVariance : hint_range(0.0, 1.0) = 0.4;
uniform float AlleyWidth : hint_range(0.0, 0.49) = 0.15;


void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

// === 4D XW Rotation ===
vec4 rotate4D_XW(vec4 p, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec4(
        p.x * c - p.w * s,
        p.y,
        p.z,
        p.x * s + p.w * c
    );
}

// === 4D YW Rotation ===
vec4 rotate4D_YW(vec4 p, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec4(
        p.x,
        p.y * c - p.w * s,
        p.z,
        p.y * s + p.w * c
    );
}

// =====================================================================
//  WAVE FUNCTIONS
// =====================================================================
float wave_triangle(float x) {
    return abs(fract(x * (1.0 / 6.28318)) * 2.0 - 1.0) * 2.0 - 1.0;
}
float wave_square(float x) {
    return sign(sin(x));
}
float wave_sawtooth(float x) {
    return fract(x * (1.0 / 6.28318)) * 2.0 - 1.0;
}
float wave_bounce(float x) {
    return abs(sin(x)) * 2.0 - 1.0;
}

float wave(float x) {
    float base = sin(x);
    float shaped;
    if      (WaveType == 1) shaped = wave_triangle(x);
    else if (WaveType == 2) shaped = wave_square(x);
    else if (WaveType == 3) shaped = wave_sawtooth(x);
    else if (WaveType == 4) shaped = wave_bounce(x);
    else                    shaped = base;
    return mix(base, shaped, WaveBlend);
}

float wave_cos(float x) {
    return wave(x + 1.5708);
}

// === SPIN FOLD ===
vec4 spinFold(vec4 z, vec3 axis, float strength) {
    if (strength < 0.001) return z;
    float spin_angle = atan(z.z, z.x) * strength;
    float s = sin(spin_angle);
    float c = cos(spin_angle);
    if (axis.y > 0.5) {
        float nx = z.x * c - z.z * s;
        float nz = z.x * s + z.z * c;
        return vec4(nx, z.y, nz, z.w);
    } else if (axis.x > 0.5) {
        float ny = z.y * c - z.z * s;
        float nz = z.y * s + z.z * c;
        return vec4(z.x, ny, nz, z.w);
    } else {
        float nx = z.x * c - z.y * s;
        float ny = z.x * s + z.y * c;
        return vec4(nx, ny, z.z, z.w);
    }
}

// === ARCH WARP ===
vec4 archWarp(vec4 z, float freq, float depth, int axis) {
    if (depth < 0.001) return z;

    if (axis == 0) {
        // XY arches — tall doorway-shaped openings along Z depth
        z.x += wave(z.y * freq) * depth;
        z.y += wave_cos(z.x * freq) * depth * 0.5;
    } else if (axis == 1) {
        // XZ arches — horizontal window openings along Y height
        z.x += wave(z.z * freq) * depth;
        z.z += wave_cos(z.x * freq) * depth * 0.5;
    } else {
        // YZ arches — side tunnel openings
        z.y += wave(z.z * freq) * depth;
        z.z += wave_cos(z.y * freq) * depth * 0.5;
    }

    // W dimension uses wave too for 4D consistency
    z.w += wave((z.x + z.y) * freq * 0.5) * depth * 0.25;

    return z;
}

// =====================================================================
//  CITY TILING HELPERS
// =====================================================================
float city_hash(vec2 p) {
    vec2 q = fract(p * vec2(127.1, 311.7));
    q += dot(q, q + 19.19);
    return fract(q.x * q.y);
}

vec2 rotate_xz(vec2 v, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

vec3 apply_city_tiling(
    vec3 p,
    out vec2 cell_id,
    out vec4 cell_constant_delta,
    out float cell_height_mult
) {
    if (!CityEnabled) {
        cell_id = vec2(0.0);
        cell_constant_delta = vec4(0.0);
        cell_height_mult = 1.0;
        return p;
    }
    cell_id = floor(p.xz / CellSize);
    vec2 local_xz = mod(p.xz, CellSize) - CellSize * 0.5;
    float half_cell = CellSize * 0.5;
    float alley = CellSize * AlleyWidth;
    if (abs(local_xz.x) > half_cell - alley || abs(local_xz.y) > half_cell - alley) {
        cell_constant_delta = vec4(0.0);
        cell_height_mult = 1.0;
        p.xz = local_xz;
        p.y += 999.0;
        return p;
    }
    float rot_angle = city_hash(cell_id) * CellRotVariance;
    local_xz = rotate_xz(local_xz, rot_angle);
    cell_constant_delta = vec4(
        (city_hash(cell_id)                        - 0.5) * CellConstantVariance,
        (city_hash(cell_id + vec2(31.7, 0.0))      - 0.5) * CellConstantVariance,
        (city_hash(cell_id + vec2(0.0, 74.1))      - 0.5) * CellConstantVariance,
        (city_hash(cell_id + vec2(53.3, 29.8))     - 0.5) * CellConstantVariance
    );
    cell_height_mult = 1.0 + (city_hash(cell_id + vec2(7.3, 113.9)) - 0.5)
                       * CellHeightVariance * 2.0;
    p.xz = local_xz;
    return p;
}

vec3 apply_shape_warp(vec3 p) {
    if (!ShapeEnabled) return p;
    p -= ShapeOffset;
    if (abs(ShapeBend) > 0.001) {
        float bend_r = 1.0 / ShapeBend;
        float angle = p.y * ShapeBend;
        float bx = sin(angle) * bend_r - bend_r;
        float by = cos(angle) * bend_r;
        p.x += bx * ShapeThickness;
        p.y = by * sign(ShapeBend);
    }
    if (TentacleCount > 0.5) {
        float angle = atan(p.z, p.x);
        float twist_offset = p.y * TentacleTwist;
        float sector = 6.28318 / TentacleCount;
        angle = mod(angle + twist_offset, sector) - sector * 0.5;
        float radius = length(p.xz);
        p.x = cos(angle) * radius;
        p.z = sin(angle) * radius;
        if (TentacleLength > 0.001) {
            p.x -= ShapeRadius * TentacleLength;
        }
    }
    if (ShapeType == 1) {
        float radius_xz = length(p.xz) - ShapeRadius;
        p.x = radius_xz;
    } else if (ShapeType == 0) {
        float r = length(p);
        if (r > 0.001) {
            float shell = abs(r - ShapeRadius);
            p = normalize(p) * shell;
        }
    }
    return p;
}

float grain_noise(vec3 p) {
    p = fract(p * vec3(127.1, 311.7, 74.7));
    p += dot(p, p.yzx + 19.19);
    return fract((p.x + p.y) * p.z);
}


float map(vec3 p3d, out vec4 orbit) {
    // === SHAPE DOMAIN WARP ===
    p3d = apply_shape_warp(p3d);

    // === CITY TILING ===
    vec2  cell_id;
    vec4  cell_constant_delta;
    float cell_height_mult;
    p3d = apply_city_tiling(p3d, cell_id, cell_constant_delta, cell_height_mult);

    if (p3d.y > 100.0) {
        orbit = vec4(0.0);
        return p3d.y;
    }

    p3d.y *= TowerBias * cell_height_mult;

    // === GLOBAL SYMMETRY ===
    apply_symmetry(p3d);

    vec4 z = vec4(p3d, OffsetW);
    vec4 combined = mix(ArchonConstant, JuliaSeed, JuliaMorph);
    if (CityEnabled) {
        combined += cell_constant_delta;
    }
    vec4 c = JuliaMode ? combined : z;

    orbit = vec4(1e20);
    float dr = 1.0;

    float w_angle = RotationAngle + Time * WRotationSpeed * 0.1;

    // =====================================================================
    //  TYPE 0 — ORGANIC (original swirling formula)
    // =====================================================================
    if (ArchonType == 0) {

        for (int i = 0; i < Iterations; i++) {

            // Step 1: Asymmetric angular fold
            z.x = abs(z.x) - combined.x;
            z.y = abs(z.y) - combined.y * 1.5;
            z.z = abs(z.z) - combined.z;
            z.w = abs(z.w) - combined.w;

            // Step 2: Spin fold
            z = spinFold(z, SpinAxis, SpinStrength * 0.1);

            // Step 2b: KIFS fold
            kifs_fold(z, KIFS_Angle_X, KIFS_Angle_Y, KIFS_Angle_Z);

            // Step 3: Arch warp
            z = archWarp(z, ArchFrequency, ArchDepth, ArchAxis);

            // Step 4: Sphere inversion
            float r2 = dot(z, z);
            if (r2 > Bailout * Bailout) break;
            float inv_r2 = (InvRadius * InvRadius) / max(r2, 0.0001);
            float inv_blend = mix(1.0, inv_r2, InvStrength);
            z *= inv_blend;
            dr = dr * abs(inv_blend) + 1.0;

            // Step 5: Scale
            z *= Scale;
            dr *= abs(Scale);

            // Step 6: 4D rotation
            z = rotate4D_XW(z, w_angle);

            orbit = min(orbit, abs(z));
        }

        float r = length(z);
        return 0.5 * log(r) * r / max(dr, 0.001);

    // =====================================================================
    //  TYPE 1 — CITY (hard box-fold Mandelbox-style architecture)
    //
    //  Uses the same uniforms but replaces smooth trig folds with:
    //  - Hard box fold (clamp reflection) for sharp slab/block edges
    //  - Sphere fold (Mandelbox inner/outer radius) for recursive detail
    //  - c added back after scale (Mandelbox iteration) for true IFS structure
    //  ArchonConstant.xyz = box fold limit per axis (like BoxFoldLimit)
    //  InvRadius         = sphere fold radius (outer)  
    //  InvStrength       = inner sphere radius fraction (0=no inner fold)
    //  Scale             = Mandelbox scale factor
    // =====================================================================
    } else {

        // Sphere fold radii derived from InvRadius and InvStrength
        // Outer radius = InvRadius, Inner radius = InvRadius * (1 - InvStrength) * 0.5
        float outer_r2 = InvRadius * InvRadius;
        float inner_r2 = outer_r2 * max(0.001, (1.0 - InvStrength) * 0.5);
        inner_r2 *= inner_r2; // square it so we compare to dot(z,z)

        for (int i = 0; i < Iterations; i++) {

            // Step 1: Box fold — clamp-reflect each axis independently
            // combined.xyz acts as per-axis fold limit, combined.w folds W
            // This creates the hard flat surfaces of stone blocks and slabs
            z.x = clamp(z.x, -combined.x, combined.x) * 2.0 - z.x;
            z.y = clamp(z.y, -combined.y, combined.y) * 2.0 - z.y;
            z.z = clamp(z.z, -combined.z, combined.z) * 2.0 - z.z;
            z.w = clamp(z.w, -combined.w, combined.w) * 2.0 - z.w;

            // Step 2: Spin fold (same as organic — adds columnar twist)
            z = spinFold(z, SpinAxis, SpinStrength * 0.1);

            // Step 2b: KIFS fold (same — adds angular crystalline detail)
            kifs_fold(z, KIFS_Angle_X, KIFS_Angle_Y, KIFS_Angle_Z);

            // Step 3: Arch warp — wave type drives window/arch cut profiles
            // In city mode the wave shape strongly affects wall cut geometry:
            // Square wave = rectangular windows, Triangle = peaked arches
            z = archWarp(z, ArchFrequency, ArchDepth, ArchAxis);

            // Step 4: Sphere fold (Mandelbox-style inner/outer inversion)
            // Inner fold: points very close to origin get pushed outward
            // Outer fold: points beyond outer radius get normalized back
            // Together these create the recursive hollowing inside each block
            float r2 = dot(z, z);
            if (r2 > Bailout * Bailout) break;

            if (r2 < inner_r2) {
                // Inside inner sphere — magnify outward (creates hollow cores)
                float fold_factor = outer_r2 / max(inner_r2, 0.0001);
                z  *= fold_factor;
                dr *= fold_factor;
            } else if (r2 < outer_r2) {
                // Between inner and outer — standard sphere inversion
                float fold_factor = outer_r2 / max(r2, 0.0001);
                z  *= fold_factor;
                dr *= fold_factor;
            }

            // Step 5: Scale and add c (true IFS — this is what makes it
            // Mandelbox-style rather than escape-time, giving hard geometry)
            z  = z * Scale + c;
            dr = dr * abs(Scale) + 1.0;

            // Step 6: 4D rotation (same — drives cross-section variety)
            z = rotate4D_XW(z, w_angle);

            orbit = min(orbit, abs(z));
        }

        // Mandelbox-style DE: linear distance estimate
        // abs(Scale-1.0) corrects for the scale offset in the iteration
        return (length(z) - abs(Scale - 1.0)) / max(dr, 0.001);
    }
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
    vec3 ro = CAMERA_POSITION_WORLD;
    vec2 p_ndc = SCREEN_UV * 2.0 - 1.0;
    p_ndc.x *= VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
    vec3 rd = normalize((INV_VIEW_MATRIX * vec4(p_ndc, -1.0, 0.0)).xyz);

    float t = 0.05;
    bool hit = false;
    vec4 orbit;
    float precision = pow(10.0, Detail);

    for (int i = 0; i < MaxSteps; i++) {
        vec3 p = ro + rd * t;
        float d = map(p, orbit);

        if (d < precision * t) {
            hit = true;
            break;
        }
        t += d * 0.4;
        if (t > 40.0) break;
    }

    if (hit) {
        vec3 p = ro + rd * t;
        vec3 n = get_normal(p);
        vec3 col = palette(length(orbit.xyz) * ColorCycle);

        if (GrainIntensity > 0.001) {
            float g = grain_noise(p * 18.7) * 2.0 - 1.0;
            col += g * GrainIntensity * 0.15;
        }

        vec3 key_light = normalize(vec3(1.0, 1.5, -0.5));
        vec3 fill_light = normalize(vec3(-0.5, 0.3, 1.0));

        float key_diff = max(dot(n, key_light), 0.0) * 0.7;
        float fill_diff = max(dot(n, fill_light), 0.0) * 0.2;
        float ambient = 0.1;
        col *= (key_diff + fill_diff + ambient);

        vec3 view_dir = normalize(ro - p);
        vec3 half_dir = normalize(key_light + view_dir);
        float spec = pow(max(dot(n, half_dir), 0.0), 64.0) * 0.4;
        col += vec3(spec);

        if (FogDensity > 0.0) {
            float fog = 1.0 - exp(-t * FogDensity);
            vec3 sky = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
            col = mix(col, sky, fog);
        }

        if (Reflectivity > 0.0) {
            vec3 ref_dir = reflect(rd, n);
            vec2 ref_uv = clamp(SCREEN_UV + ref_dir.xy * 0.05, 0.0, 1.0);
            vec3 reflection = texture(SCREEN_TEXTURE, ref_uv).rgb;
            col = mix(col, reflection, Reflectivity);
        }

        ALBEDO = apply_art_controls(col);
        ALPHA = 1.0;
    } else {
        ALBEDO = vec3(0.0);
        ALPHA = 0.0;
    }
}
