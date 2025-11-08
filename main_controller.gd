extends Control
const PROGRAM_VERSION = 1.4

# --- Private Variables ---


# --- Node References ---
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

# Symmetry Control Containers
@onready var var_a_mirror_controls: VBoxContainer = %VarAMirrorControlsContainer
@onready var var_a_kaleidoscope_controls: VBoxContainer = %VarAKaleidoscopeControlsContainer
@onready var var_b_mirror_controls: VBoxContainer = %VarBMirrorControlsContainer
@onready var var_b_kaleidoscope_controls: VBoxContainer = %VarBKaleidoscopeControlsContainer
@onready var post_mirror_controls: VBoxContainer = %PostMirrorControlsContainer
@onready var post_kaleidoscope_controls: VBoxContainer = %PostKaleidoscopeControlsContainer
@onready var post_mirror_options: HBoxContainer = %PostMirrorOptions
@onready var post_kaleidoscope_options: HBoxContainer = %PostKaleidoscopeOptions
@onready var var_a_mirror_x_check: CheckBox = %VarAMirrorXCheck
@onready var var_a_mirror_y_check: CheckBox = %VarAMirrorYCheck
@onready var var_a_kaleidoscope_slider: HSlider = %VarAKaleidoscopeSlicesSlider
@onready var var_a_kaleidoscope_spinbox: SpinBox = %VarAKaleidoscopeSlicesSpinBox
@onready var var_b_mirror_x_check: CheckBox = %VarBMirrorXCheck
@onready var var_b_mirror_y_check: CheckBox = %VarBMirrorYCheck
@onready var var_b_kaleidoscope_slider: HSlider = %VarBKaleidoscopeSlicesSlider
@onready var var_b_kaleidoscope_spinbox: SpinBox = %VarBKaleidoscopeSlicesSpinBox 
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
@onready var wave_type_dropdown_a: OptionButton = %WaveTypeDropdownA
@onready var wave_frequency_slider_a: HSlider = %WaveFrequencySliderA
@onready var wave_frequency_spinbox_a: SpinBox = %WaveFrequencySpinBoxA
@onready var wave_amplitude_slider_a: HSlider = %WaveAmplitudeSliderA
@onready var wave_amplitude_spinbox_a: SpinBox = %WaveAmplitudeSpinBoxA
@onready var wave_speed_slider_a: HSlider = %WaveSpeedSliderA
@onready var wave_speed_spinbox_a: SpinBox = %WaveSpeedSpinBoxA
@onready var wave_type_dropdown_b: OptionButton = %WaveTypeDropdownB
@onready var wave_frequency_slider_b: HSlider = %WaveFrequencySliderB
@onready var wave_frequency_spinbox_b: SpinBox = %WaveFrequencySpinBoxB
@onready var wave_amplitude_slider_b: HSlider = %WaveAmplitudeSliderB
@onready var wave_amplitude_spinbox_b: SpinBox = %WaveAmplitudeSpinBoxB
@onready var wave_speed_slider_b: HSlider = %WaveSpeedSliderB
@onready var wave_speed_spinbox_b: SpinBox = %WaveSpeedSpinBoxB
@onready var julian_power_slider_a: HSlider = %JulianPowerSliderA
@onready var julian_power_spinbox_a: SpinBox = %JulianPowerSpinBoxA
@onready var julian_dist_slider_a: HSlider = %JulianDistSliderA
@onready var julian_dist_spinbox_a: SpinBox = %JulianDistSpinBoxA
@onready var julian_a_slider_a: HSlider = %JulianASliderA
@onready var julian_a_spinbox_a: SpinBox = %JulianASpinBoxA
@onready var julian_b_slider_a: HSlider = %JulianBSliderA
@onready var julian_b_spinbox_a: SpinBox = %JulianBSpinBoxA
@onready var julian_c_slider_a: HSlider = %JulianCSliderA
@onready var julian_c_spinbox_a: SpinBox = %JulianCSpinBoxA
@onready var julian_d_slider_a: HSlider = %JulianDSliderA
@onready var julian_d_spinbox_a: SpinBox = %JulianDSpinBoxA
@onready var julian_e_slider_a: HSlider = %JulianESliderA
@onready var julian_e_spinbox_a: SpinBox = %JulianESpinBoxA
@onready var julian_f_slider_a: HSlider = %JulianFSliderA
@onready var julian_f_spinbox_a: SpinBox = %JulianFSpinBoxA
@onready var julian_power_slider_b: HSlider = %JulianPowerSliderB
@onready var julian_power_spinbox_b: SpinBox = %JulianPowerSpinBoxB
@onready var julian_dist_slider_b: HSlider = %JulianDistSliderB
@onready var julian_dist_spinbox_b: SpinBox = %JulianDistSpinBoxB
@onready var julian_a_slider_b: HSlider = %JulianASliderB
@onready var julian_a_spinbox_b: SpinBox = %JulianASpinBoxB
@onready var julian_b_slider_b: HSlider = %JulianBSliderB
@onready var julian_b_spinbox_b: SpinBox = %JulianBSpinBoxB
@onready var julian_c_slider_b: HSlider = %JulianCSliderB
@onready var julian_c_spinbox_b: SpinBox = %JulianCSpinBoxB
@onready var julian_d_slider_b: HSlider = %JulianDSliderB
@onready var julian_d_spinbox_b: SpinBox = %JulianDSpinBoxB
@onready var julian_e_slider_b: HSlider = %JulianESliderB
@onready var julian_e_spinbox_b: SpinBox = %JulianESpinBoxB
@onready var julian_f_slider_b: HSlider = %JulianFSliderB
@onready var julian_f_spinbox_b: SpinBox = %JulianFSpinBoxB
@onready var fisheye_strength_slider_a: HSlider = %FisheyeStrengthSliderA
@onready var fisheye_strength_spinbox_a: SpinBox = %FisheyeStrengthSpinBoxA
@onready var polar_offset_slider_a: HSlider = %PolarOffsetSliderA
@onready var polar_offset_spinbox_a: SpinBox = %PolarOffsetSpinBoxA
@onready var fisheye_strength_slider_b: HSlider = %FisheyeStrengthSliderB
@onready var fisheye_strength_spinbox_b: SpinBox = %FisheyeStrengthSpinBoxB
@onready var polar_offset_slider_b: HSlider = %PolarOffsetSliderB
@onready var polar_offset_spinbox_b: SpinBox = %PolarOffsetSpinBoxB
@onready var mobius_re_a_spinbox_a: SpinBox = %MobiusReASpinBoxA
@onready var mobius_im_a_spinbox_a: SpinBox = %MobiusImASpinBoxA
@onready var mobius_re_b_spinbox_a: SpinBox = %MobiusReBSpinBoxA
@onready var mobius_im_b_spinbox_a: SpinBox = %MobiusImBSpinBoxA
@onready var mobius_re_c_spinbox_a: SpinBox = %MobiusReCSpinBoxA
@onready var mobius_im_c_spinbox_a: SpinBox = %MobiusImCSpinBoxA
@onready var mobius_re_d_spinbox_a: SpinBox = %MobiusReDSpinBoxA
@onready var mobius_im_d_spinbox_a: SpinBox = %MobiusImDSpinBoxA
@onready var mobius_re_a_spinbox_b: SpinBox = %MobiusReASpinBoxB
@onready var mobius_im_a_spinbox_b: SpinBox = %MobiusImASpinBoxB
@onready var mobius_re_b_spinbox_b: SpinBox = %MobiusReBSpinBoxB
@onready var mobius_im_b_spinbox_b: SpinBox = %MobiusImBSpinBoxB
@onready var mobius_re_c_spinbox_b: SpinBox = %MobiusReCSpinBoxB
@onready var mobius_im_c_spinbox_b: SpinBox = %MobiusImCSpinBoxB
@onready var mobius_re_d_spinbox_b: SpinBox = %MobiusReDSpinBoxB
@onready var mobius_im_d_spinbox_b: SpinBox = %MobiusImDSpinBoxB


@onready var apollonian_scale_slider_a: HSlider = %ApollonianScaleSliderA
@onready var apollonian_scale_spinbox_a: SpinBox = %ApollonianScaleSpinBoxA
@onready var ap_c1x_spinbox_a: SpinBox = %ApC1XSpinBoxA
@onready var ap_c1y_spinbox_a: SpinBox = %ApC1YSpinBoxA
@onready var ap_c2x_spinbox_a: SpinBox = %ApC2XSpinBoxA
@onready var ap_c2y_spinbox_a: SpinBox = %ApC2YSpinBoxA
@onready var ap_c3x_spinbox_a: SpinBox = %ApC3XSpinBoxA
@onready var ap_c3y_spinbox_a: SpinBox = %ApC3YSpinBoxA
@onready var apollonian_scale_slider_b: HSlider = %ApollonianScaleSliderB
@onready var apollonian_scale_spinbox_b: SpinBox = %ApollonianScaleSpinBoxB
@onready var ap_c1x_spinbox_b: SpinBox = %ApC1XSpinBoxB
@onready var ap_c1y_spinbox_b: SpinBox = %ApC1YSpinBoxB
@onready var ap_c2x_spinbox_b: SpinBox = %ApC2XSpinBoxB
@onready var ap_c2y_spinbox_b: SpinBox = %ApC2YSpinBoxB
@onready var ap_c3x_spinbox_b: SpinBox = %ApC3XSpinBoxB
@onready var ap_c3y_spinbox_b: SpinBox = %ApC3YSpinBoxB

@onready var cellular_weave_grid_size_slider_a: HSlider = %CellularWeaveGridSizeSliderA
@onready var cellular_weave_grid_size_spinbox_a: SpinBox = %CellularWeaveGridSizeSpinBoxA

@onready var cellular_weave_threshold_slider_a: HSlider = %CellularWeaveThresholdSliderA
@onready var cellular_weave_threshold_spinbox_a: SpinBox = %CellularWeaveThresholdSpinBoxA
@onready var cellular_weave_iterations_slider_a: HSlider = %CellularWeaveIterationsSliderA
@onready var cellular_weave_iterations_spinbox_a: SpinBox = %CellularWeaveIterationsSpinBoxA
@onready var cellular_weave_grid_size_slider_b: HSlider = %CellularWeaveGridSizeSliderB
@onready var cellular_weave_grid_size_spinbox_b: SpinBox = %CellularWeaveGridSizeSpinBoxB
@onready var cellular_weave_threshold_slider_b: HSlider = %CellularWeaveThresholdSliderB
@onready var cellular_weave_threshold_spinbox_b: SpinBox = %CellularWeaveThresholdSpinBoxB
@onready var cellular_weave_iterations_slider_b: HSlider = %CellularWeaveIterationsSliderB
@onready var cellular_weave_iterations_spinbox_b: SpinBox = %CellularWeaveIterationsSpinBoxB

@onready var blur_amount_slider_a: HSlider = %BlurAmountSliderA
@onready var blur_amount_spinbox_a: SpinBox = %BlurAmountSpinBoxA 
@onready var blur_amount_slider_b: HSlider = %BlurAmountSliderB
@onready var blur_amount_spinbox_b: SpinBox = %BlurAmountSpinBoxB 
@onready var heart_scale_slider_a: HSlider = %HeartScaleSliderA
@onready var heart_scale_spinbox_a: SpinBox = %HeartScaleSpinBoxA
@onready var heart_rotation_slider_a: HSlider = %HeartRotationSliderA
@onready var heart_rotation_spinbox_a: SpinBox = %HeartRotationSpinBoxA
@onready var heart_strength_slider_a: HSlider = %HeartStrengthSliderA
@onready var heart_strength_spinbox_a: SpinBox = %HeartStrengthSpinBoxA
@onready var heart_scale_slider_b: HSlider = %HeartScaleSliderB
@onready var heart_scale_spinbox_b: SpinBox = %HeartScaleSpinBoxB
@onready var heart_rotation_slider_b: HSlider = %HeartRotationSliderB
@onready var heart_rotation_spinbox_b: SpinBox = %HeartRotationSpinBoxB
@onready var heart_strength_slider_b: HSlider = %HeartStrengthSliderB
@onready var heart_strength_spinbox_b: SpinBox = %HeartStrengthSpinBoxB
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
@onready var normal_strength_spinbox: SpinBox = %NormalStrengthSpinBox
@onready var light_x_angle_spinbox: SpinBox = %LightXAngleSpinBox
@onready var light_y_angle_spinbox: SpinBox = %LightYAngleSpinBox
@onready var light_energy_spinbox: SpinBox = %LightEnergySpinBox
@onready var camera_dist_spinbox: SpinBox = %CameraDistSpinBox
@onready var camera_x_rot_spinbox: SpinBox = %CameraXRotSpinBox
@onready var camera_y_rot_spinbox: SpinBox = %CameraYRotSpinBox
@onready var camera_fov_spinbox: SpinBox = %CameraFovSpinBox


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
var mirror_x: bool = false
var mirror_y: bool = false
var kaleidoscope_on: bool = false
var kaleidoscope_slices: float = 6.0
var var_a_mirror_x: bool = false
var var_a_mirror_y: bool = false
var var_a_kaleidoscope_slices: float = 6.0
var var_b_mirror_x: bool = false
var var_b_mirror_y: bool = false
var var_b_kaleidoscope_slices: float = 6.0
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

var fisheye_strength_a: float
var polar_offset_a: float
var fisheye_strength_b: float
var polar_offset_b: float

var wave_frequency_a: float
var wave_amplitude_a: float
var wave_speed_a: float
var wave_frequency_b: float
var wave_amplitude_b: float
var wave_speed_b: float
var wave_type_a: int
var wave_type_b: int

# Julian2 A Controls
var julian_power_a: float
var julian_dist_a: float 
var julian_a_a: float
var julian_b_a: float
var julian_c_a: float
var julian_d_a: float
var julian_e_a: float
var julian_f_a: float

# Julian2 B Controls
var julian_power_b: float
var julian_dist_b: float
var julian_a_b: float
var julian_b_b: float
var julian_c_b: float
var julian_d_b: float
var julian_e_b: float
var julian_f_b: float

var translate_a: Vector2
var translate_b: Vector2
var pre_scale: float
var pre_rotation: float
var pre_translate: Vector2
var post_scale: float
var post_rotation: float
var post_translate: Vector2

# ---Mobius---
var mobius_re_a_a ;  var mobius_im_a_a;
var mobius_re_b_a ;  var mobius_im_b_a;
var mobius_re_c_a ; var mobius_im_c_a;
var mobius_re_d_a ; var mobius_im_d_a;
var mobius_re_a_b ;  var mobius_im_a_b;
var mobius_re_b_b ;  var mobius_im_b_b;
var mobius_re_c_b ; var mobius_im_c_b;
var mobius_re_d_b ; var mobius_im_d_b;

