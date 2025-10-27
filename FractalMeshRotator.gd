extends MeshInstance3D

var is_dragging = false
var previous_mouse_position = Vector2.ZERO
var rotation_speed = 0.01 # Adjust this value to change sensitivity

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				previous_mouse_position = event.position
			else:
				is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		var mouse_delta = event.position - previous_mouse_position
		previous_mouse_position = event.position

		# Rotate around Y axis based on horizontal mouse movement
		rotate_y(mouse_delta.x * rotation_speed)
		# Rotate around X axis based on vertical mouse movement
		rotate_object_local(Vector3.RIGHT, mouse_delta.y * rotation_speed)
