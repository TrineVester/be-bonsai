class_name PotMeshBase
extends Node3D

func _ready() -> void:
	build_pot()


func build_pot() -> void:
	pass  # Override in pot subclass


# Builds the main tapered pot body.
# top_radius > bottom_radius gives the classic widening-toward-top pot shape.
func _create_pot_body(height: float, top_radius: float, bottom_radius: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = height
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.radial_segments = 6  # low poly
	mesh.rings = 1

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.surface_set_material(0, mat)

	mi.mesh = mesh
	mi.position.y = height / 2.0
	return mi


# Thin flat rim around the top opening.
func _create_pot_rim(radius: float, height_offset: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = 0.04
	mesh.top_radius = radius + 0.04
	mesh.bottom_radius = radius + 0.02
	mesh.radial_segments = 6
	mesh.rings = 1

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.surface_set_material(0, mat)

	mi.mesh = mesh
	mi.position.y = height_offset
	return mi
