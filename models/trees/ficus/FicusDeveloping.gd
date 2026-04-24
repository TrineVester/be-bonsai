class_name FicusDeveloping
extends RefCounted

# Stage 2 (12–36 months): 3 radiating primary branches, 3-pad dome forming
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h  := lerpf(0.98, 1.55, t)
	var br := lerpf(0.054, 0.085, t)
	mesh._visual.add_child(mesh._create_trunk(h, br, 0.034, bark))
	if t > 0.40:
		mesh._visual.add_child(mesh._create_nebari(br * 1.75, bark.darkened(0.06)))

	var blen  := lerpf(0.32, 0.55, t) * (1.0 - compact * 0.25)
	var btilt := lerpf(62.0, 76.0, t) * (1.0 - compact * 0.20)
	var bsr   := lerpf(0.018, 0.026, t)
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.50, 0.0),   0.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.50, 0.0), 120.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.50, 0.0), 240.0, btilt,        blen * 0.90, bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.68, 0.0),  60.0, btilt * 0.85, blen * 0.68, bsr * 0.72, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.68, 0.0), 180.0, btilt * 0.85, blen * 0.62, bsr * 0.72, bark))

	var pad := lerpf(0.28, 0.40, t) * (1.0 - compact * 0.42)
	var sp  := pad * 0.65
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  0.0, h * 0.75,  0.0),  pad,        0.68, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( -sp,  h * 0.64,  0.06), pad * 0.76, 0.68, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  sp,  h * 0.64, -0.06), pad * 0.76, 0.68, foliage))
