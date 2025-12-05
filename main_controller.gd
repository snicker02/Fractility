extends Control
const PROGRAM_VERSION = 3.1
const VariationPanel = preload("res://VariationPanel.gd")
# IDs for "inversive" variations that zoom in when scale INCREASES
const INVERSE_VARIATIONS = [1 ]


# --- Node References ---
@onready var overlay_stop_button: Button = %OverlayStopButton # (Remember to set Unique Name)
@onready var ui_sidebar: Panel = $HSplitContainer/Panel
@onready var viewport_a: SubViewport = %ViewportA
@onready var viewport_b: SubViewport = %ViewportB
@onready var final_output: TextureRect = %FinalOutput
@onready var file_dialog: FileDialog = %FileDialog
@onready var save_viewport: SubViewport = %SaveViewport
@onready var post_process_save_viewport: SubViewport = %PostProcessSaveViewport
@onready var fractal_mesh: MeshInstance3D = %FractalMesh
@onready var display_container_3d: SubViewportContainer = %Display_3D_Container # <-- Add reference to 3D view container
@onready var container_3d_controls: VBoxContainer = %Container3DControls
@onready var normal_map_viewport = $NormalMapViewport
@onready var normal_map_material = $NormalMapViewport/ColorRect.material
@onready var light_3d: DirectionalLight3D = %DirectionalLight3D
@onready var world_env: WorldEnvironment = %WorldEnvironment
@onready var camera_3d: Camera3D = %Camera3D
@onready var pause_animation_check: CheckBox = %PauseAnimationCheck
@onready var randomize_controls_container: VBoxContainer = %RandomizeControlsContainer
@onready var randomize_toggle_button: Button = %RandomizeToggleButton
@onready var randomize_speed_check: CheckBox = %RandomizeSpeedCheck
@onready var randomize_colors_check: CheckBox = %RandomizeColorsCheck
@onready var randomize_startup_check: CheckBox = %RandomizeOnStartupCheck
const PREFS_PATH = "user://prefs.cfg" # File path for persistent settings
@onready var randomize_params_check: CheckBox = %RandomizeParamsCheck
@onready var randomize_variations_check: CheckBox = %RandomizeVariationsCheck
@onready var displacement_slider: HSlider = %DisplacementSlider
@onready var displacement_spinbox: SpinBox = %DisplacementSpinBox
var displacement_strength: float = 0.0
@onready var emission_slider: HSlider = %EmissionSlider
@onready var emission_spinbox: SpinBox = %EmissionSpinBox
var emission_strength: float = 0.0
@onready var height_offset_slider: HSlider = %HeightOffsetSlider
@onready var height_offset_spinbox: SpinBox = %HeightOffsetSpinBox
var height_offset: float = -0.5
@onready var smoothness_slider: HSlider = %SmoothnessSlider
@onready var smoothness_spinbox: SpinBox = %SmoothnessSpinBox
var displacement_smoothness: float = 0.0
@onready var auto_rotate_check: CheckBox = %AutoRotateCheck
@onready var rotate_speed_slider: HSlider = %RotateSpeedSlider
var auto_rotate_active: bool = false
var rotate_speed: float = 0.5
@onready var dynamic_material_check: CheckBox = %DynamicMaterialCheck
var use_dynamic_material: bool = false
@onready var grade_background_check: CheckBox = %GradeBackgroundCheck
var grade_background_active: bool = false
@onready var limit_top_check: CheckBox = %LimitTopCheck
var limit_to_top: bool = false
@onready var mandel_controls: VBoxContainer = %MandelbulbControls # (Or whatever path you used)
@onready var mandel_power_slider: HSlider = %MandelPowerSlider
@onready var mandel_power_spinbox: SpinBox = %MandelPowerSpinBox
var mandel_power: float = 3.0
var is_raymarching: bool = false
@onready var mandel_mix_slider: HSlider = %MandelMixSlider
@onready var mandel_scale_slider: HSlider = %MandelScaleSlider
@onready var standard_mesh_controls: VBoxContainer = %StandardMeshControls

@onready var mandel_mix_spinbox: SpinBox = %MandelMixSpinBox
@onready var mandel_scale_spinbox: SpinBox = %MandelScaleSpinBox
@onready var rotate_speed_spinbox: SpinBox = %RotateSpeedSpinBox
var auto_rotate_vector: Vector3 = Vector3(0, 1, 0) # Default to Y-axis spin
@onready var iter_slider: HSlider = %IterSlider
@onready var iter_spinbox: SpinBox = %IterSpinBox
var ray_iterations: int = 12
@onready var ab_params: VBoxContainer = %AmazingBoxParams
@onready var ab_fold_slider: HSlider = %ABFoldLimitSlider
@onready var ab_fold_spinbox: SpinBox = %ABFoldLimitSpinBox # <--- NEW
@onready var ab_rad_slider: HSlider = %ABFixedRadSlider
@onready var ab_rad_spinbox: SpinBox = %ABFixedRadSpinBox   # <--- NEW

var ab_fold_limit: float = 1.0
var ab_fixed_radius: float = 1.0

@onready var escape_time_check: CheckBox = %EscapeTimeCheck
@onready var escape_limit_slider: HSlider = %EscapeLimitSlider
@onready var escape_limit_spinbox: SpinBox = %EscapeLimitSpinBox # Uncomment if you add one

var use_escape_time: bool = false
var escape_limit: float = 4.0

@onready var escape_shape_dropdown: OptionButton = %EscapeShapeDropdown
var escape_shape: int = 0

@onready var quality_dropdown: OptionButton = %QualityDropdown
var current_step_speed: float = 0.25 # Default to Balanced
@onready var escape_smooth_slider: HSlider = %EscapeSmoothSlider
@onready var escape_smooth_spinbox: SpinBox = %EscapeSmoothSpinBox
@onready var escape_invert_check: CheckBox = %EscapeInvertCheck

var escape_smoothness: float = 0.1
var escape_invert: bool = false


# --- MINI GAME VARIABLES ---
@onready var game_start_btn: Button = %GameStartButton # Make sure to set Unique Name
@onready var score_label: Label = %ScoreLabel          # Make sure to set Unique Name
@onready var player_hitbox: Area3D = %Camera3D/PlayerHitbox # Update path if needed

var game_score: int = 0
var game_max_orbs: int = 10
var game_active: bool = false
var game_orbs: Array[Node3D] = []

func spawn_orb():
	var orb = Area3D.new()
	var mesh_inst = MeshInstance3D.new()
	var collider = CollisionShape3D.new()
	
	# --- 1. RANDOM SHAPE (Now Smaller!) ---
	var shape_type = randi() % 3
	var mesh_geo
	var col_shape
	
	if shape_type == 0: 
		# CRYSTAL (Tiny Gem)
		var m = SphereMesh.new()
		m.radius = 0.12  # Was 0.25
		m.height = 0.3   # Was 0.5
		m.radial_segments = 4
		m.rings = 2
		mesh_geo = m
		col_shape = SphereShape3D.new()
		col_shape.radius = 0.12
		
	elif shape_type == 1:
		# DATA CUBE (Tiny Box)
		var m = BoxMesh.new()
		m.size = Vector3(0.2, 0.2, 0.2) # Was 0.35
		mesh_geo = m
		col_shape = BoxShape3D.new()
		col_shape.size = m.size
		
	else:
		# PYRAMID (Tiny Shard)
		var m = PrismMesh.new()
		m.size = Vector3(0.2, 0.2, 0.05) # Was 0.4
		mesh_geo = m
		col_shape = BoxShape3D.new()
		col_shape.size = Vector3(0.2, 0.2, 0.1)

	mesh_inst.mesh = mesh_geo
	collider.shape = col_shape

	# --- 2. MATERIAL (Glowing Neon) ---
	var mat = StandardMaterial3D.new()
	var hue = randf_range(0.3, 0.6) # Green -> Cyan -> Blue range
	mat.albedo_color = Color.from_hsv(hue, 1.0, 1.0)
	
	mat.roughness = 0.1
	mat.metallic = 0.8 # More metallic for that "artifact" look
	mat.emission_enabled = true
	mat.emission = Color.from_hsv(hue, 1.0, 1.0)
	mat.emission_energy_multiplier = 2.0
	mat.rim_enabled = true
	mat.rim = 0.5
	
	mesh_inst.material_override = mat
	
	# Build Tree
	orb.add_child(mesh_inst)
	orb.add_child(collider)
	
	# --- 3. SPIN ANIMATION ---
	var tween = orb.create_tween().set_loops()
	var rand_time = randf_range(1.5, 3.0) # Spin slightly faster since they are smaller
	tween.tween_property(mesh_inst, "rotation", Vector3(0, TAU, TAU), rand_time).as_relative()

	# --- 4. SMART POSITIONING ---
	var spawn_range = 2.0 
	var current_shape = shape_selector_button.selected
	
	if current_shape == 5: spawn_range = 1.1 
	elif current_shape == 6: spawn_range = 0.9 
	elif current_shape == 7: spawn_range = 2.0
	elif current_shape == 8: spawn_range = 2.5
	
	orb.position = Vector3(
		randf_range(-spawn_range, spawn_range),
		randf_range(-spawn_range, spawn_range),
		randf_range(-spawn_range, spawn_range)
	)
	
	%Camera3D.get_parent().add_child(orb) 
	game_orbs.append(orb)
	
	orb.area_entered.connect(func(area): 
		if area == %Camera3D.get_node("PlayerHitbox"):
			collect_orb(orb)
	)

func start_mini_game():
	# Clear old game
	for orb in game_orbs:
		if is_instance_valid(orb): orb.queue_free()
	game_orbs.clear()
	
	game_score = 0
	game_active = true
	score_label.visible = true
	score_label.text = "Orbs: 0 / " + str(game_max_orbs)
	
	# Spawn new orbs
	for i in range(game_max_orbs):
		spawn_orb()
		
	print("Game Started! Find the orbs inside the fractal.")

func collect_orb(orb: Node3D):
	if not game_active: return
	
	# Play a sound here if you have an AudioStreamPlayer!
	
	orb.queue_free() # Remove orb
	game_orbs.erase(orb)
	
	game_score += 1
	score_label.text = "Orbs: " + str(game_score) + " / " + str(game_max_orbs)
	
	if game_score >= game_max_orbs:
		win_game()

func win_game():
	game_active = false
	score_label.text = "YOU WIN! All Fractals Collected!"
	
	# Victory visual effect?
	# Let's spin the camera crazy for a second!
	auto_rotate_active = true
	rotate_speed = 2.0

# Wave Variables
@onready var as_wave_str_x_slider: HSlider = %ASWaveStrXSlider
@onready var as_wave_str_x_spinbox: SpinBox = %ASWaveStrXSpinBox
@onready var as_wave_str_y_slider: HSlider = %ASWaveStrYSlider
@onready var as_wave_str_y_spinbox: SpinBox = %ASWaveStrYSpinBox
@onready var as_wave_str_z_slider: HSlider = %ASWaveStrZSlider
@onready var as_wave_str_z_spinbox: SpinBox = %ASWaveStrZSpinBox

@onready var as_wave_freq_x_slider: HSlider = %ASWaveFreqXSlider
@onready var as_wave_freq_x_spinbox: SpinBox = %ASWaveFreqXSpinBox
@onready var as_wave_freq_y_slider: HSlider = %ASWaveFreqYSlider
@onready var as_wave_freq_y_spinbox: SpinBox = %ASWaveFreqYSpinBox
@onready var as_wave_freq_z_slider: HSlider = %ASWaveFreqZSlider
@onready var as_wave_freq_z_spinbox: SpinBox = %ASWaveFreqZSpinBox

var as_wave_str: Vector3 = Vector3.ZERO
var as_wave_freq: Vector3 = Vector3(4.0, 4.0, 4.0)

# --- Amazing Surf Variables ---
@onready var as_params: VBoxContainer = %AmazingSurfParams
@onready var as_fold_slider: HSlider = %ASFoldLimitSlider
@onready var as_fold_spinbox: SpinBox = %ASFoldLimitSpinBox # <--- NEW

@onready var as_rot_x_slider: HSlider = %ASRotXSlider
@onready var as_rot_x_spinbox: SpinBox = %ASRotXSpinBox     # <--- NEW
@onready var as_rot_y_slider: HSlider = %ASRotYSlider
@onready var as_rot_y_spinbox: SpinBox = %ASRotYSpinBox     # <--- NEW
@onready var as_rot_z_slider: HSlider = %ASRotZSlider
@onready var as_rot_z_spinbox: SpinBox = %ASRotZSpinBox     # <--- NEW

var as_fold_limit: float = 1.0
var as_rotate: Vector3 = Vector3.ZERO
@onready var as_julia_x_slider: HSlider = %ASJuliaXSlider
@onready var as_julia_x_spinbox: SpinBox = %ASJuliaXSpinBox
@onready var as_julia_y_slider: HSlider = %ASJuliaYSlider
@onready var as_julia_y_spinbox: SpinBox = %ASJuliaYSpinBox
@onready var as_julia_z_slider: HSlider = %ASJuliaZSlider
@onready var as_julia_z_spinbox: SpinBox = %ASJuliaZSpinBox

var as_julia: Vector3 = Vector3.ZERO

# Twist Variables
@onready var as_twist_x_slider: HSlider = %ASTwistXSlider
@onready var as_twist_x_spinbox: SpinBox = %ASTwistXSpinBox
@onready var as_twist_y_slider: HSlider = %ASTwistYSlider
@onready var as_twist_y_spinbox: SpinBox = %ASTwistYSpinBox
@onready var as_twist_z_slider: HSlider = %ASTwistZSlider
@onready var as_twist_z_spinbox: SpinBox = %ASTwistZSpinBox

var as_twist: Vector3 = Vector3.ZERO

var mandel_texture_intensity: float = 0.5
var mandel_texture_scale: float = 1.0

# --- Node References ---
# Main Layout
#@onready var collapse_button: Button = %CollapseButton
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var load_image_button: Button = %LoadImageButton
@onready var mirror_tiling_check_box: CheckBox = %MirrorTilingCheckBox
@onready var shape_selector_button: OptionButton = %ShapeSelectorButton
# Main Controls
@onready var var_a_dropdown: OptionButton = %VarADropdown
@onready var var_b_dropdown: OptionButton = %VarBDropdown
@onready var rep_tile_panel_a: VBoxContainer = %RepTilePanelA
@onready var rep_tile_dropdown_a: OptionButton = %RepTileDropdownA
@onready var rep_tile_panel_b: VBoxContainer = %RepTilePanelB
@onready var rep_tile_dropdown_b: OptionButton = %RepTileDropdownB
@onready var start_pattern_dropdown: OptionButton = %StartPatternDropdown
@onready var tiling_check_box: CheckBox = %TilingCheckBox
@onready var reset_on_drag_check: CheckBox = %ResetOnDragCheck
@onready var resolution_dropdown: OptionButton = %ResolutionDropdown
@onready var save_button: Button = %SaveButton
@onready var save_preset_button: Button = %SavePresetButton
@onready var load_preset_button: Button = %LoadPresetButton
@onready var copy_preset_button: Button = %CopyPresetButton
@onready var paste_preset_button: Button = %PastePresetButton

# Contextual Containers
@onready var gradient_controls_container: VBoxContainer = %GradientControlsContainer
@onready var wave_controls_container_a: VBoxContainer = %WaveControlsContainerA
@onready var wave_controls_container_b: VBoxContainer = %WaveControlsContainerB
@onready var circle_controls_container: VBoxContainer = %CircleControlsContainer
@onready var circle_grid_controls_container: VBoxContainer = %CircleGridControlsContainer
@onready var circle_grid_scale_slider: HSlider = %CircleGridScaleSlider
@onready var circle_grid_scale_spinbox: SpinBox = %CircleGridScaleSpinBox
@onready var circle_grid_radius_slider: HSlider = %CircleGridRadiusSlider
@onready var circle_grid_radius_spinbox: SpinBox = %CircleGridRadiusSpinBox
@onready var circle_grid_softness_slider: HSlider = %CircleGridSoftnessSlider
@onready var circle_grid_softness_spinbox: SpinBox = %CircleGridSoftnessSpinBox
@onready var julian_controls_container_a: VBoxContainer = %JulianControlsContainerA
@onready var julian_controls_container_b: VBoxContainer = %JulianControlsContainerB
@onready var fisheye_controls_container_a: VBoxContainer = %FisheyeControlsContainerA
@onready var polar_controls_container_a: VBoxContainer = %PolarControlsContainerA
@onready var fisheye_controls_container_b: VBoxContainer = %FisheyeControlsContainerB
@onready var polar_controls_container_b: VBoxContainer = %PolarControlsContainerB
@onready var mobius_controls_container_a: VBoxContainer = %MobiusControlsContainerA
@onready var mobius_controls_container_b: VBoxContainer = %MobiusControlsContainerB
@onready var cellular_weave_controls_container_a: VBoxContainer = %CellularWeaveControlsContainerA
@onready var cellular_weave_controls_container_b: VBoxContainer = %CellularWeaveControlsContainerB
@onready var blur_controls_container_a: VBoxContainer = %BlurControlsContainerA
@onready var blur_controls_container_b: VBoxContainer = %BlurControlsContainerB
@onready var heart_controls_container_a: VBoxContainer = %HeartControlsContainerA
@onready var heart_controls_container_b: VBoxContainer = %HeartControlsContainerB
@onready var apollonian_controls_container_a: VBoxContainer = %ApollonianControlsContainerA
@onready var apollonian_controls_container_b: VBoxContainer = %ApollonianControlsContainerB
@onready var cosine_controls_container_a: VBoxContainer = %CosineControlsContainerA
@onready var cosine_controls_container_b: VBoxContainer = %CosineControlsContainerB
@onready var sinusoidal_controls_container_a: VBoxContainer = %SinusoidalControlsContainerA
@onready var sinusoidal_controls_container_b: VBoxContainer = %SinusoidalControlsContainerB
@onready var spherical_controls_container_a: VBoxContainer = %SphericalControlsContainerA
@onready var spherical_controls_container_b: VBoxContainer = %SphericalControlsContainerB
@onready var tangent_controls_container_a: VBoxContainer = %TangentControlsContainerA
@onready var tangent_controls_container_b: VBoxContainer = %TangentControlsContainerB

# Symmetry Control Containers
@onready var var_a_mirror_controls: VBoxContainer = %VarAMirrorControlsContainer
@onready var var_a_kaleidoscope_controls: VBoxContainer = %VarAKaleidoscopeControlsContainer
@onready var var_b_mirror_controls: VBoxContainer = %VarBMirrorControlsContainer
@onready var var_b_kaleidoscope_controls: VBoxContainer = %VarBKaleidoscopeControlsContainer
@onready var post_mirror_controls: VBoxContainer = %PostMirrorControlsContainer
@onready var post_kaleidoscope_controls: VBoxContainer = %PostKaleidoscopeControlsContainer
@onready var post_mirror_options: HBoxContainer = %PostMirrorOptions
@onready var post_kaleidoscope_options: HBoxContainer = %PostKaleidoscopeOptions
@onready var post_mirror_x_check: CheckBox = %PostMirrorXCheck
@onready var post_mirror_y_check: CheckBox = %PostMirrorYCheck
@onready var post_kaleidoscope_master_check: CheckBox = %PostKaleidoscopeMasterCheck
@onready var post_kaleidoscope_slider: HSlider = %PostKaleidoscopeSlicesSlider
@onready var post_kaleidoscope_spinbox: SpinBox = %PostKaleidoscopeSlicesSpinBox

# Start Pattern Controls
@onready var show_grid_check: CheckBox = %ShowGridCheck
@onready var show_circles_check: CheckBox = %ShowCirclesCheck

# Transform Controls
@onready var post_translate_radio: CheckBox = %PostTranslateRadio
@onready var pre_translate_radio: CheckBox = %PreTranslateRadio
@onready var var_a_translate_radio: CheckBox = %VarATranslateRadio
@onready var var_b_translate_radio: CheckBox = %VarBTranslateRadio

# Color & Symmetry Pickers/Checkboxes
@onready var gradient_toggle_button: Button = %GradientToggleButton
@onready var grad_col_tl_picker: ColorPickerButton = %GradColTLPicker
@onready var grad_col_tr_picker: ColorPickerButton = %GradColTRPicker
@onready var grad_col_bl_picker: ColorPickerButton = %GradColBLPicker
@onready var grad_col_br_picker: ColorPickerButton = %GradColBRPicker

# Sliders & SpinBoxes (Grouped by name)
@onready var var_mix_slider: HSlider = %VarMixSlider
@onready var var_mix_spinbox: SpinBox = %VarMixSpinBox
@onready var feedback_amount_slider: HSlider = %FeedbackAmountSlider
@onready var feedback_amount_spinbox: SpinBox = %FeedbackAmountSpinBox
@onready var feedback_range_min_spinbox: SpinBox = %FeedbackRangeMinSpinBox
@onready var feedback_range_max_spinbox: SpinBox = %FeedbackRangeMaxSpinBox
@onready var pre_scale_slider: HSlider = %PreScaleSlider
@onready var pre_scale_spinbox: SpinBox = %PreScaleSpinBox
@onready var pre_rotation_slider: HSlider = %PreRotationSlider
@onready var pre_rotation_spinbox: SpinBox = %PreRotationSpinBox
@onready var post_scale_slider: HSlider = %PostScaleSlider
@onready var post_scale_spinbox: SpinBox = %PostScaleSpinBox
@onready var post_rotation_slider: HSlider = %PostRotationSlider
@onready var post_rotation_spinbox: SpinBox = %PostRotationSpinBox
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var brightness_spinbox: SpinBox = %BrightnessSpinBox
@onready var contrast_slider: HSlider = %ContrastSlider
@onready var contrast_spinbox: SpinBox = %ContrastSpinBox
@onready var saturation_slider: HSlider = %SaturationSlider
@onready var saturation_spinbox: SpinBox = %SaturationSpinBox
@onready var circle_count_slider: HSlider = %CircleCountSlider
@onready var circle_count_spinbox: SpinBox = %CircleCountSpinBox
@onready var circle_radius_slider: HSlider = %CircleRadiusSlider
@onready var circle_radius_spinbox: SpinBox = %CircleRadiusSpinBox
@onready var circle_softness_slider: HSlider = %CircleSoftnessSlider
@onready var circle_softness_spinbox: SpinBox = %CircleSoftnessSpinBox