# --- Add variables for Cellular Weave parameters ---
var cellular_weave_grid_size_a: float
var cellular_weave_threshold_a: float
var cellular_weave_iterations_a: float
var cellular_weave_grid_size_b: float
var cellular_weave_threshold_b: float
var cellular_weave_iterations_b: float

var blur_amount_a: float
var blur_amount_b: float

# --- Add variables for Heart parameters ---
var heart_scale_a: float
var heart_rotation_a: float
var heart_strength_a: float
var heart_scale_b: float
var heart_rotation_b: float
var heart_strength_b: float

var apollonian_scale_a: float
var ap_c1_a  := Vector2()
var ap_c2_a := Vector2()
var ap_c3_a := Vector2()
var apollonian_scale_b: float
var ap_c1_b := Vector2()
var ap_c2_b := Vector2()
var ap_c3_b := Vector2()

# Custom 2x2 Tile Vars
var custom_tl_a_id: int
var custom_tr_a_id: int
var custom_bl_a_id: int
var custom_br_a_id: int
var custom_tl_b_id: int
var custom_tr_b_id: int
var custom_bl_b_id: int
var custom_br_b_id: int

# --- 3D Light Controls ---
var light_x_rotation: float   # Default from your screenshot
var light_y_rotation: float  # Default from your screenshot
var light_energy: float 
var light_color: Color 
var light_shadows: bool

var normal_map_strength: float


# --- 3D Camera Controls ---
var camera_distance: float = 0.5 # How far the camera is from the center
var camera_x_rotation: float = 0.0 # Rotation around the horizontal axis (pitch)
var camera_y_rotation: float = 0.0 # Rotation around the vertical axis (yaw)
var camera_fov: float = 75.0 # Field of View

# --- 3D Background Control ---
var show_2d_background: bool = false

# --- Private Variables ---
var time: float = 0.0
var is_a_source = true

var post_process_material: ShaderMaterial
var _preset_json_to_save: String

var version_label: Label

func _set_platform_feedback_defaults() -> void:
	# This function is no longer needed.
	# We get the defaults from the resource file.
	pass

func _update_camera() -> void:
	if is_instance_valid(camera_3d):
		# Reset rotation first to avoid gimbal lock issues
		camera_3d.rotation = Vector3.ZERO
		
		# Apply Y rotation (yaw)
		camera_3d.rotate_y(deg_to_rad(camera_y_rotation))
		
		# Apply X rotation (pitch) - rotate around the camera's local X-axis
		camera_3d.rotate_object_local(Vector3.RIGHT, deg_to_rad(camera_x_rotation))
		
		# Move the camera backwards along its local Z-axis
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
	
	_set_platform_feedback_defaults()
	
	var window_size = get_viewport().get_visible_rect().size
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
	
	var viewport_3d = display_container_3d.get_child(0) as SubViewport
	if is_instance_valid(viewport_3d):
		viewport_3d.size = window_size

	var feedback_material = ShaderMaterial.new()
	feedback_material.shader = load("res://fractal_feedback.gdshader")
	%ViewportA.get_node("ShaderRect").material = feedback_material
	%ViewportB.get_node("ShaderRect").material = feedback_material.duplicate()
	%SaveViewport.get_node("ShaderRect").material = feedback_material.duplicate()
	post_process_material = ShaderMaterial.new()
	post_process_material.shader = load("res://post_process.gdshader")
	final_output.material = post_process_material
	
	var_a_panels = {
		"apollonian": apollonian_controls_container_a,
		"blur": blur_controls_container_a,
		"cellular_weave": cellular_weave_controls_container_a,
		"fisheye": fisheye_controls_container_a,
		"heart": heart_controls_container_a,
		"julian": julian_controls_container_a,
		"kaleidoscope": var_a_kaleidoscope_controls, # Use the correct node
		"mirror": var_a_mirror_controls,         # Use the correct node
		"mobius": mobius_controls_container_a,
		"polar": polar_controls_container_a,
		"wave": wave_controls_container_a,
		"rep_tile": rep_tile_panel_a # Special key for the Rep-Tile panel
	}
	
	var_b_panels = {
		"apollonian": apollonian_controls_container_b,
		"blur": blur_controls_container_b,
		"cellular_weave": cellular_weave_controls_container_b,
		"fisheye": fisheye_controls_container_b,
		"heart": heart_controls_container_b,
		"julian": julian_controls_container_b,
		"kaleidoscope": var_b_kaleidoscope_controls, # Use the correct node
		"mirror": var_b_mirror_controls,         # Use the correct node
		"mobius": mobius_controls_container_b,
		"polar": polar_controls_container_b,
		"wave": wave_controls_container_b,
		"rep_tile": rep_tile_panel_b # Special key for the Rep-Tile panel
	}
	
	
	# --- ADD THIS 3D MESH SETUP ---
	var mesh_material = StandardMaterial3D.new()
	mesh_material.normal_enabled = true
	mesh_material.normal_scale = 1.0
	
	# --- START OF THE FIX ---
	if window_size.x > 0 and window_size.y > 0: 
		var initial_normal_img = Image.create(int(window_size.x), int(window_size.y), false, Image.FORMAT_RGBA8)
		if is_instance_valid(initial_normal_img):
			normal_map_texture = ImageTexture.create_from_image(initial_normal_img)
		else:
			printerr("ERROR: Failed to create initial_normal_img!")

		if is_instance_valid(mesh_material):
			var current_fractal_texture = final_output.get_texture()
			mesh_material.albedo_texture = current_fractal_texture
			if is_instance_valid(normal_map_material) and is_instance_valid(current_fractal_texture):
				normal_map_material.set_shader_parameter("height_map", current_fractal_texture)
				normal_map_material.set_shader_parameter("strength", normal_map_strength)
				print("Setting normal strength: ", normal_map_strength)
			
			mesh_material.normal_texture = normal_map_viewport.get_texture()
		else:
			printerr("ERROR: mesh_material is NOT valid in _ready()!")
	else:
		printerr("ERROR: window_size is invalid for creating initial normal map image!")

	if is_instance_valid(fractal_mesh):
		fractal_mesh.set_surface_override_material(0, mesh_material)
	else:
		print("ERROR: FractalMesh node not found! Check the path.")
	# --- END ADJUSTED 3D MESH SETUP ---
	
	#update_ui_from_state()
	file_dialog.file_selected.connect(_on_file_dialog_file_selected)
		
	if OS.has_feature("web"):
		print("Control: Web build detected, disabling clipboard buttons.")
		# ... (your web button code remains unchanged) ...
	else:
		print("Control: Not web build, clipboard buttons enabled.")
		# ... (your web notice label code remains unchanged) ...

	var post_save_material = ShaderMaterial.new()
	post_save_material.shader = load("res://post_process.gdshader")
	post_process_save_viewport.get_node("ShaderRect").material = post_save_material

	_update_view_visibility()
	
	print("Control: _ready function running.")
	if not OS.has_feature("web"):
		print("Control: Not running on web.")

	print("Control: _ready function finished.")
	resized.connect(_on_main_control_resized)
	_update_light() # Set initial light properties
	_update_camera() # Set initial camera properties
	_update_background() # Set initial background

	# --- ADD THESE 2 LINES AT THE VERY END ---
	# This sets the initial panel visibility based on default IDs
	_update_var_a_visibility(_get_control_string_from_id(variation_mode_a))
	_update_var_b_visibility(_get_control_string_from_id(variation_mode_b))
	
	_update_start_pattern_visibility()
	reset_visuals()

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
		var image_2d = texture_2d.get_image()
		if not is_instance_valid(image_2d) or image_2d.is_empty():
			printerr("ERROR: Failed to get valid Image from 2D background.")
			return
		image_2d = image_2d.duplicate() # Ensure stable copy

		# --- Create temporary textures from the image copies ---
		var temp_tex_2d = ImageTexture.create_from_image(image_2d)
		var temp_tex_3d = ImageTexture.create_from_image(image_3d)

		if not is_instance_valid(temp_tex_2d) or not is_instance_valid(temp_tex_3d):
			printerr("ERROR: Failed to create temporary ImageTextures for compositing.")
			return

		# --- Setup Composite Viewport ---
		var composite_viewport = post_process_save_viewport
		var composite_rect = composite_viewport.get_node("ShaderRect")
		var composite_material = composite_rect.material as ShaderMaterial

		if not is_instance_valid(composite_rect) or not is_instance_valid(composite_material):
			printerr("ERROR: Composite viewport nodes/material not valid.")
			return
			
		# Ensure the correct shader is assigned (might have been changed by 2D save)
		var composite_shader = preload("res://Composite3DOver2D.gdshader")
		if composite_material.shader != composite_shader:
			print("Re-assigning composite shader.")
			composite_material.shader = composite_shader

		var screen_size = image_2d.get_size() # Use image size
		if screen_size.x <= 0 or screen_size.y <= 0:
			printerr("ERROR: Invalid image size for compositing: ", screen_size)
			return

		# --- Configure, Force Render Once, and Wait ---
		composite_viewport.size = screen_size
		composite_rect.texture = temp_tex_2d
		composite_material.set_shader_parameter("foreground_texture", temp_tex_3d)
		
		# Set to update once, then wait for the *next* frame's draw cycle to complete
		composite_viewport.set_update_mode(SubViewport.UPDATE_ONCE) 
		await get_tree().process_frame       # Wait for next physics/process frame
		await RenderingServer.frame_post_draw # Wait for draw commands to be submitted
		await RenderingServer.frame_post_draw # Wait for drawing to actually finish

		# --- Get Result ---
		var composite_texture = composite_viewport.get_texture()
		if is_instance_valid(composite_texture):
			final_image = composite_texture.get_image()
			if not is_instance_valid(final_image) or final_image.is_empty():
				printerr("ERROR: Failed to get valid image from composite texture after waiting.")
				final_image = null 
		else:
			printerr("ERROR: Failed to get composite texture from viewport after waiting.")

		# --- Cleanup ---
		composite_viewport.size = Vector2i(1, 1) # Reset size
		# No need to change update mode back unless you use UPDATE_ONCE elsewhere

	else: # Not showing 2D background
		final_image = image_3d # Use the duplicated image

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
	print("Starting 3D desktop save...")
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
		var image_2d = texture_2d.get_image()
		if not is_instance_valid(image_2d) or image_2d.is_empty():
			printerr("ERROR: Failed to get valid Image from 2D background.")
			return
		image_2d = image_2d.duplicate() # Ensure stable copy

		# --- Create temporary textures from the image copies ---
		var temp_tex_2d = ImageTexture.create_from_image(image_2d)
		var temp_tex_3d = ImageTexture.create_from_image(image_3d)

		if not is_instance_valid(temp_tex_2d) or not is_instance_valid(temp_tex_3d):
			printerr("ERROR: Failed to create temporary ImageTextures for compositing.")
			return

		# --- Setup Composite Viewport ---
		var composite_viewport = post_process_save_viewport
		var composite_rect = composite_viewport.get_node("ShaderRect")
		var composite_material = composite_rect.material as ShaderMaterial

		if not is_instance_valid(composite_rect) or not is_instance_valid(composite_material):
			printerr("ERROR: Composite viewport nodes/material not valid.")
			return

		# Ensure the correct shader is assigned (might have been changed by 2D save)
		var composite_shader = preload("res://Composite3DOver2D.gdshader")
		if composite_material.shader != composite_shader:
			print("Re-assigning composite shader.")
			composite_material.shader = composite_shader

		var screen_size = image_2d.get_size() # Use image size
		if screen_size.x <= 0 or screen_size.y <= 0:
			printerr("ERROR: Invalid image size for compositing: ", screen_size)
			return

		# --- Configure, Force Render Once, and Wait ---
		composite_viewport.size = screen_size
		composite_rect.texture = temp_tex_2d
		composite_material.set_shader_parameter("foreground_texture", temp_tex_3d)

		# Set to update once, then wait for the *next* frame's draw cycle to complete
		composite_viewport.set_update_mode(SubViewport.UPDATE_ONCE)
		await get_tree().process_frame       # Wait for next physics/process frame
		await RenderingServer.frame_post_draw # Wait for draw commands to be submitted
		await RenderingServer.frame_post_draw # Wait for drawing to actually finish

		# --- Get Result ---
		var composite_texture = composite_viewport.get_texture()
		if is_instance_valid(composite_texture):
			final_image = composite_texture.get_image()
			if not is_instance_valid(final_image) or final_image.is_empty():
				printerr("ERROR: Failed to get valid image from composite texture after waiting.")
				final_image = null
		else:
			printerr("ERROR: Failed to get composite texture from viewport after waiting.")

		# --- Cleanup ---
		composite_viewport.size = Vector2i(1, 1) # Reset size

	else: # Not showing 2D background
		final_image = image_3d # Use the duplicated image

	# --- Actual Saving ---
	if not is_instance_valid(final_image) or final_image.is_empty():
		printerr("ERROR: Could not get final, valid image for saving.")
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
	if is_instance_valid(viewport_3d):
		viewport_3d.size = new_size
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
		printerr("ERROR: FractalMesh is not valid, cannot change shape.")
		return

	var new_mesh: Mesh = null

	match shape_index:
		0: # Sphere
			new_mesh = SphereMesh.new()
			# You might want to set radius, height, radial_segments etc. here
			# e.g., (new_mesh as SphereMesh).radius = 0.5
		1: # Cube
			new_mesh = BoxMesh.new()
			# You might want to set size here
			# e.g., (new_mesh as BoxMesh).size = Vector3(1, 1, 1)
		2: # Quad
			new_mesh = QuadMesh.new()
			# You might want to set size here
			# e.g., (new_mesh as QuadMesh).size = Vector2(1, 1)
		3: # Prism
			new_mesh = PrismMesh.new()
			# You might want to set size here
			# e.g., (new_mesh as PrismMesh).size = Vector3(1, 1, 1)
		4: # Torus
			new_mesh = TorusMesh.new()
			# You might want to set inner_radius, outer_radius, rings, ring_segments
			# e.g., (new_mesh as TorusMesh).outer_radius = 0.5

	if new_mesh:
		fractal_mesh.mesh = new_mesh
		print("Changed mesh shape to index: ", shape_index)
	else:
		printerr("ERROR: Invalid shape index received: ", shape_index)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_visuals"):
		self.reset_visuals.call()
	if event.is_action_pressed.call("reseed_pattern"):
		self.reseed_pattern.call()
	if event.is_action_pressed("toggle_ui"):
		self.toggle_ui.call()
