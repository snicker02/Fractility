@tool
extends VBoxContainer

@export var panel_title: String = ""
@export var parameters: Array[VariationParameter] :
	set(value):
		parameters = value
		if Engine.is_editor_hint():
			_generate_controls()

# Make sure your signal matches the one you emit
signal value_updated(param_name: String, new_value: float, is_speed: bool)

# Dictionaries to store all created controls
var controls: Dictionary = {}
var spinboxes: Dictionary = {}

func _ready():
	if get_child_count() == 0 and not parameters.is_empty():
		_generate_controls()

# --- UPDATED: This function now auto-builds speed controls ---
func _generate_controls():
	# Clear all old controls
	for c in get_children():
		c.queue_free()
		
	controls.clear()
	spinboxes.clear()
	
	if not panel_title.is_empty():
		var title_label = Label.new()
		title_label.text = panel_title
		title_label.add_theme_font_size_override("font_size", 16)
		add_child(title_label)

	if parameters.is_empty():
		return

	# Rebuild the UI from the array
	for param in parameters:
		# 1. Build the main control for this parameter
		match param.control_type:
			VariationParameter.ControlType.SLIDER:
				_build_slider(param, false) # Build the MAIN slider (is_speed = false)
			VariationParameter.ControlType.DROPDOWN:
				_build_dropdown(param) # Build the dropdown
		
		# 2. --- NEW: If requested, build a speed slider for it ---
		if param.add_speed_control:
			# Create a "virtual" parameter resource for the speed slider
			var speed_param = VariationParameter.new()
			speed_param.name = param.name + "_speed"
			speed_param.label = param.label # Use same label, _build_slider will add "(Speed)"
			speed_param.default = 0.0
			speed_param.min = -1.0 # Default speed range
			speed_param.max = 1.0
			speed_param.step = 0.01
			
			# Build the secondary slider (is_speed = true)
			_build_slider(speed_param, true)


# --- UPDATED: This function now takes an 'is_speed' flag ---
func _build_slider(param: VariationParameter, is_speed: bool):
	var p_name: String = param.name
	var p_label: String = param.label
	var p_default: float = param.default
	var p_min: float = param.min
	var p_max: float = param.max
	var p_step: float = param.step

	if p_label == "":
		p_label = p_name.capitalize()
		
	# This logic now correctly labels the speed slider
	if is_speed:
		p_label += " (Speed)"

	var hbox = HBoxContainer.new()
	hbox.name = p_name + "Container"
	
	var label = Label.new()
	label.text = p_label
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_stretch_ratio = 0.5
	
	var slider = HSlider.new()
	slider.name = p_name + "Slider"
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_stretch_ratio = 1.0
	slider.min_value = p_min
	slider.max_value = p_max
	slider.step = p_step
	slider.value = p_default

	var spinbox = SpinBox.new()
	spinbox.name = p_name + "SpinBox"
	spinbox.min_value = p_min
	spinbox.max_value = p_max
	spinbox.step = p_step
	spinbox.value = p_default
	spinbox.custom_minimum_size = Vector2(70, 0)
	
	hbox.add_child(label)
	hbox.add_child(slider)
	hbox.add_child(spinbox)
	add_child(hbox)
	
	controls[p_name] = slider 
	spinboxes[p_name] = spinbox
	
	# Pass the 'is_speed' flag to the handler
	slider.value_changed.connect(_on_control_value_changed.bind(p_name, spinbox, is_speed))
	spinbox.value_changed.connect(_on_control_value_changed.bind(p_name, slider, is_speed))


# --- This function builds a dropdown (unchanged) ---
func _build_dropdown(param: VariationParameter):
	var p_name: String = param.name
	var p_label: String = param.label
	var p_default_index: int = int(param.default)
	var p_options: PackedStringArray = param.dropdown_options

	if p_label == "":
		p_label = p_name.capitalize()

	var hbox = HBoxContainer.new()
	hbox.name = p_name + "Container"
	
	var label = Label.new()
	label.text = p_label
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(label)
	
	var dropdown = OptionButton.new()
	dropdown.name = p_name + "Dropdown"
	dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dropdown.clip_text = true
	
	for item_text in p_options:
		dropdown.add_item(item_text)
		
	dropdown.select(p_default_index)
	
	hbox.add_child(dropdown)
	add_child(hbox)
	
	controls[p_name] = dropdown 
	
	dropdown.item_selected.connect(_on_dropdown_param_changed.bind(p_name))

# --- UPDATED: Handler now receives 'is_speed' ---
func _on_control_value_changed(new_value: float, param_name: String, control_to_sync: Control, is_speed: bool):
	control_to_sync.set_value_no_signal(new_value)
	# Pass 'is_speed' to the main controller
	emit_signal("value_updated", param_name, new_value, is_speed)


# --- Dropdown handler (unchanged) ---
func _on_dropdown_param_changed(index: int, param_name: String):
	# 'is_speed' is hard-coded to false for dropdowns
	emit_signal("value_updated", param_name, float(index), false)


# --- UPDATED: Now checks control types ---
func set_param_value(param_name: String, new_value: float):
	if controls.has(param_name):
		var control = controls[param_name]
		
		if control is HSlider:
			control.set_value_no_signal(new_value)
			spinboxes[param_name].set_value_no_signal(new_value)
		elif control is OptionButton:
			control.select(int(new_value))

# --- Public helper functions (unchanged) ---
func set_panel_visible(is_visible: bool):
	visible = is_visible

func get_slider(param_name: String) -> HSlider:
	if controls.has(param_name) and controls[param_name] is HSlider:
		return controls[param_name]
	return null

func get_spinbox(param_name: String) -> SpinBox:
	return spinboxes.get(param_name)