@onready var blur_amount_slider_a: HSlider = %BlurAmountSliderA
@onready var blur_amount_spinbox_a: SpinBox = %BlurAmountSpinBoxA 
@onready var blur_amount_slider_b: HSlider = %BlurAmountSliderB
@onready var blur_amount_spinbox_b: SpinBox = %BlurAmountSpinBoxB 

@onready var custom_2x2_controls_container_a: VBoxContainer = %Custom2x2ControlsContainerA
@onready var custom_tl_a: OptionButton = %CustomTLA
@onready var custom_tr_a: OptionButton = %CustomTRA
@onready var custom_bl_a: OptionButton = %CustomBLA
@onready var custom_br_a: OptionButton = %CustomBRA
@onready var custom_2x2_controls_container_b: VBoxContainer = %Custom2x2ControlsContainerB
@onready var custom_tl_b: OptionButton = %CustomTLB
@onready var custom_tr_b: OptionButton = %CustomTRB
@onready var custom_bl_b: OptionButton = %CustomBLB
@onready var custom_br_b: OptionButton = %CustomBRB
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var record_timer: Timer = %RecordTimer
@onready var record_button: Button = %RecordButton # (You already have this)
@onready var arctangent_controls_container_a: VBoxContainer = %ArcTangentControlsContainerA
@onready var arctangent_controls_container_b: VBoxContainer = %ArcTangentControlsContainerB
@onready var hyperbolic_cosine_controls_container_a: VBoxContainer = %HyperbolicCosineControlsContainerA
@onready var hyperbolic_cosine_controls_container_b: VBoxContainer = %HyperbolicCosineControlsContainerB
@onready var hyperbolic_sine_controls_container_a: VBoxContainer = %HyperbolicSineControlsContainerA
@onready var hyperbolic_sine_controls_container_b: VBoxContainer = %HyperbolicSineControlsContainerB
@onready var swirl_controls_container_a: VBoxContainer = %SwirlControlsContainerA
@onready var swirl_controls_container_b: VBoxContainer = %SwirlControlsContainerB
@onready var popcorn_controls_container_a: VBoxContainer = %PopcornControlsContainerA
@onready var popcorn_controls_container_b: VBoxContainer = %PopcornControlsContainerB
@onready var reptile_vars_a: VBoxContainer = %RepTilePanelA.get_node("VariationPanel")
@onready var reptile_vars_b: VBoxContainer = %RepTilePanelB.get_node("VariationPanel")
@onready var lazy_mega_controls_container_a: VBoxContainer = %LazyMegaControlsContainerA
@onready var lazy_mega_controls_container_b: VBoxContainer = %LazyMegaControlsContainerB
@onready var glynn_sim_controls_container_a: VBoxContainer = %GlynnSimControlsContainerA
@onready var glynn_sim_controls_container_b: VBoxContainer = %GlynnSimControlsContainerB
@onready var nebula_controls_container_a: VBoxContainer = %NebulaControlsContainerA
@onready var nebula_controls_container_b: VBoxContainer = %NebulaControlsContainerB
@onready var jigsaw_controls_container_a: VBoxContainer = %JigsawControlsContainerA
@onready var jigsaw_controls_container_b: VBoxContainer = %JigsawControlsContainerB










var is_recording: bool = false
var frame_counter: int = 0
var recording_dir: String = "user://recordings/"
#var video_output_path: String = "user://recordings/output.mp4"

@onready var light_x_angle_spinbox: SpinBox = %LightXAngleSpinBox
@onready var light_y_angle_spinbox: SpinBox = %LightYAngleSpinBox
@onready var light_energy_spinbox: SpinBox = %LightEnergySpinBox
@onready var camera_dist_spinbox: SpinBox = %CameraDistSpinBox
@onready var camera_x_rot_spinbox: SpinBox = %CameraXRotSpinBox
@onready var camera_y_rot_spinbox: SpinBox = %CameraYRotSpinBox
@onready var camera_z_rot_spinbox: SpinBox = %CameraZRotSpinBox
@onready var camera_fov_spinbox: SpinBox = %CameraFovSpinBox
@onready var clifford_controls_container_a: VBoxContainer = %CliffordControlsContainerA
@onready var clifford_controls_container_b: VBoxContainer = %CliffordControlsContainerB
@onready var dejong_controls_container_a: VBoxContainer = %DeJongControlsContainerA
@onready var dejong_controls_container_b: VBoxContainer = %DeJongControlsContainerB
@onready var truchet_controls_container_a: VBoxContainer = %TruchetControlsContainerA
@onready var truchet_controls_container_b: VBoxContainer = %TruchetControlsContainerB

#@export var ui_scene: PackedScene
@export var default_settings: VariationDefaults

# --- Control Variables ---
var variation_mode_a: int = 0 # Default Sinusoidal ID
var variation_mode_b: int = 1 # Default Spherical IDl"
var var_a_panels: Dictionary = {}
var var_b_panels: Dictionary = {}
var start_pattern_mode: int = 0
var variation_mix: float = 0.5
var feedback_amount: float = 0.98
var feedback_min: float 
var feedback_max: float 
var seamless_tiling: bool = true
var reset_on_drag_enabled: bool = true
var show_start_grid: bool = false
var show_circles: bool = true
var brightness: float = 1.0
var contrast: float = 1.0
var saturation: float = 1.0
var save_resolution_index: int = 1
var active_translate_target: int = 0
var circle_count: float = 4.0
var circle_radius: float = 0.2
var circle_softness: float = 0.05
var circle_grid_scale: float   
var circle_grid_radius: float  
var circle_grid_softness: float
var mirror_x: bool = false
var mirror_y: bool = false
var kaleidoscope_on: bool = false
var kaleidoscope_slices: float = 6.0
@onready var raymarch_core_params: VBoxContainer = %RaymarchCoreParams

var background_texture: Texture2D
var file_dialog_mode: String = "save"
var mirror_tiling: bool = false
var is_3d_view: bool = false
var normal_map_texture: ImageTexture = null

var move_post_translate: bool = true
var move_pre_translate: bool = false
var move_var_a_translate: bool = false
var move_var_b_translate: bool = false

var grad_col_tl: Color = Color.CYAN
var grad_col_tr: Color = Color.YELLOW
var grad_col_bl: Color = Color.BLUE
var grad_col_br: Color = Color.RED


var translate_a: Vector2
var translate_b: Vector2
var pre_scale: float
var pre_rotation: float
var pre_translate: Vector2
var post_scale: float
var post_rotation: float
var post_translate: Vector2



var blur_amount_a: float
var blur_amount_b: float

# Custom 2x2 Tile Vars
var custom_tl_a_id: int
var custom_tr_a_id: int
var custom_bl_a_id: int
var custom_br_a_id: int
var custom_tl_b_id: int
var custom_tr_b_id: int
var custom_bl_b_id: int
var custom_br_b_id: int


var _auto_params_a: Dictionary = {}
var _auto_params_b: Dictionary = {}
var _speed_controls: Dictionary = {}
var anim_lib = AnimationLibrary.new()

# --- 3D Light Controls ---
var light_x_rotation: float   # Default from your screenshot
var light_y_rotation: float  # Default from your screenshot
var light_energy: float 
var light_color: Color 
var light_shadows: bool

var normal_map_strength: float


# --- 3D Camera Controls ---
var camera_distance: float = 3.5 # How far the camera is from the center
var camera_x_rotation: float = 0.0 # Rotation around the horizontal axis (pitch)
var camera_y_rotation: float = 0.0 # Rotation around the vertical axis (yaw)
var camera_z_rotation: float = 0.0
var camera_fov: float = 75.0 # Field of View

# --- 3D Background Control ---
var show_2d_background: bool = false

# --- Private Variables ---
var time: float = 0.0
var is_a_source = true

var post_process_material: ShaderMaterial
var _preset_json_to_save: String

var version_label: Label
var animation_paused: bool = false

func _set_platform_feedback_defaults() -> void:
	# This function is no longer needed.
	# We get the defaults from the resource file.
	pass

func _update_camera() -> void:
	if is_instance_valid(camera_3d):
		# Reset rotation first
		camera_3d.rotation = Vector3.ZERO
		
		# 1. Yaw (Y-Axis)
		camera_3d.rotate_y(deg_to_rad(camera_y_rotation))
		
		# 2. Pitch (Local X-Axis)
		camera_3d.rotate_object_local(Vector3.RIGHT, deg_to_rad(camera_x_rotation))
		
		# 3. Roll (Local Z-Axis) -- NEW
		# We use Vector3.BACK because in Godot, the camera looks towards -Z.
		camera_3d.rotate_object_local(Vector3.BACK, deg_to_rad(camera_z_rotation))
		
		# Move the camera backwards along its new local Z-axis
		camera_3d.position = camera_3d.global_transform.basis.z * camera_distance
		
		# Set Field of View
		camera_3d.fov = camera_fov

func _update_background() -> void:
	if is_instance_valid(world_env):
		var env: Environment = world_env.environment
		if is_instance_valid(env):
			if show_2d_background:
				env.background_mode = Environment.BG_CANVAS # Use 2D parent canvas
			else:
				env.background_mode = Environment.BG_COLOR # Use solid color
				env.background_color = Color(0.3, 0.3, 0.3) # Default gray, adjust as needed
		else:
			printerr("ERROR: WorldEnvironment node has no Environment resource!")
	else:
		printerr("ERROR: WorldEnvironment node not found for background update!")

func _update_light() -> void:
	if is_instance_valid(light_3d):
		
		light_3d.rotation_degrees.x = light_x_rotation
		light_3d.rotation_degrees.y = light_y_rotation
		light_3d.light_energy = light_energy
		light_3d.light_color = light_color
		light_3d.shadow_enabled = light_shadows
		# --- Toggle Post-Process Shadows (SSAO) ---
		if is_instance_valid(world_env):
			var env: Environment = world_env.environment
			if is_instance_valid(env):
				env.ssao_enabled = light_shadows
			else:
				printerr("ERROR: WorldEnvironment node has no Environment resource!")
		else:
			printerr("ERROR: WorldEnvironment node not found!")


