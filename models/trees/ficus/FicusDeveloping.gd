class_name FicusDeveloping
extends RefCounted

# Stage 2 (12–36 months): 3 radiating branches, bubble clusters, first aerial root
# foliage2 = lighter highlight; root_color = aerial root colour
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, root_color: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h  := lerpf(0.98, 1.55, t)
	var br := lerpf(0.054, 0.085, t)
	mesh._visual.add_child(mesh._create_trunk(h, br, 0.034, bark))
	if t > 0.35:
		mesh._visual.add_child(mesh._create_nebari(br * 1.90, bark.darkened(0.08)))

	# Three radiating primary branches — ficus spreads wide at 120°
	var blen  := lerpf(0.32, 0.58, t) * (1.0 - compact * 0.25)
	var btilt := lerpf(60.0, 74.0, t) * (1.0 - compact * 0.20)
	var bsr   := lerpf(0.018, 0.026, t)
	mesh._add_branch("b_pri_0",   12.0, Vector3(0.0, h * 0.48, 0.0),   0.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_pri_120", 12.0, Vector3(0.0, h * 0.48, 0.0), 120.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_pri_240", 13.0, Vector3(0.0, h * 0.48, 0.0), 240.0, btilt,        blen * 0.90, bsr,        bark)
	mesh._add_branch("b_sec_60",  20.0, Vector3(0.0, h * 0.66, 0.0),  60.0, btilt * 0.82, blen * 0.65, bsr * 0.72, bark)
	mesh._add_branch("b_sec_180", 21.0, Vector3(0.0, h * 0.66, 0.0), 180.0, btilt * 0.82, blen * 0.60, bsr * 0.72, bark)

	# Bubble clusters at branch tips — born with their branch, plus apex dome
	var pad := lerpf(0.28, 0.40, t) * (1.0 - compact * 0.42)
	if age >= 12.0:
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.48, 0.0),   0.0, btilt,        blen),        pad * 0.78, 0.72, foliage,  foliage2, 1.3): mesh._visual.add_child(node)
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.48, 0.0), 120.0, btilt,        blen),        pad * 0.78, 0.72, foliage2, foliage,  1.2): mesh._visual.add_child(node)
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.48, 0.0), 240.0, btilt,        blen * 0.90), pad * 0.75, 0.72, foliage,  foliage2, 1.2): mesh._visual.add_child(node)
	if age >= 20.0:
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.66, 0.0),  60.0, btilt * 0.82, blen * 0.65), pad * 0.62, 0.72, foliage2, foliage,  1.2): mesh._visual.add_child(node)
	if age >= 21.0:
		for node in mesh._create_foliage_cluster(mesh._branch_tip(Vector3(0.0, h * 0.66, 0.0), 180.0, btilt * 0.82, blen * 0.60), pad * 0.60, 0.72, foliage,  foliage2, 1.2): mesh._visual.add_child(node)
	for node in mesh._create_foliage_cluster(Vector3(0.0, h * 0.88, 0.0), pad * 0.65, 0.72, foliage, foliage2, 1.3): mesh._visual.add_child(node)

	# First aerial root appearing at developing stage
	if t > 0.55:
		var root_x := blen * 0.30
		mesh._visual.add_child(mesh._create_aerial_root(Vector3(-root_x, h * 0.62, 0.04), h * 0.56, root_color))
