class_name ChineseElmDeveloping
extends RefCounted

# Stage 2 (12–36 months): near-horizontal branches, wide flat 4-pad canopy beginning
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h  := lerpf(1.02, 1.58, t)
	var br := lerpf(0.052, 0.082, t)
	mesh._visual.add_child(mesh._create_trunk(h, br, 0.032, bark))
	if t > 0.40:
		mesh._visual.add_child(mesh._create_nebari(br * 1.80, bark.darkened(0.10)))

	var blen  := lerpf(0.38, 0.64, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(72.0, 84.0, t) * (1.0 - compact * 0.18)
	var bsr   := lerpf(0.018, 0.025, t)
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.44, 0.0),  90.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.44, 0.0), 270.0, btilt,        blen * 0.95, bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.60, 0.0),   0.0, btilt,        blen * 0.80, bsr * 0.80, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.60, 0.0), 180.0, btilt,        blen * 0.75, bsr * 0.80, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.72, 0.0),  45.0, btilt * 0.88, blen * 0.62, bsr * 0.65, bark))

	var pad := lerpf(0.28, 0.40, t) * (1.0 - compact * 0.48)
	var sp  := pad * 0.95
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( 0.0, h * 0.72,  0.0),      pad,        0.52, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(-sp,  h * 0.62,  0.0),      pad * 0.82, 0.52, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( sp,  h * 0.62,  0.0),      pad * 0.82, 0.52, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( 0.0, h * 0.62,  sp * 0.7), pad * 0.68, 0.54, foliage))
