class_name GreenhouseEnvironment
extends Node3D

const LATITUDE_DEG := 52.0

# Sky color keyed to sun elevation (degrees): [elev, sky_top, sky_horizon, ground_horizon]
const _ELEV_KEYS: Array = [
	[-8.0, Color(0.01, 0.01, 0.06), Color(0.03, 0.03, 0.12), Color(0.05, 0.03, 0.08)],
	[ 0.0, Color(0.08, 0.06, 0.20), Color(0.72, 0.32, 0.10), Color(0.42, 0.20, 0.12)],
	[ 5.0, Color(0.28, 0.48, 0.72), Color(0.88, 0.62, 0.30), Color(0.55, 0.38, 0.18)],
	[20.0, Color(0.38, 0.65, 0.80), Color(0.76, 0.88, 0.70), Color(0.55, 0.45, 0.30)],
	[50.0, Color(0.55, 0.80, 0.60), Color(0.82, 0.92, 0.78), Color(0.60, 0.52, 0.38)],
]

var _sky_mat: ProceduralSkyMaterial
var _sun: DirectionalLight3D
var _string_lights: Array[OmniLight3D] = []
var _overhead_lights: Array[OmniLight3D] = []
var _bulb_mat: StandardMaterial3D
var _overhead_bulb_mat: StandardMaterial3D


func _ready() -> void:
	_build_lighting()
	_build_sky()
	add_child(GreenhouseBackground.new())
	_update_sky(GameClock.get_day_fraction())


func _process(_delta: float) -> void:
	_update_sky(GameClock.get_day_fraction())


func _build_lighting() -> void:
	_sun = DirectionalLight3D.new()
	_sun.light_color = Color(1.0, 0.95, 0.82)
	_sun.light_energy = 0.0
	_sun.shadow_enabled = true
	add_child(_sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20.0, -150.0, 0.0)
	fill.light_color = Color(0.75, 0.90, 0.85)
	fill.light_energy = 0.4
	add_child(fill)

	_build_light_string()
	_build_overhead_lights()


func _build_overhead_lights() -> void:
	_overhead_bulb_mat = StandardMaterial3D.new()
	_overhead_bulb_mat.albedo_color = Color(1.0, 0.98, 0.88)
	_overhead_bulb_mat.emission_enabled = true
	_overhead_bulb_mat.emission = Color(1.0, 0.92, 0.72)
	_overhead_bulb_mat.emission_energy_multiplier = 0.0

	# Row of 5 bare bulbs flush with the ceiling ridge, evenly spaced along x.
	const Y := 5.38
	for i in 5:
		var x := lerpf(-4.0, 4.0, float(i) / 4.0)

		var bulb_mesh := SphereMesh.new()
		bulb_mesh.radius = 0.10
		bulb_mesh.height = 0.20
		bulb_mesh.radial_segments = 8
		bulb_mesh.rings = 4
		bulb_mesh.surface_set_material(0, _overhead_bulb_mat)
		var bulb_mi := MeshInstance3D.new()
		bulb_mi.mesh = bulb_mesh
		bulb_mi.position = Vector3(x, Y, 0.0)
		add_child(bulb_mi)

		var lamp := OmniLight3D.new()
		lamp.position = Vector3(x, Y, 0.0)
		lamp.light_color = Color(1.0, 0.93, 0.75)
		lamp.light_energy = 0.0
		lamp.omni_range = 8.0
		lamp.shadow_enabled = false
		add_child(lamp)
		_overhead_lights.append(lamp)


func _build_light_string() -> void:
	const X_LEFT  := -6.4
	const X_RIGHT :=  6.4
	const Y_MOUNT :=  5.30
	const SAG     :=  0.55
	const Z_DEPTH := -4.35
	const N_BULBS :=  16

	_bulb_mat = StandardMaterial3D.new()
	_bulb_mat.albedo_color = Color(1.0, 0.95, 0.70)
	_bulb_mat.emission_enabled = true
	_bulb_mat.emission = Color(1.0, 0.85, 0.45)
	_bulb_mat.emission_energy_multiplier = 0.0

	var wire_mat := StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.14, 0.11, 0.09)

	var positions: Array[Vector3] = []
	for i in N_BULBS:
		var frac := float(i) / float(N_BULBS - 1)
		var x    := lerpf(X_LEFT, X_RIGHT, frac)
		var tc   := frac * 2.0 - 1.0
		var y    := Y_MOUNT - SAG * (1.0 - tc * tc)
		positions.append(Vector3(x, y, Z_DEPTH))

	for i in N_BULBS:
		var pos: Vector3 = positions[i]

		var bulb_mesh := SphereMesh.new()
		bulb_mesh.radius = 0.055
		bulb_mesh.height = 0.11
		bulb_mesh.radial_segments = 6
		bulb_mesh.rings = 3
		bulb_mesh.surface_set_material(0, _bulb_mat)
		var bulb_mi := MeshInstance3D.new()
		bulb_mi.mesh = bulb_mesh
		bulb_mi.position = pos
		add_child(bulb_mi)

		var lamp := OmniLight3D.new()
		lamp.position = pos
		lamp.light_color = Color(1.0, 0.82, 0.45)
		lamp.light_energy = 0.0
		lamp.omni_range = 1.8
		lamp.shadow_enabled = false
		add_child(lamp)
		_string_lights.append(lamp)

		if i < N_BULBS - 1:
			_add_wire_segment(pos, positions[i + 1], wire_mat)


