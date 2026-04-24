extends Node3D

const TREE_POSITIONS  := [Vector3(-2.2, 0.2, 0.0), Vector3(0.0, 0.2, 0.0), Vector3(2.2, 0.2, 0.0)]
const FOCUSED_POSITION := Vector3(0.0, 0.6, 3.2)
const LERP_SPEED := 6.0

var _trees: Array[TreeData] = []
var _tree_nodes: Array[Node3D] = []
var _tree_targets: Array[Vector3] = []
var _pot_nodes: Array[Node3D] = []

var _held_index: int = -1

var _speed_buttons: Array[Button] = []
var _action_panel: PanelContainer
var _tree_overlays: Array[Control] = []
var _stat_bars: Array[Dictionary] = []
var _analog_clock: Control
var _calendar_page: Control


func _ready() -> void:
	_setup_world()
	_create_trees()
	_build_ui()
	GameClock.speed_changed.connect(_on_speed_changed)
	_update_speed_buttons()


func _process(delta: float) -> void:
	var dt := GameClock.get_scaled_delta(delta)
	for tree: TreeData in _trees:
		tree.on_time_passed(dt)

	var camera := get_viewport().get_camera_3d()
	for i in 3:
		_tree_nodes[i].position = _tree_nodes[i].position.lerp(_tree_targets[i], LERP_SPEED * delta)
		if camera:
			var screen_pos := camera.unproject_position(
				_tree_nodes[i].global_position + Vector3(0.0, -0.55, 0.0)
			)
			_tree_overlays[i].position = screen_pos - Vector2(_tree_overlays[i].size.x * 0.5, 0.0)
		_tree_overlays[i].visible = (_held_index < 0 or _held_index == i)
		if _tree_overlays[i].visible:
			_refresh_tree_overlay(i)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_pick_tree(event.position)


func _setup_world() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 2.5, 6.0)
	camera.rotation_degrees = Vector3(-18.0, 0.0, 0.0)
	add_child(camera)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	light.light_energy = 1.2
	add_child(light)

	var ambient := WorldEnvironment.new()
	var env := Environment.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.6, 0.6)
	env.ambient_light_energy = 0.5
	ambient.environment = env
	add_child(ambient)

	var shelf_mesh := BoxMesh.new()
	shelf_mesh.size = Vector3(7.5, 0.2, 2.2)
	var shelf_mat := StandardMaterial3D.new()
	shelf_mat.albedo_color = Color(0.42, 0.28, 0.14)
	shelf_mesh.surface_set_material(0, shelf_mat)
	var shelf := MeshInstance3D.new()
	shelf.mesh = shelf_mesh
	shelf.position = Vector3(0.0, -0.1, 0.0)
	add_child(shelf)


func _create_trees() -> void:
	var data_instances: Array[TreeData] = [JuniperData.new(), FicusData.new(), ChineseElmData.new()]
	var mesh_classes: Array = [JuniperMesh, FicusMesh, ChineseElmMesh]
	# Default pot for each tree — can be swapped independently
	var default_pot_class := TerracottaClassicPot

	for i in 3:
		var tree: TreeData = data_instances[i]
		tree.age = float(randi_range(12, 60)) * 300.0
		tree.moisture = randf_range(0.5, 0.9)
		_trees.append(tree)
		_tree_targets.append(TREE_POSITIONS[i])

		var mesh_node: Node3D = mesh_classes[i].new()
		mesh_node.position = TREE_POSITIONS[i]
		add_child(mesh_node)
		_tree_nodes.append(mesh_node)

		var pot_node: Node3D = default_pot_class.new()
		pot_node.position = Vector3.ZERO
		mesh_node.add_child(pot_node)
		_pot_nodes.append(pot_node)

		var label := Label3D.new()
		label.text = tree.species
		label.position = Vector3(0.0, 2.4, 0.0)
		label.font_size = 32
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		mesh_node.add_child(label)

		var area := Area3D.new()
		area.set_meta("tree_index", i)
		var shape := CollisionShape3D.new()
		var capsule := CapsuleShape3D.new()
		capsule.radius = 0.7
		capsule.height = 2.2
		shape.shape = capsule
		shape.position = Vector3(0.0, 1.1, 0.0)
		area.add_child(shape)
		mesh_node.add_child(area)


# ── UI ────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	_build_top_bar(canvas)
	_build_tree_overlays(canvas)
	_build_action_panel(canvas)


