class_name ChineseElmSpire
extends RefCounted

# Stage 0 (<3 months): bare seedling
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, _age: float, _compact: float) -> void:
	mesh._visual.add_child(mesh._create_trunk(0.60, 0.022, 0.010, bark))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, 0.67, 0.0), 0.09, 0.85, foliage))
