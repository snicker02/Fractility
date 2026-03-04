extends CanvasLayer

@export var fractal_mesh: MeshInstance3D
@export var main_camera: Camera3D
var waypoints: Array = []
var _pending_screenshot: Image
var time: float = 0.0 # Manual clock for the fractal
var mandelbox_shader = preload("res://Mandelbox4D.gdshader")
var menger_shader = preload("res://menger.gdshader")
var amazingsurf_shader = preload("res://amazingsurf.gdshader")
var bristorbrot_shader = preload("res://Bristorbrot.gdshader") # Ensure this path is correct
var archon_shader = preload("res://archon.gdshader")
var animation_tween: Tween # This allows us to pause and step the animation
@onready var save_video_dialog = %SaveVideoDialog # Create a FileDialog in your scene
# Track which fractal is currently active
var current_fractal: String = "Mandelbox" # Default to Mandelbox
var archon_initialized: bool = false
# Core Menger 4D Sliders
@onready var menger_scale_slider = %MengerScaleSlider
@onready var menger_offset_w_slider = %OffsetWSlider
@onready var menger_iterations_slider = %IterationsSlider
@onready var menger_rotation_slider = %Rotations4DSlider

# Menger Offset 1 (X, Y, Z, W)
@onready var menger_ox_slider = %MengerOffset1_xSlider
@onready var menger_oy_slider = %MengerOffset1_ySlider
@onready var menger_oz_slider = %MengerOffset1_zSlider
@onready var menger_ow_slider = %MengerOffset1_wSlider

# Menger Julia 4D
@onready var menger_julia_toggle = %MS4DJuliaToggle
@onready var menger_morph_slider = %MS4DMorphSlider
@onready var menger_jx_slider = %MS4DJuliaXSlider
@onready var menger_jy_slider = %MS4DJuliaYSlider
@onready var menger_jz_slider = %MS4DJuliaZSlider
@onready var menger_jw_slider = %MS4DJuliaWSlider

var is_recording: bool = false
var frame_counter: int = 0
var recording_dir: String = "user://recordings"
@onready var record_timer = %RecordTimer # Make sure you added this Timer node
@onready var menger_detail_slider = %MengerDetailSlider
@onready var background_texture = %BackgroundTexture
@onready var bg_file_dialog = %BackgroundDialog 
var is_playing_flythrough: bool = false

func _ready():
	if has_node("%ColorPicker1"):
		%ColorPicker1.color_changed.connect(func(c): 
			get_fractal_material().set_shader_parameter("Color1", Vector3(c.r, c.g, c.b)))
	if has_node("%ColorPicker2"):
		%ColorPicker2.color_changed.connect(func(c): 
			get_fractal_material().set_shader_parameter("Color2", Vector3(c.r, c.g, c.b)))
	if has_node("%ColorPicker3"):
		%ColorPicker3.color_changed.connect(func(c): 
			get_fractal_material().set_shader_parameter("Color3", Vector3(c.r, c.g, c.b)))
	var mat = get_fractal_material()
	
	# Set initial fractal based on current shader
	if mat and mat.shader:
		if "menger" in mat.shader.resource_path.to_lower():
			current_fractal = "Menger"
		else:
			current_fractal = "Mandelbox"
	
	setup_navigation_tree()
	
	# Connect the Tree's selection signal
	if has_node("%NavigationTree"):
		%NavigationTree.item_selected.connect(_on_tree_item_selected)
	
	# Connect all UI elements using Unique Names (%)
	if has_node("%TypeSelector"): 
		%TypeSelector.item_selected.connect(_on_inv_type_selected)
	if has_node("%ScaleSlider"): 
		%ScaleSlider.value_changed.connect(_on_scale_changed)
	if has_node("%WSlider"): 
		%WSlider.value_changed.connect(_on_w_changed)
	if has_node("%ColorCycleSlider"): 
		%ColorCycleSlider.value_changed.connect(_on_color_cycle_changed)
	if has_node("%PaletteSelector"): 
		%PaletteSelector.item_selected.connect(_on_palette_selected)
	if has_node("%StepsSlider"): 
		%StepsSlider.value_changed.connect(_on_steps_changed)
	if has_node("%DetailSlider"): 
		%DetailSlider.value_changed.connect(_on_detail_changed)
	
	if has_node("%JuliaXSlider"):
		%JuliaXSlider.value_changed.connect(_on_julia_slider_changed)
	if has_node("%JuliaYSlider"):
		%JuliaYSlider.value_changed.connect(_on_julia_slider_changed)
	if has_node("%JuliaZSlider"):
		%JuliaZSlider.value_changed.connect(_on_julia_slider_changed)
	
	if has_node("%SidesSlider"):
		%SidesSlider.value_changed.connect(_on_sides_changed)
		# Set initial label
		_update_sides_label(%SidesSlider.value)
	
	if has_node("%JuliaToggle"):
		%JuliaToggle.toggled.connect(_on_julia_toggled)
	
	if has_node("%ReflectSlider"):
		%ReflectSlider.value_changed.connect(_on_reflect_changed)
	if has_node("%FogSlider"):
		%FogSlider.value_changed.connect(_on_fog_changed)
	if has_node("%SpeedSlider"):
		%SpeedSlider.value_changed.connect(_on_speed_changed)
	if has_node("%RotationSlider"):
		%RotationSlider.value_changed.connect(_on_rotation_changed)
	
	if has_node("%InvParamA") and mat:
		%InvParamA.value_changed.connect(_on_inv_param_a_changed)
		var inv_param_a = mat.get_shader_parameter("InvParamA")
		if inv_param_a != null:
			%InvParamA.value = inv_param_a
			_on_inv_param_a_changed(inv_param_a)
	
	if has_node("%FixedRadiusSlider") and mat:
		%FixedRadiusSlider.value_changed.connect(_on_fixed_radius_changed)
		var inv_scale = mat.get_shader_parameter("InvScale")
		if inv_scale != null:
			%FixedRadiusSlider.value = inv_scale
			_on_fixed_radius_changed(inv_scale)
	
	# Connect Symmetry Toggles
	if has_node("%AbsXToggle"):
		%AbsXToggle.toggled.connect(func(v): get_fractal_material().set_shader_parameter("F_absX", v))
	if has_node("%AbsYToggle"):
		%AbsYToggle.toggled.connect(func(v): get_fractal_material().set_shader_parameter("F_absY", v))
	if has_node("%AbsZToggle"):
		%AbsZToggle.toggled.connect(func(v): get_fractal_material().set_shader_parameter("F_absZ", v))
	
	if has_node("%XSwapToggle"):
		%XSwapToggle.toggled.connect(func(v): get_fractal_material().set_shader_parameter("F_X", v))
	if has_node("%YSwapToggle"):
		%YSwapToggle.toggled.connect(func(v): get_fractal_material().set_shader_parameter("F_Y", v))
	if has_node("%ZSwapToggle"):
		%ZSwapToggle.toggled.connect(func(v): get_fractal_material().set_shader_parameter("F_Z", v))
	
	# Connect Symmetry Sliders
	if has_node("%PFiveSlider"):
		%PFiveSlider.value_changed.connect(_on_pfive_changed)
	if has_node("%FoldOffsetSlider"):
		%FoldOffsetSlider.value_changed.connect(_on_fold_offset_changed)
	
	if has_node("%MengerToggle"):
		%MengerToggle.toggled.connect(_on_menger_toggled)
	
	# Buttons
	if has_node("%ResetButton"): 
		%ResetButton.pressed.connect(_on_reset_pressed)
	if has_node("%ScreenshotButton"): 
		%ScreenshotButton.pressed.connect(_on_screenshot_pressed)
	
	# Save Dialog
	if has_node("%SaveDialog"): 
		%SaveDialog.file_selected.connect(_on_dir_selected)
	
	if has_node("%SavePresetButton"):
		%SavePresetButton.pressed.connect(func(): %SavePresetDialog.popup_centered())

	if has_node("%LoadPresetButton"):
		%LoadPresetButton.pressed.connect(func(): %LoadPresetDialog.popup_centered())

	# Connect the FileDialogs (Make sure you create these in your scene)
	if has_node("%SavePresetDialog"):
		%SavePresetDialog.file_selected.connect(save_preset)

	if has_node("%LoadPresetDialog"):
		%LoadPresetDialog.file_selected.connect(load_preset)
	
	# Initialize all labels to match the current shader state
	if mat:
		# Force the shader values to 0 for reflectivity and fog
		mat.set_shader_parameter("Reflectivity", 0.0)
		mat.set_shader_parameter("FogDensity", 0.0)
		
		# Manually update the labels to 0.0 text
		if has_node("%ReflectLabel"):
			%ReflectLabel.text = "Reflectivity: 0.0"
		if has_node("%FogLabel"):
			%FogLabel.text = "Fog Density: 0.0"
		
		# Set the sliders themselves to 0
		if has_node("%ReflectSlider"):
			%ReflectSlider.value = 0.0
		if has_node("%FogSlider"):
			%FogSlider.value = 0.0
		
		var current_seed = mat.get_shader_parameter("JuliaSeed")
		var scale_val = mat.get_shader_parameter("Scale")
		var offset_w = mat.get_shader_parameter("OffsetW")
		var sides_val = mat.get_shader_parameter("InvParamB")
		var max_steps = mat.get_shader_parameter("MaxSteps")
		var detail_val = mat.get_shader_parameter("Detail")
		
		# Sync the sliders and labels to the shader's default values
		if has_node("%ScaleSlider") and scale_val != null:
			%ScaleSlider.value = scale_val
			_on_scale_changed(scale_val)
		
		if has_node("%WSlider") and offset_w != null:
			%WSlider.value = offset_w
			_on_w_changed(offset_w)
		
		if has_node("%SidesSlider") and sides_val != null:
			%SidesSlider.value = sides_val
			_on_sides_changed(sides_val)
		
		# Sync Reflectivity
		if has_node("%ReflectSlider"):
			var r_val = mat.get_shader_parameter("Reflectivity")
			if r_val != null:
				%ReflectSlider.value = r_val
				_on_reflect_changed(r_val)
		
		# Sync Fog
		if has_node("%FogSlider"):
			var f_val = mat.get_shader_parameter("FogDensity")
			if f_val != null:
				%FogSlider.value = f_val
				_on_fog_changed(f_val)
		
		# Set initial text for the static labels
		if max_steps != null:
			_update_steps_label(max_steps)
		if detail_val != null:
			_update_detail_label(detail_val)
		
		if current_seed != null:
			if has_node("%JuliaXSlider"):
				%JuliaXSlider.value = current_seed.x
			if has_node("%JuliaYSlider"):
				%JuliaYSlider.value = current_seed.y
			if has_node("%JuliaZSlider"):
				%JuliaZSlider.value = current_seed.z
	
	_on_julia_slider_changed(0.0) # Refresh labels
	
	if has_node("%TypeSelector"):
		%TypeSelector.selected = 0
		if mat:
			mat.set_shader_parameter("InvType", 0)
	
	if has_node("%PaletteSelector"):
		%PaletteSelector.selected = 0
	
	if has_node("%ResolutionSelector"):
		%ResolutionSelector.selected = 0
	
	if has_node("%SpeedSlider"):
		_on_speed_changed(%SpeedSlider.value)
	
	# Connect Menger sliders - with null checks
	if menger_scale_slider:
		menger_scale_slider.value_changed.connect(_update_menger)
	if menger_offset_w_slider:
		menger_offset_w_slider.value_changed.connect(_update_menger)
	if menger_iterations_slider:
		menger_iterations_slider.value_changed.connect(_update_menger)
	if menger_rotation_slider:
		menger_rotation_slider.value_changed.connect(_update_menger)
	if has_node("%MengerMaxStepsSlider"):
		%MengerMaxStepsSlider.value_changed.connect(_on_menger_max_steps_changed)
	# Set initial value from shader
	mat = get_fractal_material()
	if mat:
		var steps = mat.get_shader_parameter("MaxSteps")
		if steps != null:
			%MengerMaxStepsSlider.value = steps
			_on_menger_max_steps_changed(steps)
	# Menger Offset 1 (X, Y, Z, W)
	if menger_ox_slider:
		menger_ox_slider.value_changed.connect(_update_menger)
	if menger_oy_slider:
		menger_oy_slider.value_changed.connect(_update_menger)
	if menger_oz_slider:
		menger_oz_slider.value_changed.connect(_update_menger)
	if menger_ow_slider:
		menger_ow_slider.value_changed.connect(_update_menger)
	
	# Menger Julia 4D
	if menger_julia_toggle:
		menger_julia_toggle.toggled.connect(_update_menger)
	if menger_morph_slider:
		menger_morph_slider.value_changed.connect(_update_menger)
	if menger_jx_slider:
		menger_jx_slider.value_changed.connect(_update_menger)
	if menger_jy_slider:
		menger_jy_slider.value_changed.connect(_update_menger)
	if menger_jz_slider:
		menger_jz_slider.value_changed.connect(_update_menger)
	if menger_jw_slider:
		menger_jw_slider.value_changed.connect(_update_menger)
	if has_node("%MengerDetailSlider"):
		%MengerDetailSlider.value_changed.connect(_on_menger_detail_changed)
		# Sync initial value from shader
		mat = get_fractal_material()
		if mat:
			var detail_val = mat.get_shader_parameter("Detail")
			if detail_val != null:
				%MengerDetailSlider.value = detail_val
				_on_menger_detail_changed(detail_val)
		
		
	if has_node("%SaturationSlider"):
		%SaturationSlider.value_changed.connect(_on_saturation_changed)
		# Set initial label
		_on_saturation_changed(%SaturationSlider.value)

	if has_node("%ContrastSlider"):
		%ContrastSlider.value_changed.connect(_on_contrast_changed)
		_on_contrast_changed(%ContrastSlider.value)

	if has_node("%BrightnessSlider"):
		%BrightnessSlider.value_changed.connect(_on_brightness_changed)
		_on_brightness_changed(%BrightnessSlider.value)
		
		
	_on_palette_selected(%PaletteSelector.selected)
	# Animation System Connections
	if has_node("%AddWaypointButton"):
		%AddWaypointButton.pressed.connect(_on_add_waypoint_pressed)
		
	if has_node("%PlayAnimationButton"):
		%PlayAnimationButton.pressed.connect(play_flythrough)
		
	if has_node("%ClearPathButton"):
		%ClearPathButton.pressed.connect(_on_clear_path_pressed)
	if has_node("%RecordButton"):
		%RecordButton.toggled.connect(_on_record_button_toggled)
		
	if has_node("%RecordTimer"):
		%RecordTimer.timeout.connect(_on_record_timer_timeout)
		
	if has_node("%SaveVideoDialog"):
		%SaveVideoDialog.file_selected.connect(_on_save_video_dialog_file_selected)
	if has_node("%OverlayStopButton"):
		%OverlayStopButton.pressed.connect(func(): %RecordButton.button_pressed = false)
	
# Add a button connection for "Change Background"
	if has_node("%ChangeBGButton"):
		%ChangeBGButton.pressed.connect(_on_change_bg_pressed)
	
	

	if has_node("%BackgroundDialog"):
		%BackgroundDialog.file_selected.connect(_on_bg_image_selected)
	
	if has_node("%KIFSAngleXSlider"):
		%KIFSAngleXSlider.value_changed.connect(_on_kifs_angle_x_changed)

# KIFS Angle Y
	if has_node("%KIFSAngleYSlider"):
		%KIFSAngleYSlider.value_changed.connect(_on_kifs_angle_y_changed)

# KIFS Angle Z
	if has_node("%KIFSAngleZSlider"):
		%KIFSAngleZSlider.value_changed.connect(_on_kifs_angle_z_changed)

# Run it once at startup to sync the initial state
	_update_kifs_mask()


# === Amazing Surf Complete Connections ===

