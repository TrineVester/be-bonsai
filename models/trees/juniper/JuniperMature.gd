class_name JuniperMature
extends RefCounted

# Stage 3 (36+ months): full bonsai — two-segment trunk, root flare, 4 branch layers, 4 foliage pads
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.65, 2.0, t)
	var br := lerpf(0.085, 0.105, t)

	# Two trunk segments for subtle movement
	mesh._visual.add_child(mesh._create_trunk(h * 0.55, br, br * 0.62, bark))
	var upper := mesh._create_trunk(h * 0.50, br * 0.62, 0.026, bark)
	upper.position.y += h * 0.55 - (h * 0.50) * 0.5
	upper.rotation_degrees.z = 2.5
	mesh._visual.add_child(upper)
	mesh._visual.add_child(mesh._create_nebari(br * 2.3, bark.darkened(0.15)))

	var blen  := lerpf(0.55, 0.68, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(74.0, 82.0, t) * (1.0 - compact * 0.18)
	var bsr   := 0.028
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.30, 0.0),  90.0, btilt,        blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.30, 0.0), 270.0, btilt,        blen * 0.88, bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.47, 0.0),   0.0, btilt,        blen * 0.76, bsr * 0.80, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.47, 0.0), 180.0, btilt,        blen * 0.70, bsr * 0.80, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.62, 0.0),  45.0, btilt * 0.88, blen * 0.58, bsr * 0.65, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.62, 0.0), 225.0, btilt * 0.88, blen * 0.52, bsr * 0.65, bark))

	var pad := lerpf(0.40, 0.46, t) * (1.0 - compact * 0.45)
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.38, 0.0), pad,        0.54, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.55, 0.0), pad * 0.76, 0.56, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.70, 0.0), pad * 0.57, 0.60, foliage))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.84, 0.0), pad * 0.38, 0.65, foliage))