func _ready() -> void:
	# --- ALL VAR DECLARATIONS MUST GO FIRST ---
	var window_size = get_viewport().get_visible_rect().size
	var viewport_3d = display_container_3d.get_child(0) as SubViewport
	var feedback_material = ShaderMaterial.new()
	
	var initial_normal_img: Image
	var current_fractal_texture
	var post_save_material = ShaderMaterial.new()


	if overlay_stop_button:
		overlay_stop_button.pressed.connect(func(): 
			# Toggle the main record button OFF. 
			# This triggers _on_record_button_toggled(false) automatically.
			record_button.button_pressed = false 
		)
	# --- NOW, THE REST OF THE CODE CAN RUN ---
	randomize_controls_container.visible = false
	# --- Ensure WorldEnvironment has an Environment ---
	if is_instance_valid(world_env) and not is_instance_valid(world_env.environment):
		print("WARNING: WorldEnvironment has no Environment resource. Creating one.")
		world_env.environment = Environment.new()
		# Set default background for the new environment
		world_env.environment.background_mode = Environment.BG_COLOR
		world_env.environment.background_color = Color(0.3, 0.3, 0.3)
	# --- End Check ---
	gradient_controls_container.visible = false
	# --- NEW: POPULATE DROPDOWNS FIRST ---
	_populate_all_dropdowns()
	
	# NOTE: update_mode for SaveViewport must be set to 'Always' in the Inspector
	save_viewport.get_node("ShaderRect").anchors_preset = Control.PRESET_FULL_RECT

	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_PICTURES)
	
	#_set_platform_feedback_defaults() # This is now handled by reset_visuals()
	
	print("DEBUG: window_size in _ready:", window_size) # <-- Add check for size
	# --- FIX: Synchronize all viewports to the window size at startup ---
	if window_size.x <= 0 or window_size.y <= 0:
		await get_tree().process_frame
		window_size = get_viewport().get_visible_rect().size
		if window_size.x <= 0 or window_size.y <= 0:
			printerr("FATAL: Window size is still invalid. Cannot initialize viewports.")
			return # Abort
			
	# Set the sizes *before* creating any textures
	viewport_a.size = window_size
	viewport_b.size = window_size
	# --- END FIX ---
	
	#if is_instance_valid(viewport_3d):
		#viewport_3d.size = window_size

	feedback_material.shader = load("res://fractal_feedback.gdshader")
	%ViewportA.get_node("ShaderRect").material = feedback_material
	%ViewportB.get_node("ShaderRect").material = feedback_material.duplicate()
	%SaveViewport.get_node("ShaderRect").material = feedback_material.duplicate()
	post_process_material = ShaderMaterial.new()
	post_process_material.shader = load("res://post_process.gdshader")
	final_output.material = post_process_material
	
	var_a_panels = {
		"apollonian": apollonian_controls_container_a,
		"arctangent": arctangent_controls_container_a,
		"blur": blur_controls_container_a,
		"cellular_weave": cellular_weave_controls_container_a,
		"cosine": cosine_controls_container_a,
		"fisheye": fisheye_controls_container_a,
		"heart": heart_controls_container_a,
		"hyperbolic_cosine": hyperbolic_cosine_controls_container_a,
		"hyperbolic_sine": hyperbolic_sine_controls_container_a,
		"julian": julian_controls_container_a,
		"kaleidoscope": var_a_kaleidoscope_controls, # Use the correct node
		"mirror": var_a_mirror_controls,# Use the correct node
		"mobius": mobius_controls_container_a,
		"polar": polar_controls_container_a,
		"wave": wave_controls_container_a,
		"clifford": clifford_controls_container_a, 
		"dejong": dejong_controls_container_a,     
		"truchet": truchet_controls_container_a,
		"sinusoidal": sinusoidal_controls_container_a,
		"spherical": spherical_controls_container_a,
		"swirl": swirl_controls_container_a,
		"tangent": tangent_controls_container_a,
		"popcorn": popcorn_controls_container_a,
		"lazy_mega": lazy_mega_controls_container_a,
		"glynn_sim": glynn_sim_controls_container_a,
		"nebula": nebula_controls_container_a,
		"jigsaw": jigsaw_controls_container_a,
		"rep_tile": rep_tile_panel_a # Special key for the Rep-Tile panel
		
		

	}
	
	var_b_panels = {
		"apollonian": apollonian_controls_container_b,
		"arctangent": arctangent_controls_container_b,
		"blur": blur_controls_container_b,
		"cellular_weave": cellular_weave_controls_container_b,
		"cosine": cosine_controls_container_b,
		"fisheye": fisheye_controls_container_b,
		"heart": heart_controls_container_b,
		"hyperbolic_cosine": hyperbolic_cosine_controls_container_b,
		"hyperbolic_sine": hyperbolic_sine_controls_container_b,
		"julian": julian_controls_container_b,
		"kaleidoscope": var_b_kaleidoscope_controls, # Use the correct node
		"mirror": var_b_mirror_controls,# Use the correct node
		"mobius": mobius_controls_container_b,
		"polar": polar_controls_container_b,
		"wave": wave_controls_container_b,
		"clifford": clifford_controls_container_b, 
		"dejong": dejong_controls_container_b,     
		"truchet": truchet_controls_container_b,
		"sinusoidal": sinusoidal_controls_container_b,
		"spherical": spherical_controls_container_b,
		"swirl": swirl_controls_container_b,
		"tangent": tangent_controls_container_b,
		"popcorn": popcorn_controls_container_b,
		"lazy_mega": lazy_mega_controls_container_b,
		"glynn_sim": glynn_sim_controls_container_b,
		"nebula": nebula_controls_container_b,
		"jigsaw": jigsaw_controls_container_b,
		"rep_tile": rep_tile_panel_b # Special key for the Rep-Tile panel
	}
	
	# --- Connect new UI panels ---
	pause_animation_check.toggled.connect(_on_pause_animation_check_toggled)
	clifford_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	clifford_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	dejong_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	dejong_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	truchet_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	truchet_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	wave_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	wave_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	julian_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	julian_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	fisheye_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	fisheye_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	apollonian_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	apollonian_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	arctangent_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	arctangent_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	cellular_weave_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	cellular_weave_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	cosine_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	cosine_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	heart_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	heart_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	hyperbolic_cosine_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	hyperbolic_cosine_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	hyperbolic_sine_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	hyperbolic_sine_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	var_a_kaleidoscope_controls.value_updated.connect(_on_variation_param_changed.bind("a"))
	var_b_kaleidoscope_controls.value_updated.connect(_on_variation_param_changed.bind("b"))
	var_a_mirror_controls.value_updated.connect(_on_variation_param_changed.bind("a"))
	var_b_mirror_controls.value_updated.connect(_on_variation_param_changed.bind("b"))
	mobius_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	mobius_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	polar_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	polar_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	sinusoidal_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	sinusoidal_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	spherical_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	spherical_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	swirl_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	swirl_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	tangent_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	tangent_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	lazy_mega_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	lazy_mega_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	glynn_sim_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	glynn_sim_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	nebula_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	nebula_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	jigsaw_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	jigsaw_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	
	
	
	
	
	
	
	
	
	
	reptile_vars_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	reptile_vars_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	randomize_startup_check.toggled.connect(func(_p): save_user_prefs())
	randomize_speed_check.toggled.connect(func(_p): save_user_prefs())
	randomize_colors_check.toggled.connect(func(_p): save_user_prefs())
	randomize_variations_check.toggled.connect(func(_p): save_user_prefs())
	randomize_params_check.toggled.connect(func(_p): save_user_prefs())
	dynamic_material_check.toggled.connect(func(b): use_dynamic_material = b)
	grade_background_check.toggled.connect(func(b): grade_background_active = b)
	limit_top_check.toggled.connect(func(b): limit_to_top = b)
	if popcorn_controls_container_a:
		popcorn_controls_container_a.value_updated.connect(_on_variation_param_changed.bind("a"))
	if popcorn_controls_container_b:
		popcorn_controls_container_b.value_updated.connect(_on_variation_param_changed.bind("b"))
	if game_start_btn:
		game_start_btn.pressed.connect(start_mini_game)
	
	displacement_slider.value_changed.connect(func(v): 
		displacement_strength = v
		displacement_spinbox.set_value_no_signal(v)
	)
	displacement_spinbox.value_changed.connect(func(v): 
		displacement_strength = v
		displacement_slider.set_value_no_signal(v)
	)
	emission_slider.value_changed.connect(func(v): 
		emission_strength = v
		emission_spinbox.set_value_no_signal(v)
	)
	emission_spinbox.value_changed.connect(func(v): 
		emission_strength = v
		emission_slider.set_value_no_signal(v)
	)
	height_offset_slider.value_changed.connect(func(v): 
		height_offset = v
		height_offset_spinbox.set_value_no_signal(v)
	)
	height_offset_spinbox.value_changed.connect(func(v): 
		height_offset = v
		height_offset_slider.set_value_no_signal(v)
	)
	smoothness_slider.value_changed.connect(func(v): 
		displacement_smoothness = v
		smoothness_spinbox.set_value_no_signal(v)
	)
	smoothness_spinbox.value_changed.connect(func(v): 
		displacement_smoothness = v
		smoothness_slider.set_value_no_signal(v)
	)
	auto_rotate_check.toggled.connect(func(b): 
		auto_rotate_active = b
		if b:
			# When turned ON, pick a random rotation axis!
			# We use ranges like -0.5 to 0.5 to keep it somewhat steady but tumbling.
			auto_rotate_vector = Vector3(
				randf_range(-0.5, 0.5), # X (Pitch)
				1.0,                    # Y (Yaw - Always keep some spin)
				randf_range(-0.5, 0.5)  # Z (Roll)
			).normalized()
		else:
			# When turned OFF, reset to simple turntable (just in case)
			auto_rotate_vector = Vector3(0, 1, 0)
	)
	
	# Sync Slider and SpinBox
	rotate_speed_slider.value_changed.connect(func(v): 
		rotate_speed = v
		rotate_speed_spinbox.set_value_no_signal(v)
	)
	rotate_speed_spinbox.value_changed.connect(func(v): 
		rotate_speed = v
		rotate_speed_slider.set_value_no_signal(v)
	)
	
	%CameraZRotSlider.value_changed.connect(func(v): 
		camera_z_rotation = v
		_update_camera() # Update instantly
	)
	
	# --- Mandelbulb Texture Controls ---
		# --- Mandelbulb Texture Controls (Two-Way Sync) ---
	
	# Mix (Intensity)
	mandel_mix_slider.value_changed.connect(func(v): 
		mandel_texture_intensity = v
		mandel_mix_spinbox.set_value_no_signal(v)
	)
	mandel_mix_spinbox.value_changed.connect(func(v): 
		mandel_texture_intensity = v
		mandel_mix_slider.set_value_no_signal(v)
	)
	
	


	# Scale
	mandel_scale_slider.value_changed.connect(func(v): 
		mandel_texture_scale = v
		mandel_scale_spinbox.set_value_no_signal(v)
	)
	mandel_scale_spinbox.value_changed.connect(func(v): 
		mandel_texture_scale = v
		mandel_scale_slider.set_value_no_signal(v)
	)
	# --- Raymarch Advanced Controls ---
	# 1. Iterations (Detail)
	if iter_slider:
		iter_slider.value_changed.connect(func(v): 
			ray_iterations = int(v)
			if iter_spinbox: iter_spinbox.set_value_no_signal(v) # Sync SpinBox
		)
	if iter_spinbox:
		iter_spinbox.value_changed.connect(func(v):
			ray_iterations = int(v)
			if iter_slider: iter_slider.set_value_no_signal(v) # Sync Slider
		)
	
	# 2. Folding Limit
	if ab_fold_slider:
		ab_fold_slider.value_changed.connect(func(v): 
			ab_fold_limit = v
			if ab_fold_spinbox: ab_fold_spinbox.set_value_no_signal(v)
		)
	if ab_fold_spinbox:
		ab_fold_spinbox.value_changed.connect(func(v):
			ab_fold_limit = v
			if ab_fold_slider: ab_fold_slider.set_value_no_signal(v)
		)

	# Fixed Radius
	if ab_rad_slider:
		ab_rad_slider.value_changed.connect(func(v): 
			ab_fixed_radius = v
			if ab_rad_spinbox: ab_rad_spinbox.set_value_no_signal(v)
		)
	if ab_rad_spinbox:
		ab_rad_spinbox.value_changed.connect(func(v):
			ab_fixed_radius = v
			if ab_rad_slider: ab_rad_slider.set_value_no_signal(v)
		)

	# --- Amazing Surf Connections ---
	# Folding Limit
	if as_fold_slider:
		as_fold_slider.value_changed.connect(func(v): 
			as_fold_limit = v
			if as_fold_spinbox: as_fold_spinbox.set_value_no_signal(v)
		)
	if as_fold_spinbox:
		as_fold_spinbox.value_changed.connect(func(v):
			as_fold_limit = v
			if as_fold_slider: as_fold_slider.set_value_no_signal(v)
		)

	# Rotation X
	if as_rot_x_slider:
		as_rot_x_slider.value_changed.connect(func(v): 
			as_rotate.x = v
			if as_rot_x_spinbox: as_rot_x_spinbox.set_value_no_signal(v)
		)
	if as_rot_x_spinbox:
		as_rot_x_spinbox.value_changed.connect(func(v):
			as_rotate.x = v
			if as_rot_x_slider: as_rot_x_slider.set_value_no_signal(v)
		)

	# Rotation Y
	if as_rot_y_slider:
		as_rot_y_slider.value_changed.connect(func(v): 
			as_rotate.y = v
			if as_rot_y_spinbox: as_rot_y_spinbox.set_value_no_signal(v)
		)
	if as_rot_y_spinbox:
		as_rot_y_spinbox.value_changed.connect(func(v):
			as_rotate.y = v
			if as_rot_y_slider: as_rot_y_slider.set_value_no_signal(v)
		)

	# Rotation Z
	if as_rot_z_slider:
		as_rot_z_slider.value_changed.connect(func(v): 
			as_rotate.z = v
			if as_rot_z_spinbox: as_rot_z_spinbox.set_value_no_signal(v)
		)
	if as_rot_z_spinbox:
		as_rot_z_spinbox.value_changed.connect(func(v):
			as_rotate.z = v
			if as_rot_z_slider: as_rot_z_slider.set_value_no_signal(v)
	)
	# Julia X
	if as_julia_x_slider:
		as_julia_x_slider.value_changed.connect(func(v): 
			as_julia.x = v
			if as_julia_x_spinbox: as_julia_x_spinbox.set_value_no_signal(v)
		)
	if as_julia_x_spinbox:
		as_julia_x_spinbox.value_changed.connect(func(v):
			as_julia.x = v
			if as_julia_x_slider: as_julia_x_slider.set_value_no_signal(v)
		)

	# Julia Y
	if as_julia_y_slider:
		as_julia_y_slider.value_changed.connect(func(v): 
			as_julia.y = v
			if as_julia_y_spinbox: as_julia_y_spinbox.set_value_no_signal(v)
		)
	if as_julia_y_spinbox:
		as_julia_y_spinbox.value_changed.connect(func(v):
			as_julia.y = v
			if as_julia_y_slider: as_julia_y_slider.set_value_no_signal(v)
		)

	# Julia Z
	if as_julia_z_slider:
		as_julia_z_slider.value_changed.connect(func(v): 
			as_julia.z = v
			if as_julia_z_spinbox: as_julia_z_spinbox.set_value_no_signal(v)
		)
	if as_julia_z_spinbox:
		as_julia_z_spinbox.value_changed.connect(func(v):
			as_julia.z = v
			if as_julia_z_slider: as_julia_z_slider.set_value_no_signal(v)
	)
	
	# Twist X
	if as_twist_x_slider:
		as_twist_x_slider.value_changed.connect(func(v): 
			as_twist.x = v
			if as_twist_x_spinbox: as_twist_x_spinbox.set_value_no_signal(v)
		)
	if as_twist_x_spinbox:
		as_twist_x_spinbox.value_changed.connect(func(v):
			as_twist.x = v
			if as_twist_x_slider: as_twist_x_slider.set_value_no_signal(v)
		)

	# Twist Y
	if as_twist_y_slider:
		as_twist_y_slider.value_changed.connect(func(v): 
			as_twist.y = v
			if as_twist_y_spinbox: as_twist_y_spinbox.set_value_no_signal(v)
		)
	if as_twist_y_spinbox:
		as_twist_y_spinbox.value_changed.connect(func(v):
			as_twist.y = v
			if as_twist_y_slider: as_twist_y_slider.set_value_no_signal(v)
		)

	# Twist Z (Existing)
	if as_twist_z_slider:
		as_twist_z_slider.value_changed.connect(func(v): 
			as_twist.z = v
			if as_twist_z_spinbox: as_twist_z_spinbox.set_value_no_signal(v)
		)
	if as_twist_z_spinbox:
		as_twist_z_spinbox.value_changed.connect(func(v):
			as_twist.z = v
			if as_twist_z_slider: as_twist_z_slider.set_value_no_signal(v)
		)
	# --- WAVE STRENGTH (X, Y, Z) ---
	if as_wave_str_x_slider:
		as_wave_str_x_slider.value_changed.connect(func(v): 
			as_wave_str.x = v
			if as_wave_str_x_spinbox: as_wave_str_x_spinbox.set_value_no_signal(v)
		)
	if as_wave_str_x_spinbox:
		as_wave_str_x_spinbox.value_changed.connect(func(v):
			as_wave_str.x = v
			if as_wave_str_x_slider: as_wave_str_x_slider.set_value_no_signal(v)
		)

	if as_wave_str_y_slider:
		as_wave_str_y_slider.value_changed.connect(func(v): 
			as_wave_str.y = v
			if as_wave_str_y_spinbox: as_wave_str_y_spinbox.set_value_no_signal(v)
		)
	if as_wave_str_y_spinbox:
		as_wave_str_y_spinbox.value_changed.connect(func(v):
			as_wave_str.y = v
			if as_wave_str_y_slider: as_wave_str_y_slider.set_value_no_signal(v)
		)

	if as_wave_str_z_slider:
		as_wave_str_z_slider.value_changed.connect(func(v): 
			as_wave_str.z = v
			if as_wave_str_z_spinbox: as_wave_str_z_spinbox.set_value_no_signal(v)
		)
	if as_wave_str_z_spinbox:
		as_wave_str_z_spinbox.value_changed.connect(func(v):
			as_wave_str.z = v
			if as_wave_str_z_slider: as_wave_str_z_slider.set_value_no_signal(v)
		)

	# --- WAVE FREQUENCY (X, Y, Z) ---
	if as_wave_freq_x_slider:
		as_wave_freq_x_slider.value_changed.connect(func(v): 
			as_wave_freq.x = v
			if as_wave_freq_x_spinbox: as_wave_freq_x_spinbox.set_value_no_signal(v)
		)
	if as_wave_freq_x_spinbox:
		as_wave_freq_x_spinbox.value_changed.connect(func(v):
			as_wave_freq.x = v
			if as_wave_freq_x_slider: as_wave_freq_x_slider.set_value_no_signal(v)
		)

	if as_wave_freq_y_slider:
		as_wave_freq_y_slider.value_changed.connect(func(v): 
			as_wave_freq.y = v
			if as_wave_freq_y_spinbox: as_wave_freq_y_spinbox.set_value_no_signal(v)
		)
	if as_wave_freq_y_spinbox:
		as_wave_freq_y_spinbox.value_changed.connect(func(v):
			as_wave_freq.y = v
			if as_wave_freq_y_slider: as_wave_freq_y_slider.set_value_no_signal(v)
		)

	if as_wave_freq_z_slider:
		as_wave_freq_z_slider.value_changed.connect(func(v): 
			as_wave_freq.z = v
			if as_wave_freq_z_spinbox: as_wave_freq_z_spinbox.set_value_no_signal(v)
		)
	if as_wave_freq_z_spinbox:
		as_wave_freq_z_spinbox.value_changed.connect(func(v):
			as_wave_freq.z = v
			if as_wave_freq_z_slider: as_wave_freq_z_slider.set_value_no_signal(v)
		)
		
	# --- Escape Time Connections ---
	if escape_time_check:
		escape_time_check.toggled.connect(func(b): use_escape_time = b)
		
	# 1. Slider -> Variable + SpinBox
	if escape_limit_slider:
		escape_limit_slider.value_changed.connect(func(v): 
			escape_limit = v
			if escape_limit_spinbox: escape_limit_spinbox.set_value_no_signal(v)
		)

	# 2. SpinBox -> Variable + Slider
	if escape_limit_spinbox:
		escape_limit_spinbox.value_changed.connect(func(v):
			escape_limit = v
			if escape_limit_slider: escape_limit_slider.set_value_no_signal(v)
		)
	
	if escape_shape_dropdown:
		escape_shape_dropdown.clear()
		escape_shape_dropdown.add_item("Circle")   # 0
		escape_shape_dropdown.add_item("Square")   # 1
		escape_shape_dropdown.add_item("Cross")    # 2
		escape_shape_dropdown.add_item("Diamond")  # 3
		
		escape_shape_dropdown.item_selected.connect(func(index): 
			escape_shape = index
		)
	if escape_smooth_slider:
		escape_smooth_slider.value_changed.connect(func(v): 
			escape_smoothness = v
			if escape_smooth_spinbox: escape_smooth_spinbox.set_value_no_signal(v)
		)
	if escape_smooth_spinbox:
		escape_smooth_spinbox.value_changed.connect(func(v):
			escape_smoothness = v
			if escape_smooth_slider: escape_smooth_slider.set_value_no_signal(v)
		)
	if escape_invert_check:
		escape_invert_check.toggled.connect(func(b): escape_invert = b)
		
		
		
	
	
	
	file_dialog.file_selected.connect(_on_file_dialog_file_selected)
		
	if OS.has_feature("web"):
		print("Control: Web build detected, disabling clipboard buttons.")
		# ... (your web button code remains unchanged) ...
	else:
		print("Control: Not web build, clipboard buttons enabled.")
		# ... (your web notice label code remains unchanged) ...

	post_save_material.shader = load("res://post_process.gdshader")
	post_process_save_viewport.get_node("ShaderRect").material = post_save_material

	_update_view_visibility()
	
	print("Control: _ready function running.")
	if not OS.has_feature("web"):
		print("Control: Not running on web.")

	print("Control: _ready function finished.")
	resized.connect(_on_main_control_resized)
	
	# Call reset_visuals() at the end to load defaults and update the UI
	reset_visuals() 
	var should_randomize = load_user_prefs()
	# Set initial 3D properties AFTER reset_visuals() has loaded the defaults
	_update_light()
	_update_camera()
	_update_background()

	# This sets the initial panel visibility based on default IDs loaded by reset_visuals()
	_on_var_a_dropdown_item_selected(var_a_dropdown.selected)
	_on_var_b_dropdown_item_selected(var_b_dropdown.selected)
	_on_start_pattern_dropdown_item_selected(start_pattern_dropdown.selected)
	reseed_pattern()
	
	setup_animations()
	if should_randomize:
		print("Startup Randomization Enabled: Generating new image...")
		# We verify the UI state is synced before running
		_on_randomize_button_pressed()
	else:
		# Standard reseed if not randomizing
		reseed_pattern()
		
	mandel_power_slider.value_changed.connect(func(v): 
		mandel_power = v
		mandel_power_spinbox.set_value_no_signal(v)
	)
	mandel_power_spinbox.value_changed.connect(func(v): 
		mandel_power = v
		mandel_power_slider.set_value_no_signal(v)
	)
	if is_instance_valid(camera_3d):
		camera_3d.near = 0.001 # Default is 0.05, which is too far for fractals
	# --- Setup Quality Dropdown ---
	if quality_dropdown:
		quality_dropdown.clear()
		quality_dropdown.add_item("Performance (Fast)") # ID 0
		quality_dropdown.add_item("Balanced (Default)") # ID 1
		quality_dropdown.add_item("High Quality")       # ID 2
		quality_dropdown.add_item("Ultra (Slow)")       # ID 3
		
		quality_dropdown.select(1) # Default to Balanced
		
		quality_dropdown.item_selected.connect(_on_quality_changed)

func _on_quality_changed(index: int):
	match index:
		0: current_step_speed = 0.6  # Fast, creates holes/noise
		1: current_step_speed = 0.35 # Good balance
		2: current_step_speed = 0.2  # Very clean
		3: current_step_speed = 0.12 # Cinematic / 4090 only
	
	print("Quality changed. Step speed: ", current_step_speed)
func _get_control_string_from_id(var_id: int) -> String:
	for key in VariationManager.VARIATIONS:
		var data = VariationManager.VARIATIONS[key]
		if data["id"] == var_id:
			var control_string = data.get("controls") # This might be null
			if control_string == null:
				return "" # Return empty string instead of null
			else:
				return control_string # Return the actual string
	return "" # Return empty string if nothing is found


func _save_3d_view_web() -> void:
	print("Starting 3D web save...")
	var viewport_3d = display_container_3d.get_child(0) as SubViewport
	if not is_instance_valid(viewport_3d):
		printerr("ERROR: Could not find 3D viewport to save.")
		return

	# --- Wait for current rendering to settle ---
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var final_image: Image = null

	# --- Get Image Data FIRST and Duplicate ---
	var texture_3d = viewport_3d.get_texture()
	if not is_instance_valid(texture_3d):
		printerr("ERROR: Invalid 3D viewport texture.")
		return
	var image_3d = texture_3d.get_image()
	if not is_instance_valid(image_3d) or image_3d.is_empty():
		printerr("ERROR: Failed to get valid Image from 3D viewport.")
		return
	image_3d = image_3d.duplicate() # Ensure we have a stable copy

	if show_2d_background:
		print("Compositing 3D view over 2D background for save...")
		var texture_2d = final_output.get_texture()
		if not is_instance_valid(texture_2d):
			printerr("ERROR: Invalid 2D background texture.")
			return
		
		# 1. Get the Master Size (The size of the background image)
		var image_2d = texture_2d.get_image()
		var target_size = image_2d.get_size()
		
		# 2. MAGIC FIX: Force the 3D Viewport to match the Background Size!
		# We must disable the UI container stretch so we can manually resize the viewport
		var original_stretch = display_container_3d.stretch
		var original_3d_size = viewport_3d.size
		
		display_container_3d.stretch = false # Unlock size
		viewport_3d.size = target_size       # Force match 2D resolution
		
		# 3. Wait for Godot to render the frame at the new resolution
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		
		# 4. Capture the 3D image (Now it is the perfect size and aspect ratio!)
		var texture_3d_resized = viewport_3d.get_texture()
		image_3d = texture_3d_resized.get_image().duplicate()

		# 5. Restore the Live View to normal
		viewport_3d.size = original_3d_size
		display_container_3d.stretch = original_stretch

		# --- PROCEED WITH COMPOSITING ---
		image_2d = image_2d.duplicate() 
		var temp_tex_2d = ImageTexture.create_from_image(image_2d)
		var temp_tex_3d = ImageTexture.create_from_image(image_3d)

		if not is_instance_valid(temp_tex_2d) or not is_instance_valid(temp_tex_3d):
			printerr("ERROR: Failed to create temporary ImageTextures.")
			return

		# --- Setup Composite Viewport ---
		var composite_viewport = post_process_save_viewport
		var composite_rect = composite_viewport.get_node("ShaderRect")
		var composite_material = composite_rect.material as ShaderMaterial

		if not is_instance_valid(composite_rect) or not is_instance_valid(composite_material):
			printerr("ERROR: Composite viewport nodes/material not valid.")
			return

		# Ensure the correct shader is assigned
		var composite_shader = preload("res://Composite3DOver2D.gdshader")
		if composite_material.shader != composite_shader:
			composite_material.shader = composite_shader

		# Use the TARGET SIZE (Background size) for the final output
		composite_viewport.size = target_size
		composite_rect.texture = temp_tex_2d
		composite_material.set_shader_parameter("foreground_texture", temp_tex_3d)
		
		# Pass Grading Options
		composite_material.set_shader_parameter("grade_background", grade_background_active)
		composite_material.set_shader_parameter("brightness", brightness)
		composite_material.set_shader_parameter("contrast", contrast)
		composite_material.set_shader_parameter("saturation", saturation)

		# Render
		composite_viewport.set_update_mode(SubViewport.UPDATE_ONCE)
		await get_tree().process_frame       
		await RenderingServer.frame_post_draw 
		await RenderingServer.frame_post_draw 

		# Get Result
		var composite_texture = composite_viewport.get_texture()
		if is_instance_valid(composite_texture):
			final_image = composite_texture.get_image()
		
		# Cleanup
		composite_viewport.size = Vector2i(1, 1)

	else: # Not showing 2D background
		final_image = image_3d

	# --- Actual Saving ---
	if not is_instance_valid(final_image) or final_image.is_empty():
		printerr("ERROR: Could not get final, valid image for saving.")
		return

	var buffer = final_image.save_png_to_buffer()
	if buffer.is_empty():
		printerr("ERROR: Failed to save final image to buffer.")
		return

	var dt = Time.get_datetime_dict_from_system()
	var filename = "%04d-%02d-%02d_%02d-%02d-%02d_3D.png" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
	JavaScriptBridge.download_buffer(buffer, filename, "image/png")
	print("3D View Download initiated for " + filename)


# ============================================

func _save_3d_view_desktop(path: String) -> void:
	print("Starting High-Resolution 3D Save...")
	
	var viewport_3d = display_container_3d.get_child(0) as SubViewport
	if not is_instance_valid(viewport_3d):
		printerr("ERROR: Could not find 3D viewport.")
		return

	# --- STEP 1: CALCULATE THE TARGET RESOLUTION ---
	# We ignore the current 3D view size and calculate the desire High-Res size
	# based on your "Resolution" dropdown and the window aspect ratio.
	var base_width = 1024 * pow(2, save_resolution_index)
	var aspect_ratio = 9.0 / 16.0
	var render_height = int(base_width * aspect_ratio)
	var target_size = Vector2i(base_width, render_height)
	
	print("Rendering at Target Resolution: ", target_size)

	# --- STEP 2: RENDER 3D AT TARGET RESOLUTION ---
	# We temporarily resize the 3D viewport to the massive target size
	var original_stretch = display_container_3d.stretch
	var original_3d_size = viewport_3d.size
	
	display_container_3d.stretch = false # Uncouple from UI
	viewport_3d.size = target_size       # Force High-Res Size
	
	# Wait for the high-res frame to render
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	# Capture the High-Res 3D Image
	var texture_3d = viewport_3d.get_texture()
	var image_3d = texture_3d.get_image().duplicate()
	
	# Restore the Live View
	viewport_3d.size = original_3d_size
	display_container_3d.stretch = original_stretch

	var final_image: Image = null

	if show_2d_background:
		print("Compositing 3D view over 2D background...")
		
		# Get the current 2D background
		var texture_2d = final_output.get_texture()
		var image_2d = texture_2d.get_image().duplicate()
		
		# Resize the 2D background to match the High-Res 3D render
		# (This ensures they are the exact same size so no squishing happens)
		image_2d.resize(target_size.x, target_size.y, Image.INTERPOLATE_CUBIC)
		
		var temp_tex_2d = ImageTexture.create_from_image(image_2d)
		var temp_tex_3d = ImageTexture.create_from_image(image_3d)

		# --- Setup Composite Viewport ---
		var composite_viewport = post_process_save_viewport
		var composite_rect = composite_viewport.get_node("ShaderRect")
		var composite_material = composite_rect.material as ShaderMaterial

		# Ensure the correct shader is assigned
		var composite_shader = preload("res://Composite3DOver2D.gdshader")
		if composite_material.shader != composite_shader:
			composite_material.shader = composite_shader

		# Set Composite Viewport to the Target Size
		composite_viewport.size = target_size
		composite_rect.texture = temp_tex_2d
		composite_material.set_shader_parameter("foreground_texture", temp_tex_3d)
		
		# Pass Grading Options
		composite_material.set_shader_parameter("grade_background", grade_background_active)
		composite_material.set_shader_parameter("brightness", brightness)
		composite_material.set_shader_parameter("contrast", contrast)
		composite_material.set_shader_parameter("saturation", saturation)

		# Render the final composite
		composite_viewport.set_update_mode(SubViewport.UPDATE_ONCE)
		await get_tree().process_frame       
		await RenderingServer.frame_post_draw 
		await RenderingServer.frame_post_draw 

		# Get Result
		var composite_texture = composite_viewport.get_texture()
		if is_instance_valid(composite_texture):
			final_image = composite_texture.get_image()
		
		# Cleanup
		composite_viewport.size = Vector2i(1, 1)

	else: 
		# If no background, just use the High-Res 3D image
		final_image = image_3d 

	# --- STEP 3: SAVE TO DISK ---
	if not is_instance_valid(final_image) or final_image.is_empty():
		printerr("ERROR: Could not get final image.")
		return

	var error = final_image.save_png(path)
	if error == OK:
		print("3D View saved successfully to: " + path)
	else:
		printerr("Error saving 3D View. Code: ", error)
	
	
