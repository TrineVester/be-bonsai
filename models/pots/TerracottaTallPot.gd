class_name TerracottaTallPot
extends PotMeshBase

# Tall upright pot — narrow and deep, dark burnt clay hue

func build_pot() -> void:
	var body_color := Color(0.62, 0.28, 0.16)  # dark burnt terracotta
	var rim_color  := Color(0.55, 0.23, 0.12)

	var body_height := 0.52
	add_child(_create_pot_body(body_height, 0.22, 0.14, body_color))
	add_child(_create_pot_rim(0.22, body_height, rim_color))
