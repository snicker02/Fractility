class_name UIController
extends Window

# --- Signals ---
signal variation_a_changed(index: int)
signal variation_b_changed(index: int)
signal start_pattern_changed(index: int)
signal variation_mix_changed(value: float)
signal feedback_amount_changed(value: float)
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

# Wave Signals
signal wave_type_a_changed(index: int)
signal wave_frequency_a_changed(value: float)
signal wave_amplitude_a_changed(value: float)
signal wave_speed_a_changed(value: float)
signal wave_type_b_changed(index: int)
signal wave_frequency_b_changed(value: float)
signal wave_amplitude_b_changed(value: float)
signal wave_speed_b_changed(value: float)

# Julian A Signals
signal julian_power_a_changed(value: float)
signal julian_dist_a_changed(value: float)
signal julian_a_a_changed(value: float)
signal julian_b_a_changed(value: float)
signal julian_c_a_changed(value: float)
signal julian_d_a_changed(value: float)
signal julian_e_a_changed(value: float)
signal julian_f_a_changed(value: float)

# Julian B Signals
signal julian_power_b_changed(value: float)
signal julian_dist_b_changed(value: float)
signal julian_a_b_changed(value: float)
signal julian_b_b_changed(value: float)
signal julian_c_b_changed(value: float)
signal julian_d_b_changed(value: float)
signal julian_e_b_changed(value: float)
signal julian_f_b_changed(value: float)

# Polar/Fisheye Signals
signal fisheye_strength_a_changed(value: float)
signal polar_offset_a_changed(value: float)
signal fisheye_strength_b_changed(value: float)
signal polar_offset_b_changed(value: float)

# --- Post-Processing Symmetry Signals ---
signal mirror_x_changed(is_on: bool)
signal mirror_y_changed(is_on: bool)
signal kaleidoscope_changed(is_on: bool)
signal kaleidoscope_slices_changed(value: float)

# --- Variation A Symmetry Signals ---
signal var_a_mirror_x_changed(is_on: bool)
signal var_a_mirror_y_changed(is_on: bool)
signal var_a_kaleidoscope_slices_changed(value: float)

# --- Variation B Symmetry Signals ---
signal var_b_mirror_x_changed(is_on: bool)
signal var_b_mirror_y_changed(is_on: bool)
signal var_b_kaleidoscope_slices_changed(value: float)
# --- Add signals for Mobius A ---
signal mobius_re_a_a_changed(value: float)
signal mobius_im_a_a_changed(value: float)
signal mobius_re_b_a_changed(value: float)
signal mobius_im_b_a_changed(value: float)
signal mobius_re_c_a_changed(value: float)
signal mobius_im_c_a_changed(value: float)
signal mobius_re_d_a_changed(value: float)
signal mobius_im_d_a_changed(value: float)
# --- Add signals for Mobius B ---
signal mobius_re_a_b_changed(value: float)
signal mobius_im_a_b_changed(value: float)
signal mobius_re_b_b_changed(value: float)
signal mobius_im_b_b_changed(value: float)
signal mobius_re_c_b_changed(value: float)
signal mobius_im_c_b_changed(value: float)
signal mobius_re_d_b_changed(value: float)
signal mobius_im_d_b_changed(value: float)

# ADD new signals for Cellular Weave
signal cellular_weave_grid_size_a_changed(value: float)
signal cellular_weave_threshold_a_changed(value: float)
signal cellular_weave_iterations_a_changed(value: float)
signal cellular_weave_grid_size_b_changed(value: float)
signal cellular_weave_threshold_b_changed(value: float)
signal cellular_weave_iterations_b_changed(value: float)

# --- Add signals for Blur ---
signal blur_amount_a_changed(value: float)
signal blur_amount_b_changed(value: float)

# --- Add signals for Heart ---
signal heart_scale_a_changed(value: float)
signal heart_rotation_a_changed(value: float)
signal heart_strength_a_changed(value: float)
signal heart_scale_b_changed(value: float)
signal heart_rotation_b_changed(value: float)
signal heart_strength_b_changed(value: float)

signal apollonian_scale_a_changed(value: float)
signal ap_c1_a_changed(value: Vector2) # <-- ADD Vec2 signal
signal ap_c2_a_changed(value: Vector2) # <-- ADD Vec2 signal
signal ap_c3_a_changed(value: Vector2) # <-- ADD Vec2 signal
signal apollonian_scale_b_changed(value: float)
signal ap_c1_b_changed(value: Vector2) # <-- ADD Vec2 signal
signal ap_c2_b_changed(value: Vector2) # <-- ADD Vec2 signal
signal ap_c3_b_changed(value: Vector2) # <-- ADD Vec2 signal
# --- Private Variables ---
var _expanded_size: Vector2