func _on_viewport_gui_input(event: InputEvent) -> void:
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
				var delta = 0.005 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.005
				if event.ctrl_pressed:
					if event.shift_pressed: pre_rotation += delta * 5.0
					else: pre_scale = max(0.1, pre_scale + delta) # Prevent scale becoming zero or negative
				else:
					if event.shift_pressed: post_rotation += delta * 5.0
					else: post_scale = max(0.1, post_scale + delta) # Prevent scale becoming zero or negative


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


func reset_visuals() -> void:
	if default_settings == null:
		printerr("ERROR: Default Settings resource not assigned in Inspector!")
		return

	# --- Copy all values from the resource ---
	variation_mode_a = default_settings.variation_mode_a
	variation_mode_b = default_settings.variation_mode_b
	start_pattern_mode = default_settings.start_pattern_mode
	variation_mix = default_settings.variation_mix
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
	var_a_mirror_x = default_settings.var_a_mirror_x
	var_a_mirror_y = default_settings.var_a_mirror_y
	var_a_kaleidoscope_slices = default_settings.var_a_kaleidoscope_slices
	wave_type_a = default_settings.wave_type_a
	wave_frequency_a = default_settings.wave_frequency_a
	wave_amplitude_a = default_settings.wave_amplitude_a
	wave_speed_a = default_settings.wave_speed_a
	julian_power_a = default_settings.julian_power_a
	julian_dist_a = default_settings.julian_dist_a
	julian_a_a = default_settings.julian_a_a
	julian_b_a = default_settings.julian_b_a
	julian_c_a = default_settings.julian_c_a
	julian_d_a = default_settings.julian_d_a
	julian_e_a = default_settings.julian_e_a
	julian_f_a = default_settings.julian_f_a
	fisheye_strength_a = default_settings.fisheye_strength_a
	polar_offset_a = default_settings.polar_offset_a
	mobius_re_a_a = default_settings.mobius_re_a_a
	mobius_im_a_a = default_settings.mobius_im_a_a
	mobius_re_b_a = default_settings.mobius_re_b_a
	mobius_im_b_a = default_settings.mobius_im_b_a
	mobius_re_c_a = default_settings.mobius_re_c_a
	mobius_im_c_a = default_settings.mobius_im_c_a
	mobius_re_d_a = default_settings.mobius_re_d_a
	mobius_im_d_a = default_settings.mobius_im_d_a
	cellular_weave_grid_size_a = default_settings.cellular_weave_grid_size_a
	cellular_weave_threshold_a = default_settings.cellular_weave_threshold_a
	cellular_weave_iterations_a = default_settings.cellular_weave_iterations_a
	blur_amount_a = default_settings.blur_amount_a
	heart_scale_a = default_settings.heart_scale_a
	heart_rotation_a = default_settings.heart_rotation_a
	heart_strength_a = default_settings.heart_strength_a
	var_b_mirror_x = default_settings.var_b_mirror_x
	var_b_mirror_y = default_settings.var_b_mirror_y
	var_b_kaleidoscope_slices = default_settings.var_b_kaleidoscope_slices
	wave_type_b = default_settings.wave_type_b
	wave_frequency_b = default_settings.wave_frequency_b
	wave_amplitude_b = default_settings.wave_amplitude_b
	wave_speed_b = default_settings.wave_speed_b
	julian_power_b = default_settings.julian_power_b
	julian_dist_b = default_settings.julian_dist_b
	julian_a_b = default_settings.julian_a_b
	julian_b_b = default_settings.julian_b_b
	julian_c_b = default_settings.julian_c_b
	julian_d_b = default_settings.julian_d_b
	julian_e_b = default_settings.julian_e_b
	julian_f_b = default_settings.julian_f_b
	fisheye_strength_b = default_settings.fisheye_strength_b
	polar_offset_b = default_settings.polar_offset_b
	mobius_re_a_b = default_settings.mobius_re_a_b
	mobius_im_a_b = default_settings.mobius_im_a_b
	mobius_re_b_b = default_settings.mobius_re_b_b
	mobius_im_b_b = default_settings.mobius_im_b_b
	mobius_re_c_b = default_settings.mobius_re_c_b
	mobius_im_c_b = default_settings.mobius_im_c_b
	mobius_re_d_b = default_settings.mobius_re_d_b
	mobius_im_d_b = default_settings.mobius_im_d_b
	cellular_weave_grid_size_b = default_settings.cellular_weave_grid_size_b
	cellular_weave_threshold_b = default_settings.cellular_weave_threshold_b
	cellular_weave_iterations_b = default_settings.cellular_weave_iterations_b
	blur_amount_b = default_settings.blur_amount_b
	heart_scale_b = default_settings.heart_scale_b
	heart_rotation_b = default_settings.heart_rotation_b
	heart_strength_b = default_settings.heart_strength_b
	apollonian_scale_a = default_settings.apollonian_scale_a
	ap_c1_a = default_settings.ap_c1_a
	ap_c2_a = default_settings.ap_c2_a
	ap_c3_a = default_settings.ap_c3_a
	apollonian_scale_b = default_settings.apollonian_scale_b
	ap_c1_b = default_settings.ap_c1_b
	ap_c2_b = default_settings.ap_c2_b
	ap_c3_b = default_settings.ap_c3_b
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
	camera_fov = default_settings.camera_fov
	show_2d_background = default_settings.show_2d_background

	# --- Finally, update the UI ---
	time = 0.0
	update_ui_from_state()
	reseed_pattern()

func reseed_pattern() -> void:
	time = 0.0 # Resets the shader time, often used for seeding noise/patterns