# MAIN TAB - Already done, but here for completeness
	if has_node("%PowerSlider"):
		%PowerSlider.value_changed.connect(_on_surf_power_changed)
	if has_node("%SurfScaleSlider2"):
		%SurfScaleSlider2.value_changed.connect(_on_surf_scale2_changed)
	if has_node("%SurfIterationsSlider"):
		%SurfIterationsSlider.value_changed.connect(_on_surf_iterations_changed)
	if has_node("%BailoutSlider"):
		%BailoutSlider.value_changed.connect(_on_surf_bailout_changed)

	# FOLDING TAB
	# Fold Slot Toggles
	if has_node("%FoldSlot1Toggle"):
		%FoldSlot1Toggle.toggled.connect(_on_fold_slot1_toggled)
	if has_node("%FoldSlot2Toggle"):
		%FoldSlot2Toggle.toggled.connect(_on_fold_slot2_toggled)
	if has_node("%FoldSlot3Toggle"):
		%FoldSlot3Toggle.toggled.connect(_on_fold_slot3_toggled)
	if has_node("%FoldSlot4Toggle"):
		%FoldSlot4Toggle.toggled.connect(_on_fold_slot4_toggled)
	if has_node("%FoldSlot5Toggle"):
		%FoldSlot5Toggle.toggled.connect(_on_fold_slot5_toggled)

	# Fold Type Selectors
	if has_node("%FoldType1Selector"):
		%FoldType1Selector.item_selected.connect(_on_fold_type1_selected)
	if has_node("%FoldType2Selector"):
		%FoldType2Selector.item_selected.connect(_on_fold_type2_selected)
	if has_node("%FoldType3Selector"):
		%FoldType3Selector.item_selected.connect(_on_fold_type3_selected)
	if has_node("%FoldType4Selector"):
		%FoldType4Selector.item_selected.connect(_on_fold_type4_selected)
	if has_node("%FoldType5Selector"):
		%FoldType5Selector.item_selected.connect(_on_fold_type5_selected)
	if has_node("%EnableZAxisToggle"):
		%EnableZAxisToggle.toggled.connect(_on_enable_z_axis_toggled)
	
	# PARAMETERS TAB
	if has_node("%FoldLimitXSlider"):
		%FoldLimitXSlider.value_changed.connect(_on_fold_limit_x_changed)
	if has_node("%FoldLimitYSlider"):
		%FoldLimitYSlider.value_changed.connect(_on_fold_limit_y_changed)
	if has_node("%FoldLimitZSlider"):
		%FoldLimitZSlider.value_changed.connect(_on_fold_limit_z_changed)
	if has_node("%FoldingValueSlider"):
		%FoldingValueSlider.value_changed.connect(_on_folding_value_changed)
	if has_node("%Offset2Slider"):
		%Offset2Slider.value_changed.connect(_on_offset2_changed)

	# SPHERE FOLD TAB
	if has_node("%SphereFoldToggle"):
		%SphereFoldToggle.toggled.connect(_on_sphere_fold_toggled)
	if has_node("%MinRadiusSlider"):
		%MinRadiusSlider.value_changed.connect(_on_min_radius_changed)
	if has_node("%FixedRadiusSlider2"):
		%FixedRadiusSlider2.value_changed.connect(_on_fixed_radius2_changed)
	if has_node("%CylinderFoldToggle"):
		%CylinderFoldToggle.toggled.connect(_on_cylinder_fold_toggled)
	if has_node("%CylinderWeightSlider"):
		%CylinderWeightSlider.value_changed.connect(_on_cylinder_weight_changed)

	# TRANSFORMS TAB
	# Pre-Offset
	if has_node("%PreOffsetXSlider"):
		%PreOffsetXSlider.value_changed.connect(_on_pre_offset_changed)
	if has_node("%PreOffsetYSlider"):
		%PreOffsetYSlider.value_changed.connect(_on_pre_offset_changed)
	if has_node("%PreOffsetZSlider"):
		%PreOffsetZSlider.value_changed.connect(_on_pre_offset_changed)

	# Post-Offset
	if has_node("%PostOffsetXSlider"):
		%PostOffsetXSlider.value_changed.connect(_on_post_offset_changed)
	if has_node("%PostOffsetYSlider"):
		%PostOffsetYSlider.value_changed.connect(_on_post_offset_changed)
	if has_node("%PostOffsetZSlider"):
		%PostOffsetZSlider.value_changed.connect(_on_post_offset_changed)

	# Rotation
	if has_node("%ASurfRotationSlider"):
		%ASurfRotationSlider.value_changed.connect(_on_asurf_rotation_changed)

	# SURFACE TAB - Already done earlier
	if has_node("%SurfScaleSlider"):
		%SurfScaleSlider.value_changed.connect(_on_surf_scale_changed)
	if has_node("%SurfStrengthSlider"):
		%SurfStrengthSlider.value_changed.connect(_on_surf_strength_changed)
	if has_node("%SurfOctavesSlider"):
		%SurfOctavesSlider.value_changed.connect(_on_surf_octaves_changed)
	if has_node("%SurfRoughnessSlider"):
		%SurfRoughnessSlider.value_changed.connect(_on_surf_roughness_changed)
	if has_node("%SurfSpeedSlider"):
		%SurfSpeedSlider.value_changed.connect(_on_surf_speed_changed)

	# Julia Mode for Amazing Surf
	if has_node("%ASurfJuliaToggle"):
		%ASurfJuliaToggle.toggled.connect(_on_asurf_julia_toggled)
	if has_node("%ASurfJuliaXSlider"):
		%ASurfJuliaXSlider.value_changed.connect(_on_asurf_julia_changed)
	if has_node("%ASurfJuliaYSlider"):
		%ASurfJuliaYSlider.value_changed.connect(_on_asurf_julia_changed)
	if has_node("%ASurfJuliaZSlider"):
		%ASurfJuliaZSlider.value_changed.connect(_on_asurf_julia_changed)

	# 4D Folding Controls
	if has_node("%EnableWAxisToggle"):
		%EnableWAxisToggle.toggled.connect(_on_enable_w_axis_toggled)

	if has_node("%FoldLimitWSlider"):
		%FoldLimitWSlider.value_changed.connect(_on_fold_limit_w_changed)

	# 4D Rotation Controls
	if has_node("%RotationXWSlider"):
		%RotationXWSlider.value_changed.connect(_on_rotation_xw_changed)
	if has_node("%RotationYWSlider"):
		%RotationYWSlider.value_changed.connect(_on_rotation_yw_changed)
	if has_node("%RotationZWSlider"):
		%RotationZWSlider.value_changed.connect(_on_rotation_zw_changed)
	
	
	
	if has_node("%RippleFrequencySlider"):
		%RippleFrequencySlider.value_changed.connect(_on_ripple_frequency_changed)
	if has_node("%RippleAmplitudeSlider"):
		%RippleAmplitudeSlider.value_changed.connect(_on_ripple_amplitude_changed)
		
	if has_node("%DEMethodSelector"):
		%DEMethodSelector.item_selected.connect(_on_de_method_selected)
	if has_node("%DEMultiplierSlider"):
		%DEMultiplierSlider.value_changed.connect(_on_de_multiplier_changed)

	# Rendering Method
	if has_node("%RenderingMethodSelector"):
		var selector = %RenderingMethodSelector
		# Disconnect old ones if they exist to prevent double-firing
		if selector.item_selected.is_connected(_on_rendering_method_selected):
			selector.item_selected.disconnect(_on_rendering_method_selected)
		
		selector.item_selected.connect(_on_rendering_method_selected)
		
		# Set default and force the first update
		selector.selected = 0
		_on_rendering_method_selected(0)
	# Slice controls
	if has_node("%SliceWSlider"):
		%SliceWSlider.value_changed.connect(_on_slice_w_changed)
	if has_node("%AnimateSliceWToggle"):
		%AnimateSliceWToggle.toggled.connect(_on_animate_slice_w_toggled)
	if has_node("%SliceWSpeedSlider"):
		%SliceWSpeedSlider.value_changed.connect(_on_slice_w_speed_changed)
	if has_node("%SliceZoomSlider"):
		%SliceZoomSlider.value_changed.connect(_on_slice_zoom_changed)

	# Volume controls
	if has_node("%VolumeStepsSlider"):
		%VolumeStepsSlider.value_changed.connect(_on_volume_steps_changed)
	if has_node("%VolumeDensitySlider"):
		%VolumeDensitySlider.value_changed.connect(_on_volume_density_changed)
	if has_node("%VolumeBrightnessSlider"):
		%VolumeBrightnessSlider.value_changed.connect(_on_volume_brightness_changed)

	# NEW: Mandelbulber 3D Rotations (Alpha, Beta, Gamma)
	if has_node("%AlphaRotationSlider"):
		%AlphaRotationSlider.value_changed.connect(_on_alpha_rotation_changed)
	if has_node("%BetaRotationSlider"):
		%BetaRotationSlider.value_changed.connect(_on_beta_rotation_changed)
	if has_node("%GammaRotationSlider"):
		%GammaRotationSlider.value_changed.connect(_on_gamma_rotation_changed)

	# NEW: Scale Vary
	if has_node("%ScaleVarySlider"):
		%ScaleVarySlider.value_changed.connect(_on_scale_vary_changed)
	
	
	if has_node("%ASMaxStepsSlider"):
		%ASMaxStepsSlider.value_changed.connect(_on_as_max_steps_changed)
		
	if has_node("%ASDetailSlider"):
		%ASDetailSlider.value_changed.connect(_on_as_detail_changed)

	%TimeSpeedSlider.value_changed.connect(_on_shader_param_changed.bind("time_speed"))
	
	%ParallelToggle.toggled.connect(_on_shader_param_changed.bind("draw_parallel"))

	if has_node("%WarpStrengthSlider"):
		%WarpStrengthSlider.value_changed.connect(_on_warp_strength_changed)
	if has_node("%WarpFrequencySlider"):
		%WarpFrequencySlider.value_changed.connect(_on_warp_frequency_changed)

	if has_node("%WOffsetSlider"):
		%WOffsetSlider.value_changed.connect(_on_woffset_changed)
	
	if has_node("%KIFS_Axis_Selector"):
		%KIFS_Axis_Selector.item_selected.connect(_on_kifs_axis_selected)
	
	if has_node("%KIFS_Sides_Slider"):
		%KIFS_Sides_Slider.value_changed.connect(_on_kifs_sides_changed)
		_on_kifs_sides_changed(%KIFS_Sides_Slider.value) # Initial label sync

	if has_node("%KIFS_Twist_Slider"):
		%KIFS_Twist_Slider.value = 0.0

	mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("KIFS_Twist", 0.0)
		
	# Organic Ribbon/Tentacle Connections for Amazing Surf
	if has_node("%RibbonWarpStrengthSlider"):
		%RibbonWarpStrengthSlider.value_changed.connect(_on_ribbon_warp_strength_changed)

	if has_node("%RibbonWarpFrequencySlider"):
		%RibbonWarpFrequencySlider.value_changed.connect(_on_ribbon_warp_frequency_changed)

	if has_node("%RibbonTwistSlider"):
		%RibbonTwistSlider.value_changed.connect(_on_ribbon_twist_changed)
		
	
	
		# --- Master Toggle with Fixed Indentation ---
	%ShapeEnabledCheck.toggled.connect(func(is_pressed):
		get_fractal_material().set_shader_parameter("ShapeEnabled", is_pressed)
		
		# Grouping all shape-related UI nodes
		var shape_nodes = [
			%ShapeTypeButton, %ShapeRadiusSlider, %ShapeThicknessSlider, 
			%ShapeBendSlider, %GrainIntensitySlider, %TentacleCountSlider, 
			%TentacleLengthSlider, %TentacleTwistSlider
		]
		
		for node in shape_nodes:
			if is_instance_valid(node):
				if node is HSlider:
					# Sliders use 'editable'
					node.editable = is_pressed
				elif node is OptionButton:
					# Buttons use 'disabled' (inverted)
					node.disabled = !is_pressed
		)

	# --- Shape Type Selector ---
	%ShapeTypeButton.item_selected.connect(func(index):
		get_fractal_material().set_shader_parameter("ShapeType", index)
	)
		
		
		
	%ShapeBendSlider.value_changed.connect(func(v):
		%ShapeBendLabel.text = "Spine Bend : " + str(snapped(v, 0.01))
		get_fractal_material().set_shader_parameter("ShapeBend", v)
	)
	
	
	
		
	
		# Connect Geometry Sliders with one-line lambdas
	%ShapeRadiusSlider.value_changed.connect(func(v):
		%ShapeRadiusLabel.text = "Radius : " + str(snapped(v, 0.01))
		get_fractal_material().set_shader_parameter("ShapeRadius", v)
	)

	%ShapeThicknessSlider.value_changed.connect(func(v):
		%ShapeThicknessLabel.text = "Tube width: " + str(snapped(v, 0.01))
		get_fractal_material().set_shader_parameter("ShapeThickness", v)
	)	

	# Connect Offset Sliders
	%ShapeOffsetXSlider.value_changed.connect(_on_shape_offset_changed)
	%ShapeOffsetYSlider.value_changed.connect(_on_shape_offset_changed)
	%ShapeOffsetZSlider.value_changed.connect(_on_shape_offset_changed)
	# Connect the Master Shape Toggle
	
	# --- Global Shape Detail: Grain Intensity ---
	%GrainIntensitySlider.value_changed.connect(func(v):
		%GrainIntensityLabel.text = "Grain Intensity : " + str(snapped(v, 0.01))
		get_fractal_material().set_shader_parameter("GrainIntensity", v)
	)

	# --- Tentacle Spines Settings ---
	%TentacleCountSlider.value_changed.connect(func(v):
		%TentacleCountLabel.text = "Tentacle Count : " + str(int(v))
		get_fractal_material().set_shader_parameter("TentacleCount", v)
	)

	%TentacleLengthSlider.value_changed.connect(func(v):
		%TentacleLengthLabel.text = "Tentacle Length : " + str(snapped(v, 0.01))
		get_fractal_material().set_shader_parameter("TentacleLength", v)
	)

	%TentacleTwistSlider.value_changed.connect(func(v):
		%TentacleTwistLabel.text = "Tentacle Twist : " + str(snapped(v, 0.01))
		get_fractal_material().set_shader_parameter("TentacleTwist", v)
	)
		
		
		
	for slider_path in ["%KIFSAngleXSlider", "%KIFSAngleYSlider", "%KIFSAngleZSlider"]:
		if has_node(slider_path):
			get_node(slider_path).value = 0.0

		for rot_path in ["%RotationXWSlider", "%RotationYWSlider", "%RotationZWSlider"]:
			if has_node(rot_path):
				get_node(rot_path).value = 0.0

	# Push zeroes directly to the shader too
	mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("KIFS_Angle_X", 0.0)
		mat.set_shader_parameter("KIFS_Angle_Y", 0.0)
		mat.set_shader_parameter("KIFS_Angle_Z", 0.0)
		mat.set_shader_parameter("RotationXW", 0.0)
		mat.set_shader_parameter("RotationYW", 0.0)
		mat.set_shader_parameter("RotationZW", 0.0)
	
	if has_node("%GrainIntensitySlider"):
		%GrainIntensitySlider.value = 0.0

	mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("GrainIntensity", 0.0)
	for zero_path in ["%GrainIntensitySlider", "%TentacleCountSlider", 
		"%TentacleLengthSlider", "%TentacleTwistSlider", "%ShapeBendSlider"]:
		if has_node(zero_path):
			get_node(zero_path).value = 0.0
			
			
			
		# === ARCHON CONNECTIONS ===
	if has_node("%ArchonScaleSlider"):
		%ArchonScaleSlider.value_changed.connect(_on_archon_scale_changed)
	if has_node("%ArchonIterationsSlider"):
		%ArchonIterationsSlider.value_changed.connect(_on_archon_iterations_changed)
	if has_node("%ArchonBailoutSlider"):
		%ArchonBailoutSlider.value_changed.connect(_on_archon_bailout_changed)
	if has_node("%ArchonTowerBiasSlider"):
		%ArchonTowerBiasSlider.value_changed.connect(_on_archon_tower_bias_changed)

	# Archon Constant XYZW
	if has_node("%ArchonConstantXSlider"):
		%ArchonConstantXSlider.value_changed.connect(_on_archon_constant_changed)
	if has_node("%ArchonConstantYSlider"):
		%ArchonConstantYSlider.value_changed.connect(_on_archon_constant_changed)
	if has_node("%ArchonConstantZSlider"):
		%ArchonConstantZSlider.value_changed.connect(_on_archon_constant_changed)
	if has_node("%ArchonConstantWSlider"):
		%ArchonConstantWSlider.value_changed.connect(_on_archon_constant_changed)
		
	# City Tiling
	if has_node("%ArchonCityEnabledToggle"):
		%ArchonCityEnabledToggle.toggled.connect(_on_archon_city_enabled_toggled)
	if has_node("%ArchonCellSizeSlider"):
		%ArchonCellSizeSlider.value_changed.connect(_on_archon_cell_size_changed)
	if has_node("%ArchonCellRotVarianceSlider"):
		%ArchonCellRotVarianceSlider.value_changed.connect(_on_archon_cell_rot_variance_changed)
	if has_node("%ArchonCellConstantVarianceSlider"):
		%ArchonCellConstantVarianceSlider.value_changed.connect(_on_archon_cell_constant_variance_changed)
	if has_node("%ArchonCellHeightVarianceSlider"):
		%ArchonCellHeightVarianceSlider.value_changed.connect(_on_archon_cell_height_variance_changed)
	if has_node("%ArchonAlleyWidthSlider"):
		%ArchonAlleyWidthSlider.value_changed.connect(_on_archon_alley_width_changed)

	# Spin Fold
	if has_node("%ArchonSpinStrengthSlider"):
		%ArchonSpinStrengthSlider.value_changed.connect(_on_archon_spin_strength_changed)
	if has_node("%ArchonSpinAxisSelector"):
		%ArchonSpinAxisSelector.clear()
		%ArchonSpinAxisSelector.add_item("Y - Columns")
		%ArchonSpinAxisSelector.add_item("X - Arches")
		%ArchonSpinAxisSelector.add_item("Z - Rings")
		%ArchonSpinAxisSelector.selected = 0
		_on_archon_spin_axis_selected(0)
		%ArchonSpinAxisSelector.item_selected.connect(_on_archon_spin_axis_selected)


	# Arch Warp
	if has_node("%ArchonArchFreqSlider"):
		%ArchonArchFreqSlider.value_changed.connect(_on_archon_arch_freq_changed)
	if has_node("%ArchonArchDepthSlider"):
		%ArchonArchDepthSlider.value_changed.connect(_on_archon_arch_depth_changed)
	if has_node("%ArchonArchAxisSelector"):
		%ArchonArchAxisSelector.clear()
		%ArchonArchAxisSelector.add_item("XY - Doorways")
		%ArchonArchAxisSelector.add_item("XZ - Windows")
		%ArchonArchAxisSelector.add_item("YZ - Tunnels")
		%ArchonArchAxisSelector.selected = 0
		_on_archon_arch_axis_selected(0)
		%ArchonArchAxisSelector.item_selected.connect(_on_archon_arch_axis_selected)
		
		# Wave Shape
	if has_node("%ArchonWaveTypeSelector"):
		var wt = mat.get_shader_parameter("WaveType")
		%ArchonWaveTypeSelector.selected = int(wt) if wt != null else 0
		# This connection was missing — without it selecting a wave type does nothing
		%ArchonWaveTypeSelector.item_selected.connect(_on_archon_wave_type_selected)
	if has_node("%ArchonWaveBlendSlider"):
		%ArchonWaveBlendSlider.value_changed.connect(_on_archon_wave_blend_changed)
	

	# Inversion
	if has_node("%ArchonInvRadiusSlider"):
		%ArchonInvRadiusSlider.value_changed.connect(_on_archon_inv_radius_changed)
	if has_node("%ArchonInvStrengthSlider"):
		%ArchonInvStrengthSlider.value_changed.connect(_on_archon_inv_strength_changed)

	# 4D Transform
	if has_node("%ArchonRotationSlider"):
		%ArchonRotationSlider.value_changed.connect(_on_archon_rotation_changed)
	if has_node("%ArchonWRotationSpeedSlider"):
		%ArchonWRotationSpeedSlider.value_changed.connect(_on_archon_w_rotation_speed_changed)

	# Rendering
	if has_node("%ArchonMaxStepsSlider"):
		%ArchonMaxStepsSlider.value_changed.connect(_on_archon_max_steps_changed)
	if has_node("%ArchonDetailSlider"):
		%ArchonDetailSlider.value_changed.connect(_on_archon_detail_changed)

	# Julia
	if has_node("%ArchonJuliaToggle"):
		%ArchonJuliaToggle.toggled.connect(_on_archon_julia_toggled)
	if has_node("%ArchonJuliaMorphSlider"):
		%ArchonJuliaMorphSlider.value_changed.connect(_on_archon_julia_morph_changed)
	if has_node("%ArchonJuliaXSlider"):
		%ArchonJuliaXSlider.value_changed.connect(_on_archon_julia_seed_changed)
	if has_node("%ArchonJuliaYSlider"):
		%ArchonJuliaYSlider.value_changed.connect(_on_archon_julia_seed_changed)
	if has_node("%ArchonJuliaZSlider"):
		%ArchonJuliaZSlider.value_changed.connect(_on_archon_julia_seed_changed)
	if has_node("%ArchonJuliaWSlider"):
		%ArchonJuliaWSlider.value_changed.connect(_on_archon_julia_seed_changed)
	if has_node("%ArchonTypeSelector"):
		%ArchonTypeSelector.selected = 0
		%ArchonTypeSelector.item_selected.connect(_on_archon_type_selected)

	if has_node("%ShapeTypeButton"):
		%ShapeTypeButton.selected = 0
	
	
		




