class_name UIController
extends Window

# --- Signals ---
var _is_initializing := true
signal variation_a_changed(id: int) # Emits the Variation ID
signal variation_b_changed(id: int) # Emits the Variation ID
signal start_pattern_changed(index: int)
signal variation_mix_changed(value: float)
signal feedback_amount_changed(value: float)
signal feedback_range_min_changed(value: float)
signal feedback_range_max_changed(value: float)
signal seamless_tiling_changed(is_on: bool)
signal reset_on_drag_changed(is_on: bool)
signal show_grid_toggled(is_on: bool)
signal show_circles_toggled(is_on: bool)
signal pre_scale_changed(value: float)
signal pre_rotation_changed(value: float)
signal post_scale_changed(value: float)
signal post_rotation_changed(value: float)
signal brightness_changed(value: float)
signal contrast_changed(value: float)
signal saturation_changed(value: float)
signal resolution_selected(index: int)
signal save_button_pressed()
signal circle_count_changed(value: float)
signal circle_radius_changed(value: float)
signal circle_softness_changed(value: float)
signal post_translate_toggled(is_on: bool)
signal pre_translate_toggled(is_on: bool)
signal var_a_translate_toggled(is_on: bool)
signal var_b_translate_toggled(is_on: bool)
signal grad_col_tl_changed(color: Color)
signal grad_col_tr_changed(color: Color)
signal grad_col_bl_changed(color: Color)
signal grad_col_br_changed(color: Color)
signal translate_target_changed(index: int)
signal load_image_button_pressed()
signal mirror_tiling_changed(is_on: bool)
signal save_preset_pressed()
signal load_preset_pressed()
signal copy_preset_pressed()
signal paste_preset_pressed()
signal wave_type_a_changed(index: int)
signal wave_frequency_a_changed(value: float)
signal wave_amplitude_a_changed(value: float)
signal wave_speed_a_changed(value: float)
signal wave_type_b_changed(index: int)
signal wave_frequency_b_changed(value: float)
signal wave_amplitude_b_changed(value: float)
signal wave_speed_b_changed(value: float)
signal julian_power_a_changed(value: float)
signal julian_dist_a_changed(value: float)
signal julian_a_a_changed(value: float)
signal julian_b_a_changed(value: float)
signal julian_c_a_changed(value: float)
signal julian_d_a_changed(value: float)
signal julian_e_a_changed(value: float)
signal julian_f_a_changed(value: float)
signal julian_power_b_changed(value: float)
signal julian_dist_b_changed(value: float)
signal julian_a_b_changed(value: float)
signal julian_b_b_changed(value: float)
signal julian_c_b_changed(value: float)
signal julian_d_b_changed(value: float)
signal julian_e_b_changed(value: float)
signal julian_f_b_changed(value: float)
signal fisheye_strength_a_changed(value: float)
signal polar_offset_a_changed(value: float)
signal fisheye_strength_b_changed(value: float)
signal polar_offset_b_changed(value: float)
signal mirror_x_changed(is_on: bool)
signal mirror_y_changed(is_on: bool)
signal kaleidoscope_changed(is_on: bool)
signal kaleidoscope_slices_changed(value: float)
signal var_a_mirror_x_changed(is_on: bool)
signal var_a_mirror_y_changed(is_on: bool)
signal var_a_kaleidoscope_slices_changed(value: float)
signal var_b_mirror_x_changed(is_on: bool)
signal var_b_mirror_y_changed(is_on: bool)
signal var_b_kaleidoscope_slices_changed(value: float)
signal mobius_re_a_a_changed(value: float)
signal mobius_im_a_a_changed(value: float)
signal mobius_re_b_a_changed(value: float)
signal mobius_im_b_a_changed(value: float)
signal mobius_re_c_a_changed(value: float)
signal mobius_im_c_a_changed(value: float)
signal mobius_re_d_a_changed(value: float)
signal mobius_im_d_a_changed(value: float)
signal mobius_re_a_b_changed(value: float)
signal mobius_im_a_b_changed(value: float)
signal mobius_re_b_b_changed(value: float)
signal mobius_im_b_b_changed(value: float)
signal mobius_re_c_b_changed(value: float)
signal mobius_im_c_b_changed(value: float)
signal mobius_re_d_b_changed(value: float)
signal mobius_im_d_b_changed(value: float)
signal cellular_weave_grid_size_a_changed(value: float)
signal cellular_weave_threshold_a_changed(value: float)
signal cellular_weave_iterations_a_changed(value: float)
signal cellular_weave_grid_size_b_changed(value: float)
signal cellular_weave_threshold_b_changed(value: float)
signal cellular_weave_iterations_b_changed(value: float)
signal blur_amount_a_changed(value: float)
signal blur_amount_b_changed(value: float)
signal heart_scale_a_changed(value: float)
signal heart_rotation_a_changed(value: float)
signal heart_strength_a_changed(value: float)
signal heart_scale_b_changed(value: float)
signal heart_rotation_b_changed(value: float)
signal heart_strength_b_changed(value: float)
signal apollonian_scale_a_changed(value: float)
signal ap_c1_a_changed(value: Vector2)
signal ap_c2_a_changed(value: Vector2)
signal ap_c3_a_changed(value: Vector2)
signal apollonian_scale_b_changed(value: float)
signal ap_c1_b_changed(value: Vector2)
signal ap_c2_b_changed(value: Vector2)
signal ap_c3_b_changed(value: Vector2)
signal custom_tl_a_changed(index: int)
signal custom_tr_a_changed(index: int)
signal custom_bl_a_changed(index: int)
signal custom_br_a_changed(index: int)
signal custom_tl_b_changed(index: int)
signal custom_tr_b_changed(index: int)
signal custom_bl_b_changed(index: int)
signal custom_br_b_changed(index: int)
signal shape_selected(shape_index: int)
signal light_x_rot_changed(value: float)
signal light_y_rot_changed(value: float)
signal light_energy_changed(value: float)
signal light_color_changed(color: Color)
signal light_shadows_toggled(is_on: bool)
signal normal_strength_changed(value: float)
signal camera_dist_changed(value: float)
signal camera_x_rot_changed(value: float)
signal camera_y_rot_changed(value: float)
signal camera_fov_changed(value: float)
signal background_toggled(is_on: bool)

# --- Private Variables ---
var _expanded_size: Vector2
var _all_variations_data: Array[Dictionary] = []
var _rep_tile_variations: Array[Dictionary] = []
var _main_variations: Array[Dictionary] = []

var _ap_c1_a := Vector2.ZERO
var _ap_c2_a := Vector2.ZERO
var _ap_c3_a := Vector2.ZERO
var _ap_c1_b := Vector2.ZERO
var _ap_c2_b := Vector2.ZERO
var _ap_c3_b := Vector2.ZERO

var tl_stylebox := StyleBoxFlat.new()
var tr_stylebox := StyleBoxFlat.new()
var bl_stylebox := StyleBoxFlat.new()
var br_stylebox := StyleBoxFlat.new()

# --- Node References ---
# Main Layout
@onready var collapse_button: Button = %CollapseButton
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
@onready var var_b_mirror_x_check: CheckBox = %VarBMirrorXCheck
@onready var var_b_mirror_y_check: CheckBox = %VarBMirrorYCheck
@onready var var_b_kaleidoscope_slider: HSlider = %VarBKaleidoscopeSlicesSlider
@onready var post_mirror_x_check: CheckBox = %PostMirrorXCheck
@onready var post_mirror_y_check: CheckBox = %PostMirrorYCheck
@onready var post_kaleidoscope_master_check: CheckBox = %PostKaleidoscopeMasterCheck
@onready var post_kaleidoscope_slider: HSlider = %PostKaleidoscopeSlicesSlider

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
@onready var cellular_weave_threshold_slider_a: HSlider = %CellularWeaveThresholdSliderA
@onready var cellular_weave_iterations_slider_a: HSlider = %CellularWeaveIterationsSliderA
@onready var cellular_weave_grid_size_slider_b: HSlider = %CellularWeaveGridSizeSliderB
@onready var cellular_weave_threshold_slider_b: HSlider = %CellularWeaveThresholdSliderB
@onready var cellular_weave_iterations_slider_b: HSlider = %CellularWeaveIterationsSliderB
@onready var blur_amount_slider_a: HSlider = %BlurAmountSliderA
@onready var blur_amount_slider_b: HSlider = %BlurAmountSliderB
@onready var heart_scale_slider_a: HSlider = %HeartScaleSliderA
@onready var heart_rotation_slider_a: HSlider = %HeartRotationSliderA
@onready var heart_strength_slider_a: HSlider = %HeartStrengthSliderA
@onready var heart_scale_slider_b: HSlider = %HeartScaleSliderB
@onready var heart_rotation_slider_b: HSlider = %HeartRotationSliderB
@onready var heart_strength_slider_b: HSlider = %HeartStrengthSliderB
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

