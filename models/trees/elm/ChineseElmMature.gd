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
	inner_trunk.position.y = 0.01
	mesh._visual.add_child(inner_trunk)
	# Upper trunk — S-curve lean
	var upper := mesh._create_trunk(h * 0.54, br * 0.70, 0.028, bark)
	upper.position.y = h * 0.50 - (h * 0.54) * 0.5
	upper.rotation_degrees.z = 3.5
	upper.position.x = 0.05
	mesh._visual.add_child(upper)
	mesh._visual.add_child(mesh._create_nebari(br * 2.50, bark.darkened(0.16)))

	# 8 near-horizontal branches — classic elm wide umbrella
	var blen  := lerpf(0.68, 0.85, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(83.0, 88.0, t) * (1.0 - compact * 0.16)
	var bsr   := 0.026
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.34, 0.0),  90.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.34, 0.0), 270.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.48, 0.0),   0.0, btilt,        blen * 0.86, bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.48, 0.0), 180.0, btilt,        blen * 0.86, bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.60, 0.0),  45.0, btilt * 0.88, blen * 0.70, bsr * 0.78, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.60, 0.0), 225.0, btilt * 0.88, blen * 0.68, bsr * 0.78, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.70, 0.0), 135.0, btilt * 0.75, blen * 0.55, bsr * 0.62, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.70, 0.0), 315.0, btilt * 0.75, blen * 0.52, bsr * 0.62, bark))

	# Winter: show the beautiful bare branch structure only
	if mesh.is_winter():
		return

	# 7 extremely flat pads — flatten 0.28, very wide spread, high sway amplitude
	var pad := lerpf(0.42, 0.50, t) * (1.0 - compact * 0.52)
	var sp  := pad * 1.15
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  0.0,       h * 0.74,  0.0),        pad * 0.80, 0.28, foliage,  2.5))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( -sp,        h * 0.62,  0.0),        pad,        0.27, foliage2, 2.8))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  sp,        h * 0.62,  0.0),        pad,        0.27, foliage,  2.8))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  0.0,       h * 0.62,  sp * 0.88),  pad * 0.86, 0.29, foliage2, 2.6))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(  0.0,       h * 0.62, -sp * 0.88),  pad * 0.86, 0.29, foliage,  2.6))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(-sp * 0.72,  h * 0.59,  sp * 0.58),  pad * 0.68, 0.30, foliage2, 3.0))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3( sp * 0.72,  h * 0.59, -sp * 0.58),  pad * 0.68, 0.30, foliage,  3.0))
