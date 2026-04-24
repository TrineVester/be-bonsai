class_name TreeMeshBase
extends Node3D

func _ready() -> void:
	build_tree()


func build_tree() -> void:
	pass  # Override in species subclass


func _create_trunk(height: float, bottom_radius: float, top_radius: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = height
	mesh.bottom_radius = bottom_radius
	mesh.top_radius = top_radius
	mesh.radial_segments = 6  # low poly
	mesh.rings = 1

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.surface_set_material(0, mat)

	mi.mesh = mesh
	mi.position.y = height / 2.0
	return mi


func _create_foliage(radius: float, position: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 6  # low poly faceted look
	mesh.rings = 4

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.surface_set_material(0, mat)

	mi.mesh = mesh
	mi.position = position
	return mi
