class_name JuniperSpire
extends RefCounted

# Stage 0 (<3 months): bare seedling — thin trunk, tiny apex tuft
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, _age: float, _compact: float) -> void:
	mesh._visual.add_child(mesh._create_trunk(0.65, 0.025, 0.010, bark))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, 0.72, 0.0), 0.10, 0.80, foliage))