func update_ui_from_state() -> void:
	
		var values = {
			"var_a_id": variation_mode_a, # Pass ID
			"var_b_id": variation_mode_b, # Pass ID
			"start_pattern": start_pattern_mode,
			"var_mix": variation_mix, "feedback": feedback_amount, "feedback_min": feedback_min, "feedback_max": feedback_max, "tiling": seamless_tiling,"mirror_tiling": mirror_tiling,
			"reset_on_drag": reset_on_drag_enabled, "show_grid": show_start_grid, "show_circles": show_circles,
			"pre_scale": pre_scale, "pre_rot": pre_rotation, "post_scale": post_scale, "post_rot": post_rotation,
			"brightness": brightness, "contrast": contrast, "saturation": saturation,
			"circle_count": circle_count, "circle_radius": circle_radius, "circle_softness": circle_softness,
			"grad_tl": grad_col_tl, "grad_tr": grad_col_tr, "grad_bl": grad_col_bl, "grad_br": grad_col_br,
			"move_post": move_post_translate, "move_pre": move_pre_translate,
			"move_var_a": move_var_a_translate, "move_var_b": move_var_b_translate,
			"post_mirror_x": mirror_x, "post_mirror_y": mirror_y, "post_kaleidoscope_on": kaleidoscope_on, "post_kaleidoscope_slices": kaleidoscope_slices,
			# Var A specific
			"var_a_mirror_x": var_a_mirror_x, "var_a_mirror_y": var_a_mirror_y, "var_a_kaleidoscope_slices": var_a_kaleidoscope_slices,
			"wave_type_a": wave_type_a, "wave_freq_a": wave_frequency_a, "wave_amp_a": wave_amplitude_a, "wave_speed_a": wave_speed_a,
			"julian_power_a": julian_power_a, "julian_dist_a": julian_dist_a, "julian_a_a": julian_a_a, "julian_b_a": julian_b_a, "julian_c_a": julian_c_a, "julian_d_a": julian_d_a, "julian_e_a": julian_e_a, "julian_f_a": julian_f_a,
			"fisheye_strength_a": fisheye_strength_a, "polar_offset_a": polar_offset_a,
			"mobius_re_a_a": mobius_re_a_a, "mobius_im_a_a": mobius_im_a_a, "mobius_re_b_a": mobius_re_b_a, "mobius_im_b_a": mobius_im_b_a, "mobius_re_c_a": mobius_re_c_a, "mobius_im_c_a": mobius_im_c_a, "mobius_re_d_a": mobius_re_d_a, "mobius_im_d_a": mobius_im_d_a,
			"cellular_weave_grid_size_a": cellular_weave_grid_size_a, "cellular_weave_threshold_a": cellular_weave_threshold_a, "cellular_weave_iterations_a": cellular_weave_iterations_a,
			"blur_amount_a": blur_amount_a,
			"heart_scale_a": heart_scale_a, "heart_rotation_a": heart_rotation_a, "heart_strength_a": heart_strength_a,
			"apollonian_scale_a": apollonian_scale_a,
			"ap_c1_a": ap_c1_a, # <-- ADD
			"ap_c2_a": ap_c2_a, # <-- ADD
			"ap_c3_a": ap_c3_a, # <-- ADD
			"custom_tl_a": custom_tl_a_id,
			"custom_tr_a": custom_tr_a_id,
			"custom_bl_a": custom_bl_a_id,
			"custom_br_a": custom_br_a_id,
			# Var B specific
			"var_b_mirror_x": var_b_mirror_x, "var_b_mirror_y": var_b_mirror_y, "var_b_kaleidoscope_slices": var_b_kaleidoscope_slices,
			"wave_type_b": wave_type_b, "wave_freq_b": wave_frequency_b, "wave_amp_b": wave_amplitude_b, "wave_speed_b": wave_speed_b,
			"julian_power_b": julian_power_b, "julian_dist_b": julian_dist_b, "julian_a_b": julian_a_b, "julian_b_b": julian_b_b, "julian_c_b": julian_c_b, "julian_d_b": julian_d_b, "julian_e_b": julian_e_b, "julian_f_b": julian_f_b,
			"fisheye_strength_b": fisheye_strength_b, "polar_offset_b": polar_offset_b,
			"mobius_re_a_b": mobius_re_a_b, "mobius_im_a_b": mobius_im_a_b, "mobius_re_b_b": mobius_re_b_b, "mobius_im_b_b": mobius_im_b_b, "mobius_re_c_b": mobius_re_c_b, "mobius_im_c_b": mobius_im_c_b, "mobius_re_d_b": mobius_re_d_b, "mobius_im_d_b": mobius_im_d_b,
			"cellular_weave_grid_size_b": cellular_weave_grid_size_b, "cellular_weave_threshold_b": cellular_weave_threshold_b, "cellular_weave_iterations_b": cellular_weave_iterations_b,
			"blur_amount_b": blur_amount_b,
			"heart_scale_b": heart_scale_b, "heart_rotation_b": heart_rotation_b, "heart_strength_b": heart_strength_b,
			"apollonian_scale_b": apollonian_scale_b,
			"ap_c1_b": ap_c1_b, # <-- ADD
			"ap_c2_b": ap_c2_b, # <-- ADD
			"ap_c3_b": ap_c3_b, # <-- ADD
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
			"cam_fov": camera_fov,
			"show_2d_bg": show_2d_background,
			"save_res_index": save_resolution_index
			
		}
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

	# --- Var A Symmetry ---
	var_a_mirror_x_check.set_pressed_no_signal(initial_values.get("var_a_mirror_x", false))
	var_a_mirror_y_check.set_pressed_no_signal(initial_values.get("var_a_mirror_y", false))
	var_a_kaleidoscope_slider.set_value_no_signal(initial_values.get("var_a_kaleidoscope_slices", 6.0))
	var_a_kaleidoscope_spinbox.set_value_no_signal(initial_values.get("var_a_kaleidoscope_slices", 6.0))
	
	# --- Var B Symmetry ---
	var_b_mirror_x_check.set_pressed_no_signal(initial_values.get("var_b_mirror_x", false))
	var_b_mirror_y_check.set_pressed_no_signal(initial_values.get("var_b_mirror_y", false))
	var_b_kaleidoscope_slider.set_value_no_signal(initial_values.get("var_b_kaleidoscope_slices", 6.0))
	var_b_kaleidoscope_spinbox.set_value_no_signal(initial_values.get("var_b_kaleidoscope_slices", 6.0))

	# --- Var A Controls ---
	wave_type_dropdown_a.select(initial_values.get("wave_type_a", 0))
	wave_frequency_slider_a.set_value_no_signal(initial_values.get("wave_freq_a", 0.0))
	wave_frequency_spinbox_a.set_value_no_signal(initial_values.get("wave_freq_a", 0.0))
	wave_amplitude_slider_a.set_value_no_signal(initial_values.get("wave_amp_a", 0.1))
	wave_amplitude_spinbox_a.set_value_no_signal(initial_values.get("wave_amp_a", 0.1))
	wave_speed_slider_a.set_value_no_signal(initial_values.get("wave_speed_a", 0.0))
	wave_speed_spinbox_a.set_value_no_signal(initial_values.get("wave_speed_a", 0.0))

	julian_power_slider_a.set_value_no_signal(initial_values.get("julian_power_a", 2.0))
	julian_power_spinbox_a.set_value_no_signal(initial_values.get("julian_power_a", 2.0))
	julian_dist_slider_a.set_value_no_signal(initial_values.get("julian_dist_a", 1.0))
	julian_dist_spinbox_a.set_value_no_signal(initial_values.get("julian_dist_a", 1.0))
	julian_a_slider_a.set_value_no_signal(initial_values.get("julian_a_a", 1.0))
	julian_a_spinbox_a.set_value_no_signal(initial_values.get("julian_a_a", 1.0))
	julian_b_slider_a.set_value_no_signal(initial_values.get("julian_b_a", 0.0))
	julian_b_spinbox_a.set_value_no_signal(initial_values.get("julian_b_a", 0.0))
	julian_c_slider_a.set_value_no_signal(initial_values.get("julian_c_a", 0.0))
	julian_c_spinbox_a.set_value_no_signal(initial_values.get("julian_c_a", 0.0))
	julian_d_slider_a.set_value_no_signal(initial_values.get("julian_d_a", 1.0))
	julian_d_spinbox_a.set_value_no_signal(initial_values.get("julian_d_a", 1.0))
	julian_e_slider_a.set_value_no_signal(initial_values.get("julian_e_a", 0.0))
	julian_e_spinbox_a.set_value_no_signal(initial_values.get("julian_e_a", 0.0))
	julian_f_slider_a.set_value_no_signal(initial_values.get("julian_f_a", 0.0))
	julian_f_spinbox_a.set_value_no_signal(initial_values.get("julian_f_a", 0.0))

	fisheye_strength_slider_a.set_value_no_signal(initial_values.get("fisheye_strength_a", 2.0))
	fisheye_strength_spinbox_a.set_value_no_signal(initial_values.get("fisheye_strength_a", 2.0))
	polar_offset_slider_a.set_value_no_signal(initial_values.get("polar_offset_a", 1.0))
	polar_offset_spinbox_a.set_value_no_signal(initial_values.get("polar_offset_a", 1.0))
	
	_on_mobius_re_a_a_changed(initial_values.get("mobius_re_a_a", 0.1))
	_on_mobius_im_a_a_changed(initial_values.get("mobius_im_a_a", 0.2))
	_on_mobius_re_b_a_changed(initial_values.get("mobius_re_b_a", 0.2))
	_on_mobius_im_b_a_changed(initial_values.get("mobius_im_b_a", -0.12))
	_on_mobius_re_c_a_changed(initial_values.get("mobius_re_c_a", -0.15))
	_on_mobius_im_c_a_changed(initial_values.get("mobius_im_c_a", -0.15))
	_on_mobius_re_d_a_changed(initial_values.get("mobius_re_d_a", 0.21))
	_on_mobius_im_d_a_changed(initial_values.get("mobius_im_d_a", 0.1))
	
	cellular_weave_grid_size_slider_a.set_value_no_signal(initial_values.get("cellular_weave_grid_size_a", 10.0))
	cellular_weave_grid_size_spinbox_a.set_value_no_signal(initial_values.get("cellular_weave_grid_size_a", 10.0))
	cellular_weave_threshold_slider_a.set_value_no_signal(initial_values.get("cellular_weave_threshold_a", 4.0))
	cellular_weave_threshold_spinbox_a.set_value_no_signal(initial_values.get("cellular_weave_threshold_a", 4.0))
	cellular_weave_iterations_slider_a.set_value_no_signal(initial_values.get("cellular_weave_iterations_a", 1.0))
	cellular_weave_iterations_spinbox_a.set_value_no_signal(initial_values.get("cellular_weave_iterations_a", 1.0))
	
	_on_heart_scale_a_changed(initial_values.get("heart_scale_a", 0.3))
	_on_heart_rotation_a_changed(initial_values.get("heart_rotation_a", 0.0))
	_on_heart_strength_a_changed(initial_values.get("heart_strength_a", 0.5))
	
	blur_amount_slider_a.set_value_no_signal(initial_values.get("blur_amount_a", 0.0))
	blur_amount_spinbox_a.set_value_no_signal(initial_values.get("blur_amount_a", 0.0))
	
	
	apollonian_scale_slider_a.set_value_no_signal(initial_values.get("apollonian_scale_a", 1.5))
	apollonian_scale_spinbox_a.set_value_no_signal(initial_values.get("apollonian_scale_a", 1.5))
	var c1a = initial_values.get("ap_c1_a", Vector2(0.0, 0.5))
	ap_c1_a = c1a # <-- FIX
	ap_c1x_spinbox_a.value = c1a.x
	ap_c1y_spinbox_a.value = c1a.y
	var c2a = initial_values.get("ap_c2_a", Vector2(-0.433, -0.25))
	ap_c2_a = c2a # <-- FIX
	ap_c2x_spinbox_a.value = c2a.x
	ap_c2y_spinbox_a.value = c2a.y
	var c3a = initial_values.get("ap_c3_a", Vector2(0.433, -0.25))
	ap_c3_a = c3a # <-- FIX
	ap_c3x_spinbox_a.value = c3a.x
	ap_c3y_spinbox_a.value = c3a.y

	# --- Var B Controls ---
	wave_type_dropdown_b.select(initial_values.get("wave_type_b", 0))
	wave_frequency_slider_b.set_value_no_signal(initial_values.get("wave_freq_b", 5.0))
	wave_frequency_spinbox_b.set_value_no_signal(initial_values.get("wave_freq_b", 5.0))
	wave_amplitude_slider_b.set_value_no_signal(initial_values.get("wave_amp_b", 0.1))
	wave_amplitude_spinbox_b.set_value_no_signal(initial_values.get("wave_amp_b", 0.1))
	wave_speed_slider_b.set_value_no_signal(initial_values.get("wave_speed_b", 0.0))
	wave_speed_spinbox_b.set_value_no_signal(initial_values.get("wave_speed_b", 0.0))
	
	julian_power_slider_b.set_value_no_signal(initial_values.get("julian_power_b", -3.0))
	julian_power_spinbox_b.set_value_no_signal(initial_values.get("julian_power_b", -3.0))
	julian_dist_slider_b.set_value_no_signal(initial_values.get("julian_dist_b", 1.0))
	julian_dist_spinbox_b.set_value_no_signal(initial_values.get("julian_dist_b", 1.0))
	julian_a_slider_b.set_value_no_signal(initial_values.get("julian_a_b", 1.0))
	julian_a_spinbox_b.set_value_no_signal(initial_values.get("julian_a_b", 1.0))
	julian_b_slider_b.set_value_no_signal(initial_values.get("julian_b_b", 0.0))
	julian_b_spinbox_b.set_value_no_signal(initial_values.get("julian_b_b", 0.0))
	julian_c_slider_b.set_value_no_signal(initial_values.get("julian_c_b", 0.0))
	julian_c_spinbox_b.set_value_no_signal(initial_values.get("julian_c_b", 0.0))
	julian_d_slider_b.set_value_no_signal(initial_values.get("julian_d_b", 1.0))
	julian_d_spinbox_b.set_value_no_signal(initial_values.get("julian_d_b", 1.0))
	julian_e_slider_b.set_value_no_signal(initial_values.get("julian_e_b", 0.0))
	julian_e_spinbox_b.set_value_no_signal(initial_values.get("julian_e_b", 0.0))
	julian_f_slider_b.set_value_no_signal(initial_values.get("julian_f_b", 0.0))
	julian_f_spinbox_b.set_value_no_signal(initial_values.get("julian_f_b", 0.0))

	fisheye_strength_slider_b.set_value_no_signal(initial_values.get("fisheye_strength_b", 2.0))
	fisheye_strength_spinbox_b.set_value_no_signal(initial_values.get("fisheye_strength_b", 2.0))
	polar_offset_slider_b.set_value_no_signal(initial_values.get("polar_offset_b", 1.0))
	polar_offset_spinbox_b.set_value_no_signal(initial_values.get("polar_offset_b", 1.0))
	
	_on_mobius_re_a_b_changed(initial_values.get("mobius_re_a_b", 0.1))
	_on_mobius_im_a_b_changed(initial_values.get("mobius_im_a_b", 0.2))
	_on_mobius_re_b_b_changed(initial_values.get("mobius_re_b_b", 0.2))
	_on_mobius_im_b_b_changed(initial_values.get("mobius_im_b_b", -0.12))
	_on_mobius_re_c_b_changed(initial_values.get("mobius_re_c_b", -0.15))
	_on_mobius_im_c_b_changed(initial_values.get("mobius_im_c_b", -0.15))
	_on_mobius_re_d_b_changed(initial_values.get("mobius_re_d_b", 0.21))
	_on_mobius_im_d_b_changed(initial_values.get("mobius_im_d_b", 0.1))
	
	
	
	cellular_weave_grid_size_slider_b.set_value_no_signal(initial_values.get("cellular_weave_grid_size_b", 10.0))
	cellular_weave_grid_size_spinbox_b.set_value_no_signal(initial_values.get("cellular_weave_grid_size_b", 10.0))
	cellular_weave_threshold_slider_b.set_value_no_signal(initial_values.get("cellular_weave_threshold_b", 4.0))
	cellular_weave_threshold_spinbox_b.set_value_no_signal(initial_values.get("cellular_weave_threshold_b", 4.0))
	cellular_weave_iterations_slider_b.set_value_no_signal(initial_values.get("cellular_weave_iterations_b", 1.0))
	cellular_weave_iterations_spinbox_b.set_value_no_signal(initial_values.get("cellular_weave_iterations_b", 1.0))

	_on_heart_scale_b_changed(initial_values.get("heart_scale_b", 0.3))
	_on_heart_rotation_b_changed(initial_values.get("heart_rotation_b", 0.0))
	_on_heart_strength_b_changed(initial_values.get("heart_strength_b", 0.5))
	
	blur_amount_slider_b.set_value_no_signal(initial_values.get("blur_amount_b", 0.0))
	blur_amount_spinbox_b.set_value_no_signal(initial_values.get("blur_amount_b", 0.0))

	apollonian_scale_slider_b.set_value_no_signal(initial_values.get("apollonian_scale_b", 1.5))
	apollonian_scale_spinbox_b.set_value_no_signal(initial_values.get("apollonian_scale_b", 1.5))
	var c1b = initial_values.get("ap_c1_b", Vector2(0.0, 0.5))
	ap_c1_b = c1b # <-- FIX
	ap_c1x_spinbox_b.value = c1b.x
	ap_c1y_spinbox_b.value = c1b.y
	var c2b = initial_values.get("ap_c2_b", Vector2(-0.433, -0.25))
	ap_c2_b = c2b # <-- FIX
	ap_c2x_spinbox_b.value = c2b.x
	ap_c2y_spinbox_b.value = c2b.y
	var c3b = initial_values.get("ap_c3_b", Vector2(0.433, -0.25))
	ap_c3_b = c3b # <-- FIX
	ap_c3x_spinbox_b.value = c3b.x
	ap_c3y_spinbox_b.value = c3b.y
	
	# --- Custom 2x2 ---
	var tl_a_id = initial_values.get("custom_tl_a", 0) as int
	custom_tl_a.select(_get_item_index_by_text(custom_tl_a, _get_name_from_id(tl_a_id)))
	var tr_a_id = initial_values.get("custom_tr_a", 0) as int
	custom_tr_a.select(_get_item_index_by_text(custom_tr_a, _get_name_from_id(tr_a_id)))
	var bl_a_id = initial_values.get("custom_bl_a", 0) as int
	custom_bl_a.select(_get_item_index_by_text(custom_bl_a, _get_name_from_id(bl_a_id)))
	var br_a_id = initial_values.get("custom_br_a", 0) as int
	custom_br_a.select(_get_item_index_by_text(custom_br_a, _get_name_from_id(br_a_id)))
	var tl_b_id = initial_values.get("custom_tl_b", 0) as int
	custom_tl_b.select(_get_item_index_by_text(custom_tl_b, _get_name_from_id(tl_b_id)))
	var tr_b_id = initial_values.get("custom_tr_b", 0) as int
	custom_tr_b.select(_get_item_index_by_text(custom_tr_b, _get_name_from_id(tr_b_id)))
	var bl_b_id = initial_values.get("custom_bl_b", 0) as int
	custom_bl_b.select(_get_item_index_by_text(custom_bl_b, _get_name_from_id(bl_b_id)))
	var br_b_id = initial_values.get("custom_br_b", 0) as int
	custom_br_b.select(_get_item_index_by_text(custom_br_b, _get_name_from_id(br_b_id)))
	
	# --- 3D Light Controls ---
	%LightXAngleSlider.set_value_no_signal(initial_values.get("light_x_rot", 77.0))
	light_x_angle_spinbox.set_value_no_signal(initial_values.get("light_x_rot", 77.0)) 
	%LightYAngleSlider.set_value_no_signal(initial_values.get("light_y_rot", 163.5))
	light_y_angle_spinbox.set_value_no_signal(initial_values.get("light_y_rot", 163.5)) 
	%LightEnergySlider.set_value_no_signal(initial_values.get("light_energy", 1.0))
	light_energy_spinbox.set_value_no_signal(initial_values.get("light_energy", 1.0)) 
	%LightColorPicker.color = initial_values.get("light_color", Color.WHITE)
	%ShadowCheckBox.set_pressed_no_signal(initial_values.get("light_shadows", true))

	%NormalStrengthSlider.set_value_no_signal(initial_values.get("normal_strength", 1.0))
	normal_strength_spinbox.set_value_no_signal(initial_values.get("normal_strength", 1.0)) 

	%CameraDistSlider.set_value_no_signal(initial_values.get("cam_dist", 2.5))
	camera_dist_spinbox.set_value_no_signal(initial_values.get("cam_dist", 2.5)) 
	%CameraXRotSlider.set_value_no_signal(initial_values.get("cam_x_rot", 0.0))
	camera_x_rot_spinbox.set_value_no_signal(initial_values.get("cam_x_rot", 0.0)) 
	%CameraYRotSlider.set_value_no_signal(initial_values.get("cam_y_rot", 0.0))
	camera_y_rot_spinbox.set_value_no_signal(initial_values.get("cam_y_rot", 0.0)) 
	%CameraFovSlider.set_value_no_signal(initial_values.get("cam_fov", 75.0))
	camera_fov_spinbox.set_value_no_signal(initial_values.get("cam_fov", 75.0)) 

	%BackgroundCheckBox.set_pressed_no_signal(initial_values.get("show_2d_bg", false))
	
	
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
			
			# 2. Get the current window aspect ratio
			var window_size = get_viewport().get_visible_rect().size
			var aspect_ratio = window_size.y / window_size.x
			
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
			
			# 2. Get the current window aspect ratio
			var window_size = get_viewport().get_visible_rect().size
			var aspect_ratio = window_size.y / window_size.x
			
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