func _ready() -> void:
	self.borderless = true
	
	# --- Populate Dropdowns Programmatically ---
	_all_variations_data = VariationManager.get_variations_data()
	var_a_dropdown.clear()
	var_b_dropdown.clear()
	rep_tile_dropdown_a.clear()
	rep_tile_dropdown_b.clear()

	var has_rep_tiles = false
	for var_data in _all_variations_data:
		if var_data.get("category") == "Rep-Tile":
			_rep_tile_variations.append(var_data)
			has_rep_tiles = true
		else:
			_main_variations.append(var_data)

	for var_data in _main_variations:
		var_a_dropdown.add_item(var_data["name"])
		var_b_dropdown.add_item(var_data["name"])
	if has_rep_tiles:
		var_a_dropdown.add_item("Rep-Tiles")
		var_b_dropdown.add_item("Rep-Tiles")

	for var_data in _rep_tile_variations:
		rep_tile_dropdown_a.add_item(var_data["name"])
		rep_tile_dropdown_b.add_item(var_data["name"])
	# --- END Dropdown Population ---
		
	# --- Populate Other Dropdowns ---
	start_pattern_dropdown.add_item("Gradient + Grid"); start_pattern_dropdown.add_item("Circles"); start_pattern_dropdown.add_item("Image Input"); start_pattern_dropdown.add_item("Perlin Noise")
	resolution_dropdown.add_item("1K"); resolution_dropdown.add_item("2K"); resolution_dropdown.add_item("4K"); resolution_dropdown.add_item("8K")
	resolution_dropdown.select(1)
	wave_type_dropdown_a.add_item("Vertical"); wave_type_dropdown_a.add_item("Radial"); wave_type_dropdown_a.add_item("Square")
	wave_type_dropdown_b.add_item("Vertical"); wave_type_dropdown_b.add_item("Radial"); wave_type_dropdown_b.add_item("Square")
	gradient_controls_container.visible = false
	gradient_toggle_button.text = "► Gradient Controls"
	
	# --- Populate Custom 2x2 Dropdowns ---
	var transform_options = ["Identity", "Rotate +90", "Rotate 180", "Rotate -90", "Flip X", "Flip Y"]
	var dropdowns = [
		custom_tl_a, custom_tr_a, custom_bl_a, custom_br_a,
		custom_tl_b, custom_tr_b, custom_bl_b, custom_br_b
	]
	for dropdown in dropdowns:
		dropdown.clear()
		for option_name in transform_options:
			dropdown.add_item(option_name)
			
			
	# --- Populate Shape Selector ---
	shape_selector_button.add_item("Sphere") # Index 0
	shape_selector_button.add_item("Cube")   # Index 1
	shape_selector_button.add_item("Quad")   # Index 2 (Flat Plane)
	shape_selector_button.add_item("Prism")  # Index 3
	shape_selector_button.add_item("Torus")  # Index 4
	shape_selector_button.item_selected.connect(_on_shape_selector_item_selected)
	# --- END Shape Selector Setup ---

	update_contextual_ui_visibility() # Ensure this runs after dropdown setup if it affects visibility
	_is_initializing = false
	# --- Connect Signals ---
	# Connect NEW Dropdown Handlers
	var_a_dropdown.item_selected.connect(_on_main_dropdown_item_selected.bind(var_a_dropdown, rep_tile_dropdown_a))
	var_b_dropdown.item_selected.connect(_on_main_dropdown_item_selected.bind(var_b_dropdown, rep_tile_dropdown_b))
	rep_tile_dropdown_a.item_selected.connect(_on_rep_tile_dropdown_item_selected.bind(var_a_dropdown, rep_tile_dropdown_a, "a"))
	rep_tile_dropdown_b.item_selected.connect(_on_rep_tile_dropdown_item_selected.bind(var_b_dropdown, rep_tile_dropdown_b, "b"))

	# Connect other controls
	collapse_button.pressed.connect(_on_collapse_button_pressed)
	load_image_button.pressed.connect(load_image_button_pressed.emit)
	start_pattern_dropdown.item_selected.connect(_on_start_pattern_dropdown_item_selected)
	tiling_check_box.toggled.connect(_on_tiling_check_box_toggled)
	reset_on_drag_check.toggled.connect(_on_reset_on_drag_check_toggled)
	show_grid_check.toggled.connect(_on_show_grid_check_toggled)
	show_circles_check.toggled.connect(_on_show_circles_check_toggled)
	resolution_dropdown.item_selected.connect(_on_resolution_dropdown_item_selected)
	save_button.pressed.connect(_on_save_button_pressed)
	post_translate_radio.toggled.connect(_on_post_translate_toggled)
	pre_translate_radio.toggled.connect(_on_pre_translate_toggled)
	var_a_translate_radio.toggled.connect(_on_var_a_translate_toggled)
	var_b_translate_radio.toggled.connect(_on_var_b_translate_toggled)
	grad_col_tl_picker.color_changed.connect(_on_grad_col_tl_picker_color_changed)
	grad_col_tr_picker.color_changed.connect(_on_grad_col_tr_picker_color_changed)
	grad_col_bl_picker.color_changed.connect(_on_grad_col_bl_picker_color_changed)
	grad_col_br_picker.color_changed.connect(_on_grad_col_br_picker_color_changed)
	wave_type_dropdown_a.item_selected.connect(_on_wave_type_dropdown_a_item_selected)
	wave_type_dropdown_b.item_selected.connect(_on_wave_type_dropdown_b_item_selected)
	mirror_tiling_check_box.toggled.connect(mirror_tiling_changed.emit)
	gradient_toggle_button.pressed.connect(_on_gradient_toggle_button_pressed)
	
	save_preset_button.pressed.connect(save_preset_pressed.emit)
	load_preset_button.pressed.connect(load_preset_pressed.emit)
	copy_preset_button.pressed.connect(copy_preset_pressed.emit)
	paste_preset_button.pressed.connect(paste_preset_pressed.emit)
	
	# Connect Sliders/SpinBoxes
	var_mix_slider.value_changed.connect(variation_mix_changed.emit)
	var_mix_spinbox.value_changed.connect(_on_varmixslider_value_changed)
	feedback_amount_slider.value_changed.connect(feedback_amount_changed.emit)
	feedback_amount_slider.value_changed.connect(_on_feedbackamountslider_value_changed)
	feedback_amount_spinbox.value_changed.connect(_on_feedbackamountslider_value_changed)
	feedback_range_min_spinbox.value_changed.connect(feedback_range_min_changed.emit)
	feedback_range_max_spinbox.value_changed.connect(feedback_range_max_changed.emit)
	pre_scale_slider.value_changed.connect(pre_scale_changed.emit)
	pre_rotation_slider.value_changed.connect(pre_rotation_changed.emit)
	post_scale_slider.value_changed.connect(post_scale_changed.emit)
	post_rotation_slider.value_changed.connect(post_rotation_changed.emit)
	brightness_slider.value_changed.connect(brightness_changed.emit)
	contrast_slider.value_changed.connect(contrast_changed.emit)
	saturation_slider.value_changed.connect(saturation_changed.emit)
	circle_count_slider.value_changed.connect(circle_count_changed.emit)
	circle_radius_slider.value_changed.connect(circle_radius_changed.emit)
	circle_softness_slider.value_changed.connect(circle_softness_changed.emit)
	
	# Wave A
	wave_frequency_slider_a.value_changed.connect(wave_frequency_a_changed.emit)
	wave_amplitude_slider_a.value_changed.connect(wave_amplitude_a_changed.emit)
	wave_speed_slider_a.value_changed.connect(wave_speed_a_changed.emit)
	# Wave B
	wave_frequency_slider_b.value_changed.connect(wave_frequency_b_changed.emit)
	wave_amplitude_slider_b.value_changed.connect(wave_amplitude_b_changed.emit)
	wave_speed_slider_b.value_changed.connect(wave_speed_b_changed.emit)
	
	# Julian A
	julian_power_slider_a.value_changed.connect(julian_power_a_changed.emit)
	julian_dist_slider_a.value_changed.connect(julian_dist_a_changed.emit)
	julian_a_slider_a.value_changed.connect(julian_a_a_changed.emit)
	julian_b_slider_a.value_changed.connect(julian_b_a_changed.emit)
	julian_c_slider_a.value_changed.connect(julian_c_a_changed.emit)
	julian_d_slider_a.value_changed.connect(julian_d_a_changed.emit)
	julian_e_slider_a.value_changed.connect(julian_e_a_changed.emit)
	julian_f_slider_a.value_changed.connect(julian_f_a_changed.emit)
	# Julian B
	julian_power_slider_b.value_changed.connect(julian_power_b_changed.emit)
	julian_dist_slider_b.value_changed.connect(julian_dist_b_changed.emit)
	julian_a_slider_b.value_changed.connect(julian_a_b_changed.emit)
	julian_b_slider_b.value_changed.connect(julian_b_b_changed.emit)
	julian_c_slider_b.value_changed.connect(julian_c_b_changed.emit)
	julian_d_slider_b.value_changed.connect(julian_d_b_changed.emit)
	julian_e_slider_b.value_changed.connect(julian_e_b_changed.emit)
	julian_f_slider_b.value_changed.connect(julian_f_b_changed.emit)
	
	# Polar/Fisheye A
	fisheye_strength_slider_a.value_changed.connect(fisheye_strength_a_changed.emit)
	polar_offset_slider_a.value_changed.connect(polar_offset_a_changed.emit)
	# Polar/Fisheye B
	fisheye_strength_slider_b.value_changed.connect(fisheye_strength_b_changed.emit)
	polar_offset_slider_b.value_changed.connect(polar_offset_b_changed.emit)
	
	# Symmetry A
	var_a_mirror_x_check.toggled.connect(var_a_mirror_x_changed.emit)
	var_a_mirror_y_check.toggled.connect(var_a_mirror_y_changed.emit)
	var_a_kaleidoscope_slider.value_changed.connect(var_a_kaleidoscope_slices_changed.emit)
	# Symmetry B
	var_b_mirror_x_check.toggled.connect(var_b_mirror_x_changed.emit)
	var_b_mirror_y_check.toggled.connect(var_b_mirror_y_changed.emit)
	var_b_kaleidoscope_slider.value_changed.connect(var_b_kaleidoscope_slices_changed.emit)
	# Symmetry Post
	post_mirror_x_check.toggled.connect(mirror_x_changed.emit)
	post_mirror_y_check.toggled.connect(mirror_y_changed.emit)
	post_kaleidoscope_master_check.toggled.connect(_on_post_kaleidoscope_master_check_toggled)
	post_kaleidoscope_slider.value_changed.connect(kaleidoscope_slices_changed.emit)

	# Mobius A
	%MobiusReASliderA.value_changed.connect(mobius_re_a_a_changed.emit)
	%MobiusImASliderA.value_changed.connect(mobius_im_a_a_changed.emit)
	%MobiusReBSliderA.value_changed.connect(mobius_re_b_a_changed.emit)
	%MobiusImBSliderA.value_changed.connect(mobius_im_b_a_changed.emit)
	%MobiusReCSliderA.value_changed.connect(mobius_re_c_a_changed.emit)
	%MobiusImCSliderA.value_changed.connect(mobius_im_c_a_changed.emit)
	%MobiusReDSliderA.value_changed.connect(mobius_re_d_a_changed.emit)
	%MobiusImDSliderA.value_changed.connect(mobius_im_d_a_changed.emit)
	# Mobius B
	%MobiusReASliderB.value_changed.connect(mobius_re_a_b_changed.emit)
	%MobiusImASliderB.value_changed.connect(mobius_im_a_b_changed.emit)
	%MobiusReBSliderB.value_changed.connect(mobius_re_b_b_changed.emit)
	%MobiusImBSliderB.value_changed.connect(mobius_im_b_b_changed.emit)
	%MobiusReCSliderB.value_changed.connect(mobius_re_c_b_changed.emit)
	%MobiusImCSliderB.value_changed.connect(mobius_im_c_b_changed.emit)
	%MobiusReDSliderB.value_changed.connect(mobius_re_d_b_changed.emit)
	%MobiusImDSliderB.value_changed.connect(mobius_im_d_b_changed.emit)

	# Cellular Weave A
	cellular_weave_grid_size_slider_a.value_changed.connect(cellular_weave_grid_size_a_changed.emit)
	cellular_weave_threshold_slider_a.value_changed.connect(cellular_weave_threshold_a_changed.emit)
	cellular_weave_iterations_slider_a.value_changed.connect(cellular_weave_iterations_a_changed.emit)
	# Cellular Weave B
	cellular_weave_grid_size_slider_b.value_changed.connect(cellular_weave_grid_size_b_changed.emit)
	cellular_weave_threshold_slider_b.value_changed.connect(cellular_weave_threshold_b_changed.emit)
	cellular_weave_iterations_slider_b.value_changed.connect(cellular_weave_iterations_b_changed.emit)
	
	# Blur A/B
	blur_amount_slider_a.value_changed.connect(blur_amount_a_changed.emit)
	blur_amount_slider_b.value_changed.connect(blur_amount_b_changed.emit)
	
	# Heart A/B
	heart_scale_slider_a.value_changed.connect(heart_scale_a_changed.emit)
	heart_rotation_slider_a.value_changed.connect(heart_rotation_a_changed.emit)
	heart_strength_slider_a.value_changed.connect(heart_strength_a_changed.emit)
	heart_scale_slider_b.value_changed.connect(heart_scale_b_changed.emit)
	heart_rotation_slider_b.value_changed.connect(heart_rotation_b_changed.emit)
	heart_strength_slider_b.value_changed.connect(heart_strength_b_changed.emit)

	# Apollonian A/B
	apollonian_scale_slider_a.value_changed.connect(apollonian_scale_a_changed.emit)
	ap_c1x_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c1_a", v, "x"))
	ap_c1y_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c1_a", v, "y"))
	ap_c2x_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c2_a", v, "x"))
	ap_c2y_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c2_a", v, "y"))
	ap_c3x_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c3_a", v, "x"))
	ap_c3y_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c3_a", v, "y"))
	apollonian_scale_slider_b.value_changed.connect(apollonian_scale_b_changed.emit)
	ap_c1x_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c1_b", v, "x"))
	ap_c1y_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c1_b", v, "y"))
	ap_c2x_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c2_b", v, "x"))
	ap_c2y_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c2_b", v, "y"))
	ap_c3x_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c3_b", v, "x"))
	ap_c3y_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c3_b", v, "y"))
	
	custom_tl_a.item_selected.connect(custom_tl_a_changed.emit)
	custom_tr_a.item_selected.connect(custom_tr_a_changed.emit)
	custom_bl_a.item_selected.connect(custom_bl_a_changed.emit)
	custom_br_a.item_selected.connect(custom_br_a_changed.emit)
	custom_tl_b.item_selected.connect(custom_tl_b_changed.emit)
	custom_tr_b.item_selected.connect(custom_tr_b_changed.emit)
	custom_bl_b.item_selected.connect(custom_bl_b_changed.emit)
	custom_br_b.item_selected.connect(custom_br_b_changed.emit)


	# --- Configure Controls ---
	configure_control_pair(var_mix_slider, var_mix_spinbox, 0.0, 1.0, 0.01)
	configure_control_pair(feedback_amount_slider, feedback_amount_spinbox, 0.8, 1.0, 0.001)
	feedback_range_min_spinbox.min_value = -0.02; feedback_range_min_spinbox.max_value = 0.2; feedback_range_min_spinbox.step = 0.001 
	feedback_range_max_spinbox.min_value = 0.0; feedback_range_max_spinbox.max_value = 0.2; feedback_range_max_spinbox.step = 0.001 
	configure_control_pair(pre_scale_slider, pre_scale_spinbox, 0.1, 10.0, 0.01)
	configure_control_pair(pre_rotation_slider, pre_rotation_spinbox, -PI, PI, 0.01)
	configure_control_pair(post_scale_slider, post_scale_spinbox, 0.1, 10.0, 0.01)
	configure_control_pair(post_rotation_slider, post_rotation_spinbox, -PI, PI, 0.01)
	configure_control_pair(brightness_slider, brightness_spinbox, 0.0, 3.0, 0.01)
	configure_control_pair(contrast_slider, contrast_spinbox, 0.0, 3.0, 0.01)
	configure_control_pair(saturation_slider, saturation_spinbox, 0.0, 3.0, 0.01)
	configure_control_pair(circle_count_slider, circle_count_spinbox, 1.0, 20.0, 1.0)
	configure_control_pair(circle_radius_slider, circle_radius_spinbox, 0.0, 0.5, 0.01)
	configure_control_pair(circle_softness_slider, circle_softness_spinbox, 0.0, 0.1, 0.001)
	configure_control_pair(wave_frequency_slider_a, wave_frequency_spinbox_a, 0.0, 50.0, 0.1)
	configure_control_pair(wave_amplitude_slider_a, wave_amplitude_spinbox_a, 0.0, 0.5, 0.001)
	configure_control_pair(wave_speed_slider_a, wave_speed_spinbox_a, -5.0, 5.0, 0.1)
	configure_control_pair(wave_frequency_slider_b, wave_frequency_spinbox_b, 0.0, 50.0, 0.1)
	configure_control_pair(wave_amplitude_slider_b, wave_amplitude_spinbox_b, 0.0, 0.5, 0.001)
	configure_control_pair(wave_speed_slider_b, wave_speed_spinbox_b, -5.0, 5.0, 0.1)
	configure_control_pair(julian_power_slider_a, julian_power_spinbox_a, -5.0, 5.0, 0.01)
	configure_control_pair(julian_dist_slider_a, julian_dist_spinbox_a, 0.5, 2.0, 0.01)
	configure_control_pair(julian_a_slider_a, julian_a_spinbox_a, -2.0, 2.0, 0.01)
	configure_control_pair(julian_b_slider_a, julian_b_spinbox_a, -2.0, 2.0, 0.01)
	configure_control_pair(julian_c_slider_a, julian_c_spinbox_a, -2.0, 2.0, 0.01)
	configure_control_pair(julian_d_slider_a, julian_d_spinbox_a, -2.0, 2.0, 0.01)
	configure_control_pair(julian_e_slider_a, julian_e_spinbox_a, -2.0, 2.0, 0.01)
	configure_control_pair(julian_f_slider_a, julian_f_spinbox_a, -2.0, 2.0, 0.01)
	configure_control_pair(julian_power_slider_b, julian_power_spinbox_b, -5.0, 5.0, 0.01)
	configure_control_pair(julian_dist_slider_b, julian_dist_spinbox_b, 0.5, 2.0, 0.01)
	configure_control_pair(julian_a_slider_b, julian_a_spinbox_b, -2.0, 2.0, 0.01)
	configure_control_pair(julian_b_slider_b, julian_b_spinbox_b, -2.0, 2.0, 0.01)
	configure_control_pair(julian_c_slider_b, julian_c_spinbox_b, -2.0, 2.0, 0.01)
	configure_control_pair(julian_d_slider_b, julian_d_spinbox_b, -2.0, 2.0, 0.01)
	configure_control_pair(julian_e_slider_b, julian_e_spinbox_b, -2.0, 2.0, 0.01)
	configure_control_pair(julian_f_slider_b, julian_f_spinbox_b, -2.0, 2.0, 0.01)
	configure_control_pair(fisheye_strength_slider_a, fisheye_strength_spinbox_a, 0.0, 4.0, 0.01)
	configure_control_pair(polar_offset_slider_a, polar_offset_spinbox_a, -2.0, 2.0, 0.01)
	configure_control_pair(fisheye_strength_slider_b, fisheye_strength_spinbox_b, 0.0, 4.0, 0.01)
	configure_control_pair(polar_offset_slider_b, polar_offset_spinbox_b, -2.0, 2.0, 0.01)
	configure_control_pair(%VarAKaleidoscopeSlicesSlider, %VarAKaleidoscopeSlicesSpinBox, 2.0, 20.0, 1.0)
	configure_control_pair(%VarBKaleidoscopeSlicesSlider, %VarBKaleidoscopeSlicesSpinBox, 2.0, 20.0, 1.0)
	configure_control_pair(%PostKaleidoscopeSlicesSlider, %PostKaleidoscopeSlicesSpinBox, 2.0, 20.0, 1.0)
	configure_control_pair(%MobiusReASliderA, %MobiusReASpinBoxA, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusImASliderA, %MobiusImASpinBoxA, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusReBSliderA, %MobiusReBSpinBoxA, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusImBSliderA, %MobiusImBSpinBoxA, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusReCSliderA, %MobiusReCSpinBoxA, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusImCSliderA, %MobiusImCSpinBoxA, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusReDSliderA, %MobiusReDSpinBoxA, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusImDSliderA, %MobiusImDSpinBoxA, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusReASliderB, %MobiusReASpinBoxB, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusImASliderB, %MobiusImASpinBoxB, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusReBSliderB, %MobiusReBSpinBoxB, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusImBSliderB, %MobiusImBSpinBoxB, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusReCSliderB, %MobiusReCSpinBoxB, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusImCSliderB, %MobiusImCSpinBoxB, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusReDSliderB, %MobiusReDSpinBoxB, -2.0, 2.0, 0.01)
	configure_control_pair(%MobiusImDSliderB, %MobiusImDSpinBoxB, -2.0, 2.0, 0.01)
	configure_control_pair(%CellularWeaveGridSizeSliderA, %CellularWeaveGridSizeSpinBoxA, 2.0, 50.0, 1.0)
	configure_control_pair(%CellularWeaveThresholdSliderA, %CellularWeaveThresholdSpinBoxA, 0.0, 8.0, 1.0)
	configure_control_pair(%CellularWeaveIterationsSliderA, %CellularWeaveIterationsSpinBoxA, 1.0, 10.0, 1.0)
	configure_control_pair(%CellularWeaveGridSizeSliderB, %CellularWeaveGridSizeSpinBoxB, 2.0, 50.0, 1.0)
	configure_control_pair(%CellularWeaveThresholdSliderB, %CellularWeaveThresholdSpinBoxB, 0.0, 8.0, 1.0)
	configure_control_pair(%CellularWeaveIterationsSliderB, %CellularWeaveIterationsSpinBoxB, 1.0, 10.0, 1.0)
	configure_control_pair(%BlurAmountSliderA, %BlurAmountSpinBoxA, 0.0, 1.0, 0.01)
	configure_control_pair(%BlurAmountSliderB, %BlurAmountSpinBoxB, 0.0, 1.0, 0.01)
	configure_control_pair(%HeartScaleSliderA, %HeartScaleSpinBoxA, 0.1, 5.0, 0.01)
	configure_control_pair(%HeartRotationSliderA, %HeartRotationSpinBoxA, -180.0, 180.0, 1.0)
	configure_control_pair(%HeartStrengthSliderA, %HeartStrengthSpinBoxA, 0.0, 1.0, 0.01)
	configure_control_pair(%HeartScaleSliderB, %HeartScaleSpinBoxB, 0.1, 5.0, 0.01)
	configure_control_pair(%HeartRotationSliderB, %HeartRotationSpinBoxB, -180.0, 180.0, 1.0)
	configure_control_pair(%HeartStrengthSliderB, %HeartStrengthSpinBoxB, 0.0, 1.0, 0.01)
	configure_control_pair(apollonian_scale_slider_a, apollonian_scale_spinbox_a, 0.5, 3.0, 0.01)
	configure_control_pair(apollonian_scale_slider_b, apollonian_scale_spinbox_b, 0.5, 3.0, 0.01)
	
	# --- Configure 3D Controls ---
	configure_control_pair(%NormalStrengthSlider, normal_strength_spinbox, 0.0, 5.0, 0.01) # Use the ranges you set in the scene
	configure_control_pair(%LightXAngleSlider, light_x_angle_spinbox, -180.0, 180.0, 0.5)
	configure_control_pair(%LightYAngleSlider, light_y_angle_spinbox, -180.0, 180.0, 0.5)
	configure_control_pair(%LightEnergySlider, light_energy_spinbox, 0.0, 5.0, 0.01)
	configure_control_pair(%CameraDistSlider, camera_dist_spinbox, 0.5, 10.0, 0.1)
	configure_control_pair(%CameraXRotSlider, camera_x_rot_spinbox, -90.0, 90.0, 0.5)
	configure_control_pair(%CameraYRotSlider, camera_y_rot_spinbox, -180.0, 180.0, 0.5)
	configure_control_pair(%CameraFovSlider, camera_fov_spinbox, 30.0, 120.0, 1.0)
