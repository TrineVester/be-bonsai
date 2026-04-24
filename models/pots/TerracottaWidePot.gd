class_name TerracottaWidePot
extends PotMeshBase

# Wide shallow drum pot — low profile, broad opening, sandy light clay hue

func build_pot() -> void:
	var body_color := Color(0.85, 0.55, 0.35)  # light sandy terracotta
	var rim_color  := Color(0.78, 0.48, 0.28)

	var body_height := 0.22
	add_child(_create_pot_body(body_height, 0.42, 0.30, body_color))
	add_child(_create_pot_rim(0.42, body_height, rim_color))
	add_child(_create_soil_disc(0.42, body_height))