func _render_and_save_image(path: String, render_size: Vector2i) -> void:
	# --- STAGE 1: Render the raw high-resolution fractal ---
	var source_viewport = viewport_a if is_a_source else viewport_b
	var previous_frame_texture = source_viewport.get_texture()

	save_viewport.size = render_size
	var save_material = save_viewport.get_node("ShaderRect").material as ShaderMaterial

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
	save_material.set_shader_parameter("translate_a", translate_a)
	save_material.set_shader_parameter("translate_b", translate_b)
	save_material.set_shader_parameter("grad_col_tl", grad_col_tl)
	save_material.set_shader_parameter("grad_col_tr", grad_col_tr)
	save_material.set_shader_parameter("grad_col_bl", grad_col_bl)
	save_material.set_shader_parameter("grad_col_br", grad_col_br)
	save_material.set_shader_parameter("background_texture", background_texture)

	# Var A Params
	save_material.set_shader_parameter("var_a_mirror_x", var_a_mirror_x)
	save_material.set_shader_parameter("var_a_mirror_y", var_a_mirror_y)
	save_material.set_shader_parameter("var_a_kaleidoscope_slices", var_a_kaleidoscope_slices)
	save_material.set_shader_parameter("wave_type_a", wave_type_a)
	save_material.set_shader_parameter("wave_frequency_a", wave_frequency_a)
	save_material.set_shader_parameter("wave_amplitude_a", wave_amplitude_a)
	save_material.set_shader_parameter("wave_speed_a", wave_speed_a)
	save_material.set_shader_parameter("julian_power_a", julian_power_a)
	save_material.set_shader_parameter("julian_dist_a", julian_dist_a)
	save_material.set_shader_parameter("julian_mat_a_col1", Vector2(julian_a_a, julian_c_a))
	save_material.set_shader_parameter("julian_mat_a_col2", Vector2(julian_b_a, julian_d_a))
	save_material.set_shader_parameter("julian_trans_a", Vector2(julian_e_a, julian_f_a))
	save_material.set_shader_parameter("fisheye_strength_a", fisheye_strength_a)
	save_material.set_shader_parameter("polar_offset_a", polar_offset_a)
	save_material.set_shader_parameter("mobius_a_a", Vector2(mobius_re_a_a, mobius_im_a_a))
	save_material.set_shader_parameter("mobius_b_a", Vector2(mobius_re_b_a, mobius_im_b_a))
	save_material.set_shader_parameter("mobius_c_a", Vector2(mobius_re_c_a, mobius_im_c_a))
	save_material.set_shader_parameter("mobius_d_a", Vector2(mobius_re_d_a, mobius_im_d_a))
	save_material.set_shader_parameter("cellular_weave_grid_size_a", cellular_weave_grid_size_a)
	save_material.set_shader_parameter("cellular_weave_threshold_a", cellular_weave_threshold_a)
	save_material.set_shader_parameter("cellular_weave_iterations_a", cellular_weave_iterations_a)
	save_material.set_shader_parameter("blur_amount_a", blur_amount_a)
	save_material.set_shader_parameter("heart_scale_a", heart_scale_a)
	save_material.set_shader_parameter("heart_rotation_a", heart_rotation_a)
	save_material.set_shader_parameter("heart_strength_a", heart_strength_a)
	save_material.set_shader_parameter("apollonian_scale_a", apollonian_scale_a)
	save_material.set_shader_parameter("ap_c1_a", ap_c1_a) # <-- ADD
	save_material.set_shader_parameter("ap_c2_a", ap_c2_a) # <-- ADD
	save_material.set_shader_parameter("ap_c3_a", ap_c3_a) # <-- ADD
	save_material.set_shader_parameter("custom_tl_a", custom_tl_a_id)
	save_material.set_shader_parameter("custom_tr_a", custom_tr_a_id)
	save_material.set_shader_parameter("custom_bl_a", custom_bl_a_id)
	save_material.set_shader_parameter("custom_br_a", custom_br_a_id)

	# Var B Params
	save_material.set_shader_parameter("var_b_mirror_x", var_b_mirror_x)
	save_material.set_shader_parameter("var_b_mirror_y", var_b_mirror_y)
	save_material.set_shader_parameter("var_b_kaleidoscope_slices", var_b_kaleidoscope_slices)
	save_material.set_shader_parameter("wave_type_b", wave_type_b)
	save_material.set_shader_parameter("wave_frequency_b", wave_frequency_b)
	save_material.set_shader_parameter("wave_amplitude_b", wave_amplitude_b)
	save_material.set_shader_parameter("wave_speed_b", wave_speed_b)
	save_material.set_shader_parameter("julian_power_b", julian_power_b)
	save_material.set_shader_parameter("julian_dist_b", julian_dist_b)
	save_material.set_shader_parameter("julian_mat_b_col1", Vector2(julian_a_b, julian_c_b))
	save_material.set_shader_parameter("julian_mat_b_col2", Vector2(julian_b_b, julian_d_b))
	save_material.set_shader_parameter("julian_trans_b", Vector2(julian_e_b, julian_f_b))
	save_material.set_shader_parameter("fisheye_strength_b", fisheye_strength_b)
	save_material.set_shader_parameter("polar_offset_b", polar_offset_b)
	save_material.set_shader_parameter("mobius_a_b", Vector2(mobius_re_a_b, mobius_im_a_b))
	save_material.set_shader_parameter("mobius_b_b", Vector2(mobius_re_b_b, mobius_im_b_b))
	save_material.set_shader_parameter("mobius_c_b", Vector2(mobius_re_c_b, mobius_im_c_b))
	save_material.set_shader_parameter("mobius_d_b", Vector2(mobius_re_d_b, mobius_im_d_b))
	save_material.set_shader_parameter("cellular_weave_grid_size_b", cellular_weave_grid_size_b)
	save_material.set_shader_parameter("cellular_weave_threshold_b", cellular_weave_threshold_b)
	save_material.set_shader_parameter("cellular_weave_iterations_b", cellular_weave_iterations_b)
	save_material.set_shader_parameter("blur_amount_b", blur_amount_b)
	save_material.set_shader_parameter("heart_scale_b", heart_scale_b)
	save_material.set_shader_parameter("heart_rotation_b", heart_rotation_b)
	save_material.set_shader_parameter("heart_strength_b", heart_strength_b)
	save_material.set_shader_parameter("apollonian_scale_b", apollonian_scale_b)
	save_material.set_shader_parameter("ap_c1_b", ap_c1_b) # <-- ADD
	save_material.set_shader_parameter("ap_c2_b", ap_c2_b) # <-- ADD
	save_material.set_shader_parameter("ap_c3_b", ap_c3_b) # <-- ADD
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
		
	time += delta
	# print("2. Process is using pre_translate: ", pre_translate) # DEBUG

	var source_viewport = viewport_a if is_a_source else viewport_b
	var target_viewport = viewport_b if is_a_source else viewport_a

	var previous_frame_texture = source_viewport.get_texture()
	var target_material = target_viewport.get_node("ShaderRect").material as ShaderMaterial

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
	target_material.set_shader_parameter("translate_a", translate_a)
	target_material.set_shader_parameter("translate_b", translate_b)
	target_material.set_shader_parameter("grad_col_tl", grad_col_tl)
	target_material.set_shader_parameter("grad_col_tr", grad_col_tr)
	target_material.set_shader_parameter("grad_col_bl", grad_col_bl)
	target_material.set_shader_parameter("grad_col_br", grad_col_br)
	target_material.set_shader_parameter("background_texture", background_texture)

	# Var A Params
	target_material.set_shader_parameter("var_a_mirror_x", var_a_mirror_x)
	target_material.set_shader_parameter("var_a_mirror_y", var_a_mirror_y)
	target_material.set_shader_parameter("var_a_kaleidoscope_slices", var_a_kaleidoscope_slices)
	target_material.set_shader_parameter("wave_type_a", wave_type_a)
	target_material.set_shader_parameter("wave_frequency_a", wave_frequency_a)
	target_material.set_shader_parameter("wave_amplitude_a", wave_amplitude_a)
	target_material.set_shader_parameter("wave_speed_a", wave_speed_a)
	target_material.set_shader_parameter("julian_power_a", julian_power_a)
	target_material.set_shader_parameter("julian_dist_a", julian_dist_a)
	target_material.set_shader_parameter("julian_mat_a_col1", Vector2(julian_a_a, julian_c_a))
	target_material.set_shader_parameter("julian_mat_a_col2", Vector2(julian_b_a, julian_d_a))
	target_material.set_shader_parameter("julian_trans_a", Vector2(julian_e_a, julian_f_a))
	target_material.set_shader_parameter("fisheye_strength_a", fisheye_strength_a)
	target_material.set_shader_parameter("polar_offset_a", polar_offset_a)
	target_material.set_shader_parameter("mobius_a_a", Vector2(mobius_re_a_a, mobius_im_a_a))
	target_material.set_shader_parameter("mobius_b_a", Vector2(mobius_re_b_a, mobius_im_b_a))
	target_material.set_shader_parameter("mobius_c_a", Vector2(mobius_re_c_a, mobius_im_c_a))
	target_material.set_shader_parameter("mobius_d_a", Vector2(mobius_re_d_a, mobius_im_d_a))
	target_material.set_shader_parameter("cellular_weave_grid_size_a", cellular_weave_grid_size_a)
	target_material.set_shader_parameter("cellular_weave_threshold_a", cellular_weave_threshold_a)
	target_material.set_shader_parameter("cellular_weave_iterations_a", cellular_weave_iterations_a)
	target_material.set_shader_parameter("blur_amount_a", blur_amount_a)
	target_material.set_shader_parameter("heart_scale_a", heart_scale_a)
	target_material.set_shader_parameter("heart_rotation_a", heart_rotation_a)
	target_material.set_shader_parameter("heart_strength_a", heart_strength_a)
	target_material.set_shader_parameter("apollonian_scale_a", apollonian_scale_a)
	target_material.set_shader_parameter("ap_c1_a", ap_c1_a) # <-- ADD
	target_material.set_shader_parameter("ap_c2_a", ap_c2_a) # <-- ADD
	target_material.set_shader_parameter("ap_c3_a", ap_c3_a) # <-- ADD
	target_material.set_shader_parameter("custom_tl_a", custom_tl_a_id)
	target_material.set_shader_parameter("custom_tr_a", custom_tr_a_id)
	target_material.set_shader_parameter("custom_bl_a", custom_bl_a_id)
	target_material.set_shader_parameter("custom_br_a", custom_br_a_id)
	

	# Var B Params
	target_material.set_shader_parameter("var_b_mirror_x", var_b_mirror_x)
	target_material.set_shader_parameter("var_b_mirror_y", var_b_mirror_y)
	target_material.set_shader_parameter("var_b_kaleidoscope_slices", var_b_kaleidoscope_slices)
	target_material.set_shader_parameter("wave_type_b", wave_type_b)
	target_material.set_shader_parameter("wave_frequency_b", wave_frequency_b)
	target_material.set_shader_parameter("wave_amplitude_b", wave_amplitude_b)
	target_material.set_shader_parameter("wave_speed_b", wave_speed_b)
	target_material.set_shader_parameter("julian_power_b", julian_power_b)
	target_material.set_shader_parameter("julian_dist_b", julian_dist_b)
	target_material.set_shader_parameter("julian_mat_b_col1", Vector2(julian_a_b, julian_c_b))
	target_material.set_shader_parameter("julian_mat_b_col2", Vector2(julian_b_b, julian_d_b))
	target_material.set_shader_parameter("julian_trans_b", Vector2(julian_e_b, julian_f_b))
	target_material.set_shader_parameter("fisheye_strength_b", fisheye_strength_b)
	target_material.set_shader_parameter("polar_offset_b", polar_offset_b)
	target_material.set_shader_parameter("mobius_a_b", Vector2(mobius_re_a_b, mobius_im_a_b))
	target_material.set_shader_parameter("mobius_b_b", Vector2(mobius_re_b_b, mobius_im_b_b))
	target_material.set_shader_parameter("mobius_c_b", Vector2(mobius_re_c_b, mobius_im_c_b))
	target_material.set_shader_parameter("mobius_d_b", Vector2(mobius_re_d_b, mobius_im_d_b))
	target_material.set_shader_parameter("cellular_weave_grid_size_b", cellular_weave_grid_size_b)
	target_material.set_shader_parameter("cellular_weave_threshold_b", cellular_weave_threshold_b)
	target_material.set_shader_parameter("cellular_weave_iterations_b", cellular_weave_iterations_b)
	target_material.set_shader_parameter("blur_amount_b", blur_amount_b)
	target_material.set_shader_parameter("heart_scale_b", heart_scale_b)
	target_material.set_shader_parameter("heart_rotation_b", heart_rotation_b)
	target_material.set_shader_parameter("heart_strength_b", heart_strength_b)
	target_material.set_shader_parameter("apollonian_scale_b", apollonian_scale_b)
	target_material.set_shader_parameter("ap_c1_b", ap_c1_b) # <-- ADD
	target_material.set_shader_parameter("ap_c2_b", ap_c2_b) # <-- ADD
	target_material.set_shader_parameter("ap_c3_b", ap_c3_b) # <-- ADD
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
# # --- NEW 3D MESH UPDATE (GPU-ONLY) ---
	


	var mesh_material = fractal_mesh.get_surface_override_material(0)
	if is_instance_valid(mesh_material):

		# Determine the viewport that was just rendered TO in this frame
		var rendered_viewport = viewport_b if is_a_source else viewport_a 
		# (Note: is_a_source was flipped just before this block)

		# 1. Get the texture directly from the viewport that was just rendered
		var current_texture = rendered_viewport.get_texture()

		# Check if the texture is valid *before* proceeding
		if not is_instance_valid(current_texture):
			if is_3d_view:
				printerr("ERROR in _process: rendered_viewport texture is invalid!")
			return # Stop processing this mesh update if texture is bad

		# 2. Set the albedo (color) texture
		mesh_material.albedo_texture = current_texture

		# 3. Pass texture and strength into the normal map shader
		if is_instance_valid(normal_map_material):
			# We already checked current_texture is valid above
			normal_map_material.set_shader_parameter("height_map", current_texture)
			normal_map_material.set_shader_parameter("strength", normal_map_strength)
		else:
			if is_3d_view:
				printerr("ERROR in _process: normal_map_material is NOT valid!")

		# 4. Get the *result* from the NormalMapViewport and set it
		mesh_material.normal_texture = normal_map_viewport.get_texture()

	else:
		if is_3d_view:
			printerr("ERROR: mesh_material is null in _process!")
	# --- END 3D MESH UPDATE ---

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
		"var_a_mirror_x": var_a_mirror_x,
		"var_a_mirror_y": var_a_mirror_y,
		"var_a_kaleidoscope_slices": var_a_kaleidoscope_slices,
		"wave_type_a": wave_type_a,
		"wave_frequency_a": wave_frequency_a,
		"wave_amplitude_a": wave_amplitude_a,
		"wave_speed_a": wave_speed_a,
		"julian_power_a": julian_power_a,
		"julian_dist_a": julian_dist_a,
		"julian_a_a": julian_a_a, "julian_b_a": julian_b_a, "julian_c_a": julian_c_a,
		"julian_d_a": julian_d_a, "julian_e_a": julian_e_a, "julian_f_a": julian_f_a,
		"fisheye_strength_a": fisheye_strength_a,
		"polar_offset_a": polar_offset_a,
		"mobius_re_a_a": mobius_re_a_a, "mobius_im_a_a": mobius_im_a_a, "mobius_re_b_a": mobius_re_b_a,
		"mobius_im_b_a": mobius_im_b_a, "mobius_re_c_a": mobius_re_c_a, "mobius_im_c_a": mobius_im_c_a,
		"mobius_re_d_a": mobius_re_d_a, "mobius_im_d_a": mobius_im_d_a,
		"cellular_weave_grid_size_a": cellular_weave_grid_size_a,
		"cellular_weave_threshold_a": cellular_weave_threshold_a,
		"cellular_weave_iterations_a": cellular_weave_iterations_a,
		"blur_amount_a": blur_amount_a,
		"heart_scale_a": heart_scale_a,
		"heart_rotation_a": heart_rotation_a,
		"heart_strength_a": heart_strength_a,
		"apollonian_scale_a": apollonian_scale_a,
		"ap_c1_a": {"x": ap_c1_a.x, "y": ap_c1_a.y}, # <-- ADD (Save as Dict)
		"ap_c2_a": {"x": ap_c2_a.x, "y": ap_c2_a.y}, # <-- ADD (Save as Dict)
		"ap_c3_a": {"x": ap_c3_a.x, "y": ap_c3_a.y}, # <-- ADD (Save as Dict),
		"custom_tl_a": custom_tl_a_id,
		"custom_tr_a": custom_tr_a_id,
		"custom_bl_a": custom_bl_a_id,
		"custom_br_a": custom_br_a_id,

		# Variation B Parameters
		"var_b_mirror_x": var_b_mirror_x,
		"var_b_mirror_y": var_b_mirror_y,
		"var_b_kaleidoscope_slices": var_b_kaleidoscope_slices,
		"wave_type_b": wave_type_b,
		"wave_frequency_b": wave_frequency_b,
		"wave_amplitude_b": wave_amplitude_b,
		"wave_speed_b": wave_speed_b,
		"julian_power_b": julian_power_b,
		"julian_dist_b": julian_dist_b,
		"julian_a_b": julian_a_b, "julian_b_b": julian_b_b, "julian_c_b": julian_c_b,
		"julian_d_b": julian_d_b, "julian_e_b": julian_e_b, "julian_f_b": julian_f_b,
		"fisheye_strength_b": fisheye_strength_b,
		"polar_offset_b": polar_offset_b,
		"mobius_re_a_b": mobius_re_a_b, "mobius_im_a_b": mobius_im_a_b, "mobius_re_b_b": mobius_re_b_b,
		"mobius_im_b_b": mobius_im_b_b, "mobius_re_c_b": mobius_re_c_b, "mobius_im_c_b": mobius_im_c_b,
		"mobius_re_d_b": mobius_re_d_b, "mobius_im_d_b": mobius_im_d_b,
		"cellular_weave_grid_size_b": cellular_weave_grid_size_b,
		"cellular_weave_threshold_b": cellular_weave_threshold_b,
		"cellular_weave_iterations_b": cellular_weave_iterations_b,
		"blur_amount_b": blur_amount_b,
		"heart_scale_b": heart_scale_b,
		"heart_rotation_b": heart_rotation_b,
		"heart_strength_b": heart_strength_b,
		"apollonian_scale_b": apollonian_scale_b,
		"ap_c1_b": {"x": ap_c1_b.x, "y": ap_c1_b.y}, # <-- ADD (Save as Dict)
		"ap_c2_b": {"x": ap_c2_b.x, "y": ap_c2_b.y}, # <-- ADD (Save as Dict)
		"ap_c3_b": {"x": ap_c3_b.x, "y": ap_c3_b.y}, # <-- ADD (Save as Dict)
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
		"camera_fov": camera_fov,
		"show_2d_background": show_2d_background
		
	}
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
# Read and print the preset's version (use 0.0 if not found)
	var preset_version = data.get("version", 0.0)
	print("  SetState: Preset was created with version: ", preset_version)
	_set_platform_feedback_defaults()
	# --- Main Controls ---
	variation_mode_a = data.get("variation_mode_a_id", 0) # Load ID
	variation_mode_b = data.get("variation_mode_b_id", 1) # Load ID
	start_pattern_mode = data.get("start_pattern_mode", 0)
	variation_mix = data.get("variation_mix", 0.5)
	save_resolution_index = data.get("save_resolution_index", 1)