# --- END Configure 3D Controls ---

	var ap_min = -2.0; var ap_max = 2.0; var ap_step = 0.01
	ap_c1x_spinbox_a.min_value = ap_min; ap_c1x_spinbox_a.max_value = ap_max; ap_c1x_spinbox_a.step = ap_step
	ap_c1y_spinbox_a.min_value = ap_min; ap_c1y_spinbox_a.max_value = ap_max; ap_c1y_spinbox_a.step = ap_step
	ap_c2x_spinbox_a.min_value = ap_min; ap_c2x_spinbox_a.max_value = ap_max; ap_c2x_spinbox_a.step = ap_step
	ap_c2y_spinbox_a.min_value = ap_min; ap_c2y_spinbox_a.max_value = ap_max; ap_c2y_spinbox_a.step = ap_step
	ap_c3x_spinbox_a.min_value = ap_min; ap_c3x_spinbox_a.max_value = ap_max; ap_c3x_spinbox_a.step = ap_step
	ap_c3y_spinbox_a.min_value = ap_min; ap_c3y_spinbox_a.max_value = ap_max; ap_c3y_spinbox_a.step = ap_step
	ap_c1x_spinbox_b.min_value = ap_min; ap_c1x_spinbox_b.max_value = ap_max; ap_c1x_spinbox_b.step = ap_step
	ap_c1y_spinbox_b.min_value = ap_min; ap_c1y_spinbox_b.max_value = ap_max; ap_c1y_spinbox_b.step = ap_step
	ap_c2x_spinbox_b.min_value = ap_min; ap_c2x_spinbox_b.max_value = ap_max; ap_c2x_spinbox_b.step = ap_step
	ap_c2y_spinbox_b.min_value = ap_min; ap_c2y_spinbox_b.max_value = ap_max; ap_c2y_spinbox_b.step = ap_step
	ap_c3x_spinbox_b.min_value = ap_min; ap_c3x_spinbox_b.max_value = ap_max; ap_c3x_spinbox_b.step = ap_step
	ap_c3y_spinbox_b.min_value = ap_min; ap_c3y_spinbox_b.max_value = ap_max; ap_c3y_spinbox_b.step = ap_step


	# --- Color Picker Setup ---
	grad_col_tl_picker.add_theme_stylebox_override("normal", tl_stylebox)
	grad_col_tr_picker.add_theme_stylebox_override("normal", tr_stylebox)
	grad_col_bl_picker.add_theme_stylebox_override("normal", bl_stylebox)
	grad_col_br_picker.add_theme_stylebox_override("normal", br_stylebox)

	# --- Initial UI State ---
	_expanded_size = self.size
	scroll_container.visible = false
	var collapsed_height = collapse_button.size.y + 20
	self.size = Vector2(self.size.x, collapsed_height)
	collapse_button.text = "▼ Expand"
	post_mirror_controls.visible = true
	post_kaleidoscope_controls.visible = true
	
	
	%LightXAngleSlider.value_changed.connect(light_x_rot_changed.emit)
	%LightYAngleSlider.value_changed.connect(light_y_rot_changed.emit)
	%LightEnergySlider.value_changed.connect(light_energy_changed.emit)
	%LightColorPicker.color_changed.connect(light_color_changed.emit)
	%ShadowCheckBox.toggled.connect(light_shadows_toggled.emit)
	
	%NormalStrengthSlider.value_changed.connect(normal_strength_changed.emit)
	
	%CameraDistSlider.value_changed.connect(camera_dist_changed.emit)
	%CameraXRotSlider.value_changed.connect(camera_x_rot_changed.emit)
	%CameraYRotSlider.value_changed.connect(camera_y_rot_changed.emit)
	%CameraFovSlider.value_changed.connect(camera_fov_changed.emit)
	%BackgroundCheckBox.toggled.connect(background_toggled.emit)
	
	update_contextual_ui_visibility()

