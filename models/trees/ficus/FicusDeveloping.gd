class_name FicusDeveloping
extends RefCounted

# Stage 2 (12-36 months): 3 radiating branches, bubble clusters, first aerial root
# foliage2 = lighter highlight; root_color = aerial root colour
# At t=0: h=0.98, matches FicusYoung exit. At t=1: h=1.55, matches FicusMature entry.
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, root_color: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h  := lerpf(0.98, 1.55, t)
	var br := lerpf(0.054, 0.085, t)
	mesh._visual.add_child(mesh._create_trunk(h, br, 0.034, bark))
	if t > 0.35:
		mesh._visual.add_child(mesh._create_nebari(br * 1.90, bark.darkened(0.08)))

	# Upper (sec) branches appear FIRST — near apex, no naked stem at stage entry
	# Lower (pri) branches appear later, after upper canopy established
	var blen  := lerpf(0.20, 0.58, t) * (1.0 - compact * 0.25)
	var btilt := lerpf(60.0, 74.0, t) * (1.0 - compact * 0.20)
	var bsr   := lerpf(0.018, 0.026, t)
	mesh._add_branch("b_sec_60",  12.0, Vector3(0.0, h * 0.60, 0.0),  60.0, btilt * 0.85, blen * 0.65, bsr * 0.72, bark)
	mesh._add_branch("b_sec_180", 14.0, Vector3(0.0, h * 0.60, 0.0), 180.0, btilt * 0.85, blen * 0.60, bsr * 0.72, bark)
	mesh._add_branch("b_pri_0",   22.0, Vector3(0.0, h * 0.40, 0.0),   0.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_pri_120", 22.0, Vector3(0.0, h * 0.40, 0.0), 120.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_pri_240", 23.0, Vector3(0.0, h * 0.40, 0.0), 240.0, btilt,        blen * 0.90, bsr,        bark)

	# Bubble clusters only once branch has grown past inset
	var pad    := lerpf(0.18, 0.40, t) * (1.0 - compact * 0.42)
	var eff_s1 := mesh._eff_len(12.0, blen * 0.65)
	var eff_s2 := mesh._eff_len(14.0, blen * 0.60)
	var eff_p0 := mesh._eff_len(22.0, blen)
	var eff_p2 := mesh._eff_len(23.0, blen * 0.90)
	if eff_s1 > pad * 0.31 and not mesh._data.is_branch_pruned("b_sec_60"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.60, 0.0),  60.0, btilt * 0.85, eff_s1 - pad * 0.31), pad * 0.62, 0.72, foliage2, foliage,  1.2): mesh._visual.add_child(node)
	if eff_s2 > pad * 0.30 and not mesh._data.is_branch_pruned("b_sec_180"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.60, 0.0), 180.0, btilt * 0.85, eff_s2 - pad * 0.30), pad * 0.60, 0.72, foliage,  foliage2, 1.2): mesh._visual.add_child(node)
	if eff_p0 > pad * 0.39 and not mesh._data.is_branch_pruned("b_pri_0"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.40, 0.0),   0.0, btilt,        eff_p0 - pad * 0.39), pad * 0.78, 0.72, foliage,  foliage2, 1.3): mesh._visual.add_child(node)
	if eff_p0 > pad * 0.39 and not mesh._data.is_branch_pruned("b_pri_120"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.40, 0.0), 120.0, btilt,        eff_p0 - pad * 0.39), pad * 0.78, 0.72, foliage2, foliage,  1.2): mesh._visual.add_child(node)
	if eff_p2 > pad * 0.38 and not mesh._data.is_branch_pruned("b_pri_240"):
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.40, 0.0), 240.0, btilt,        eff_p2 - pad * 0.38), pad * 0.75, 0.72, foliage,  foliage2, 1.2): mesh._visual.add_child(node)
	# Apex cluster at trunk top - grows continuously, never shrinks
	for node in mesh._create_foliage_cluster(Vector3(0.0, h, 0.0), lerpf(0.26, 0.34, t), 0.72, foliage, foliage2, 1.3): mesh._visual.add_child(node)

	# First aerial root appearing mid-stage
	if t > 0.55:
		var root_x := blen * 0.30
		mesh._visual.add_child(mesh._create_aerial_root(Vector3(-root_x, h * 0.62, 0.04), h * 0.56, root_color))
