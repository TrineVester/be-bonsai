class_name TreeMeshBase
extends Node3D

const SEC_PER_MONTH := 86400.0 * 30.0

var _data: TreeData
var _visual: Node3D

# Wind sway: list of {node, phase, amplitude, freq} dicts populated during build_tree()
var _sway_nodes: Array = []
# Set true temporarily (e.g. on interaction) to boost amplitude
var _sway_boost: float = 0.0


func _ready() -> void:
	_visual = Node3D.new()
	add_child(_visual)
	build_tree()


func _process(delta: float) -> void:
	if _sway_nodes.is_empty():
		return
	var t := Time.get_ticks_msec() * 0.001
	_sway_boost = maxf(0.0, _sway_boost - delta * 1.5)
	for entry in _sway_nodes:
		var node: Node3D = entry["node"]
		if not is_instance_valid(node):
			continue
		var amp: float = entry["amplitude"] * (1.0 + _sway_boost)
		var freq: float = entry["freq"]
		var phase: float = entry["phase"]
		node.rotation_degrees.z = sin(t * freq * TAU + phase) * amp
		node.rotation_degrees.x = sin(t * freq * 0.7 * TAU + phase + 1.0) * amp * 0.4


# Call this from Main.gd after adding to scene tree
func setup(data: TreeData) -> void:
	_data = data
	rebuild()


# Clears and rebuilds only the visual geometry — pot/label/area are untouched
func rebuild() -> void:
	if not _visual:
		return
	for child in _visual.get_children():
		child.queue_free()
	_sway_nodes.clear()
	build_tree()


# Trigger a brief boost in foliage sway (call on water/pick-up interaction)
func trigger_sway_boost() -> void:
	_sway_boost = 3.5


func build_tree() -> void:
	pass  # Override in species subclass


func get_age_months() -> float:
	if not _data:
		return 0.0
	return _data.age / SEC_PER_MONTH


# Canopy compactness 0.0 (wild) → 1.0 (tightly trained)
func get_compactness() -> float:
	if not _data:
		return 0.0
	return clampf(_data.prune_count * 0.12, 0.0, 0.85)


# True for Nov–Feb (months 11, 12, 1, 2) — used by Chinese Elm for bare stage
func is_winter() -> bool:
	if not _data:
		return false
	var m := GameClock.get_month()
	return m == 11 or m == 12 or m == 1 or m == 2


# ─── Mesh Helpers ─────────────────────────────────────────────────────────────

func _make_bark_mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.90
	mat.metallic = 0.0
	return mat


func _make_foliage_mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.95
	mat.metallic = 0.0
	mat.subsurf_scatter_enabled = true
	mat.subsurf_scatter_strength = 0.18
	return mat