# === ARCHON HANDLERS ===


# Reads current shader values and pushes them back to every Archon UI slider.
# Called after load_preset() so the UI reflects what was loaded.

func _on_archon_type_selected(index: int):
	print("ArchonType selected: ", index)
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("ArchonType", index)
		print("ArchonType shader param set to: ", mat.get_shader_parameter("ArchonType"))
	else:
		print("ERROR: No material found!")
func _sync_archon_ui_from_shader():
	var mat = get_fractal_material()
	if not mat: return

	# Helper to set a slider without triggering its value_changed signal
	var _set = func(path: String, val):
		if has_node(path):
			var node = get_node(path)
			node.set_block_signals(true)
			node.value = float(val)
			node.set_block_signals(false)

	var _set_b = func(path: String, val):
		if has_node(path):
			var node = get_node(path)
			node.set_block_signals(true)
			node.button_pressed = bool(val)
			node.set_block_signals(false)
	if has_node("%ArchonTypeSelector"):
		var at = mat.get_shader_parameter("ArchonType")
		%ArchonTypeSelector.selected = int(at) if at != null else 0
	if has_node("%ArchonSpinAxisSelector"):
		%ArchonSpinAxisSelector.selected = 0
	_on_archon_spin_axis_selected(0)

	if has_node("%ArchonArchAxisSelector"):
		%ArchonArchAxisSelector.selected = 0
		_on_archon_arch_axis_selected(0)
	
	# --- Main ---
	_set.call("%ArchonScaleSlider",      mat.get_shader_parameter("Scale"))
	_set.call("%ArchonIterationsSlider", mat.get_shader_parameter("Iterations"))
	_set.call("%ArchonBailoutSlider",    mat.get_shader_parameter("Bailout"))
	_set.call("%ArchonTowerBiasSlider",  mat.get_shader_parameter("TowerBias"))

	var ac = mat.get_shader_parameter("ArchonConstant")
	if ac != null:
		_set.call("%ArchonConstantXSlider", ac.x)
		_set.call("%ArchonConstantYSlider", ac.y)
		_set.call("%ArchonConstantZSlider", ac.z)
		_set.call("%ArchonConstantWSlider", ac.w)

	# --- Spin Fold ---
	_set.call("%ArchonSpinStrengthSlider", mat.get_shader_parameter("SpinStrength"))

	# --- Arch Warp ---
	_set.call("%ArchonArchFreqSlider",   mat.get_shader_parameter("ArchFrequency"))
	_set.call("%ArchonArchDepthSlider",  mat.get_shader_parameter("ArchDepth"))

	# --- Inversion ---
	_set.call("%ArchonInvRadiusSlider",   mat.get_shader_parameter("InvRadius"))
	_set.call("%ArchonInvStrengthSlider", mat.get_shader_parameter("InvStrength"))

	# --- 4D Transform ---
	_set.call("%ArchonRotationSlider",        mat.get_shader_parameter("RotationAngle"))
	_set.call("%ArchonWRotationSpeedSlider",  mat.get_shader_parameter("WRotationSpeed"))

	# --- Rendering ---
	_set.call("%ArchonMaxStepsSlider", mat.get_shader_parameter("MaxSteps"))
	_set.call("%ArchonDetailSlider",   mat.get_shader_parameter("Detail"))

	# --- Wave Shape ---
	_set.call("%ArchonWaveBlendSlider", mat.get_shader_parameter("WaveBlend"))
	if has_node("%ArchonWaveTypeSelector"):
		var wt = mat.get_shader_parameter("WaveType")
		%ArchonWaveTypeSelector.selected = int(wt) if wt != null else 0
	# --- Julia ---
	_set_b.call("%ArchonJuliaToggle",    mat.get_shader_parameter("JuliaMode"))
	_set.call("%ArchonJuliaMorphSlider", mat.get_shader_parameter("JuliaMorph"))
	var js = mat.get_shader_parameter("JuliaSeed")
	if js != null:
		_set.call("%ArchonJuliaXSlider", js.x)
		_set.call("%ArchonJuliaYSlider", js.y)
		_set.call("%ArchonJuliaZSlider", js.z)
		_set.call("%ArchonJuliaWSlider", js.w)

	# --- City Tiling ---
	_set_b.call("%ArchonCityEnabledToggle",       mat.get_shader_parameter("CityEnabled"))
	_set.call("%ArchonCellSizeSlider",            mat.get_shader_parameter("CellSize"))
	_set.call("%ArchonCellRotVarianceSlider",     mat.get_shader_parameter("CellRotVariance"))
	_set.call("%ArchonCellConstantVarianceSlider",mat.get_shader_parameter("CellConstantVariance"))
	_set.call("%ArchonCellHeightVarianceSlider",  mat.get_shader_parameter("CellHeightVariance"))
	_set.call("%ArchonAlleyWidthSlider",          mat.get_shader_parameter("AlleyWidth"))

	# --- Shape ---
	_set_b.call("%ShapeEnabledCheck",     mat.get_shader_parameter("ShapeEnabled"))
	_set.call("%ShapeRadiusSlider",       mat.get_shader_parameter("ShapeRadius"))
	_set.call("%ShapeThicknessSlider",    mat.get_shader_parameter("ShapeThickness"))
	_set.call("%ShapeBendSlider",         mat.get_shader_parameter("ShapeBend"))
	_set.call("%GrainIntensitySlider",    mat.get_shader_parameter("GrainIntensity"))
	_set.call("%TentacleCountSlider",     mat.get_shader_parameter("TentacleCount"))
	_set.call("%TentacleLengthSlider",    mat.get_shader_parameter("TentacleLength"))
	_set.call("%TentacleTwistSlider",     mat.get_shader_parameter("TentacleTwist"))
	if has_node("%ShapeTypeButton"):
		var st = mat.get_shader_parameter("ShapeType")
		var st_int = int(st) if st != null else 0
		%ShapeTypeButton.selected = max(0, st_int)
	# --- Symmetry ---
	_set_b.call("%AbsXToggle", mat.get_shader_parameter("F_absX"))
	_set_b.call("%AbsYToggle", mat.get_shader_parameter("F_absY"))
	_set_b.call("%AbsZToggle", mat.get_shader_parameter("F_absZ"))
	_set_b.call("%XSwapToggle", mat.get_shader_parameter("F_X"))
	_set_b.call("%YSwapToggle", mat.get_shader_parameter("F_Y"))
	_set_b.call("%ZSwapToggle", mat.get_shader_parameter("F_Z"))
	_set.call("%KIFSAngleXSlider", mat.get_shader_parameter("KIFS_Angle_X"))
	_set.call("%KIFSAngleYSlider", mat.get_shader_parameter("KIFS_Angle_Y"))
	_set.call("%KIFSAngleZSlider", mat.get_shader_parameter("KIFS_Angle_Z"))

	# Now update all labels to match the restored values
	_on_archon_scale_changed(get_v("%ArchonScaleSlider", 2.0))
	_on_archon_iterations_changed(get_v("%ArchonIterationsSlider", 20.0))
	_on_archon_bailout_changed(get_v("%ArchonBailoutSlider", 8.0))
	_on_archon_tower_bias_changed(get_v("%ArchonTowerBiasSlider", 1.8))
	_on_archon_constant_changed(0.0)
	_on_archon_spin_strength_changed(get_v("%ArchonSpinStrengthSlider", 0.4))
	_on_archon_arch_freq_changed(get_v("%ArchonArchFreqSlider", 1.5))
	_on_archon_arch_depth_changed(get_v("%ArchonArchDepthSlider", 0.4))
	_on_archon_inv_radius_changed(get_v("%ArchonInvRadiusSlider", 1.2))
	_on_archon_inv_strength_changed(get_v("%ArchonInvStrengthSlider", 0.8))
	_on_archon_rotation_changed(get_v("%ArchonRotationSlider", 0.3))
	_on_archon_w_rotation_speed_changed(get_v("%ArchonWRotationSpeedSlider", 0.0))
	_on_archon_max_steps_changed(get_v("%ArchonMaxStepsSlider", 128.0))
	_on_archon_detail_changed(get_v("%ArchonDetailSlider", -2.5))
	_on_archon_wave_blend_changed(get_v("%ArchonWaveBlendSlider", 1.0))
	_on_archon_cell_size_changed(get_v("%ArchonCellSizeSlider", 4.0))
	_on_archon_cell_rot_variance_changed(get_v("%ArchonCellRotVarianceSlider", 0.8))
	_on_archon_cell_constant_variance_changed(get_v("%ArchonCellConstantVarianceSlider", 0.3))
	_on_archon_cell_height_variance_changed(get_v("%ArchonCellHeightVarianceSlider", 0.4))
	_on_archon_alley_width_changed(get_v("%ArchonAlleyWidthSlider", 0.15))

	print("Archon UI synced from shader.")

func _on_archon_city_enabled_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("CityEnabled", pressed)

func _on_archon_cell_size_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("CellSize", value)
	if has_node("%ArchonCellSizeLabel"):
		%ArchonCellSizeLabel.text = "Cell Size: " + str(snapped(value, 0.1))

func _on_archon_cell_rot_variance_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("CellRotVariance", value)
	if has_node("%ArchonCellRotVarianceLabel"):
		%ArchonCellRotVarianceLabel.text = "Rotation Variance: " + str(snapped(value, 0.01))

func _on_archon_cell_constant_variance_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("CellConstantVariance", value)
	if has_node("%ArchonCellConstantVarianceLabel"):
		%ArchonCellConstantVarianceLabel.text = "Ruin Variance: " + str(snapped(value, 0.01))

func _on_archon_cell_height_variance_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("CellHeightVariance", value)
	if has_node("%ArchonCellHeightVarianceLabel"):
		%ArchonCellHeightVarianceLabel.text = "Height Variance: " + str(snapped(value, 0.01))

func _on_archon_alley_width_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("AlleyWidth", value)
	if has_node("%ArchonAlleyWidthLabel"):
		%ArchonAlleyWidthLabel.text = "Alley Width: " + str(snapped(value, 0.01))

func _on_archon_wave_type_selected(index: int):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("WaveType", index)
	# Optional: print a hint so you know what you picked
	var names = ["Sine", "Triangle", "Square", "Sawtooth", "Bounce"]
	print("Archon WaveType -> ", names[index])

func _on_archon_wave_blend_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("WaveBlend", value)
	if has_node("%ArchonWaveBlendLabel"):
		%ArchonWaveBlendLabel.text = "Wave Blend: " + str(snapped(value, 0.01))

func _on_archon_scale_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("Scale", value)
	if has_node("%ArchonScaleLabel"):
		%ArchonScaleLabel.text = "Scale: " + str(snapped(value, 0.01))

func _on_archon_iterations_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("Iterations", int(value))
	if has_node("%ArchonIterationsLabel"):
		%ArchonIterationsLabel.text = "Iterations: " + str(int(value))

func _on_archon_bailout_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("Bailout", value)
	if has_node("%ArchonBailoutLabel"):
		%ArchonBailoutLabel.text = "Bailout: " + str(snapped(value, 0.1))

func _on_archon_tower_bias_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("TowerBias", value)
	if has_node("%ArchonTowerBiasLabel"):
		%ArchonTowerBiasLabel.text = "Tower Bias: " + str(snapped(value, 0.01))

func _on_archon_constant_changed(_v: float):
	var mat = get_fractal_material()
	if not mat: return
	var val = Vector4(
		get_v("%ArchonConstantXSlider", 1.0),
		get_v("%ArchonConstantYSlider", 1.3),
		get_v("%ArchonConstantZSlider", 0.8),
		get_v("%ArchonConstantWSlider", 0.2)
	)
	mat.set_shader_parameter("ArchonConstant", val)
	if has_node("%ArchonConstantXLabel"): %ArchonConstantXLabel.text = "Constant X: " + str(snapped(val.x, 0.01))
	if has_node("%ArchonConstantYLabel"): %ArchonConstantYLabel.text = "Constant Y: " + str(snapped(val.y, 0.01))
	if has_node("%ArchonConstantZLabel"): %ArchonConstantZLabel.text = "Constant Z: " + str(snapped(val.z, 0.01))
	if has_node("%ArchonConstantWLabel"): %ArchonConstantWLabel.text = "Constant W: " + str(snapped(val.w, 0.01))

func _on_archon_spin_strength_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("SpinStrength", value)
	if has_node("%ArchonSpinStrengthLabel"):
		%ArchonSpinStrengthLabel.text = "Spin Strength: " + str(snapped(value, 0.01))

func _on_archon_spin_axis_selected(index: int):
	var mat = get_fractal_material()
	if not mat: return
	# 0=Y axis (columns), 1=X axis (arches), 2=Z axis (rings)
	var axes = [Vector3(0,1,0), Vector3(1,0,0), Vector3(0,0,1)]
	mat.set_shader_parameter("SpinAxis", axes[index])

func _on_archon_arch_freq_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("ArchFrequency", value)
	if has_node("%ArchonArchFreqLabel"):
		%ArchonArchFreqLabel.text = "Arch Frequency: " + str(snapped(value, 0.01))

func _on_archon_arch_depth_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("ArchDepth", value)
	if has_node("%ArchonArchDepthLabel"):
		%ArchonArchDepthLabel.text = "Arch Depth: " + str(snapped(value, 0.01))

func _on_archon_arch_axis_selected(index: int):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("ArchAxis", index)

func _on_archon_inv_radius_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("InvRadius", value)
	if has_node("%ArchonInvRadiusLabel"):
		%ArchonInvRadiusLabel.text = "Inv Radius: " + str(snapped(value, 0.01))

func _on_archon_inv_strength_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("InvStrength", value)
	if has_node("%ArchonInvStrengthLabel"):
		%ArchonInvStrengthLabel.text = "Inv Strength: " + str(snapped(value, 0.01))

func _on_archon_rotation_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("RotationAngle", value)
	if has_node("%ArchonRotationLabel"):
		%ArchonRotationLabel.text = "4D Rotation: " + str(snapped(value, 0.01))

func _on_archon_w_rotation_speed_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("WRotationSpeed", value)
	if has_node("%ArchonWRotationSpeedLabel"):
		%ArchonWRotationSpeedLabel.text = "W Anim Speed: " + str(snapped(value, 0.01))

func _on_archon_max_steps_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("MaxSteps", int(value))
	if has_node("%ArchonMaxStepsLabel"):
		%ArchonMaxStepsLabel.text = "Max Steps: " + str(int(value))

func _on_archon_detail_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("Detail", value)
	if has_node("%ArchonDetailLabel"):
		%ArchonDetailLabel.text = "Detail: " + str(snapped(value, 0.01))

func _on_archon_julia_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("JuliaMode", pressed)

func _on_archon_julia_morph_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("JuliaMorph", value)
	if has_node("%ArchonJuliaMorphLabel"):
		%ArchonJuliaMorphLabel.text = "Julia Morph: " + str(snapped(value, 0.01))

func _on_archon_julia_seed_changed(_v: float):
	var mat = get_fractal_material()
	if not mat: return
	var seed = Vector4(
		get_v("%ArchonJuliaXSlider", 1.0),
		get_v("%ArchonJuliaYSlider", 1.3),
		get_v("%ArchonJuliaZSlider", 0.8),
		get_v("%ArchonJuliaWSlider", 0.2)
	)
	mat.set_shader_parameter("JuliaSeed", seed)
	if has_node("%ArchonJuliaXLabel"): %ArchonJuliaXLabel.text = "Julia X: " + str(snapped(seed.x, 0.01))
	if has_node("%ArchonJuliaYLabel"): %ArchonJuliaYLabel.text = "Julia Y: " + str(snapped(seed.y, 0.01))
	if has_node("%ArchonJuliaZLabel"): %ArchonJuliaZLabel.text = "Julia Z: " + str(snapped(seed.z, 0.01))
	if has_node("%ArchonJuliaWLabel"): %ArchonJuliaWLabel.text = "Julia W: " + str(snapped(seed.w, 0.01))

func _sync_archon_to_shader():
	var mat = get_fractal_material()
	if not mat: return
	
	# Push hardcoded defaults directly — safe even if sliders don't exist yet
	mat.set_shader_parameter("Scale", 2.0)
	mat.set_shader_parameter("Iterations", 20)
	mat.set_shader_parameter("Bailout", 8.0)
	mat.set_shader_parameter("TowerBias", 0.0)
	mat.set_shader_parameter("ArchonConstant", Vector4(1.0, 1.3, 0.8, 0.2))
	mat.set_shader_parameter("SpinStrength", 0.0)
	mat.set_shader_parameter("SpinAxis", Vector3(0.0, 1.0, 0.0))
	mat.set_shader_parameter("ArchFrequency", 1.5)
	mat.set_shader_parameter("ArchDepth",  0.4)
	mat.set_shader_parameter("ArchAxis", 0)
	mat.set_shader_parameter("InvRadius", 1.2)
	mat.set_shader_parameter("InvStrength", 0.8)
	mat.set_shader_parameter("RotationAngle", 0.3)
	mat.set_shader_parameter("WRotationSpeed", 0.0)
	mat.set_shader_parameter("MaxSteps", 200)
	mat.set_shader_parameter("Detail", -1.0)
	mat.set_shader_parameter("JuliaMode", false)
	mat.set_shader_parameter("JuliaMorph", 0.0)
	mat.set_shader_parameter("JuliaSeed", Vector4(1.0, 1.3, 0.8, 0.2))
	mat.set_shader_parameter("WaveType", 0)    # 0 = Sine (safe default)
	mat.set_shader_parameter("WaveBlend", 1.0)
	# Shape defaults — off by default, safe to switch on from Shapes tab
	mat.set_shader_parameter("ShapeEnabled", false)
	mat.set_shader_parameter("ShapeType", 0)
	mat.set_shader_parameter("ShapeRadius", 1.5)
	mat.set_shader_parameter("ShapeThickness", 0.4)
	mat.set_shader_parameter("ShapeBend", 0.0)
	mat.set_shader_parameter("ShapeOffset", Vector3(0.0, 0.0, 0.0))
	mat.set_shader_parameter("GrainIntensity", 0.0)
	mat.set_shader_parameter("TentacleCount", 0.0)
	mat.set_shader_parameter("TentacleLength", 0.0)
	mat.set_shader_parameter("TentacleTwist", 0.0)
	mat.set_shader_parameter("CityEnabled", false)
	mat.set_shader_parameter("CellSize", 4.0)
	mat.set_shader_parameter("CellRotVariance", 0.8)
	mat.set_shader_parameter("CellConstantVariance", 0.3)
	mat.set_shader_parameter("CellHeightVariance", 0.4)
	mat.set_shader_parameter("AlleyWidth", 0.15)
	mat.set_shader_parameter("ArchonType", 0)

	
	# Then override with slider values if they exist
	_on_archon_scale_changed(get_v("%ArchonScaleSlider", 2.0))
	_on_archon_iterations_changed(get_v("%ArchonIterationsSlider", 20))
	print("Archon shader synced.")

	
	if has_node("%ArchonCityEnabledToggle"):
		%ArchonCityEnabledToggle.button_pressed = false
	if has_node("%ArchonCellSizeSlider"):
		%ArchonCellSizeSlider.value = 4.0
		_on_archon_cell_size_changed(4.0)
	if has_node("%ArchonCellRotVarianceSlider"):
		%ArchonCellRotVarianceSlider.value = 0.8
	if has_node("%ArchonCellConstantVarianceSlider"):
		%ArchonCellConstantVarianceSlider.value = 0.3
	if has_node("%ArchonCellHeightVarianceSlider"):
		%ArchonCellHeightVarianceSlider.value = 0.4
	if has_node("%ArchonAlleyWidthSlider"):
		%ArchonAlleyWidthSlider.value = 0.15

	
	
	




