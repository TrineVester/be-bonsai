class_name FicusMature
extends RefCounted

# Stage 3 (36+ months): full dome — 6 branches, 5 overlapping round pads
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.55, 1.80, t)
	var br := lerpf(0.085, 0.108, t)
	mesh._visual.add_child(mesh._create_trunk(h, br, 0.032, bark))
	mesh._visual.add_child(mesh._create_nebari(br * 2.1, bark.darkened(0.08)))

	var blen  := lerpf(0.58, 0.72, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(78.0, 86.0, t) * (1.0 - compact * 0.18)
	var bsr   := 0.028
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.42, 0.0),   0.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.42, 0.0), 120.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.42, 0.0), 240.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.62, 0.0),  60.0, btilt * 0.78, blen * 0.70, bsr * 0.72, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.62, 0.0), 180.0, btilt * 0.78, blen * 0.70, bsr * 0.72, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.62, 0.0), 300.0, btilt * 0.78, blen * 0.65, bsr * 0.72, bark))

	var pad := lerpf(0.42, 0.50, t) * (1.0 - compact * 0.45)
	var sp  := pad * 0.72
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  0.0,          h * 0.78,  0.0),       pad,        0.65, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( -sp,           h * 0.67,  0.06),       pad * 0.80, 0.68, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  sp,           h * 0.67, -0.06),       pad * 0.80, 0.68, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( sp * 0.55,     h * 0.64,  sp * 0.85),  pad * 0.68, 0.68, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(-sp * 0.55,     h * 0.64, -sp * 0.85),  pad * 0.68, 0.68, foliage))
