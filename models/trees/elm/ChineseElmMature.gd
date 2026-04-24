class_name ChineseElmMature
extends RefCounted

# Stage 3 (36+ months): wide umbrella — two-tone flaky bark, 8 branches, 7 flat pads, winter-bare
# bark2 = orange inner bark for mottled patch effect; foliage2 = highlight
static func build(mesh: TreeMeshBase, bark: Color, bark2: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.58, 1.85, t)
	var br := lerpf(0.082, 0.110, t)

	# Lower trunk — outer dark bark
	mesh._visual.add_child(mesh._create_trunk(h * 0.50, br, br * 0.70, bark))
	# Two-tone mottled bark: thinner inner-bark cylinder slightly smaller radius
	var inner_trunk := mesh._create_trunk(h * 0.48, br * 0.96, br * 0.67, bark2)
	# default position from _create_trunk (height/2) correctly overlays the lower trunk
	mesh._visual.add_child(inner_trunk)
	# Upper trunk — S-curve lean
	var upper := mesh._create_trunk(h * 0.54, br * 0.70, 0.028, bark)
	upper.position.y = h * 0.50 + (h * 0.54) * 0.5
	upper.rotation_degrees.z = 3.5
	upper.position.x = 0.05
	mesh._visual.add_child(upper)
	mesh._visual.add_child(mesh._create_nebari(br * 2.50, bark.darkened(0.16)))

	# 8 near-horizontal branches — classic elm wide umbrella
	var blen  := lerpf(0.68, 0.85, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(83.0, 88.0, t) * (1.0 - compact * 0.16)
	var bsr   := 0.026
	mesh._add_branch("b_low_r",  12.0, Vector3(0.0, h * 0.42, 0.0),  90.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_low_l",  12.0, Vector3(0.0, h * 0.42, 0.0), 270.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_mid_f",  18.0, Vector3(0.0, h * 0.54, 0.0),   0.0, btilt,        blen * 0.86, bsr,        bark)
	mesh._add_branch("b_mid_b",  18.0, Vector3(0.0, h * 0.54, 0.0), 180.0, btilt,        blen * 0.86, bsr,        bark)
	mesh._add_branch("b_up_45",  26.0, Vector3(0.0, h * 0.64, 0.0),  45.0, btilt * 0.88, blen * 0.70, bsr * 0.78, bark)
	mesh._add_branch("b_up_225", 36.0, Vector3(0.0, h * 0.64, 0.0), 225.0, btilt * 0.88, blen * 0.68, bsr * 0.78, bark)
	mesh._add_branch("b_up_135", 40.0, Vector3(0.0, h * 0.74, 0.0), 135.0, btilt * 0.75, blen * 0.55, bsr * 0.62, bark)
	mesh._add_branch("b_up_315", 44.0, Vector3(0.0, h * 0.74, 0.0), 315.0, btilt * 0.75, blen * 0.52, bsr * 0.62, bark)

	# Winter: show the beautiful bare branch structure only
	if mesh.is_winter():
		return

	# Flat pads at branch tips — only once branch has grown past the inset point
	var pad := lerpf(0.42, 0.50, t) * (1.0 - compact * 0.52)
	var eff_lr := mesh._eff_len(12.0, blen)
	var eff_mf := mesh._eff_len(18.0, blen * 0.86)
	var eff_u4 := mesh._eff_len(26.0, blen * 0.70)
	var eff_u2 := mesh._eff_len(36.0, blen * 0.68)
	var eff_13 := mesh._eff_len(40.0, blen * 0.55)
	var eff_31 := mesh._eff_len(44.0, blen * 0.52)
	if eff_lr > pad * 0.5  and not mesh._data.is_branch_pruned("b_low_r"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.42, 0.0),  90.0, btilt,        eff_lr - pad * 0.5),  pad,        0.27, foliage,  2.8))
	if eff_lr > pad * 0.5  and not mesh._data.is_branch_pruned("b_low_l"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.42, 0.0), 270.0, btilt,        eff_lr - pad * 0.5),  pad,        0.27, foliage2, 2.8))
	if eff_mf > pad * 0.43 and not mesh._data.is_branch_pruned("b_mid_f"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.54, 0.0),   0.0, btilt,        eff_mf - pad * 0.43), pad * 0.86, 0.28, foliage2, 2.6))
	if eff_mf > pad * 0.43 and not mesh._data.is_branch_pruned("b_mid_b"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.54, 0.0), 180.0, btilt,        eff_mf - pad * 0.43), pad * 0.86, 0.28, foliage,  2.6))
	if eff_u4 > pad * 0.35 and not mesh._data.is_branch_pruned("b_up_45"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.64, 0.0),  45.0, btilt * 0.88, eff_u4 - pad * 0.35), pad * 0.70, 0.29, foliage,  2.6))
	if eff_u2 > pad * 0.34 and not mesh._data.is_branch_pruned("b_up_225"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.64, 0.0), 225.0, btilt * 0.88, eff_u2 - pad * 0.34), pad * 0.68, 0.29, foliage2, 2.6))
	if eff_13 > pad * 0.34 and not mesh._data.is_branch_pruned("b_up_135"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.74, 0.0), 135.0, btilt * 0.75, eff_13 - pad * 0.34), pad * 0.68, 0.30, foliage2, 3.0))
	if eff_31 > pad * 0.34 and not mesh._data.is_branch_pruned("b_up_315"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.74, 0.0), 315.0, btilt * 0.75, eff_31 - pad * 0.34), pad * 0.68, 0.30, foliage,  3.0))
	# Apex starts matching Developing exit (0.32) and grows gently with the umbrella canopy
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 1.04, 0.0), lerpf(0.32, pad * 0.78, t), 0.28, foliage, 2.5))