func _add_wire_segment(from: Vector3, to: Vector3, mat: StandardMaterial3D) -> void:
	var dir := (to - from).normalized()
	var wire_mesh := CylinderMesh.new()
	wire_mesh.height = from.distance_to(to)
	wire_mesh.top_radius = 0.007
	wire_mesh.bottom_radius = 0.007
	wire_mesh.radial_segments = 4
	wire_mesh.rings = 1
	wire_mesh.surface_set_material(0, mat)
	var mi := MeshInstance3D.new()
	mi.mesh = wire_mesh
	mi.position = (from + to) * 0.5
	mi.quaternion = Quaternion(Vector3.UP, dir)
	add_child(mi)


func _build_sky() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	_sky_mat = ProceduralSkyMaterial.new()
	_sky_mat.sun_angle_max = 30.0
	sky.sky_material = _sky_mat
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.9
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.glow_bloom = 0.1
	world_env.environment = env
	add_child(world_env)


func _update_sky(t: float) -> void:
	var lat_rad := deg_to_rad(LATITUDE_DEG)
	var doy     := float((GameClock.get_month() - 1) * 30 + (GameClock.get_day() - 1))
	var dec_rad := deg_to_rad(23.45 * sin(TAU * (doy - 81.0) / 360.0))

	# Hour angle: t=0.5 is solar noon (HA=0), t=0/1 is midnight (HA=±π)
	var ha_rad  := (t - 0.5) * TAU
	var sin_elev := sin(lat_rad) * sin(dec_rad) + cos(lat_rad) * cos(dec_rad) * cos(ha_rad)
	var elev_rad := asin(clampf(sin_elev, -1.0, 1.0))
	var elev_deg := rad_to_deg(elev_rad)
	var cos_elev := cos(elev_rad)

	# Azimuth (0 = north, 90 = east, clockwise)
	var az_rad := 0.0
	if cos_elev > 0.0001:
		var cos_az := (sin(dec_rad) - sin(lat_rad) * sin_elev) / (cos(lat_rad) * cos_elev)
		az_rad = acos(clampf(cos_az, -1.0, 1.0))
		if t > 0.5:
			az_rad = TAU - az_rad

	# Sun energy scales with elevation (rises above horizon, peaks at max elevation)
	var sun_energy := clampf(sin_elev * 2.2 + 0.08, 0.0, 1.8)
	_sun.light_energy = sun_energy

	# Orient sun: light_dir points FROM sun position TOWARD scene
	# In Godot (+X=east, +Y=up, -Z=north): sun at azimuth az, elevation elev_rad
	var light_dir := Vector3(
		-sin(az_rad) * cos_elev,
		-sin_elev,
		cos(az_rad) * cos_elev
	)
	var up_ref := Vector3.BACK if abs(light_dir.dot(Vector3.UP)) > 0.99 else Vector3.UP
	_sun.basis = Basis.looking_at(light_dir, up_ref)

	# Sky colors derived from elevation, not clock time — naturally adjusts with seasons
	var a: Array = _ELEV_KEYS[0]
	var b: Array = _ELEV_KEYS[_ELEV_KEYS.size() - 1]
	for i in range(_ELEV_KEYS.size() - 1):
		if elev_deg >= (_ELEV_KEYS[i][0] as float) and elev_deg <= (_ELEV_KEYS[i + 1][0] as float):
			a = _ELEV_KEYS[i]
			b = _ELEV_KEYS[i + 1]
			break
	var span: float = (b[0] as float) - (a[0] as float)
	var f: float    = 0.0 if span == 0.0 else clampf((elev_deg - (a[0] as float)) / span, 0.0, 1.0)
	_sky_mat.sky_top_color        = (a[1] as Color).lerp(b[1], f)
	_sky_mat.sky_horizon_color    = (a[2] as Color).lerp(b[2], f)
	_sky_mat.ground_horizon_color = (a[3] as Color).lerp(b[3], f)

	# Fairy lights: on 1h before sunset, off 1h after sunrise
	var cos_ha0 := -tan(lat_rad) * tan(dec_rad)
	var fairy := 0.0
	if abs(cos_ha0) > 1.0:
		fairy = 1.0 if cos_ha0 < -1.0 else 0.0
	else:
		var ha0    := acos(clampf(cos_ha0, -1.0, 1.0))
		var t_rise := 0.5 - ha0 / TAU
		var t_set  := 0.5 + ha0 / TAU
		const ONE_HOUR := 1.0 / 24.0
		if t >= t_set - ONE_HOUR and t < t_set:
			fairy = (t - (t_set - ONE_HOUR)) / ONE_HOUR
		elif t >= t_set or t <= t_rise:
			fairy = 1.0
		elif t > t_rise and t <= t_rise + ONE_HOUR:
			fairy = 1.0 - (t - t_rise) / ONE_HOUR
	_bulb_mat.emission_energy_multiplier = fairy * 2.5
	for lamp: OmniLight3D in _string_lights:
		lamp.light_energy = fairy * 0.5
	_overhead_bulb_mat.emission_energy_multiplier = fairy * 2.0
	for lamp: OmniLight3D in _overhead_lights:
		lamp.light_energy = fairy * 1.6
