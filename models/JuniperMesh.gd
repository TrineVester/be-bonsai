class_name JuniperMesh
extends TreeMeshBase

# Juniper: tall narrow silhouette, stacked foliage clusters, dark bark

func build_tree() -> void:
	var trunk_color := Color(0.28, 0.18, 0.10)    # dark reddish-brown bark
	var foliage_color := Color(0.15, 0.35, 0.15)  # deep forest green

	add_child(_create_trunk(2.0, 0.12, 0.05, trunk_color))

	# Stacked clusters getting smaller toward top — conifer silhouette
	add_child(_create_foliage(0.55, Vector3(0.0, 1.0, 0.0), foliage_color))
	add_child(_create_foliage(0.40, Vector3(0.0, 1.55, 0.0), foliage_color))
	add_child(_create_foliage(0.25, Vector3(0.0, 1.95, 0.0), foliage_color))