func _on_main_control_resized():
	# Short delay to ensure viewport size is stable after resize event
	await get_tree().process_frame
	await get_tree().process_frame

	var new_size = get_viewport().get_visible_rect().size
	print("DEBUG: Window resized to:", new_size)

	if new_size.x <= 0 or new_size.y <= 0:
		printerr("ERROR: Invalid size on resize:", new_size)
		return

	# Resize feedback viewports
	viewport_a.size = new_size
	viewport_b.size = new_size
	
	
	var viewport_3d = display_container_3d.get_child(0) as SubViewport
	#if is_instance_valid(viewport_3d):
		#viewport_3d.size = new_size
	# --- NEW (GPU-ONLY) ---
	# Just resize the NormalMapViewport. The shader will handle the rest.
	normal_map_viewport.size = new_size
	# --- END NEW ---

	# Optional: Reseed pattern after resize to avoid stretching artifacts
	reseed_pattern()
func _on_view_toggle_toggled(button_pressed: bool):
	is_3d_view = button_pressed
	_update_view_visibility()

# --- NEW FUNCTION to show/hide views ---
func _update_view_visibility():
	if display_container_3d:
		display_container_3d.visible = is_3d_view
	if final_output:
		# Keep FinalOutput visible if we are in 3D view AND showing the 2D background
		if is_3d_view and show_2d_background:
			final_output.visible = true 
		else:
			# Otherwise, hide it when in 3D view, show it when in 2D view
			final_output.visible = not is_3d_view
	# --- ADD THIS ---
	if container_3d_controls: # Check if we found it
		container_3d_controls.visible = is_3d_view
func _on_load_image_button_pressed() -> void:
	if OS.has_feature("web"):
		# On the web, we only call the JavaScript function.
		JavaScriptBridge.eval("openFileLoader()")
	else:
		# On desktop, we do everything related to the FileDialog.
		file_dialog_mode = "load"
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.filters = PackedStringArray(["*.png ; PNG Images", "*.jpg ; JPG Images", "*.jpeg ; JPEG Images", "*.webp ; WebP Images"])
		file_dialog.popup_centered()

func _on_shape_selected(shape_index: int):
	if not is_instance_valid(fractal_mesh):
		return

	var new_mesh: Mesh = null

	# --- STEP 1: CREATE GEOMETRY ---
	match shape_index:
		0: # Sphere
			var m = SphereMesh.new()
			m.radius = 0.5
			m.height = 1.0
			m.radial_segments = 128
			m.rings = 64 
			new_mesh = m
		1: # Cube
			var m = BoxMesh.new()
			m.size = Vector3(2.0, 2.0, 2.0)
			m.subdivide_width = 100
			m.subdivide_height = 100
			m.subdivide_depth = 100
			new_mesh = m
		2: # Quad
			var m = BoxMesh.new()
			m.size = Vector3(2, 0.5, 2)
			m.subdivide_width = 200
			m.subdivide_depth = 200
			m.subdivide_height = 1 
			new_mesh = m
		3: # Prism
			var m = PrismMesh.new()
			m.size = Vector3(2.0, 2.0, 2.0)
			m.subdivide_width = 64
			m.subdivide_height = 64
			m.subdivide_depth = 64
			new_mesh = m
		4: # Torus
			var m = TorusMesh.new()
			m.outer_radius = 0.5
			m.inner_radius = 0.25
			m.rings = 128
			m.ring_segments = 64
			new_mesh = m
		5, 6, 7, 8: # Raymarching Shapes
			var m = BoxMesh.new()
			m.size = Vector3(20.0, 20.0, 20.0)
			new_mesh = m

	# --- STEP 2: APPLY MATERIALS & UI ---
	if new_mesh:
		fractal_mesh.mesh = new_mesh
		
		# Always show Main Container
		mandel_controls.visible = true 
		
		# Ensure Mix/Scale Sliders are visible
		if mandel_mix_slider: mandel_mix_slider.get_parent().visible = true
		if mandel_scale_slider: mandel_scale_slider.get_parent().visible = true
		
		# Default: Hide Raymarch-specific panels
		if ab_params: ab_params.visible = false
		if as_params: as_params.visible = false

		# --- NORMAL MESHES (0-4) ---
		if shape_index < 5:
			var mat = ShaderMaterial.new()
			mat.shader = load("res://fractal_3d_displacement.gdshader")
			fractal_mesh.set_surface_override_material(0, mat)
			
			is_raymarching = false
			
			# SHOW Standard Controls (Height, Glow, etc)
			if standard_mesh_controls: standard_mesh_controls.visible = true

			# HIDE Raymarch Core Sliders
			if raymarch_core_params: raymarch_core_params.visible = false
			else:
				# Fallback
				if mandel_power_slider: mandel_power_slider.visible = false
				if mandel_power_spinbox: mandel_power_spinbox.visible = false
				if iter_slider: iter_slider.visible = false
				if iter_spinbox: iter_spinbox.visible = false
			
			if shape_index == 2: # Quad
				mat.set_shader_parameter("use_terrain_mode", true)
			else:
				mat.set_shader_parameter("use_terrain_mode", false)

		# --- RAYMARCHING SHAPES (5-8) ---
		else:
			var mat = ShaderMaterial.new()
			is_raymarching = true
			
			# HIDE Standard Controls (Height, Glow, etc don't apply)
			if standard_mesh_controls: standard_mesh_controls.visible = false
			
			# SHOW Raymarch Core Sliders
			if raymarch_core_params: raymarch_core_params.visible = true
			else:
				if mandel_power_slider: mandel_power_slider.visible = true
				if mandel_power_spinbox: mandel_power_spinbox.visible = true
				if iter_slider: iter_slider.visible = true
				if iter_spinbox: iter_spinbox.visible = true
			
			if shape_index == 5:
				mat.shader = load("res://raymarch_mandelbulb.gdshader")
			elif shape_index == 6:
				mat.shader = load("res://raymarch_menger.gdshader")
			# Show the modifiers (Rotate/Twist/Wave) for EVERY raymarcher (5, 6, 7, 8)
			if as_params: as_params.visible = true
			
			# Only show "Fold/Radius" for Amazing Box (7)
			if ab_params: ab_params.visible = (shape_index == 7)

			# -- LOAD SHADERS --
			if shape_index == 5:
				mat.shader = load("res://raymarch_mandelbulb.gdshader")
			elif shape_index == 6:
				mat.shader = load("res://raymarch_menger.gdshader")
			elif shape_index == 7:
				mat.shader = load("res://raymarch_amazingbox.gdshader")
			elif shape_index == 8:
				mat.shader = load("res://raymarch_amazingsurf.gdshader")
			
			fractal_mesh.set_surface_override_material(0, mat)
			
		print("Changed mesh shape to index: ", shape_index)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_visuals"):
		self.reset_visuals.call()
	if event.is_action_pressed.call("reseed_pattern"):
		self.reseed_pattern.call()
	if event.is_action_pressed("toggle_ui"):
		self.toggle_ui.call()
func _on_viewport_gui_input(event: InputEvent) -> void:
	# --- 3D CAMERA CONTROLS ---
	# Standard 2D Fractal Controls (Pan/Zoom the Texture)
	
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		var relative_motion = event.relative / get_viewport_rect().size
		if move_post_translate:
			post_translate -= relative_motion
		if move_pre_translate:
			pre_translate -= relative_motion
		if move_var_a_translate:
			translate_a -= relative_motion
		if move_var_b_translate:
			translate_b -= relative_motion

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if reset_on_drag_enabled:
				reseed_pattern()
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				var base_delta = 0.005 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.005
				
				var dominant_variation_id = variation_mode_a
				if variation_mix >= 0.5:
					dominant_variation_id = variation_mode_b
				
				var zoom_delta = base_delta
				if not dominant_variation_id in INVERSE_VARIATIONS:
					zoom_delta *= -1.0

				if event.ctrl_pressed:
					if event.shift_pressed: pre_rotation += zoom_delta * 5.0
					else: pre_scale = max(0.1, pre_scale + zoom_delta)
				else:
					if event.shift_pressed: post_rotation += zoom_delta * 5.0
					else: post_scale = max(0.1, post_scale + zoom_delta)
func _update_feedback_ranges_in_ui():
	# 1. Set the new min/max ranges on the slider and spinbox
	feedback_amount_slider.min_value = feedback_min
	feedback_amount_spinbox.min_value = feedback_min
	feedback_amount_slider.max_value = feedback_max
	feedback_amount_spinbox.max_value = feedback_max

		# 2. Clamp the current feedback_amount variable to the new range
	var clamped_value = clamp(feedback_amount, feedback_min, feedback_max)

		# 3. Check if the value actually needs to be changed
	if not is_equal_approx(feedback_amount, clamped_value):
		feedback_amount = clamped_value # Update the main variable

		# 4. Force the UI to update to the new clamped value
		# We use set_value_no_signal() to prevent a signal feedback loop
	feedback_amount_slider.set_value_no_signal(feedback_amount)
	feedback_amount_spinbox.set_value_no_signal(feedback_amount)

func _on_randomize_button_pressed() -> void:
	var include_speed = randomize_speed_check.button_pressed
	var include_variations = randomize_variations_check.button_pressed
	var include_params = randomize_params_check.button_pressed
	var randomize_colors = randomize_colors_check.button_pressed
	
	# 1. Randomize Colors
	if randomize_colors:
		grad_col_tl = Color(randf(), randf(), randf())
		grad_col_tr = Color(randf(), randf(), randf())
		grad_col_bl = Color(randf(), randf(), randf())
		grad_col_br = Color(randf(), randf(), randf())
		
		grad_col_tl_picker.color = grad_col_tl
		grad_col_tr_picker.color = grad_col_tr
		grad_col_bl_picker.color = grad_col_bl
		grad_col_br_picker.color = grad_col_br

	# 2. Randomize Variations (Switch Types)
	if include_variations:
		# Randomize Variation A Selection
		if var_a_dropdown.item_count > 0:
			var rand_idx = randi() % var_a_dropdown.item_count
			var_a_dropdown.select(rand_idx)
			_on_var_a_dropdown_item_selected(rand_idx)
			
			if var_a_dropdown.get_item_text(rand_idx) == "Rep-Tiles":
				var rand_rep = randi() % rep_tile_dropdown_a.item_count
				rep_tile_dropdown_a.select(rand_rep)
				_on_rep_tile_dropdown_a_item_selected(rand_rep)

		# Randomize Variation B Selection
		if var_b_dropdown.item_count > 0:
			var rand_idx = randi() % var_b_dropdown.item_count
			var_b_dropdown.select(rand_idx)
			_on_var_b_dropdown_item_selected(rand_idx)
			
			if var_b_dropdown.get_item_text(rand_idx) == "Rep-Tiles":
				var rand_rep = randi() % rep_tile_dropdown_b.item_count
				rep_tile_dropdown_b.select(rand_rep)
				_on_rep_tile_dropdown_b_item_selected(rand_rep)

	# 3. Smart Feedback Reset (NOW OUTSIDE THE IF BLOCK)
	# This ensures it runs even if you are only randomizing parameters
	var target_feedback = 0.8
	if include_speed:
		target_feedback = 0.9
		
	# If our target is higher than the allowed Max, raise the Max!
	if target_feedback > feedback_max:
		feedback_max = target_feedback
		feedback_range_max_spinbox.set_value_no_signal(target_feedback)
		_update_feedback_ranges_in_ui() 
		
	# Apply the value
	feedback_amount = target_feedback
	feedback_amount_slider.set_value_no_signal(target_feedback)
	feedback_amount_spinbox.set_value_no_signal(target_feedback)


	# 4. Randomize Parameters (Sliders)
	if include_params:
		var control_string_a = _get_control_string_from_id(variation_mode_a)
		if control_string_a != "" and var_a_panels.has(control_string_a):
			var panel = var_a_panels[control_string_a]
			if panel.has_method("randomize_settings"):
				panel.randomize_settings(include_speed)

		var control_string_b = _get_control_string_from_id(variation_mode_b)
		if control_string_b != "" and var_b_panels.has(control_string_b):
			var panel = var_b_panels[control_string_b]
			if panel.has_method("randomize_settings"):
				panel.randomize_settings(include_speed)
				
		# Randomize Mix only if params are enabled
		var_mix_slider.value = randf_range(0.2, 0.8)

	# 5. Reseed
	reseed_pattern()
	print("Randomized settings!")
	
func reset_visuals() -> void:
	if default_settings == null:
		printerr("ERROR: Default Settings resource not assigned in Inspector!")
		return

	# --- Copy all values from the resource ---
	variation_mode_a = default_settings.variation_mode_a
	variation_mode_b = default_settings.variation_mode_b
	start_pattern_mode = default_settings.start_pattern_mode
	variation_mix = default_settings.variation_mix
	animation_paused = false
	feedback_amount = default_settings.feedback_amount
	feedback_min = default_settings.feedback_min
	feedback_max = default_settings.feedback_max
	seamless_tiling = default_settings.seamless_tiling
	mirror_tiling = default_settings.mirror_tiling
	reset_on_drag_enabled = default_settings.reset_on_drag_enabled
	save_resolution_index = default_settings.save_resolution_index
	show_start_grid = default_settings.show_start_grid
	show_circles = default_settings.show_circles
	circle_count = default_settings.circle_count
	circle_radius = default_settings.circle_radius
	circle_softness = default_settings.circle_softness
	circle_grid_scale = default_settings.circle_grid_scale
	circle_grid_radius = default_settings.circle_grid_radius
	circle_grid_softness = default_settings.circle_grid_softness
	grad_col_tl = default_settings.grad_col_tl
	grad_col_tr = default_settings.grad_col_tr
	grad_col_bl = default_settings.grad_col_bl
	grad_col_br = default_settings.grad_col_br
	pre_scale = default_settings.pre_scale
	pre_rotation = default_settings.pre_rotation
	pre_translate = default_settings.pre_translate
	post_scale = default_settings.post_scale
	post_rotation = default_settings.post_rotation
	post_translate = default_settings.post_translate
	translate_a = default_settings.translate_a
	translate_b = default_settings.translate_b
	brightness = default_settings.brightness
	contrast = default_settings.contrast
	saturation = default_settings.saturation
	move_post_translate = default_settings.move_post_translate
	move_pre_translate = default_settings.move_pre_translate
	move_var_a_translate = default_settings.move_var_a_translate
	move_var_b_translate = default_settings.move_var_b_translate
	mirror_x = default_settings.mirror_x
	mirror_y = default_settings.mirror_y
	kaleidoscope_on = default_settings.kaleidoscope_on
	kaleidoscope_slices = default_settings.kaleidoscope_slices




	blur_amount_a = default_settings.blur_amount_a
	



	blur_amount_b = default_settings.blur_amount_b


	custom_tl_a_id = default_settings.custom_tl_a_id
	custom_tr_a_id = default_settings.custom_tr_a_id
	custom_bl_a_id = default_settings.custom_bl_a_id
	custom_br_a_id = default_settings.custom_br_a_id
	custom_tl_b_id = default_settings.custom_tl_b_id
	custom_tr_b_id = default_settings.custom_tr_b_id
	custom_bl_b_id = default_settings.custom_bl_b_id
	custom_br_b_id = default_settings.custom_br_b_id
	light_x_rotation = default_settings.light_x_rotation
	light_y_rotation = default_settings.light_y_rotation
	light_energy = default_settings.light_energy
	light_color = default_settings.light_color
	light_shadows = default_settings.light_shadows
	normal_map_strength = default_settings.normal_map_strength
	camera_distance = default_settings.camera_distance
	camera_x_rotation = default_settings.camera_x_rotation
	camera_y_rotation = default_settings.camera_y_rotation
	camera_z_rotation = default_settings.camera_z_rotation if "camera_z_rotation" in default_settings else 0.0
	camera_fov = default_settings.camera_fov
	show_2d_background = default_settings.show_2d_background

	# --- Finally, update the UI ---
	time = 0.0
	update_ui_from_state()
	# Ensure 3D toggles are synced
	limit_to_top = default_settings.limit_to_top if "limit_to_top" in default_settings else false
	use_dynamic_material = default_settings.use_dynamic_material if "use_dynamic_material" in default_settings else false
	grade_background_active = default_settings.grade_background_active if "grade_background_active" in default_settings else false
	reseed_pattern()

func reseed_pattern() -> void:
	time = 0.0 # Resets the shader time, often used for seeding noise/patterns

func update_ui_from_state() -> void:
	
		var values = {
			"animation_paused": animation_paused,
			"var_a_id": variation_mode_a, # Pass ID
			"var_b_id": variation_mode_b, # Pass ID
			"start_pattern": start_pattern_mode,
			"var_mix": variation_mix, "feedback": feedback_amount, "feedback_min": feedback_min, "feedback_max": feedback_max, "tiling": seamless_tiling,"mirror_tiling": mirror_tiling,
			"reset_on_drag": reset_on_drag_enabled, "show_grid": show_start_grid, "show_circles": show_circles,
			"pre_scale": pre_scale, "pre_rot": pre_rotation, "post_scale": post_scale, "post_rot": post_rotation,
			"brightness": brightness, "contrast": contrast, "saturation": saturation,
			"circle_count": circle_count, "circle_radius": circle_radius, "circle_softness": circle_softness,
			"circle_grid_scale": circle_grid_scale,
			"circle_grid_radius": circle_grid_radius,
			"circle_grid_softness": circle_grid_softness,
			"grad_tl": grad_col_tl, "grad_tr": grad_col_tr, "grad_bl": grad_col_bl, "grad_br": grad_col_br,
			"move_post": move_post_translate, "move_pre": move_pre_translate,
			"move_var_a": move_var_a_translate, "move_var_b": move_var_b_translate,
			"post_mirror_x": mirror_x, "post_mirror_y": mirror_y, "post_kaleidoscope_on": kaleidoscope_on, "post_kaleidoscope_slices": kaleidoscope_slices,
			# Var A specific
			"blur_amount_a": blur_amount_a,

			"custom_tl_a": custom_tl_a_id,
			"custom_tr_a": custom_tr_a_id,
			"custom_bl_a": custom_bl_a_id,
			"custom_br_a": custom_br_a_id,
			# Var B specific
			"blur_amount_b": blur_amount_b,

			"custom_tl_b": custom_tl_b_id,
			"custom_tr_b": custom_tr_b_id,
			"custom_bl_b": custom_bl_b_id,
			"custom_br_b": custom_br_b_id,
			# --- ADD THESE ---
			"light_x_rot": light_x_rotation,
			"light_y_rot": light_y_rotation,
			"light_energy": light_energy,
			"light_color": light_color,
			"light_shadows": light_shadows,
			# --- END ---
			"normal_strength": normal_map_strength,
			
			"cam_dist": camera_distance,
			"cam_x_rot": camera_x_rotation,
			"cam_y_rot": camera_y_rotation,
			"cam_z_rot": camera_z_rotation,
			"cam_fov": camera_fov,
			"show_2d_bg": show_2d_background,
			"save_res_index": save_resolution_index,
			# --- NEW: 3D VALUES ---
			"disp_str": displacement_strength,
			"height_off": height_offset,
			"smooth": displacement_smoothness,
			"limit_top": limit_to_top,
			"emit_str": emission_strength,
			"dyn_mat": use_dynamic_material,
			"grade_bg": grade_background_active,
			
		}
		values.merge(_auto_params_a, true) # Add all "A" auto-params
		values.merge(_auto_params_b, true) # Add all "B" auto-params
		initialize_ui(values)
		
func _set_dropdown_selection(dropdown: OptionButton, text_to_select: String):
	var index = _get_item_index_by_text(dropdown, text_to_select)
	if index != -1:
		dropdown.select(index)
	elif dropdown.item_count > 0:
		dropdown.select(0) # Fallback to first item

# --- REPLACED FUNCTION ---

# --- NEW: Helper to find item index by text ---
func _get_item_index_by_text(dropdown: OptionButton, text: String) -> int:
	for i in range(dropdown.item_count):
		if dropdown.get_item_text(i) == text:
			return i
	return -1 # Not found

