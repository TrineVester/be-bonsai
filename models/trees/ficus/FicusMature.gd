class_name FicusMature
extends RefCounted

# Stage 3 (36+ months): full dome — 6 branches, 3 large bubble clusters, 2 aerial roots
# foliage2 = lighter highlight; root_color = aerial root colour
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, root_color: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.55, 1.82, t)
	var br := lerpf(0.085, 0.112, t)

	# Trunk — smooth silver-grey, wide at base
	mesh._visual.add_child(mesh._create_trunk(h, br, 0.032, bark))
	mesh._visual.add_child(mesh._create_nebari(br * 2.4, bark.darkened(0.10)))

	var blen  := lerpf(0.58, 0.75, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(76.0, 84.0, t) * (1.0 - compact * 0.18)
	var bsr   := 0.028
	mesh._add_branch("b_pri_0",   12.0, Vector3(0.0, h * 0.40, 0.0),   0.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_pri_120", 12.0, Vector3(0.0, h * 0.40, 0.0), 120.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_pri_240", 13.0, Vector3(0.0, h * 0.40, 0.0), 240.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_sec_60",  20.0, Vector3(0.0, h * 0.60, 0.0),  60.0, btilt * 0.78, blen * 0.68, bsr * 0.72, bark)
	mesh._add_branch("b_sec_180", 21.0, Vector3(0.0, h * 0.60, 0.0), 180.0, btilt * 0.78, blen * 0.68, bsr * 0.72, bark)
	mesh._add_branch("b_ter_300", 36.0, Vector3(0.0, h * 0.60, 0.0), 300.0, btilt * 0.78, blen * 0.62, bsr * 0.72, bark)

	# Bubble clusters at branch tips — only once branch has grown past the inset point
	var pad := lerpf(0.44, 0.52, t) * (1.0 - compact * 0.45)
	var eff_p0 := mesh._eff_len(12.0, blen)
	var eff_s1 := mesh._eff_len(20.0, blen * 0.68)
	var eff_s2 := mesh._eff_len(21.0, blen * 0.68)
	var eff_t3 := mesh._eff_len(36.0, blen * 0.62)
	if eff_p0 > pad * 0.41 and not mesh._data.is_branch_pruned("b_pri_0"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.40, 0.0),   0.0, btilt,        eff_p0 - pad * 0.41), pad * 0.82, 0.72, foliage,  foliage2, 1.3): mesh._visual.add_child(node)
	if eff_p0 > pad * 0.41 and not mesh._data.is_branch_pruned("b_pri_120"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.40, 0.0), 120.0, btilt,        eff_p0 - pad * 0.41), pad * 0.82, 0.72, foliage2, foliage,  1.3): mesh._visual.add_child(node)
	if eff_p0 > pad * 0.41 and not mesh._data.is_branch_pruned("b_pri_240"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.40, 0.0), 240.0, btilt,        eff_p0 - pad * 0.41), pad * 0.82, 0.70, foliage,  foliage2, 1.3): mesh._visual.add_child(node)
	if eff_s1 > pad * 0.34 and not mesh._data.is_branch_pruned("b_sec_60"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.60, 0.0),  60.0, btilt * 0.78, eff_s1 - pad * 0.34), pad * 0.68, 0.72, foliage2, foliage,  1.2): mesh._visual.add_child(node)
	if eff_s2 > pad * 0.34 and not mesh._data.is_branch_pruned("b_sec_180"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.60, 0.0), 180.0, btilt * 0.78, eff_s2 - pad * 0.34), pad * 0.68, 0.70, foliage,  foliage2, 1.2): mesh._visual.add_child(node)
	if eff_t3 > pad * 0.31 and not mesh._data.is_branch_pruned("b_ter_300"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.60, 0.0), 300.0, btilt * 0.78, eff_t3 - pad * 0.31), pad * 0.62, 0.72, foliage2, foliage,  1.2): mesh._visual.add_child(node)
	# Apex starts matching Developing exit (0.34) and grows with the canopy
	for node in mesh._create_foliage_cluster(Vector3(0.0, h * 1.00, 0.0), lerpf(0.34, pad * 0.95, t), 0.72, foliage, foliage2, 1.4): mesh._visual.add_child(node)

	# Two aerial roots — Ficus retusa signature
	var root_x := blen * 0.38
	mesh._visual.add_child(mesh._create_aerial_root(Vector3(-root_x, h * 0.60,  0.05), h * 0.54, root_color))
	mesh._visual.add_child(mesh._create_aerial_root(Vector3( root_x * 0.72, h * 0.58, -0.04), h * 0.50, root_color))
