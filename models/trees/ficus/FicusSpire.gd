class_name FicusSpire
extends RefCounted

# Stage 0 (<3 months): bare seedling
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, _age: float, _compact: float) -> void:
	mesh._visual.add_child(mesh._create_trunk(0.55, 0.022, 0.012, bark))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, 0.62, 0.0), 0.09, 0.90, foliage))
