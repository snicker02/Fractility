extends Control
const PROGRAM_VERSION = 1.0
# --- Node References ---
@onready var viewport_a: SubViewport = %ViewportA
@onready var viewport_b: SubViewport = %ViewportB
@onready var final_output: TextureRect = %FinalOutput
@onready var file_dialog: FileDialog = %FileDialog
@onready var save_viewport: SubViewport = %SaveViewport
@onready var post_process_save_viewport: SubViewport = %PostProcessSaveViewport


@export var ui_scene: PackedScene


# --- Control Variables ---
var variation_mode_a: String = "Sinusoidal"
var variation_mode_b: String = "Spherical"
var start_pattern_mode: int = 0
var variation_mix: float = 0.5
var feedback_amount: float = 0.98
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

var move_post_translate: bool = true
var move_pre_translate: bool = false
var move_var_a_translate: bool = false
var move_var_b_translate: bool = false

var grad_col_tl: Color = Color.CYAN
var grad_col_tr: Color = Color.YELLOW
var grad_col_bl: Color = Color.BLUE
var grad_col_br: Color = Color.RED

var fisheye_strength_a: float = 2.0
var polar_offset_a: float = 1.0
var fisheye_strength_b: float = 2.0
var polar_offset_b: float = 1.0

var wave_frequency_a: float = 0.0
var wave_amplitude_a: float = 0.1
var wave_speed_a: float = 0.0
var wave_frequency_b: float = 5.0
var wave_amplitude_b: float = 0.1
var wave_speed_b: float = 0.0
var wave_type_a: int = 0 # 0: Vertical, 1: Radial, 2: Square
var wave_type_b: int = 0

# Julian2 A Controls
var julian_power_a: float = 2.0
var julian_dist_a: float = 1.0
var julian_a_a: float = 1.0
var julian_b_a: float = 0.0
var julian_c_a: float = 0.0
var julian_d_a: float = 1.0
var julian_e_a: float = 0.0
var julian_f_a: float = 0.0

# Julian2 B Controls
var julian_power_b: float = -3.0
var julian_dist_b: float = 1.0
var julian_a_b: float = 1.0
var julian_b_b: float = 0.0
var julian_c_b: float = 0.0
var julian_d_b: float = 1.0
var julian_e_b: float = 0.0
var julian_f_b: float = 0.0

var translate_a: Vector2 = Vector2.ZERO
var translate_b: Vector2 = Vector2.ZERO
var pre_scale: float = 1.0
var pre_rotation: float = 0.0
var pre_translate: Vector2 = Vector2.ZERO
var post_scale: float = 0.995
var post_rotation: float = 0.0
var post_translate: Vector2 = Vector2.ZERO

# ---Mobius---
var mobius_re_a_a = 0.1;  var mobius_im_a_a = 0.2;
var mobius_re_b_a = 0.2;  var mobius_im_b_a = -0.12;
var mobius_re_c_a = -0.15; var mobius_im_c_a = -0.15;
var mobius_re_d_a = 0.21; var mobius_im_d_a = 0.1;
var mobius_re_a_b = 0.1;  var mobius_im_a_b = 0.2;
var mobius_re_b_b = 0.2;  var mobius_im_b_b = -0.12;
var mobius_re_c_b = -0.15; var mobius_im_c_b = -0.15;
var mobius_re_d_b = 0.21; var mobius_im_d_b = 0.1;

# --- Add variables for Cellular Weave parameters ---
var cellular_weave_grid_size_a: float = 10.0
var cellular_weave_threshold_a: float = 4.0
var cellular_weave_iterations_a: float = 1.0
var cellular_weave_grid_size_b: float = 10.0
var cellular_weave_threshold_b: float = 4.0
var cellular_weave_iterations_b: float = 1.0

var blur_amount_a: float = 0.0
var blur_amount_b: float = 0.0