func _build_top_bar(canvas: CanvasLayer) -> void:
	var outer := HBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	outer.add_theme_constant_override("separation", 8)
	outer.offset_left = 8.0
	outer.offset_top  = 8.0
	canvas.add_child(outer)

	var card := PanelContainer.new()
	var card_style := StyleBoxFlat.new()
	card_style.bg_color            = Color(0.08, 0.08, 0.10, 0.82)
	card_style.corner_radius_top_left     = 8
	card_style.corner_radius_top_right    = 8
	card_style.corner_radius_bottom_left  = 8
	card_style.corner_radius_bottom_right = 8
	card_style.content_margin_left   = 10.0
	card_style.content_margin_right  = 10.0
	card_style.content_margin_top    = 8.0
	card_style.content_margin_bottom = 8.0
	card.add_theme_stylebox_override("panel", card_style)
	outer.add_child(card)

	var card_hbox := HBoxContainer.new()
	card_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_hbox.add_theme_constant_override("separation", 10)
	card.add_child(card_hbox)

	_analog_clock = AnalogClock.new()
	_analog_clock.custom_minimum_size = Vector2(48.0, 48.0)
	card_hbox.add_child(_analog_clock)

	var divider := ColorRect.new()
	divider.color = Color(1.0, 1.0, 1.0, 0.12)
	divider.custom_minimum_size = Vector2(1.0, 36.0)
	card_hbox.add_child(divider)

	_calendar_page = CalendarPage.new()
	card_hbox.add_child(_calendar_page)

	var sep := Control.new()
	sep.custom_minimum_size.x = 16.0
	outer.add_child(sep)

	var speed_card := PanelContainer.new()
	speed_card.add_theme_stylebox_override("panel", card_style)
	outer.add_child(speed_card)

	var speed_hbox := HBoxContainer.new()
	speed_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	speed_hbox.add_theme_constant_override("separation", 4)
	speed_card.add_child(speed_hbox)

	var speed_options: Array = [["Pause", 0.0], ["Slow", 1440.0], ["Normal", 8640.0], ["Fast", 86400.0]]

	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style_normal.corner_radius_top_left     = 5
	style_normal.corner_radius_top_right    = 5
	style_normal.corner_radius_bottom_left  = 5
	style_normal.corner_radius_bottom_right = 5
	style_normal.content_margin_left   = 8.0
	style_normal.content_margin_right  = 8.0
	style_normal.content_margin_top    = 4.0
	style_normal.content_margin_bottom = 4.0

	var style_pressed := StyleBoxFlat.new()
	style_pressed.bg_color = Color(1.0, 1.0, 1.0, 0.12)
	style_pressed.corner_radius_top_left     = 5
	style_pressed.corner_radius_top_right    = 5
	style_pressed.corner_radius_bottom_left  = 5
	style_pressed.corner_radius_bottom_right = 5
	style_pressed.content_margin_left   = 8.0
	style_pressed.content_margin_right  = 8.0
	style_pressed.content_margin_top    = 4.0
	style_pressed.content_margin_bottom = 4.0

	for entry: Array in speed_options:
		var btn := Button.new()
		btn.text = entry[0]
		btn.custom_minimum_size = Vector2(58, 30)
		btn.toggle_mode = true
		btn.flat = true
		btn.add_theme_stylebox_override("normal",        style_normal)
		btn.add_theme_stylebox_override("hover",         style_normal)
		btn.add_theme_stylebox_override("pressed",       style_pressed)
		btn.add_theme_stylebox_override("focus",         style_normal)
		btn.add_theme_color_override("font_color",              Color(1.0, 1.0, 1.0, 0.45))
		btn.add_theme_color_override("font_hover_color",        Color(1.0, 1.0, 1.0, 0.75))
		btn.add_theme_color_override("font_pressed_color",      Color(1.0, 1.0, 1.0, 1.00))
		btn.add_theme_color_override("font_focus_color",        Color(1.0, 1.0, 1.0, 0.45))
		btn.pressed.connect(GameClock.set_speed.bind(entry[1]))
		speed_hbox.add_child(btn)
		_speed_buttons.append(btn)


