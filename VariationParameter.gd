@tool
extends Resource
class_name VariationParameter

enum ControlType {
	SLIDER,
	DROPDOWN,
	CHECKBOX
}

@export var control_type: ControlType = ControlType.SLIDER
@export var name: String = ""
@export var label: String = ""
@export var add_speed_control: bool = false

# --- HIGH PRECISION SLIDER SETTINGS ---
# The "0.00001" tells Godot to allow 5 decimal places.
# "or_greater/less" allows you to type numbers outside the slider range if needed.

@export_range(-10000.0, 10000.0, 0.00001, "or_greater", "or_less") var default: float = 0.0
@export_range(-10000.0, 10000.0, 0.00001, "or_greater", "or_less") var min: float = 0.0
@export_range(-10000.0, 10000.0, 0.00001, "or_greater", "or_less") var max: float = 1.0
@export_range(0.00001, 100.0, 0.00001, "or_greater") var step: float = 0.01

# Dropdown settings
@export var dropdown_options: PackedStringArray = []
