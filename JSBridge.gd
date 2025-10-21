# JSBridge.gd - SIMPLIFIED
extends Node

signal preset_loaded(json_string: String)

func _ready():
	print("JSBridge: _ready function STARTED.")
	# No JS callback setup here anymore
	print("JSBridge: _ready function FINISHED.")

# This function will eventually be called BY JavaScript via the callback
# that Control.gd sets up.
func load_preset_from_js_callback(args):
	print("JSBridge: load_preset_from_js_callback RECEIVED data.")
	if args.size() > 0 and typeof(args[0]) == TYPE_STRING:
		var json_string = args[0]
		print("JSBridge: Received VALID preset string via callback! Emitting signal.")
		# Optional: print("JSON string received: ", json_string)
		emit_signal("preset_loaded", json_string)
	else:
		print("JSBridge Error: Invalid or missing data received from JavaScript callback. Args received: ", args)