func _build_tree_overlays(canvas: CanvasLayer) -> void:
	var stat_names  := ["Water", "Health", "Fert", "Prune", "Repot"]
	var stat_colors := [
		Color(0.25, 0.55, 1.00),
		Color(0.25, 0.85, 0.35),
		Color(1.00, 0.60, 0.20),
		Color(1.00, 0.90, 0.20),
		Color(0.70, 0.30, 1.00),
	]

	for i in 3:
		var bg := PanelContainer.new()
		bg.custom_minimum_size = Vector2(136.0, 0.0)
		canvas.add_child(bg)
		_tree_overlays.append(bg)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		bg.add_child(vbox)

		var bars: Dictionary = {}
		for j in stat_names.size():
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 4)
			vbox.add_child(row)

			var lbl := Label.new()
			lbl.text = stat_names[j]
			lbl.custom_minimum_size.x = 38.0
			lbl.add_theme_font_size_override("font_size", 10)
			row.add_child(lbl)

			var bar := ProgressBar.new()
			bar.max_value = 1.0
			bar.custom_minimum_size = Vector2(76.0, 10.0)
			bar.show_percentage = false
			var style := StyleBoxFlat.new()
			style.bg_color = stat_colors[j]
			bar.add_theme_stylebox_override("fill", style)
			row.add_child(bar)

			bars[stat_names[j]] = bar

		_stat_bars.append(bars)


func _build_action_panel(canvas: CanvasLayer) -> void:
	_action_panel = PanelContainer.new()
	_action_panel.visible = false
	_action_panel.anchor_left   = 0.0
	_action_panel.anchor_right  = 1.0
	_action_panel.anchor_top    = 1.0
	_action_panel.anchor_bottom = 1.0
	_action_panel.offset_top    = -56.0
	_action_panel.offset_bottom = -4.0
	canvas.add_child(_action_panel)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)
	_action_panel.add_child(hbox)

	for op: String in ["Water", "Prune", "Fertilize", "Repot"]:
		var btn := Button.new()
		btn.text = op
		btn.custom_minimum_size = Vector2(80, 36)
		btn.pressed.connect(_do_operation.bind(op))
		hbox.add_child(btn)

	var put_back := Button.new()
	put_back.text = "← Put Back"
	put_back.custom_minimum_size = Vector2(90, 36)
	put_back.pressed.connect(_put_back_tree)
	hbox.add_child(put_back)


# ── Actions ───────────────────────────────────────────────────────────────────

func _try_pick_tree(mouse_pos: Vector2) -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return
	var space := get_world_3d().direct_space_state
	var origin    := camera.project_ray_origin(mouse_pos)
	var direction := camera.project_ray_normal(mouse_pos)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 100.0)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result := space.intersect_ray(query)
	if result.is_empty():
		return
	var collider = result["collider"]
	if collider is Area3D and collider.has_meta("tree_index"):
		var idx: int = collider.get_meta("tree_index")
		if idx == _held_index:
			_put_back_tree()
		else:
			_pick_up_tree(idx)


func _pick_up_tree(index: int) -> void:
	if _held_index >= 0:
		_tree_targets[_held_index] = TREE_POSITIONS[_held_index]
	_held_index = index
	_tree_targets[index] = FOCUSED_POSITION
	GameClock.pause_for_interaction()
	_action_panel.visible = true


func _put_back_tree() -> void:
	if _held_index >= 0:
		_tree_targets[_held_index] = TREE_POSITIONS[_held_index]
	_held_index = -1
	GameClock.resume_from_interaction()
	_action_panel.visible = false


func _do_operation(op: String) -> void:
	if _held_index < 0:
		return
	var tree := _trees[_held_index]
	match op:
		"Water":     tree.water()
		"Prune":     tree.prune()
		"Fertilize": tree.fertilize()
		"Repot":     tree.repot()


# ── Refresh ───────────────────────────────────────────────────────────────────

func _refresh_tree_overlay(i: int) -> void:
	var tree  := _trees[i]
	var bars: Dictionary = _stat_bars[i]
	bars["Water"].value  = tree.moisture
	bars["Health"].value = tree.health
	bars["Fert"].value   = tree.fertilizer_level
	bars["Prune"].value  = tree.get_prune_urgency()
	bars["Repot"].value  = tree.get_repot_urgency()


func _on_speed_changed(_speed: float) -> void:
	_update_speed_buttons()


func _update_speed_buttons() -> void:
	var speeds: Array = [0.0, 1440.0, 8640.0, 86400.0]
	for i in _speed_buttons.size():
		_speed_buttons[i].button_pressed = (GameClock.speed == speeds[i])
