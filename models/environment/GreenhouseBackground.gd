class_name GreenhouseBackground
extends Node3D

func _ready() -> void:
	_build_floor()
	_build_outdoor_garden()
	_build_glass_walls()
	_build_frame_supports()
	_build_floor_plants()


func _build_floor() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(14.0, 0.1, 10.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.45, 0.36)
	mat.roughness = 0.9
	mesh.surface_set_material(0, mat)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0.0, -0.45, -1.5)
	add_child(mi)


# Garden seen through the glass — sits behind all three glass walls
func _build_outdoor_garden() -> void:
	# Grass ground outside
	var ground_mesh := BoxMesh.new()
	ground_mesh.size = Vector3(40.0, 0.1, 25.0)
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.22, 0.50, 0.16)
	ground_mat.roughness = 1.0
	ground_mesh.surface_set_material(0, ground_mat)
	var ground_mi := MeshInstance3D.new()
	ground_mi.mesh = ground_mesh
	ground_mi.position = Vector3(0.0, -0.46, -5.0)
	add_child(ground_mi)

	# Stone path down the center
	var path_mesh := BoxMesh.new()
	path_mesh.size = Vector3(1.8, 0.05, 12.0)
	var path_mat := StandardMaterial3D.new()
	path_mat.albedo_color = Color(0.58, 0.55, 0.50)
	path_mat.roughness = 0.95
	path_mesh.surface_set_material(0, path_mat)
	var path_mi := MeshInstance3D.new()
	path_mi.mesh = path_mesh
	path_mi.position = Vector3(0.0, -0.40, -7.0)
	add_child(path_mi)

	# Tall conifer trees at the back
	var conifer_positions := [
		Vector3(-8.0, 0.0, -9.0), Vector3(-5.0, 0.0, -10.0),
		Vector3(-2.0, 0.0,  -9.5), Vector3( 2.5, 0.0, -10.0),
		Vector3( 5.5, 0.0,  -9.0), Vector3( 8.5, 0.0, -9.5),
	]
	for pos in conifer_positions:
		add_child(_create_conifer(pos, randf_range(1.8, 2.8)))

	# Mid-layer varied bushes
	var back_bush_positions := [
		Vector3(-7.0, 0.0, -5.5), Vector3(-4.5, 0.0, -6.0),
		Vector3(-2.0, 0.0, -5.2), Vector3( 1.0, 0.0, -6.2),
		Vector3( 3.5, 0.0, -5.5), Vector3( 6.0, 0.0, -5.8),
		Vector3(-6.0, 0.0, -7.5), Vector3( 5.0, 0.0, -7.0),
	]
	for pos in back_bush_positions:
		add_child(_create_garden_bush(pos, randf_range(0.4, 0.85)))

	# Flowers dotted along the path and near bushes
	var flower_colors := [
		Color(0.95, 0.30, 0.30),  # red
		Color(0.95, 0.85, 0.20),  # yellow
		Color(0.70, 0.30, 0.90),  # purple
		Color(0.95, 0.60, 0.20),  # orange
		Color(1.00, 0.85, 0.90),  # pink
	]
	var flower_positions := [
		Vector3(-3.0, -0.2, -4.8), Vector3(-1.2, -0.2, -5.2),
		Vector3( 1.5, -0.2, -4.6), Vector3( 3.2, -0.2, -5.0),
		Vector3(-5.5, -0.2, -5.8), Vector3( 5.0, -0.2, -6.0),
		Vector3(-2.5, -0.2, -7.0), Vector3( 2.0, -0.2, -7.2),
	]
	for i in flower_positions.size():
		var color: Color = flower_colors[i % flower_colors.size()]
		add_child(_create_flower(flower_positions[i], color))

	# Side garden — visible through left and right glass walls
	var side_positions := [
		Vector3(-9.5, 0.0,  0.5), Vector3(-10.5, 0.0, -1.5),
		Vector3(-9.0, 0.0,  2.5), Vector3(-11.0, 0.0,  1.0),
		Vector3( 9.5, 0.0,  0.0), Vector3(10.5, 0.0, -1.0),
		Vector3( 9.0, 0.0,  2.0), Vector3(11.0, 0.0,  1.5),
	]
	for pos in side_positions:
		add_child(_create_garden_bush(pos, randf_range(0.3, 0.70)))