func initialize_ui(initial_values: Dictionary) -> void:
	
	# --- Handle Variation Dropdowns ---
	var var_a_id = initial_values.get("var_a_id", 0) # Expect ID
	var var_b_id = initial_values.get("var_b_id", 1) # Expect ID
	var var_a_name = _get_name_from_id(var_a_id)
	var var_b_name = _get_name_from_id(var_b_id)
	if var_a_name != "" and VariationManager.VARIATIONS[var_a_name].get("category") == "Rep-Tile":
		_set_dropdown_selection(var_a_dropdown, "Rep-Tiles")
		_set_dropdown_selection(rep_tile_dropdown_a, var_a_name)
	else:
		_set_dropdown_selection(var_a_dropdown, var_a_name)
	if var_b_name != "" and VariationManager.VARIATIONS[var_b_name].get("category") == "Rep-Tile":
		_set_dropdown_selection(var_b_dropdown, "Rep-Tiles")
		_set_dropdown_selection(rep_tile_dropdown_b, var_b_name)
	else:
		_set_dropdown_selection(var_b_dropdown, var_b_name)
	
	# --- Update Feedback Controls ---
	var fb_min = initial_values.get("feedback_min", 0.8)
	var fb_max = initial_values.get("feedback_max", 1.0)
	feedback_amount_slider.min_value = fb_min
	feedback_amount_spinbox.min_value = fb_min
	feedback_amount_slider.max_value = fb_max
	feedback_amount_spinbox.max_value = fb_max
	feedback_amount_slider.set_value_no_signal(initial_values.get("feedback", 0.98))
	feedback_amount_spinbox.set_value_no_signal(initial_values.get("feedback", 0.98))
	feedback_range_min_spinbox.value = fb_min
	feedback_range_max_spinbox.value = fb_max
	
	# --- Initialize Other Controls ---
	pause_animation_check.set_pressed_no_signal(initial_values.get("animation_paused", false))
	start_pattern_dropdown.select(initial_values.get("start_pattern", 0))
	resolution_dropdown.select(initial_values.get("save_res_index", 1))
	tiling_check_box.set_pressed_no_signal(initial_values.get("tiling", true))
	mirror_tiling_check_box.set_pressed_no_signal(initial_values.get("mirror_tiling", false))
	reset_on_drag_check.button_pressed = initial_values.get("reset_on_drag", true)
	show_grid_check.button_pressed = initial_values.get("show_grid", false)
	show_circles_check.set_pressed_no_signal(initial_values.get("show_circles", true))
	post_translate_radio.set_pressed_no_signal(initial_values.get("move_post", true))
	pre_translate_radio.set_pressed_no_signal(initial_values.get("move_pre", false))
	var_a_translate_radio.set_pressed_no_signal(initial_values.get("move_var_a", false))
	var_b_translate_radio.set_pressed_no_signal(initial_values.get("move_var_b", false))
	
	var_mix_slider.set_value_no_signal(initial_values.get("var_mix", 0.5))
	var_mix_spinbox.set_value_no_signal(initial_values.get("var_mix", 0.5))
	
	# Transforms
	pre_scale_slider.set_value_no_signal(initial_values.get("pre_scale", 1.0))
	pre_scale_spinbox.set_value_no_signal(initial_values.get("pre_scale", 1.0))
	pre_rotation_slider.set_value_no_signal(initial_values.get("pre_rot", 0.0))
	pre_rotation_spinbox.set_value_no_signal(initial_values.get("pre_rot", 0.0))
	post_scale_slider.set_value_no_signal(initial_values.get("post_scale", 0.995))
	post_scale_spinbox.set_value_no_signal(initial_values.get("post_scale", 0.995))
	post_rotation_slider.set_value_no_signal(initial_values.get("post_rot", 0.0))
	post_rotation_spinbox.set_value_no_signal(initial_values.get("post_rot", 0.0))
	
	# Color
	brightness_slider.set_value_no_signal(initial_values.get("brightness", 1.0))
	brightness_spinbox.set_value_no_signal(initial_values.get("brightness", 1.0))
	contrast_slider.set_value_no_signal(initial_values.get("contrast", 1.0))
	contrast_spinbox.set_value_no_signal(initial_values.get("contrast", 1.0))
	saturation_slider.set_value_no_signal(initial_values.get("saturation", 1.0))
	saturation_spinbox.set_value_no_signal(initial_values.get("saturation", 1.0))
	
	grad_col_tl_picker.color = initial_values.get("grad_tl", Color.CYAN)
	grad_col_tr_picker.color = initial_values.get("grad_tr", Color.YELLOW)
	grad_col_bl_picker.color = initial_values.get("grad_bl", Color.BLUE)
	grad_col_br_picker.color = initial_values.get("grad_br", Color.RED)
	
	# Post Symmetry
	post_mirror_x_check.set_pressed_no_signal(initial_values.get("post_mirror_x", false))
	post_mirror_y_check.set_pressed_no_signal(initial_values.get("post_mirror_y", false))
	post_kaleidoscope_master_check.set_pressed_no_signal(initial_values.get("post_kaleidoscope_on", false))
	post_kaleidoscope_slider.set_value_no_signal(initial_values.get("post_kaleidoscope_slices", 6.0))
	post_kaleidoscope_spinbox.set_value_no_signal(initial_values.get("post_kaleidoscope_slices", 6.0))

	# Circles
	circle_count_slider.set_value_no_signal(initial_values.get("circle_count", 4.0))
	circle_count_spinbox.set_value_no_signal(initial_values.get("circle_count", 4.0))
	circle_radius_slider.set_value_no_signal(initial_values.get("circle_radius", 0.2))
	circle_radius_spinbox.set_value_no_signal(initial_values.get("circle_radius", 0.2))
	circle_softness_slider.set_value_no_signal(initial_values.get("circle_softness", 0.05))
	circle_softness_spinbox.set_value_no_signal(initial_values.get("circle_softness", 0.05))
	
	circle_grid_scale_slider.set_value_no_signal(initial_values.get("circle_grid_scale", 8.0))
	circle_grid_scale_spinbox.set_value_no_signal(initial_values.get("circle_grid_scale", 8.0))
	circle_grid_radius_slider.set_value_no_signal(initial_values.get("circle_grid_radius", 0.4))
	circle_grid_radius_spinbox.set_value_no_signal(initial_values.get("circle_grid_radius", 0.4))
	circle_grid_softness_slider.set_value_no_signal(initial_values.get("circle_grid_softness", 0.05))
	circle_grid_softness_spinbox.set_value_no_signal(initial_values.get("circle_grid_softness", 0.05))

	blur_amount_slider_a.set_value_no_signal(initial_values.get("blur_amount_a", 0.0))
	blur_amount_spinbox_a.set_value_no_signal(initial_values.get("blur_amount_a", 0.0))
	
	
	blur_amount_slider_b.set_value_no_signal(initial_values.get("blur_amount_b", 0.0))
	blur_amount_spinbox_b.set_value_no_signal(initial_values.get("blur_amount_b", 0.0))
		# --- Custom 2x2 ---
	custom_tl_a.select(initial_values.get("custom_tl_a", 0))
	custom_tr_a.select(initial_values.get("custom_tr_a", 0))
	custom_bl_a.select(initial_values.get("custom_bl_a", 0))
	custom_br_a.select(initial_values.get("custom_br_a", 0))
	custom_tl_b.select(initial_values.get("custom_tl_b", 0))
	custom_tr_b.select(initial_values.get("custom_tr_b", 0))
	custom_bl_b.select(initial_values.get("custom_bl_b", 0))
	custom_br_b.select(initial_values.get("custom_br_b", 0))
	
	# --- 3D Light Controls ---
	%LightXAngleSlider.set_value_no_signal(initial_values.get("light_x_rot", 77.0))
	light_x_angle_spinbox.set_value_no_signal(initial_values.get("light_x_rot", 77.0))
	%LightYAngleSlider.set_value_no_signal(initial_values.get("light_y_rot", 163.5))
	light_y_angle_spinbox.set_value_no_signal(initial_values.get("light_y_rot", 163.5))
	%LightEnergySlider.set_value_no_signal(initial_values.get("light_energy", 1.0))
	light_energy_spinbox.set_value_no_signal(initial_values.get("light_energy", 1.0))
	%LightColorPicker.color = initial_values.get("light_color", Color.WHITE)
	%ShadowCheckBox.set_pressed_no_signal(initial_values.get("light_shadows", true))

	#%NormalStrengthSlider.set_value_no_signal(initial_values.get("normal_strength", 1.0))
	#normal_strength_spinbox.set_value_no_signal(initial_values.get("normal_strength", 1.0))

	%CameraDistSlider.set_value_no_signal(initial_values.get("cam_dist", 3.5))
	camera_dist_spinbox.set_value_no_signal(initial_values.get("cam_dist", 3.5))
	%CameraXRotSlider.set_value_no_signal(initial_values.get("cam_x_rot", 0.0))
	camera_x_rot_spinbox.set_value_no_signal(initial_values.get("cam_x_rot", 0.0))
	%CameraYRotSlider.set_value_no_signal(initial_values.get("cam_y_rot", 0.0))
	camera_y_rot_spinbox.set_value_no_signal(initial_values.get("cam_y_rot", 0.0))
	%CameraZRotSlider.set_value_no_signal(initial_values.get("cam_z_rot", 0.0))
	camera_z_rot_spinbox.set_value_no_signal(initial_values.get("cam_z_rot", 0.0))
	%CameraFovSlider.set_value_no_signal(initial_values.get("cam_fov", 75.0))
	camera_fov_spinbox.set_value_no_signal(initial_values.get("cam_fov", 75.0))

	%BackgroundCheckBox.set_pressed_no_signal(initial_values.get("show_2d_bg", false))
	
	# --- Mandelbulb UI Init ---
	# (Existing lines for sliders...)
	mandel_mix_slider.set_value_no_signal(initial_values.get("tex_int", 0.5))
	mandel_scale_slider.set_value_no_signal(initial_values.get("tex_scale", 1.0))
	
	# (NEW lines for spinboxes)
	mandel_mix_spinbox.set_value_no_signal(initial_values.get("tex_int", 0.5))
	mandel_scale_spinbox.set_value_no_signal(initial_values.get("tex_scale", 1.0))
	
	
	# --- NEW: 3D SLIDERS & CHECKS ---
	displacement_slider.set_value_no_signal(initial_values.get("disp_str", 0.2))
	displacement_spinbox.set_value_no_signal(initial_values.get("disp_str", 0.2))
	
	height_offset_slider.set_value_no_signal(initial_values.get("height_off", -0.5))
	height_offset_spinbox.set_value_no_signal(initial_values.get("height_off", -0.5))
	
	smoothness_slider.set_value_no_signal(initial_values.get("smooth", 0.0))
	smoothness_spinbox.set_value_no_signal(initial_values.get("smooth", 0.0))
	
	emission_slider.set_value_no_signal(initial_values.get("emit_str", 0.0))
	emission_spinbox.set_value_no_signal(initial_values.get("emit_str", 0.0))
	
	# Update the Checkbox Visuals
	limit_top_check.set_pressed_no_signal(initial_values.get("limit_top", false))
	dynamic_material_check.set_pressed_no_signal(initial_values.get("dyn_mat", false))
	grade_background_check.set_pressed_no_signal(initial_values.get("grade_bg", false))

	# CRITICAL: Update the variables to match!
	limit_to_top = limit_top_check.button_pressed
	use_dynamic_material = dynamic_material_check.button_pressed
	grade_background_active = grade_background_check.button_pressed
func _on_save_button_pressed() -> void:
	if OS.has_feature("web"):
		if is_3d_view:
			# --- NEW ---
			# Handle 3D web save immediately
			_save_3d_view_web()
			# --- END NEW ---
		else:
			# Handle 2D web save
			print("Starting web render for download...")
			
			# 1. Get the base width from the dropdown
			var base_width = 1024 * pow(2, save_resolution_index)
			
			# 2. Force 16:9 Aspect Ratio
			# This guarantees 2048x1152 instead of calculating based on window shape
			var aspect_ratio = 9.0 / 16.0
			
			# 3. Calculate the new height
			var render_height = int(base_width * aspect_ratio)
			
			# 4. Create the final render size
			var render_size = Vector2i(base_width, render_height)
			
			# 5. Call save with an EMPTY string for path
			_render_and_save_image("", render_size) 
	
	# This 'else' is now correctly indented
	else:
		# Desktop: Just open the dialog. The file_selected function will handle the logic.
		file_dialog_mode = "save"
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.filters = PackedStringArray(["*.png ; PNG Images"])
		var dt = Time.get_datetime_dict_from_system()
		var timestamp = "%04d-%02d-%02d_%02d-%02d-%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
		file_dialog.current_file = timestamp + ".png"
		file_dialog.popup_centered()

func _on_save_preset_pressed() -> void:
	var data = _gather_preset_data()
	var json_string = JSON.stringify(data, "\t") # Use "\t" for pretty printing

	if OS.has_feature("web"):
		var buffer = json_string.to_utf8_buffer()
		var dt = Time.get_datetime_dict_from_system()
		var filename = "preset_%04d-%02d-%02d.json" % [dt.year, dt.month, dt.day]
		JavaScriptBridge.download_buffer(buffer, filename, "application/json")
		print("Preset download initiated for " + filename)
	else:
		_preset_json_to_save = json_string
		file_dialog_mode = "save_preset"
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.filters = PackedStringArray(["*.json ; JSON Preset"])
		file_dialog.current_file = "my_fractal.json"
		file_dialog.popup_centered()

func _on_load_preset_pressed() -> void:
	if OS.has_feature("web"):
		print("Control: Load Preset button pressed, calling JS click().")
		# *** IMPORTANT: Make sure this ID matches your main HTML file's input ID ***
		JavaScriptBridge.eval("document.getElementById('fileLoaderPreset').click();") # Or 'fileLoaderPresetSimple' if you used that ID
	else:
		# Show FileDialog for desktop loading
		file_dialog_mode = "load_preset"
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.filters = PackedStringArray(["*.json ; JSON Preset"])
		file_dialog.popup_centered()
		print("Control: Load Preset button pressed (non-web).")

func _on_copy_preset_pressed() -> void:
	var data = _gather_preset_data()
	var json_string = JSON.stringify(data) # No tabs for compact clipboard string

	if OS.has_feature("web"):
		# Escape the JSON string to be safely passed within JavaScript eval
		var escaped_json = json_string.replace("'", "\\'").replace('"', '\\"').replace("\n", "\\n")
		var js_command = "copyPresetToClipboard('%s');" % escaped_json
		print("Control: Executing JS for copy: ", js_command) # Debug
		JavaScriptBridge.eval(js_command)
		# Optionally provide user feedback here (e.g., update a label)
		print("Control: JS copy command sent.")
	else:
		# Desktop fallback
		DisplayServer.clipboard_set(json_string)
		print("Preset copied to clipboard (Desktop).")

func _on_paste_preset_pressed() -> void:
	if OS.has_feature("web"):
		# Ask JavaScript to read the clipboard and put it in the mailbox
		print("Control: Executing JS for paste...")
		JavaScriptBridge.eval("pastePresetFromClipboard();")
		# Godot will pick it up in _process via window.pastedPresetData
		print("Control: JS paste command sent. Will check mailbox in _process.")
	else:
		# Desktop fallback
		var clipboard_text = DisplayServer.clipboard_get()
		var parse_result = JSON.parse_string(clipboard_text)
		if parse_result != null:
			_apply_preset_data(parse_result)
			print("Preset pasted from clipboard (Desktop).")
		else:
			print("Error: Clipboard text is not a valid preset (Desktop).")

func _on_file_dialog_file_selected(path: String) -> void:
	if file_dialog_mode == "save":
		if is_3d_view:
			# Handle 3D desktop save
			_save_3d_view_desktop(path)
		else:
			# Handle 2D desktop save
			print("Starting high-resolution render...")
			
			# 1. Get the base width from the dropdown
			var base_width = 1024 * pow(2, save_resolution_index)
			
			# 2. Force 16:9 Aspect Ratio
			var aspect_ratio = 9.0 / 16.0
			
			# 3. Calculate the new height
			var render_height = int(base_width * aspect_ratio)
			
			# 4. Create the final render size
			var render_size = Vector2i(base_width, render_height)
			
			_render_and_save_image(path, render_size)

	elif file_dialog_mode == "load":
		var image = Image.load_from_file(path)
		if image:
			background_texture = ImageTexture.create_from_image(image)
			reseed_pattern()
			print("Background image loaded successfully.")
		else:
			print("Error: Could not load image from path.")

	elif file_dialog_mode == "save_preset":
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_string(_preset_json_to_save)
			file.close()
			print("Preset saved to: " + path)
		else:
			printerr("Error: Could not open file for writing at path: ", path, " | Error code: ", FileAccess.get_open_error())

	elif file_dialog_mode == "load_preset":
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var text_content = file.get_as_text()
			file.close()
			var data = JSON.parse_string(text_content)
			if data:
				_apply_preset_data(data)
			else:
				print("Error: Could not parse preset file.")
		else:
			printerr("Error: Could not open file for reading at path: ", path, " | Error code: ", FileAccess.get_open_error())
	elif file_dialog_mode == "save_animation":
		# The user has picked a name and location.
		# The 'path' is absolute, so we can use it directly.
		_stitch_frames_to_video(path)

func _render_and_save_image(path: String, render_size: Vector2i) -> void:
	# --- STAGE 1: Render the raw high-resolution fractal ---
	var source_viewport = viewport_a if is_a_source else viewport_b
	var previous_frame_texture = source_viewport.get_texture()

	save_viewport.size = render_size
	var save_material = save_viewport.get_node("ShaderRect").material as ShaderMaterial
	var is_animating = not _speed_controls.is_empty()
	save_material.set_shader_parameter("is_animating", is_animating)

	# Set all the fractal parameters
	save_material.set_shader_parameter("previous_frame", previous_frame_texture)
	save_material.set_shader_parameter("variation_mode_a", variation_mode_a)
	save_material.set_shader_parameter("variation_mode_b", variation_mode_b)
	save_material.set_shader_parameter("start_pattern_mode", start_pattern_mode)
	save_material.set_shader_parameter("variation_mix", variation_mix)
	save_material.set_shader_parameter("time", time) # Use current time for consistency
	save_material.set_shader_parameter("pre_scale", pre_scale)
	save_material.set_shader_parameter("pre_rotation", pre_rotation)
	save_material.set_shader_parameter("pre_translate", pre_translate)
	save_material.set_shader_parameter("post_scale", post_scale)
	save_material.set_shader_parameter("post_rotation", post_rotation)
	save_material.set_shader_parameter("post_translate", post_translate)
	save_material.set_shader_parameter("feedback_amount", feedback_amount)
	save_material.set_shader_parameter("seamless_tiling", seamless_tiling)
	save_material.set_shader_parameter("mirror_tiling", mirror_tiling)
	save_material.set_shader_parameter("show_grid", show_start_grid)
	save_material.set_shader_parameter("show_circles", show_circles)
	save_material.set_shader_parameter("circle_count", circle_count)
	save_material.set_shader_parameter("circle_radius", circle_radius)
	save_material.set_shader_parameter("circle_softness", circle_softness)
	save_material.set_shader_parameter("circle_grid_scale", circle_grid_scale)
	save_material.set_shader_parameter("circle_grid_radius", circle_grid_radius)
	save_material.set_shader_parameter("circle_grid_softness", circle_grid_softness)
	save_material.set_shader_parameter("translate_a", translate_a)
	save_material.set_shader_parameter("translate_b", translate_b)
	save_material.set_shader_parameter("grad_col_tl", grad_col_tl)
	save_material.set_shader_parameter("grad_col_tr", grad_col_tr)
	save_material.set_shader_parameter("grad_col_bl", grad_col_bl)
	save_material.set_shader_parameter("grad_col_br", grad_col_br)
	save_material.set_shader_parameter("background_texture", background_texture)
	save_material.set_shader_parameter("escape_shape", escape_shape)
	for param_name in _auto_params_a:
		save_material.set_shader_parameter(param_name,_auto_params_a[param_name])
	
	for param_name in _auto_params_b:
		save_material.set_shader_parameter(param_name, _auto_params_b[param_name])
	# Var A Params
	
	save_material.set_shader_parameter("blur_amount_a", blur_amount_a)


	save_material.set_shader_parameter("custom_tl_a", custom_tl_a_id)
	save_material.set_shader_parameter("custom_tr_a", custom_tr_a_id)
	save_material.set_shader_parameter("custom_bl_a", custom_bl_a_id)
	save_material.set_shader_parameter("custom_br_a", custom_br_a_id)
	save_material.set_shader_parameter("use_escape_time", use_escape_time)
	save_material.set_shader_parameter("escape_limit", escape_limit)
	save_material.set_shader_parameter("escape_smoothness", escape_smoothness)
	save_material.set_shader_parameter("escape_invert", escape_invert)
	
	# Var B Params
	save_material.set_shader_parameter("blur_amount_b", blur_amount_b)


	save_material.set_shader_parameter("custom_tl_b", custom_tl_b_id)
	save_material.set_shader_parameter("custom_tr_b", custom_tr_b_id)
	save_material.set_shader_parameter("custom_bl_b", custom_bl_b_id)
	save_material.set_shader_parameter("custom_br_b", custom_br_b_id)

	# Wait for the raw fractal to render
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw # Sometimes need two waits

	var raw_fractal_texture = save_viewport.get_texture()

	# --- STAGE 2: Render the post-processed image ---
	post_process_save_viewport.size = render_size
	var post_save_material = post_process_save_viewport.get_node("ShaderRect").material as ShaderMaterial

	# Feed the raw fractal into the post-processing shader
	post_process_save_viewport.get_node("ShaderRect").texture = raw_fractal_texture

	# Set the color grading & post-fx parameters
	post_save_material.set_shader_parameter("brightness", brightness)
	post_save_material.set_shader_parameter("contrast", contrast)
	post_save_material.set_shader_parameter("saturation", saturation)
	post_save_material.set_shader_parameter("mirror_x", mirror_x)
	post_save_material.set_shader_parameter("mirror_y", mirror_y)
	post_save_material.set_shader_parameter("kaleidoscope_on", kaleidoscope_on)
	post_save_material.set_shader_parameter("kaleidoscope_slices", kaleidoscope_slices)

	# Wait for the post-processing to render
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw # Sometimes need two waits

	var final_image = post_process_save_viewport.get_texture().get_image()

	# --- SAVE THE FINAL IMAGE ---
	if OS.has_feature("web"):
		var buffer = final_image.save_png_to_buffer()
		var dt = Time.get_datetime_dict_from_system()
		var filename = "%04d-%02d-%02d_%02d-%02d-%02d.png" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
		JavaScriptBridge.download_buffer(buffer, filename, "image/png")
		print("Download initiated for " + filename)
	else:
		var error = final_image.save_png(path)
		if error == OK:
			print("Image saved successfully to: " + path)
		else:
			printerr("Error saving image. Code: ", error)

	# Clean up viewport sizes to avoid unnecessary rendering
	save_viewport.size = Vector2i(1, 1)
	post_process_save_viewport.size = Vector2i(1, 1)

