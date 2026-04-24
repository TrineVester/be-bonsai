class_name ShelfMesh
extends Node3D

func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.30, 0.20, 0.10)
	mat.roughness = 0.7

	var shelf_mesh := BoxMesh.new()
	shelf_mesh.size = Vector3(7.5, 0.12, 2.0)
	shelf_mesh.surface_set_material(0, mat)
	var shelf := MeshInstance3D.new()
	shelf.mesh = shelf_mesh
	shelf.position = Vector3(0.0, -0.06, 0.0)
	add_child(shelf)

	for lx: float in [-3.4, -1.1, 1.1, 3.4]:
		for lz: float in [-0.8, 0.8]:
			var leg_mesh := BoxMesh.new()
			leg_mesh.size = Vector3(0.08, 0.38, 0.08)
			leg_mesh.surface_set_material(0, mat)
			var leg := MeshInstance3D.new()
			leg.mesh = leg_mesh
			leg.position = Vector3(lx, -0.31, lz)
			add_child(leg)
