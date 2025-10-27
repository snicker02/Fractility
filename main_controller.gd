extends Control
const PROGRAM_VERSION = 1.4
# --- Node References ---
@onready var viewport_a: SubViewport = %ViewportA
@onready var viewport_b: SubViewport = %ViewportB
@onready var final_output: TextureRect = %FinalOutput
@onready var file_dialog: FileDialog = %FileDialog
@onready var save_viewport: SubViewport = %SaveViewport
@onready var post_process_save_viewport: SubViewport = %PostProcessSaveViewport
@onready var fractal_mesh: MeshInstance3D = %FractalMesh
@onready var display_container_3d: SubViewportContainer = %Display_3D_Container # <-- Add reference to 3D view container
@onready var container_3d_controls: VBoxContainer
@onready var normal_map_viewport = $NormalMapViewport
@onready var normal_map_material = $NormalMapViewport/ColorRect.material
@onready var light_3d: DirectionalLight3D = %DirectionalLight3D
@onready var world_env: WorldEnvironment = %WorldEnvironment
@onready var camera_3d: Camera3D = %Camera3D


@export var ui_scene: PackedScene


# --- Control Variables ---
var variation_mode_a: int = 0 # Default Sinusoidal ID
var variation_mode_b: int = 1 # Default Spherical IDl"
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

# Custom 2x2 Tile Vars
var custom_tl_a: int = 0
var custom_tr_a: int = 0
var custom_bl_a: int = 0
var custom_br_a: int = 0
var custom_tl_b: int = 0
var custom_tr_b: int = 0
var custom_bl_b: int = 0
var custom_br_b: int = 0

# --- 3D Light Controls ---
var light_x_rotation: float = 0.0   # Default from your screenshot
var light_y_rotation: float = 0.0  # Default from your screenshot
var light_energy: float = 1.0
var light_color: Color = Color.WHITE
var light_shadows: bool = true

var normal_map_strength: float = 1.0


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
var ui_instance: UIController # Specify the class_name
var post_process_material: ShaderMaterial
var _preset_json_to_save: String

var version_label: Label

