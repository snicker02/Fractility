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