func _process(delta: float) -> void:
	# --- AUTO ROTATION LOGIC ---
	if auto_rotate_active and is_3d_view and not animation_paused:
		var speed_mult = rotate_speed * delta * 30.0
		
		# Apply rotation to all axes based on the random vector
		camera_x_rotation += auto_rotate_vector.x * speed_mult
		camera_y_rotation += auto_rotate_vector.y * speed_mult
		camera_z_rotation += auto_rotate_vector.z * speed_mult
		
		# Wrap variables to keep numbers clean
		if camera_y_rotation > 360.0: camera_y_rotation -= 360.0
		if camera_x_rotation > 360.0: camera_x_rotation -= 360.0
		if camera_z_rotation > 360.0: camera_z_rotation -= 360.0
		
		# Update UI sliders visually
		%CameraXRotSlider.set_value_no_signal(camera_x_rotation)
		camera_x_rot_spinbox.set_value_no_signal(camera_x_rotation)
		
		%CameraYRotSlider.set_value_no_signal(camera_y_rotation)
		camera_y_rot_spinbox.set_value_no_signal(camera_y_rotation)
		
		%CameraZRotSlider.set_value_no_signal(camera_z_rotation)
		# If you added a CameraZRotSpinBox, update it here too:
		camera_z_rot_spinbox.set_value_no_signal(camera_z_rotation)
		
		# Actually move the camera
		_update_camera()
	if OS.has_feature("web"):
		# --- Existing Mailbox Check for Files ---
		var b64_data = JavaScriptBridge.eval("window.loadedImageData || null")
		if b64_data != null:
			JavaScriptBridge.eval("window.loadedImageData = null;")
			_load_image_from_base64(b64_data)

		var preset_json_string = JavaScriptBridge.eval("window.loadedPresetData || null")
		if preset_json_string != null:
			print("Control _process: Found loaded preset data in JS mailbox.")
			JavaScriptBridge.eval("window.loadedPresetData = null;")
			var data = JSON.parse_string(preset_json_string)
			if data:
				_apply_preset_data(data)
			else:
				print("Control Error: Could not parse loaded preset JSON string from mailbox.")
		# --- END Existing Mailbox Check ---

		# --- NEW Mailbox Check for Pasted Preset ---
		var pasted_preset_string = JavaScriptBridge.eval("window.pastedPresetData || null")
		if pasted_preset_string != null:
			print("Control _process: Found pasted preset data in JS mailbox.")
			JavaScriptBridge.eval("window.pastedPresetData = null;") # Clear mailbox
			var parse_result = JSON.parse_string(pasted_preset_string)
			if parse_result != null:
				_apply_preset_data(parse_result)
				print("Control: Applied preset pasted from clipboard.")
			else:
				print("Control Error: Pasted clipboard text is not a valid preset.")
		# --- END NEW Mailbox Check ---
	# Only use real-time if we are NOT recording.
	# If we ARE recording, the Timer will handle the time steps manually.
	var stop_time_for_recording = is_recording and not OS.has_feature("web")
	if not animation_paused and not stop_time_for_recording:
		time += delta
	# print("2. Process is using pre_translate: ", pre_translate) # DEBUG

	var source_viewport = viewport_a if is_a_source else viewport_b
	var target_viewport = viewport_b if is_a_source else viewport_a

	var previous_frame_texture = source_viewport.get_texture()
	var target_material = target_viewport.get_node("ShaderRect").material as ShaderMaterial
	var is_animating = not _speed_controls.is_empty()
	# --- SEND ESCAPE TIME PARAMS ---
	target_material.set_shader_parameter("use_escape_time", use_escape_time)
	target_material.set_shader_parameter("escape_limit", escape_limit)
	target_material.set_shader_parameter("is_animating", is_animating)
	target_material.set_shader_parameter("escape_shape", escape_shape)
	target_material.set_shader_parameter("escape_smoothness", escape_smoothness)
	target_material.set_shader_parameter("escape_invert", escape_invert)
	
	
	# Send Auto-Params for A
	for param_name in _auto_params_a:
			target_material.set_shader_parameter(param_name, _auto_params_a[param_name])
	# Send Auto-Params for B
	for param_name in _auto_params_b:
		target_material.set_shader_parameter(param_name, _auto_params_b[param_name])
	# --- Set Fractal Shader Params ---
	target_material.set_shader_parameter("previous_frame", previous_frame_texture)
	
	target_material.set_shader_parameter("variation_mode_a", variation_mode_a)
	target_material.set_shader_parameter("variation_mode_b", variation_mode_b)
	target_material.set_shader_parameter("start_pattern_mode", start_pattern_mode)
	target_material.set_shader_parameter("variation_mix", variation_mix)
	target_material.set_shader_parameter("time", time)
	target_material.set_shader_parameter("pre_scale", pre_scale)
	target_material.set_shader_parameter("pre_rotation", pre_rotation)
	target_material.set_shader_parameter("pre_translate", pre_translate)
	target_material.set_shader_parameter("post_scale", post_scale)
	target_material.set_shader_parameter("post_rotation", post_rotation)
	target_material.set_shader_parameter("post_translate", post_translate)
	target_material.set_shader_parameter("feedback_amount", feedback_amount)
	target_material.set_shader_parameter("seamless_tiling", seamless_tiling)
	target_material.set_shader_parameter("mirror_tiling", mirror_tiling)
	target_material.set_shader_parameter("show_grid", show_start_grid)
	target_material.set_shader_parameter("show_circles", show_circles)
	target_material.set_shader_parameter("circle_count", circle_count)
	target_material.set_shader_parameter("circle_radius", circle_radius)
	target_material.set_shader_parameter("circle_softness", circle_softness)
	target_material.set_shader_parameter("circle_grid_scale", circle_grid_scale)
	target_material.set_shader_parameter("circle_grid_radius", circle_grid_radius)
	target_material.set_shader_parameter("circle_grid_softness", circle_grid_softness)
	target_material.set_shader_parameter("translate_a", translate_a)
	target_material.set_shader_parameter("translate_b", translate_b)
	target_material.set_shader_parameter("grad_col_tl", grad_col_tl)
	target_material.set_shader_parameter("grad_col_tr", grad_col_tr)
	target_material.set_shader_parameter("grad_col_bl", grad_col_bl)
	target_material.set_shader_parameter("grad_col_br", grad_col_br)
	target_material.set_shader_parameter("background_texture", background_texture)

	# Var A Params
	
	target_material.set_shader_parameter("blur_amount_a", blur_amount_a)


	target_material.set_shader_parameter("custom_tl_a", custom_tl_a_id)
	target_material.set_shader_parameter("custom_tr_a", custom_tr_a_id)
	target_material.set_shader_parameter("custom_bl_a", custom_bl_a_id)
	target_material.set_shader_parameter("custom_br_a", custom_br_a_id)
	

	# Var B Params
	target_material.set_shader_parameter("blur_amount_b", blur_amount_b)


	target_material.set_shader_parameter("custom_tl_b", custom_tl_b_id)
	target_material.set_shader_parameter("custom_tr_b", custom_tr_b_id)
	target_material.set_shader_parameter("custom_bl_b", custom_bl_b_id)
	target_material.set_shader_parameter("custom_br_b", custom_br_b_id)
	# ---------------------------------

	# --- Set Post Process Shader Params ---
	post_process_material.set_shader_parameter("brightness", brightness)
	post_process_material.set_shader_parameter("contrast", contrast)
	post_process_material.set_shader_parameter("saturation", saturation)
	post_process_material.set_shader_parameter("mirror_x", mirror_x)
	post_process_material.set_shader_parameter("mirror_y", mirror_y)
	post_process_material.set_shader_parameter("kaleidoscope_on", kaleidoscope_on)
	post_process_material.set_shader_parameter("kaleidoscope_slices", kaleidoscope_slices)
	# ------------------------------------

	final_output.texture = target_viewport.get_texture()
	is_a_source = not is_a_source

	# --- NEW 3D MESH UPDATE (DISPLACEMENT + COLOR) ---
	var mesh_material = fractal_mesh.get_surface_override_material(0) as ShaderMaterial
	
	if is_instance_valid(mesh_material):
		var current_shape = shape_selector_button.selected
		
		# --- 1. CRITICAL: SEND TEXTURE TO EVERYONE ---
		var tex = viewport_b.get_texture() if is_a_source else viewport_a.get_texture()
		mesh_material.set_shader_parameter("fractal_texture", tex)

		# --- 2. UNIVERSAL PARAMS ---
		mesh_material.set_shader_parameter("brightness", brightness)
		mesh_material.set_shader_parameter("contrast", contrast)
		mesh_material.set_shader_parameter("saturation", saturation)
		
		# --- TEXTURE & DISPLACEMENT (UNIFIED) ---
		mesh_material.set_shader_parameter("texture_intensity", mandel_texture_intensity)
		mesh_material.set_shader_parameter("texture_scale", mandel_texture_scale)
		
		# *** THIS IS THE CHANGE ***
		# We use 'displacement_strength' (the main slider variable)
		# instead of 'mandel_displacement' (the one we deleted).
		mesh_material.set_shader_parameter("displacement_strength", displacement_strength)
		mesh_material.set_shader_parameter("displacement_smoothness", displacement_smoothness)
		mesh_material.set_shader_parameter("emission_energy", emission_strength)

		# --- 3. RAYMARCH SPECIFIC PARAMS ---
		if is_raymarching:
			mesh_material.set_shader_parameter("step_speed", current_step_speed)
			# Send Light Data
			if light_3d:
				var light_dir = light_3d.global_transform.basis.z
				mesh_material.set_shader_parameter("light_direction", light_dir)
				var l_col = Vector3(light_color.r, light_color.g, light_color.b)
				mesh_material.set_shader_parameter("light_color_val", l_col)
				mesh_material.set_shader_parameter("light_energy_val", light_energy)

			# Send Core Fractal Data
			mesh_material.set_shader_parameter("power", mandel_power)
			mesh_material.set_shader_parameter("iterations", ray_iterations)
			
			# Shape Specifics
			if current_shape == 7: # Amazing Box
				mesh_material.set_shader_parameter("folding_limit", ab_fold_limit)
				mesh_material.set_shader_parameter("fixed_radius", ab_fixed_radius)
				mesh_material.set_shader_parameter("min_radius", 0.5)
				
			# We send these to 5, 6, 7, and 8 now!
			mesh_material.set_shader_parameter("fold_rotate", as_rotate)
			mesh_material.set_shader_parameter("twist", as_twist)
			mesh_material.set_shader_parameter("wave_strength", as_wave_str)
			mesh_material.set_shader_parameter("wave_frequency", as_wave_freq)
			mesh_material.set_shader_parameter("julia_offset", as_julia)

			# --- SHAPE SPECIFIC EXTRAS ---
			if current_shape == 7: # Amazing Box
				mesh_material.set_shader_parameter("folding_limit", ab_fold_limit)
				mesh_material.set_shader_parameter("fixed_radius", ab_fixed_radius)
				mesh_material.set_shader_parameter("min_radius", 0.5)
				
			elif current_shape == 8: # Amazing Surf
				# Surf needs Fold Limit too
				mesh_material.set_shader_parameter("folding_limit", as_fold_limit)
				mesh_material.set_shader_parameter("julia_offset", as_julia)
				mesh_material.set_shader_parameter("twist", as_twist)
				mesh_material.set_shader_parameter("wave_strength", as_wave_str)
				mesh_material.set_shader_parameter("wave_frequency", as_wave_freq)
		else:
			# --- 4. NORMAL MESH SPECIFIC PARAMS ---
			# Normal displacement shader needs 'displacement_offset' specifically
			mesh_material.set_shader_parameter("displacement_offset", height_offset)
			mesh_material.set_shader_parameter("limit_displacement_to_top", limit_to_top)
			mesh_material.set_shader_parameter("use_dynamic_material", use_dynamic_material)
func _load_image_from_base64(b64_string: String) -> void:
	if not "," in b64_string:
		print("Error: Invalid Base64 string format (missing comma).")
		return

	var base64_data = b64_string.split(",")[1]
	var image_bytes = Marshalls.base64_to_raw(base64_data)

	if image_bytes.is_empty():
		print("Error: Failed to decode Base64 data.")
		return

	var image = Image.new()
	var error = FAILED # Start with a failure state

	# Determine format from header if possible
	var header = b64_string.split(",")[0]
	if "image/png" in header:
		error = image.load_png_from_buffer(image_bytes)
	elif "image/jpeg" in header or "image/jpg" in header:
		error = image.load_jpeg_from_buffer(image_bytes)
	elif "image/webp" in header:
		error = image.load_webp_from_buffer(image_bytes)
	else:
		# If header is generic or missing, try common formats
		print("Warning: Unknown image type in Base64 header, attempting common formats.")
		error = image.load_png_from_buffer(image_bytes)
		if error != OK:
			error = image.load_jpeg_from_buffer(image_bytes)
		if error != OK:
			error = image.load_webp_from_buffer(image_bytes)

	if error == OK:
		background_texture = ImageTexture.create_from_image(image)
		reseed_pattern()
		print("Background image loaded successfully from browser.")
	else:
		print("Error: Could not load image from Base64 data. Format might be unsupported or data corrupted. Error code: ", error)

func load_image_from_js(buffer: PackedByteArray) -> void:
	# Deprecated? _load_image_from_base64 handles the web loading now.
	# Keep if you have another JS path that sends raw bytes.
	if buffer.is_empty():
		print("Error: Received empty buffer from JavaScript.")
		return

	var image = Image.new()
	var error = image.load_png_from_buffer(buffer)
	if error != OK:
		error = image.load_jpeg_from_buffer(buffer)
	if error != OK:
		error = image.load_webp_from_buffer(buffer) # Add WebP check

	if error == OK:
		background_texture = ImageTexture.create_from_image(image)
		reseed_pattern()
		print("Background image loaded successfully from JS buffer.")
	else:
		print("Error: Could not load image from the provided JS data. Error code: ", error)


func _gather_preset_data() -> Dictionary:
	var data = {
		# Version & Main Controls
		"version": PROGRAM_VERSION,
		"variation_mode_a_id": variation_mode_a, # Save ID
		"variation_mode_b_id": variation_mode_b, # Save ID
		"start_pattern_mode": start_pattern_mode,
		"variation_mix": variation_mix,
		"feedback_amount": feedback_amount,
		"feedback_min": feedback_min,
		"feedback_max": feedback_max,
		"seamless_tiling": seamless_tiling,
		"mirror_tiling": mirror_tiling,
		"reset_on_drag_enabled": reset_on_drag_enabled,
		"save_resolution_index": save_resolution_index,
		"animation_paused": animation_paused,

		# Start Patterns
		"show_start_grid": show_start_grid,
		"show_circles": show_circles,
		"circle_count": circle_count,
		"circle_radius": circle_radius,
		"circle_softness": circle_softness,
		"grad_col_tl": {"r": grad_col_tl.r, "g": grad_col_tl.g, "b": grad_col_tl.b, "a": grad_col_tl.a},
		"grad_col_tr": {"r": grad_col_tr.r, "g": grad_col_tr.g, "b": grad_col_tr.b, "a": grad_col_tr.a},
		"grad_col_bl": {"r": grad_col_bl.r, "g": grad_col_bl.g, "b": grad_col_bl.b, "a": grad_col_bl.a},
		"grad_col_br": {"r": grad_col_br.r, "g": grad_col_br.g, "b": grad_col_br.b, "a": grad_col_br.a},

		# Transforms & Color
		"pre_scale": pre_scale,
		"pre_rotation": pre_rotation,
		"pre_translate": {"x": pre_translate.x, "y": pre_translate.y},
		"post_scale": post_scale,
		"post_rotation": post_rotation,
		"post_translate": {"x": post_translate.x, "y": post_translate.y},
		"translate_a": {"x": translate_a.x, "y": translate_a.y},
		"translate_b": {"x": translate_b.x, "y": translate_b.y},
		"brightness": brightness,
		"contrast": contrast,
		"saturation": saturation,

		# Active Mouse Translate
		"move_post_translate": move_post_translate,
		"move_pre_translate": move_pre_translate,
		"move_var_a_translate": move_var_a_translate,
		"move_var_b_translate": move_var_b_translate,

		# Post-Processing Symmetry
		"post_mirror_x": mirror_x,
		"post_mirror_y": mirror_y,
		"post_kaleidoscope_on": kaleidoscope_on,
		"post_kaleidoscope_slices": kaleidoscope_slices,

		# Variation A Parameters

		


		"blur_amount_a": blur_amount_a,


		"custom_tl_a": custom_tl_a_id,
		"custom_tr_a": custom_tr_a_id,
		"custom_bl_a": custom_bl_a_id,
		"custom_br_a": custom_br_a_id,

		# Variation B Parameters



		"blur_amount_b": blur_amount_b,


		"custom_tl_b": custom_tl_b_id,
		"custom_tr_b": custom_tr_b_id,
		"custom_bl_b": custom_bl_b_id,
		"custom_br_b": custom_br_b_id,
		
		# --- ADD THESE ---
		"light_x_rotation": light_x_rotation,
		"light_y_rotation": light_y_rotation,
		"light_energy": light_energy,
		"light_color": {"r": light_color.r, "g": light_color.g, "b": light_color.b, "a": light_color.a},
		"light_shadows": light_shadows,
		# --- END ---
		
		"normal_map_strength": normal_map_strength,
		
		"camera_distance": camera_distance,
		"camera_x_rotation": camera_x_rotation,
		"camera_y_rotation": camera_y_rotation,
		"camera_z_rotation": camera_z_rotation,
		"camera_fov": camera_fov,
		"show_2d_background": show_2d_background,
		"displacement_strength": displacement_strength,
		"height_offset": height_offset,
		"displacement_smoothness": displacement_smoothness,
		"limit_to_top": limit_to_top,
		"emission_strength": emission_strength,
		"use_dynamic_material": use_dynamic_material,
		"grade_background_active": grade_background_active,
		"tex_int": mandel_texture_intensity,
		"tex_scale": mandel_texture_scale,
	}
	data.merge(_auto_params_a, true) # Add all "A" auto-params
	data.merge(_auto_params_b, true) # Add all "B" auto-params
	return data

func _apply_preset_data(data: Dictionary) -> void:
	print("ApplyPreset: Start.")
	print("  - Before 1st SetState: pre=%s, post=%s, a=%s, b=%s" % [pre_translate, post_translate, translate_a, translate_b])

	# 1. Set state from data
	_set_state_from_preset_data(data)
	print("ApplyPreset: After 1st SetState.")
	print("  - Values: pre=%s, post=%s, a=%s, b=%s" % [pre_translate, post_translate, translate_a, translate_b])

	# 2. Update UI
	update_ui_from_state()
	print("ApplyPreset: After UI Update.")
	print("  - Values: pre=%s, post=%s, a=%s, b=%s" % [pre_translate, post_translate, translate_a, translate_b])
	
	_on_var_a_dropdown_item_selected(var_a_dropdown.selected)
	_on_var_b_dropdown_item_selected(var_b_dropdown.selected)
	_on_start_pattern_dropdown_item_selected(start_pattern_dropdown.selected)

	
	# 3. No need to re-apply ranges, update_ui_from_state handled it.
	# 4. Reseed
	reseed_pattern()
	print("Preset applied successfully. Final values:")
	print("  - Final: pre=%s, post=%s, a=%s, b=%s" % [pre_translate, post_translate, translate_a, translate_b])

# --- Helper function for robust Color loading ---
# MOVED TO CLASS LEVEL (OUTSIDE _set_state_from_preset_data)
func get_color(data: Dictionary, key: String, default_color: Color) -> Color:
	if data.has(key):
		var loaded_val = data[key]
		if typeof(loaded_val) == TYPE_DICTIONARY and loaded_val.has("r") and loaded_val.has("g") and loaded_val.has("b") and loaded_val.has("a"):
			# Ensure values are numbers
			if typeof(loaded_val.r) in [TYPE_INT, TYPE_FLOAT] and \
				typeof(loaded_val.g) in [TYPE_INT, TYPE_FLOAT] and \
				typeof(loaded_val.b) in [TYPE_INT, TYPE_FLOAT] and \
				typeof(loaded_val.a) in [TYPE_INT, TYPE_FLOAT]:
				return Color(float(loaded_val.r), float(loaded_val.g), float(loaded_val.b), float(loaded_val.a))
			else:
				print("    SetState WARNING: Non-numeric value in color dict for '%s', using default." % key)
		elif typeof(loaded_val) == TYPE_STRING: # Handle clipboard format
			var converted_color = str_to_var(loaded_val)
			if typeof(converted_color) == TYPE_COLOR:
				return converted_color
			else:
				print("    SetState WARNING: Invalid string format for color '%s', using default." % key)
		else:
			print("    SetState WARNING: Unexpected type for color '%s', using default." % key)
	else:
		print("    SetState NOTE: Color key '%s' not found, using default." % key)
	return default_color

# --- Helper function for robust Vector2 loading ---
# MOVED TO CLASS LEVEL (OUTSIDE _set_state_from_preset_data)
func get_vector2(data: Dictionary, key: String, default_vector: Vector2) -> Vector2:
	var result = default_vector
	var reason = "default"
	if data.has(key):
		var val = data[key]
		if typeof(val) == TYPE_DICTIONARY and val.has("x") and val.has("y"):
			# Ensure values are numbers before creating Vector2
			if typeof(val.x) in [TYPE_INT, TYPE_FLOAT] and typeof(val.y) in [TYPE_INT, TYPE_FLOAT]:
				result = Vector2(float(val.x), float(val.y)) # Cast to float just in case
				reason = "DICT"
			else:
				reason = "DICT values not numbers, set to default"
		elif typeof(val) == TYPE_STRING:
			var converted_vec = str_to_var(val)
			if typeof(converted_vec) == TYPE_VECTOR2:
				result = converted_vec
				reason = "STRING"
			else: reason = "invalid string, set to default"
		else: reason = "unexpected type, set to default"
	else: reason = "key not found, set to default"

	print("    SetState: %s set from %s: %s" % [key, reason, result])
	return result

