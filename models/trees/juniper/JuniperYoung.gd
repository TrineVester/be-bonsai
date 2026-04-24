class_name JuniperYoung
extends RefCounted

# Stage 1 (3–12 months): thickening trunk, first two flat horizontal spray tiers
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, age: float, compact: float) -> void:
	var t := clampf((age - 3.0) / 9.0, 0.0, 1.0)
	var h := lerpf(0.65, 1.05, t)
	mesh._visual.add_child(mesh._create_trunk(h, lerpf(0.030, 0.058, t), lerpf(0.010, 0.024, t), bark))
	var r := lerpf(0.10, 0.28, t) * (1.0 - compact * 0.30)
	# Single apex spray pad — juniper grows upward first, branches come later in Developing
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 1.00, 0.0), r, 0.38, foliage, 0.7))
