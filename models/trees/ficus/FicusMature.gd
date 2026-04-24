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
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.40, 0.0),   0.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.40, 0.0), 120.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.40, 0.0), 240.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.60, 0.0),  60.0, btilt * 0.78, blen * 0.68, bsr * 0.72, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.60, 0.0), 180.0, btilt * 0.78, blen * 0.68, bsr * 0.72, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.60, 0.0), 300.0, btilt * 0.78, blen * 0.62, bsr * 0.72, bark))

	# Three large bubble clusters forming the hemispherical dome
	var pad := lerpf(0.44, 0.52, t) * (1.0 - compact * 0.45)
	var sp  := pad * 0.70
	for node in mesh._create_foliage_cluster(Vector3(  0.0,      h * 0.78,  0.0),      pad,        0.72, foliage,  foliage2, 1.4):
		mesh._visual.add_child(node)
	for node in mesh._create_foliage_cluster(Vector3( -sp,       h * 0.66,  0.06),      pad * 0.82, 0.70, foliage2, foliage,  1.3):
		mesh._visual.add_child(node)
	for node in mesh._create_foliage_cluster(Vector3(  sp,       h * 0.66, -0.06),      pad * 0.82, 0.70, foliage,  foliage2, 1.3):
		mesh._visual.add_child(node)
	for node in mesh._create_foliage_cluster(Vector3(  sp * 0.5, h * 0.63,  sp * 0.85), pad * 0.68, 0.72, foliage2, foliage,  1.2):
		mesh._visual.add_child(node)
	for node in mesh._create_foliage_cluster(Vector3( -sp * 0.5, h * 0.63, -sp * 0.85), pad * 0.68, 0.72, foliage,  foliage2, 1.2):
		mesh._visual.add_child(node)

	# Two aerial roots — Ficus retusa signature
	mesh._visual.add_child(mesh._create_aerial_root(Vector3(-sp * 0.55, h * 0.60,  0.05), h * 0.54, root_color))
	mesh._visual.add_child(mesh._create_aerial_root(Vector3( sp * 0.40, h * 0.58, -0.04), h * 0.50, root_color))