# --- Add variables for Heart parameters ---
var heart_scale_a: float = 0.3
var heart_rotation_a: float = 0.0
var heart_strength_a: float = 0.5
var heart_scale_b: float = 0.3
var heart_rotation_b: float = 0.0
var heart_strength_b: float = 0.5

var apollonian_scale_a: float = 1.5
var ap_c1_a := Vector2(0.0, 0.5)      # <-- ADD
var ap_c2_a := Vector2(-0.433, -0.25) # <-- ADD
var ap_c3_a := Vector2(0.433, -0.25)  # <-- ADD
var apollonian_scale_b: float = 1.5
var ap_c1_b := Vector2(0.0, 0.5)      # <-- ADD
var ap_c2_b := Vector2(-0.433, -0.25) # <-- ADD
var ap_c3_b := Vector2(0.433, -0.25)  # <-- ADD
# --- Private Variables ---
var time: float = 0.0
var is_a_source = true
var ui_instance: Node # Assuming UIController type if you have one
var post_process_material: ShaderMaterial
var _preset_json_to_save: String

var version_label: Label

func _ready() -> void:
	# NOTE: update_mode for SaveViewport must be set to 'Always' in the Inspector
	save_viewport.get_node("ShaderRect").anchors_preset = Control.PRESET_FULL_RECT

	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_PICTURES)

	var feedback_material = ShaderMaterial.new()
	feedback_material.shader = load("res://fractal_feedback.gdshader")
	%ViewportA.get_node("ShaderRect").material = feedback_material
	%ViewportB.get_node("ShaderRect").material = feedback_material.duplicate()
	%SaveViewport.get_node("ShaderRect").material = feedback_material.duplicate()
	post_process_material = ShaderMaterial.new()
	post_process_material.shader = load("res://post_process.gdshader")
	final_output.material = post_process_material

	if ui_scene:
		ui_instance = ui_scene.instantiate() # Cast later if needed
		add_child(ui_instance)
		# --- Set Version Label ---
		version_label = ui_instance.get_node_or_null("RootVBox/Version number") # Find it again here
		if version_label:
			version_label.text = "V " + str(PROGRAM_VERSION) # Set the text
		else:
			print("WARNING: Could not find Version number label node.")
			# --------------------------

		

		# --- Connect UI Signals ---
		# Variation Modes & Mix
		ui_instance.variation_a_changed.connect(func(index): variation_mode_a = ui_instance.var_a_dropdown.get_item_text(index))
		ui_instance.variation_b_changed.connect(func(index): variation_mode_b = ui_instance.var_b_dropdown.get_item_text(index))
		ui_instance.variation_mix_changed.connect(func(value): variation_mix = value)

		# Start Pattern & Feedback
		ui_instance.start_pattern_changed.connect(func(index): start_pattern_mode = index)
		ui_instance.show_grid_toggled.connect(func(is_on): show_start_grid = is_on)
		ui_instance.show_circles_toggled.connect(func(is_on): show_circles = is_on)
		ui_instance.circle_count_changed.connect(func(value): circle_count = value)
		ui_instance.circle_radius_changed.connect(func(value): circle_radius = value)
		ui_instance.circle_softness_changed.connect(func(value): circle_softness = value)
		ui_instance.grad_col_tl_changed.connect(func(color): grad_col_tl = color)
		ui_instance.grad_col_tr_changed.connect(func(color): grad_col_tr = color)
		ui_instance.grad_col_bl_changed.connect(func(color): grad_col_bl = color)
		ui_instance.grad_col_br_changed.connect(func(color): grad_col_br = color)
		ui_instance.feedback_amount_changed.connect(func(value): feedback_amount = value)

		# Transforms & Tiling
		ui_instance.pre_scale_changed.connect(func(value): pre_scale = value)
		ui_instance.pre_rotation_changed.connect(func(value): pre_rotation = value)
		ui_instance.post_scale_changed.connect(func(value): post_scale = value)
		ui_instance.post_rotation_changed.connect(func(value): post_rotation = value)
		ui_instance.seamless_tiling_changed.connect(func(is_on): seamless_tiling = is_on)
		ui_instance.mirror_tiling_changed.connect(func(is_on): mirror_tiling = is_on)
		ui_instance.reset_on_drag_changed.connect(func(is_on): reset_on_drag_enabled = is_on)

		# Color Grading
		ui_instance.brightness_changed.connect(func(value): brightness = value)
		ui_instance.contrast_changed.connect(func(value): contrast = value)
		ui_instance.saturation_changed.connect(func(value): saturation = value)

		# Post Processing Symmetry
		ui_instance.mirror_x_changed.connect(func(is_on): mirror_x = is_on)
		ui_instance.mirror_y_changed.connect(func(is_on): mirror_y = is_on)
		ui_instance.kaleidoscope_changed.connect(func(is_on): kaleidoscope_on = is_on)
		ui_instance.kaleidoscope_slices_changed.connect(func(value): kaleidoscope_slices = value)

		# Variation A Parameters
		ui_instance.var_a_mirror_x_changed.connect(func(is_on): var_a_mirror_x = is_on)
		ui_instance.var_a_mirror_y_changed.connect(func(is_on): var_a_mirror_y = is_on)
		ui_instance.var_a_kaleidoscope_slices_changed.connect(func(value): var_a_kaleidoscope_slices = value)
		ui_instance.wave_type_a_changed.connect(func(index): wave_type_a = index)
		ui_instance.wave_frequency_a_changed.connect(func(value): wave_frequency_a = value)
		ui_instance.wave_amplitude_a_changed.connect(func(value): wave_amplitude_a = value)
		ui_instance.wave_speed_a_changed.connect(func(value): wave_speed_a = value)
		ui_instance.julian_power_a_changed.connect(func(value): julian_power_a = value)
		ui_instance.julian_dist_a_changed.connect(func(value): julian_dist_a = value)
		ui_instance.julian_a_a_changed.connect(func(value): julian_a_a = value)
		ui_instance.julian_b_a_changed.connect(func(value): julian_b_a = value)
		ui_instance.julian_c_a_changed.connect(func(value): julian_c_a = value)
		ui_instance.julian_d_a_changed.connect(func(value): julian_d_a = value)
		ui_instance.julian_e_a_changed.connect(func(value): julian_e_a = value)
		ui_instance.julian_f_a_changed.connect(func(value): julian_f_a = value)
		ui_instance.fisheye_strength_a_changed.connect(func(value): fisheye_strength_a = value)
		ui_instance.polar_offset_a_changed.connect(func(value): polar_offset_a = value)
		ui_instance.mobius_re_a_a_changed.connect(func(v): mobius_re_a_a = v)
		ui_instance.mobius_im_a_a_changed.connect(func(v): mobius_im_a_a = v)
		ui_instance.mobius_re_b_a_changed.connect(func(v): mobius_re_b_a = v)
		ui_instance.mobius_im_b_a_changed.connect(func(v): mobius_im_b_a = v)
		ui_instance.mobius_re_c_a_changed.connect(func(v): mobius_re_c_a = v)
		ui_instance.mobius_im_c_a_changed.connect(func(v): mobius_im_c_a = v)
		ui_instance.mobius_re_d_a_changed.connect(func(v): mobius_re_d_a = v)
		ui_instance.mobius_im_d_a_changed.connect(func(v): mobius_im_d_a = v)
		ui_instance.cellular_weave_grid_size_a_changed.connect(func(v): cellular_weave_grid_size_a = v)
		ui_instance.cellular_weave_threshold_a_changed.connect(func(v): cellular_weave_threshold_a = v)
		ui_instance.cellular_weave_iterations_a_changed.connect(func(v): cellular_weave_iterations_a = v)
		ui_instance.blur_amount_a_changed.connect(func(v): blur_amount_a = v)
		ui_instance.heart_scale_a_changed.connect(func(v): heart_scale_a = v)
		ui_instance.heart_rotation_a_changed.connect(func(v): heart_rotation_a = v)
		ui_instance.heart_strength_a_changed.connect(func(v): heart_strength_a = v)
		ui_instance.apollonian_scale_a_changed.connect(func(v): apollonian_scale_a = v)
		ui_instance.ap_c1_a_changed.connect(func(v): ap_c1_a = v) # <-- ADD
		ui_instance.ap_c2_a_changed.connect(func(v): ap_c2_a = v) # <-- ADD
		ui_instance.ap_c3_a_changed.connect(func(v): ap_c3_a = v) # <-- ADD


		# Variation B Parameters
		ui_instance.var_b_mirror_x_changed.connect(func(is_on): var_b_mirror_x = is_on)
		ui_instance.var_b_mirror_y_changed.connect(func(is_on): var_b_mirror_y = is_on)
		ui_instance.var_b_kaleidoscope_slices_changed.connect(func(value): var_b_kaleidoscope_slices = value)
		ui_instance.wave_type_b_changed.connect(func(index): wave_type_b = index)
		ui_instance.wave_frequency_b_changed.connect(func(value): wave_frequency_b = value)
		ui_instance.wave_amplitude_b_changed.connect(func(value): wave_amplitude_b = value)
		ui_instance.wave_speed_b_changed.connect(func(value): wave_speed_b = value)
		ui_instance.julian_power_b_changed.connect(func(value): julian_power_b = value)
		ui_instance.julian_dist_b_changed.connect(func(value): julian_dist_b = value)
		ui_instance.julian_a_b_changed.connect(func(value): julian_a_b = value)
		ui_instance.julian_b_b_changed.connect(func(value): julian_b_b = value)
		ui_instance.julian_c_b_changed.connect(func(value): julian_c_b = value)
		ui_instance.julian_d_b_changed.connect(func(value): julian_d_b = value)
		ui_instance.julian_e_b_changed.connect(func(value): julian_e_b = value)
		ui_instance.julian_f_b_changed.connect(func(value): julian_f_b = value)
		ui_instance.fisheye_strength_b_changed.connect(func(value): fisheye_strength_b = value)
		ui_instance.polar_offset_b_changed.connect(func(value): polar_offset_b = value)
		ui_instance.mobius_re_a_b_changed.connect(func(v): mobius_re_a_b = v)
		ui_instance.mobius_im_a_b_changed.connect(func(v): mobius_im_a_b = v)
		ui_instance.mobius_re_b_b_changed.connect(func(v): mobius_re_b_b = v)
		ui_instance.mobius_im_b_b_changed.connect(func(v): mobius_im_b_b = v)
		ui_instance.mobius_re_c_b_changed.connect(func(v): mobius_re_c_b = v)
		ui_instance.mobius_im_c_b_changed.connect(func(v): mobius_im_c_b = v)
		ui_instance.mobius_re_d_b_changed.connect(func(v): mobius_re_d_b = v)
		ui_instance.mobius_im_d_b_changed.connect(func(v): mobius_im_d_b = v)
		ui_instance.cellular_weave_grid_size_b_changed.connect(func(v): cellular_weave_grid_size_b = v)
		ui_instance.cellular_weave_threshold_b_changed.connect(func(v): cellular_weave_threshold_b = v)
		ui_instance.cellular_weave_iterations_b_changed.connect(func(v): cellular_weave_iterations_b = v)
		ui_instance.blur_amount_b_changed.connect(func(v): blur_amount_b = v)
		ui_instance.heart_scale_b_changed.connect(func(v): heart_scale_b = v)
		ui_instance.heart_rotation_b_changed.connect(func(v): heart_rotation_b = v)
		ui_instance.heart_strength_b_changed.connect(func(v): heart_strength_b = v)
		ui_instance.apollonian_scale_b_changed.connect(func(v): apollonian_scale_b = v)
		ui_instance.ap_c1_b_changed.connect(func(v): ap_c1_b = v) # <-- ADD
		ui_instance.ap_c2_b_changed.connect(func(v): ap_c2_b = v) # <-- ADD
		ui_instance.ap_c3_b_changed.connect(func(v): ap_c3_b = v) # <-- ADD

		# Mouse Drag Target
		ui_instance.translate_target_changed.connect(func(index): active_translate_target = index) # Assuming index matches order 0:post, 1:pre, 2:var_a, 3:var_b
		ui_instance.post_translate_toggled.connect(func(is_on): move_post_translate = is_on)
		ui_instance.pre_translate_toggled.connect(func(is_on): move_pre_translate = is_on)
		ui_instance.var_a_translate_toggled.connect(func(is_on): move_var_a_translate = is_on)
		ui_instance.var_b_translate_toggled.connect(func(is_on): move_var_b_translate = is_on)

		# Save/Load/Preset Buttons
		ui_instance.save_button_pressed.connect(_on_save_button_pressed)
		ui_instance.load_image_button_pressed.connect(_on_load_image_button_pressed)
		ui_instance.save_preset_pressed.connect(_on_save_preset_pressed)
		ui_instance.load_preset_pressed.connect(_on_load_preset_pressed)
		ui_instance.copy_preset_pressed.connect(_on_copy_preset_pressed)
		ui_instance.paste_preset_pressed.connect(_on_paste_preset_pressed)
		ui_instance.resolution_selected.connect(func(index): save_resolution_index = index)
		# -----------------------------

		update_ui_from_state()
		file_dialog.file_selected.connect(_on_file_dialog_file_selected)
		
		
		
		if OS.has_feature("web"):
			print("Control: Web build detected, disabling clipboard buttons.")

			# Get references using the FULL PATHS from ui_instance
			var copy_button = ui_instance.get_node_or_null("RootVBox/ScrollContainer/MarginContainer/MainContainer/HBoxContainer16/CopyPresetButton")
			var paste_button = ui_instance.get_node_or_null("RootVBox/ScrollContainer/MarginContainer/MainContainer/HBoxContainer16/PastePresetButton")
			var notice_label = ui_instance.get_node_or_null("RootVBox/ScrollContainer/MarginContainer/MainContainer/ClipboardNoticeLabel")

			if copy_button:
				copy_button.disabled = true
				print("Control: Copy button disabled.")
			else:
				# Be specific in the warning
				print("Control WARNING: Could not find CopyPresetButton at path 'RootVBox/ScrollContainer/MarginContainer/MainContainer/HBoxContainer16/CopyPresetButton'. Check names/path.")

			if paste_button:
				paste_button.disabled = true
				print("Control: Paste button disabled.")
			else:
				print("Control WARNING: Could not find PastePresetButton at path 'RootVBox/ScrollContainer/MarginContainer/MainContainer/HBoxContainer16/PastePresetButton'. Check names/path.")

			if notice_label:
				notice_label.text = "Clipboard Copy/Paste disabled on web"
				notice_label.visible = true
				print("Control: Clipboard notice label shown.")
			else:
				print("Control WARNING: Could not find ClipboardNoticeLabel at path 'RootVBox/ScrollContainer/MarginContainer/MainContainer/ClipboardNoticeLabel'. Check names/path.")
		else:
			print("Control: Not web build, clipboard buttons enabled.")
			# Ensure the label is hidden on non-web builds
			var notice_label = ui_instance.get_node_or_null("RootVBox/ScrollContainer/MarginContainer/MainContainer/ClipboardNoticeLabel") # Use full path here too
			if notice_label:
				notice_label.visible = false

	var post_save_material = ShaderMaterial.new()
	post_save_material.shader = load("res://post_process.gdshader")
	post_process_save_viewport.get_node("ShaderRect").material = post_save_material

	# --- Web Specific Setup ---
	print("Control: _ready function running.")
	if not OS.has_feature("web"):
		print("Control: Not running on web.")
		# Optionally disable web-only buttons if desired
		# if is_instance_valid(ui_instance):
		#     ui_instance.load_preset_button.disabled = true # Example

	print("Control: _ready function finished.")
		

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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_visuals"):
		self.reset_visuals.call()
	if event.is_action_pressed.call("reseed_pattern"):
		self.reseed_pattern.call()
	if event.is_action_pressed("toggle_ui"):
		self.toggle_ui.call()

	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		var relative_motion = event.relative / get_viewport_rect().size
		if move_post_translate:
			post_translate -= relative_motion
		if move_pre_translate:
			pre_translate -= relative_motion
			# print("1. Input changed pre_translate to: ", pre_translate) # DEBUG
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
					else: pre_scale = max(0.1, pre_scale - delta) # Prevent scale becoming zero or negative
				else:
					if event.shift_pressed: post_rotation += delta * 5.0
					else: post_scale = max(0.1, post_scale - delta) # Prevent scale becoming zero or negative