# --- Function to apply loaded data to variables ---
func _set_state_from_preset_data(data: Dictionary) -> void:
	print("  SetState: Applying data...")
	
	# --- CLEAR OLD AUTO-PARAMS ---
	_auto_params_a.clear()
	_auto_params_b.clear()
	_speed_controls.clear()
	if data.has("variation_mode_a_id"):
		variation_mode_a = int(data["variation_mode_a_id"])
	if data.has("variation_mode_b_id"):
		variation_mode_b = int(data["variation_mode_b_id"])
	# --- PASS 1: Load all hard-coded class variables ---
	# This is critical so we know which variations are active.
	for key in data:
		var value = data[key]
		if key in self: # Check if it's a known class variable
			# Special handling for vectors/colors from JSON
			if "translate" in key or key.begins_with("ap_c"):
				set(key, get_vector2(data, key, Vector2.ZERO))
			elif "grad_col" in key or key == "light_color":
				set(key, get_color(data, key, Color.WHITE))
			else:
				# It's a simple value (float, bool, int), just set it
				set(key, value) # This sets variation_mode_a, etc.
	animation_paused = data.get("animation_paused", false)

	# --- PASS 2: Pre-populate auto-params with defaults ---
	# Now that variation_mode_a is set, we find its panel and load its defaults.
	var control_string_a = _get_control_string_from_id(variation_mode_a)
	if control_string_a != "" and var_a_panels.has(control_string_a):
		var panel_a = var_a_panels[control_string_a]
		if panel_a is VariationPanel:
			for param in panel_a.parameters:
				_auto_params_a[param.name] = param.default

	# Do the same for Variation B
	var control_string_b = _get_control_string_from_id(variation_mode_b)
	if control_string_b != "" and var_b_panels.has(control_string_b):
		var panel_b = var_b_panels[control_string_b]
		if panel_b is VariationPanel:
			for param in panel_b.parameters:
				_auto_params_b[param.name] = param.default

	# --- PASS 3: Load saved auto-param values from file ---
	for key in data:
		var value = data[key]
		if not (key in self): # Only check keys that are NOT class variables
			
			# Check if this key (e.g., "clifford_a_a_speed")
			# exists in the parameters for the active Var A panel.
			if _auto_params_a.has(key):
				_auto_params_a[key] = value
				
				# --- ADD THIS BLOCK ---
				# If this is a speed key and it's not zero,
				# add it to the active speed controls.
				if key.ends_with("_speed") and value != 0.0:
					_speed_controls[key] = value
				# --- END ADD ---
				
			# Check if this key (e.g., "clifford_b_b_speed")
			# exists in the parameters for the active Var B panel.
			elif _auto_params_b.has(key):
				_auto_params_b[key] = value
				
				# --- ADD THIS BLOCK ---
				if key.ends_with("_speed") and value != 0.0:
					_speed_controls[key] = value

	var preset_version = data.get("version", 0.0)
	print("  SetState: Preset was created with version: ", preset_version)
	
	# Set platform-specific feedback ranges, but let loaded values override
	_set_platform_feedback_defaults()
	feedback_min = data.get("feedback_min", feedback_min)
	feedback_max = data.get("feedback_max", feedback_max)
	var loaded_feedback_amount = data.get("feedback_amount", feedback_amount)
	feedback_amount = clamp(loaded_feedback_amount, feedback_min, feedback_max)

	# Apply 3D settings
	_update_light()
	_update_camera()
	_update_background()

	print("  SetState: Finished applying data.")


# =================================================================
# --- UI CONTROL LOGIC & SIGNAL CALLBACKS ---
# =================================================================

func _on_variation_mix_changed(value: float):
	variation_mix = value
	var_mix_slider.set_value_no_signal(value)
	var_mix_spinbox.set_value_no_signal(value)

func _on_var_mix_slider_value_changed(value: float) -> void:
	_on_variation_mix_changed(value)

func _on_var_mix_spin_box_value_changed(value: float) -> void:
	_on_variation_mix_changed(value)

# --- Feedback Amount ---
func _on_feedback_amount_changed(value: float):
	feedback_amount = value
	feedback_amount_slider.set_value_no_signal(value)
	feedback_amount_spinbox.set_value_no_signal(value)

func _on_feedback_amount_slider_value_changed(value: float):
	_on_feedback_amount_changed(value)

func _on_feedback_amount_spinbox_value_changed(value: float):
	_on_feedback_amount_changed(value)

# --- Feedback Range (These are simpler) ---
func _on_feedback_range_min_spinbox_value_changed(value: float):
	feedback_min = value
	_update_feedback_ranges_in_ui() # This is your existing helper function

func _on_feedback_range_max_spinbox_value_changed(value: float):
	feedback_max = value
	_update_feedback_ranges_in_ui() # This is your existing helper function

# --- Pre-Scale ---
func _on_pre_scale_changed(value: float):
	pre_scale = value
	pre_scale_slider.set_value_no_signal(value)
	pre_scale_spinbox.set_value_no_signal(value)

func _on_pre_scale_slider_value_changed(value: float):
	_on_pre_scale_changed(value)

func _on_pre_scale_spinbox_value_changed(value: float):
	_on_pre_scale_changed(value)

# --- Pre-Rotation ---
func _on_pre_rotation_changed(value: float):
	pre_rotation = value
	pre_rotation_slider.set_value_no_signal(value)
	pre_rotation_spinbox.set_value_no_signal(value)
	
func _on_pre_rotation_slider_value_changed(value: float):
	_on_pre_rotation_changed(value)

func _on_pre_rotation_spinbox_value_changed(value: float):
	_on_pre_rotation_changed(value)

# --- Post-Scale ---
func _on_post_scale_changed(value: float):
	post_scale = value
	post_scale_slider.set_value_no_signal(value)
	post_scale_spinbox.set_value_no_signal(value)

func _on_post_scale_slider_value_changed(value: float):
	_on_post_scale_changed(value)

func _on_post_scale_spinbox_value_changed(value: float):
	_on_post_scale_changed(value)

# --- Post-Rotation ---
func _on_post_rotation_changed(value: float):
	post_rotation = value
	post_rotation_slider.set_value_no_signal(value)
	post_rotation_spinbox.set_value_no_signal(value)

func _on_post_rotation_slider_value_changed(value: float):
	_on_post_rotation_changed(value)

func _on_post_rotation_spinbox_value_changed(value: float):
	_on_post_rotation_changed(value)

# --- Brightness ---
func _on_brightness_changed(value: float):
	brightness = value
	brightness_slider.set_value_no_signal(value)
	brightness_spinbox.set_value_no_signal(value)

func _on_brightness_slider_value_changed(value: float):
	_on_brightness_changed(value)
	
func _on_brightness_spinbox_value_changed(value: float):
	_on_brightness_changed(value)

# --- Contrast ---
func _on_contrast_changed(value: float):
	contrast = value
	contrast_slider.set_value_no_signal(value)
	contrast_spinbox.set_value_no_signal(value)
	
func _on_contrast_slider_value_changed(value: float):
	_on_contrast_changed(value)

func _on_contrast_spinbox_value_changed(value: float):
	_on_contrast_changed(value)

# --- Saturation ---
func _on_saturation_changed(value: float):
	saturation = value
	saturation_slider.set_value_no_signal(value)
	saturation_spinbox.set_value_no_signal(value)

func _on_saturation_slider_value_changed(value: float):
	_on_saturation_changed(value)

func _on_saturation_spinbox_value_changed(value: float):
	_on_saturation_changed(value)

# --- Circle Count ---
func _on_circle_count_changed(value: float):
	circle_count = value
	circle_count_slider.set_value_no_signal(value)
	circle_count_spinbox.set_value_no_signal(value)

func _on_circle_count_slider_value_changed(value: float):
	_on_circle_count_changed(value)
	
func _on_circle_count_spinbox_value_changed(value: float):
	_on_circle_count_changed(value)

# --- Circle Radius ---
func _on_circle_radius_changed(value: float):
	circle_radius = value
	circle_radius_slider.set_value_no_signal(value)
	circle_radius_spinbox.set_value_no_signal(value)

func _on_circle_radius_slider_value_changed(value: float):
	_on_circle_radius_changed(value)

func _on_circle_radius_spinbox_value_changed(value: float):
	_on_circle_radius_changed(value)

# --- Circle Softness ---
func _on_circle_softness_changed(value: float):
	circle_softness = value
	circle_softness_slider.set_value_no_signal(value)
	circle_softness_spinbox.set_value_no_signal(value)

func _on_circle_softness_slider_value_changed(value: float):
	_on_circle_softness_changed(value)

func _on_circle_softness_spinbox_value_changed(value: float):
	_on_circle_softness_changed(value)


# --- Circle Grid Scale ---
func _on_circle_grid_scale_changed(value: float):
	circle_grid_scale = value
	circle_grid_scale_slider.set_value_no_signal(value)
	circle_grid_scale_spinbox.set_value_no_signal(value)
	reseed_pattern()

func _on_circle_grid_scale_slider_value_changed(value: float):
	_on_circle_grid_scale_changed(value)

func _on_circle_grid_scale_spinbox_value_changed(value: float):
	_on_circle_grid_scale_changed(value)

# --- Circle Grid Radius ---
func _on_circle_grid_radius_changed(value: float):
	circle_grid_radius = value
	circle_grid_radius_slider.set_value_no_signal(value)
	circle_grid_radius_spinbox.set_value_no_signal(value)
	reseed_pattern()

func _on_circle_grid_radius_slider_value_changed(value: float):
	_on_circle_grid_radius_changed(value)

func _on_circle_grid_radius_spinbox_value_changed(value: float):
	_on_circle_grid_radius_changed(value)

# --- Circle Grid Softness ---
func _on_circle_grid_softness_changed(value: float):
	circle_grid_softness = value
	circle_grid_softness_slider.set_value_no_signal(value)
	circle_grid_softness_spinbox.set_value_no_signal(value)
	reseed_pattern()

func _on_circle_grid_softness_slider_value_changed(value: float):
	_on_circle_grid_softness_changed(value)

func _on_circle_grid_softness_spinbox_value_changed(value: float):
	_on_circle_grid_softness_changed(value)



# --- ADD THIS NEW FUNCTION ---
func _update_var_a_visibility(control_key: String):
	# 1. Hide all panels
	for key in var_a_panels:
		var_a_panels[key].visible = false
	
	# 2. Show the correct one
	if control_key != "" and var_a_panels.has(control_key):
		var_a_panels[control_key].visible = true
	# (If control_key is null, like for "Sinusoidal", nothing will be shown)

func _update_var_b_visibility(control_key: String):
	# 1. Hide all panels
	for key in var_b_panels:
		var_b_panels[key].visible = false
	
	# 2. Show the correct one
	if control_key != "" and var_b_panels.has(control_key):
		var_b_panels[control_key].visible = true

# --- REPLACED SIGNAL CALLBACKS ---
# (You must connect these in the editor)

func _on_var_a_dropdown_item_selected(index: int):
	var item_text = var_a_dropdown.get_item_text(index)
	var control_string = "" 

	if item_text == "Rep-Tiles":
		control_string = "rep_tile" 
		var rep_text = rep_tile_dropdown_a.get_item_text(rep_tile_dropdown_a.selected)
		if VariationManager.VARIATIONS.has(rep_text):
			variation_mode_a = VariationManager.VARIATIONS[rep_text]["id"]
		
		# --- ADD THIS CHECK ---
		if rep_text == "Custom 2x2 Tile":
			custom_2x2_controls_container_a.visible = true
		else:
			custom_2x2_controls_container_a.visible = false
		# --- END ADD ---
	else:
		if VariationManager.VARIATIONS.has(item_text):
			var data = VariationManager.VARIATIONS[item_text]
			variation_mode_a = data["id"]
			var new_control = data.get("controls")
			if new_control != null:
				control_string = new_control
		
		custom_2x2_controls_container_a.visible = false # --- ADD THIS LINE ---
	
	_update_var_a_visibility(control_string)
	if control_string != "" and var_a_panels.has(control_string):
		var panel = var_a_panels[control_string]
		if panel is VariationPanel:
			# It's an auto-panel! Load its defaults.
			for param in panel.parameters:
				_auto_params_a[param.name] = param.default

func _on_rep_tile_dropdown_a_item_selected(index: int):
	# This just updates the ID. The panel is already visible.
	var item_text = rep_tile_dropdown_a.get_item_text(index)
	if VariationManager.VARIATIONS.has(item_text):
		variation_mode_a = VariationManager.VARIATIONS[item_text]["id"]
	if item_text == "Custom 2x2 Tile":
		custom_2x2_controls_container_a.visible = true
	else:
		custom_2x2_controls_container_a.visible = false


func _on_var_b_dropdown_item_selected(index: int):
	var item_text = var_b_dropdown.get_item_text(index)
	var control_string = ""

	if item_text == "Rep-Tiles":
		control_string = "rep_tile"
		var rep_text = rep_tile_dropdown_b.get_item_text(rep_tile_dropdown_b.selected)
		if VariationManager.VARIATIONS.has(rep_text):
			variation_mode_b = VariationManager.VARIATIONS[rep_text]["id"]
		
		# --- ADD THIS CHECK ---
		if rep_text == "Custom 2x2 Tile":
			custom_2x2_controls_container_b.visible = true
		else:
			custom_2x2_controls_container_b.visible = false
		# --- END ADD ---
	else:
		if VariationManager.VARIATIONS.has(item_text):
			var data = VariationManager.VARIATIONS[item_text]
			variation_mode_b = data["id"]
			var new_control = data.get("controls")
			if new_control != null:
				control_string = new_control
		
		custom_2x2_controls_container_b.visible = false # --- ADD THIS LINE ---
	
	_update_var_b_visibility(control_string)
	
	if control_string != "" and var_b_panels.has(control_string):
		var panel = var_b_panels[control_string]
		if panel is VariationPanel:
			# It's an auto-panel! Load its defaults.
			for param in panel.parameters:
				_auto_params_b[param.name] = param.default

func _on_rep_tile_dropdown_b_item_selected(index: int):
	# This just updates the ID. The panel is already visible.
	var item_text = rep_tile_dropdown_b.get_item_text(index)
	if VariationManager.VARIATIONS.has(item_text):
		variation_mode_b = VariationManager.VARIATIONS[item_text]["id"]
	if item_text == "Custom 2x2 Tile":
		custom_2x2_controls_container_b.visible = true
	else:
		custom_2x2_controls_container_b.visible = false

# --- ADD THIS NEW HELPER FUNCTION ---
func _get_name_from_id(var_id: int) -> String:
	for key in VariationManager.VARIATIONS:
		var data = VariationManager.VARIATIONS[key]
		if data["id"] == var_id:
			return key # Returns the name, e.g., "Sinusoidal"
	return "" # Return empty string if not found

# --- ADD THIS NEW FUNCTION TO POPULATE THE UI ---
# --- ADD THIS NEW FUNCTION TO POPULATE THE UI ---
func _populate_all_dropdowns():
	# --- 1. Populate Start Pattern Dropdown ---
	start_pattern_dropdown.clear()
	# These are based on your shader's `start_pattern_mode` (int)
	start_pattern_dropdown.clear()
	start_pattern_dropdown.add_item("Gradient + Grid") # Index 0
	start_pattern_dropdown.add_item("Circles")         # Index 1
	start_pattern_dropdown.add_item("Image Input")     # Index 2
	start_pattern_dropdown.add_item("Perlin Noise")    # Index 3
	start_pattern_dropdown.add_item("Concentric Rings")     # Index 4
	# (Add more items here if you have them)

	# --- 2. Populate Variation Dropdowns ---
	var_a_dropdown.clear()
	var_b_dropdown.clear()
	rep_tile_dropdown_a.clear()
	rep_tile_dropdown_b.clear()
	
	var main_vars = []
	var rep_tile_vars = []
	
	for key in VariationManager.VARIATIONS:
		var data = VariationManager.VARIATIONS[key]
		var item_data = {"name": key, "data": data}
		
		if data.get("category") == "Rep-Tile":
			rep_tile_vars.append(item_data)
		else:
			main_vars.append(item_data)
	
	# --- CHANGE: Add "Rep-Tiles" to the list BEFORE sorting ---
	# This treats it like a normal item, so "R" sorts after "P" (Polar)
	main_vars.append({"name": "Rep-Tiles", "data": null})
	
	# Sort both lists alphabetically
	main_vars.sort_custom(func(a, b): return a["name"] < b["name"])
	rep_tile_vars.sort_custom(func(a, b): return a["name"] < b["name"])
	
	# --- REMOVED: The old manual add_item("Rep-Tiles") lines ---
	
	# Populate the dropdowns
	for item in main_vars:
		var_a_dropdown.add_item(item["name"])
		var_b_dropdown.add_item(item["name"])
		
	for item in rep_tile_vars:
		rep_tile_dropdown_a.add_item(item["name"])
		rep_tile_dropdown_b.add_item(item["name"])

	# --- 4. Populate Custom 2x2 Dropdowns ---
	# Clear all 8 dropdowns
	custom_tl_a.clear()
	custom_tr_a.clear()
	custom_bl_a.clear()
	custom_br_a.clear()
	custom_tl_b.clear()
	custom_tr_b.clear()
	custom_bl_b.clear()
	custom_br_b.clear()

	# Define the 6 transform types
	var transform_items = [
		"Identity",    # Index 0
		"Rotate +90",  # Index 1
		"Rotate 180",  # Index 2
		"Rotate -90",  # Index 3
		"Flip X",      # Index 4
		"Flip Y"       # Index 5
	]

	# Populate all 8 dropdowns with the transform types
	for item_text in transform_items:
		custom_tl_a.add_item(item_text)
		custom_tr_a.add_item(item_text)
		custom_bl_a.add_item(item_text)
		custom_br_a.add_item(item_text)
		custom_tl_b.add_item(item_text)
		custom_tr_b.add_item(item_text)
		custom_bl_b.add_item(item_text)
		custom_br_b.add_item(item_text)
		
# =================================================================
# --- Custom 2x2 Signal Callbacks ---
# =================================================================

	resolution_dropdown.clear()
	resolution_dropdown.add_item("Width: 1024px") # Index 0
	resolution_dropdown.add_item("Width: 2048px") # Index 1
	resolution_dropdown.add_item("Width: 4096px") # Index 2
	resolution_dropdown.add_item("Width: 8192px") # Index 3
	
	
	# --- 6. ADD THIS NEW SECTION ---
	shape_selector_button.clear()
	shape_selector_button.add_item("Sphere") # Index 0
	shape_selector_button.add_item("Cube")   # Index 1
	shape_selector_button.add_item("Quad")   # Index 2
	shape_selector_button.add_item("Prism")  # Index 3
	shape_selector_button.add_item("Torus")  # Index 4
	shape_selector_button.add_item("Mandelbulb (Raymarch)") # Index 5
	shape_selector_button.add_item("Menger Sponge (Raymarch)") # Index 6 
	shape_selector_button.add_item("Amazing Box (Raymarch)") # Index 7
	shape_selector_button.add_item("Amazing Surf (Raymarch)") # Index 8
	

func _get_id_from_name(var_name: String) -> int:
	if VariationManager.VARIATIONS.has(var_name):
		return VariationManager.VARIATIONS[var_name]["id"]
	return 0 # Default to 0 (Sinusoidal) if not found

func _on_custom_tl_a_item_selected(index: int):
	custom_tl_a_id = index

func _on_custom_tr_a_item_selected(index: int):
	custom_tr_a_id = index

func _on_custom_bl_a_item_selected(index: int):
	custom_bl_a_id = index

func _on_custom_br_a_item_selected(index: int):
	custom_br_a_id = index

func _on_custom_tl_b_item_selected(index: int):
	custom_tl_b_id = index

func _on_custom_tr_b_item_selected(index: int):
	custom_tr_b_id = index

func _on_custom_bl_b_item_selected(index: int):
	custom_bl_b_id = index

func _on_custom_br_b_item_selected(index: int):
	custom_br_b_id = index

func _on_randomize_toggle_button_pressed():
	# Toggle visibility
	randomize_controls_container.visible = not randomize_controls_container.visible

	# Optional: Change arrow direction text
	if randomize_controls_container.visible:
		randomize_toggle_button.text = "Randomizer Settings ▲"
	else:
		randomize_toggle_button.text = "Randomizer ▼"

func _on_gradient_toggle_button_pressed():
	gradient_controls_container.visible = not gradient_controls_container.visible
	

func _update_start_pattern_visibility():
	# 1. Get the selected index
	var selected_index = start_pattern_dropdown.selected
	
	# 2. Hide all related controls first
	gradient_toggle_button.visible = false
	circle_controls_container.visible = false
	circle_grid_controls_container.visible = false
	load_image_button.visible = false
	
	# 3. Also hide the gradient panel itself, in case it was left open
	gradient_controls_container.visible = false 
	
	# 4. Show the correct controls based on selection
	match selected_index:
		0: # Gradient + Grid
			gradient_toggle_button.visible = true
			# We leave the gradient_controls_container hidden
			# The button itself will toggle it
		1: # Circles
			circle_controls_container.visible = true
		2: # Image Input
			load_image_button.visible = true
		3: # Perlin Noise
			pass # No extra controls to show
			# Circle Grid
		4: # Concentric Rings
			gradient_toggle_button.visible = true # <-- THIS IS THE FIX
			circle_grid_controls_container.visible = true


func _on_start_pattern_dropdown_item_selected(index: int) -> void:
	start_pattern_mode = index # Update the state variable
	_update_start_pattern_visibility() # Call the helper to update the UI


# =================================================================
# --- Gradient Color Picker Signals ---
# =================================================================

func _on_grad_col_tl_picker_color_changed(color: Color):
	grad_col_tl = color

func _on_grad_col_tr_picker_color_changed(color: Color):
	grad_col_tr = color

func _on_grad_col_bl_picker_color_changed(color: Color):
	grad_col_bl = color

func _on_grad_col_br_picker_color_changed(color: Color):
	grad_col_br = color


func _on_show_circles_check_toggled(button_pressed: bool):
	show_circles = button_pressed

func _on_tiling_check_box_toggled(button_pressed: bool):
	seamless_tiling = button_pressed
	

func _on_reset_on_drag_check_toggled(button_pressed: bool):
	reset_on_drag_enabled = button_pressed


# =================================================================
# --- Post Symmetry & Tiling Signals ---
# =================================================================

func _on_mirror_tiling_check_box_toggled(button_pressed: bool):
	mirror_tiling = button_pressed

func _on_post_mirror_x_check_toggled(button_pressed: bool):
	mirror_x = button_pressed

func _on_post_mirror_y_check_toggled(button_pressed: bool):
	mirror_y = button_pressed

func _on_post_kaleidoscope_master_check_toggled(button_pressed: bool):
	kaleidoscope_on = button_pressed

