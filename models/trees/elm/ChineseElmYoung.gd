class_name ChineseElmYoung
extends RefCounted

# Stage 1 (3–12 months): thickening trunk, small spreading pads forming
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, age: float, compact: float) -> void:
	var t := clampf((age - 3.0) / 9.0, 0.0, 1.0)
	var h := lerpf(0.60, 1.02, t)
	mesh._visual.add_child(mesh._create_trunk(h, lerpf(0.025, 0.052, t), lerpf(0.010, 0.022, t), bark))
	var r := lerpf(0.14, 0.26, t) * (1.0 - compact * 0.28)
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.86, 0.0), r, 0.80, foliage))
	if t > 0.45:
		mesh._visual.add_child(mesh._create_foliage_pad(Vector3(-0.16 * t, h * 0.75,  0.08), r * 0.64, 0.80, foliage))
		mesh._visual.add_child(mesh._create_foliage_pad(Vector3( 0.16 * t, h * 0.75, -0.08), r * 0.64, 0.80, foliage))