func configure_control_pair(slider: HSlider, spinbox: SpinBox, min_val: float, max_val: float, step_val: float) -> void:
	slider.min_value = min_val; slider.max_value = max_val; slider.step = step_val
	spinbox.min_value = min_val; spinbox.max_value = max_val; spinbox.step = step_val
	slider.value_changed.connect(spinbox.set_value)
	spinbox.value_changed.connect(slider.set_value)

# --- NEW: Helper to find item index by text ---
func _get_item_index_by_text(dropdown: OptionButton, text: String) -> int:
	for i in range(dropdown.item_count):
		if dropdown.get_item_text(i) == text:
			return i
	return -1 # Not found

# --- NEW: Helper to set dropdown selection safely ---
func _set_dropdown_selection(dropdown: OptionButton, text_to_select: String):
	var index = _get_item_index_by_text(dropdown, text_to_select)
	if index != -1:
		dropdown.select(index)
	elif dropdown.item_count > 0:
		dropdown.select(0) # Fallback to first item

# --- REPLACED FUNCTION ---
func initialize_ui(initial_values: Dictionary) -> void:
	# --- Handle Variation Dropdowns ---
	var var_a_id = initial_values.get("var_a_id", 0) # Expect ID
	var var_b_id = initial_values.get("var_b_id", 1) # Expect ID

	var found_a = false
	var found_b = false

	# Check Rep-Tiles First for A
	for i in range(rep_tile_dropdown_a.item_count):
		var rep_name = rep_tile_dropdown_a.get_item_text(i)
		if VariationManager.VARIATIONS.has(rep_name) and VariationManager.VARIATIONS[rep_name]["id"] == var_a_id:
			_set_dropdown_selection(var_a_dropdown, "Rep-Tiles")
			rep_tile_dropdown_a.select(i)
			found_a = true
			break
	# Check Main Variations for A
	if not found_a:
		for i in range(var_a_dropdown.item_count):
			var main_name = var_a_dropdown.get_item_text(i)
			if main_name != "Rep-Tiles" and VariationManager.VARIATIONS.has(main_name) and VariationManager.VARIATIONS[main_name]["id"] == var_a_id:
				var_a_dropdown.select(i)
				found_a = true
				break
	if not found_a and var_a_dropdown.item_count > 0: var_a_dropdown.select(0) # Fallback

	# Check Rep-Tiles First for B
	for i in range(rep_tile_dropdown_b.item_count):
		var rep_name = rep_tile_dropdown_b.get_item_text(i)
		if VariationManager.VARIATIONS.has(rep_name) and VariationManager.VARIATIONS[rep_name]["id"] == var_b_id:
			_set_dropdown_selection(var_b_dropdown, "Rep-Tiles")
			rep_tile_dropdown_b.select(i)
			found_b = true
			break
	# Check Main Variations for B
	if not found_b:
		for i in range(var_b_dropdown.item_count):
			var main_name = var_b_dropdown.get_item_text(i)
			if main_name != "Rep-Tiles" and VariationManager.VARIATIONS.has(main_name) and VariationManager.VARIATIONS[main_name]["id"] == var_b_id:
				var_b_dropdown.select(i)
				found_b = true
				break
	if not found_b and var_b_dropdown.item_count > 0: var_b_dropdown.select(1 if var_b_dropdown.item_count > 1 else 0) # Fallback
	
	# --- Update Feedback Controls ---
	# Get min/max values from the dictionary first
	var fb_min = initial_values.get("feedback_min", 0.8)
	var fb_max = initial_values.get("feedback_max", 1.0)
	
	# 1. Set the ranges for the MAIN slider/spinbox
	feedback_amount_slider.min_value = fb_min
	feedback_amount_spinbox.min_value = fb_min
	feedback_amount_slider.max_value = fb_max
	feedback_amount_spinbox.max_value = fb_max
	
	# 2. Set the VALUE of the main slider/spinbox
	feedback_amount_slider.value = initial_values.get("feedback", 0.98)
	
	# 3. Set the VALUE of the RANGE spinboxes
	feedback_range_min_spinbox.value = fb_min
	feedback_range_max_spinbox.value = fb_max
	# --- End Update ---
	

	
	# --- Initialize Other Controls ---
	start_pattern_dropdown.select(initial_values.get("start_pattern", 0))
	tiling_check_box.button_pressed = initial_values.get("tiling", true)
	mirror_tiling_check_box.button_pressed = initial_values.get("mirror_tiling", false)
	reset_on_drag_check.button_pressed = initial_values.get("reset_on_drag", true)
	show_grid_check.button_pressed = initial_values.get("show_grid", false)
	show_circles_check.button_pressed = initial_values.get("show_circles", true)
	post_translate_radio.button_pressed = initial_values.get("move_post", true)
	pre_translate_radio.button_pressed = initial_values.get("move_pre", false)
	var_a_translate_radio.button_pressed = initial_values.get("move_var_a", false)
	var_b_translate_radio.button_pressed = initial_values.get("move_var_b", false)
	var_mix_slider.value = initial_values.get("var_mix", 0.5)
	feedback_amount_slider.value = initial_values.get("feedback", 0.98)
	
	# Transforms
	pre_scale_slider.value = initial_values.get("pre_scale", 1.0)
	pre_rotation_slider.value = initial_values.get("pre_rot", 0.0)
	post_scale_slider.value = initial_values.get("post_scale", 0.995)
	post_rotation_slider.value = initial_values.get("post_rot", 0.0)
	
	# Color
	brightness_slider.value = initial_values.get("brightness", 1.0)
	contrast_slider.value = initial_values.get("contrast", 1.0)
	saturation_slider.value = initial_values.get("saturation", 1.0)
	grad_col_tl_picker.color = initial_values.get("grad_tl", Color.CYAN)
	tl_stylebox.bg_color = grad_col_tl_picker.color
	grad_col_tr_picker.color = initial_values.get("grad_tr", Color.YELLOW)
	tr_stylebox.bg_color = grad_col_tr_picker.color
	grad_col_bl_picker.color = initial_values.get("grad_bl", Color.BLUE)
	bl_stylebox.bg_color = grad_col_bl_picker.color
	grad_col_br_picker.color = initial_values.get("grad_br", Color.RED)
	br_stylebox.bg_color = grad_col_br_picker.color
	
	# Circles
	circle_count_slider.value = initial_values.get("circle_count", 4.0)
	circle_radius_slider.value = initial_values.get("circle_radius", 0.2)
	circle_softness_slider.value = initial_values.get("circle_softness", 0.05)

	# Waves
	wave_type_dropdown_a.select(initial_values.get("wave_type_a", 0))
	wave_frequency_slider_a.value = initial_values.get("wave_freq_a", 0.0)
	wave_amplitude_slider_a.value = initial_values.get("wave_amp_a", 0.1)
	wave_speed_slider_a.value = initial_values.get("wave_speed_a", 0.0)
	wave_type_dropdown_b.select(initial_values.get("wave_type_b", 0))
	wave_frequency_slider_b.value = initial_values.get("wave_freq_b", 5.0)
	wave_amplitude_slider_b.value = initial_values.get("wave_amp_b", 0.1)
	wave_speed_slider_b.value = initial_values.get("wave_speed_b", 0.0)
	
	# Julian A
	julian_power_slider_a.value = initial_values.get("julian_power_a", 2.0)
	julian_dist_slider_a.value = initial_values.get("julian_dist_a", 1.0)
	julian_a_slider_a.value = initial_values.get("julian_a_a", 1.0)
	julian_b_slider_a.value = initial_values.get("julian_b_a", 0.0)
	julian_c_slider_a.value = initial_values.get("julian_c_a", 0.0)
	julian_d_slider_a.value = initial_values.get("julian_d_a", 1.0)
	julian_e_slider_a.value = initial_values.get("julian_e_a", 0.0)
	julian_f_slider_a.value = initial_values.get("julian_f_a", 0.0)
	
	# Julian B
	julian_power_slider_b.value = initial_values.get("julian_power_b", -3.0)
	julian_dist_slider_b.value = initial_values.get("julian_dist_b", 1.0)
	julian_a_slider_b.value = initial_values.get("julian_a_b", 1.0)
	julian_b_slider_b.value = initial_values.get("julian_b_b", 0.0)
	julian_c_slider_b.value = initial_values.get("julian_c_b", 0.0)
	julian_d_slider_b.value = initial_values.get("julian_d_b", 1.0)
	julian_e_slider_b.value = initial_values.get("julian_e_b", 0.0)
	julian_f_slider_b.value = initial_values.get("julian_f_b", 0.0)
	
	# Polar/Fisheye
	fisheye_strength_slider_a.value = initial_values.get("fisheye_strength_a", 2.0)
	polar_offset_slider_a.value = initial_values.get("polar_offset_a", 1.0)
	fisheye_strength_slider_b.value = initial_values.get("fisheye_strength_b", 2.0)
	polar_offset_slider_b.value = initial_values.get("polar_offset_b", 1.0)
	
	# Mobius A
	%MobiusReASliderA.value = initial_values.get("mobius_re_a_a", 0.1)
	%MobiusImASliderA.value = initial_values.get("mobius_im_a_a", 0.2)
	%MobiusReBSliderA.value = initial_values.get("mobius_re_b_a", 0.2)
	%MobiusImBSliderA.value = initial_values.get("mobius_im_b_a", -0.12)
	%MobiusReCSliderA.value = initial_values.get("mobius_re_c_a", -0.15)
	%MobiusImCSliderA.value = initial_values.get("mobius_im_c_a", -0.15)
	%MobiusReDSliderA.value = initial_values.get("mobius_re_d_a", 0.21)
	%MobiusImDSliderA.value = initial_values.get("mobius_im_d_a", 0.1)
	# Mobius B
	%MobiusReASliderB.value = initial_values.get("mobius_re_a_b", 0.1)
	%MobiusImASliderB.value = initial_values.get("mobius_im_a_b", 0.2)
	%MobiusReBSliderB.value = initial_values.get("mobius_re_b_b", 0.2)
	%MobiusImBSliderB.value = initial_values.get("mobius_im_b_b", -0.12)
	%MobiusReCSliderB.value = initial_values.get("mobius_re_c_b", -0.15)
	%MobiusImCSliderB.value = initial_values.get("mobius_im_c_b", -0.15)
	%MobiusReDSliderB.value = initial_values.get("mobius_re_d_b", 0.21)
	%MobiusImDSliderB.value = initial_values.get("mobius_im_d_b", 0.1)
	
	# Heart A
	heart_scale_slider_a.value = initial_values.get("heart_scale_a", 0.3)
	heart_rotation_slider_a.value = initial_values.get("heart_rotation_a", 0.0)
	heart_strength_slider_a.value = initial_values.get("heart_strength_a", 0.5)
	# Heart B
	heart_scale_slider_b.value = initial_values.get("heart_scale_b", 0.3)
	heart_rotation_slider_b.value = initial_values.get("heart_rotation_b", 0.0)
	heart_strength_slider_b.value = initial_values.get("heart_strength_b", 0.5)
	
	# Apollonian A
	apollonian_scale_slider_a.value = initial_values.get("apollonian_scale_a", 1.5)
	var c1a = initial_values.get("ap_c1_a", Vector2(0.0, 0.5))
	_ap_c1_a = c1a
	ap_c1x_spinbox_a.value = c1a.x
	ap_c1y_spinbox_a.value = c1a.y
	var c2a = initial_values.get("ap_c2_a", Vector2(-0.433, -0.25))
	_ap_c2_a = c2a
	ap_c2x_spinbox_a.value = c2a.x
	ap_c2y_spinbox_a.value = c2a.y
	var c3a = initial_values.get("ap_c3_a", Vector2(0.433, -0.25))
	_ap_c3_a = c3a
	ap_c3x_spinbox_a.value = c3a.x
	ap_c3y_spinbox_a.value = c3a.y
	# Apollonian B
	apollonian_scale_slider_b.value = initial_values.get("apollonian_scale_b", 1.5)
	var c1b = initial_values.get("ap_c1_b", Vector2(0.0, 0.5))
	_ap_c1_b = c1b
	ap_c1x_spinbox_b.value = c1b.x
	ap_c1y_spinbox_b.value = c1b.y
	var c2b = initial_values.get("ap_c2_b", Vector2(-0.433, -0.25))
	_ap_c2_b = c2b
	ap_c2x_spinbox_b.value = c2b.x
	ap_c2y_spinbox_b.value = c2b.y
	var c3b = initial_values.get("ap_c3_b", Vector2(0.433, -0.25))
	_ap_c3_b = c3b
	ap_c3x_spinbox_b.value = c3b.x
	ap_c3y_spinbox_b.value = c3b.y
	
	# Initialize Custom 2x2 controls
	custom_tl_a.select(initial_values.get("custom_tl_a", 0))
	custom_tr_a.select(initial_values.get("custom_tr_a", 0))
	custom_bl_a.select(initial_values.get("custom_bl_a", 0))
	custom_br_a.select(initial_values.get("custom_br_a", 0))
	custom_tl_b.select(initial_values.get("custom_tl_b", 0))
	custom_tr_b.select(initial_values.get("custom_tr_b", 0))
	custom_bl_b.select(initial_values.get("custom_bl_b", 0))
	custom_br_b.select(initial_values.get("custom_br_b", 0))
	
	%LightXAngleSlider.set_value_no_signal(initial_values.get("light_x_rot", 77.0))
	%LightYAngleSlider.set_value_no_signal(initial_values.get("light_y_rot", 163.5))
	%LightEnergySlider.set_value_no_signal(initial_values.get("light_energy", 1.0))
	%LightColorPicker.color = initial_values.get("light_color", Color.WHITE)
	%ShadowCheckBox.set_pressed_no_signal(initial_values.get("light_shadows", true))
	
	%NormalStrengthSlider.set_value_no_signal(initial_values.get("normal_strength", 1.0))
	
	%CameraDistSlider.set_value_no_signal(initial_values.get("cam_dist", 2.5))
	%CameraXRotSlider.set_value_no_signal(initial_values.get("cam_x_rot", 0.0))
	%CameraYRotSlider.set_value_no_signal(initial_values.get("cam_y_rot", 0.0))
	%CameraFovSlider.set_value_no_signal(initial_values.get("cam_fov", 75.0))
	%BackgroundCheckBox.set_pressed_no_signal(initial_values.get("show_2d_bg", false))
	
	
	%LightXAngleSlider.set_value_no_signal(initial_values.get("light_x_rot", 77.0))
	light_x_angle_spinbox.set_value_no_signal(initial_values.get("light_x_rot", 77.0)) # <-- Add

	%LightYAngleSlider.set_value_no_signal(initial_values.get("light_y_rot", 163.5))
	light_y_angle_spinbox.set_value_no_signal(initial_values.get("light_y_rot", 163.5)) # <-- Add

	%LightEnergySlider.set_value_no_signal(initial_values.get("light_energy", 1.0))
	light_energy_spinbox.set_value_no_signal(initial_values.get("light_energy", 1.0)) # <-- Add

	%LightColorPicker.color = initial_values.get("light_color", Color.WHITE)
	%ShadowCheckBox.set_pressed_no_signal(initial_values.get("light_shadows", true))

	%NormalStrengthSlider.set_value_no_signal(initial_values.get("normal_strength", 1.0))
	normal_strength_spinbox.set_value_no_signal(initial_values.get("normal_strength", 1.0)) # <-- Add

	%CameraDistSlider.set_value_no_signal(initial_values.get("cam_dist", 2.5))
	camera_dist_spinbox.set_value_no_signal(initial_values.get("cam_dist", 2.5)) # <-- Add

	%CameraXRotSlider.set_value_no_signal(initial_values.get("cam_x_rot", 0.0))
	camera_x_rot_spinbox.set_value_no_signal(initial_values.get("cam_x_rot", 0.0)) # <-- Add

	%CameraYRotSlider.set_value_no_signal(initial_values.get("cam_y_rot", 0.0))
	camera_y_rot_spinbox.set_value_no_signal(initial_values.get("cam_y_rot", 0.0)) # <-- Add

	%CameraFovSlider.set_value_no_signal(initial_values.get("cam_fov", 75.0))
	camera_fov_spinbox.set_value_no_signal(initial_values.get("cam_fov", 75.0)) # <-- Add

	%BackgroundCheckBox.set_pressed_no_signal(initial_values.get("show_2d_bg", false))

	update_contextual_ui_visibility()

