class_name ChineseElmMature
extends RefCounted

# Stage 3 (36+ months): wide umbrella — 8 near-horizontal branches, 7-pad flat canopy
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.58, 1.82, t)
	var br := lerpf(0.082, 0.108, t)
	mesh._visual.add_child(mesh._create_trunk(h, br, 0.030, bark))
	mesh._visual.add_child(mesh._create_nebari(br * 2.35, bark.darkened(0.14)))

	var blen  := lerpf(0.66, 0.82, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(82.0, 88.0, t) * (1.0 - compact * 0.16)
	var bsr   := 0.026
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.36, 0.0),  90.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.36, 0.0), 270.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.50, 0.0),   0.0, btilt,        blen * 0.85, bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.50, 0.0), 180.0, btilt,        blen * 0.85, bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.62, 0.0),  45.0, btilt * 0.88, blen * 0.70, bsr * 0.78, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.62, 0.0), 225.0, btilt * 0.88, blen * 0.68, bsr * 0.78, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.70, 0.0), 135.0, btilt * 0.75, blen * 0.55, bsr * 0.62, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.70, 0.0), 315.0, btilt * 0.75, blen * 0.52, bsr * 0.62, bark))

	var pad := lerpf(0.40, 0.48, t) * (1.0 - compact * 0.52)
	var sp  := pad * 1.12
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  0.0,       h * 0.75,  0.0),        pad * 0.82, 0.48, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( -sp,        h * 0.64,  0.0),        pad,        0.48, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  sp,        h * 0.64,  0.0),        pad,        0.48, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  0.0,       h * 0.64,  sp * 0.85),  pad * 0.84, 0.50, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  0.0,       h * 0.64, -sp * 0.85),  pad * 0.84, 0.50, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(-sp * 0.7,   h * 0.61,  sp * 0.55),  pad * 0.66, 0.52, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( sp * 0.7,   h * 0.61, -sp * 0.55),  pad * 0.66, 0.52, foliage))