# --- Node References ---
# Main Layout
@onready var collapse_button: Button = %CollapseButton
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var load_image_button: Button = %LoadImageButton
@onready var mirror_tiling_check_box: CheckBox = %MirrorTilingCheckBox
# Main Controls
@onready var var_a_dropdown: OptionButton = %VarADropdown
@onready var var_b_dropdown: OptionButton = %VarBDropdown
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

# Symmetry Control Containers
@onready var var_a_mirror_controls: VBoxContainer = %VarAMirrorControlsContainer
@onready var var_a_kaleidoscope_controls: VBoxContainer = %VarAKaleidoscopeControlsContainer
@onready var var_b_mirror_controls: VBoxContainer = %VarBMirrorControlsContainer
@onready var var_b_kaleidoscope_controls: VBoxContainer = %VarBKaleidoscopeControlsContainer
@onready var post_mirror_controls: VBoxContainer = %PostMirrorControlsContainer
@onready var post_kaleidoscope_controls: VBoxContainer = %PostKaleidoscopeControlsContainer
@onready var post_mirror_options: HBoxContainer = %PostMirrorOptions
@onready var post_kaleidoscope_options: HBoxContainer = %PostKaleidoscopeOptions

# Variation A Symmetry Controls
@onready var var_a_mirror_x_check: CheckBox = %VarAMirrorXCheck
@onready var var_a_mirror_y_check: CheckBox = %VarAMirrorYCheck
@onready var var_a_kaleidoscope_slider: HSlider = %VarAKaleidoscopeSlicesSlider

# Variation B Symmetry Controls
@onready var var_b_mirror_x_check: CheckBox = %VarBMirrorXCheck
@onready var var_b_mirror_y_check: CheckBox = %VarBMirrorYCheck
@onready var var_b_kaleidoscope_slider: HSlider = %VarBKaleidoscopeSlicesSlider

# Post-Processing Symmetry Controls

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

@onready var mobius_controls_container_a: VBoxContainer = %MobiusControlsContainerA
@onready var mobius_controls_container_b: VBoxContainer = %MobiusControlsContainerB
@onready var mobius_re_a_slider_a: HSlider = %MobiusReASliderA
@onready var mobius_im_a_slider_a: HSlider = %MobiusImASliderA
@onready var mobius_re_b_slider_a: HSlider = %MobiusReBSliderA
@onready var mobius_im_b_slider_a: HSlider = %MobiusImBSliderA
@onready var mobius_re_c_slider_a: HSlider = %MobiusReCSliderA
@onready var mobius_im_c_slider_a: HSlider = %MobiusImCSliderA
@onready var mobius_re_d_slider_a: HSlider = %MobiusReDSliderA
@onready var mobius_im_d_slider_a: HSlider = %MobiusImDSliderA
@onready var mobius_re_a_slider_b: HSlider = %MobiusReASliderB
@onready var mobius_im_a_slider_b: HSlider = %MobiusImASliderB
@onready var mobius_re_b_slider_b: HSlider = %MobiusReBSliderB
@onready var mobius_im_b_slider_b: HSlider = %MobiusImBSliderB
@onready var mobius_re_c_slider_b: HSlider = %MobiusReCSliderB
@onready var mobius_im_c_slider_b: HSlider = %MobiusImCSliderB
@onready var mobius_re_d_slider_b: HSlider = %MobiusReDSliderB
@onready var mobius_im_d_slider_b: HSlider = %MobiusImDSliderB

@onready var cellular_weave_controls_container_a: VBoxContainer = %CellularWeaveControlsContainerA
@onready var cellular_weave_controls_container_b: VBoxContainer = %CellularWeaveControlsContainerB
@onready var cellular_weave_grid_size_slider_a: HSlider = %CellularWeaveGridSizeSliderA
@onready var cellular_weave_threshold_slider_a: HSlider = %CellularWeaveThresholdSliderA
@onready var cellular_weave_iterations_slider_a: HSlider = %CellularWeaveIterationsSliderA

@onready var cellular_weave_grid_size_slider_b: HSlider = %CellularWeaveGridSizeSliderB
@onready var cellular_weave_threshold_slider_b: HSlider = %CellularWeaveThresholdSliderB
@onready var cellular_weave_iterations_slider_b: HSlider = %CellularWeaveIterationsSliderB

@onready var blur_controls_container_a: VBoxContainer = %BlurControlsContainerA
@onready var blur_controls_container_b: VBoxContainer = %BlurControlsContainerB
@onready var blur_amount_slider_a: HSlider = %BlurAmountSliderA
@onready var blur_amount_slider_b: HSlider = %BlurAmountSliderB

