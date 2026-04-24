class_name JuniperDeveloping
extends RefCounted

# Stage 2 (12–36 months): visible primary branches, defined 3-tier foliage
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, age: float, compact: float) -> void:
	var t   := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h   := lerpf(1.05, 1.65, t)
	var br  := lerpf(0.058, 0.085, t)
	mesh._visual.add_child(mesh._create_trunk(h, br, 0.032, bark))
	if t > 0.45:
		mesh._visual.add_child(mesh._create_nebari(br * 1.9, bark.darkened(0.12)))

	var blen  := lerpf(0.28, 0.52, t) * (1.0 - compact * 0.28)
	var btilt := lerpf(70.0, 80.0, t) * (1.0 - compact * 0.18)
	var bsr   := lerpf(0.016, 0.024, t)
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.35, 0.0),  90.0, btilt, blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.35, 0.0), 270.0, btilt, blen * 0.90, bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.54, 0.0),   0.0, btilt, blen * 0.78, bsr * 0.80, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.54, 0.0), 180.0, btilt, blen * 0.72, bsr * 0.80, bark))

	var pad := lerpf(0.26, 0.40, t) * (1.0 - compact * 0.40)
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.43, 0.0), pad,        0.62, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.62, 0.0), pad * 0.75, 0.62, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.80, 0.0), pad * 0.52, 0.65, foliage))
