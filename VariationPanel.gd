@tool
extends VBoxContainer


@export var panel_title: String = ""
# This array will appear in the Inspector.
# We will fill it out there to define our sliders.
@export var parameters: Array[VariationParameter] :
	set(value):
		parameters = value
		if Engine.is_editor_hint():
			_generate_controls()

# This signal will tell the main controller when a value changes.
# We pass the parameter name (like "clifford_a") and its new value.
signal value_updated(param_name: String, new_value: float)

# We need references to the controls we create to sync them.
var sliders: Dictionary = {}
var spinboxes: Dictionary = {}

func _ready():
	# This runs when the game starts.
	# We need to build the controls if they aren't already built.
	if get_child_count() == 0 and not parameters.is_empty():
		_generate_controls()

# The main function to build the UI
# The main function to build the UI
func _generate_controls():
	# Clear all old controls
	for c in get_children():
		c.queue_free()
		
	sliders.clear()
	spinboxes.clear()
	
	if not panel_title.is_empty():
		var title_label = Label.new()
		title_label.text = panel_title
		# Optional: Add some styling to make it look like a title
		title_label.add_theme_font_size_override("font_size", 16) # Makes it a bit bigger
		add_child(title_label)

	if parameters.is_empty():
		return

	# Rebuild the UI from the array
	for param in parameters:
		# Get data from the resource, using its direct properties
		var p_name: String = param.name
		var p_label: String = param.label
		var p_default: float = param.default
		var p_min: float = param.min
		var p_max: float = param.max
		var p_step: float = param.step

		# If the label is empty, auto-capitalize the name
		if p_label == "":
			p_label = p_name.capitalize()

		var hbox = HBoxContainer.new()
		hbox.name = p_name + "Container" # Set a name for clarity
		
		var label = Label.new()
		label.text = p_label
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_stretch_ratio = 0.5 # Give label 1/3 of space
		
		var slider = HSlider.new()
		slider.name = p_name + "Slider"
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_stretch_ratio = 1.0 # Give slider 2/3 of space
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
		spinbox.custom_minimum_size = Vector2(70, 0) # Give it some space
		
		hbox.add_child(label)
		hbox.add_child(slider)
		hbox.add_child(spinbox)
		add_child(hbox)
		
		# --- Store references ---
		sliders[p_name] = slider
		spinboxes[p_name] = spinbox
		
		# --- Connect signals ---
		# Connect them to a local function that will sync them
		# and then emit our public signal.
		slider.value_changed.connect(_on_control_value_changed.bind(p_name, spinbox))
		spinbox.value_changed.connect(_on_control_value_changed.bind(p_name, slider))
# This function is called by EITHER the slider or spinbox
func _on_control_value_changed(new_value: float, param_name: String, control_to_sync: Control):
	# Sync the other control
	control_to_sync.set_value_no_signal(new_value)
	
	# Emit our public signal so the main controller knows
	emit_signal("value_updated", param_name, new_value)


# --- Public functions ---
# A function our main_controller can call to set the value
# without triggering a new signal
func set_param_value(param_name: String, new_value: float):
	if sliders.has(param_name):
		sliders[param_name].set_value_no_signal(new_value)
		spinboxes[param_name].set_value_no_signal(new_value)

# A function to set the panel's visibility
func set_panel_visible(is_visible: bool):
	visible = is_visible