# --- Now, override defaults if they exist in the preset ---
	# 1. Load the range from preset, or use platform default if not present
	feedback_min = data.get("feedback_min", feedback_min)
	feedback_max = data.get("feedback_max", feedback_max)
	
	# 2. Load the amount, or use platform default if not present
	var loaded_feedback_amount = data.get("feedback_amount", feedback_amount)
	
	# 3. Clamp the loaded amount to the (now-final) range
	feedback_amount = clamp(loaded_feedback_amount, feedback_min, feedback_max)
	feedback_amount = data.get("feedback_amount", 0.98)
	seamless_tiling = data.get("seamless_tiling", true)
	mirror_tiling = data.get("mirror_tiling", false)
	reset_on_drag_enabled = data.get("reset_on_drag_enabled", true)

	# --- Start Patterns ---
	show_start_grid = data.get("show_start_grid", false)
	show_circles = data.get("show_circles", true)
	circle_count = data.get("circle_count", 4.0)
	circle_radius = data.get("circle_radius", 0.2)
	circle_softness = data.get("circle_softness", 0.05)
	# Use the moved helper functions, passing 'data'
	grad_col_tl = get_color(data, "grad_col_tl", Color.CYAN)
	grad_col_tr = get_color(data, "grad_col_tr", Color.YELLOW)
	grad_col_bl = get_color(data, "grad_col_bl", Color.BLUE)
	grad_col_br = get_color(data, "grad_col_br", Color.RED)

	# --- Transforms & Color ---
	pre_scale = data.get("pre_scale", 1.0)
	pre_rotation = data.get("pre_rotation", 0.0)
	# Use the moved helper functions, passing 'data'
	pre_translate = get_vector2(data, "pre_translate", Vector2.ZERO)
	post_scale = data.get("post_scale", 1.0) # Default changed to 1.0 for consistency
	post_rotation = data.get("post_rotation", 0.0)
	post_translate = get_vector2(data, "post_translate", Vector2.ZERO)
	translate_a = get_vector2(data, "translate_a", Vector2.ZERO)
	translate_b = get_vector2(data, "translate_b", Vector2.ZERO)
	brightness = data.get("brightness", 1.0)
	contrast = data.get("contrast", 1.0)
	saturation = data.get("saturation", 1.0)

	# --- Active Mouse Translate ---
	move_post_translate = data.get("move_post_translate", true)
	move_pre_translate = data.get("move_pre_translate", false)
	move_var_a_translate = data.get("move_var_a_translate", false)
	move_var_b_translate = data.get("move_var_b_translate", false)

	# --- Post-Processing Symmetry ---
	mirror_x = data.get("post_mirror_x", false)
	mirror_y = data.get("post_mirror_y", false)
	kaleidoscope_on = data.get("post_kaleidoscope_on", false)
	kaleidoscope_slices = data.get("post_kaleidoscope_slices", 6.0)

	# --- Variation A Parameters ---
	var_a_mirror_x = data.get("var_a_mirror_x", false)
	var_a_mirror_y = data.get("var_a_mirror_y", false)
	var_a_kaleidoscope_slices = data.get("var_a_kaleidoscope_slices", 6.0)
	wave_type_a = data.get("wave_type_a", 0)
	wave_frequency_a = data.get("wave_frequency_a", 0.0)
	wave_amplitude_a = data.get("wave_amplitude_a", 0.1)
	wave_speed_a = data.get("wave_speed_a", 0.0)
	julian_power_a = data.get("julian_power_a", 2.0)
	julian_dist_a = data.get("julian_dist_a", 1.0)
	julian_a_a = data.get("julian_a_a", 1.0); julian_b_a = data.get("julian_b_a", 0.0); julian_c_a = data.get("julian_c_a", 0.0)
	julian_d_a = data.get("julian_d_a", 1.0); julian_e_a = data.get("julian_e_a", 0.0); julian_f_a = data.get("julian_f_a", 0.0)
	fisheye_strength_a = data.get("fisheye_strength_a", 2.0)
	polar_offset_a = data.get("polar_offset_a", 1.0)
	mobius_re_a_a = data.get("mobius_re_a_a", 0.1); mobius_im_a_a = data.get("mobius_im_a_a", 0.2)
	mobius_re_b_a = data.get("mobius_re_b_a", 0.2); mobius_im_b_a = data.get("mobius_im_b_a", -0.12)
	mobius_re_c_a = data.get("mobius_re_c_a", -0.15); mobius_im_c_a = data.get("mobius_im_c_a", -0.15)
	mobius_re_d_a = data.get("mobius_re_d_a", 0.21); mobius_im_d_a = data.get("mobius_im_d_a", 0.1)
	cellular_weave_grid_size_a = data.get("cellular_weave_grid_size_a", 10.0)
	cellular_weave_threshold_a = data.get("cellular_weave_threshold_a", 4.0)
	cellular_weave_iterations_a = data.get("cellular_weave_iterations_a", 1.0)
	blur_amount_a = data.get("blur_amount_a", 0.0)
	heart_scale_a = data.get("heart_scale_a", 0.3)
	heart_rotation_a = data.get("heart_rotation_a", 0.0)
	heart_strength_a = data.get("heart_strength_a", 0.5)
	apollonian_scale_a = data.get("apollonian_scale_a", 1.5)
	ap_c1_a = get_vector2(data, "ap_c1_a", Vector2(0.0, 0.5))      # <-- ADD (Use helper)
	ap_c2_a = get_vector2(data, "ap_c2_a", Vector2(-0.433, -0.25)) # <-- ADD (Use helper)
	ap_c3_a = get_vector2(data, "ap_c3_a", Vector2(0.433, -0.25))  # <-- ADD (Use helper)
	custom_tl_a_id = data.get("custom_tl_a", 0)
	custom_tr_a_id = data.get("custom_tr_a", 0)
	custom_bl_a_id = data.get("custom_bl_a", 0)
	custom_br_a_id = data.get("custom_br_a", 0)

	# --- Variation B Parameters ---
	var_b_mirror_x = data.get("var_b_mirror_x", false)
	var_b_mirror_y = data.get("var_b_mirror_y", false)
	var_b_kaleidoscope_slices = data.get("var_b_kaleidoscope_slices", 6.0)
	wave_type_b = data.get("wave_type_b", 0)
	wave_frequency_b = data.get("wave_frequency_b", 5.0)
	wave_amplitude_b = data.get("wave_amplitude_b", 0.1)
	wave_speed_b = data.get("wave_speed_b", 0.0)
	julian_power_b = data.get("julian_power_b", -3.0)
	julian_dist_b = data.get("julian_dist_b", 1.0)
	julian_a_b = data.get("julian_a_b", 1.0); julian_b_b = data.get("julian_b_b", 0.0); julian_c_b = data.get("julian_c_b", 0.0)
	julian_d_b = data.get("julian_d_b", 1.0); julian_e_b = data.get("julian_e_b", 0.0); julian_f_b = data.get("julian_f_b", 0.0)
	fisheye_strength_b = data.get("fisheye_strength_b", 2.0)
	polar_offset_b = data.get("polar_offset_b", 1.0)
	mobius_re_a_b = data.get("mobius_re_a_b", 0.1); mobius_im_a_b = data.get("mobius_im_a_b", 0.2)
	mobius_re_b_b = data.get("mobius_re_b_b", 0.2); mobius_im_b_b = data.get("mobius_im_b_b", -0.12)
	mobius_re_c_b = data.get("mobius_re_c_b", -0.15); mobius_im_c_b = data.get("mobius_im_c_b", -0.15)
	mobius_re_d_b = data.get("mobius_re_d_b", 0.21); mobius_im_d_b = data.get("mobius_im_d_b", 0.1)
	cellular_weave_grid_size_b = data.get("cellular_weave_grid_size_b", 10.0)
	cellular_weave_threshold_b = data.get("cellular_weave_threshold_b", 4.0)
	cellular_weave_iterations_b = data.get("cellular_weave_iterations_b", 1.0)
	blur_amount_b = data.get("blur_amount_b", 0.0)
	heart_scale_b = data.get("heart_scale_b", 0.3)
	heart_rotation_b = data.get("heart_rotation_b", 0.0)
	heart_strength_b = data.get("heart_strength_b", 0.5)
	apollonian_scale_b = data.get("apollonian_scale_b", 1.5)
	ap_c1_b = get_vector2(data, "ap_c1_b", Vector2(0.0, 0.5))      # <-- ADD (Use helper)
	ap_c2_b = get_vector2(data, "ap_c2_b", Vector2(-0.433, -0.25)) # <-- ADD (Use helper)
	ap_c3_b = get_vector2(data, "ap_c3_b", Vector2(0.433, -0.25))  # <-- ADD (Use helper)
	custom_tl_b_id = data.get("custom_tl_b", 0)
	custom_tr_b_id = data.get("custom_tr_b", 0)
	custom_bl_b_id = data.get("custom_bl_b", 0)
	custom_br_b_id = data.get("custom_br_b", 0)
	
	# --- ADD THESE ---
	light_x_rotation = data.get("light_x_rotation", 0.0)
	light_y_rotation = data.get("light_y_rotation", 0.0)
	light_energy = data.get("light_energy", 1.0)
	light_color = get_color(data, "light_color", Color.WHITE)
	light_shadows = data.get("light_shadows", true)
	_update_light() # Apply loaded light values
	# --- END ---
	normal_map_strength = data.get("normal_map_strength", 1.0)
	
	camera_distance = data.get("camera_distance", 0.5)
	camera_x_rotation = data.get("camera_x_rotation", 0.0)
	camera_y_rotation = data.get("camera_y_rotation", 0.0)
	camera_fov = data.get("camera_fov", 75.0)
	show_2d_background = data.get("show_2d_background", false)
	_update_camera() # Apply loaded camera values
	_update_background() # Apply loaded background value
	
	

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
			
	main_vars.sort_custom(func(a, b): return a["name"] < b["name"])
	rep_tile_vars.sort_custom(func(a, b): return a["name"] < b["name"])
	
	var_a_dropdown.add_item("Rep-Tiles")
	var_b_dropdown.add_item("Rep-Tiles")
	
	for item in main_vars:
		var_a_dropdown.add_item(item["name"])
		var_b_dropdown.add_item(item["name"])
		
	for item in rep_tile_vars:
		rep_tile_dropdown_a.add_item(item["name"])
		rep_tile_dropdown_b.add_item(item["name"])

	# --- 3. Populate Wave Type Dropdowns (FIXES ERROR) ---
	wave_type_dropdown_a.clear()
	wave_type_dropdown_b.clear()
	# Based on comments in your code: 0: Vertical, 1: Radial, 2: Square
	wave_type_dropdown_a.add_item("Vertical") # Index 0
	wave_type_dropdown_a.add_item("Radial")   # Index 1
	wave_type_dropdown_a.add_item("Square")   # Index 2
	
	wave_type_dropdown_b.add_item("Vertical") # Index 0
	wave_type_dropdown_b.add_item("Radial")   # Index 1
	wave_type_dropdown_b.add_item("Square")   # Index 2

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



func _on_gradient_toggle_button_pressed():
	gradient_controls_container.visible = not gradient_controls_container.visible
	