func _on_kaleidoscope_slices_changed(value: float):
	kaleidoscope_slices = value
	post_kaleidoscope_slider.set_value_no_signal(value)
	post_kaleidoscope_spinbox.set_value_no_signal(value)

# --- Updated slider callback ---
func _on_post_kaleidoscope_slider_value_changed(value: float):
	_on_kaleidoscope_slices_changed(value)

# --- New spinbox callback ---




func _on_post_kaleidoscope_slices_spin_box_value_changed(value: float):
	_on_kaleidoscope_slices_changed(value)




# =================================================================
# --- Resolution Dropdown Signal ---
# =================================================================

func _on_resolution_dropdown_item_selected(index: int):
	save_resolution_index = index

# =================================================================
# --- 3D Controls Signals ---
# =================================================================



# --- 2D Background Checkbox ---
func _on_background_check_box_toggled(button_pressed: bool):
	show_2d_background = button_pressed
	_update_background() # Call helper
	_update_view_visibility() # Call helper to fix 2D/3D visibility

# --- Normal Strength ---
func _on_normal_strength_changed(value: float):
	normal_map_strength = value


func _on_normal_strength_slider_value_changed(value: float):
	_on_normal_strength_changed(value)

func _on_normal_strength_spinbox_value_changed(value: float):
	_on_normal_strength_changed(value)

# --- Light X Angle ---
func _on_light_x_angle_changed(value: float):
	light_x_rotation = value
	%LightXAngleSlider.set_value_no_signal(value) # Assuming slider is %LightXAngleSlider
	light_x_angle_spinbox.set_value_no_signal(value)
	_update_light() # Call helper

func _on_light_x_angle_slider_value_changed(value: float):
	_on_light_x_angle_changed(value)

func _on_light_x_angle_spinbox_value_changed(value: float):
	_on_light_x_angle_changed(value)

# --- Light Y Angle ---
func _on_light_y_angle_changed(value: float):
	light_y_rotation = value
	%LightYAngleSlider.set_value_no_signal(value) # Assuming slider is %LightYAngleSlider
	light_y_angle_spinbox.set_value_no_signal(value)
	_update_light() # Call helper

func _on_light_y_angle_slider_value_changed(value: float):
	_on_light_y_angle_changed(value)

func _on_light_y_angle_spinbox_value_changed(value: float):
	_on_light_y_angle_changed(value)

# --- Light Energy ---
func _on_light_energy_changed(value: float):
	light_energy = value
	%LightEnergySlider.set_value_no_signal(value) # Assuming slider is %LightEnergySlider
	light_energy_spinbox.set_value_no_signal(value)
	_update_light() # Call helper

func _on_light_energy_slider_value_changed(value: float):
	_on_light_energy_changed(value)

func _on_light_energy_spinbox_value_changed(value: float):
	_on_light_energy_changed(value)

# --- Light Color ---
func _on_light_color_picker_color_changed(color: Color):
	light_color = color
	_update_light() # Call helper
	
# --- Light Shadows ---
func _on_shadow_check_box_toggled(button_pressed: bool):
	light_shadows = button_pressed
	_update_light() # Call helper

# --- Camera Distance ---
func _on_camera_dist_changed(value: float):
	camera_distance = value
	%CameraDistSlider.set_value_no_signal(value) # Assuming slider is %CameraDistSlider
	camera_dist_spinbox.set_value_no_signal(value)
	_update_camera() # Call helper

func _on_camera_dist_slider_value_changed(value: float):
	_on_camera_dist_changed(value)

func _on_camera_dist_spinbox_value_changed(value: float):
	_on_camera_dist_changed(value)

# --- Camera X Rotate ---
func _on_camera_x_rot_changed(value: float):
	camera_x_rotation = value
	%CameraXRotSlider.set_value_no_signal(value) # Assuming slider is %CameraXRotSlider
	camera_x_rot_spinbox.set_value_no_signal(value)
	_update_camera() # Call helper

func _on_camera_x_rot_slider_value_changed(value: float):
	_on_camera_x_rot_changed(value)

func _on_camera_x_rot_spinbox_value_changed(value: float):
	_on_camera_x_rot_changed(value)

# --- Camera Y Rotate ---
func _on_camera_y_rot_changed(value: float):
	camera_y_rotation = value
	%CameraYRotSlider.set_value_no_signal(value) # Assuming slider is %CameraYRotSlider
	camera_y_rot_spinbox.set_value_no_signal(value)
	camera_z_rot_spinbox.set_value_no_signal(value)
	_update_camera() # Call helper

func _on_camera_y_rot_slider_value_changed(value: float):
	_on_camera_y_rot_changed(value)

func _on_camera_y_rot_spinbox_value_changed(value: float):
	_on_camera_y_rot_changed(value)
	
func _on_camera_z_rot_changed(value: float):
	camera_z_rotation = value
	%CameraZRotSlider.set_value_no_signal(value)
	
	if camera_z_rot_spinbox:
		camera_z_rot_spinbox.set_value_no_signal(value)
		
	_update_camera()

func _on_camera_z_rot_slider_value_changed(value: float):
	_on_camera_z_rot_changed(value)

func _on_camera_z_rot_spinbox_value_changed(value: float):
	_on_camera_z_rot_changed(value)

# --- Camera FOV ---
func _on_camera_fov_changed(value: float):
	camera_fov = value
	%CameraFovSlider.set_value_no_signal(value) # Assuming slider is %CameraFovSlider
	camera_fov_spinbox.set_value_no_signal(value)
	_update_camera() # Call helper

func _on_camera_fov_slider_value_changed(value: float):
	_on_camera_fov_changed(value)

func _on_camera_fov_spinbox_value_changed(value: float):
	_on_camera_fov_changed(value)


# =================================================================
# --- Active Translate Radio Button Signals ---
# =================================================================

func _on_post_translate_radio_toggled(button_pressed: bool):
	if button_pressed:
		# Set this one as active
		move_post_translate = true
		move_pre_translate = false
		move_var_a_translate = false
		move_var_b_translate = false
		
		# Update other buttons' visuals without firing their signals
		pre_translate_radio.set_pressed_no_signal(false)
		var_a_translate_radio.set_pressed_no_signal(false)
		var_b_translate_radio.set_pressed_no_signal(false)
	else:
		# Prevent un-toggling; a radio group must have one selection
		post_translate_radio.set_pressed_no_signal(true)

func _on_pre_translate_radio_toggled(button_pressed: bool):
	if button_pressed:
		move_post_translate = false
		move_pre_translate = true
		move_var_a_translate = false
		move_var_b_translate = false
		
		post_translate_radio.set_pressed_no_signal(false)
		var_a_translate_radio.set_pressed_no_signal(false)
		var_b_translate_radio.set_pressed_no_signal(false)
	else:
		pre_translate_radio.set_pressed_no_signal(true)

func _on_var_a_translate_radio_toggled(button_pressed: bool):
	if button_pressed:
		move_post_translate = false
		move_pre_translate = false
		move_var_a_translate = true
		move_var_b_translate = false
		
		post_translate_radio.set_pressed_no_signal(false)
		pre_translate_radio.set_pressed_no_signal(false)
		var_b_translate_radio.set_pressed_no_signal(false)
	else:
		var_a_translate_radio.set_pressed_no_signal(true)

func _on_var_b_translate_radio_toggled(button_pressed: bool):
	if button_pressed:
		move_post_translate = false
		move_pre_translate = false
		move_var_a_translate = false
		move_var_b_translate = true
		
		post_translate_radio.set_pressed_no_signal(false)
		pre_translate_radio.set_pressed_no_signal(false)
		var_a_translate_radio.set_pressed_no_signal(false)
	else:
		var_b_translate_radio.set_pressed_no_signal(true)


# =================================================================
# --- Variation-Specific Signal Callbacks ---
# =================================================================


# --- Fisheye & Polar Controls (Var A & B) ---





# --- Blur Amount A ---
func _on_blur_amount_a_changed(value: float):
	blur_amount_a = value
	blur_amount_slider_a.set_value_no_signal(value)
	blur_amount_spinbox_a.set_value_no_signal(value)

func _on_blur_amount_slider_a_value_changed(value: float):
	_on_blur_amount_a_changed(value)

func _on_blur_amount_spinbox_a_value_changed(value: float):
	_on_blur_amount_a_changed(value)

# --- Blur Amount B ---
func _on_blur_amount_b_changed(value: float):
	blur_amount_b = value
	blur_amount_slider_b.set_value_no_signal(value)
	blur_amount_spinbox_b.set_value_no_signal(value)

func _on_blur_amount_slider_b_value_changed(value: float):
	_on_blur_amount_b_changed(value)

func _on_blur_amount_spinbox_b_value_changed(value: float):
	_on_blur_amount_b_changed(value)




# =================================================================
# --- Auto-UI Panel Handlers ---
# =================================================================

# =================================================================
# --- Auto-UI Panel Handlers ---
# =================================================================

func _on_variation_param_changed(param_name: String, new_value: float, is_speed: bool, var_group: String):
	# This one function handles ALL new variation panels.
	# param_name will be "clifford_a_a", "dejong_b_a", etc.
	# var_group will be "a" or "b".
	
	if var_group == "a":
		_auto_params_a[param_name] = new_value
	else:
		_auto_params_b[param_name] = new_value
	if is_speed:
		if new_value != 0.0:
			_speed_controls[param_name] = new_value
		elif _speed_controls.has(param_name):
			_speed_controls.erase(param_name)
			
			
func setup_animations():
	# --- Get or create the default Animation Library ---
	var anim_lib: AnimationLibrary
	if animation_player.has_animation_library(""):
		anim_lib = animation_player.get_animation_library("")
	else:
		anim_lib = AnimationLibrary.new()
		animation_player.add_animation_library("", anim_lib)

	# --- Create a "Clifford Pulse" animation ---
	var anim = Animation.new()
	anim.length = 4.0 # 4 seconds long
	anim.loop_mode = Animation.LOOP_LINEAR # Make it loop

	# --- Track 1: Animate the 'clifford_a_a' slider ---
	var track_clifford_a = anim.add_track(Animation.TYPE_VALUE)
	var slider_a_path = clifford_controls_container_a.get_slider("clifford_a_a").get_path()
	anim.track_set_path(track_clifford_a, str(slider_a_path) + ":value")
	
	anim.track_insert_key(track_clifford_a, 0.0, -1.7) # Start value
	anim.track_insert_key(track_clifford_a, 2.0, 1.0)  # Mid value
	anim.track_insert_key(track_clifford_a, 4.0, -1.7) # End value (same as start)

	# --- Track 2: Animate the 'clifford_c_a' slider ---
	var track_clifford_c = anim.add_track(Animation.TYPE_VALUE)
	var slider_c_path = clifford_controls_container_a.get_slider("clifford_c_a").get_path()
	anim.track_set_path(track_clifford_c, str(slider_c_path) + ":value")
	
	anim.track_insert_key(track_clifford_c, 0.0, -0.5)
	anim.track_insert_key(track_clifford_c, 2.0, 0.8)
	anim.track_insert_key(track_clifford_c, 4.0, -0.5)

	# --- Track 3: The "No Mud" Fix ---
	var track_feedback = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_feedback, str(feedback_amount_slider.get_path()) + ":value")
	anim.track_insert_key(track_feedback, 0.0, 1.0) # Set feedback to 1.0

	# --- Add the animation to the library ---
	anim_lib.add_animation("Clifford_Pulse", anim)



# =================================================================
# --- Animation & Recording ---
# =================================================================

func _on_record_button_toggled(button_pressed: bool):
	is_recording = button_pressed
	
	if is_recording:
		# --- STARTING RECORDING ---
		record_button.text = "Stop Recording"
		
		if OS.has_feature("web"):
			# 1. Hide the UI so we record ONLY the fractal
			if ui_sidebar: ui_sidebar.visible = false
			if overlay_stop_button: overlay_stop_button.visible = true
			
			# --- FIX: WAIT FOR RESIZE ---
			# We wait 2 frames to ensure the canvas is stable before capturing
			await get_tree().process_frame
			await get_tree().process_frame
			
			# 3. Start the Browser Recorder
			JavaScriptBridge.eval("startRecording();")
			
		else:
			# --- DESKTOP START LOGIC (Unchanged) ---
			frame_counter = 0
			var full_rec_dir = ProjectSettings.globalize_path(recording_dir)
			
			var dir = DirAccess.open("user://")
			if not dir:
				printerr("CRITICAL: Cannot open 'user://' directory.")
				is_recording = false
				record_button.set_pressed_no_signal(false)
				record_button.text = "Start Recording"
				return

			if not dir.dir_exists("recordings"):
				var err = dir.make_dir("recordings")
				if err != OK:
					printerr("Failed to create recordings directory.")
					is_recording = false
					record_button.set_pressed_no_signal(false)
					record_button.text = "Start Recording"
					return
			
			var rec_dir = DirAccess.open(full_rec_dir)
			if rec_dir:
				for file in rec_dir.get_files():
					if file.ends_with(".png"):
						rec_dir.remove(file)
			
			print("Starting frame capture... Saving to: ", full_rec_dir)
			record_timer.start()
			
	else:
		# --- STOPPING RECORDING ---
		record_button.text = "Start Recording"
		
		if OS.has_feature("web"):
			# 1. Stop the Browser Recorder
			JavaScriptBridge.eval("stopRecording();")
			
			# 2. Restore the UI
			if ui_sidebar: ui_sidebar.visible = true
			if overlay_stop_button: overlay_stop_button.visible = false
			
		else:
			# --- DESKTOP STOP LOGIC (Unchanged) ---
			record_timer.stop()
			print("Recording finished. %d frames saved." % frame_counter)
			
			await get_tree().create_timer(0.1).timeout
			
			file_dialog_mode = "save_animation"
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.filters = PackedStringArray(["*.mp4 ; MP4 Video"])
			
			var dt = Time.get_datetime_dict_from_system()
			var timestamp = "%04d-%02d-%02d_%02d-%02d-%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
			file_dialog.current_file = "animation_" + timestamp + ".mp4"
			file_dialog.popup_centered()

func _on_record_timer_timeout():
	# This function only runs on desktop
	if not is_recording:
		return

	var final_image: Image = null
	var final_path: String = recording_dir.path_join("frame_%05d.png" % frame_counter)

	if is_3d_view:
		# --- 3D RECORDING LOGIC ---
		var viewport_3d = display_container_3d.get_child(0) as SubViewport
		if not is_instance_valid(viewport_3d):
			printerr("ERROR (Record): Could not find 3D viewport.")
			return

		await RenderingServer.frame_post_draw

		var texture_3d = viewport_3d.get_texture()
		if not is_instance_valid(texture_3d):
			return
		var image_3d = texture_3d.get_image()
		if not is_instance_valid(image_3d) or image_3d.is_empty():
			return
		image_3d = image_3d.duplicate()

		if show_2d_background:
			# --- COMPOSITING LOGIC ---
			var texture_2d = final_output.get_texture()
			if not is_instance_valid(texture_2d):
				return
			var image_2d = texture_2d.get_image()
			if not is_instance_valid(image_2d) or image_2d.is_empty():
				return
			image_2d = image_2d.duplicate()

			var temp_tex_2d = ImageTexture.create_from_image(image_2d)
			var temp_tex_3d = ImageTexture.create_from_image(image_3d)

			if not is_instance_valid(temp_tex_2d) or not is_instance_valid(temp_tex_3d):
				return

			var composite_viewport = post_process_save_viewport
			var composite_rect = composite_viewport.get_node("ShaderRect")
			var composite_material = composite_rect.material as ShaderMaterial

			var composite_shader = preload("res://Composite3DOver2D.gdshader")
			if composite_material.shader != composite_shader:
				composite_material.shader = composite_shader

			var screen_size = image_2d.get_size() 
			if screen_size.x <= 0 or screen_size.y <= 0:
				return

			composite_viewport.size = screen_size
			composite_rect.texture = temp_tex_2d
			composite_material.set_shader_parameter("foreground_texture", temp_tex_3d)
			
			# --- NEW: Pass Grading Options to Composite (The Fix) ---
			composite_material.set_shader_parameter("grade_background", grade_background_active)
			composite_material.set_shader_parameter("brightness", brightness)
			composite_material.set_shader_parameter("contrast", contrast)
			composite_material.set_shader_parameter("saturation", saturation)
			# --------------------------------------------------------

			composite_viewport.set_update_mode(SubViewport.UPDATE_ONCE)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw 
			await RenderingServer.frame_post_draw 

			var composite_texture = composite_viewport.get_texture()
			if is_instance_valid(composite_texture):
				final_image = composite_texture.get_image()
			
			composite_viewport.size = Vector2i(1, 1)

		else: # 3D view, no background
			final_image = image_3d

	else:
		# --- 2D RECORDING LOGIC ---
		var source_viewport = viewport_a if is_a_source else viewport_b
		var raw_fractal_texture = source_viewport.get_texture()
		
		if not is_instance_valid(raw_fractal_texture):
			return
		
		post_process_save_viewport.size = source_viewport.size
		var post_save_material = post_process_save_viewport.get_node("ShaderRect").material as ShaderMaterial
		var post_save_rect = post_process_save_viewport.get_node("ShaderRect")

		var post_shader = preload("res://post_process.gdshader")
		if post_save_material.shader != post_shader:
			post_save_material.shader = post_shader

		post_save_rect.texture = raw_fractal_texture

		post_save_material.set_shader_parameter("brightness", brightness)
		post_save_material.set_shader_parameter("contrast", contrast)
		post_save_material.set_shader_parameter("saturation", saturation)
		post_save_material.set_shader_parameter("mirror_x", mirror_x)
		post_save_material.set_shader_parameter("mirror_y", mirror_y)
		post_save_material.set_shader_parameter("kaleidoscope_on", kaleidoscope_on)
		post_save_material.set_shader_parameter("kaleidoscope_slices", kaleidoscope_slices)
		
		await RenderingServer.frame_post_draw

		final_image = post_process_save_viewport.get_texture().get_image()

	# --- SAVE ---
	if not is_instance_valid(final_image) or final_image.is_empty():
		return

	var err = final_image.save_png(final_path)
	if err != OK:
		print("Error saving PNG frame: ", err)
	
	frame_counter += 1
	# --- NEW: Manual Time Step ---
	# We force the time forward by exactly 1/60th of a second.
	# This ensures the video plays at normal speed, even if your PC lags while saving.
	if not animation_paused:
		time += 0.016666 # (1.0 / 60.0)

func _stitch_frames_to_video(save_path: String):
	var global_rec_dir = ProjectSettings.globalize_path(recording_dir)
	var input_path = global_rec_dir.path_join("frame_%05d.png")
	
	# 1. Determine the correct command/path for FFmpeg
	var ffmpeg_cmd = "ffmpeg" # Default for Windows/Linux
	
	if OS.get_name() == "macOS":
		# Check common Mac locations (Homebrew installs)
		if FileAccess.file_exists("/opt/homebrew/bin/ffmpeg"):
			ffmpeg_cmd = "/opt/homebrew/bin/ffmpeg" # Apple Silicon
		elif FileAccess.file_exists("/usr/local/bin/ffmpeg"):
			ffmpeg_cmd = "/usr/local/bin/ffmpeg"    # Intel Mac
		# Else fallback to just "ffmpeg" and hope for the best
	
	# 2. Prepare Arguments
	var ffmpeg_args = [
		"-y", 
		"-framerate", "60", 
		"-i", input_path,   
		"-c:v", "libx264",  
		"-pix_fmt", "yuv420p", 
		save_path  
	]
	
	# 3. Execute
	var output = []
	print("Running FFmpeg... Command: ", ffmpeg_cmd)
	var exit_code = OS.execute(ffmpeg_cmd, ffmpeg_args, output, true)
	
	if exit_code == 0:
		print("Video saved successfully to: ", save_path)
		OS.shell_open(save_path)
	else:
		printerr("--- FFMPEG FAILED ---")
		printerr("Exit Code: ", exit_code)
		printerr("Output: ", output)
		
		# 4. Mac-Specific Error Message
		if OS.get_name() == "macOS":
			OS.alert("Video creation failed. \n\nMac Users: Please ensure FFmpeg is installed via Homebrew ('brew install ffmpeg'). \n\nIf it is installed, your Mac's security settings might be blocking it. Try running 'ffmpeg' once in your Terminal to approve it.", "Export Error")
		else:
			OS.alert("FFmpeg failed to stitch video. Please check if FFmpeg is installed correctly.", "Export Error")
			
		OS.shell_open(global_rec_dir) # Open the PNG folder so they at least have the frames

func _on_pause_animation_check_toggled(button_pressed: bool):
	animation_paused = button_pressed

func save_user_prefs():
	var config = ConfigFile.new()
	config.set_value("randomizer", "on_startup", randomize_startup_check.button_pressed)
	config.set_value("randomizer", "include_speed", randomize_speed_check.button_pressed)
	config.set_value("randomizer", "include_colors", randomize_colors_check.button_pressed)
	config.set_value("randomizer", "include_variations", randomize_variations_check.button_pressed)
	# --- NEW ---
	config.set_value("randomizer", "include_params", randomize_params_check.button_pressed)
	
	config.save(PREFS_PATH)

func load_user_prefs():
	var config = ConfigFile.new()
	var err = config.load(PREFS_PATH)
	
	if err == OK:
		var on_startup = config.get_value("randomizer", "on_startup", false)
		var inc_speed = config.get_value("randomizer", "include_speed", false)
		var inc_colors = config.get_value("randomizer", "include_colors", false)
		var inc_vars = config.get_value("randomizer", "include_variations", true)
		# --- NEW ---
		var inc_params = config.get_value("randomizer", "include_params", true) # Default True
		
		randomize_startup_check.set_pressed_no_signal(on_startup)
		randomize_speed_check.set_pressed_no_signal(inc_speed)
		randomize_colors_check.set_pressed_no_signal(inc_colors)
		randomize_variations_check.set_pressed_no_signal(inc_vars)
		# --- NEW ---
		randomize_params_check.set_pressed_no_signal(inc_params)
		
		return on_startup
	return false
