extends Camera3D

# Settings
var mouse_sensitivity: float = 0.002
var move_speed: float = 5.0
var boost_multiplier: float = 4.0

# State
var _mouse_captured: bool = false

func _ready():
	# Ensure we start without capturing the mouse so you can use the UI
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event):
	# Toggle Fly Mode with RIGHT MOUSE BUTTON
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				# Capture mouse (Hide cursor, enable look)
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				_mouse_captured = true
			else:
				# Release mouse (Show cursor, enable UI)
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				_mouse_captured = false

	# Mouse Look Logic
	if event is InputEventMouseMotion and _mouse_captured:
		# Rotate Yaw (Left/Right)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotate Pitch (Up/Down) - Clamped so you don't flip over
		var rotation_x = rotation.x - event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))

func _process(delta):
	if not _mouse_captured:
		return

	# Keyboard Movement (WASD + Q/E)
	var input_dir = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W): input_dir.z -= 1
	if Input.is_key_pressed(KEY_S): input_dir.z += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	if Input.is_key_pressed(KEY_E): input_dir.y += 1 # Fly Up
	if Input.is_key_pressed(KEY_Q): input_dir.y -= 1 # Fly Down

	# Speed Boost (Shift)
	var current_speed = move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed *= boost_multiplier

	# Apply Movement relative to where we are looking
	if input_dir.length() > 0:
		translate(input_dir.normalized() * current_speed * delta)
