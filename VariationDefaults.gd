extends Resource
class_name VariationDefaults

## --- Main Controls ---
@export var variation_mode_a: int = 0 # Sinusoidal ID
@export var variation_mode_b: int = 1 # Spherical ID
@export var start_pattern_mode: int = 0
@export var variation_mix: float = 0.5
@export var feedback_amount: float = 0.8
@export var feedback_min: float = 0.0
@export var feedback_max: float = 0.95
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
@export var circle_grid_scale: float = 8.0
@export var circle_grid_radius: float = 0.4
@export var circle_grid_softness: float = 0.05

## --- Escape Time (Orbit Trap) ---
@export var use_escape_time: bool = false
@export var escape_limit: float = 4.0
@export var escape_shape: int = 0
@export var escape_smoothness: float = 0.1
@export var escape_invert: bool = false

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
@export var wave_phase_a: float = 0.0
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
@export var clifford_a_a: float = -1.7
@export var clifford_b_a: float = 1.7
@export var clifford_c_a: float = -0.5
@export var clifford_d_a: float = -1.2
@export var clifford_a_a_speed: float = 0.0
@export var clifford_b_a_speed: float = 0.0
@export var clifford_c_a_speed: float = 0.0
@export var clifford_d_a_speed: float = 0.0

@export var dejong_a_a: float = 1.4
@export var dejong_b_a: float = 2.3
@export var dejong_c_a: float = 1.5
@export var dejong_d_a: float = -0.6

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

@export var popcorn_scale_a: float = 1.0
@export var popcorn_scale_a_speed: float = 0.0
@export var popcorn_strength_a: float = 0.1
@export var popcorn_strength_a_speed: float = 0.0
@export var popcorn_density_a: float = 3.0
@export var popcorn_density_a_speed: float = 0.0


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

@export var clifford_a_b: float = -1.7
@export var clifford_b_b: float = 1.7
@export var clifford_c_b: float = -0.5
@export var clifford_d_b: float = -1.2
@export var clifford_a_b_speed: float = 0.0
@export var clifford_b_b_speed: float = 0.0
@export var clifford_c_b_speed: float = 0.0
@export var clifford_d_b_speed: float = 0.0
@export var dejong_a_b: float = 1.4
@export var dejong_b_b: float = 2.3
@export var dejong_c_b: float = 1.5
@export var dejong_d_b: float = -0.6
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

@export var popcorn_scale_b: float = 1.0
@export var popcorn_scale_b_speed: float = 0.0
@export var popcorn_strength_b: float = 0.1
@export var popcorn_strength_b_speed: float = 0.0
@export var popcorn_density_b: float = 3.0
@export var popcorn_density_b_speed: float = 0.0

## --- Truchet A ---
@export var truchet_scale_a: float = 2.0
@export var truchet_rotate_a: float = 0.0
@export var truchet_strength_a: float = 0.1
@export var truchet_mode_a: float = 1.0

## --- Truchet B ---
@export var truchet_scale_b: float = 2.0
@export var truchet_rotate_b: float = 0.0
@export var truchet_strength_b: float = 0.1
@export var truchet_mode_b: float = 1.0

## --- 3D Controls (General) ---
@export var light_x_rotation: float = 0.0
@export var light_y_rotation: float = 0.0
@export var light_energy: float = 1.0
@export var light_color: Color = Color.WHITE
@export var light_shadows: bool = true
@export var normal_map_strength: float = 1.0
@export var camera_distance: float = 3.5
@export var camera_x_rotation: float = 0.0
@export var camera_y_rotation: float = 0.0
@export var camera_z_rotation: float = 0.0 # Added Z
@export var camera_fov: float = 75.0
@export var show_2d_background: bool = false

## --- 3D Surface / Material ---
@export var displacement_strength: float = 0.2
@export var height_offset: float = -0.5
@export var displacement_smoothness: float = 0.0
@export var limit_to_top: bool = false
@export var emission_strength: float = 0.0
@export var use_dynamic_material: bool = false
@export var grade_background_active: bool = false

## --- Raymarching (3D Fractals) ---
@export var mandel_power: float = 3.0
@export var ray_iterations: int = 12
@export var mandel_texture_intensity: float = 0.5
@export var mandel_texture_scale: float = 1.0

# Amazing Box / Surf Settings
@export var ab_fold_limit: float = 1.0
@export var ab_fixed_radius: float = 1.0

# Chaos Modifiers (ASurf & Others)
@export var as_fold_limit: float = 1.0
@export var as_rotate: Vector3 = Vector3.ZERO
@export var as_twist: Vector3 = Vector3.ZERO
@export var as_wave_strength: Vector3 = Vector3.ZERO
@export var as_wave_frequency: Vector3 = Vector3(4.0, 4.0, 4.0)
@export var as_julia: Vector3 = Vector3.ZERO

