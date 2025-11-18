@tool
class_name VariationParameter
extends Resource

# --- Defines the control types ---
enum ControlType { SLIDER, DROPDOWN }
@export var control_type: ControlType = ControlType.SLIDER

# --- These properties are for ALL control types ---
@export var name: String
@export var label: String

# --- NEW: This checkbox will auto-create a speed slider ---
# This is the property your new VariationPanel.gd script is looking for.
@export var add_speed_control: bool = false 

# --- These properties are for SLIDERS ---
@export var default: float = 0.0
@export var min: float = -10.0
@export var max: float = 10.0
@export var step: float = 0.001

# --- These properties are for DROPDOWNS ---
@export var dropdown_options: PackedStringArray