func _set_platform_feedback_defaults() -> void:
	if OS.has_feature("web"):
		# Tighter range for web/mobile
		feedback_min = 0.0
		feedback_max = 0.02
		feedback_amount = 0.01
	else:
		# Wider range for desktop
		feedback_min = 0.0
		feedback_max = 0.1
	# Also reset the main feedback value to a safe default
		feedback_amount = 0.02

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
	
	# NOTE: update_mode for SaveViewport must be set to 'Always' in the Inspector
	save_viewport.get_node("ShaderRect").anchors_preset = Control.PRESET_FULL_RECT

	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_PICTURES)
	
	_set_platform_feedback_defaults()
	# ... (await get_tree().process_frame)
	var window_size = get_viewport().get_visible_rect().size
	print("DEBUG: window_size in _ready:", window_size) # <-- Add check for size
	# --- FIX: Synchronize all viewports to the window size at startup ---
	if window_size.x <= 0 or window_size.y <= 0:
		# This can happen if _ready() runs before the window is fully drawn.
		# Wait one frame and try again.
		await get_tree().process_frame
		window_size = get_viewport().get_visible_rect().size
		if window_size.x <= 0 or window_size.y <= 0:
			printerr("FATAL: Window size is still invalid. Cannot initialize viewports.")
			return # Abort
			
	# Set the sizes *before* creating any textures
	viewport_a.size = window_size
	viewport_b.size = window_size
	# --- END FIX ---
	normal_map_viewport.size = $ViewportA.size
	var feedback_material = ShaderMaterial.new()
	feedback_material.shader = load("res://fractal_feedback.gdshader")
	%ViewportA.get_node("ShaderRect").material = feedback_material
	%ViewportB.get_node("ShaderRect").material = feedback_material.duplicate()
	%SaveViewport.get_node("ShaderRect").material = feedback_material.duplicate()
	post_process_material = ShaderMaterial.new()
	post_process_material.shader = load("res://post_process.gdshader")
	final_output.material = post_process_material
	
	
	# --- ADD THIS 3D MESH SETUP ---
	# 1. Create a new material for the 3D mesh
	var mesh_material = StandardMaterial3D.new()
	
	# 2. Set shading to UNSHADED. This is a key step!
	# It makes the mesh display your texture's exact colors 
	# without needing any 3D lights.
	mesh_material.normal_enabled = true # 
	mesh_material.normal_scale = 1.0
	
	# --- START OF THE FIX ---
	# 3. Assign this new material to the mesh's first surface
	if window_size.x > 0 and window_size.y > 0: # <-- Add check for valid size
		
		# We still need this for the resize function to work later
		var initial_normal_img = Image.create(int(window_size.x), int(window_size.y), false, Image.FORMAT_RGBA8)
		if is_instance_valid(initial_normal_img):
			normal_map_texture = ImageTexture.create_from_image(initial_normal_img)
		else:
			printerr("ERROR: Failed to create initial_normal_img!")

		# --- CORRECTED MERGED BLOCK ---
		# This combines the two 'if' blocks into one, keeping the variable in scope
		if is_instance_valid(mesh_material):
			# 1. Get the texture *once*
			var current_fractal_texture = final_output.get_texture() 

			# 2. Set the albedo (color) texture
			mesh_material.albedo_texture = current_fractal_texture

			# 3. Pass this texture into the normal map shader
			if is_instance_valid(normal_map_material) and is_instance_valid(current_fractal_texture):
				# Use the variable we just defined
				normal_map_material.set_shader_parameter("height_map", current_fractal_texture)
				normal_map_material.set_shader_parameter("strength", normal_map_strength)
				print("Setting normal strength: ", normal_map_strength)
			
			# 4. Get the *result* from the NormalMapViewport and set it
			mesh_material.normal_texture = normal_map_viewport.get_texture()
		else:
			printerr("ERROR: mesh_material is NOT valid in _ready()!")
		# --- END MERGED BLOCK ---

	else:
		printerr("ERROR: window_size is invalid for creating initial normal map image!")

	# Assign material to mesh
	if is_instance_valid(fractal_mesh):
		fractal_mesh.set_surface_override_material(0, mesh_material)
	else:
		print("ERROR: FractalMesh node not found! Check the path.")
	# --- END ADJUSTED 3D MESH SETUP ---
	# --- END OF THE FIX ---
	

	if ui_scene:
		ui_instance = ui_scene.instantiate() as UIController
		add_child(ui_instance)
		
		# --- Get 3D Controls Container ---
		container_3d_controls = ui_instance.get_node_or_null("%Container3DControls")
		if not container_3d_controls:
			print("WARNING: Could not find Container3DControls node in UI.")
		# --- END ---

		# --- Connect Shape Signal ---
		ui_instance.shape_selected.connect(_on_shape_selected)
		# --- END ---
		# Now it's safe to use ui_instance because it exists
		var view_toggle_checkbox = ui_instance.get_node_or_null("%ViewToggleCheckBox")
		if view_toggle_checkbox:
			view_toggle_checkbox.button_pressed = is_3d_view # Set initial state
			view_toggle_checkbox.toggled.connect(_on_view_toggle_toggled)
		else:
			print("WARNING: Could not find ViewToggleCheckBox node in UI.")
		# --- END CheckBox setup ---
		# --- Set Version Label ---
		version_label = ui_instance.get_node_or_null("%Version number") # Find it again here
		if version_label:
			version_label.text = "V " + str(PROGRAM_VERSION) # Set the text
		else:
			print("WARNING: Could not find Version number label node.")
			# --------------------------
		
		# ... [all your other UI signal connections go here] ...
		# ... [they are correct, so I'm omitting them for brevity] ...
		
		# --- Connect UI Signals ---
		# Variation Modes & Mix
		ui_instance.variation_a_changed.connect(func(id): variation_mode_a = id) # Directly receive ID
		ui_instance.variation_b_changed.connect(func(id): variation_mode_b = id) # Directly receive ID	
		ui_instance.variation_mix_changed.connect(func(value): variation_mix = value)

		# Start Pattern & Feedback
		ui_instance.start_pattern_changed.connect(func(index):
			start_pattern_mode = index
			print("DEBUG: Start Pattern Mode changed to: ", start_pattern_mode)
			reseed_pattern() # <-- This line MUST be INSIDE the connect
		)
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
		ui_instance.feedback_range_min_changed.connect(func(value):
			feedback_min = value
			_update_feedback_ranges_in_ui()
		)
		ui_instance.feedback_range_max_changed.connect(func(value):
			feedback_max = value
			_update_feedback_ranges_in_ui()
		)

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
		ui_instance.custom_tl_a_changed.connect(func(idx): custom_tl_a = idx)
		ui_instance.custom_tr_a_changed.connect(func(idx): custom_tr_a = idx)
		ui_instance.custom_bl_a_changed.connect(func(idx): custom_bl_a = idx)
		ui_instance.custom_br_a_changed.connect(func(idx): custom_br_a = idx)


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
		ui_instance.custom_tl_b_changed.connect(func(idx): custom_tl_b = idx)
		ui_instance.custom_tr_b_changed.connect(func(idx): custom_tr_b = idx)
		ui_instance.custom_bl_b_changed.connect(func(idx): custom_bl_b = idx)
		ui_instance.custom_br_b_changed.connect(func(idx): custom_br_b = idx)

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
		
		# --- Connect 3D Light Signals ---
		ui_instance.light_x_rot_changed.connect(func(value):
			light_x_rotation = value
			_update_light()
		)
		ui_instance.light_y_rot_changed.connect(func(value):
			light_y_rotation = value
			_update_light()
		)
		ui_instance.light_energy_changed.connect(func(value):
			light_energy = value
			_update_light()
		)
		ui_instance.light_color_changed.connect(func(color):
			light_color = color
			_update_light()
		)
		ui_instance.light_shadows_toggled.connect(func(is_on):
			light_shadows = is_on
			_update_light()
		)
		# --- END Light Signals ---
		ui_instance.normal_strength_changed.connect(func(value):
			normal_map_strength = value
			
		)
		
		# --- Connect 3D Camera Signals ---
		ui_instance.camera_dist_changed.connect(func(value):
			camera_distance = value
			_update_camera()
		)
		ui_instance.camera_x_rot_changed.connect(func(value):
			camera_x_rotation = value
			_update_camera()
		)
		ui_instance.camera_y_rot_changed.connect(func(value):
			camera_y_rotation = value
			_update_camera()
		)
		ui_instance.camera_fov_changed.connect(func(value):
			camera_fov = value
			_update_camera()
		)
		# --- END Camera Signals ---

		# --- Connect Background Signal ---
		ui_instance.background_toggled.connect(func(is_on):
			show_2d_background = is_on
			_update_background()
			_update_view_visibility()
		)
		# --- END Background Signal ---
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
# --- Set initial visibility based on is_3d_view ---
	_update_view_visibility()
	# --- Web Specific Setup ---
	print("Control: _ready function running.")
	if not OS.has_feature("web"):
		print("Control: Not running on web.")
		# Optionally disable web-only buttons if desired
		# if is_instance_valid(ui_instance):
		#     ui_instance.load_preset_button.disabled = true # Example

	print("Control: _ready function finished.")
	resized.connect(_on_main_control_resized)
	_update_light() # Set initial light properties
	_update_camera() # Set initial camera properties
	_update_background() # Set initial background

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


