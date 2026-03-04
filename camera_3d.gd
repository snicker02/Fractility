extends Camera3D

@export var movement_speed: float = 2.0
@export var look_sensitivity: float = 0.15
@export var scroll_speed: float = 0.5 # Controls zoom sensitivity
var fly_speed: float = .1

var rotation_x: float = 0.0
var rotation_y: float = 0.0

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F2:
			# Find the RuntimeDebugTools node in the root
			var rdt = get_node_or_null("/root/RuntimeDebugTools")
			if rdt:
				# Find the child named DebugUI which contains the visual menu
				var ui = rdt.get_node_or_null("DebugUI")
				if ui:
					ui.visible = !ui.visible
					print("Toggled Debug UI: ", ui.visible)
	# 1. Right-Click to capture mouse, Release to free it
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		# 2. Mouse Wheel Zoom (Scroll Up = Forward, Scroll Down = Backward)
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				global_position += -transform.basis.z * scroll_speed
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				global_position += transform.basis.z * scroll_speed

	# 3. Mouse Look logic (only happens if mouse is captured)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_y -= event.relative.x * look_sensitivity
		rotation_x -= event.relative.y * look_sensitivity
		rotation_x = clamp(rotation_x, -90, 90)
		rotation_degrees = Vector3(rotation_x, rotation_y, 0)

func set_rotation_from_basis(b: Basis):
	var euler = b.get_euler()
	rotation_x = rad_to_deg(euler.x)
	rotation_y = rad_to_deg(euler.y)
	rotation_degrees = Vector3(rotation_x, rotation_y, 0)

func _ready():
	near = 0.001
	far = 4000.0

func _process(delta):


	var input_dir = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.z -= 1
	if Input.is_key_pressed(KEY_S): input_dir.z += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	if Input.is_key_pressed(KEY_Q): input_dir.y -= 1 # Fly Down
	if Input.is_key_pressed(KEY_E): input_dir.y += 1 # Fly Up

	if input_dir != Vector3.ZERO:
		# 1. Calculate direction based on where the camera is looking
		var move_vec = (transform.basis * input_dir).normalized()
		
		# 2. Use fly_speed (the slider variable) and delta for smooth movement
		global_position += move_vec * fly_speed * delta
func reset_internal_rotation():
	rotation_x = 0.0
	rotation_y = 0.0