# --- REPLACED FUNCTION ---

func _on_shape_selector_item_selected(index: int):
	if _is_initializing: return # Prevent emission during setup
	emit_signal("shape_selected", index)
func update_contextual_ui_visibility() -> void:
	# --- Step 1: Hide ALL contextual panels first ---
	# This is the most important step to fix the bug
	wave_controls_container_a.visible = false
	julian_controls_container_a.visible = false
	polar_controls_container_a.visible = false
	fisheye_controls_container_a.visible = false
	var_a_mirror_controls.visible = false
	var_a_kaleidoscope_controls.visible = false
	mobius_controls_container_a.visible = false
	cellular_weave_controls_container_a.visible = false
	blur_controls_container_a.visible = false
	heart_controls_container_a.visible = false
	apollonian_controls_container_a.visible = false
	custom_2x2_controls_container_a.visible = false # <-- Hide custom controls
	
	wave_controls_container_b.visible = false
	julian_controls_container_b.visible = false
	polar_controls_container_b.visible = false
	fisheye_controls_container_b.visible = false
	var_b_mirror_controls.visible = false
	var_b_kaleidoscope_controls.visible = false
	mobius_controls_container_b.visible = false
	cellular_weave_controls_container_b.visible = false
	blur_controls_container_b.visible = false
	heart_controls_container_b.visible = false
	apollonian_controls_container_b.visible = false
	custom_2x2_controls_container_b.visible = false # <-- Hide custom controls

	rep_tile_panel_a.visible = false # Hide main rep-tile panel A
	rep_tile_panel_b.visible = false # Hide main rep-tile panel B
	
	
	# --- Step 2: Get the selected variation names ---
	var selected_name_a = var_a_dropdown.get_item_text(var_a_dropdown.selected)
	var selected_name_b = var_b_dropdown.get_item_text(var_b_dropdown.selected)
	var active_variation_name_a = selected_name_a
	var active_variation_name_b = selected_name_b

	# --- Handle Var A Visibility ---
	if selected_name_a == "Rep-Tiles":
		rep_tile_panel_a.visible = true # Show rep-tile panel A
		active_variation_name_a = rep_tile_dropdown_a.get_item_text(rep_tile_dropdown_a.selected)
	
	if VariationManager.VARIATIONS.has(active_variation_name_a):
		var controls_a = VariationManager.VARIATIONS[active_variation_name_a].get("controls")
		if controls_a != null:
			match controls_a:
				"wave": wave_controls_container_a.visible = true
				"julian": julian_controls_container_a.visible = true
				"polar": polar_controls_container_a.visible = true
				"fisheye": fisheye_controls_container_a.visible = true
				"mirror": var_a_mirror_controls.visible = true
				"kaleidoscope": var_a_kaleidoscope_controls.visible = true
				"mobius": mobius_controls_container_a.visible = true
				"cellular_weave": cellular_weave_controls_container_a.visible = true
				"blur": blur_controls_container_a.visible = true
				"heart": heart_controls_container_a.visible = true
				"apollonian": apollonian_controls_container_a.visible = true
				"custom_2x2": custom_2x2_controls_container_a.visible = true

	# --- Handle Var B Visibility ---
	if selected_name_b == "Rep-Tiles":
		rep_tile_panel_b.visible = true # Show rep-tile panel B
		active_variation_name_b = rep_tile_dropdown_b.get_item_text(rep_tile_dropdown_b.selected)

	if VariationManager.VARIATIONS.has(active_variation_name_b):
		var controls_b = VariationManager.VARIATIONS[active_variation_name_b].get("controls")
		if controls_b != null:
			match controls_b:
				"wave": wave_controls_container_b.visible = true
				"julian": julian_controls_container_b.visible = true
				"polar": polar_controls_container_b.visible = true
				"fisheye": fisheye_controls_container_b.visible = true
				"mirror": var_b_mirror_controls.visible = true
				"kaleidoscope": var_b_kaleidoscope_controls.visible = true
				"mobius": mobius_controls_container_b.visible = true
				"cellular_weave": cellular_weave_controls_container_b.visible = true
				"blur": blur_controls_container_b.visible = true
				"heart": heart_controls_container_b.visible = true
				"apollonian": apollonian_controls_container_b.visible = true
				"custom_2x2": custom_2x2_controls_container_b.visible = true

	# --- Handle Post-Processing and Start Pattern visibility ---
	
	post_kaleidoscope_options.visible = post_kaleidoscope_master_check.button_pressed
		
	# --- Start Pattern Controls Visibility ---
	show_grid_check.get_parent().visible = false
	circle_controls_container.visible = false
	load_image_button.visible = false
	gradient_toggle_button.visible = false
	gradient_controls_container.visible = false

	var start_mode = start_pattern_dropdown.selected
	match start_mode:
		0: # Gradient + Grid
			show_grid_check.get_parent().visible = true
			gradient_toggle_button.visible = true
			if gradient_toggle_button.text == "▼ Gradient Controls":
				gradient_controls_container.visible = true
		1: # Circles
			circle_controls_container.visible = true
		2: # Image Input
			load_image_button.visible = true
		3: # Perlin Noise
			pass # No controls