func _create_conifer(pos: Vector3, height: float) -> Node3D:
	var root := Node3D.new()
	root.position = pos
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.18, 0.10)
	var foliage_mat := StandardMaterial3D.new()
	foliage_mat.albedo_color = Color(0.12, 0.32, 0.14)

	# Trunk
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.height = height * 0.4
	trunk_mesh.top_radius = 0.05
	trunk_mesh.bottom_radius = 0.10
	trunk_mesh.radial_segments = 5
	trunk_mesh.surface_set_material(0, trunk_mat)
	var trunk_mi := MeshInstance3D.new()
	trunk_mi.mesh = trunk_mesh
	trunk_mi.position = Vector3(0.0, height * 0.2, 0.0)
	root.add_child(trunk_mi)

	# Three stacked conical tiers
	for tier in 3:
		var cone_mesh := CylinderMesh.new()
		cone_mesh.height = height * 0.4
		cone_mesh.top_radius = 0.0
		cone_mesh.bottom_radius = (0.55 - tier * 0.12) * height * 0.35
		cone_mesh.radial_segments = 6
		cone_mesh.surface_set_material(0, foliage_mat)
		var cone_mi := MeshInstance3D.new()
		cone_mi.mesh = cone_mesh
		cone_mi.position = Vector3(0.0, height * 0.38 + tier * height * 0.22, 0.0)
		root.add_child(cone_mi)

	return root


func _create_garden_bush(pos: Vector3, radius: float) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 1.3
	mesh.radial_segments = 6
	mesh.rings = 4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(
		randf_range(0.08, 0.20),
		randf_range(0.38, 0.55),
		randf_range(0.10, 0.22)
	)
	mesh.surface_set_material(0, mat)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	return mi


func _create_flower(pos: Vector3, color: Color) -> Node3D:
	var root := Node3D.new()
	root.position = pos

	# Stem
	var stem_mesh := CylinderMesh.new()
	stem_mesh.height = 0.22
	stem_mesh.top_radius = 0.012
	stem_mesh.bottom_radius = 0.012
	stem_mesh.radial_segments = 4
	var stem_mat := StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.20, 0.50, 0.15)
	stem_mesh.surface_set_material(0, stem_mat)
	var stem_mi := MeshInstance3D.new()
	stem_mi.mesh = stem_mesh
	stem_mi.position = Vector3(0.0, 0.11, 0.0)
	root.add_child(stem_mi)

	# Flower head
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.075
	head_mesh.height = 0.10
	head_mesh.radial_segments = 5
	head_mesh.rings = 3
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = color
	head_mesh.surface_set_material(0, head_mat)
	var head_mi := MeshInstance3D.new()
	head_mi.mesh = head_mesh
	head_mi.position = Vector3(0.0, 0.26, 0.0)
	root.add_child(head_mi)

	return root


# All three walls are now frosted glass — back, left, right
func _build_glass_walls() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.78, 0.93, 0.80, 0.30)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.55        # higher roughness = frosted/blurry look
	mat.metallic = 0.05
	mat.refraction_enabled = true
	mat.refraction_scale = 0.04  # slight distortion through the glass
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # render both faces so glass is visible from inside

	# Back wall — z=-4.5
	var back_mesh := BoxMesh.new()
	back_mesh.size = Vector3(13.74, 6.0, 0.12)
	back_mesh.surface_set_material(0, mat)
	var back_mi := MeshInstance3D.new()
	back_mi.mesh = back_mesh
	back_mi.position = Vector3(0.0, 2.5, -4.5)
	add_child(back_mi)

	# Side walls — from z=-4.5 to z=5.5, depth=10.0, center z=0.5
	for side in [-1, 1]:
		var side_mesh := BoxMesh.new()
		side_mesh.size = Vector3(0.12, 6.0, 10.0)
		side_mesh.surface_set_material(0, mat)
		var side_mi := MeshInstance3D.new()
		side_mi.mesh = side_mesh
		side_mi.position = Vector3(side * 6.8, 2.5, 0.5)
		add_child(side_mi)


