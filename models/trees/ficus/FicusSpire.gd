class_name FicusSpire
extends RefCounted

# Stage 0 (<3 months): bare seedling — smooth thin trunk, round apex cluster
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, _age: float, _compact: float) -> void:
	var h := 0.55
	mesh._visual.add_child(mesh._create_trunk(h, 0.022, 0.012, bark))
	# Apex pad sits right at trunk top
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h, 0.0), 0.10, 0.88, foliage, 1.0))