@onready var heart_controls_container_a: VBoxContainer = %HeartControlsContainerA
@onready var heart_controls_container_b: VBoxContainer = %HeartControlsContainerB
@onready var heart_scale_slider_a: HSlider = %HeartScaleSliderA
@onready var heart_rotation_slider_a: HSlider = %HeartRotationSliderA
@onready var heart_strength_slider_a: HSlider = %HeartStrengthSliderA
@onready var heart_scale_slider_b: HSlider = %HeartScaleSliderB
@onready var heart_rotation_slider_b: HSlider = %HeartRotationSliderB
@onready var heart_strength_slider_b: HSlider = %HeartStrengthSliderB

@onready var apollonian_controls_container_a: VBoxContainer = %ApollonianControlsContainerA
@onready var apollonian_scale_slider_a: HSlider = %ApollonianScaleSliderA
@onready var apollonian_scale_spinbox_a: SpinBox = %ApollonianScaleSpinBoxA
@onready var ap_c1x_spinbox_a: SpinBox = %ApC1XSpinBoxA # <-- ADD
@onready var ap_c1y_spinbox_a: SpinBox = %ApC1YSpinBoxA # <-- ADD
@onready var ap_c2x_spinbox_a: SpinBox = %ApC2XSpinBoxA # <-- ADD
@onready var ap_c2y_spinbox_a: SpinBox = %ApC2YSpinBoxA # <-- ADD
@onready var ap_c3x_spinbox_a: SpinBox = %ApC3XSpinBoxA # <-- ADD
@onready var ap_c3y_spinbox_a: SpinBox = %ApC3YSpinBoxA # <-- ADD

@onready var apollonian_controls_container_b: VBoxContainer = %ApollonianControlsContainerB
@onready var apollonian_scale_slider_b: HSlider = %ApollonianScaleSliderB
@onready var apollonian_scale_spinbox_b: SpinBox = %ApollonianScaleSpinBoxB
@onready var ap_c1x_spinbox_b: SpinBox = %ApC1XSpinBoxB # <-- ADD
@onready var ap_c1y_spinbox_b: SpinBox = %ApC1YSpinBoxB # <-- ADD
@onready var ap_c2x_spinbox_b: SpinBox = %ApC2XSpinBoxB # <-- ADD
@onready var ap_c2y_spinbox_b: SpinBox = %ApC2YSpinBoxB # <-- ADD
@onready var ap_c3x_spinbox_b: SpinBox = %ApC3XSpinBoxB # <-- ADD
@onready var ap_c3y_spinbox_b: SpinBox = %ApC3YSpinBoxB # <-- ADD

# --- Temporary storage for Vector2 signals ---
var _ap_c1_a := Vector2.ZERO
var _ap_c2_a := Vector2.ZERO
var _ap_c3_a := Vector2.ZERO
var _ap_c1_b := Vector2.ZERO
var _ap_c2_b := Vector2.ZERO
var _ap_c3_b := Vector2.ZERO

# Styleboxes for Color Pickers
var tl_stylebox := StyleBoxFlat.new()
var tr_stylebox := StyleBoxFlat.new()
var bl_stylebox := StyleBoxFlat.new()
var br_stylebox := StyleBoxFlat.new()

# Sliders & SpinBoxes (Grouped by name)
@onready var var_mix_slider: HSlider = %VarMixSlider
@onready var var_mix_spinbox: SpinBox = %VarMixSpinBox
@onready var feedback_amount_slider: HSlider = %FeedbackAmountSlider
@onready var feedback_amount_spinbox: SpinBox = %FeedbackAmountSpinBox
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


