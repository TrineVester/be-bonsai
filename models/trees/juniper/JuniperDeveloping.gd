class_name JuniperDeveloping
extends RefCounted

# Stage 2 (12–36 months): visible primary branches, 3 clearly separated flat tiers
# foliage2 is the lighter highlight colour passed from JuniperMesh
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t   := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h   := lerpf(1.05, 1.65, t)
	var br  := lerpf(0.058, 0.085, t)

	# S-curve trunk: lower segment straight, upper segment leaning slightly
	mesh._visual.add_child(mesh._create_trunk(h * 0.55, br, br * 0.72, bark))
	var upper := mesh._create_trunk(h * 0.50, br * 0.72, 0.030, bark)
	upper.position.y = h * 0.55 - (h * 0.50) * 0.5
	upper.rotation_degrees.z = 1.8
	mesh._visual.add_child(upper)

	if t > 0.35:
		mesh._visual.add_child(mesh._create_nebari(br * 2.0, bark.darkened(0.14)))

	var blen  := lerpf(0.28, 0.54, t) * (1.0 - compact * 0.28)
	# Juniper branches tilt steeply — droop from weight then pads face upward
	var btilt := lerpf(72.0, 82.0, t) * (1.0 - compact * 0.18)
	var bsr   := lerpf(0.016, 0.024, t)
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.32, 0.0),  90.0, btilt, blen,        bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.32, 0.0), 270.0, btilt, blen * 0.90, bsr,        bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.50, 0.0),   0.0, btilt, blen * 0.78, bsr * 0.80, bark))
	mesh._visual.add_child(mesh._create_branch(Vector3(0.0, h * 0.50, 0.0), 180.0, btilt, blen * 0.72, bsr * 0.80, bark))

	# Three flat horizontal tiers — clearly separated with visible gaps
	var pad := lerpf(0.28, 0.42, t) * (1.0 - compact * 0.40)
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.40, 0.0), pad,        0.38, foliage,  0.7))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.58, 0.0), pad * 0.75, 0.38, foliage2, 0.75))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.78, 0.0), pad * 0.50, 0.40, foliage,  0.65))
