class_name JuniperSpire
extends RefCounted

# Stage 0 (<3 months): bare seedling — thin trunk, tiny flat apex tuft
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, _age: float, _compact: float) -> void:
	mesh._visual.add_child(mesh._create_trunk(0.65, 0.025, 0.010, bark))
	# Very flat spray at apex — juniper needle character even as seedling
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, 0.70, 0.0), 0.10, 0.38, foliage, 0.6))