# --- NEW HELPER FUNCTION ---
func _update_ap_vec2(point_id: String, value: float, component: String):
	match point_id:
		"c1_a":
			if component == "x": _ap_c1_a.x = value
			else: _ap_c1_a.y = value
			ap_c1_a_changed.emit(_ap_c1_a)
		"c2_a":
			if component == "x": _ap_c2_a.x = value
			else: _ap_c2_a.y = value
			ap_c2_a_changed.emit(_ap_c2_a)
		"c3_a":
			if component == "x": _ap_c3_a.x = value
			else: _ap_c3_a.y = value
			ap_c3_a_changed.emit(_ap_c3_a)
		"c1_b":
			if component == "x": _ap_c1_b.x = value
			else: _ap_c1_b.y = value
			ap_c1_b_changed.emit(_ap_c1_b)
		"c2_b":
			if component == "x": _ap_c2_b.x = value
			else: _ap_c2_b.y = value
			ap_c2_b_changed.emit(_ap_c2_b)
		"c3_b":
			if component == "x": _ap_c3_b.x = value
			else: _ap_c3_b.y = value
			ap_c3_b_changed.emit(_ap_c3_b)

# --- NEW HANDLER ---
func _on_main_dropdown_item_selected(index: int, main_dropdown: OptionButton, rep_tile_dropdown: OptionButton) -> void:
	var selected_name = main_dropdown.get_item_text(index)
	var is_a = (main_dropdown == var_a_dropdown)

	if selected_name == "Rep-Tiles":
		var rep_tile_index = rep_tile_dropdown.selected
		var rep_tile_name = rep_tile_dropdown.get_item_text(rep_tile_index)
		for var_data in _rep_tile_variations:
			if var_data["name"] == rep_tile_name:
				if is_a:
					variation_a_changed.emit(var_data["id"])
				else:
					variation_b_changed.emit(var_data["id"])
				break
	else:
		for var_data in _main_variations:
			if var_data["name"] == selected_name:
				if is_a:
					variation_a_changed.emit(var_data["id"])
				else:
					variation_b_changed.emit(var_data["id"])
				break

	update_contextual_ui_visibility()

