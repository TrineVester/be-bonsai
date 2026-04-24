class_name JuniperDeveloping
extends RefCounted

# Stage 2 (12-36 months): primary branches emerge, flat spray tiers build up
# foliage2 is the lighter highlight colour passed from JuniperMesh
# At t=0: h=1.05, matches JuniperYoung exit. At t=1: h=1.65, matches JuniperMature entry.
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t   := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h   := lerpf(1.05, 1.65, t)
	var br  := lerpf(0.058, 0.085, t)

	# S-curve trunk: lean grows gradually from nothing
	mesh._visual.add_child(mesh._create_trunk(h * 0.55, br, br * 0.72, bark))
	var upper := mesh._create_trunk(h * 0.50, br * 0.72, 0.030, bark)
	upper.position.y = h * 0.55 + (h * 0.50) * 0.5
	upper.rotation_degrees.z = lerpf(0.0, 1.8, t)
	upper.position.x = lerpf(0.0, 0.025, t)
	mesh._visual.add_child(upper)

	if t > 0.35:
		mesh._visual.add_child(mesh._create_nebari(br * 2.0, bark.darkened(0.14)))

	# Upper branches appear FIRST (high on tree), lower branches fill in last
	# Natural top-down development: avoids naked-stem look at stage entry
	var blen  := lerpf(0.22, 0.54, t) * (1.0 - compact * 0.28)
	var btilt := lerpf(72.0, 82.0, t) * (1.0 - compact * 0.18)
	var bsr   := lerpf(0.016, 0.024, t)
	mesh._add_branch("b_up_45",  12.0, Vector3(0.0, h * 0.65, 0.0),  45.0, btilt * 0.88, blen * 0.65, bsr * 0.75, bark)
	mesh._add_branch("b_up_225", 14.0, Vector3(0.0, h * 0.65, 0.0), 225.0, btilt * 0.88, blen * 0.60, bsr * 0.75, bark)
	mesh._add_branch("b_mid_f",  18.0, Vector3(0.0, h * 0.52, 0.0),   0.0, btilt,        blen * 0.78, bsr * 0.80, bark)
	mesh._add_branch("b_mid_b",  18.0, Vector3(0.0, h * 0.52, 0.0), 180.0, btilt,        blen * 0.72, bsr * 0.80, bark)
	mesh._add_branch("b_low_r",  26.0, Vector3(0.0, h * 0.38, 0.0),  90.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_low_l",  26.0, Vector3(0.0, h * 0.38, 0.0), 270.0, btilt,        blen * 0.90, bsr,        bark)

	# Foliage only once branch long enough to clear the inset
	var pad    := lerpf(0.20, 0.42, t) * (1.0 - compact * 0.40)
	var eff_u4 := mesh._eff_len(12.0, blen * 0.65)
	var eff_u2 := mesh._eff_len(14.0, blen * 0.60)
	var eff_mf := mesh._eff_len(18.0, blen * 0.78)
	var eff_mb := mesh._eff_len(18.0, blen * 0.72)
	var eff_lr := mesh._eff_len(26.0, blen)
	var eff_ll := mesh._eff_len(26.0, blen * 0.90)
	if eff_u4 > pad * 0.32 and not mesh._data.is_branch_pruned("b_up_45"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.65, 0.0),  45.0, btilt * 0.88, eff_u4 - pad * 0.32), pad * 0.65, 0.38, foliage,  0.7))
	if eff_u2 > pad * 0.30 and not mesh._data.is_branch_pruned("b_up_225"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.65, 0.0), 225.0, btilt * 0.88, eff_u2 - pad * 0.30), pad * 0.60, 0.38, foliage2, 0.75))
	if eff_mf > pad * 0.38 and not mesh._data.is_branch_pruned("b_mid_f"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.52, 0.0),   0.0, btilt,        eff_mf - pad * 0.38), pad * 0.75, 0.38, foliage2, 0.75))
	if eff_mb > pad * 0.36 and not mesh._data.is_branch_pruned("b_mid_b"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.52, 0.0), 180.0, btilt,        eff_mb - pad * 0.36), pad * 0.72, 0.38, foliage,  0.65))
	if eff_lr > pad * 0.5  and not mesh._data.is_branch_pruned("b_low_r"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.38, 0.0),  90.0, btilt,        eff_lr - pad * 0.5),  pad,        0.38, foliage,  0.7))
	if eff_ll > pad * 0.45 and not mesh._data.is_branch_pruned("b_low_l"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.38, 0.0), 270.0, btilt,        eff_ll - pad * 0.45), pad * 0.90, 0.38, foliage2, 0.75))
	# Apex pad at trunk top - grows continuously, never shrinks
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 1.05, 0.0), lerpf(0.24, 0.32, t), 0.40, foliage, 0.65))