# === BristorBrot Parameter Updates ===

func _on_woffset_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("WOffset", value)
	if has_node("%WOffsetLabel"):
		%WOffsetLabel.text = "W Offset: " + str(snapped(value, 0.01))


func _on_warp_strength_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("WarpStrength", value)
	if has_node("%WarpStrengthLabel"):
		%WarpStrengthLabel.text = "Warp Strength: " + str(snapped(value, 0.01))

func _on_warp_frequency_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("WarpFrequency", value)
	if has_node("%WarpFrequencyLabel"):
		%WarpFrequencyLabel.text = "Warp Frequency: " + str(snapped(value, 0.01))


# === Amazing Surf Parameter Updates ===

func _on_shape_offset_changed(_v):
	# Update labels with prefixes
	%ShapeOffsetXLabel.text = "Offset X: " + str(snapped(%ShapeOffsetXSlider.value, 0.01))
	%ShapeOffsetYLabel.text = "Offset Y: " + str(snapped(%ShapeOffsetYSlider.value, 0.01))
	%ShapeOffsetZLabel.text = "Offset Z: " + str(snapped(%ShapeOffsetZSlider.value, 0.01))
	
	# Push the combined Vector3 to the shader
	var offset = Vector3(
		%ShapeOffsetXSlider.value, 
		%ShapeOffsetYSlider.value, 
		%ShapeOffsetZSlider.value
	)
	get_fractal_material().set_shader_parameter("ShapeOffset", offset)

func _update_shape_offset(_v):
	var offset = Vector3(%ShapeOffsetXSlider.value, %ShapeOffsetYSlider.value, %ShapeOffsetZSlider.value)
	get_fractal_material().set_shader_parameter("ShapeOffset", offset)


func _on_ribbon_warp_strength_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("WarpStrength", value)
	if has_node("%RibbonWarpStrengthLabel"):
		%RibbonWarpStrengthLabel.text = "Ribbon Warp Strength: " + str(snapped(value, 0.01))

func _on_ribbon_warp_frequency_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("WarpFrequency", value)
	if has_node("%RibbonWarpFrequencyLabel"):
		%RibbonWarpFrequencyLabel.text = "Ribbon Warp Freq: " + str(snapped(value, 0.01))

func _on_ribbon_twist_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("RibbonTwist", value)
	if has_node("%RibbonTwistLabel"):
		%RibbonTwistLabel.text = "Ribbon Twist: " + str(snapped(value, 0.01))

func _on_kifs_axis_selected(index: int):
	var mat = get_fractal_material()
	if mat:
		# 0: XY, 1: XZ, 2: YZ
		mat.set_shader_parameter("KIFS_Axis", index)

func _on_kifs_sides_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("KIFS_Sides", value)
	
	if has_node("%KIFS_Sides_Label"):
		%KIFS_Sides_Label.text = "Symmetry Sides: " + str(int(value))

func _on_kifs_twist_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("KIFS_Twist", value)
	
	if has_node("%KIFS_Twist_Label"):
		%KIFS_Twist_Label.text = "KIFS Twist: " + str(snapped(value, 0.01))


func _on_as_max_steps_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("MaxSteps", int(value))
	
	if has_node("%ASMaxStepsLabel"):
		%ASMaxStepsLabel.text = "Max Steps: " + str(int(value))

func _on_as_detail_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("Detail", value)
	
	if has_node("%ASDetailLabel"):
		# Using snapped(value, 0.01) makes the UI look much cleaner
		%ASDetailLabel.text = "Detail: " + str(snapped(value, 0.01))



func _on_scale_vary_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("ScaleVary", value)
	if has_node("%ScaleVaryLabel"):
		%ScaleVaryLabel.text = "Scale Vary: " + str(snapped(value, 0.01))

func _update_euler_rotation():
	var mat = get_fractal_material()
	if mat and has_node("%AlphaRotationSlider") and has_node("%BetaRotationSlider") and has_node("%GammaRotationSlider"):
		var euler = Vector3(
			%AlphaRotationSlider.value,
			%BetaRotationSlider.value,
			%GammaRotationSlider.value
		)
		mat.set_shader_parameter("EulerRotation", euler)
		
		# Update labels if they exist
		if has_node("%AlphaRotationLabel"): %AlphaRotationLabel.text = "Alpha (X): " + str(int(euler.x)) + "°"
		if has_node("%BetaRotationLabel"): %BetaRotationLabel.text = "Beta (Y): " + str(int(euler.y)) + "°"
		if has_node("%GammaRotationLabel"): %GammaRotationLabel.text = "Gamma (Z): " + str(int(euler.z)) + "°"

func _on_alpha_rotation_changed(_value): _update_euler_rotation()
func _on_beta_rotation_changed(_value):  _update_euler_rotation()
func _on_gamma_rotation_changed(_value): _update_euler_rotation()

func _on_rendering_method_selected(index: int):
	print("Rendering method changed to: ", index)
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("RenderingMethod", index)
		print("Set RenderingMethod to: ", index)
		
		# Show/hide appropriate controls
		update_rendering_ui_visibility(index)

func update_rendering_ui_visibility(mode: int):
	# 1. List every node that should NOT be visible in certain modes
	var to_hide = [
		"%SliceWLabel", "%SliceWSlider", "%AnimateSliceWToggle",
		"%SliceWSpeedLabel", "%SliceWSpeedSlider", "%SliceZoomLabel", "%SliceZoomSlider",
		"%VolumeStepsLabel", "%VolumeStepsSlider", "%VolumeDensityLabel", 
		"%VolumeDensitySlider", "%VolumeBrightnessLabel", "%VolumeBrightnessSlider",
		"%ASMaxStepsLabel", "%ASMaxStepsSlider", 
		"%ASDetailLabel", "%ASDetailSlider"
	]
	
	# 2. Hide everything in that list first
	for path in to_hide:
		if has_node(path):
			get_node(path).visible = false
	
	# 3. Bring back only the ones needed for the current mode
	match mode:
		0: # Raymarch Mode (Default)
			# We want the Amazing Surf sliders back here!
			if has_node("%ASMaxStepsLabel"): %ASMaxStepsLabel.visible = true
			if has_node("%ASMaxStepsSlider"): %ASMaxStepsSlider.visible = true
			if has_node("%ASDetailLabel"): %ASDetailLabel.visible = true
			if has_node("%ASDetailSlider"): %ASDetailSlider.visible = true
			
		1: # Slice Mode
			%SliceWLabel.visible = true
			%SliceWSlider.visible = true
			%AnimateSliceWToggle.visible = true
			%SliceWSpeedLabel.visible = true
			%SliceWSpeedSlider.visible = true
			%SliceZoomLabel.visible = true
			%SliceZoomSlider.visible = true
			
		2: # Volume Mode
			%VolumeStepsLabel.visible = true
			%VolumeStepsSlider.visible = true
			%VolumeDensityLabel.visible = true
			%VolumeDensitySlider.visible = true
			%VolumeBrightnessLabel.visible = true
			%VolumeBrightnessSlider.visible = true
				
				
func _on_slice_w_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("SliceW", value)
	if has_node("%SliceWLabel"):
		%SliceWLabel.text = "Slice W: " + str(snapped(value, 0.01))

func _on_animate_slice_w_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("AnimateSliceW", pressed)

func _on_slice_w_speed_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("SliceWSpeed", value)
	if has_node("%SliceWSpeedLabel"):
		%SliceWSpeedLabel.text = "W Speed: " + str(snapped(value, 0.01))

func _on_slice_zoom_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("SliceZoom", value)
	if has_node("%SliceZoomLabel"):
		%SliceZoomLabel.text = "Zoom: " + str(snapped(value, 0.1))

func _on_volume_steps_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("VolumeSteps", int(value))
	if has_node("%VolumeStepsLabel"):
		%VolumeStepsLabel.text = "Volume Steps: " + str(int(value))

func _on_volume_density_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("VolumeDensity", value)
	if has_node("%VolumeDensityLabel"):
		%VolumeDensityLabel.text = "Density: " + str(snapped(value, 0.1))

func _on_volume_brightness_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("VolumeBrightness", value)
	if has_node("%VolumeBrightnessLabel"):
		%VolumeBrightnessLabel.text = "Brightness: " + str(snapped(value, 0.1))



func _on_de_method_selected(index: int):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("DEMethod", index)
		print("DE Method changed to: ", ["Standard", "Box", "Hybrid"][index])


func _on_de_multiplier_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("DEMultiplier", value)
	if has_node("%DEMultiplierLabel"):
		%DEMultiplierLabel.text = "DE Multiplier: " + str(snapped(value, 0.01))


func _on_ripple_frequency_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("RippleFrequency", value)
	if has_node("%RippleFrequencyLabel"):
		%RippleFrequencyLabel.text = "Ripple Frequency: " + str(snapped(value, 0.1))

func _on_ripple_amplitude_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("RippleAmplitude", value)
	if has_node("%RippleAmplitudeLabel"):
		%RippleAmplitudeLabel.text = "Ripple Amplitude: " + str(snapped(value, 0.01))



func _on_fold_limit_x_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		var current = mat.get_shader_parameter("FoldLimit4D")
		if current == null:
			current = Vector4(1.0, 1.0, 1.0, 1.0)
		mat.set_shader_parameter("FoldLimit4D", Vector4(value, current.y, current.z, current.w))
	if has_node("%FoldLimitXLabel"):
		%FoldLimitXLabel.text = "Fold Limit X: " + str(snapped(value, 0.01))

func _on_fold_limit_y_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		var current = mat.get_shader_parameter("FoldLimit4D")
		if current == null:
			current = Vector4(1.0, 1.0, 1.0, 1.0)
		mat.set_shader_parameter("FoldLimit4D", Vector4(current.x, value, current.z, current.w))
	if has_node("%FoldLimitYLabel"):
		%FoldLimitYLabel.text = "Fold Limit Y: " + str(snapped(value, 0.01))

func _on_fold_limit_z_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		var current = mat.get_shader_parameter("FoldLimit4D")
		if current == null:
			current = Vector4(1.0, 1.0, 1.0, 1.0)
		mat.set_shader_parameter("FoldLimit4D", Vector4(current.x, current.y, value, current.w))
	if has_node("%FoldLimitZLabel"):
		%FoldLimitZLabel.text = "Fold Limit Z: " + str(snapped(value, 0.01))


# === 4D Folding Functions ===

func _on_enable_w_axis_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("EnableWAxisFold", pressed)

func _on_fold_limit_w_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		var current = mat.get_shader_parameter("FoldLimit4D")
		if current == null:
			current = Vector4(1.0, 1.0, 1.0, 1.0)
		mat.set_shader_parameter("FoldLimit4D", Vector4(current.x, current.y, current.z, value))
	if has_node("%FoldLimitWLabel"):
		%FoldLimitWLabel.text = "Fold Limit W: " + str(snapped(value, 0.01))

# === 4D Rotation Functions ===

func _on_rotation_xw_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("RotationXW", value)
	if has_node("%RotationXWLabel"):
		%RotationXWLabel.text = "Rotation XW: " + str(snapped(value, 0.01))

func _on_rotation_yw_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("RotationYW", value)
	if has_node("%RotationYWLabel"):
		%RotationYWLabel.text = "Rotation YW: " + str(snapped(value, 0.01))

func _on_rotation_zw_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("RotationZW", value)
	if has_node("%RotationZWLabel"):
		%RotationZWLabel.text = "Rotation ZW: " + str(snapped(value, 0.01))


func _on_asurf_julia_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("JuliaMode", pressed)

func _on_asurf_julia_changed(_value: float):
	var mat = get_fractal_material()
	if mat and has_node("%ASurfJuliaXSlider") and has_node("%ASurfJuliaYSlider") and has_node("%ASurfJuliaZSlider"):
		var seed = Vector3(
			%ASurfJuliaXSlider.value,
			%ASurfJuliaYSlider.value,
			%ASurfJuliaZSlider.value
		)
		mat.set_shader_parameter("JuliaSeed", seed)
		
		if has_node("%ASurfJuliaXLabel"):
			%ASurfJuliaXLabel.text = "Julia X: " + str(snapped(seed.x, 0.01))
		if has_node("%ASurfJuliaYLabel"):
			%ASurfJuliaYLabel.text = "Julia Y: " + str(snapped(seed.y, 0.01))
		if has_node("%ASurfJuliaZLabel"):
			%ASurfJuliaZLabel.text = "Julia Z: " + str(snapped(seed.z, 0.01))

func _on_surf_power_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("Power", value)
	if has_node("%PowerLabel"):
		%PowerLabel.text = "Power: " + str(snapped(value, 0.1))

func _on_surf_scale2_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("Scale", value)
	if has_node("%SurfScaleLabel2"):
		%SurfScaleLabel2.text = "Scale: " + str(snapped(value, 0.01))

func _on_surf_iterations_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("Iterations", int(value))
	if has_node("%SurfIterationsLabel"):
		%SurfIterationsLabel.text = "Iterations: " + str(int(value))

func _on_surf_bailout_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("Bailout", value)
	if has_node("%BailoutLabel"):
		%BailoutLabel.text = "Bailout: " + str(snapped(value, 0.1))

func _on_surf_scale_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("SurfScale", value)
	if has_node("%SurfScaleLabel"):
		%SurfScaleLabel.text = "Surf Scale: " + str(snapped(value, 0.1))

func _on_surf_strength_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("SurfStrength", value)
	if has_node("%SurfStrengthLabel"):
		%SurfStrengthLabel.text = "Surf Strength: " + str(snapped(value, 0.01))

func _on_surf_octaves_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("SurfOctaves", int(value))
	if has_node("%SurfOctavesLabel"):
		%SurfOctavesLabel.text = "Surf Octaves: " + str(int(value))

func _on_surf_roughness_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("SurfRoughness", value)
	if has_node("%SurfRoughnessLabel"):
		%SurfRoughnessLabel.text = "Surf Roughness: " + str(snapped(value, 0.01))

func _on_surf_speed_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("SurfSpeed", value)
	if has_node("%SurfSpeedLabel"):
		%SurfSpeedLabel.text = "Surf Speed: " + str(snapped(value, 0.01))

