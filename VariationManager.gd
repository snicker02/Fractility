# VariationManager.gd

extends Node

# This is our master list of all variations.
# The KEY is the name that appears in the UI.
# The VALUE is another dictionary with its properties.
# The "id" is the stable number we send to the shader. IT NEVER CHANGES.
const VARIATIONS = {
	# Rep-Tiles Category
	"L-tromino":        { "id": 19, "controls": null,       "category": "Rep-Tile" },
	"Custom 2x2 Tile":  { "id": 20, "controls": "custom_2x2", "category": "Rep-Tile" },
	"Sphinx":           { "id": 21, "controls": null, "category": "Rep-Tile" },
	# Add other true rep-tiles here later

	# Other Variations (Sorted Alphabetically)
	"Apollonian Gasket": { "id": 13, "controls": "apollonian" }, 
	"ArcTangent":       { "id": 16, "controls": null },
	"Blur":             { "id": 11, "controls": "blur" },
	# ... (rest of your variations) ...
	"Cosine":           { "id": 14, "controls": null },
	"Fisheye":          { "id": 6, "controls": "fisheye" },
	"Heart":            { "id": 12, "controls": "heart" },
	"Hyperbolic Cosine":{ "id": 18, "controls": null },
	"Hyperbolic Sine":  { "id": 17, "controls": null },
	"Julian2":          { "id": 4, "controls": "julian" },
	"Kaleidoscope":     { "id": 8, "controls": "kaleidoscope" },
	"Mirror":           { "id": 7, "controls": "mirror" },
	"Mobius":           { "id": 9, "controls": "mobius" },
	"Polar":            { "id": 5, "controls": "polar" },
	"Sinusoidal":       { "id": 0, "controls": null },
	"Spherical":        { "id": 1, "controls": null },
	"Swirl":            { "id": 2, "controls": null },
	"Tangent":          { "id": 15, "controls": null },
	"Wave":             { "id": 3, "controls": "wave" },
}

# --- Function to get variations data ---
func get_variations_data() -> Array[Dictionary]:
	# ... (This function remains the same) ...
	var list: Array[Dictionary] = []
	var keys = VARIATIONS.keys()
	keys.sort()
	for key in keys:
		var data = VARIATIONS[key].duplicate()
		data["name"] = key
		list.append(data)
	return list