func toggle_ui() -> void:
	if is_instance_valid(ui_instance):
		ui_instance.visible = not ui_instance.visible

func reset_visuals() -> void:
	variation_mode_a = "Sinusoidal"; variation_mode_b = "Spherical"
	start_pattern_mode = 0
	variation_mix = 0.5
	feedback_amount = 0.98
	seamless_tiling = true
	mirror_tiling = false
	reset_on_drag_enabled = true
	show_start_grid = false; show_circles = true
	circle_count = 4.0; circle_radius = 0.2; circle_softness = 0.05
	grad_col_tl = Color.CYAN; grad_col_tr = Color.YELLOW; grad_col_bl = Color.BLUE; grad_col_br = Color.RED
	pre_scale = 1.0; pre_rotation = 0.0; pre_translate = Vector2.ZERO
	post_scale = 0.995; post_rotation = 0.0; post_translate = Vector2.ZERO
	translate_a = Vector2.ZERO; translate_b = Vector2.ZERO
	brightness = 1.0; contrast = 1.0; saturation = 1.0
	move_post_translate = true; move_pre_translate = false; move_var_a_translate = false; move_var_b_translate = false
	mirror_x = false; mirror_y = false; kaleidoscope_on = false; kaleidoscope_slices = 6.0
	var_a_mirror_x = false; var_a_mirror_y = false; var_a_kaleidoscope_slices = 6.0
	wave_type_a = 0; wave_frequency_a = 0.0; wave_amplitude_a = 0.1; wave_speed_a = 0.0
	julian_power_a = 2.0; julian_dist_a = 1.0; julian_a_a = 1.0; julian_b_a = 0.0; julian_c_a = 0.0; julian_d_a = 1.0; julian_e_a = 0.0; julian_f_a = 0.0
	fisheye_strength_a = 2.0; polar_offset_a = 1.0
	mobius_re_a_a = 0.1; mobius_im_a_a = 0.2; mobius_re_b_a = 0.2; mobius_im_b_a = -0.12; mobius_re_c_a = -0.15; mobius_im_c_a = -0.15; mobius_re_d_a = 0.21; mobius_im_d_a = 0.1
	cellular_weave_grid_size_a = 10.0; cellular_weave_threshold_a = 4.0; cellular_weave_iterations_a = 1.0
	blur_amount_a = 0.0
	heart_scale_a = 0.3; heart_rotation_a = 0.0; heart_strength_a = 0.5
	var_b_mirror_x = false; var_b_mirror_y = false; var_b_kaleidoscope_slices = 6.0
	wave_type_b = 0; wave_frequency_b = 5.0; wave_amplitude_b = 0.1; wave_speed_b = 0.0
	julian_power_b = -3.0; julian_dist_b = 1.0; julian_a_b = 1.0; julian_b_b = 0.0; julian_c_b = 0.0; julian_d_b = 1.0; julian_e_b = 0.0; julian_f_b = 0.0
	fisheye_strength_b = 2.0; polar_offset_b = 1.0
	mobius_re_a_b = 0.1; mobius_im_a_b = 0.2; mobius_re_b_b = 0.2; mobius_im_b_b = -0.12; mobius_re_c_b = -0.15; mobius_im_c_b = -0.15; mobius_re_d_b = 0.21; mobius_im_d_b = 0.1
	cellular_weave_grid_size_b = 10.0; cellular_weave_threshold_b = 4.0; cellular_weave_iterations_b = 1.0
	blur_amount_b = 0.0
	heart_scale_b = 0.3; heart_rotation_b = 0.0; heart_strength_b = 0.5
	apollonian_scale_a = 1.5
	ap_c1_a = Vector2(0.0, 0.5)      # <-- ADD
	ap_c2_a = Vector2(-0.433, -0.25) # <-- ADD
	ap_c3_a = Vector2(0.433, -0.25)  # <-- ADD
	apollonian_scale_b = 1.5
	ap_c1_b = Vector2(0.0, 0.5)      # <-- ADD
	ap_c2_b = Vector2(-0.433, -0.25) # <-- ADD
	ap_c3_b = Vector2(0.433, -0.25)  # <-- ADD
	
	
	time = 0.0
	update_ui_from_state()
	reseed_pattern()