func _update_start_pattern_visibility():
	# 1. Get the selected index
	var selected_index = start_pattern_dropdown.selected
	
	# 2. Hide all related controls first
	gradient_toggle_button.visible = false
	circle_controls_container.visible = false
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

# --- 3D Shape Dropdown ---
# (You already have this function, just connect the signal)
# func _on_shape_selected(shape_index: int):
# ...

# --- 2D Background Checkbox ---
func _on_background_check_box_toggled(button_pressed: bool):
	show_2d_background = button_pressed
	_update_background() # Call helper
	_update_view_visibility() # Call helper to fix 2D/3D visibility

# --- Normal Strength ---
func _on_normal_strength_changed(value: float):
	normal_map_strength = value
	%NormalStrengthSlider.set_value_no_signal(value) # Assuming slider is %NormalStrengthSlider
	normal_strength_spinbox.set_value_no_signal(value)

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
	_update_camera() # Call helper

func _on_camera_y_rot_slider_value_changed(value: float):
	_on_camera_y_rot_changed(value)

func _on_camera_y_rot_spinbox_value_changed(value: float):
	_on_camera_y_rot_changed(value)

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

# --- Symmetry Controls (Var A & B) ---

func _on_var_a_mirror_x_check_toggled(button_pressed: bool):
	var_a_mirror_x = button_pressed

func _on_var_a_mirror_y_check_toggled(button_pressed: bool):
	var_a_mirror_y = button_pressed

func _on_var_b_mirror_x_check_toggled(button_pressed: bool):
	var_b_mirror_x = button_pressed

func _on_var_b_mirror_y_check_toggled(button_pressed: bool):
	var_b_mirror_y = button_pressed

func _on_var_a_kaleidoscope_slices_changed(value: float):
	var_a_kaleidoscope_slices = value
	var_a_kaleidoscope_slider.set_value_no_signal(value)
	var_a_kaleidoscope_spinbox.set_value_no_signal(value)

func _on_var_a_kaleidoscope_slices_slider_value_changed(value: float):
	_on_var_a_kaleidoscope_slices_changed(value)

func _on_var_a_kaleidoscope_slices_spinbox_value_changed(value: float):
	_on_var_a_kaleidoscope_slices_changed(value)

func _on_var_b_kaleidoscope_slices_changed(value: float):
	var_b_kaleidoscope_slices = value
	var_b_kaleidoscope_slider.set_value_no_signal(value)
	var_b_kaleidoscope_spinbox.set_value_no_signal(value)

func _on_var_b_kaleidoscope_slices_slider_value_changed(value: float):
	_on_var_b_kaleidoscope_slices_changed(value)

func _on_var_b_kaleidoscope_slices_spinbox_value_changed(value: float):
	_on_var_b_kaleidoscope_slices_changed(value)


# --- Wave Controls (Var A & B) ---

func _on_wave_type_dropdown_a_item_selected(index: int):
	wave_type_a = index

func _on_wave_frequency_a_changed(value: float):
	wave_frequency_a = value
	wave_frequency_slider_a.set_value_no_signal(value)
	wave_frequency_spinbox_a.set_value_no_signal(value)

func _on_wave_frequency_slider_a_value_changed(value: float):
	_on_wave_frequency_a_changed(value)

func _on_wave_frequency_spinbox_a_value_changed(value: float):
	_on_wave_frequency_a_changed(value)

func _on_wave_amplitude_a_changed(value: float):
	wave_amplitude_a = value
	wave_amplitude_slider_a.set_value_no_signal(value)
	wave_amplitude_spinbox_a.set_value_no_signal(value)

func _on_wave_amplitude_slider_a_value_changed(value: float):
	_on_wave_amplitude_a_changed(value)

func _on_wave_amplitude_spinbox_a_value_changed(value: float):
	_on_wave_amplitude_a_changed(value)

func _on_wave_speed_a_changed(value: float):
	wave_speed_a = value
	wave_speed_slider_a.set_value_no_signal(value)
	wave_speed_spinbox_a.set_value_no_signal(value)

func _on_wave_speed_slider_a_value_changed(value: float):
	_on_wave_speed_a_changed(value)

func _on_wave_speed_spinbox_a_value_changed(value: float):
	_on_wave_speed_a_changed(value)

func _on_wave_type_dropdown_b_item_selected(index: int):
	wave_type_b = index

func _on_wave_frequency_b_changed(value: float):
	wave_frequency_b = value
	wave_frequency_slider_b.set_value_no_signal(value)
	wave_frequency_spinbox_b.set_value_no_signal(value)

func _on_wave_frequency_slider_b_value_changed(value: float):
	_on_wave_frequency_b_changed(value)

func _on_wave_frequency_spinbox_b_value_changed(value: float):
	_on_wave_frequency_b_changed(value)

func _on_wave_amplitude_b_changed(value: float):
	wave_amplitude_b = value
	wave_amplitude_slider_b.set_value_no_signal(value)
	wave_amplitude_spinbox_b.set_value_no_signal(value)

func _on_wave_amplitude_slider_b_value_changed(value: float):
	_on_wave_amplitude_b_changed(value)

func _on_wave_amplitude_spinbox_b_value_changed(value: float):
	_on_wave_amplitude_b_changed(value)

func _on_wave_speed_b_changed(value: float):
	wave_speed_b = value
	wave_speed_slider_b.set_value_no_signal(value)
	wave_speed_spinbox_b.set_value_no_signal(value)

func _on_wave_speed_slider_b_value_changed(value: float):
	_on_wave_speed_b_changed(value)

func _on_wave_speed_spinbox_b_value_changed(value: float):
	_on_wave_speed_b_changed(value)


# --- Julian Controls (Var A & B) ---

# (This is a pattern: repeat for all 6 Julian pairs, A and B)
func _on_julian_power_a_changed(value: float):
	julian_power_a = value
	julian_power_slider_a.set_value_no_signal(value)
	julian_power_spinbox_a.set_value_no_signal(value)

func _on_julian_power_slider_a_value_changed(value: float):
	_on_julian_power_a_changed(value)

func _on_julian_power_spinbox_a_value_changed(value: float):
	_on_julian_power_a_changed(value)

func _on_julian_dist_a_changed(value: float):
	julian_dist_a = value
	julian_dist_slider_a.set_value_no_signal(value)
	julian_dist_spinbox_a.set_value_no_signal(value)

func _on_julian_dist_slider_a_value_changed(value: float):
	_on_julian_dist_a_changed(value)

func _on_julian_dist_spinbox_a_value_changed(value: float):
	_on_julian_dist_a_changed(value)

func _on_julian_a_a_changed(value: float):
	julian_a_a = value
	julian_a_slider_a.set_value_no_signal(value)
	julian_a_spinbox_a.set_value_no_signal(value)

func _on_julian_a_slider_a_value_changed(value: float):
	_on_julian_a_a_changed(value)

func _on_julian_a_spinbox_a_value_changed(value: float):
	_on_julian_a_a_changed(value)

func _on_julian_b_a_changed(value: float):
	julian_b_a = value
	julian_b_slider_a.set_value_no_signal(value)
	julian_b_spinbox_a.set_value_no_signal(value)

func _on_julian_b_slider_a_value_changed(value: float):
	_on_julian_b_a_changed(value)

func _on_julian_b_spinbox_a_value_changed(value: float):
	_on_julian_b_a_changed(value)

func _on_julian_c_a_changed(value: float):
	julian_c_a = value
	julian_c_slider_a.set_value_no_signal(value)
	julian_c_spinbox_a.set_value_no_signal(value)

func _on_julian_c_slider_a_value_changed(value: float):
	_on_julian_c_a_changed(value)

func _on_julian_c_spinbox_a_value_changed(value: float):
	_on_julian_c_a_changed(value)

func _on_julian_d_a_changed(value: float):
	julian_d_a = value
	julian_d_slider_a.set_value_no_signal(value)
	julian_d_spinbox_a.set_value_no_signal(value)

func _on_julian_d_slider_a_value_changed(value: float):
	_on_julian_d_a_changed(value)

func _on_julian_d_spinbox_a_value_changed(value: float):
	_on_julian_d_a_changed(value)

func _on_julian_e_a_changed(value: float):
	julian_e_a = value
	julian_e_slider_a.set_value_no_signal(value)
	julian_e_spinbox_a.set_value_no_signal(value)

func _on_julian_e_slider_a_value_changed(value: float):
	_on_julian_e_a_changed(value)

func _on_julian_e_spinbox_a_value_changed(value: float):
	_on_julian_e_a_changed(value)

func _on_julian_f_a_changed(value: float):
	julian_f_a = value
	julian_f_slider_a.set_value_no_signal(value)
	julian_f_spinbox_a.set_value_no_signal(value)

func _on_julian_f_slider_a_value_changed(value: float):
	_on_julian_f_a_changed(value)

func _on_julian_f_spinbox_a_value_changed(value: float):
	_on_julian_f_a_changed(value)

func _on_julian_power_b_changed(value: float):
	julian_power_b = value
	julian_power_slider_b.set_value_no_signal(value)
	julian_power_spinbox_b.set_value_no_signal(value)

func _on_julian_power_slider_b_value_changed(value: float):
	_on_julian_power_b_changed(value)

func _on_julian_power_spinbox_b_value_changed(value: float):
	_on_julian_power_b_changed(value)

func _on_julian_dist_b_changed(value: float):
	julian_dist_b = value
	julian_dist_slider_b.set_value_no_signal(value)
	julian_dist_spinbox_b.set_value_no_signal(value)

func _on_julian_dist_slider_b_value_changed(value: float):
	_on_julian_dist_b_changed(value)

func _on_julian_dist_spinbox_b_value_changed(value: float):
	_on_julian_dist_b_changed(value)

func _on_julian_a_b_changed(value: float):
	julian_a_b = value
	julian_a_slider_b.set_value_no_signal(value)
	julian_a_spinbox_b.set_value_no_signal(value)

func _on_julian_a_slider_b_value_changed(value: float):
	_on_julian_a_b_changed(value)

func _on_julian_a_spinbox_b_value_changed(value: float):
	_on_julian_a_b_changed(value)

func _on_julian_b_b_changed(value: float):
	julian_b_b = value
	julian_b_slider_b.set_value_no_signal(value)
	julian_b_spinbox_b.set_value_no_signal(value)

func _on_julian_b_slider_b_value_changed(value: float):
	_on_julian_b_b_changed(value)

func _on_julian_b_spinbox_b_value_changed(value: float):
	_on_julian_b_b_changed(value)

func _on_julian_c_b_changed(value: float):
	julian_c_b = value
	julian_c_slider_b.set_value_no_signal(value)
	julian_c_spinbox_b.set_value_no_signal(value)

func _on_julian_c_slider_b_value_changed(value: float):
	_on_julian_c_b_changed(value)

func _on_julian_c_spinbox_b_value_changed(value: float):
	_on_julian_c_b_changed(value)

func _on_julian_d_b_changed(value: float):
	julian_d_b = value
	julian_d_slider_b.set_value_no_signal(value)
	julian_d_spinbox_b.set_value_no_signal(value)

func _on_julian_d_slider_b_value_changed(value: float):
	_on_julian_d_b_changed(value)

func _on_julian_d_spinbox_b_value_changed(value: float):
	_on_julian_d_b_changed(value)

func _on_julian_e_b_changed(value: float):
	julian_e_b = value
	julian_e_slider_b.set_value_no_signal(value)
	julian_e_spinbox_b.set_value_no_signal(value)

func _on_julian_e_slider_b_value_changed(value: float):
	_on_julian_e_b_changed(value)

func _on_julian_e_spinbox_b_value_changed(value: float):
	_on_julian_e_b_changed(value)

func _on_julian_f_b_changed(value: float):
	julian_f_b = value
	julian_f_slider_b.set_value_no_signal(value)
	julian_f_spinbox_b.set_value_no_signal(value)

func _on_julian_f_slider_b_value_changed(value: float):
	_on_julian_f_b_changed(value)

func _on_julian_f_spinbox_b_value_changed(value: float):
	_on_julian_f_b_changed(value)


# --- Fisheye & Polar Controls (Var A & B) ---

func _on_fisheye_strength_a_changed(value: float):
	fisheye_strength_a = value
	fisheye_strength_slider_a.set_value_no_signal(value)
	fisheye_strength_spinbox_a.set_value_no_signal(value)

func _on_fisheye_strength_slider_a_value_changed(value: float):
	_on_fisheye_strength_a_changed(value)

func _on_fisheye_strength_spinbox_a_value_changed(value: float):
	_on_fisheye_strength_a_changed(value)

func _on_polar_offset_a_changed(value: float):
	polar_offset_a = value
	polar_offset_slider_a.set_value_no_signal(value)
	polar_offset_spinbox_a.set_value_no_signal(value)

func _on_polar_offset_slider_a_value_changed(value: float):
	_on_polar_offset_a_changed(value)

func _on_polar_offset_spinbox_a_value_changed(value: float):
	_on_polar_offset_a_changed(value)

func _on_fisheye_strength_b_changed(value: float):
	fisheye_strength_b = value
	fisheye_strength_slider_b.set_value_no_signal(value)
	fisheye_strength_spinbox_b.set_value_no_signal(value)

func _on_fisheye_strength_slider_b_value_changed(value: float):
	_on_fisheye_strength_b_changed(value)

func _on_fisheye_strength_spinbox_b_value_changed(value: float):
	_on_fisheye_strength_b_changed(value)

func _on_polar_offset_b_changed(value: float):
	polar_offset_b = value
	polar_offset_slider_b.set_value_no_signal(value)
	polar_offset_spinbox_b.set_value_no_signal(value)

func _on_polar_offset_slider_b_value_changed(value: float):
	_on_polar_offset_b_changed(value)

func _on_polar_offset_spinbox_b_value_changed(value: float):
	_on_polar_offset_b_changed(value)


# --- Apollonian Scale Controls (Var A & B) ---

func _on_apollonian_scale_a_changed(value: float):
	apollonian_scale_a = value
	apollonian_scale_slider_a.set_value_no_signal(value)
	apollonian_scale_spinbox_a.set_value_no_signal(value)

func _on_apollonian_scale_slider_a_value_changed(value: float):
	_on_apollonian_scale_a_changed(value)

func _on_apollonian_scale_spinbox_a_value_changed(value: float):
	_on_apollonian_scale_a_changed(value)
	
func _on_apollonian_scale_b_changed(value: float):
	apollonian_scale_b = value
	apollonian_scale_slider_b.set_value_no_signal(value)
	apollonian_scale_spinbox_b.set_value_no_signal(value)

