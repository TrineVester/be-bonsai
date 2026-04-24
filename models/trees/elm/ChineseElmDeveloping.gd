class_name ChineseElmDeveloping
extends RefCounted

# Stage 2 (12–36 months): near-horizontal branches, wide flat umbrella canopy (winter-aware)
# foliage2 is the lighter highlight colour
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h  := lerpf(1.02, 1.58, t)
	var br := lerpf(0.052, 0.082, t)

	# Slight S-curve lean — grows with age, common in Chinese Elm bonsai
	mesh._visual.add_child(mesh._create_trunk(h * 0.52, br, br * 0.68, bark))
	var upper := mesh._create_trunk(h * 0.52, br * 0.68, 0.030, bark)
	upper.position.y = h * 0.52 + (h * 0.52) * 0.5
	upper.rotation_degrees.z = lerpf(0.0, 2.2, t)
	upper.position.x = lerpf(0.0, 0.03, t)
	mesh._visual.add_child(upper)

	if t > 0.35:
		mesh._visual.add_child(mesh._create_nebari(br * 1.90, bark.darkened(0.12)))

	# Elm branches very nearly horizontal — high tilt, wide reach
	var blen  := lerpf(0.40, 0.68, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(76.0, 86.0, t) * (1.0 - compact * 0.18)
	var bsr   := lerpf(0.018, 0.025, t)
	# Lerp branch heights toward Mature values so there is no jump at stage transition
	var mid_y := h * lerpf(0.58, 0.54, t)
	var up_y  := h * lerpf(0.70, 0.64, t)
	mesh._add_branch("b_low_r", 12.0, Vector3(0.0, h * 0.42, 0.0),  90.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_low_l", 12.0, Vector3(0.0, h * 0.42, 0.0), 270.0, btilt,        blen * 0.95, bsr,        bark)
	mesh._add_branch("b_mid_f", 18.0, Vector3(0.0, mid_y,    0.0),   0.0, btilt,        blen * 0.80, bsr * 0.80, bark)
	mesh._add_branch("b_mid_b", 18.0, Vector3(0.0, mid_y,    0.0), 180.0, btilt,        blen * 0.76, bsr * 0.80, bark)
	mesh._add_branch("b_up_45", 26.0, Vector3(0.0, up_y,     0.0),  45.0, btilt * 0.88, blen * 0.62, bsr * 0.65, bark)

	# Winter: bare branch structure only
	if mesh.is_winter():
		return

	# Very flat umbrella pads at branch tips — inset so pad wraps tip, skip pruned branches
	var pad := lerpf(0.30, 0.44, t) * (1.0 - compact * 0.48)
	if age >= 12.0 and not mesh._data.is_branch_pruned("b_low_r"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.42, 0.0),  90.0, btilt,        mesh._eff_len(12.0, blen)        - pad * 0.5),  pad,        0.30, foliage,  2.4))
	if age >= 12.0 and not mesh._data.is_branch_pruned("b_low_l"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.42, 0.0), 270.0, btilt,        mesh._eff_len(12.0, blen * 0.95) - pad * 0.48), pad * 0.95, 0.30, foliage2, 2.4))
	if age >= 18.0 and not mesh._data.is_branch_pruned("b_mid_f"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, mid_y,    0.0),   0.0, btilt,        mesh._eff_len(18.0, blen * 0.80) - pad * 0.40), pad * 0.80, 0.30, foliage2, 2.2))
	if age >= 18.0 and not mesh._data.is_branch_pruned("b_mid_b"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, mid_y,    0.0), 180.0, btilt,        mesh._eff_len(18.0, blen * 0.76) - pad * 0.38), pad * 0.76, 0.30, foliage,  2.2))
	if age >= 26.0 and not mesh._data.is_branch_pruned("b_up_45"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, up_y,     0.0),  45.0, btilt * 0.88, mesh._eff_len(26.0, blen * 0.62) - pad * 0.31), pad * 0.62, 0.32, foliage2, 2.0))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 1.04, 0.0), pad * 0.55, 0.32, foliage, 2.0))