func _build_frame_supports() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.40, 0.42, 0.46)
	mat.metallic = 0.85
	mat.roughness = 0.35

	# Vertical corner posts — positioned on the INSIDE face of the glass walls so they're visible
	# Side wall inner face at x=±6.74, back wall inner face at z=-4.44
	var corner_positions := [
		Vector3(-6.6, 2.5, -4.44),  # back-left corner (inside)
		Vector3( 6.6, 2.5, -4.44),  # back-right corner (inside)
		Vector3(-6.6, 2.5,  5.5),   # front-left edge
		Vector3( 6.6, 2.5,  5.5),   # front-right edge
	]
	for pos in corner_positions:
		var post := BoxMesh.new()
		post.size = Vector3(0.18, 6.0, 0.18)
		post.surface_set_material(0, mat)
		var post_mi := MeshInstance3D.new()
		post_mi.mesh = post
		post_mi.position = pos
		add_child(post_mi)

	# Intermediate vertical posts on back wall — also on inside face
	for px in [-3.5, 3.5]:
		var post := BoxMesh.new()
		post.size = Vector3(0.12, 6.0, 0.12)
		post.surface_set_material(0, mat)
		var post_mi := MeshInstance3D.new()
		post_mi.mesh = post
		post_mi.position = Vector3(px, 2.5, -4.44)
		add_child(post_mi)

	# Top horizontal beam along back wall — inside face
	var back_beam := BoxMesh.new()
	back_beam.size = Vector3(13.74, 0.14, 0.14)
	back_beam.surface_set_material(0, mat)
	var back_beam_mi := MeshInstance3D.new()
	back_beam_mi.mesh = back_beam
	back_beam_mi.position = Vector3(0.0, 5.45, -4.44)
	add_child(back_beam_mi)

	# Top horizontal beams along both side walls — inside face
	for side in [-1, 1]:
		var side_beam := BoxMesh.new()
		side_beam.size = Vector3(0.14, 0.14, 10.0)
		side_beam.surface_set_material(0, mat)
		var side_beam_mi := MeshInstance3D.new()
		side_beam_mi.mesh = side_beam
		side_beam_mi.position = Vector3(side * 6.6, 5.45, 0.5)
		add_child(side_beam_mi)


# Indoor potted plants placed along the sides of the greenhouse floor
func _build_floor_plants() -> void:
	var positions := [
		Vector3(-5.8, -0.35,  0.0),
		Vector3(-5.8, -0.35,  2.0),
		Vector3( 5.8, -0.35,  0.0),
		Vector3( 5.8, -0.35,  2.0),
	]
	for pos in positions:
		add_child(_create_floor_plant(pos))


func _create_floor_plant(pos: Vector3) -> Node3D:
	var root := Node3D.new()
	root.position = pos

	var pot_mesh := CylinderMesh.new()
	pot_mesh.height = 0.18
	pot_mesh.top_radius = 0.12
	pot_mesh.bottom_radius = 0.08
	pot_mesh.radial_segments = 6
	var pot_mat := StandardMaterial3D.new()
	pot_mat.albedo_color = Color(0.72, 0.35, 0.20)
	pot_mesh.surface_set_material(0, pot_mat)
	var pot_mi := MeshInstance3D.new()
	pot_mi.mesh = pot_mesh
	pot_mi.position = Vector3(0.0, 0.09, 0.0)
	root.add_child(pot_mi)

	var foliage_mesh := SphereMesh.new()
	foliage_mesh.radius = 0.18
	foliage_mesh.height = 0.28
	foliage_mesh.radial_segments = 6
	foliage_mesh.rings = 4
	var foliage_mat := StandardMaterial3D.new()
	foliage_mat.albedo_color = Color(0.18, 0.48, 0.22)
	foliage_mesh.surface_set_material(0, foliage_mat)
	var foliage_mi := MeshInstance3D.new()
	foliage_mi.mesh = foliage_mesh
	foliage_mi.position = Vector3(0.0, 0.34, 0.0)
	root.add_child(foliage_mi)

	return root
