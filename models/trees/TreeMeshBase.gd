class_name TreeMeshBase
extends Node3D

const SEC_PER_MONTH := 86400.0 * 30.0

var _data: TreeData
var _visual: Node3D


func _ready() -> void:
	_visual = Node3D.new()
	add_child(_visual)
	build_tree()


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
	build_tree()


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


# ─── Mesh Helpers ─────────────────────────────────────────────────────────────

func _create_trunk(height: float, bottom_radius: float, top_radius: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = height
	mesh.bottom_radius = bottom_radius
	mesh.top_radius = top_radius
	mesh.radial_segments = 6
	mesh.rings = 1
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.surface_set_material(0, mat)
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
	mesh.top_radius = base_radius * 0.25
	mesh.radial_segments = 5
	mesh.rings = 1
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.surface_set_material(0, mat)
	mi.mesh = mesh
	mi.position.y = length * 0.5  # base at node pos, tip extends outward
	node.add_child(mi)
	return node


# Foliage pad: flatten < 1.0 makes it wider than tall (bonsai pad shape)
func _create_foliage_pad(pos: Vector3, radius: float, flatten: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0 * flatten
	mesh.radial_segments = 7
	mesh.rings = 4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.surface_set_material(0, mat)
	mi.mesh = mesh
	mi.position = pos
	return mi


# Root flare at trunk base
func _create_nebari(radius: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = 0.07
	mesh.bottom_radius = radius
	mesh.top_radius = radius * 0.55
	mesh.radial_segments = 7
	mesh.rings = 1
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.surface_set_material(0, mat)
	mi.mesh = mesh
	mi.position.y = 0.035
	return mi
