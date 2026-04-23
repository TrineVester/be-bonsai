class_name ChineseElmMesh
extends TreeMeshBase

# Chinese Elm: wide spreading canopy, reddish-brown flaky bark, umbrella shape

func build_tree() -> void:
	var trunk_color := Color(0.42, 0.25, 0.14)    # warm reddish-brown bark
	var foliage_color := Color(0.25, 0.48, 0.20)  # fresh light green

	add_child(_create_trunk(1.6, 0.11, 0.05, trunk_color))

	# Wide spread of clusters — umbrella/informal upright silhouette
	add_child(_create_foliage(0.45, Vector3(0.0,  1.7,  0.0),  foliage_color))
	add_child(_create_foliage(0.35, Vector3(-0.5, 1.5,  0.1),  foliage_color))
	add_child(_create_foliage(0.35, Vector3(0.5,  1.5, -0.1),  foliage_color))
	add_child(_create_foliage(0.28, Vector3(-0.3, 1.3,  0.3),  foliage_color))
	add_child(_create_foliage(0.28, Vector3(0.3,  1.3, -0.3),  foliage_color))