func _update_feedback_ranges_in_ui():
	if is_instance_valid(ui_instance):
		# 1. Set the new min/max ranges on the slider and spinbox
		ui_instance.feedback_amount_slider.min_value = feedback_min
		ui_instance.feedback_amount_spinbox.min_value = feedback_min
		ui_instance.feedback_amount_slider.max_value = feedback_max
		ui_instance.feedback_amount_spinbox.max_value = feedback_max

		# 2. Clamp the current feedback_amount variable to the new range
		var clamped_value = clamp(feedback_amount, feedback_min, feedback_max)

		# 3. Check if the value actually needs to be changed
		if not is_equal_approx(feedback_amount, clamped_value):
			feedback_amount = clamped_value # Update the main variable

		# 4. Force the UI to update to the new clamped value
		# We use set_value_no_signal() to prevent a signal feedback loop
		ui_instance.feedback_amount_slider.set_value_no_signal(feedback_amount)
		ui_instance.feedback_amount_spinbox.set_value_no_signal(feedback_amount)


func reset_visuals() -> void:
	variation_mode_a = 0 # Reset to Sinusoidal ID
	variation_mode_b = 1 # Reset to Spherical ID
	start_pattern_mode = 0
	variation_mix = 0.5
	feedback_amount = 0.98
	seamless_tiling = true
	mirror_tiling = false
	reset_on_drag_enabled = true
	_set_platform_feedback_defaults()
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
	custom_tl_a = 0
	custom_tr_a = 0
	custom_bl_a = 0
	custom_br_a = 0
	custom_tl_b = 0
	custom_tr_b = 0
	custom_bl_b = 0
	custom_br_b = 0
	# --- ADD THESE ---
	light_x_rotation = 0.0
	light_y_rotation = 0.0
	light_energy = 1.0
	light_color = Color.WHITE
	light_shadows = true
	_update_light() # Apply the reset values
	# --- END ---
	normal_map_strength = 1.0
	
	camera_distance = 0.5
	camera_x_rotation = 0.0
	camera_y_rotation = 0.0
	camera_fov = 75.0
	show_2d_background = false
	_update_camera() # Apply reset values
	_update_background() # Apply reset values
	
	time = 0.0
	update_ui_from_state()
	reseed_pattern()