func _on_apollonian_scale_slider_b_value_changed(value: float):
	_on_apollonian_scale_b_changed(value)

func _on_apollonian_scale_spinbox_b_value_changed(value: float):
	_on_apollonian_scale_b_changed(value)


# --- Heart Controls (Var A & B) ---
func _on_heart_scale_a_changed(value: float):
	heart_scale_a = value
	heart_scale_slider_a.set_value_no_signal(value)
	heart_scale_spinbox_a.set_value_no_signal(value)
	
func _on_heart_scale_slider_a_value_changed(value: float): _on_heart_scale_a_changed(value)
func _on_heart_scale_spinbox_a_value_changed(value: float): _on_heart_scale_a_changed(value)

func _on_heart_rotation_a_changed(value: float):
	heart_rotation_a = value
	heart_rotation_slider_a.set_value_no_signal(value)
	heart_rotation_spinbox_a.set_value_no_signal(value)
	
func _on_heart_rotation_slider_a_value_changed(value: float): _on_heart_rotation_a_changed(value)
func _on_heart_rotation_spinbox_a_value_changed(value: float): _on_heart_rotation_a_changed(value)

func _on_heart_strength_a_changed(value: float):
	heart_strength_a = value
	heart_strength_slider_a.set_value_no_signal(value)
	heart_strength_spinbox_a.set_value_no_signal(value)
	
func _on_heart_strength_slider_a_value_changed(value: float): _on_heart_strength_a_changed(value)
func _on_heart_strength_spinbox_a_value_changed(value: float): _on_heart_strength_a_changed(value)

func _on_heart_scale_b_changed(value: float):
	heart_scale_b = value
	heart_scale_slider_b.set_value_no_signal(value)
	heart_scale_spinbox_b.set_value_no_signal(value)
	
func _on_heart_scale_slider_b_value_changed(value: float): _on_heart_scale_b_changed(value)
func _on_heart_scale_spinbox_b_value_changed(value: float): _on_heart_scale_b_changed(value)

func _on_heart_rotation_b_changed(value: float):
	heart_rotation_b = value
	heart_rotation_slider_b.set_value_no_signal(value)
	heart_rotation_spinbox_b.set_value_no_signal(value)
	
func _on_heart_rotation_slider_b_value_changed(value: float): _on_heart_rotation_b_changed(value)
func _on_heart_rotation_spinbox_b_value_changed(value: float): _on_heart_rotation_b_changed(value)

func _on_heart_strength_b_changed(value: float):
	heart_strength_b = value
	heart_strength_slider_b.set_value_no_signal(value)
	heart_strength_spinbox_b.set_value_no_signal(value)
	
func _on_heart_strength_slider_b_value_changed(value: float): _on_heart_strength_b_changed(value)
func _on_heart_strength_spinbox_b_value_changed(value: float): _on_heart_strength_b_changed(value)
# --- Slider-Only Controls (Mobius, CellularWeave, Blur) ---

# --- Mobius A ---
func _on_mobius_re_a_a_changed(value: float):
	mobius_re_a_a = value
	%MobiusReASliderA.set_value_no_signal(value)
	mobius_re_a_spinbox_a.set_value_no_signal(value)

func _on_mobius_im_a_a_changed(value: float):
	mobius_im_a_a = value
	%MobiusImASliderA.set_value_no_signal(value)
	mobius_im_a_spinbox_a.set_value_no_signal(value)

func _on_mobius_re_b_a_changed(value: float):
	mobius_re_b_a = value
	%MobiusReBSliderA.set_value_no_signal(value)
	mobius_re_b_spinbox_a.set_value_no_signal(value)

func _on_mobius_im_b_a_changed(value: float):
	mobius_im_b_a = value
	%MobiusImBSliderA.set_value_no_signal(value)
	mobius_im_b_spinbox_a.set_value_no_signal(value)

func _on_mobius_re_c_a_changed(value: float):
	mobius_re_c_a = value
	%MobiusReCSliderA.set_value_no_signal(value)
	mobius_re_c_spinbox_a.set_value_no_signal(value)

func _on_mobius_im_c_a_changed(value: float):
	mobius_im_c_a = value
	%MobiusImCSliderA.set_value_no_signal(value)
	mobius_im_c_spinbox_a.set_value_no_signal(value)

func _on_mobius_re_d_a_changed(value: float):
	mobius_re_d_a = value
	%MobiusReDSliderA.set_value_no_signal(value)
	mobius_re_d_spinbox_a.set_value_no_signal(value)

func _on_mobius_im_d_a_changed(value: float):
	mobius_im_d_a = value
	%MobiusImDSliderA.set_value_no_signal(value)
	mobius_im_d_spinbox_a.set_value_no_signal(value)

# --- Mobius B ---
func _on_mobius_re_a_b_changed(value: float):
	mobius_re_a_b = value
	%MobiusReASliderB.set_value_no_signal(value)
	mobius_re_a_spinbox_b.set_value_no_signal(value)

func _on_mobius_im_a_b_changed(value: float):
	mobius_im_a_b = value
	%MobiusImASliderB.set_value_no_signal(value)
	mobius_im_a_spinbox_b.set_value_no_signal(value)

func _on_mobius_re_b_b_changed(value: float):
	mobius_re_b_b = value
	%MobiusReBSliderB.set_value_no_signal(value)
	mobius_re_b_spinbox_b.set_value_no_signal(value)

func _on_mobius_im_b_b_changed(value: float):
	mobius_im_b_b = value
	%MobiusImBSliderB.set_value_no_signal(value)
	mobius_im_b_spinbox_b.set_value_no_signal(value)

func _on_mobius_re_c_b_changed(value: float):
	mobius_re_c_b = value
	%MobiusReCSliderB.set_value_no_signal(value)
	mobius_re_c_spinbox_b.set_value_no_signal(value)

func _on_mobius_im_c_b_changed(value: float):
	mobius_im_c_b = value
	%MobiusImCSliderB.set_value_no_signal(value)
	mobius_im_c_spinbox_b.set_value_no_signal(value)

func _on_mobius_re_d_b_changed(value: float):
	mobius_re_d_b = value
	%MobiusReDSliderB.set_value_no_signal(value)
	mobius_re_d_spinbox_b.set_value_no_signal(value)

func _on_mobius_im_d_b_changed(value: float):
	mobius_im_d_b = value
	%MobiusImDSliderB.set_value_no_signal(value)
	mobius_im_d_spinbox_b.set_value_no_signal(value)


# --- SLIDER HANDLERS (A) ---
func _on_mobius_re_a_slider_a_value_changed(value: float): _on_mobius_re_a_a_changed(value)
func _on_mobius_im_a_slider_a_value_changed(value: float): _on_mobius_im_a_a_changed(value)
func _on_mobius_re_b_slider_a_value_changed(value: float): _on_mobius_re_b_a_changed(value)
func _on_mobius_im_b_slider_a_value_changed(value: float): _on_mobius_im_b_a_changed(value)
func _on_mobius_re_c_slider_a_value_changed(value: float): _on_mobius_re_c_a_changed(value)
func _on_mobius_im_c_slider_a_value_changed(value: float): _on_mobius_im_c_a_changed(value)
func _on_mobius_re_d_slider_a_value_changed(value: float): _on_mobius_re_d_a_changed(value)
func _on_mobius_im_d_slider_a_value_changed(value: float): _on_mobius_im_d_a_changed(value)

# --- SPINBOX HANDLERS (A) ---
func _on_mobius_re_a_spinbox_a_value_changed(value: float): _on_mobius_re_a_a_changed(value)
func _on_mobius_im_a_spinbox_a_value_changed(value: float): _on_mobius_im_a_a_changed(value)
func _on_mobius_re_b_spinbox_a_value_changed(value: float): _on_mobius_re_b_a_changed(value)
func _on_mobius_im_b_spinbox_a_value_changed(value: float): _on_mobius_im_b_a_changed(value)
func _on_mobius_re_c_spinbox_a_value_changed(value: float): _on_mobius_re_c_a_changed(value)
func _on_mobius_im_c_spinbox_a_value_changed(value: float): _on_mobius_im_c_a_changed(value)
func _on_mobius_re_d_spinbox_a_value_changed(value: float): _on_mobius_re_d_a_changed(value)
func _on_mobius_im_d_spinbox_a_value_changed(value: float): _on_mobius_im_d_a_changed(value)

# --- SLIDER HANDLERS (B) ---
func _on_mobius_re_a_slider_b_value_changed(value: float): _on_mobius_re_a_b_changed(value)
func _on_mobius_im_a_slider_b_value_changed(value: float): _on_mobius_im_a_b_changed(value)
func _on_mobius_re_b_slider_b_value_changed(value: float): _on_mobius_re_b_b_changed(value)
func _on_mobius_im_b_slider_b_value_changed(value: float): _on_mobius_im_b_b_changed(value)
func _on_mobius_re_c_slider_b_value_changed(value: float): _on_mobius_re_c_b_changed(value)
func _on_mobius_im_c_slider_b_value_changed(value: float): _on_mobius_im_c_b_changed(value)
func _on_mobius_re_d_slider_b_value_changed(value: float): _on_mobius_re_d_b_changed(value)
func _on_mobius_im_d_slider_b_value_changed(value: float): _on_mobius_im_d_b_changed(value)

# --- SPINBOX HANDLERS (B) ---
func _on_mobius_re_a_spinbox_b_value_changed(value: float): _on_mobius_re_a_b_changed(value)
func _on_mobius_im_a_spinbox_b_value_changed(value: float): _on_mobius_im_a_b_changed(value)
func _on_mobius_re_b_spinbox_b_value_changed(value: float): _on_mobius_re_b_b_changed(value)
func _on_mobius_im_b_spinbox_b_value_changed(value: float): _on_mobius_im_b_b_changed(value)
func _on_mobius_re_c_spinbox_b_value_changed(value: float): _on_mobius_re_c_b_changed(value)
func _on_mobius_im_c_spinbox_b_value_changed(value: float): _on_mobius_im_c_b_changed(value)
func _on_mobius_re_d_spinbox_b_value_changed(value: float): _on_mobius_re_d_b_changed(value)
func _on_mobius_im_d_spinbox_b_value_changed(value: float): _on_mobius_im_d_b_changed(value)


# --- Cellular Weave A ---
func _on_cellular_weave_grid_size_a_changed(value: float):
	cellular_weave_grid_size_a = value
	cellular_weave_grid_size_slider_a.set_value_no_signal(value)
	cellular_weave_grid_size_spinbox_a.set_value_no_signal(value)

func _on_cellular_weave_grid_size_slider_a_value_changed(value: float):
	_on_cellular_weave_grid_size_a_changed(value)

func _on_cellular_weave_grid_size_spinbox_a_value_changed(value: float):
	_on_cellular_weave_grid_size_a_changed(value)

func _on_cellular_weave_threshold_a_changed(value: float):
	cellular_weave_threshold_a = value
	cellular_weave_threshold_slider_a.set_value_no_signal(value)
	cellular_weave_threshold_spinbox_a.set_value_no_signal(value)

func _on_cellular_weave_threshold_slider_a_value_changed(value: float):
	_on_cellular_weave_threshold_a_changed(value)

func _on_cellular_weave_threshold_spinbox_a_value_changed(value: float):
	_on_cellular_weave_threshold_a_changed(value)

func _on_cellular_weave_iterations_a_changed(value: float):
	cellular_weave_iterations_a = value
	cellular_weave_iterations_slider_a.set_value_no_signal(value)
	cellular_weave_iterations_spinbox_a.set_value_no_signal(value)

func _on_cellular_weave_iterations_slider_a_value_changed(value: float):
	_on_cellular_weave_iterations_a_changed(value)

func _on_cellular_weave_iterations_spinbox_a_value_changed(value: float):
	_on_cellular_weave_iterations_a_changed(value)

# --- Cellular Weave B ---
func _on_cellular_weave_grid_size_b_changed(value: float):
	cellular_weave_grid_size_b = value
	cellular_weave_grid_size_slider_b.set_value_no_signal(value)
	cellular_weave_grid_size_spinbox_b.set_value_no_signal(value)
	
func _on_cellular_weave_grid_size_slider_b_value_changed(value: float):
	_on_cellular_weave_grid_size_b_changed(value)

func _on_cellular_weave_grid_size_spinbox_b_value_changed(value: float):
	_on_cellular_weave_grid_size_b_changed(value)

func _on_cellular_weave_threshold_b_changed(value: float):
	cellular_weave_threshold_b = value
	cellular_weave_threshold_slider_b.set_value_no_signal(value)
	cellular_weave_threshold_spinbox_b.set_value_no_signal(value)

func _on_cellular_weave_threshold_slider_b_value_changed(value: float):
	_on_cellular_weave_threshold_b_changed(value)

func _on_cellular_weave_threshold_spinbox_b_value_changed(value: float):
	_on_cellular_weave_threshold_b_changed(value)

func _on_cellular_weave_iterations_b_changed(value: float):
	cellular_weave_iterations_b = value
	cellular_weave_iterations_slider_b.set_value_no_signal(value)
	cellular_weave_iterations_spinbox_b.set_value_no_signal(value)

func _on_cellular_weave_iterations_slider_b_value_changed(value: float):
	_on_cellular_weave_iterations_b_changed(value)

func _on_cellular_weave_iterations_spinbox_b_value_changed(value: float):
	_on_cellular_weave_iterations_b_changed(value)

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

# --- Unique Vector Controls (Apollonian) ---
func _on_ap_c1x_spinbox_a_value_changed(value: float):
	ap_c1_a.x = value
func _on_ap_c1y_spinbox_a_value_changed(value: float):
	ap_c1_a.y = value
func _on_ap_c2x_spinbox_a_value_changed(value: float):
	ap_c2_a.x = value
func _on_ap_c2y_spinbox_a_value_changed(value: float):
	ap_c2_a.y = value
func _on_ap_c3x_spinbox_a_value_changed(value: float):
	ap_c3_a.x = value
func _on_ap_c3y_spinbox_a_value_changed(value: float):
	ap_c3_a.y = value

func _on_ap_c1x_spinbox_b_value_changed(value: float):
	ap_c1_b.x = value
func _on_ap_c1y_spinbox_b_value_changed(value: float):
	ap_c1_b.y = value
func _on_ap_c2x_spinbox_b_value_changed(value: float):
	ap_c2_b.x = value
func _on_ap_c2y_spinbox_b_value_changed(value: float):
	ap_c2_b.y = value
func _on_ap_c3x_spinbox_b_value_changed(value: float):
	ap_c3_b.x = value
func _on_ap_c3y_spinbox_b_value_changed(value: float):
	ap_c3_b.y = value
