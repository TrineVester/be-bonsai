class_name ChineseElmDeveloping
extends RefCounted

# Stage 2 (12–36 months): near-horizontal branches, wide flat umbrella canopy (winter-aware)
# foliage2 is the lighter highlight colour
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h  := lerpf(1.02, 1.58, t)
	var br := lerpf(0.052, 0.082, t)

	# Slight S-curve lean — common in Chinese Elm bonsai
	mesh._visual.add_child(mesh._create_trunk(h * 0.52, br, br * 0.68, bark))
	var upper := mesh._create_trunk(h * 0.52, br * 0.68, 0.030, bark)
	upper.position.y = h * 0.52 - (h * 0.52) * 0.5
	upper.rotation_degrees.z = 2.2
	upper.position.x = 0.03
	mesh._visual.add_child(upper)

	if t > 0.35:
		mesh._visual.add_child(mesh._create_nebari(br * 1.90, bark.darkened(0.12)))

	# Elm branches very nearly horizontal — high tilt, wide reach
	var blen  := lerpf(0.40, 0.68, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(76.0, 86.0, t) * (1.0 - compact * 0.18)
	var bsr   := lerpf(0.018, 0.025, t)
	mesh._add_branch("b_low_r", 12.0, Vector3(0.0, h * 0.42, 0.0),  90.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_low_l", 12.0, Vector3(0.0, h * 0.42, 0.0), 270.0, btilt,        blen * 0.95, bsr,        bark)
	mesh._add_branch("b_mid_f", 18.0, Vector3(0.0, h * 0.58, 0.0),   0.0, btilt,        blen * 0.80, bsr * 0.80, bark)
	mesh._add_branch("b_mid_b", 18.0, Vector3(0.0, h * 0.58, 0.0), 180.0, btilt,        blen * 0.76, bsr * 0.80, bark)
	mesh._add_branch("b_up_45", 26.0, Vector3(0.0, h * 0.70, 0.0),  45.0, btilt * 0.88, blen * 0.62, bsr * 0.65, bark)

	# Winter: bare branch structure only
	if mesh.is_winter():
		return

	# Very flat umbrella pads at branch tips — born with their branch, plus apex
	var pad := lerpf(0.30, 0.44, t) * (1.0 - compact * 0.48)
	if age >= 12.0:
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.42, 0.0),  90.0, btilt,        blen),        pad,        0.30, foliage,  2.4))
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.42, 0.0), 270.0, btilt,        blen * 0.95), pad * 0.95, 0.30, foliage2, 2.4))
	if age >= 18.0:
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.58, 0.0),   0.0, btilt,        blen * 0.80), pad * 0.80, 0.30, foliage2, 2.2))
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.58, 0.0), 180.0, btilt,        blen * 0.76), pad * 0.76, 0.30, foliage,  2.2))
	if age >= 26.0:
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.70, 0.0),  45.0, btilt * 0.88, blen * 0.62), pad * 0.62, 0.32, foliage2, 2.0))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.92, 0.0), pad * 0.55, 0.32, foliage, 2.0))