func _create_trunk(height: float, bottom_radius: float, top_radius: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = height
	mesh.bottom_radius = bottom_radius
	mesh.top_radius = top_radius
	mesh.radial_segments = 7
	mesh.rings = 3
	mesh.surface_set_material(0, _make_bark_mat(color))
	mi.mesh = mesh
	mi.position.y = height / 2.0
	return mi


# Branch cylinder: originates at pos, extends outward.
# yaw_deg: direction in XZ plane (0=+Z toward cam, 90=+X right, 180=-Z back, 270=-X left)
# tilt_deg: tilt from vertical (0=straight up, 90=horizontal). Bonsai typically 70-85°.
func _create_branch(pos: Vector3, yaw_deg: float, tilt_deg: float, length: float, base_radius: float, color: Color) -> Node3D:
	var node := Node3D.new()
	node.position = pos
	node.rotation_degrees = Vector3(tilt_deg, yaw_deg, 0.0)
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = length
	mesh.bottom_radius = base_radius
	mesh.top_radius = base_radius * 0.20
	mesh.radial_segments = 5
	mesh.rings = 2
	mesh.surface_set_material(0, _make_bark_mat(color))
	mi.mesh = mesh
	mi.position.y = length * 0.5
	node.add_child(mi)
	return node


# Foliage pad: flatten < 1.0 makes it wider than tall (bonsai pad shape).
# sway_amp: amplitude in degrees for wind sway (0 = no sway)
func _create_foliage_pad(pos: Vector3, radius: float, flatten: float, color: Color, sway_amp: float = 1.2) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0 * flatten
	mesh.radial_segments = 8
	mesh.rings = 5
	mesh.surface_set_material(0, _make_foliage_mat(color))
	mi.mesh = mesh
	mi.position = pos
	if sway_amp > 0.0:
		_sway_nodes.append({
			"node": mi,
			"phase": pos.x * 3.7 + pos.z * 2.1,
			"amplitude": sway_amp,
			"freq": 0.45 + (pos.y * 0.08)
		})
	return mi


# Foliage cluster: 3 overlapping pads around a centre — breaks up the "rubber ball" look.
# Used by Ficus for bubble-cloud canopy.
func _create_foliage_cluster(center: Vector3, radius: float, flatten: float, color: Color, color2: Color, sway_amp: float = 1.2) -> Array:
	var nodes: Array = []
	var offsets := [
		Vector3( 0.0,         radius * 0.18,  0.0),
		Vector3(-radius * 0.55, radius * -0.08, radius * 0.28),
		Vector3( radius * 0.50, radius * -0.08, -radius * 0.24),
	]
	var colors := [color, color2, color]
	for i in 3:
		var mi := _create_foliage_pad(center + offsets[i], radius * 0.72, flatten, colors[i], sway_amp)
		nodes.append(mi)
	return nodes


# Thin hanging aerial root — Ficus signature feature
func _create_aerial_root(top_pos: Vector3, length: float, color: Color) -> Node3D:
	var node := Node3D.new()
	node.position = top_pos
	# Slight lean via two-segment approach
	var seg1 := MeshInstance3D.new()
	var m1 := CylinderMesh.new()
	m1.height = length * 0.55
	m1.top_radius = 0.008
	m1.bottom_radius = 0.006
	m1.radial_segments = 4
	m1.rings = 1
	m1.surface_set_material(0, _make_bark_mat(color.lightened(0.15)))
	seg1.mesh = m1
	seg1.position.y = -(length * 0.55) * 0.5
	node.add_child(seg1)

	var seg2 := MeshInstance3D.new()
	var m2 := CylinderMesh.new()
	m2.height = length * 0.50
	m2.top_radius = 0.006
	m2.bottom_radius = 0.004
	m2.radial_segments = 4
	m2.rings = 1
	m2.surface_set_material(0, _make_bark_mat(color.lightened(0.15)))
	seg2.mesh = m2
	seg2.position = Vector3(top_pos.x * 0.08, -(length * 0.55) - (length * 0.50) * 0.5, 0.02)
	node.add_child(seg2)
	return node


# Deadwood stub — bleached grey, used on Juniper jin
func _create_jin(pos: Vector3, yaw_deg: float, tilt_deg: float, length: float) -> Node3D:
	var jin_color := Color(0.80, 0.78, 0.72)
	var node := Node3D.new()
	node.position = pos
	node.rotation_degrees = Vector3(tilt_deg, yaw_deg, 0.0)
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = length
	mesh.bottom_radius = 0.018
	mesh.top_radius = 0.004
	mesh.radial_segments = 4
	mesh.rings = 1
	mesh.surface_set_material(0, _make_bark_mat(jin_color))
	mi.mesh = mesh
	mi.position.y = length * 0.5
	node.add_child(mi)
	return node


# Root flare at trunk base
func _create_nebari(radius: float, color: Color) -> Node3D:
	var root := Node3D.new()

	# Main flare disc
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = 0.10
	mesh.bottom_radius = radius
	mesh.top_radius = radius * 0.45
	mesh.radial_segments = 8
	mesh.rings = 2
	mesh.surface_set_material(0, _make_bark_mat(color))
	mi.mesh = mesh
	mi.position.y = 0.05
	root.add_child(mi)

	# 4 surface root spurs fanning outward
	var spur_angles := [0.0, 90.0, 180.0, 270.0]
	for ang in spur_angles:
		var spur := MeshInstance3D.new()
		var sm := CylinderMesh.new()
		sm.height = radius * 0.9
		sm.top_radius = 0.012
		sm.bottom_radius = 0.020
		sm.radial_segments = 4
		sm.rings = 1
		sm.surface_set_material(0, _make_bark_mat(color.darkened(0.08)))
		spur.mesh = sm
		var node := Node3D.new()
		node.rotation_degrees = Vector3(82.0, ang, 0.0)
		node.position.y = 0.015
		spur.position.y = radius * 0.45
		node.add_child(spur)
		root.add_child(node)

	return root