func reseed_pattern() -> void:
	time = 0.0 # Resets the shader time, often used for seeding noise/patterns

func update_ui_from_state() -> void:
	if is_instance_valid(ui_instance) and ui_instance.has_method("initialize_ui"):
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
			"custom_tl_a": custom_tl_a,
			"custom_tr_a": custom_tr_a,
			"custom_bl_a": custom_bl_a,
			"custom_br_a": custom_br_a,
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
			"custom_tl_b": custom_tl_b,
			"custom_tr_b": custom_tr_b,
			"custom_bl_b": custom_bl_b,
			"custom_br_b": custom_br_b,
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
			"show_2d_bg": show_2d_background
			
		}
		ui_instance.initialize_ui(values)

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
			var resolution = 1024 * pow(2, save_resolution_index)
			_render_and_save_image("", Vector2i(resolution, resolution))
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
			# --- NEW ---
			# Handle 3D desktop save
			_save_3d_view_desktop(path)
			# --- END NEW ---
		else:
			# Handle 2D desktop save
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
	save_material.set_shader_parameter("custom_tl_a", custom_tl_a)
	save_material.set_shader_parameter("custom_tr_a", custom_tr_a)
	save_material.set_shader_parameter("custom_bl_a", custom_bl_a)
	save_material.set_shader_parameter("custom_br_a", custom_br_a)

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
	save_material.set_shader_parameter("custom_tl_b", custom_tl_b)
	save_material.set_shader_parameter("custom_tr_b", custom_tr_b)
	save_material.set_shader_parameter("custom_bl_b", custom_bl_b)
	save_material.set_shader_parameter("custom_br_b", custom_br_b)

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
	target_material.set_shader_parameter("custom_tl_a", custom_tl_a)
	target_material.set_shader_parameter("custom_tr_a", custom_tr_a)
	target_material.set_shader_parameter("custom_bl_a", custom_bl_a)
	target_material.set_shader_parameter("custom_br_a", custom_br_a)
	

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
	target_material.set_shader_parameter("custom_tl_b", custom_tl_b)
	target_material.set_shader_parameter("custom_tr_b", custom_tr_b)
	target_material.set_shader_parameter("custom_bl_b", custom_bl_b)
	target_material.set_shader_parameter("custom_br_b", custom_br_b)
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
		"custom_tl_a": custom_tl_a,
		"custom_tr_a": custom_tr_a,
		"custom_bl_a": custom_bl_a,
		"custom_br_a": custom_br_a,

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
		"custom_tl_b": custom_tl_b,
		"custom_tr_b": custom_tr_b,
		"custom_bl_b": custom_bl_b,
		"custom_br_b": custom_br_b,
		
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
	custom_tl_a = data.get("custom_tl_a", 0)
	custom_tr_a = data.get("custom_tr_a", 0)
	custom_bl_a = data.get("custom_bl_a", 0)
	custom_br_a = data.get("custom_br_a", 0)

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
	custom_tl_b = data.get("custom_tl_b", 0)
	custom_tr_b = data.get("custom_tr_b", 0)
	custom_bl_b = data.get("custom_bl_b", 0)
	custom_br_b = data.get("custom_br_b", 0)
	
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
