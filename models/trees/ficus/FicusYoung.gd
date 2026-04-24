class_name FicusYoung
extends RefCounted

# Stage 1 (3–12 months): thickening trunk, single dome with hints of side pads
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, age: float, compact: float) -> void:
	var t := clampf((age - 3.0) / 9.0, 0.0, 1.0)
	var h := lerpf(0.55, 0.98, t)
	mesh._visual.add_child(mesh._create_trunk(h, lerpf(0.025, 0.054, t), lerpf(0.012, 0.026, t), bark))
	var r := lerpf(0.15, 0.28, t) * (1.0 - compact * 0.30)
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.88, 0.0), r, 0.85, foliage))
	if t > 0.4:
		mesh._visual.add_child(mesh._create_foliage_pad(Vector3(-0.18 * t, h * 0.76,  0.06), r * 0.62, 0.85, foliage))
		mesh._visual.add_child(mesh._create_foliage_pad(Vector3( 0.18 * t, h * 0.76, -0.06), r * 0.62, 0.85, foliage))
