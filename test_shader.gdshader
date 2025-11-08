shader_type canvas_item;

void fragment() {
    // A simple color that blinks
    COLOR = vec4(1.0, 0.0, 1.0, 1.0) * (0.5 + sin(TIME) * 0.5);
}