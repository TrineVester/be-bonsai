class_name GreenhouseEnvironment
extends Node3D

func _ready() -> void:
	_build_lighting()
	_build_sky()
	add_child(GreenhouseBackground.new())


func _build_lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, 35.0, 0.0)
	sun.light_color = Color(1.0, 0.95, 0.82)
	sun.light_energy = 1.8
	sun.shadow_enabled = true
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20.0, -150.0, 0.0)
	fill.light_color = Color(0.75, 0.90, 0.85)
	fill.light_energy = 0.4
	add_child(fill)


func _build_sky() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()

	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color        = Color(0.55, 0.80, 0.60)
	sky_mat.sky_horizon_color    = Color(0.82, 0.92, 0.78)
	sky_mat.ground_bottom_color  = Color(0.30, 0.22, 0.14)
	sky_mat.ground_horizon_color = Color(0.60, 0.52, 0.38)
	sky_mat.sun_angle_max = 30.0
	sky.sky_material = sky_mat

	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.9
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.glow_bloom = 0.1

	world_env.environment = env
	add_child(world_env)
