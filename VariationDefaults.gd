extends Resource
class_name VariationDefaults

## --- Main Controls ---
@export var variation_mode_a: int = 0 #Sinusoidal ID
@export var variation_mode_b: int = 1  # Spherical ID
@export var start_pattern_mode: int = 0
@export var variation_mix: float = 0.5
@export var feedback_amount: float = 0.02
@export var feedback_min: float = 0.0
@export var feedback_max: float = 0.1
@export var seamless_tiling: bool = true
@export var mirror_tiling: bool = false
@export var reset_on_drag_enabled: bool = true
@export var save_resolution_index: int = 1

## --- Start Patterns ---
@export var show_start_grid: bool = false
@export var show_circles: bool = true
@export var circle_count: float = 4.0
@export var circle_radius: float = 0.2
@export var circle_softness: float = 0.05
@export var grad_col_tl: Color = Color.CYAN
@export var grad_col_tr: Color = Color.YELLOW
@export var grad_col_bl: Color = Color.BLUE
@export var grad_col_br: Color = Color.RED

## --- Transforms ---
@export var pre_scale: float = 1.0
@export var pre_rotation: float = 0.0
@export var pre_translate: Vector2 = Vector2.ZERO
@export var post_scale: float = 0.995
@export var post_rotation: float = 0.0
@export var post_translate: Vector2 = Vector2.ZERO
@export var translate_a: Vector2 = Vector2.ZERO
@export var translate_b: Vector2 = Vector2.ZERO
@export var move_post_translate: bool = true
@export var move_pre_translate: bool = false
@export var move_var_a_translate: bool = false
@export var move_var_b_translate: bool = false

## --- Color & Post FX ---
@export var brightness: float = 1.0
@export var contrast: float = 1.0
@export var saturation: float = 1.0
@export var mirror_x: bool = false
@export var mirror_y: bool = false
@export var kaleidoscope_on: bool = false
@export var kaleidoscope_slices: float = 6.0

## --- Variation A ---
@export var var_a_mirror_x: bool = false
@export var var_a_mirror_y: bool = false
@export var var_a_kaleidoscope_slices: float = 6.0
@export var wave_type_a: int = 0
@export var wave_frequency_a: float = 0.0
@export var wave_amplitude_a: float = 0.1
@export var wave_speed_a: float = 0.0
@export var julian_power_a: float = 2.0
@export var julian_dist_a: float = 1.0
@export var julian_a_a: float = 1.0
@export var julian_b_a: float = 0.0
@export var julian_c_a: float = 0.0
@export var julian_d_a: float = 1.0
@export var julian_e_a: float = 0.0
@export var julian_f_a: float = 0.0
@export var fisheye_strength_a: float = 2.0
@export var polar_offset_a: float = 1.0
@export var mobius_re_a_a: float = 0.1
@export var mobius_im_a_a: float = 0.2
@export var mobius_re_b_a: float = 0.2
@export var mobius_im_b_a: float = -0.12
@export var mobius_re_c_a: float = -0.15
@export var mobius_im_c_a: float = -0.15
@export var mobius_re_d_a: float = 0.21
@export var mobius_im_d_a: float = 0.1
@export var cellular_weave_grid_size_a: float = 10.0
@export var cellular_weave_threshold_a: float = 4.0
@export var cellular_weave_iterations_a: float = 1.0
@export var blur_amount_a: float = 0.0
@export var heart_scale_a: float = 0.3
@export var heart_rotation_a: float = 0.0
@export var heart_strength_a: float = 0.5
@export var apollonian_scale_a: float = 1.5
@export var ap_c1_a: Vector2 = Vector2(0.0, 0.5)
@export var ap_c2_a: Vector2 = Vector2(-0.433, -0.25)
@export var ap_c3_a: Vector2 = Vector2(0.433, -0.25)
@export var custom_tl_a_id: int = 0
@export var custom_tr_a_id: int = 0
@export var custom_bl_a_id: int = 0
@export var custom_br_a_id: int = 0

## --- Variation B ---
@export var var_b_mirror_x: bool = false
@export var var_b_mirror_y: bool = false
@export var var_b_kaleidoscope_slices: float = 6.0
@export var wave_type_b: int = 0
@export var wave_frequency_b: float = 5.0
@export var wave_amplitude_b: float = 0.1
@export var wave_speed_b: float = 0.0
@export var julian_power_b: float = -3.0
@export var julian_dist_b: float = 1.0
@export var julian_a_b: float = 1.0
@export var julian_b_b: float = 0.0
@export var julian_c_b: float = 0.0
@export var julian_d_b: float = 1.0
@export var julian_e_b: float = 0.0
@export var julian_f_b: float = 0.0
@export var fisheye_strength_b: float = 2.0
@export var polar_offset_b: float = 1.0
@export var mobius_re_a_b: float = 0.1
@export var mobius_im_a_b: float = 0.2
@export var mobius_re_b_b: float = 0.2
@export var mobius_im_b_b: float = -0.12
@export var mobius_re_c_b: float = -0.15
@export var mobius_im_c_b: float = -0.15
@export var mobius_re_d_b: float = 0.21
@export var mobius_im_d_b: float = 0.1
@export var cellular_weave_grid_size_b: float = 10.0
@export var cellular_weave_threshold_b: float = 4.0
@export var cellular_weave_iterations_b: float = 1.0
@export var blur_amount_b: float = 0.0
@export var heart_scale_b: float = 0.3
@export var heart_rotation_b: float = 0.0
@export var heart_strength_b: float = 0.5
@export var apollonian_scale_b: float = 1.5
@export var ap_c1_b: Vector2 = Vector2(0.0, 0.5)
@export var ap_c2_b: Vector2 = Vector2(-0.433, -0.25)
@export var ap_c3_b: Vector2 = Vector2(0.433, -0.25)
@export var custom_tl_b_id: int = 0
@export var custom_tr_b_id: int = 0
@export var custom_bl_b_id: int = 0
@export var custom_br_b_id: int = 0

## --- 3D Controls ---
@export var light_x_rotation: float = 0.0
@export var light_y_rotation: float = 0.0
@export var light_energy: float = 1.0
@export var light_color: Color = Color.WHITE
@export var light_shadows: bool = true
@export var normal_map_strength: float = 1.0
@export var camera_distance: float = 0.5
@export var camera_x_rotation: float = 0.0
@export var camera_y_rotation: float = 0.0
@export var camera_fov: float = 75.0
@export var show_2d_background: bool = false
