class_name JuniperMature
extends RefCounted

# Stage 3 (36+ months): full bonsai — S-curve trunk, dramatic nebari, 4 flat tiers, jin deadwood
# foliage2 is the lighter highlight colour passed from JuniperMesh
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.65, 2.0, t)
	var br := lerpf(0.085, 0.108, t)

	# Lower trunk — thick, strong
	mesh._visual.add_child(mesh._create_trunk(h * 0.52, br, br * 0.65, bark))
	# Upper trunk — leans slightly (classic juniper S-curve)
	var upper := mesh._create_trunk(h * 0.52, br * 0.65, 0.026, bark)
	upper.position.y = h * 0.52 + (h * 0.52) * 0.5
	upper.rotation_degrees.z = 3.2
	upper.position.x = 0.04
	mesh._visual.add_child(upper)
	mesh._visual.add_child(mesh._create_nebari(br * 2.6, bark.darkened(0.16)))

	# Jin deadwood stubs — bleached grey, lower trunk, defining Juniper character
	mesh._visual.add_child(mesh._create_jin(Vector3(0.0, h * 0.18, 0.0), 160.0, 75.0, 0.18))
	mesh._visual.add_child(mesh._create_jin(Vector3(0.0, h * 0.25, 0.0),  35.0, 70.0, 0.12))

	var blen  := lerpf(0.55, 0.70, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(76.0, 84.0, t) * (1.0 - compact * 0.18)
	var bsr   := 0.028
	mesh._add_branch("b_low_r",  12.0, Vector3(0.0, h * 0.38, 0.0),  90.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_low_l",  12.0, Vector3(0.0, h * 0.38, 0.0), 270.0, btilt,        blen * 0.88, bsr,        bark)
	mesh._add_branch("b_mid_f",  18.0, Vector3(0.0, h * 0.52, 0.0),   0.0, btilt,        blen * 0.76, bsr * 0.80, bark)
	mesh._add_branch("b_mid_b",  18.0, Vector3(0.0, h * 0.52, 0.0), 180.0, btilt,        blen * 0.70, bsr * 0.80, bark)
	mesh._add_branch("b_up_45",  30.0, Vector3(0.0, h * 0.65, 0.0),  45.0, btilt * 0.88, blen * 0.58, bsr * 0.65, bark)
	mesh._add_branch("b_up_225", 30.0, Vector3(0.0, h * 0.65, 0.0), 225.0, btilt * 0.88, blen * 0.52, bsr * 0.65, bark)

	# Foliage pads at branch tips — only once branch has grown past the inset point
	var pad := lerpf(0.40, 0.48, t) * (1.0 - compact * 0.45)
	var eff_lr := mesh._eff_len(12.0, blen)
	var eff_ll := mesh._eff_len(12.0, blen * 0.88)
	var eff_mf := mesh._eff_len(18.0, blen * 0.76)
	var eff_mb := mesh._eff_len(18.0, blen * 0.70)
	var eff_u4 := mesh._eff_len(30.0, blen * 0.58)
	var eff_u2 := mesh._eff_len(30.0, blen * 0.52)
	if eff_lr > pad * 0.5  and not mesh._data.is_branch_pruned("b_low_r"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.38, 0.0),  90.0, btilt,        eff_lr - pad * 0.5),  pad,        0.36, foliage,  0.6))
	if eff_ll > pad * 0.44 and not mesh._data.is_branch_pruned("b_low_l"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.38, 0.0), 270.0, btilt,        eff_ll - pad * 0.44), pad * 0.88, 0.36, foliage2, 0.65))
	if eff_mf > pad * 0.38 and not mesh._data.is_branch_pruned("b_mid_f"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.52, 0.0),   0.0, btilt,        eff_mf - pad * 0.38), pad * 0.76, 0.36, foliage2, 0.65))
	if eff_mb > pad * 0.35 and not mesh._data.is_branch_pruned("b_mid_b"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.52, 0.0), 180.0, btilt,        eff_mb - pad * 0.35), pad * 0.70, 0.36, foliage,  0.6))
	if eff_u4 > pad * 0.28 and not mesh._data.is_branch_pruned("b_up_45"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.65, 0.0),  45.0, btilt * 0.88, eff_u4 - pad * 0.28), pad * 0.56, 0.38, foliage,  0.7))
	if eff_u2 > pad * 0.26 and not mesh._data.is_branch_pruned("b_up_225"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.65, 0.0), 225.0, btilt * 0.88, eff_u2 - pad * 0.26), pad * 0.52, 0.38, foliage2, 0.6))
	# Apex starts matching Developing exit (0.32) and shrinks gently as canopy fills out
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 1.04, 0.0), lerpf(0.32, 0.22, t), 0.40, foliage2, 0.6))
