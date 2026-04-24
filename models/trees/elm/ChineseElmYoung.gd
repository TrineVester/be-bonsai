class_name ChineseElmYoung
extends RefCounted

# Stage 1 (3–12 months): slender trunk, wide flat spreading pads (winter-aware)
# foliage2 is the lighter highlight colour
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t := clampf((age - 3.0) / 9.0, 0.0, 1.0)
	var h := lerpf(0.60, 1.02, t)
	mesh._visual.add_child(mesh._create_trunk(h, lerpf(0.025, 0.052, t), lerpf(0.010, 0.022, t), bark))

	# Skip foliage in winter — bare twig structure is the feature
	if mesh.is_winter():
		return

	var r := lerpf(0.09, 0.26, t) * (1.0 - compact * 0.28)
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h, 0.0), r, 0.35, foliage, 2.0))
	if t > 0.35:
		# Two side pads grow in smoothly - they become the low branches in Developing
		var side_t := clampf((t - 0.35) / 0.65, 0.0, 1.0)
		var side_r := r * 0.60 * side_t
		mesh._visual.add_child(mesh._create_foliage_pad(Vector3(-r * 0.75, h * 0.78,  0.06), side_r, 0.33, foliage2, 2.2))
		mesh._visual.add_child(mesh._create_foliage_pad(Vector3( r * 0.70, h * 0.78, -0.06), side_r, 0.33, foliage,  2.2))