func _on_surf_julia_toggled(button_pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("JuliaMode", button_pressed)
		
		
		
# === Amazing Surf Callback Functions ===

# FOLDING TAB FUNCTIONS
func _on_enable_z_axis_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("EnableZAxisFold", pressed)
func _on_fold_slot1_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldSlot1Enabled", pressed)

func _on_fold_slot2_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldSlot2Enabled", pressed)

func _on_fold_slot3_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldSlot3Enabled", pressed)

func _on_fold_slot4_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldSlot4Enabled", pressed)

func _on_fold_slot5_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldSlot5Enabled", pressed)

func _on_fold_type1_selected(index: int):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldType1", index)

func _on_fold_type2_selected(index: int):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldType2", index)

func _on_fold_type3_selected(index: int):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldType3", index)

func _on_fold_type4_selected(index: int):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldType4", index)

func _on_fold_type5_selected(index: int):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldType5", index)

# PARAMETERS TAB FUNCTIONS

func _on_folding_value_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FoldingValue", value)
	if has_node("%FoldingValueLabel"):
		%FoldingValueLabel.text = "Folding Value: " + str(snapped(value, 0.01))

func _on_offset2_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("Offset2", value)
	if has_node("%Offset2Label"):
		%Offset2Label.text = "Offset 2: " + str(snapped(value, 0.01))

# SPHERE FOLD TAB FUNCTIONS
func _on_sphere_fold_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("SphereFoldEnabled", pressed)

func _on_min_radius_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("MinRadius", value)
	if has_node("%MinRadiusLabel"):
		%MinRadiusLabel.text = "Min Radius: " + str(snapped(value, 0.01))

func _on_fixed_radius2_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FixedRadius", value)
	if has_node("%FixedRadiusLabel2"):
		%FixedRadiusLabel2.text = "Fixed Radius: " + str(snapped(value, 0.01))

func _on_cylinder_fold_toggled(pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("ForceCylinderFold", pressed)

func _on_cylinder_weight_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("CylinderWeight", value)
	if has_node("%CylinderWeightLabel"):
		%CylinderWeightLabel.text = "Cylinder Weight: " + str(snapped(value, 0.01))

# TRANSFORMS TAB FUNCTIONS
func _on_pre_offset_changed(_value: float):
	var mat = get_fractal_material()
	if mat and has_node("%PreOffsetXSlider") and has_node("%PreOffsetYSlider") and has_node("%PreOffsetZSlider"):
		var offset = Vector3(
			%PreOffsetXSlider.value,
			%PreOffsetYSlider.value,
			%PreOffsetZSlider.value
		)
		mat.set_shader_parameter("PreOffset", offset)
		
		if has_node("%PreOffsetXLabel"):
			%PreOffsetXLabel.text = "Pre-Offset X: " + str(snapped(offset.x, 0.01))
		if has_node("%PreOffsetYLabel"):
			%PreOffsetYLabel.text = "Pre-Offset Y: " + str(snapped(offset.y, 0.01))
		if has_node("%PreOffsetZLabel"):
			%PreOffsetZLabel.text = "Pre-Offset Z: " + str(snapped(offset.z, 0.01))

func _on_post_offset_changed(_value: float):
	var mat = get_fractal_material()
	if mat and has_node("%PostOffsetXSlider") and has_node("%PostOffsetYSlider") and has_node("%PostOffsetZSlider"):
		var offset = Vector3(
			%PostOffsetXSlider.value,
			%PostOffsetYSlider.value,
			%PostOffsetZSlider.value
		)
		mat.set_shader_parameter("PostOffset", offset)
		
		if has_node("%PostOffsetXLabel"):
			%PostOffsetXLabel.text = "Post-Offset X: " + str(snapped(offset.x, 0.01))
		if has_node("%PostOffsetYLabel"):
			%PostOffsetYLabel.text = "Post-Offset Y: " + str(snapped(offset.y, 0.01))
		if has_node("%PostOffsetZLabel"):
			%PostOffsetZLabel.text = "Post-Offset Z: " + str(snapped(offset.z, 0.01))

func _on_asurf_rotation_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("RotationAngle", value)
	if has_node("%ASurfRotationLabel"):
		%ASurfRotationLabel.text = "Rotation: " + str(snapped(value, 0.01))
		



func _on_menger_max_steps_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		print("Setting Menger MaxSteps to: ", int(value))
		print("Current shader: ", mat.shader.resource_path)
		mat.set_shader_parameter("MaxSteps", int(value))
		print("Shader reports MaxSteps is now: ", mat.get_shader_parameter("MaxSteps"))
	
	if has_node("%MengerMaxStepsLabel"):
		%MengerMaxStepsLabel.text = "Max Steps: " + str(int(value))

func _on_menger_detail_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("Detail", value)
	if has_node("%MengerDetailLabel"):
		%MengerDetailLabel.text = "Detail: " + str(snapped(value, 0.01))

func _update_kifs_mask(_toggled_state: bool = false):
	# Check if all nodes exist before trying to read them
	if not has_node("%KIFS_X_Toggle") or not has_node("%KIFS_Y_Toggle") or not has_node("%KIFS_Z_Toggle"):
		print("ERROR: KIFS toggle nodes not found!")
		return
		
	# Create the mask: 1.0 for On, 0.0 for Off
	var mask = Vector3(
		1.0 if %KIFS_X_Toggle.button_pressed else 0.0,
		1.0 if %KIFS_Y_Toggle.button_pressed else 0.0,
		1.0 if %KIFS_Z_Toggle.button_pressed else 0.0
	)
	
	# DEBUG: Print what we're sending to the shader
	print("KIFS Mask: ", mask)
	
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("KIFS_Axes", mask)
		print("KIFS_Axes shader parameter set to: ", mat.get_shader_parameter("KIFS_Axes"))
	else:
		print("ERROR: No material found!")
func _on_kifs_angle_x_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("KIFS_Angle_X", value)
	if has_node("%KIFSAngleXLabel"):
		%KIFSAngleXLabel.text = "KIFS X Twist: " + str(snapped(value, 0.01))

func _on_kifs_angle_y_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("KIFS_Angle_Y", value)
	if has_node("%KIFSAngleYLabel"):
		%KIFSAngleYLabel.text = "KIFS Y Twist: " + str(snapped(value, 0.01))

func _on_kifs_angle_z_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("KIFS_Angle_Z", value)
	if has_node("%KIFSAngleZLabel"):
		%KIFSAngleZLabel.text = "KIFS Z Twist: " + str(snapped(value, 0.01))

func _on_change_bg_pressed():
	if has_node("%BackgroundDialog"):
		%BackgroundDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		%BackgroundDialog.filters = PackedStringArray(["*.png, *.jpg, *.jpeg ; Images"])
		%BackgroundDialog.access = FileDialog.ACCESS_FILESYSTEM
		%BackgroundDialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
		%BackgroundDialog.popup_centered()
	
func _on_bg_image_selected(path: String):
	var img = Image.load_from_file(path)
	
	# Create a horizontally mirrored seamless texture
	var width = img.get_width()
	var height = img.get_height()
	var seamless_img = Image.create(width * 2, height, false, img.get_format())
	
	# Copy original to left half
	seamless_img.blit_rect(img, Rect2i(0, 0, width, height), Vector2i(0, 0))
	
	# Mirror it to the right half
	for x in range(width):
		for y in range(height):
			var color = img.get_pixel(width - 1 - x, y)
			seamless_img.set_pixel(width + x, y, color)
	
	# Set it as the 3D environment background
	var world_env = get_node_or_null("../WorldEnvironment")
	if world_env and world_env.environment:
		var sky = Sky.new()
		var sky_material = PanoramaSkyMaterial.new()
		sky_material.panorama = ImageTexture.create_from_image(seamless_img)
		sky.sky_material = sky_material
		
		world_env.environment.background_mode = Environment.BG_SKY
		world_env.environment.sky = sky

	
	
	
# --- Logic Functions ---
func setup_navigation_tree():
	%NavigationTree.clear()
	var root = %NavigationTree.create_item()
	%NavigationTree.hide_root = true
	
	# --- GLOBAL SETTINGS ---
	var global_node = %NavigationTree.create_item(root)
	global_node.set_text(0, "Global Settings")
	global_node.set_selectable(0, false)
	
	var cam = %NavigationTree.create_item(global_node)
	cam.set_text(0, "Camera & Speed")
	cam.set_metadata(0, 0)
	
	var env = %NavigationTree.create_item(global_node)
	env.set_text(0, "Environment & Glow")
	env.set_metadata(0, 1)
	
	# --- FRACTALS (Visually Nested) ---
	var fractal_node = %NavigationTree.create_item(root)
	fractal_node.set_text(0, "Fractals")
	fractal_node.set_selectable(0, false)
	
	var mandel = %NavigationTree.create_item(fractal_node)
	mandel.set_text(0, "Mandelbox")
	mandel.set_metadata(0, 2) # Mandelbox4D tab index
	
	var menger = %NavigationTree.create_item(fractal_node)
	menger.set_text(0, "Menger4D")
	menger.set_metadata(0, 3) # Menger4D tab index
	
	var surf = %NavigationTree.create_item(fractal_node)  # NEW
	surf.set_text(0, "Amazing Surf")  # NEW
	surf.set_metadata(0, 4) 
	
	var bristor = %NavigationTree.create_item(fractal_node) # Changed 'surf' to 'bristor'
	bristor.set_text(0, "BristorBrot") # Changed 'surf' to 'bristor'
	bristor.set_metadata(0, 5) 
	
	# --- SYMMETRY ---
	var sym = %NavigationTree.create_item(root)
	sym.set_text(0, "Symmetry Folding")
	sym.set_metadata(0, 6) 
	
	# --- Shapes ---
	var shapes = %NavigationTree.create_item(root)
	shapes.set_text(0, "Shapes")
	shapes.set_metadata(0, 7) 
	
	var archon = %NavigationTree.create_item(fractal_node)
	archon.set_text(0, "Archon")
	archon.set_metadata(0, 8)


func _on_speed_changed(value: float):
	# Find your Camera3D node - adjust the path if necessary
	var camera = get_viewport().get_camera_3d() 
	if camera and "fly_speed" in camera:
		camera.fly_speed = value
	
	# Update the label text
	if has_node("%SpeedLabel"):
		%SpeedLabel.text = "Fly Speed: " + str(snapped(value, 0.01))

func _on_julia_slider_changed(_value: float):
	var mat = get_fractal_material()
	if mat and has_node("%JuliaXSlider") and has_node("%JuliaYSlider") and has_node("%JuliaZSlider"):
		# Create a new vector from the three slider values
		var current_seed = mat.get_shader_parameter("JuliaSeed")
		var new_seed = Vector4(
			%JuliaXSlider.value,
			%JuliaYSlider.value,
			%JuliaZSlider.value,
			current_seed.w if current_seed else 0.0 # Keep W as is
		)
		mat.set_shader_parameter("JuliaSeed", new_seed)
		
		# Update Labels
		if has_node("%JuliaXLabel"):
			%JuliaXLabel.text = "Julia X: " + str(snapped(new_seed.x, 0.01))
		if has_node("%JuliaYLabel"):
			%JuliaYLabel.text = "Julia Y: " + str(snapped(new_seed.y, 0.01))
		if has_node("%JuliaZLabel"):
			%JuliaZLabel.text = "Julia Z: " + str(snapped(new_seed.z, 0.01))

func _on_reflect_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("Reflectivity", value)
	
	if has_node("%ReflectLabel"):
		%ReflectLabel.text = "Reflectivity: " + str(snapped(value, 0.01))

func _on_fog_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("FogDensity", value)
	
	if has_node("%FogLabel"):
		%FogLabel.text = "Fog Density: " + str(snapped(value, 0.001))

func _on_julia_toggled(button_pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("JuliaMode", button_pressed)

func _update_steps_label(value: float):
	if has_node("%StepsLabel"):
		%StepsLabel.text = "Max Steps: " + str(int(value))

func _update_detail_label(value: float):
	if has_node("%DetailLabel"):
		%DetailLabel.text = "Detail: " + str(snapped(value, 0.1))

func get_fractal_material() -> ShaderMaterial:
	if not fractal_mesh: 
		return null
	var mat = fractal_mesh.get_active_material(0)
	return mat as ShaderMaterial

func _input(event):
	# Press 'H' to toggle UI visibility
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		if has_node("%PanelContainer"):
			%PanelContainer.visible = !%PanelContainer.visible
	
	# Press F2 to toggle debug tools
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		# Access the plugin via the absolute root path
		var rdt = get_node_or_null("/root/RuntimeDebugTools")
		
		if rdt:
			var ui = rdt.get_node_or_null("DebugUI")
			if ui:
				ui.visible = !ui.visible
				# Free the mouse so you can click the UI
				if ui.visible:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				print("DebugUI child not found under RuntimeDebugTools")
		else:
			print("RuntimeDebugTools node not found at /root/")
	# Press 'P' to add waypoint (NEW!)
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		_on_add_waypoint_pressed()
	# If 'R' is pressed while recording, stop it
	if is_recording and event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			%RecordButton.button_pressed = false # Triggers the stop logic

func _on_reset_pressed():
	if main_camera:
		main_camera.global_position = Vector3(0, 0, 5)
		main_camera.rotation_degrees = Vector3.ZERO
		if main_camera.has_method("reset_internal_rotation"):
			main_camera.call("reset_internal_rotation")

func _on_screenshot_pressed():
	if not has_node("%PanelContainer") or not has_node("%ResolutionSelector"):
		return
	
	# 1. Get chosen resolution from the dropdown
	var res_index = %ResolutionSelector.selected
	var target_res = Vector2i(1920, 1080) # Default
	
	match res_index:
		1: target_res = Vector2i(3840, 2160) # 4K
		2: target_res = Vector2i(7680, 4320) # 8K
	
	# 2. Hide UI
	%PanelContainer.visible = false
	
	# 3. Setup Viewport
	if not has_node("%HighResViewport"):
		return
	var high_res_v = %HighResViewport
	high_res_v.size = target_res
	
	# 4. Sync Cameras
	if main_camera and has_node("%HighResViewport/Camera3D"):
		var hr_cam = %HighResViewport/Camera3D
		hr_cam.global_transform = main_camera.global_transform
		hr_cam.fov = main_camera.fov
	
	# 5. Capture Frame
	if has_node("%RenderContainer"):
		%RenderContainer.visible = true
	
	await RenderingServer.frame_post_draw
	_pending_screenshot = high_res_v.get_texture().get_image()
	
	# 6. Cleanup
	if has_node("%RenderContainer"):
		%RenderContainer.visible = false
	%PanelContainer.visible = true
	
	# 7. Show the Save Box (The Fix)
	if has_node("%SaveDialog"):
		
		var timestamp = str(Time.get_unix_time_from_system())
		var fractal_name = current_fractal.to_lower()
		
		# Ensure this specific node is in SAVE mode so it doesn't trigger the BG loader
		%SaveDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE 
		%SaveDialog.current_file = fractal_name + "_" + timestamp + ".png"
		
		# Bring it to the front
		%SaveDialog.popup_centered()

func _on_dir_selected(path: String):
	if _pending_screenshot:
		if not path.ends_with(".png"): 
			path += ".png"
		_pending_screenshot.save_png(path)

# --- Parameter Updates ---

func _on_scale_changed(value):
	var mat = get_fractal_material()
	if mat: 
		mat.set_shader_parameter("Scale", value)
	
	if has_node("%ScaleLabel"):
		%ScaleLabel.text = "Scale: " + str(snapped(value, 0.01))

func _on_w_changed(value):
	var mat = get_fractal_material()
	if mat: 
		mat.set_shader_parameter("OffsetW", value)
	
	if has_node("%WLabel"):
		%WLabel.text = "4D Slice (W): " + str(snapped(value, 0.01))

func _on_steps_changed(value):
	var mat = get_fractal_material()
	if mat: 
		mat.set_shader_parameter("MaxSteps", int(value))
	
	if has_node("%StepsLabel"):
		%StepsLabel.text = "Max Steps: " + str(int(value))

func _on_detail_changed(value):
	var mat = get_fractal_material()
	if mat: 
		mat.set_shader_parameter("Detail", value)
	
	if has_node("%DetailLabel"):
		%DetailLabel.text = "Detail: " + str(snapped(value, 0.1))

func _on_color_cycle_changed(value):
	var mat = get_fractal_material()
	if mat: 
		mat.set_shader_parameter("ColorCycle", value)

func _on_palette_selected(index: int):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("PaletteType", index)
	
	# Hide color pickers unless "Custom Gradient" (Index 4) is chosen
	if has_node("%CustomColorContainer"):
		%CustomColorContainer.visible = (index == 4)

func _on_inv_type_selected(index):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("InvType", index)
	
	# Update label based on inversion type
	if has_node("%ParamALabel"):
		match index:
			7: # Toroidal
				%ParamALabel.text = "Major Radius (Donut Size)"
			8: # Amazing Box
				%ParamALabel.text = "Min Radius (Inversion)"
			_: # Default for all other types
				%ParamALabel.text = "Inversion Param A"

func _on_sides_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("InvParamB", value)
	_update_sides_label(value)

func _update_sides_label(value: float):
	if has_node("%SidesLabel"):
		%SidesLabel.text = "Polygon Sides: " + str(int(value))

func _on_tree_item_selected():
	var selected = %NavigationTree.get_selected()
	if not selected: 
		return
	
	var tab_index = selected.get_metadata(0)
	if has_node("%TabContainer"):
		%TabContainer.current_tab = tab_index
	
	var mat = get_fractal_material()
	if not mat: 
		return
	
	# Swap shaders based on selection
	if selected.get_text(0) == "Menger4D":
		current_fractal = "Menger"
		mat.shader = menger_shader
		mat.set_shader_parameter("MengerOffset1", Vector4(1.0, 1.0, 1.0, 1.0))
		mat.set_shader_parameter("OffsetW", 0.0)
		mat.set_shader_parameter("RotationAngle", 0.0)
		_update_menger()
		
	elif selected.get_text(0) == "Mandelbox":
		current_fractal = "Mandelbox"
		mat.shader = mandelbox_shader
		if has_node("%ScaleSlider"):
			_on_scale_changed(%ScaleSlider.value)
		if has_node("%WSlider"):
			_on_w_changed(%WSlider.value)
		if has_node("%RotationSlider"):
			_on_rotation_changed(%RotationSlider.value)
			
	elif selected.get_text(0) == "Amazing Surf":
		current_fractal = "AmazingSurf"
		mat.shader = amazingsurf_shader
		print("Switched to Amazing Surf")
		if not is_playing_flythrough:
			await RenderingServer.frame_post_draw
			if not is_playing_flythrough:  # Check AGAIN after the await
				_sync_asurf_to_shader()
		
	elif selected.get_text(0) == "BristorBrot":
		current_fractal = "BristorBrot"
		mat.shader = bristorbrot_shader
		mat.set_shader_parameter("time_speed", %TimeSpeedSlider.value)
		mat.set_shader_parameter("draw_parallel", %ParallelToggle.button_pressed)
		# Restore current color picker values instead of resetting to defaults
		if has_node("%ColorPicker1"):
			var c1 = %ColorPicker1.color
			mat.set_shader_parameter("Color1", Vector3(c1.r, c1.g, c1.b))
		if has_node("%ColorPicker2"):
			var c2 = %ColorPicker2.color
			mat.set_shader_parameter("Color2", Vector3(c2.r, c2.g, c2.b))
		if has_node("%ColorPicker3"):
			var c3 = %ColorPicker3.color
			mat.set_shader_parameter("Color3", Vector3(c3.r, c3.g, c3.b))
		print("Switched to BristorBrot")
	
	elif selected.get_text(0) == "Archon":
		current_fractal = "Archon"
		mat.shader = archon_shader
		# Only set defaults and move camera on the very first load.
		# After that, switching back just restores the shader without touching values.
		if not archon_initialized:
			if main_camera:
				main_camera.global_position = Vector3(0.0, 0.0, 6.0)
				main_camera.rotation_degrees = Vector3.ZERO
			_sync_archon_to_shader()
			archon_initialized = true
		print("Switched to Archon")


	
	if OS.is_debug_build():
		diagnostic_check()

func _sync_asurf_to_shader():
	if is_playing_flythrough: return
	var mat = get_fractal_material()
	if not mat: return
	
	# Main
	_on_surf_power_changed(get_v("%PowerSlider", 0.0))
	_on_as_max_steps_changed(get_v("%ASMaxStepsSlider", 64))
	_on_as_detail_changed(get_v("%ASDetailSlider", -1.0))
	_on_surf_scale2_changed(get_v("%SurfScaleSlider2", 2.0))
	_on_surf_iterations_changed(get_v("%SurfIterationsSlider", 12))
	_on_surf_bailout_changed(get_v("%BailoutSlider", 4.0))
	
	# Surface
	_on_surf_scale_changed(get_v("%SurfScaleSlider", 0.0))
	_on_surf_strength_changed(get_v("%SurfStrengthSlider", 0.0))
	_on_surf_roughness_changed(get_v("%SurfRoughnessSlider", 0.0))
	_on_surf_octaves_changed(get_v("%SurfOctavesSlider", 4.0))
	_on_surf_speed_changed(get_v("%SurfSpeedSlider", 0.0))
	
	# Transforms
	_on_pre_offset_changed(0.0)
	_on_post_offset_changed(0.0)
	_on_asurf_rotation_changed(get_v("%ASurfRotationSlider", 0.0))
	_on_alpha_rotation_changed(get_v("%AlphaRotationSlider", 0.0))
	_on_beta_rotation_changed(get_v("%BetaRotationSlider", 0.0))
	_on_gamma_rotation_changed(get_v("%GammaRotationSlider", 0.0))
	
	# Folding
	_on_fold_limit_x_changed(get_v("%FoldLimitXSlider", 1.0))
	_on_fold_limit_y_changed(get_v("%FoldLimitYSlider", 1.0))
	_on_fold_limit_z_changed(get_v("%FoldLimitZSlider", 1.0))
	_on_fold_limit_w_changed(get_v("%FoldLimitWSlider", 1.0))
	_on_folding_value_changed(get_v("%FoldingValueSlider", 2.0))
	_on_offset2_changed(get_v("%Offset2Slider", 0.0))
	
	# Sphere Fold
	_on_min_radius_changed(get_v("%MinRadiusSlider", 0.5))
	_on_fixed_radius2_changed(get_v("%FixedRadiusSlider2", 1.0))
	_on_cylinder_weight_changed(get_v("%CylinderWeightSlider", 1.0))
	
	# KIFS
	_on_kifs_sides_changed(get_v("%KIFS_Sides_Slider", 6.0))
	_on_kifs_twist_changed(get_v("%KIFS_Twist_Slider", 0.0))
	
	# Julia
	_on_asurf_julia_changed(0.0)
	
	# States (toggles snap directly)
	if mat.get_shader_parameter("EnableZAxisFold") != null:
		mat.set_shader_parameter("EnableZAxisFold", get_b("%EnableZAxisToggle"))
	if mat.get_shader_parameter("EnableWAxisFold") != null:
		mat.set_shader_parameter("EnableWAxisFold", get_b("%EnableWAxisToggle"))
	if mat.get_shader_parameter("SphereFoldEnabled") != null:
		mat.set_shader_parameter("SphereFoldEnabled", get_b("%SphereFoldToggle"))
	if mat.get_shader_parameter("ForceCylinderFold") != null:
		mat.set_shader_parameter("ForceCylinderFold", get_b("%CylinderFoldToggle"))
	if mat.get_shader_parameter("JuliaMode") != null:
		mat.set_shader_parameter("JuliaMode", get_b("%ASurfJuliaToggle"))
	if mat.get_shader_parameter("FoldSlot1Enabled") != null:
		mat.set_shader_parameter("FoldSlot1Enabled", get_b("%FoldSlot1Toggle"))
	if mat.get_shader_parameter("FoldSlot2Enabled") != null:
		mat.set_shader_parameter("FoldSlot2Enabled", get_b("%FoldSlot2Toggle"))
	if mat.get_shader_parameter("FoldSlot3Enabled") != null:
		mat.set_shader_parameter("FoldSlot3Enabled", get_b("%FoldSlot3Toggle"))
	if mat.get_shader_parameter("FoldSlot4Enabled") != null:
		mat.set_shader_parameter("FoldSlot4Enabled", get_b("%FoldSlot4Toggle"))
	if mat.get_shader_parameter("FoldSlot5Enabled") != null:
		mat.set_shader_parameter("FoldSlot5Enabled", get_b("%FoldSlot5Toggle"))

	print("Amazing Surf shader synced to UI values.")


func _on_pfive_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		# SymmetryStrength is the new name for pfive in the shader
		mat.set_shader_parameter("SymmetryStrength", Vector3(value, value, value))
	
	if has_node("%PFiveLabel"):
		%PFiveLabel.text = "Symmetry: " + str(snapped(value, 0.01))

func _on_fold_offset_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		# Updating F_offset as a uniform vec3
		var offset_vec = Vector3(value, value, value)
		mat.set_shader_parameter("F_offset", offset_vec)
		print("F_offset set to: ", offset_vec)
		print("Shader confirms F_offset is: ", mat.get_shader_parameter("F_offset"))
	
	if has_node("%FoldOffsetLabel"):
		%FoldOffsetLabel.text = "Fold Offset: " + str(snapped(value, 0.01))


func _on_rotation_changed(value: float):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("RotationAngle", value)
	
	if has_node("%RotationLabel"):
		%RotationLabel.text = "4D Rotation: " + str(snapped(value, 0.01))

func _on_inv_param_a_changed(value: float):
	var mat = get_fractal_material()
	if mat: 
		mat.set_shader_parameter("InvParamA", value)
	
	if has_node("%ParamALabel"):
		%ParamALabel.text = "Min Radius: " + str(snapped(value, 0.01))

func _on_fixed_radius_changed(value: float):
	var mat = get_fractal_material()
	if mat: 
		mat.set_shader_parameter("InvScale", value)
	
	if has_node("%FixedRadiusLabel"):
		%FixedRadiusLabel.text = "Fixed Radius: " + str(snapped(value, 0.01))

func _on_menger_toggled(button_pressed: bool):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("MengerMode", button_pressed)

func _update_menger(_value = 0):
	var mat = get_fractal_material()
	if not mat: 
		return
	
	# Check if sliders exist before accessing them
	if not menger_scale_slider or not menger_offset_w_slider or not menger_iterations_slider:
		return
	if not menger_rotation_slider or not menger_julia_toggle or not menger_morph_slider:
		return
	
	# Set shader parameters from slider values
	mat.set_shader_parameter("MengerScale", menger_scale_slider.value)
	mat.set_shader_parameter("OffsetW", menger_offset_w_slider.value)
	mat.set_shader_parameter("Iterations", int(menger_iterations_slider.value))
	mat.set_shader_parameter("RotationAngle", menger_rotation_slider.value)
	mat.set_shader_parameter("JuliaMode", menger_julia_toggle.button_pressed)
	mat.set_shader_parameter("JuliaMorph", menger_morph_slider.value)
	
	# Update labels - Core Menger 4D
	if has_node("%MengerScalelabel"):
		%MengerScalelabel.text = "Sponge Scale: " + str(snapped(menger_scale_slider.value, 0.01))
	if has_node("%OffsetWlabel"):
		%OffsetWlabel.text = "4D Slice (W): " + str(snapped(menger_offset_w_slider.value, 0.01))
	if has_node("%Iterationslabel"):
		%Iterationslabel.text = "Complexity: " + str(int(menger_iterations_slider.value))
	if has_node("%Rotation4Dslabel"):
		%Rotation4Dslabel.text = "4D Rotation: " + str(snapped(menger_rotation_slider.value, 0.01))
	
	# Update Menger Offset 1 Vector Labels
	if menger_ox_slider and has_node("%MengerOffset1_xlabel"):
		%MengerOffset1_xlabel.text = "Offset X: " + str(snapped(menger_ox_slider.value, 0.01))
	if menger_oy_slider and has_node("%MengerOffset1_ylabel"):
		%MengerOffset1_ylabel.text = "Offset Y: " + str(snapped(menger_oy_slider.value, 0.01))
	if menger_oz_slider and has_node("%MengerOffset1_zlabel"):
		%MengerOffset1_zlabel.text = "Offset Z: " + str(snapped(menger_oz_slider.value, 0.01))
	if menger_ow_slider and has_node("%MengerOffset1_wlabel"):
		%MengerOffset1_wlabel.text = "Offset W: " + str(snapped(menger_ow_slider.value, 0.01))
	
	# Update MS4D Julia 4D Labels
	if menger_jx_slider and has_node("%MS4DJuliaXLabel"):
		%MS4DJuliaXLabel.text = "Julia X: " + str(snapped(menger_jx_slider.value, 0.01))
	if menger_jy_slider and has_node("%MS4DJuliaYLabel"):
		%MS4DJuliaYLabel.text = "Julia Y: " + str(snapped(menger_jy_slider.value, 0.01))
	if menger_jz_slider and has_node("%MS4DJuliaZLabel"):
		%MS4DJuliaZLabel.text = "Julia Z: " + str(snapped(menger_jz_slider.value, 0.01))
	if menger_jw_slider and has_node("%MS4DJuliaWLabel"):
		%MS4DJuliaWLabel.text = "Julia W: " + str(snapped(menger_jw_slider.value, 0.01))
	
	# Update Morph label (this was missing in the original)
	if has_node("%MS4DMorphLabel"):
		%MS4DMorphLabel.text = "Julia Influence: " + str(int(menger_morph_slider.value * 100)) + "%"
	
	# Create Vector4s for the 4D math - only if sliders exist
	if menger_ox_slider and menger_oy_slider and menger_oz_slider and menger_ow_slider:
		var m_offset = Vector4(
			menger_ox_slider.value,
			menger_oy_slider.value,
			menger_oz_slider.value,
			menger_ow_slider.value
		)
		mat.set_shader_parameter("MengerOffset1", m_offset)
	
	if menger_jx_slider and menger_jy_slider and menger_jz_slider and menger_jw_slider:
		var j_seed = Vector4(
			menger_jx_slider.value,
			menger_jy_slider.value,
			menger_jz_slider.value,
			menger_jw_slider.value
		)
		mat.set_shader_parameter("JuliaSeed", j_seed)

func diagnostic_check():
	var mat = get_fractal_material()
	if not mat:
		print("DIAGNOSTIC: No material found!")
		return
	
	print("--- Hyperion Shader Diagnostic ---")
	print("Active Fractal: ", current_fractal)
	print("Current Shader: ", mat.shader.resource_path)
	
	# Camera info
	if main_camera:
		print("Camera Position: ", main_camera.global_position)
		print("Camera Forward: ", -main_camera.global_transform.basis.z)
	
	# Check Global Environment
	print("Reflectivity: ", mat.get_shader_parameter("Reflectivity"))
	print("FogDensity: ", mat.get_shader_parameter("FogDensity"))
	print("OffsetW: ", mat.get_shader_parameter("OffsetW"))
	print("ColorCycle: ", mat.get_shader_parameter("ColorCycle"))
	print("PaletteType: ", mat.get_shader_parameter("PaletteType"))
	
	# Check Symmetry State
	print("Symmetry X Active: ", mat.get_shader_parameter("F_X"))
	print("Symmetry Y Active: ", mat.get_shader_parameter("F_Y"))
	print("Symmetry Z Active: ", mat.get_shader_parameter("F_Z"))
	print("SymmetryStrength Vector: ", mat.get_shader_parameter("SymmetryStrength"))
	print("Fold Offset: ", mat.get_shader_parameter("F_offset"))
	
	# Check Fractal-Specific Parameters
	var shader_path = mat.shader.resource_path
	if "Mandelbox" in shader_path:
		print("Scale: ", mat.get_shader_parameter("Scale"))
		print("BoxFoldLimit: ", mat.get_shader_parameter("BoxFoldLimit"))
		print("Iterations: ", mat.get_shader_parameter("Iterations"))
		print("RotationAngle: ", mat.get_shader_parameter("RotationAngle"))
		print("JuliaMode: ", mat.get_shader_parameter("JuliaMode"))
		print("InvType: ", mat.get_shader_parameter("InvType"))
		print("InvParamA: ", mat.get_shader_parameter("InvParamA"))
		print("InvParamB: ", mat.get_shader_parameter("InvParamB"))
		print("InvScale: ", mat.get_shader_parameter("InvScale"))
	elif "menger" in shader_path:
		print("MengerScale: ", mat.get_shader_parameter("MengerScale"))
		print("Iterations: ", mat.get_shader_parameter("Iterations"))
		print("RotationAngle: ", mat.get_shader_parameter("RotationAngle"))
		print("JuliaMode: ", mat.get_shader_parameter("JuliaMode"))
		print("JuliaMorph: ", mat.get_shader_parameter("JuliaMorph"))
	
	# Note: SCREEN_TEXTURE is automatically provided by Godot's hint_screen_texture
	# It cannot be queried via get_shader_parameter() - this is normal behavior
	print("Note: SCREEN_TEXTURE is auto-provided by hint_screen_texture (cannot be queried)")
	print("----------------------------------")

func advanced_diagnostic():
	var mat = get_fractal_material()
	if not mat:
		return
	
	var shader_rid = mat.get_shader_rid()
	
	# Check if the engine thinks the uniform is valid
	var has_offset_w = RenderingServer.shader_get_parameter_default(shader_rid, "OffsetW")
	var has_screen_tex = RenderingServer.shader_get_parameter_default(shader_rid, "SCREEN_TEXTURE")
	
	print("--- Hyperion System Check ---")
	print("GPU recognizes OffsetW: ", has_offset_w != null)
	print("GPU recognizes SCREEN_TEXTURE: ", has_screen_tex != null)
	print("-----------------------------")
func _on_saturation_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("Saturation", value)
	if has_node("%SaturationLabel"):
		%SaturationLabel.text = "Saturation: " + str(snapped(value, 0.01))

func _on_contrast_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("Contrast", value)
	if has_node("%ContrastLabel"):
		%ContrastLabel.text = "Contrast: " + str(snapped(value, 0.01))

func _on_brightness_changed(value: float):
	var mat = get_fractal_material()
	if mat: mat.set_shader_parameter("Brightness", value)
	if has_node("%BrightnessLabel"):
		%BrightnessLabel.text = "Brightness: " + str(snapped(value, 0.01))


func _on_add_waypoint_pressed():
	if not main_camera: return
	
	var point = {
		"pos": main_camera.global_position,
		"rot": main_camera.global_transform.basis,
		"fractal_type": current_fractal,
		"w": get_v("%WSlider"),
		
		"floats": {
			# Main
			"SymmetryStrength": Vector3(get_v("%PFiveSlider"), get_v("%PFiveSlider"), get_v("%PFiveSlider")),
			"F_offset": Vector3(get_v("%FoldOffsetSlider"), get_v("%FoldOffsetSlider"), get_v("%FoldOffsetSlider")),
			"Power": get_v("%PowerSlider"),
			"Scale": get_v("%SurfScaleSlider2", 2.0) if current_fractal == "AmazingSurf" else (get_v("%ScaleSlider", 2.5) if current_fractal == "Mandelbox" else (get_v("%ArchonScaleSlider", 2.0) if current_fractal == "Archon" else 1.0)),
			"Bailout": get_v("%BailoutSlider", 4.0) if current_fractal == "AmazingSurf" else (get_v("%ArchonBailoutSlider", 8.0) if current_fractal == "Archon" else get_v("%BailoutSlider", 100.0)),
			"ScaleVary": get_v("%ScaleVarySlider"),
			"DEMultiplier": get_v("%DEMultiplierSlider", 1.0),
			"MengerScale": get_v("%MengerScaleSlider", 3.0) if current_fractal == "Menger" else 3.0,
			"BoxFoldLimit": get_v("%BoxFoldSlider", 1.0) if current_fractal == "Mandelbox" else 1.0,
			"InvParamA": get_v("%InvParamA"),
			"InvScale": get_v("%FixedRadiusSlider"),
			"InvRadius": get_v("%ArchonInvRadiusSlider", 1.2),
			"InvStrength": get_v("%ArchonInvStrengthSlider", 0.8),
			"RotationAngle": get_v("%Rotations4DSlider", 0.0) if current_fractal == "Menger" else (get_v("%ASurfRotationSlider", 0.0) if current_fractal == "AmazingSurf" else (get_v("%ArchonRotationSlider", 0.3) if current_fractal == "Archon" else get_v("%RotationSlider", 0.0))),
			"Reflectivity": get_v("%ReflectSlider"),
			"FogDensity": get_v("%FogSlider"),
			"Brightness": get_v("%BrightnessSlider", 1.0),
			"Iterations": int(get_v("%IterationsSlider", 8)) if current_fractal == "Menger" else (int(get_v("%SurfIterationsSlider", 6)) if current_fractal == "AmazingSurf" else (int(get_v("%ArchonIterationsSlider", 20)) if current_fractal == "Archon" else int(get_v("%StepsSlider", 17)))),
			"MaxSteps": int(get_v("%MengerMaxStepsSlider", 256)) if current_fractal == "Menger" else (int(get_v("%ASMaxStepsSlider", 64)) if current_fractal == "AmazingSurf" else (int(get_v("%ArchonMaxStepsSlider", 200)) if current_fractal == "Archon" else int(get_v("%StepsSlider", 256)))),
			"Detail": get_v("%MengerDetailSlider", -2.5) if current_fractal == "Menger" else (get_v("%ASDetailSlider", -1.0) if current_fractal == "AmazingSurf" else (get_v("%ArchonDetailSlider", -1.0) if current_fractal == "Archon" else get_v("%DetailSlider", -2.5))),

			# Archon-specific (safe to always include — ignored by other shaders)
			"TowerBias": get_v("%ArchonTowerBiasSlider", 0.0),
			"SpinStrength": get_v("%ArchonSpinStrengthSlider", 0.0),
			"ArchFrequency": get_v("%ArchonArchFreqSlider", 1.5),
			"ArchDepth": get_v("%ArchonArchDepthSlider", 0.4),
			"WRotationSpeed": get_v("%ArchonWRotationSpeedSlider", 0.0),
			"WaveBlend": get_v("%ArchonWaveBlendSlider", 1.0),
			"JuliaMorph": get_v("%ArchonJuliaMorphSlider", 0.0) if current_fractal == "Archon" else get_v("%MS4DMorphSlider"),
			"JuliaSeed": Vector4(
				get_v("%ArchonJuliaXSlider"), get_v("%ArchonJuliaYSlider"),
				get_v("%ArchonJuliaZSlider"), get_v("%ArchonJuliaWSlider")
			) if current_fractal == "Archon" else (Vector4(
				get_v("%MS4DJuliaXSlider"), get_v("%MS4DJuliaYSlider"),
				get_v("%MS4DJuliaZSlider"), get_v("%MS4DJuliaWSlider")
			) if current_fractal == "Menger" else Vector4(
				get_v("%ASurfJuliaXSlider"), get_v("%ASurfJuliaYSlider"),
				get_v("%ASurfJuliaZSlider"), 0.0
			)),
			"ArchonConstant": Vector4(
				get_v("%ArchonConstantXSlider", 1.0),
				get_v("%ArchonConstantYSlider", 1.3),
				get_v("%ArchonConstantZSlider", 0.8),
				get_v("%ArchonConstantWSlider", 0.2)
			),

			# City Tiling
			"CellSize": get_v("%ArchonCellSizeSlider", 4.0),
			"CellRotVariance": get_v("%ArchonCellRotVarianceSlider", 0.8),
			"CellConstantVariance": get_v("%ArchonCellConstantVarianceSlider", 0.3),
			"CellHeightVariance": get_v("%ArchonCellHeightVarianceSlider", 0.4),
			"AlleyWidth": get_v("%ArchonAlleyWidthSlider", 0.15),

			# Folding
			"FoldLimit4D": Vector4(
				get_v("%FoldLimitXSlider", 1.0),
				get_v("%FoldLimitYSlider", 1.0),
				get_v("%FoldLimitZSlider", 1.0),
				get_v("%FoldLimitWSlider", 1.0)
			),
			"FoldingValue": get_v("%FoldingValueSlider"),
			"Offset2": get_v("%Offset2Slider"),

			# Transforms
			"PreOffset": Vector3(get_v("%PreOffsetXSlider"), get_v("%PreOffsetYSlider"), get_v("%PreOffsetZSlider")),
			"PostOffset": Vector3(get_v("%PostOffsetXSlider"), get_v("%PostOffsetYSlider"), get_v("%PostOffsetZSlider")),
			"EulerRotation": Vector3(get_v("%AlphaRotationSlider"), get_v("%BetaRotationSlider"), get_v("%GammaRotationSlider")),
			"KIFS_Sides": get_v("%KIFS_Sides_Slider", 6.0),
			"KIFS_Twist": get_v("%KIFS_Twist_Slider", 0.0),
			"KIFS_Axis": float(max(0, %KIFS_Axis_Selector.selected)) if has_node("%KIFS_Axis_Selector") else 0.0,

			# Warp / BristorBrot
			"WOffset": get_v("%WOffsetSlider"),
			"WarpStrength": get_v("%RibbonWarpStrengthSlider") if current_fractal == "AmazingSurf" else get_v("%WarpStrengthSlider"),
			"WarpFrequency": get_v("%RibbonWarpFrequencySlider") if current_fractal == "AmazingSurf" else get_v("%WarpFrequencySlider"),
			"RibbonTwist": get_v("%RibbonTwistSlider") if current_fractal == "AmazingSurf" else 0.0,
			"RotationXW": get_v("%RotationXWSlider"),
			"RotationYW": get_v("%RotationYWSlider"),
			"RotationZW": get_v("%RotationZWSlider"),
			"RippleFrequency": get_v("%RippleFrequencySlider"),
			"RippleAmplitude": get_v("%RippleAmplitudeSlider"),
			"KIFS_Angle_X": get_v("%KIFSAngleXSlider"),
			"KIFS_Angle_Y": get_v("%KIFSAngleYSlider"),
			"KIFS_Angle_Z": get_v("%KIFSAngleZSlider"),

			# Amazing Surf surface
			"SurfScale": get_v("%SurfScaleSlider"),
			"SurfStrength": get_v("%SurfStrengthSlider"),
			"SurfRoughness": get_v("%SurfRoughnessSlider"),
			"SurfSpeed": get_v("%SurfSpeedSlider"),

			# Menger specific
			"MengerOffset1": Vector4(
				get_v("%MengerOffset1_xSlider", 1.0),
				get_v("%MengerOffset1_ySlider", 1.0),
				get_v("%MengerOffset1_zSlider", 1.0),
				get_v("%MengerOffset1_wSlider", 1.0),
			),

			# Rendering / Post
			"SliceW": get_v("%SliceWSlider"),
			"VolumeDensity": get_v("%VolumeDensitySlider"),
			"Saturation": get_v("%SaturationSlider", 1.0),
			"Contrast": get_v("%ContrastSlider", 1.0),
			"ShapeRadius": get_v("%ShapeRadiusSlider", 1.0),
			"ShapeThickness": get_v("%ShapeThicknessSlider", 0.4),
			"ShapeBend": get_v("%ShapeBendSlider", 0.0),
			"GrainIntensity": get_v("%GrainIntensitySlider", 0.0),
			"TentacleCount": get_v("%TentacleCountSlider", 0.0),
			"TentacleLength": get_v("%TentacleLengthSlider", 0.0),
			"TentacleTwist": get_v("%TentacleTwistSlider", 0.0),
			"ShapeOffset": Vector3(
				get_v("%ShapeOffsetXSlider", 0.0),
				get_v("%ShapeOffsetYSlider", 0.0),
				get_v("%ShapeOffsetZSlider", 0.0)),
			"ShapeEnabled": get_b("%ShapeEnabledCheck"),
			"ShapeType": max(0, %ShapeTypeButton.selected) if has_node("%ShapeTypeButton") else 0,

		},
		
		"states": {
			"JuliaMode": get_b("%ArchonJuliaToggle") if current_fractal == "Archon" else (get_b("%MS4DJuliaToggle") if current_fractal == "Menger" else get_b("%ASurfJuliaToggle")),
			"SphereFoldEnabled": get_b("%SphereFoldToggle"),
			"FoldSlot1Enabled": get_b("%FoldSlot1Toggle"),
			"FoldSlot2Enabled": get_b("%FoldSlot2Toggle"),
			"FoldSlot3Enabled": get_b("%FoldSlot3Toggle"),
			"FoldSlot4Enabled": get_b("%FoldSlot4Toggle"),
			"FoldSlot5Enabled": get_b("%FoldSlot5Toggle"),
			"RenderingMethod": %RenderingMethodSelector.selected if has_node("%RenderingMethodSelector") else 0,
			"F_absX": get_b("%AbsXToggle"),
			"F_absY": get_b("%AbsYToggle"),
			"F_absZ": get_b("%AbsZToggle"),
			"F_X": get_b("%XSwapToggle"),
			"F_Y": get_b("%YSwapToggle"),
			"F_Z": get_b("%ZSwapToggle"),

			# Amazing Surf Folding
			"EnableZAxisFold": get_b("%EnableZAxisToggle"),
			"EnableWAxisFold": get_b("%EnableWAxisToggle"),
			"ForceCylinderFold": get_b("%CylinderFoldToggle"),

			# Fold Types
			"FoldType1": %FoldType1Selector.selected if has_node("%FoldType1Selector") else 0,
			"FoldType2": %FoldType2Selector.selected if has_node("%FoldType2Selector") else 0,
			"FoldType3": %FoldType3Selector.selected if has_node("%FoldType3Selector") else 0,

			# DE & Bristor
			"DEMethod": %DEMethodSelector.selected if has_node("%DEMethodSelector") else 0,
			"draw_parallel": get_b("%ParallelToggle"),

			# Archon
			"ArchonWaveType": %ArchonWaveTypeSelector.selected if has_node("%ArchonWaveTypeSelector") else 0,
			"CityEnabled": get_b("%ArchonCityEnabledToggle"),
			"ArchonType": max(0, %ArchonTypeSelector.selected) if has_node("%ArchonTypeSelector") else 0,
		}
	}
	
	# Debug Comparison Logic
	if waypoints.size() > 0:
		var last = waypoints[-1]
		print("\n--- WAYPOINT #", waypoints.size() + 1, " DIFF REPORT ---")
		
		if last.pos.distance_to(point.pos) > 0.01:
			print("  [MOVE] Dist: ", last.pos.distance_to(point.pos))
		
		var angle_diff = last.rot.get_rotation_quaternion().angle_to(point.rot.get_rotation_quaternion())
		if angle_diff > 0.01:
			print("  [ROT] Angle Change: ", rad_to_deg(angle_diff), " degrees")
		else:
			print("  [!] WARNING: No rotation detected between points.")

		for f in point.floats:
			if last.floats.has(f) and last.floats[f] != point.floats[f]:
				print("  [PARAM] ", f, ": ", last.floats[f], " -> ", point.floats[f])
	
	waypoints.append(point)
	print("SUCCESS: Waypoint #", waypoints.size(), " recorded.\n")
	
	# Full debug dump
	print("=== FULL WAYPOINT #", waypoints.size(), " DUMP ===")
	print("  POS: ", point.pos)
	print("  ROT: ", point.rot)
	print("  W: ", point.w)
	print("  --- FLOATS ---")
	for key in point.floats:
		print("    ", key, " = ", point.floats[key])
	print("  --- STATES ---")
	for key in point.states:
		print("    ", key, " = ", point.states[key])
	print("=== END DUMP ===\n")

func load_waypoint(index: int):
	if index < 0 or index >= waypoints.size(): return
	var p = waypoints[index]
	var mat = get_fractal_material()
	if not mat: return

	# Create a tween for smooth transitions
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 1. Animate Camera Position and Rotation
	tween.tween_property(main_camera, "global_position", p.pos, 2.0)
	# For Basis (Rotation), we use a helper or interpolate_with
	main_camera.global_transform.basis = main_camera.global_transform.basis.slerp(p.rot, 1.0) # Simplified for this snippet

	# 2. Animate Floats and Vectors (The "Melt" effect)
	for key in p.floats:
		var start_val = mat.get_shader_parameter(key)
		var end_val = p.floats[key]
		
		# We use a method tween to update shader uniforms every frame
		tween.tween_method(
			func(v): mat.set_shader_parameter(key, v),
			start_val, 
			end_val, 
			2.0
		)

	# 3. Snap States (Toggles/Integers)
	# These usually can't be tweened (you're either in Julia mode or you aren't)
	for key in p.states:
		mat.set_shader_parameter(key, p.states[key])
		
	# 4. Update the UI Sliders to match the new position
	update_ui_to_match_shader()
func sync_ui_to_shader():
	var mat = get_fractal_material()
	if not mat: return
	
	# This loops through all sliders in the scene
	# If a slider's name (minus "Slider") matches a shader param, it updates it.
	for node in get_tree().get_nodes_in_group("auto_sync_sliders"): 
		# Tip: Add your sliders to a group named "auto_sync_sliders" in the editor
		var p_name = node.name.replace("Slider", "")
		var val = mat.get_shader_parameter(p_name)
		
		if val != null and val is float:
			node.set_value_no_signal(val)
			
	# Update special cases manually
	var seed = mat.get_shader_parameter("JuliaSeed")
	if seed is Vector3:
		if has_node("%ASurfJuliaXSlider"): %ASurfJuliaXSlider.value = seed.x
		if has_node("%ASurfJuliaYSlider"): %ASurfJuliaYSlider.value = seed.y
		if has_node("%ASurfJuliaZSlider"): %ASurfJuliaZSlider.value = seed.z
	
	# Update Julia Toggle
	%ASurfJuliaToggle.button_pressed = mat.get_shader_parameter("JuliaMode")
	# Sync the Ribbon-specific sliders from shader params
	var ws = mat.get_shader_parameter("WarpStrength")
	if ws != null: set_s_val("%RibbonWarpStrengthSlider", ws)
	
	var wf = mat.get_shader_parameter("WarpFrequency")
	if wf != null: set_s_val("%RibbonWarpFrequencySlider", wf)
	
	var rt = mat.get_shader_parameter("RibbonTwist")
	if rt != null: set_s_val("%RibbonTwistSlider", rt)

func play_flythrough():
	print("--- DEBUG: Flythrough Starting ---")
	if waypoints.size() < 2:
		print("ERROR: Not enough waypoints. Count: ", waypoints.size())
		return
	
	var mat = get_fractal_material()
	if not mat:
		print("ERROR: Fractal Material not found!")
		return

	if animation_tween:
		animation_tween.kill()
	
	is_playing_flythrough = true
	
	# Snap to first waypoint immediately
	# Only snap camera to first waypoint, leave shader params as-is
	var first = waypoints[0]
	
	# Smoothly reset all shader params to waypoint 1 values first
	var reset_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var reset_tween_has_tweeners = false
	var mat_check = mat
	for param in first.floats:
		if mat_check.get_shader_parameter(param) == null:
			continue
		var current_val = mat_check.get_shader_parameter(param)
		var target_val = first.floats[param]
		if str(current_val) == str(target_val):
			continue
		if typeof(current_val) != typeof(target_val):
			mat_check.set_shader_parameter(param, target_val)
			continue
		reset_tween_has_tweeners = true
		if current_val is Vector4:
			var cv = current_val; var tv = target_val
			reset_tween.tween_method(
				func(t, c=cv, tg=tv, p=param):
					mat_check.set_shader_parameter(p, Vector4(
						lerp(c.x,tg.x,t), lerp(c.y,tg.y,t),
						lerp(c.z,tg.z,t), lerp(c.w,tg.w,t))),
				0.0, 1.0, 1.5)
		elif current_val is Vector3:
			var cv = current_val; var tv = target_val
			reset_tween.tween_method(
				func(t, c=cv, tg=tv, p=param):
					mat_check.set_shader_parameter(p, Vector3(
						lerp(c.x,tg.x,t), lerp(c.y,tg.y,t), lerp(c.z,tg.z,t))),
				0.0, 1.0, 1.5)
		else:
			var cv = current_val; var tv = target_val
			reset_tween.tween_method(
				func(v, p=param): mat_check.set_shader_parameter(p, v),
				cv, tv, 1.5)

	# Only snap camera and wait if there was actually something to tween
	main_camera.global_position = first.pos
	main_camera.global_transform.basis = first.rot

	if reset_tween_has_tweeners:
		await get_tree().create_timer(1.6).timeout
	else:
		reset_tween.kill()  # Destroy the empty tween to prevent the crash
	
	# Wait for the reset to finish before starting segments
	await get_tree().create_timer(1.6).timeout
	
	# Now build sequential tween segment by segment
	_play_segment(0, mat)

const MENGER_PARAMS = ["MengerScale", "Iterations", "RotationAngle", "Detail", "MaxSteps",
	"OffsetW", "JuliaMorph", "MengerOffset1", "JuliaSeed", "JuliaMode",
	"Reflectivity", "FogDensity", "Brightness", "ColorCycle", "Saturation", 
	"Contrast", "KIFS_Angle_X", "KIFS_Angle_Y", "KIFS_Angle_Z",
	"SymmetryStrength", "F_offset",
	"ShapeEnabled", "ShapeRadius", "ShapeThickness", "ShapeBend",
	"ShapeOffset", "GrainIntensity", "TentacleCount", "TentacleLength", "TentacleTwist",
	"ShapeType"]
const MENGER_STATES = ["JuliaMode", "F_absX", "F_absY", "F_absZ", "F_X", "F_Y", "F_Z", "ShapeType", "ShapeEnabled"]
func _play_segment(index: int, mat: ShaderMaterial):
	if index >= waypoints.size() - 1:
		var last = waypoints[waypoints.size() - 1]
		for param in last.floats:
			if last.get("fractal_type", "") == "Menger" and param not in MENGER_PARAMS:
				continue
			if mat.get_shader_parameter(param) != null:
				mat.set_shader_parameter(param, last.floats[param])
		for state in last.states:
			if last.get("fractal_type", "") == "Menger" and state not in MENGER_STATES:
				continue
			mat.set_shader_parameter(state, last.states[state])
		await get_tree().create_timer(0.1).timeout
		is_playing_flythrough = false
		print("--- Flythrough Complete ---")
		return
		
		


	var prev = waypoints[index]
	var next = waypoints[index + 1]
	var duration = 5.0
	
	print(">> PLAYING SEGMENT ", index + 1, ":")
	print("   Cam Move: ", prev.pos, " -> ", next.pos)

	animation_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	animation_tween.tween_property(main_camera, "global_position", next.pos, duration)
	
	var q_start = prev.rot.get_rotation_quaternion()
	var q_end = next.rot.get_rotation_quaternion()
	animation_tween.tween_method(
		func(t, qs = q_start, qe = q_end):
			main_camera.global_transform.basis = Basis(qs.slerp(qe, t)),
		0.0, 1.0, duration
	)
	
	var mat_skip = []
	for param in next.floats:
		if mat.get_shader_parameter(param) == null:
			mat_skip.append(param)
	
	for param in next.floats:
		# ✅ Skip params that don't belong to Menger
		if next.get("fractal_type", "") == "Menger" and param not in MENGER_PARAMS:
			continue
			
		var start_val = prev.floats.get(param, null)
		var end_val = next.floats[param]
		
		if start_val == null:
			continue
		if param in mat_skip:
			continue
		if typeof(start_val) != typeof(end_val):
			mat.set_shader_parameter(param, end_val)
			continue
		if str(start_val) == str(end_val):
			continue
		
		print("   [TWEENING] ", param, ": ", start_val, " -> ", end_val)
		var p_captured = param
		
		if start_val is Vector3:
			var sv = start_val
			var ev = end_val
			animation_tween.tween_method(
				func(t, s = sv, e = ev, pname = p_captured):
					mat.set_shader_parameter(pname, Vector3(
						lerp(s.x, e.x, t), lerp(s.y, e.y, t), lerp(s.z, e.z, t)
					)),
				0.0, 1.0, duration
			)
		elif start_val is Vector4:
			var sv = start_val
			var ev = end_val
			animation_tween.tween_method(
				func(t, s = sv, e = ev, pname = p_captured):
					mat.set_shader_parameter(pname, Vector4(
						lerp(s.x, e.x, t), lerp(s.y, e.y, t),
						lerp(s.z, e.z, t), lerp(s.w, e.w, t)
					)),
				0.0, 1.0, duration
			)
		else:
			animation_tween.tween_method(
				func(v, pname = p_captured): mat.set_shader_parameter(pname, v),
				start_val, end_val, duration
			)
	
	# ✅ Skip states that don't belong to Menger
	for state in next.states:
		if next.get("fractal_type", "") == "Menger" and state not in MENGER_STATES:
			continue
		mat.set_shader_parameter(state, next.states[state])
	
	# Archon: remap stored state name to actual shader param name
	# Archon: remap stored state name to actual shader param name
	if next.states.has("ArchonWaveType"):
		mat.set_shader_parameter("WaveType", next.states["ArchonWaveType"])
	# Always explicitly set ArchonType — default to 0 (Organic) if not in waypoint
	# This handles waypoints recorded before ArchonType was added to the dict
	mat.set_shader_parameter("ArchonType", max(0, next.states.get("ArchonType", 0)))


	var seq_tween = create_tween()
	seq_tween.tween_interval(duration)
	seq_tween.tween_callback(func(ni = index + 1, m = mat): _play_segment(ni, m))
			
func _on_clear_path_pressed():
	waypoints.clear()
	print("Animation path cleared.")
	
func save_animation_path(path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		# Convert our Basis objects to something JSON-friendly
		var save_data = []
		for p in waypoints:
			save_data.append({
				"pos": var_to_str(p.pos),
				"rot": var_to_str(p.rot),
				"w": p.w,
				"sat": p.sat,
				"con": p.con
			})
		file.store_string(JSON.stringify(save_data))
		print("Animation path saved to: ", path)

		
func start_video_capture():
	var screen_res = get_viewport().size
	# If using a plugin like GodotVideoRecorder:
	# recorder.start_recording("user://temp_output.mp4", screen_res, 60.0)
	print("Capturing at: ", screen_res.x, "x", screen_res.y)
func stop_video_capture():
	# This is where you tell the plugin to finalize the MP4
	print("Recording stopped and finalized.")
	# If using the FFmpeg extension, you'd call its 'stop' method here
func _stitch_frames_to_video(save_path: String):
	var global_rec_dir = ProjectSettings.globalize_path(recording_dir)
	var input_path = global_rec_dir.path_join("frame_%05d.png")
	
	# 1. Determine the FFmpeg command path
	var ffmpeg_command = "ffmpeg" # Default for Windows/Linux
	
	if OS.get_name() == "macOS":
		# Search common Homebrew installation paths for Intel and Apple Silicon Macs
		var mac_paths = [
			"/opt/homebrew/bin/ffmpeg",  # Apple Silicon (M1/M2/M3)
			"/usr/local/bin/ffmpeg",    # Intel Macs
			"/usr/bin/ffmpeg"           # System default
		]
		
		for path in mac_paths:
			if FileAccess.file_exists(path):
				ffmpeg_command = path
				print("DEBUG: Found FFmpeg at Mac-specific path: ", path)
				break
	
	# 2. Set up the conversion arguments
	# -y: Overwrite existing file
	# -framerate: Tells FFmpeg the input images represent 30fps
	# -i: The input image sequence
	# -c:v: Use H.264 codec
	# -pix_fmt: Use yuv420p for maximum compatibility with players
	# -r: Force the output video to strictly 30fps
	var ffmpeg_args = [
		"-y", 
		"-framerate", "12", 
		"-i", input_path, 
		"-c:v", "libx264", 
		"-pix_fmt", "yuv420p", 
		"-r", "12", 
		save_path 
	]
	
	print("DEBUG: Executing FFmpeg command: ", ffmpeg_command)
	
	var output = []
	var exit_code = OS.execute(ffmpeg_command, ffmpeg_args, output, true)
	
	# 3. Handle result
	if exit_code == 0:
		print("SUCCESS: Video saved successfully!")
		# Automatically open the folder containing the new video
		OS.shell_open(ProjectSettings.globalize_path(save_path.get_base_dir()))
	else:
		# Log the error for debugging
		printerr("FFmpeg ERROR Code: ", exit_code)
		for line in output:
			printerr("FFmpeg Output: ", line)
			
		var err_msg = "FFmpeg failed (Code " + str(exit_code) + ")."
		if OS.get_name() == "macOS" and ffmpeg_command == "ffmpeg":
			err_msg += "\n\nMac users: Ensure FFmpeg is installed via Homebrew ('brew install ffmpeg')."
			
		OS.alert(err_msg, "Export Error")
		
func _on_record_timer_timeout():
	if not is_recording: return

	# 1. Manually step the animation by exactly 1/30th of a second
	if animation_tween and animation_tween.is_valid():
		animation_tween.custom_step(0.033333)

	# 2. Capture the "Clean" frame without UI
	%PanelContainer.hide()
	%OverlayStopButton.hide()
	
	await RenderingServer.frame_post_draw
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("user://recordings/frame_%05d.png" % frame_counter)
	
	# 3. Restore the Stop Button for the user
	%OverlayStopButton.show()
	frame_counter += 1
	
func prepare_recording_dir():
	var dir = DirAccess.open("user://")
	if not dir:
		printerr("CRITICAL: Cannot open 'user://' directory.")
		return false

	# Ensure the subdirectory exists
	if not dir.dir_exists("recordings"):
		dir.make_dir("recordings")
	
	# Open the recordings folder to clean it
	var rec_dir = DirAccess.open("user://recordings")
	if rec_dir:
		rec_dir.list_dir_begin()
		var file_name = rec_dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				rec_dir.remove(file_name)
			file_name = rec_dir.get_next()
		print("Cleaned old frames from recordings directory.")
	return true
	
func _on_record_button_toggled(is_pressed: bool):
	is_recording = is_pressed
	
	if is_recording:
		# --- STARTING RECORDING ---
		%RecordButton.text = "Stop Recording"
		
		# FORCE UI CHANGES FOR DESKTOP
		if has_node("%PanelContainer"): %PanelContainer.visible = false
		if has_node("%OverlayStopButton"): %OverlayStopButton.visible = true
		
		frame_counter = 0
		if prepare_recording_dir():
			%RecordTimer.start()
			print("Recording started at 30 FPS...")
			
	else:
		# --- STOPPING RECORDING ---
		%RecordButton.text = "Start Recording"
		
		# RESTORE UI
		if has_node("%PanelContainer"): %PanelContainer.visible = true
		if has_node("%OverlayStopButton"): %OverlayStopButton.visible = false
		
		%RecordTimer.stop()
		print("Recording finished. %d frames saved." % frame_counter)
		
		# Open the dialog to name your MP4
		%SaveVideoDialog.popup_centered()
func _on_save_video_dialog_file_selected(path: String):
	# This path is where the user wants the final MP4
	_stitch_frames_to_video(path)


# Helper to safely get slider values without crashing if one is missing
func get_v(node_path: String, default: float = 0.0) -> float:
	var node = get_node_or_null(node_path)
	if node and "value" in node:
		return node.value
	return default

# Helper to safely get toggle states
func get_b(node_path: String, default: bool = false) -> bool:
	var node = get_node_or_null(node_path)
	if node and "button_pressed" in node:
		return node.button_pressed
	return default


func save_preset(path: String):
	var config = ConfigFile.new()
	var mat = get_fractal_material()
	if not mat: return

	# ... (Metadata and Camera sections remain the same) ...

	# 4. Save Special UI States
	config.set_value("UIState", "PaletteType", %PaletteSelector.selected if has_node("%PaletteSelector") else 0)
	config.set_value("UIState", "TimeSpeed", %TimeSpeedSlider.value)
	config.set_value("UIState", "IsParallel", %ParallelToggle.button_pressed)
	
	# FORCE SAVE Color Pickers
	if has_node("%ColorPicker1"):
		config.set_value("ShaderParams", "shader_parameter/Color1", %ColorPicker1.color)
	if has_node("%ColorPicker2"):
		config.set_value("ShaderParams", "shader_parameter/Color2", %ColorPicker2.color)
	if has_node("%ColorPicker3"):
		config.set_value("ShaderParams", "shader_parameter/Color3", %ColorPicker3.color)

	# --- FIXED SHAPE SETTINGS (Converted from Dictionary to ConfigValue) ---
	# These are now correctly formatted for ConfigFile
	config.set_value("UIState", "ShapeEnabled", %ShapeEnabledCheck.button_pressed)
	var shape_type_val = %ShapeTypeButton.selected if has_node("%ShapeTypeButton") else 0
	config.set_value("UIState", "ShapeType", max(0, shape_type_val))
	config.set_value("UIState", "ShapeBend", %ShapeBendSlider.value)
	config.set_value("UIState", "GrainIntensity", %GrainIntensitySlider.value)
	config.set_value("UIState", "TentacleCount", %TentacleCountSlider.value)
	config.set_value("UIState", "TentacleLength", %TentacleLengthSlider.value)
	config.set_value("UIState", "TentacleTwist", %TentacleTwistSlider.value)
	
	config.set_value("UIState", "Contrast", %ContrastSlider.value if has_node("%ContrastSlider") else 1.0)

	# Gradient check
	var grad_tex = mat.get_shader_parameter("GradientTexture") 
	if grad_tex and grad_tex is GradientTexture1D:
		config.set_value("UIState", "CustomGradientData", grad_tex.gradient)
	
	
	# === ARCHON ===
	if current_fractal == "Archon":
		config.set_value("Metadata", "shader_path", archon_shader.resource_path)
		config.set_value("Metadata", "fractal_type", "Archon")
		
		if main_camera:
			config.set_value("Camera", "pos",   main_camera.global_position)
			config.set_value("Camera", "basis", main_camera.global_transform.basis)
		
		# Save every Archon-specific param explicitly so nothing is missed
		var archon_params = [
			"Scale","ArchonType", "Iterations", "Bailout", "TowerBias", "ArchonConstant",
			"SpinStrength", "SpinAxis", "ArchFrequency", "ArchDepth", "ArchAxis",
			"InvRadius", "InvStrength", "RotationAngle", "WRotationSpeed",
			"MaxSteps", "Detail", "JuliaMode", "JuliaMorph", "JuliaSeed",
			"WaveType", "WaveBlend",
			"CityEnabled", "CellSize", "CellRotVariance", "CellConstantVariance",
			"CellHeightVariance", "AlleyWidth",
			"ShapeEnabled", "ShapeType", "ShapeRadius", "ShapeThickness",
			"ShapeBend", "ShapeOffset", "GrainIntensity",
			"TentacleCount", "TentacleLength", "TentacleTwist",
			"F_absX", "F_absY", "F_absZ", "F_X", "F_Y", "F_Z",
			"SymmetryStrength", "F_offset",
			"KIFS_Angle_X", "KIFS_Angle_Y", "KIFS_Angle_Z"
		]
		var mat_save = get_fractal_material()
		if mat_save:
			for param in archon_params:
				var val = mat_save.get_shader_parameter(param)
				if val != null:
					config.set_value("ArchonParams", param, val)
	
	
	
	
	# 5. ACTUALLY SAVE (MOVED OUTSIDE THE LOOP)
	var save_err = config.save(path)
	if save_err == OK:
		print("SUCCESS: Preset saved to: ", path)
	else:
		print("ERROR: Could not save file. Code: ", save_err)

func load_preset(path: String):
	var config = ConfigFile.new()
	var err = config.load(path)
	if err != OK: return
	
	
	# === ARCHON ===
	if config.get_value("Metadata", "fractal_type", "") == "Archon":
		var mat_load = get_fractal_material()
		if not mat_load:
			print("ERROR: No material to load Archon preset into.")
			return

		# --- Step 1: Switch shader first, before touching any params ---
		mat_load.shader = archon_shader
		current_fractal = "Archon"

		# --- Step 2: Clear the init flag so the UI sync is allowed ---
		archon_initialized = false

		# --- Step 3: Apply ALL params — scalars and vectors are both in ArchonParams ---
		# ConfigFile natively preserves Vector3/Vector4 types so no separate
		# section is needed. The [ArchonVectors] section was a mistake.
		if config.has_section("ArchonParams"):
			for key in config.get_section_keys("ArchonParams"):
				var val = config.get_value("ArchonParams", key)
				mat_load.set_shader_parameter(key, val)

		# --- Step 5: Restore camera ---
		if main_camera:
			main_camera.global_position = config.get_value("Camera", "pos", Vector3(0, 0, 6))
			var loaded_basis = config.get_value("Camera", "basis", Basis())
			main_camera.global_transform.basis = loaded_basis
			# Pass the loaded basis into the camera so its internal yaw/pitch
			# variables match — do NOT call reset_internal_rotation here as
			# that zeros them out and overrides the loaded orientation.
			if main_camera.has_method("set_rotation_from_basis"):
				main_camera.call("set_rotation_from_basis", loaded_basis)

		# --- Step 6: Push shader state back to every UI slider ---
		_sync_archon_ui_from_shader()

		# --- Step 7: Lock in BEFORE selecting in tree ---
		# Must be true before set_selected fires _on_tree_item_selected,
		# otherwise it calls _sync_archon_to_shader() and wipes loaded values.
		archon_initialized = true

		# --- Step 8: Select Archon in nav tree to show the right tab ---
		if has_node("%NavigationTree"):
			var tree_root = %NavigationTree.get_root()
			var archon_item = find_tree_item(tree_root, "Archon")
			if archon_item:
				%NavigationTree.set_selected(archon_item, 0)
			if has_node("%TabContainer"):
				%TabContainer.current_tab = 8

		print("Archon preset loaded successfully.")
		return  # Skip the generic sync below — Archon is fully handled


	var mat = get_fractal_material()
	
	# 1. Restore Fractal Type/Shader
	var new_path = config.get_value("Metadata", "shader_path", "")
	if new_path != "" and mat.shader.resource_path != new_path:
		mat.shader = load(new_path)
		current_fractal = config.get_value("Metadata", "fractal_type", "Mandelbox")
	
	# 2. FIXED: Restore Camera (With Safety Defaults)
	# Adding Vector3 and Basis defaults prevents the 'Nil' crash
	main_camera.global_position = config.get_value("Camera", "pos", Vector3(0, 0, 5)) 
	main_camera.global_transform.basis = config.get_value("Camera", "basis", Basis())
	
	if main_camera.has_method("reset_internal_rotation"):
		main_camera.call("reset_internal_rotation")

	# 3. Restore Shader Parameters
	if config.has_section("ShaderParams"):
		for key in config.get_section_keys("ShaderParams"):
			var val = config.get_value("ShaderParams", key)
			
			# Strip the prefix so "shader_parameter/Power" becomes "Power"
			var clean_name = key.replace("shader_parameter/", "")
			
			# Apply it to the material
			mat.set_shader_parameter(clean_name, val)
			
	
	
	# --- 4. NEW: Restore Global Shape & U-Bend Settings ---
	# We use has_section_key to avoid errors if loading an old preset
	if config.has_section_key("UIState", "ShapeEnabled"):
		var is_enabled = config.get_value("UIState", "ShapeEnabled", false)
		if has_node("%ShapeEnabledCheck"):
			%ShapeEnabledCheck.button_pressed = is_enabled
			%ShapeEnabledCheck.toggled.emit(is_enabled) 

	if config.has_section_key("UIState", "ShapeType"):
		if has_node("%ShapeTypeButton"):
			%ShapeTypeButton.selected = config.get_value("UIState", "ShapeType", 0)
			mat.set_shader_parameter("ShapeType", %ShapeTypeButton.selected)

# Use a helper to set values safely and avoid the 'null instance' error
	set_slider_safe("%ShapeBendSlider", "UIState", "ShapeBend", config, 0.0)
	set_slider_safe("%TentacleCountSlider", "UIState", "TentacleCount", config, 8.0)
	set_slider_safe("%TentacleLengthSlider", "UIState", "TentacleLength", config, 0.5)
	set_slider_safe("%TentacleTwistSlider", "UIState", "TentacleTwist", config, 1.0)
	
		
	if config.has_section_key("UIState", "CustomGradientData"):
		var grad_res = config.get_value("UIState", "CustomGradientData")
		if grad_res is Gradient:
			# Update the shader texture
			var new_tex = GradientTexture1D.new()
			new_tex.gradient = grad_res
			mat.set_shader_parameter("GradientTexture", new_tex)
			
			# UPDATE THE UI COLOR PICKERS
			# Usually: Stop 0 = Color1, Stop 0.5 = Color2, Stop 1.0 = Color3
			if grad_res.get_point_count() >= 3:
				if has_node("%ColorPicker1"): 
					%ColorPicker1.color = grad_res.get_color(0)
				if has_node("%ColorPicker2"): 
					%ColorPicker2.color = grad_res.get_color(1)
				if has_node("%ColorPicker3"): 
					%ColorPicker3.color = grad_res.get_color(2)
					
				# Manually trigger the shader update for the colors
				_on_color_updated() 
	%TimeSpeedSlider.value = config.get_value("UIState", "TimeSpeed", 0.5)
	%ParallelToggle.button_pressed = config.get_value("UIState", "IsParallel", true)
	
	
	# Manually trigger the shader update after loading
	_on_shader_param_changed(%TimeSpeedSlider.value, "time_speed")
	_on_shader_param_changed(%ParallelToggle.button_pressed, "draw_parallel")
	
	print("Preset loaded with custom colors!")
	
	# IMPORTANT: Refresh the UI sliders to match the new values
	sync_ui_to_shader()
	
	
	
	
func _on_color_updated():
	var mat = get_fractal_material()
	if not mat: return
	
	var c1 = %ColorPicker1.color
	var c2 = %ColorPicker2.color
	var c3 = %ColorPicker3.color
	
	# Send to shader as Vector3 (ignoring Alpha)
	mat.set_shader_parameter("Color1", Vector3(c1.r, c1.g, c1.b))
	mat.set_shader_parameter("Color2", Vector3(c2.r, c2.g, c2.b))
	mat.set_shader_parameter("Color3", Vector3(c3.r, c3.g, c3.b))
func _on_time_speed_slider_value_changed(value: float) -> void:
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("time_speed", value)



func _on_parallel_toggle_toggled(toggled_on: bool) -> void:
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("draw_parallel", toggled_on)
		
		
func _on_shader_param_changed(value, param_name: String):
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter(param_name, value)
func change_fractal_type(new_type_name: String):
	# Update the internal state
	current_fractal = new_type_name
	
	# This part depends on how your UI is named. 
	# If you have a Tree node named %FractalTree:
	var tree = %FractalTree 
	var root = tree.get_root()
	
	# Search for the item in the tree that matches the string (e.g., "Mandelbox")
	var item = find_tree_item(root, new_type_name)
	if item:
		tree.set_selected(item)
		# This manually triggers your _on_tree_item_selected logic
		_on_tree_item_selected() 

# Helper to find the right item in your sidebar list
func find_tree_item(parent: TreeItem, text: String) -> TreeItem:
	if parent.get_text(0) == text:
		return parent
	# Godot 4: get_children() returns Array[TreeItem], not a single item
	for child in parent.get_children():
		var found = find_tree_item(child, text)
		if found: return found
	return null
	
func update_ui_to_match_shader():
	var mat = get_fractal_material()
	if not mat: return

	# 1. Update Floats (Sliders)
	# This uses the key names from your 'floats' dictionary
	# Note: We use %Name notation to match your unique scene tree IDs
	set_s_val("%WSlider", mat.get_shader_parameter("W"))
	set_s_val("%ScaleSlider", mat.get_shader_parameter("Scale"))
	set_s_val("%PowerSlider", mat.get_shader_parameter("Power"))
	set_s_val("%ReflectSlider", mat.get_shader_parameter("Reflectivity"))
	set_s_val("%FogSlider", mat.get_shader_parameter("FogDensity"))
	
	# 2. Update Vector3/Vector4 Sliders (Individual Components)
	var pre_off = mat.get_shader_parameter("PreOffset")
	if pre_off is Vector3:
		set_s_val("%PreOffsetXSlider", pre_off.x)
		set_s_val("%PreOffsetYSlider", pre_off.y)
		set_s_val("%PreOffsetZSlider", pre_off.z)

	var fold_lim = mat.get_shader_parameter("FoldLimit4D")
	if fold_lim is Vector4:
		set_s_val("%FoldLimitXSlider", fold_lim.x)
		set_s_val("%FoldLimitYSlider", fold_lim.y)
		set_s_val("%FoldLimitZSlider", fold_lim.z)
		set_s_val("%FoldLimitWSlider", fold_lim.w)

	# 3. Update States (Checkboxes/Toggles)
	set_b_val("%ASurfJuliaToggle", mat.get_shader_parameter("JuliaMode"))
	set_b_val("%SphereFoldToggle", mat.get_shader_parameter("SphereFoldEnabled"))
	set_b_val("%AbsXToggle", mat.get_shader_parameter("F_absX"))
	set_b_val("%AbsYToggle", mat.get_shader_parameter("F_absY"))
	set_b_val("%AbsZToggle", mat.get_shader_parameter("F_absZ"))

# Helper to safely set slider values without triggering 'value_changed' loops
func set_s_val(node_name: String, value):
	if has_node(node_name) and value != null:
		var node = get_node(node_name)
		node.set_block_signals(true) # Prevents feedback loops
		node.value = float(value)
		node.set_block_signals(false)

# Helper to safely set checkbox states
func set_b_val(node_name: String, value):
	if has_node(node_name) and value != null:
		var node = get_node(node_name)
		node.set_block_signals(true)
		node.button_pressed = bool(value)
		node.set_block_signals(false)
func _process(delta: float):
	# 1. Keep the fractal shader's internal time moving
	time += delta
	var mat = get_fractal_material()
	if mat:
		mat.set_shader_parameter("Time", time)

	# 2. If we are playing a flythrough, ensure the UI stays in sync 
	# (Optional, but keeps sliders moving while you fly)
func set_slider_safe(node_path: String, section: String, key: String, config: ConfigFile, default: float):
	if has_node(node_path):
		var slider = get_node(node_path)
		slider.value = config.get_value(section, key, default)
	else:
		print("Warning: Slider ", node_path, " not found in UI.")
