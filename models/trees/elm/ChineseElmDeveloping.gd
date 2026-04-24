class_name ChineseElmDeveloping
extends RefCounted

# Stage 2 (12-36 months): near-horizontal branches, wide flat umbrella canopy (winter-aware)
# foliage2 is the lighter highlight colour
# At t=0: h=1.02, matches ChineseElmYoung exit. At t=1: h=1.58, matches ChineseElmMature entry.
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h  := lerpf(1.02, 1.58, t)
	var br := lerpf(0.052, 0.082, t)

	# S-curve lean grows gradually from nothing
	mesh._visual.add_child(mesh._create_trunk(h * 0.52, br, br * 0.68, bark))
	var upper := mesh._create_trunk(h * 0.52, br * 0.68, 0.030, bark)
	upper.position.y = h * 0.52 + (h * 0.52) * 0.5
	upper.rotation_degrees.z = lerpf(0.0, 2.2, t)
	upper.position.x = lerpf(0.0, 0.03, t)
	mesh._visual.add_child(upper)

	if t > 0.35:
		mesh._visual.add_child(mesh._create_nebari(br * 1.90, bark.darkened(0.12)))

	# Upper branch appears FIRST (high on tree) — avoids naked-stem at stage entry
	# Natural top-down development: mid then low branches fill in afterward
	var blen  := lerpf(0.25, 0.68, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(76.0, 86.0, t) * (1.0 - compact * 0.18)
	var bsr   := lerpf(0.018, 0.025, t)
	mesh._add_branch("b_up_45",  12.0, Vector3(0.0, h * 0.64, 0.0),  45.0, btilt * 0.88, blen * 0.62, bsr * 0.65, bark)
	mesh._add_branch("b_mid_f",  18.0, Vector3(0.0, h * 0.54, 0.0),   0.0, btilt,        blen * 0.80, bsr * 0.80, bark)
	mesh._add_branch("b_mid_b",  18.0, Vector3(0.0, h * 0.54, 0.0), 180.0, btilt,        blen * 0.76, bsr * 0.80, bark)
	mesh._add_branch("b_low_r",  26.0, Vector3(0.0, h * 0.42, 0.0),  90.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_low_l",  26.0, Vector3(0.0, h * 0.42, 0.0), 270.0, btilt,        blen * 0.95, bsr,        bark)

	# Winter: bare branch structure only
	if mesh.is_winter():
		return

	# Foliage only once branch long enough to clear the inset
	var pad    := lerpf(0.18, 0.44, t) * (1.0 - compact * 0.48)
	var eff_u4 := mesh._eff_len(12.0, blen * 0.62)
	var eff_mf := mesh._eff_len(18.0, blen * 0.80)
	var eff_mb := mesh._eff_len(18.0, blen * 0.76)
	var eff_lr := mesh._eff_len(26.0, blen)
	var eff_ll := mesh._eff_len(26.0, blen * 0.95)
	if eff_u4 > pad * 0.31 and not mesh._data.is_branch_pruned("b_up_45"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.64, 0.0),  45.0, btilt * 0.88, eff_u4 - pad * 0.31), pad * 0.62, 0.32, foliage2, 2.0))
	if eff_mf > pad * 0.40 and not mesh._data.is_branch_pruned("b_mid_f"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.54, 0.0),   0.0, btilt,        eff_mf - pad * 0.40), pad * 0.80, 0.30, foliage2, 2.2))
	if eff_mb > pad * 0.38 and not mesh._data.is_branch_pruned("b_mid_b"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.54, 0.0), 180.0, btilt,        eff_mb - pad * 0.38), pad * 0.76, 0.30, foliage,  2.2))
	if eff_lr > pad * 0.5  and not mesh._data.is_branch_pruned("b_low_r"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.42, 0.0),  90.0, btilt,        eff_lr - pad * 0.5),  pad,        0.30, foliage,  2.4))
	if eff_ll > pad * 0.48 and not mesh._data.is_branch_pruned("b_low_l"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.42, 0.0), 270.0, btilt,        eff_ll - pad * 0.48), pad * 0.95, 0.30, foliage2, 2.4))
	# Apex pad at trunk top - grows continuously, never shrinks
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 1.04, 0.0), lerpf(0.26, 0.32, t), 0.32, foliage, 2.0))
