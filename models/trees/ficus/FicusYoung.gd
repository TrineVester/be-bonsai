class_name FicusYoung
extends RefCounted

# Stage 1 (3–12 months): thickening trunk, bubble dome with side sub-pads
# foliage2 is the lighter highlight colour
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t := clampf((age - 3.0) / 9.0, 0.0, 1.0)
	var h := lerpf(0.55, 0.98, t)
	mesh._visual.add_child(mesh._create_trunk(h, lerpf(0.025, 0.054, t), lerpf(0.012, 0.026, t), bark))
	var r := lerpf(0.15, 0.30, t) * (1.0 - compact * 0.30)
	# Top dome — round and full
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.88, 0.0), r, 0.82, foliage, 1.2))
	if t > 0.4:
		# Side sub-pads beginning to form the bubble cluster
		mesh._visual.add_child(mesh._create_foliage_pad(Vector3(-r * 0.65, h * 0.78, 0.06),  r * 0.60, 0.82, foliage2, 1.1))
		mesh._visual.add_child(mesh._create_foliage_pad(Vector3( r * 0.60, h * 0.78, -0.06), r * 0.60, 0.82, foliage,  1.1))