func _ready() -> void:
	self.borderless = true
	
	
	# --- NEW: Populate Dropdowns Programmatically ---
	var sorted_names = VariationManager.get_sorted_variation_names()
	for variation_name in sorted_names:
		var_a_dropdown.add_item(variation_name)
		var_b_dropdown.add_item(variation_name)
		
	# --- Populate Dropdowns ---
	start_pattern_dropdown.add_item("Gradient + Grid"); start_pattern_dropdown.add_item("Circles"); start_pattern_dropdown.add_item("Image Input"); start_pattern_dropdown.add_item("Perlin Noise")
	resolution_dropdown.add_item("1K"); resolution_dropdown.add_item("2K"); resolution_dropdown.add_item("4K"); resolution_dropdown.add_item("8K")
	resolution_dropdown.select(1)
	wave_type_dropdown_a.add_item("Vertical"); wave_type_dropdown_a.add_item("Radial"); wave_type_dropdown_a.add_item("Square")
	wave_type_dropdown_b.add_item("Vertical"); wave_type_dropdown_b.add_item("Radial"); wave_type_dropdown_b.add_item("Square")
	gradient_controls_container.visible = false
	gradient_toggle_button.text = "► Gradient Controls"

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


	save_preset_button.pressed.connect(save_preset_pressed.emit)
	load_preset_button.pressed.connect(load_preset_pressed.emit)
	copy_preset_button.pressed.connect(copy_preset_pressed.emit)
	paste_preset_button.pressed.connect(paste_preset_pressed.emit)

	apollonian_scale_slider_a.value_changed.connect(apollonian_scale_a_changed.emit)
	ap_c1x_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c1_a", v, "x")) # <-- ADD
	ap_c1y_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c1_a", v, "y")) # <-- ADD
	ap_c2x_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c2_a", v, "x")) # <-- ADD
	ap_c2y_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c2_a", v, "y")) # <-- ADD
	ap_c3x_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c3_a", v, "x")) # <-- ADD
	ap_c3y_spinbox_a.value_changed.connect(func(v): _update_ap_vec2("c3_a", v, "y")) # <-- ADD

	apollonian_scale_slider_b.value_changed.connect(apollonian_scale_b_changed.emit)
	ap_c1x_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c1_b", v, "x")) # <-- ADD
	ap_c1y_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c1_b", v, "y")) # <-- ADD
	ap_c2x_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c2_b", v, "x")) # <-- ADD
	ap_c2y_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c2_b", v, "y")) # <-- ADD
	ap_c3x_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c3_b", v, "x")) # <-- ADD
	ap_c3y_spinbox_b.value_changed.connect(func(v): _update_ap_vec2("c3_b", v, "y")) # <-- ADD 

	# --- Configure Controls ---
	configure_control_pair(var_mix_slider, var_mix_spinbox, 0.0, 1.0, 0.01)
	configure_control_pair(feedback_amount_slider, feedback_amount_spinbox, 0.8, 1.0, 0.001)
	configure_control_pair(pre_scale_slider, pre_scale_spinbox, 0.1, 10.0, 0.01)
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
	cellular_weave_grid_size_slider_a.value_changed.connect(cellular_weave_grid_size_a_changed.emit)
	cellular_weave_threshold_slider_a.value_changed.connect(cellular_weave_threshold_a_changed.emit)
	cellular_weave_iterations_slider_a.value_changed.connect(cellular_weave_iterations_a_changed.emit)
	cellular_weave_grid_size_slider_b.value_changed.connect(cellular_weave_grid_size_b_changed.emit)
	cellular_weave_threshold_slider_b.value_changed.connect(cellular_weave_threshold_b_changed.emit)
	cellular_weave_iterations_slider_b.value_changed.connect(cellular_weave_iterations_b_changed.emit)
	configure_control_pair(%BlurAmountSliderA, %BlurAmountSpinBoxA, 0.0, 1.0, 0.01)
	configure_control_pair(%BlurAmountSliderB, %BlurAmountSpinBoxB, 0.0, 1.0, 0.01)
	configure_control_pair(%HeartScaleSliderA, %HeartScaleSpinBoxA, 0.1, 5.0, 0.01)
	configure_control_pair(%HeartRotationSliderA, %HeartRotationSpinBoxA, -180.0, 180.0, 1.0)
	configure_control_pair(%HeartStrengthSliderA, %HeartStrengthSpinBoxA, 0.0, 1.0, 0.01)
	configure_control_pair(%HeartScaleSliderB, %HeartScaleSpinBoxB, 0.1, 5.0, 0.01)
	configure_control_pair(%HeartRotationSliderB, %HeartRotationSpinBoxB, -180.0, 180.0, 1.0)
	configure_control_pair(%HeartStrengthSliderB, %HeartStrengthSpinBoxB, 0.0, 1.0, 0.01)
	configure_control_pair(apollonian_scale_slider_a, apollonian_scale_spinbox_a, 0.5, 3.0, 0.01) # Expanded range
	configure_control_pair(apollonian_scale_slider_b, apollonian_scale_spinbox_b, 0.5, 3.0, 0.01)

	var ap_min = -2.0
	var ap_max = 2.0
	var ap_step = 0.01
	ap_c1x_spinbox_a.min_value = ap_min; ap_c1x_spinbox_a.max_value = ap_max; ap_c1x_spinbox_a.step = ap_step # <-- ADD config
	ap_c1y_spinbox_a.min_value = ap_min; ap_c1y_spinbox_a.max_value = ap_max; ap_c1y_spinbox_a.step = ap_step # <-- ADD config
	ap_c2x_spinbox_a.min_value = ap_min; ap_c2x_spinbox_a.max_value = ap_max; ap_c2x_spinbox_a.step = ap_step # <-- ADD config
	ap_c2y_spinbox_a.min_value = ap_min; ap_c2y_spinbox_a.max_value = ap_max; ap_c2y_spinbox_a.step = ap_step # <-- ADD config
	ap_c3x_spinbox_a.min_value = ap_min; ap_c3x_spinbox_a.max_value = ap_max; ap_c3x_spinbox_a.step = ap_step # <-- ADD config
	ap_c3y_spinbox_a.min_value = ap_min; ap_c3y_spinbox_a.max_value = ap_max; ap_c3y_spinbox_a.step = ap_step # <-- ADD config
	# Repeat config for B SpinBoxes...
	ap_c1x_spinbox_b.min_value = ap_min; ap_c1x_spinbox_b.max_value = ap_max; ap_c1x_spinbox_b.step = ap_step # <-- ADD config
	ap_c1y_spinbox_b.min_value = ap_min; ap_c1y_spinbox_b.max_value = ap_max; ap_c1y_spinbox_b.step = ap_step # <-- ADD config
	ap_c2x_spinbox_b.min_value = ap_min; ap_c2x_spinbox_b.max_value = ap_max; ap_c2x_spinbox_b.step = ap_step # <-- ADD config
	ap_c2y_spinbox_b.min_value = ap_min; ap_c2y_spinbox_b.max_value = ap_max; ap_c2y_spinbox_b.step = ap_step # <-- ADD config
	ap_c3x_spinbox_b.min_value = ap_min; ap_c3x_spinbox_b.max_value = ap_max; ap_c3x_spinbox_b.step = ap_step # <-- ADD config
	ap_c3y_spinbox_b.min_value = ap_min; ap_c3y_spinbox_b.max_value = ap_max; ap_c3y_spinbox_b.step = ap_step # <-- ADD config



	# --- Color Picker Setup ---
	grad_col_tl_picker.add_theme_stylebox_override("normal", tl_stylebox)
	grad_col_tr_picker.add_theme_stylebox_override("normal", tr_stylebox)
	grad_col_bl_picker.add_theme_stylebox_override("normal", bl_stylebox)
	grad_col_br_picker.add_theme_stylebox_override("normal", br_stylebox)

	# --- Connect Signals ---
	collapse_button.pressed.connect(_on_collapse_button_pressed)
	load_image_button.pressed.connect(load_image_button_pressed.emit)
	var_a_dropdown.item_selected.connect(_on_var_a_dropdown_item_selected)
	var_b_dropdown.item_selected.connect(_on_var_b_dropdown_item_selected)
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
	blur_amount_slider_a.value_changed.connect(blur_amount_a_changed.emit)
	blur_amount_slider_b.value_changed.connect(blur_amount_b_changed.emit)
	heart_scale_slider_a.value_changed.connect(heart_scale_a_changed.emit)
	heart_rotation_slider_a.value_changed.connect(heart_rotation_a_changed.emit)
	heart_strength_slider_a.value_changed.connect(heart_strength_a_changed.emit)
	heart_scale_slider_b.value_changed.connect(heart_scale_b_changed.emit)
	heart_rotation_slider_b.value_changed.connect(heart_rotation_b_changed.emit)
	heart_strength_slider_b.value_changed.connect(heart_strength_b_changed.emit)
	mirror_tiling_check_box.toggled.connect(mirror_tiling_changed.emit)

	
	
	
	gradient_toggle_button.pressed.connect(_on_gradient_toggle_button_pressed)
	# --- Connect A/B/Post Symmetry Controls ---
	# Variation A Controls
	var_a_mirror_x_check.toggled.connect(var_a_mirror_x_changed.emit)
	var_a_mirror_y_check.toggled.connect(var_a_mirror_y_changed.emit)
	var_a_kaleidoscope_slider.value_changed.connect(var_a_kaleidoscope_slices_changed.emit)

	# Variation B Controls
	var_b_mirror_x_check.toggled.connect(var_b_mirror_x_changed.emit)
	var_b_mirror_y_check.toggled.connect(var_b_mirror_y_changed.emit)
	var_b_kaleidoscope_slider.value_changed.connect(var_b_kaleidoscope_slices_changed.emit)

	# Post-Processing Controls
	
	post_mirror_x_check.toggled.connect(mirror_x_changed.emit)
	post_mirror_y_check.toggled.connect(mirror_y_changed.emit)
	post_kaleidoscope_master_check.toggled.connect(_on_post_kaleidoscope_master_check_toggled)
	post_kaleidoscope_slider.value_changed.connect(kaleidoscope_slices_changed.emit)

	# --- Initial UI State ---
	_expanded_size = self.size
	# Start in a collapsed state
	scroll_container.visible = false
	var collapsed_height = collapse_button.size.y + 20 
	self.size = Vector2(self.size.x, collapsed_height)
	collapse_button.text = "▼ Expand"
	post_mirror_controls.visible = true
	post_kaleidoscope_controls.visible = true
	
	# ---Mobius ---
	%MobiusReASliderA.value_changed.connect(mobius_re_a_a_changed.emit)
	%MobiusImASliderA.value_changed.connect(mobius_im_a_a_changed.emit)
	%MobiusReBSliderA.value_changed.connect(mobius_re_b_a_changed.emit)
	%MobiusImBSliderA.value_changed.connect(mobius_im_b_a_changed.emit)
	%MobiusReCSliderA.value_changed.connect(mobius_re_c_a_changed.emit)
	%MobiusImCSliderA.value_changed.connect(mobius_im_c_a_changed.emit)
	%MobiusReDSliderA.value_changed.connect(mobius_re_d_a_changed.emit)
	%MobiusImDSliderA.value_changed.connect(mobius_im_d_a_changed.emit)
	%MobiusReASliderB.value_changed.connect(mobius_re_a_b_changed.emit)
	%MobiusImASliderB.value_changed.connect(mobius_im_a_b_changed.emit)
	%MobiusReBSliderB.value_changed.connect(mobius_re_b_b_changed.emit)
	%MobiusImBSliderB.value_changed.connect(mobius_im_b_b_changed.emit)
	%MobiusReCSliderB.value_changed.connect(mobius_re_c_b_changed.emit)
	%MobiusImCSliderB.value_changed.connect(mobius_im_c_b_changed.emit)
	%MobiusReDSliderB.value_changed.connect(mobius_re_d_b_changed.emit)
	%MobiusImDSliderB.value_changed.connect(mobius_im_d_b_changed.emit)
	
	
	var_mix_slider.value_changed.connect(variation_mix_changed.emit)
	feedback_amount_slider.value_changed.connect(feedback_amount_changed.emit)
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
	update_contextual_ui_visibility()

