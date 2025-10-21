# VariationManager.gd

extends Node

# This is our master list of all variations.
# The KEY is the name that appears in the UI.
# The VALUE is another dictionary with its properties.
# The "id" is the stable number we send to the shader. IT NEVER CHANGES.
const VARIATIONS = {
	"Apollonian": { "id": 13, "controls": "apollonian" },
	"Blur":         { "id": 11, "controls": "blur" },
	"Cellular Weave": { "id": 10, "controls": "cellular_weave" },
	"Fisheye":      { "id": 6, "controls": "fisheye" },
	"Heart":        { "id": 12, "controls": "heart" },
	"Julian2":      { "id": 4, "controls": "julian" },
	"Kaleidoscope": { "id": 8, "controls": "kaleidoscope" },
	"Mirror":       { "id": 7, "controls": "mirror" },
	"Mobius":       { "id": 9, "controls": "mobius" }, 
	"Polar":        { "id": 5, "controls": "polar" },
	"Sinusoidal":   { "id": 0, "controls": null },
	"Spherical":    { "id": 1, "controls": null },
	"Swirl":        { "id": 2, "controls": null },
	"Wave":         { "id": 3, "controls": "wave" },
	
}

# A helper function to get the sorted list of names for the UI
func get_sorted_variation_names() -> Array[String]:
	# Create an empty, correctly typed array first.
	var names: Array[String] = []
	# Use the assign() method to copy the keys into the typed array.
	names.assign(VARIATIONS.keys())
	
	names.sort()
	return names
