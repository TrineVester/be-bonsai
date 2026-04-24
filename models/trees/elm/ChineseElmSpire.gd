class_name ChineseElmSpire
extends RefCounted

# Stage 0 (<3 months): bare seedling — slender trunk, very flat tiny apex pad
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, _age: float, _compact: float) -> void:
	var h := 0.60
	mesh._visual.add_child(mesh._create_trunk(h, 0.022, 0.010, bark))
	# Apex pad sits right at trunk top
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h, 0.0), 0.09, 0.42, foliage, 1.8))