# --- NEW HANDLER ---
func _on_rep_tile_dropdown_item_selected(index: int, main_dropdown: OptionButton, rep_tile_dropdown: OptionButton, var_id: String) -> void:
	var main_selected_name = main_dropdown.get_item_text(main_dropdown.selected)
	if main_selected_name == "Rep-Tiles":
		var rep_tile_name = rep_tile_dropdown.get_item_text(index)
		for var_data in _rep_tile_variations:
			if var_data["name"] == rep_tile_name:
				if var_id == "a":
					variation_a_changed.emit(var_data["id"])
				else:
					variation_b_changed.emit(var_data["id"])
				break
	update_contextual_ui_visibility()

# --- Signal Emitters (OLD var_a/b removed) ---
func _on_start_pattern_dropdown_item_selected(index: int) -> void:
	emit_signal("start_pattern_changed", index)
	update_contextual_ui_visibility()

func _on_tiling_check_box_toggled(is_on: bool) -> void: emit_signal("seamless_tiling_changed", is_on)
func _on_reset_on_drag_check_toggled(is_on: bool) -> void: emit_signal("reset_on_drag_changed", is_on)
func _on_show_grid_check_toggled(is_on: bool) -> void: emit_signal("show_grid_toggled", is_on)
func _on_show_circles_check_toggled(is_on: bool) -> void: emit_signal("show_circles_toggled", is_on)
func _on_resolution_dropdown_item_selected(index: int) -> void: emit_signal("resolution_selected", index)
func _on_save_button_pressed() -> void: emit_signal("save_button_pressed")
func _on_post_translate_toggled(is_on: bool) -> void: emit_signal("post_translate_toggled", is_on)
func _on_pre_translate_toggled(is_on: bool) -> void: emit_signal("pre_translate_toggled", is_on)
func _on_var_a_translate_toggled(is_on: bool) -> void: emit_signal("var_a_translate_toggled", is_on)
func _on_var_b_translate_toggled(is_on: bool) -> void: emit_signal("var_b_translate_toggled", is_on)
func _on_wave_type_dropdown_a_item_selected(index: int) -> void: emit_signal("wave_type_a_changed", index)
func _on_wave_type_dropdown_b_item_selected(index: int) -> void: emit_signal("wave_type_b_changed", index)