func configure_control_pair(slider: HSlider, spinbox: SpinBox, min_val: float, max_val: float, step_val: float) -> void:
	slider.min_value = min_val; slider.max_value = max_val; slider.step = step_val
	spinbox.min_value = min_val; spinbox.max_value = max_val; spinbox.step = step_val
	slider.value_changed.connect(spinbox.set_value)
	spinbox.value_changed.connect(slider.set_value)

func initialize_ui(initial_values: Dictionary) -> void:
	# General
	var var_a_name = initial_values.get("var_a", "Sinusoidal")
	for i in range(var_a_dropdown.item_count):
		if var_a_dropdown.get_item_text(i) == var_a_name:
			var_a_dropdown.select(i)
			break # Stop searching once found
	var var_b_name = initial_values.get("var_b", "Spherical")
	for i in range(var_b_dropdown.item_count):
		if var_b_dropdown.get_item_text(i) == var_b_name:
			var_b_dropdown.select(i)
			break # Stop searching once found
	
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
	mirror_tiling_check_box.button_pressed = initial_values.get("mirror_tiling", false)
	
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
	
	# Mobius
	# Mobius A
	mobius_re_a_slider_a.value = initial_values.get("mobius_re_a_a", 0.1)
	mobius_im_a_slider_a.value = initial_values.get("mobius_im_a_a", 0.1)
	mobius_re_b_slider_a.value = initial_values.get("mobius_re_b_a", 0.1)
	mobius_im_b_slider_a.value = initial_values.get("mobius_im_b_a", 0.1)
	mobius_re_c_slider_a.value = initial_values.get("mobius_re_c_a", 0.1)
	mobius_im_c_slider_a.value = initial_values.get("mobius_im_c_a", 0.1)
	mobius_re_d_slider_a.value = initial_values.get("mobius_re_d_a", 0.1)
	mobius_im_d_slider_a.value = initial_values.get("mobius_im_d_a", 0.1)
		# Mobius B
	mobius_re_a_slider_b.value = initial_values.get("mobius_re_a_b", 0.1)
	mobius_im_a_slider_b.value = initial_values.get("mobius_im_a_b", 0.1)
	mobius_re_b_slider_b.value = initial_values.get("mobius_re_b_b", 0.1)
	mobius_im_b_slider_b.value = initial_values.get("mobius_im_b_b", 0.1)
	mobius_re_c_slider_b.value = initial_values.get("mobius_re_c_b", 0.1)
	mobius_im_c_slider_b.value = initial_values.get("mobius_im_c_b", 0.1)
	mobius_re_d_slider_b.value = initial_values.get("mobius_re_d_b", 0.1)
	mobius_im_d_slider_b.value = initial_values.get("mobius_im_d_b", 0.1)
	
		# Heart A
	heart_scale_slider_a.value = initial_values.get("heart_scale_a", 0.3)
	heart_rotation_slider_a.value = initial_values.get("heart_rotation_a", 0.0)
	heart_strength_slider_a.value = initial_values.get("heart_strength_a", 0.5)

	# Heart B
	heart_scale_slider_b.value = initial_values.get("heart_scale_b", 0.3)
	heart_rotation_slider_b.value = initial_values.get("heart_rotation_b", 0.0)
	heart_strength_slider_b.value = initial_values.get("heart_strength_b", 0.5)
	
	apollonian_scale_slider_a.value = initial_values.get("apollonian_scale_a", 1.5)
	var c1a = initial_values.get("ap_c1_a", Vector2(0.0, 0.5)) # <-- ADD Init
	_ap_c1_a = c1a # Update internal var
	ap_c1x_spinbox_a.value = c1a.x
	ap_c1y_spinbox_a.value = c1a.y
	var c2a = initial_values.get("ap_c2_a", Vector2(-0.433, -0.25)) # <-- ADD Init
	_ap_c2_a = c2a
	ap_c2x_spinbox_a.value = c2a.x
	ap_c2y_spinbox_a.value = c2a.y
	var c3a = initial_values.get("ap_c3_a", Vector2(0.433, -0.25)) # <-- ADD Init
	_ap_c3_a = c3a
	ap_c3x_spinbox_a.value = c3a.x
	ap_c3y_spinbox_a.value = c3a.y

	apollonian_scale_slider_b.value = initial_values.get("apollonian_scale_b", 1.5)
	var c1b = initial_values.get("ap_c1_b", Vector2(0.0, 0.5)) # <-- ADD Init
	_ap_c1_b = c1b
	ap_c1x_spinbox_b.value = c1b.x
	ap_c1y_spinbox_b.value = c1b.y
	var c2b = initial_values.get("ap_c2_b", Vector2(-0.433, -0.25)) # <-- ADD Init
	_ap_c2_b = c2b
	ap_c2x_spinbox_b.value = c2b.x
	ap_c2y_spinbox_b.value = c2b.y
	var c3b = initial_values.get("ap_c3_b", Vector2(0.433, -0.25)) # <-- ADD Init
	_ap_c3_b = c3b
	ap_c3x_spinbox_b.value = c3b.x
	ap_c3y_spinbox_b.value = c3b.y
	
	update_contextual_ui_visibility()

