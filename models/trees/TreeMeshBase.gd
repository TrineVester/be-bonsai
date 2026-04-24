class_name TreeMeshBase
extends Node3D

const SEC_PER_MONTH := 86400.0 * 30.0

var _data: TreeData
var _visual: Node3D

# Wind sway: list of {node, phase, amplitude, freq} dicts populated during build_tree()
var _sway_nodes: Array = []
# Set true temporarily (e.g. on interaction) to boost amplitude
var _sway_boost: float = 0.0

# Tree index (set via setup) stored on branch Area3D meta for click detection
var _tree_idx: int = -1
# Maps branch_id → {mi: MeshInstance3D, node: Node3D, area: Area3D}
var _branch_nodes: Dictionary = {}
var _selected_branch_id: String = ""


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
func setup(data: TreeData, tree_idx: int = -1) -> void:
	_data = data
	_tree_idx = tree_idx
	rebuild()


# Clears and rebuilds only the visual geometry — pot/label/area are untouched
func rebuild() -> void:
	if not _visual:
		return
	for child in _visual.get_children():
		child.queue_free()
	_sway_nodes.clear()
	_branch_nodes.clear()
	_selected_branch_id = ""
	build_tree()


# Trigger a brief boost in foliage sway (call on water/pick-up interaction)
func trigger_sway_boost() -> void:
	_sway_boost = 3.5


func build_tree() -> void:
	pass  # Override in species subclass


# ─── Branch Selection ───────────────────────────────────────────────────────────────────
func select_branch(id: String) -> void:
	deselect_branch()
	_selected_branch_id = id
	if _branch_nodes.has(id):
		var mi: MeshInstance3D = _branch_nodes[id]["mi"]
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.92, 0.76, 0.18)  # golden highlight
		mat.roughness = 0.65
		mi.material_override = mat


func deselect_branch() -> void:
	if _selected_branch_id != "" and _branch_nodes.has(_selected_branch_id):
		var mi: MeshInstance3D = _branch_nodes[_selected_branch_id]["mi"]
		mi.material_override = null
	_selected_branch_id = ""


func get_selected_branch() -> String:
	return _selected_branch_id


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


# Shaped branch with per-branch state: birth animation, prune check, wiring override.
# Adds a clickable Area3D on collision layer 2. Populates _branch_nodes[id].
# Call from stage build() functions instead of _create_branch() + add_child().
func _add_branch(id: String, born_months: float, pos: Vector3, yaw_deg: float, tilt_deg: float, length: float, base_radius: float, color: Color) -> void:
	var age := get_age_months()
	if age < born_months:
		return  # branch hasn't grown yet

	# Soft birth: grows from 0 → full over 4 months
	var birth_t := clampf((age - born_months) / 4.0, 0.0, 1.0)
	var eff_len    := length * birth_t
	var eff_radius := base_radius * birth_t
	if eff_len < 0.015:
		return

	# Check for pruning — show a tiny bleached stub
	if _data and _data.is_branch_pruned(id):
		var stub := _create_jin(pos, yaw_deg, tilt_deg, minf(0.10, length * 0.15))
		_visual.add_child(stub)
		return

	# Apply wiring overrides (future shaping feature)
	var eff_yaw  := yaw_deg
	var eff_tilt := tilt_deg
	if _data:
		var angles := _data.get_branch_angles(id, yaw_deg, tilt_deg)
		eff_yaw  = angles[0]
		eff_tilt = angles[1]

	var node: Node3D = _create_branch(pos, eff_yaw, eff_tilt, eff_len, eff_radius, color)
	var mi := node.get_child(0) as MeshInstance3D

	# Clickable area for per-branch pruning (collision layer 2, detected only when tree held)
	var area := Area3D.new()
	area.collision_layer = 2
	area.collision_mask  = 0
	area.set_meta("branch_id", id)
	if _tree_idx >= 0:
		area.set_meta("tree_index", _tree_idx)
	var shape_node := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.height = maxf(0.06, eff_len)
	cap.radius = 0.10
	shape_node.shape = cap
	shape_node.position.y = eff_len * 0.5
	area.add_child(shape_node)
	node.add_child(area)

	_visual.add_child(node)
	_branch_nodes[id] = {"mi": mi, "node": node, "area": area}


# Returns the world-space tip of a branch from pos, given its yaw+tilt orientation.
# Matches the _create_branch rotation convention (Godot YXZ Euler: Ry * Rx).
# Use this in stage build() functions to place foliage at branch ends.
func _branch_tip(pos: Vector3, yaw_deg: float, tilt_deg: float, length: float) -> Vector3:
	var yaw_r  := deg_to_rad(yaw_deg)
	var tilt_r := deg_to_rad(tilt_deg)
	return pos + Vector3(sin(tilt_r) * sin(yaw_r), cos(tilt_r), sin(tilt_r) * cos(yaw_r)) * length


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