# Simple signal emitters for sliders/spinboxes
func _on_varmixslider_value_changed(value: float) -> void:
	variation_mix_changed.emit(value)
func _on_feedbackamountslider_value_changed(value: float) -> void: emit_signal("feedback_amount_changed", value)
func _on_prescaleslider_value_changed(value: float) -> void: emit_signal("pre_scale_changed", value)
func _on_prerotationslider_value_changed(value: float) -> void: emit_signal("pre_rotation_changed", value)
func _on_postscaleslider_value_changed(value: float) -> void: emit_signal("post_scale_changed", value)
func _on_postrotationslider_value_changed(value: float) -> void: emit_signal("post_rotation_changed", value)
func _on_brightnessslider_value_changed(value: float) -> void: emit_signal("brightness_changed", value)
func _on_contrastslider_value_changed(value: float) -> void: emit_signal("contrast_changed", value)
func _on_saturationslider_value_changed(value: float) -> void: emit_signal("saturation_changed", value)
func _on_circlecountslider_value_changed(value: float) -> void: emit_signal("circle_count_changed", value)
func _on_circleradiusslider_value_changed(value: float) -> void: emit_signal("circle_radius_changed", value)
func _on_circlesoftnessslider_value_changed(value: float) -> void: emit_signal("circle_softness_changed", value)
func _on_wavefrequencyslidera_value_changed(value: float) -> void: emit_signal("wave_frequency_a_changed", value)
func _on_waveamplitudeslidera_value_changed(value: float) -> void: emit_signal("wave_amplitude_a_changed", value)
func _on_wavespeedslidera_value_changed(value: float) -> void: emit_signal("wave_speed_a_changed", value)
func _on_wavefrequencysliderb_value_changed(value: float) -> void: emit_signal("wave_frequency_b_changed", value)
func _on_waveamplitudesliderb_value_changed(value: float) -> void: emit_signal("wave_amplitude_b_changed", value)
func _on_wavespeedsliderb_value_changed(value: float) -> void: emit_signal("wave_speed_b_changed", value)
func _on_julianpowerslidera_value_changed(value: float) -> void: emit_signal("julian_power_a_changed", value)
func _on_juliandistslidera_value_changed(value: float) -> void: emit_signal("julian_dist_a_changed", value)
func _on_julianaslidera_value_changed(value: float) -> void: emit_signal("julian_a_a_changed", value)
func _on_julianbslidera_value_changed(value: float) -> void: emit_signal("julian_b_a_changed", value)
func _on_juliancslidera_value_changed(value: float) -> void: emit_signal("julian_c_a_changed", value)
func _on_juliandslidera_value_changed(value: float) -> void: emit_signal("julian_d_a_changed", value)
func _on_julianeslidera_value_changed(value: float) -> void: emit_signal("julian_e_a_changed", value)
func _on_julianfslidera_value_changed(value: float) -> void: emit_signal("julian_f_a_changed", value)
func _on_julianpowersliderb_value_changed(value: float) -> void: emit_signal("julian_power_b_changed", value)
func _on_juliandistsliderb_value_changed(value: float) -> void: emit_signal("julian_dist_b_changed", value)
func _on_julianasliderb_value_changed(value: float) -> void: emit_signal("julian_a_b_changed", value)
func _on_julianbsliderb_value_changed(value: float) -> void: emit_signal("julian_b_b_changed", value)
func _on_juliancsliderb_value_changed(value: float) -> void: emit_signal("julian_c_b_changed", value)

func _on_juliandsliderb_value_changed(value: float) -> void: emit_signal("julian_d_b_changed", value)
func _on_julianesliderb_value_changed(value: float) -> void: emit_signal("julian_e_b_changed", value)
func _on_julianfsliderb_value_changed(value: float) -> void: emit_signal("julian_f_b_changed", value)
func _on_fisheyestrengthslidera_value_changed(value: float) -> void: emit_signal("fisheye_strength_a_changed", value)
func _on_polaroffsetslidera_value_changed(value: float) -> void: emit_signal("polar_offset_a_changed", value)
func _on_fisheyestrengthsliderb_value_changed(value: float) -> void: emit_signal("fisheye_strength_b_changed", value)
func _on_polaroffsetsliderb_value_changed(value: float) -> void: emit_signal("polar_offset_b_changed", value)
func _on_kaleidoscopeslicesslider_value_changed(value: float) -> void: emit_signal("kaleidoscope_slices_changed", value)


func _on_grad_col_tl_picker_color_changed(color: Color) -> void:
	tl_stylebox.bg_color = color
	emit_signal("grad_col_tl_changed", color)

func _on_grad_col_tr_picker_color_changed(color: Color) -> void:
	tr_stylebox.bg_color = color
	emit_signal("grad_col_tr_changed", color)

func _on_grad_col_bl_picker_color_changed(color: Color) -> void:
	bl_stylebox.bg_color = color
	emit_signal("grad_col_bl_changed", color)

func _on_grad_col_br_picker_color_changed(color: Color) -> void:
	br_stylebox.bg_color = color
	emit_signal("grad_col_br_changed", color)

func _on_gradient_toggle_button_pressed() -> void:
	gradient_controls_container.visible = not gradient_controls_container.visible
	if gradient_controls_container.visible:
		gradient_toggle_button.text = "▼ Gradient Controls"
	else:
		gradient_toggle_button.text = "► Gradient Controls"
		
func _on_collapse_button_pressed() -> void:
	scroll_container.visible = not scroll_container.visible
	if scroll_container.visible:
		self.size = _expanded_size
		collapse_button.text = "▲ Collapse"
	else:
		_expanded_size = self.size
		var collapsed_height = collapse_button.size.y + 20
		self.size = Vector2(self.size.x, collapsed_height)
		collapse_button.text = "▼ Expand"

func _on_post_mirror_master_check_toggled(is_on: bool) -> void:
	emit_signal("mirror_x_changed", is_on and post_mirror_x_check.button_pressed)
	emit_signal("mirror_y_changed", is_on and post_mirror_y_check.button_pressed)
	update_contextual_ui_visibility()

func _on_post_kaleidoscope_master_check_toggled(is_on: bool) -> void:
	emit_signal("kaleidoscope_changed", is_on)
	update_contextual_ui_visibility()
