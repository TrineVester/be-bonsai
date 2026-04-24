class_name TerracottaClassicPot
extends PotMeshBase

# Classic oval bonsai pot — medium height, tapered sides, standard terracotta hue

func build_pot() -> void:
	var body_color := Color(0.78, 0.38, 0.22)  # standard terracotta
	var rim_color  := Color(0.72, 0.33, 0.18)  # slightly darker rim

	var body_height := 0.35
	add_child(_create_pot_body(body_height, 0.28, 0.18, body_color))
	add_child(_create_pot_rim(0.28, body_height, rim_color))
	add_child(_create_soil_disc(0.28, body_height))
