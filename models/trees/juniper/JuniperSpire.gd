class_name JuniperSpire
extends RefCounted

# Stage 0 (<3 months): bare seedling — thin trunk, tiny flat apex tuft
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, _age: float, _compact: float) -> void:
	var h := 0.65
	mesh._visual.add_child(mesh._create_trunk(h, 0.025, 0.010, bark))
	# Apex pad sits right at trunk top
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h, 0.0), 0.10, 0.38, foliage, 0.6))