# In ui_controller.gd

func update_contextual_ui_visibility() -> void:
	# --- Step 1: Hide ALL contextual panels first ---
	wave_controls_container_a.visible = false
	julian_controls_container_a.visible = false
	polar_controls_container_a.visible = false
	fisheye_controls_container_a.visible = false
	var_a_mirror_controls.visible = false
	var_a_kaleidoscope_controls.visible = false
	mobius_controls_container_a.visible = false
	
	wave_controls_container_b.visible = false
	julian_controls_container_b.visible = false
	polar_controls_container_b.visible = false
	fisheye_controls_container_b.visible = false
	var_b_mirror_controls.visible = false
	var_b_kaleidoscope_controls.visible = false
	mobius_controls_container_b.visible = false
	cellular_weave_controls_container_a.visible = false
	cellular_weave_controls_container_b.visible = false
	blur_controls_container_a.visible = false
	blur_controls_container_b.visible = false
	heart_controls_container_a.visible = false
	heart_controls_container_b.visible = false
	
	apollonian_controls_container_a.visible = false 
	apollonian_controls_container_b.visible = false
	
	# --- Step 2: Get the selected variation names ---
	var selected_name_a = var_a_dropdown.get_item_text(var_a_dropdown.selected)
	var selected_name_b = var_b_dropdown.get_item_text(var_b_dropdown.selected)

	# --- Step 3 & 4 for VarA ---
	if VariationManager.VARIATIONS.has(selected_name_a):
		var variation_data_a = VariationManager.VARIATIONS[selected_name_a]
		if variation_data_a.has("controls") and variation_data_a["controls"] != null:
			match variation_data_a["controls"]:
				"wave": wave_controls_container_a.visible = true
				"julian": julian_controls_container_a.visible = true
				"polar": polar_controls_container_a.visible = true
				"fisheye": fisheye_controls_container_a.visible = true
				"mirror": var_a_mirror_controls.visible = true
				"kaleidoscope": var_a_kaleidoscope_controls.visible = true
				"mobius": mobius_controls_container_a.visible = true # Must be _a
				"cellular_weave": cellular_weave_controls_container_a.visible = true
				"blur": blur_controls_container_a.visible = true
				"heart": heart_controls_container_a.visible = true
				"apollonian": apollonian_controls_container_a.visible = true


	# --- Step 3 & 4 for VarB ---
	if VariationManager.VARIATIONS.has(selected_name_b):
		var variation_data_b = VariationManager.VARIATIONS[selected_name_b]
		if variation_data_b.has("controls") and variation_data_b["controls"] != null:
			match variation_data_b["controls"]:
				"wave": wave_controls_container_b.visible = true
				"julian": julian_controls_container_b.visible = true
				"polar": polar_controls_container_b.visible = true
				"fisheye": fisheye_controls_container_b.visible = true
				"mirror": var_b_mirror_controls.visible = true
				"kaleidoscope": var_b_kaleidoscope_controls.visible = true
				"mobius": mobius_controls_container_b.visible = true # Must be _b
				"cellular_weave": cellular_weave_controls_container_b.visible = true
				"blur": blur_controls_container_b.visible = true
				"heart": heart_controls_container_b.visible = true
				"apollonian": apollonian_controls_container_b.visible = true


	# --- Handle Post-Processing and Start Pattern visibility ---
	
	post_kaleidoscope_options.visible = post_kaleidoscope_master_check.button_pressed
		
	# --- Start Pattern Controls Visibility ---
	# First, hide all context-specific start pattern controls.
	show_grid_check.get_parent().visible = false
	circle_controls_container.visible = false
	load_image_button.visible = false
	gradient_toggle_button.visible = false
	# Also hide the gradient panel itself, in case it was left open.
	gradient_controls_container.visible = false

	# Now, show only the controls for the selected mode.
	var start_mode = start_pattern_dropdown.selected
	match start_mode:
		0: # Gradient + Grid
			show_grid_check.get_parent().visible = true
			gradient_toggle_button.visible = true
			# Restore the gradient panel's visibility if it was open.
			if gradient_toggle_button.text == "▼ Gradient Controls":
				gradient_controls_container.visible = true
		1: # Circles
			circle_controls_container.visible = true
		2: # Image Input
			load_image_button.visible = true
		3: # Perlin Noise
			# This mode has no specific controls, so we do nothing.
			pass
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
	