## --- Lazy Mega (A) ---
@export var lazy_shape_a: int = 0       # 0=Circle, 1=Square, 2=Diamond
@export var lazy_inside_mode_a: int = 0 # 0=Twist, 1=Travis, 2=Hole
@export var lazy_outside_mode_a: int = 0 # 0=Inverse, 1=Travis, 2=None
@export var lazy_amount_a: float = 0.5  # The size of the boundary
@export var lazy_twist_a: float = 0.2
@export var lazy_spin_a: float = 0.1
@export var lazy_space_a: float = 0.4
@export var lazy_offset_a: Vector2 = Vector2(0.1, 0.2)
@export var lazy_amount_a_speed: float = 0.0
@export var lazy_twist_a_speed: float = 0.0
@export var lazy_spin_a_speed: float = 0.0
@export var lazy_space_a_speed: float = 0.0
@export var lazy_ring_mode_a: int = 0 # 0=Empty, 1=Texture, 2=Rings, 3=Rays
@export var lazy_ring_spin_a: float = 0.0
@export var lazy_ring_spin_a_speed: float = 0.0
@export var lazy_edge_softness_a: float = 0.0
## --- Lazy Mega (B) ---
@export var lazy_shape_b: int = 0
@export var lazy_inside_mode_b: int = 0
@export var lazy_outside_mode_b: int = 0
@export var lazy_amount_b: float = 0.5
@export var lazy_twist_b: float = 0.2
@export var lazy_spin_b: float = 0.1
@export var lazy_space_b: float = 0.4
@export var lazy_offset_b: Vector2 = Vector2(0.1, 0.2)
@export var lazy_amount_b_speed: float = 0.0
@export var lazy_twist_b_speed: float = 0.0
@export var lazy_spin_b_speed: float = 0.0
@export var lazy_space_b_speed: float = 0.0
@export var lazy_ring_mode_b: int = 0
@export var lazy_ring_spin_b: float = 0.0
@export var lazy_ring_spin_b_speed: float = 0.0
@export var lazy_edge_softness_b: float = 0.0
## --- GlynnSim A ---
@export var glynn_radius_a: float = 1.0
@export var glynn_thickness_a: float = 0.1
@export var glynn_contrast_a: float = 0.5
@export var glynn_pow_a: float = 1.5
@export var glynn_phi1_a: float = 110.0
@export var glynn_phi2_a: float = 150.0
@export var glynn_radius_a_speed: float = 0.0
@export var glynn_thickness_a_speed: float = 0.0
@export var glynn_contrast_a_speed: float = 0.0
@export var glynn_pow_a_speed: float = 0.0
@export var glynn_phi1_a_speed: float = 0.0
@export var glynn_phi2_a_speed: float = 0.0
@export var glynn_ring_mode_a: int = 0

## --- GlynnSim B ---
@export var glynn_radius_b: float = 1.0
@export var glynn_thickness_b: float = 0.1
@export var glynn_contrast_b: float = 0.5
@export var glynn_pow_b: float = 1.5
@export var glynn_phi1_b: float = 110.0
@export var glynn_phi2_b: float = 150.0
@export var glynn_radius_b_speed: float = 0.0
@export var glynn_thickness_b_speed: float = 0.0
@export var glynn_contrast_b_speed: float = 0.0
@export var glynn_pow_b_speed: float = 0.0
@export var glynn_phi1_b_speed: float = 0.0
@export var glynn_phi2_b_speed: float = 0.0
@export var glynn_ring_mode_b: int = 0

## --- Nebula A ---
@export var nebula_scale_a: float = 2.0
@export var nebula_speed_a: float = 0.1
@export var nebula_detail_a: float = 5.0 # Octaves (Layers of noise)
@export var nebula_distortion_a: float = 0.5
@export var nebula_scale_a_speed: float = 0.0
@export var nebula_speed_a_speed: float = 0.0
@export var nebula_detail_a_speed: float = 0.0
@export var nebula_distortion_a_speed: float = 0.0
@export var nebula_swirl_a: float = 0.0
@export var nebula_swirl_a_speed: float = 0.0
@export var nebula_stars_a: float = 0.0 # 0 = None, 1 = Lots of stars
@export var nebula_filaments_a: float = 0.0 # 0=Soft, 1=Sharp
## --- Nebula B ---
@export var nebula_scale_b: float = 2.0
@export var nebula_speed_b: float = 0.1
@export var nebula_detail_b: float = 5.0
@export var nebula_distortion_b: float = 0.5
@export var nebula_scale_b_speed: float = 0.0
@export var nebula_speed_b_speed: float = 0.0
@export var nebula_detail_b_speed: float = 0.0
@export var nebula_distortion_b_speed: float = 0.0
@export var nebula_swirl_b: float = 0.0
@export var nebula_swirl_b_speed: float = 0.0
@export var nebula_stars_b: float = 0.0
@export var nebula_filaments_b: float = 0.0

## --- Jigsaw A ---
@export var jigsaw_scale_a: float = 5.0
@export var jigsaw_tab_size_a: float = 0.3
@export var jigsaw_distortion_a: float = 0.0 # 0=Clean, 1=Jumbled
@export var jigsaw_scale_a_speed: float = 0.0
@export var jigsaw_tab_size_a_speed: float = 0.0
@export var jigsaw_distortion_a_speed: float = 0.0
@export var jigsaw_outline_a: float = 0.0 # 0.0 = No Line, 0.1 = Thick Line
## --- Jigsaw B ---
@export var jigsaw_scale_b: float = 5.0
@export var jigsaw_tab_size_b: float = 0.3
@export var jigsaw_distortion_b: float = 0.0
@export var jigsaw_scale_b_speed: float = 0.0
@export var jigsaw_tab_size_b_speed: float = 0.0
@export var jigsaw_distortion_b_speed: float = 0.0
@export var jigsaw_outline_b: float = 0.0