func reseed_pattern() -> void:
	time = 0.0 # Resets the shader time, often used for seeding noise/patterns

func update_ui_from_state() -> void:
	if is_instance_valid(ui_instance) and ui_instance.has_method("initialize_ui"):
		var values = {
			"var_a": variation_mode_a, "var_b": variation_mode_b, "start_pattern": start_pattern_mode,
			"var_mix": variation_mix, "feedback": feedback_amount, "tiling": seamless_tiling,"mirror_tiling": mirror_tiling,
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
		}
		ui_instance.initialize_ui(values)

func _on_save_button_pressed() -> void:
	if OS.has_feature("web"):
		print("Starting web render for download...")
		var resolution = 1024 * pow(2, save_resolution_index)
		_render_and_save_image("", Vector2i(resolution, resolution))
	else:
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
		print("Starting high-resolution render...")
		var resolution = 1024 * pow(2, save_resolution_index)
		_render_and_save_image(path, Vector2i(resolution, resolution))

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
	var id_a = VariationManager.VARIATIONS[variation_mode_a]["id"]
	var id_b = VariationManager.VARIATIONS[variation_mode_b]["id"]
	save_material.set_shader_parameter("variation_mode_a", id_a)
	save_material.set_shader_parameter("variation_mode_b", id_b)
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
	var id_a = VariationManager.VARIATIONS[variation_mode_a]["id"]
	var id_b = VariationManager.VARIATIONS[variation_mode_b]["id"]
	target_material.set_shader_parameter("variation_mode_a", id_a)
	target_material.set_shader_parameter("variation_mode_b", id_b)
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
		"variation_mode_a": variation_mode_a,
		"variation_mode_b": variation_mode_b,
		"start_pattern_mode": start_pattern_mode,
		"variation_mix": variation_mix,
		"feedback_amount": feedback_amount,
		"seamless_tiling": seamless_tiling,
		"mirror_tiling": mirror_tiling,
		"reset_on_drag_enabled": reset_on_drag_enabled,

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

	# 3. Set state from data AGAIN
	_set_state_from_preset_data(data)
	print("ApplyPreset: After 2nd SetState.")
	print("  - Values: pre=%s, post=%s, a=%s, b=%s" % [pre_translate, post_translate, translate_a, translate_b])

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
	# --- Main Controls ---
	variation_mode_a = data.get("variation_mode_a", "Sinusoidal")
	variation_mode_b = data.get("variation_mode_b", "Spherical")
	start_pattern_mode = data.get("start_pattern_mode", 0)
	variation_mix = data.get("variation_mix", 0.5)
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

	print("  SetState: Finished applying data.")
