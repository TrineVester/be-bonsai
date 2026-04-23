class_name FicusMesh
extends TreeMeshBase

# Ficus: round full canopy, light gray bark, tropical indoor look

func build_tree() -> void:
	var trunk_color := Color(0.70, 0.68, 0.62)    # pale gray bark
	var foliage_color := Color(0.20, 0.45, 0.18)  # medium green

	add_child(_create_trunk(1.5, 0.10, 0.06, trunk_color))

	# Large round central mass with two smaller side clusters
	add_child(_create_foliage(0.65, Vector3(0.0,  1.6, 0.0),  foliage_color))
	add_child(_create_foliage(0.40, Vector3(-0.4, 1.4, 0.0),  foliage_color))
	add_child(_create_foliage(0.40, Vector3(0.4,  1.4, 0.0),  foliage_color))
