extends MultiMeshInstance3D

@export var grid_size: int = 128  # 128x128 = 16,384 cylinders
@export var spacing: float = 1.2

func _ready():
	# 1. Initialize the MultiMesh
	multimesh.instance_count = grid_size * grid_size
	multimesh.visible_instance_count = grid_size * grid_size
	
	var index = 0
	for x in range(grid_size):
		for y in range(grid_size):
			# 2. Position the cylinder in a flat grid
			var pos = Vector3(x * spacing, 0, y * spacing)
			var t = Transform3D(Basis(), pos)
			multimesh.set_instance_transform(index, t)
			
			# 3. Store the "UV" coordinate in the Custom Data
			# We pass this to the shader so it knows which part of the texture to read!
			var uv_x = float(x) / float(grid_size)
			var uv_y = float(y) / float(grid_size)
			multimesh.set_instance_custom_data(index, Color(uv_x, uv_y, 0.0, 0.0))
			
			index += 1
