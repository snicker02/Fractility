extends MeshInstance3D

@export var move_speed: float = 2.0
var slice_pos: Vector2 = Vector2.ZERO

func _process(delta):
	var mat = get_active_material(0)
	if not mat:
		return

	var input_dir = Vector2.ZERO
	
	# Keyboard Input
	if Input.is_key_pressed(KEY_W): input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S): input_dir.y += 1.0
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D): input_dir.x += 1.0
	
	if input_dir != Vector2.ZERO:
		# Safety check for the Zoom parameter
		var zoom = mat.get_shader_parameter("SliceZoom")
		if zoom == null: 
			zoom = 1.0 # Default to 1.0 if the uniform isn't found
			
		# Apply movement
		slice_pos += input_dir.normalized() * move_speed * delta * zoom
		
		# Set the uniform
		mat.set_shader_parameter("SliceOffset", slice_pos)

	# BONUS: Q/E to change W-depth
	if Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_E):
		var w_change = (1.0 if Input.is_key_pressed(KEY_E) else -1.0) * delta
		var current_w = mat.get_shader_parameter("SliceW")
		if current_w != null:
			mat.set_shader_parameter("SliceW", current_w + w_change)
