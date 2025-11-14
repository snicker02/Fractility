@tool
extends Resource
class_name VariationParameter

@export var name: String = ""
@export var label: String = ""
@export var is_speed_control: bool = false
@export var default: float = 0.0
@export var min: float = -10.0
@export var max: float = 10.0
@export var step: float = 0.001