# --- Signal Emitters ---
func _on_var_a_dropdown_item_selected(index: int) -> void: 
	emit_signal("variation_a_changed", index)
	update_contextual_ui_visibility()

func _on_var_b_dropdown_item_selected(index: int) -> void: 
	emit_signal("variation_b_changed", index)
	update_contextual_ui_visibility()

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
func _on_varmixslider_value_changed(value: float) -> void: emit_signal("variation_mix_changed", value)
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

func _on_wave_type_dropdown_a_item_selected(index: int) -> void: emit_signal("wave_type_a_changed", index)
func _on_wave_type_dropdown_b_item_selected(index: int) -> void: emit_signal("wave_type_b_changed", index)
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

func _on_mirror_x_check_toggled(is_on: bool) -> void: 
	emit_signal("mirror_x_changed", is_on)
	update_contextual_ui_visibility()

func _on_mirror_y_check_toggled(is_on: bool) -> void: 
	emit_signal("mirror_y_changed", is_on)
	update_contextual_ui_visibility()

func _on_kaleidoscope_check_toggled(is_on: bool) -> void: 
	emit_signal("kaleidoscope_changed", is_on)
	update_contextual_ui_visibility()

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
	# Toggle the visibility of the main controls area
	scroll_container.visible = not scroll_container.visible

	if scroll_container.visible:
		# --- EXPANDING ---
		# Restore the panel to its last expanded size
		self.size = _expanded_size
		collapse_button.text = "▲ Collapse"
	else:
		# --- COLLAPSING ---
		# Store the current size in case the user has resized the panel
		_expanded_size = self.size
		# Calculate the new, smaller height (button height + some padding)
		var collapsed_height = collapse_button.size.y + 20 
		# Set the panel to the new collapsed size
		self.size = Vector2(self.size.x, collapsed_height)
		collapse_button.text = "▼ Expand"

func _on_post_mirror_master_check_toggled(is_on: bool) -> void:
	# This function runs when the master post-mirror checkbox is toggled.
	# It emits the signal that tells the shader whether to apply the effect.
	# It also updates the UI to show/hide the X/Y checkboxes.
	emit_signal("mirror_x_changed", is_on and post_mirror_x_check.button_pressed)
	emit_signal("mirror_y_changed", is_on and post_mirror_y_check.button_pressed)
	update_contextual_ui_visibility()

func _on_post_kaleidoscope_master_check_toggled(is_on: bool) -> void:
	# This function runs when the master post-kaleidoscope checkbox is toggled.
	# It tells the shader whether to apply the effect and shows/hides the slices slider.
	emit_signal("kaleidoscope_changed", is_on)
	update_contextual_ui_visibility()
