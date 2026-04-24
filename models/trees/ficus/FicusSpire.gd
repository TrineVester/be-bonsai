class_name FicusSpire
extends RefCounted

# Stage 0 (<3 months): bare seedling — smooth thin trunk, round apex cluster
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, _age: float, _compact: float) -> void:
	mesh._visual.add_child(mesh._create_trunk(0.55, 0.022, 0.012, bark))
	# Ficus foliage is round and full even as a seedling
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, 0.64, 0.0), 0.10, 0.88, foliage, 1.0))
