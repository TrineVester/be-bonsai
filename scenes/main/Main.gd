extends Node3D

const GreenhouseEnvironment := preload("res://scenes/greenhouse/GreenhouseEnvironment.gd")
const ShelfMesh := preload("res://models/environment/ShelfMesh.gd")

const TREE_POSITIONS   := [Vector3(-2.2, 0.0, 0.0), Vector3(0.0, 0.0, 0.0), Vector3(2.2, 0.0, 0.0)]
const FOCUSED_POSITION := Vector3(0.0, 0.0, 0.0)  # unused for movement; kept for reference
const LERP_SPEED       := 6.0

var _trees:        Array[TreeData] = []
var _tree_nodes:   Array[Node3D]   = []
var _tree_targets: Array[Vector3]  = []
var _pot_nodes:    Array[Node3D]   = []

var _held_index: int = -1

# ── Inspect-view state (active while a tree is focused) ───────────────────────
var _view_yaw:    float = 0.0   # accumulated horizontal drag
var _view_pitch:  float = 0.0   # accumulated vertical drag (clamped)
var _view_zoom:   float = 0.0   # scroll offset on Z (negative = closer)
var _drag_origin: Vector2 = Vector2.ZERO
var _is_dragging: bool   = false

const DRAG_THRESHOLD    := 5.0
const YAW_SENSITIVITY   := 0.45   # degrees per pixel
const PITCH_SENSITIVITY := 0.28
const ZOOM_STEP         := 0.3
const ZOOM_MIN          := -2.5   # most zoomed in
const ZOOM_MAX          :=  3.0   # most zoomed out

const ORBIT_PIVOT_HEIGHT := 0.55  # look-at height above focused tree base
const ORBIT_DIST_BASE    := 2.8   # default orbit radius
const ORBIT_PITCH_BASE   := 8.0   # default downward look angle (degrees)
const DEFAULT_CAM_POS    := Vector3(0.0, 2.2, 4.2)
const DEFAULT_CAM_PIVOT  := Vector3(0.0, 1.1, 0.0)

var _tree_overlays: Array[TreeStatOverlay] = []
var _action_panel:  ActionPanel
var _camera: Camera3D


func _ready() -> void:
	add_child(GreenhouseEnvironment.new())
	add_child(ShelfMesh.new())
	_setup_camera()
	_create_trees()
	_build_ui()
	GameClock.month_advanced.connect(_on_month_advanced)


func _process(delta: float) -> void:
	var dt := GameClock.get_scaled_delta(delta)
	for tree: TreeData in _trees:
		tree.on_time_passed(dt)

	for i in 3:
		_tree_nodes[i].position = _tree_nodes[i].position.lerp(_tree_targets[i], LERP_SPEED * delta)
		if i == _held_index:
			# Pin to top-right corner when the tree is being inspected
			var vp := get_viewport().get_visible_rect().size
			_tree_overlays[i].position = Vector2(vp.x - _tree_overlays[i].size.x - 8.0, 54.0)
		elif _camera:
			var screen_pos := _camera.unproject_position(
				_tree_nodes[i].global_position + Vector3(0.0, -0.55, 0.0)
			)
			_tree_overlays[i].position = screen_pos - Vector2(_tree_overlays[i].size.x * 0.5, 0.0)
		_tree_overlays[i].visible = (_held_index < 0 or _held_index == i)
		if _tree_overlays[i].visible:
			_tree_overlays[i].refresh(_trees[i])

	# Camera: orbit the focused tree or drift back to default framing
	if _camera:
		var cam_tgt: Vector3
		var cam_pivot: Vector3
		if _held_index >= 0:
			# Orbit around the tree's current world position
			var tree_pos := _tree_nodes[_held_index].position
			cam_pivot = tree_pos + Vector3(0.0, ORBIT_PIVOT_HEIGHT, 0.0)
			var dist    := maxf(0.8, ORBIT_DIST_BASE + _view_zoom)
			var yaw_r   := deg_to_rad(_view_yaw)
			var pitch_r := deg_to_rad(clampf(ORBIT_PITCH_BASE + _view_pitch, -5.0, 80.0))
			cam_tgt = cam_pivot + Vector3(
				sin(yaw_r) * cos(pitch_r),
				sin(pitch_r),
				cos(yaw_r) * cos(pitch_r)
			) * dist
		else:
			cam_tgt   = DEFAULT_CAM_POS
			cam_pivot = DEFAULT_CAM_PIVOT
		_camera.position = _camera.position.lerp(cam_tgt, LERP_SPEED * delta)
		if _camera.position.distance_to(cam_pivot) > 0.05:
			_camera.look_at(cam_pivot, Vector3.UP)


func _unhandled_input(event: InputEvent) -> void:
	# DEV: press G to fast-forward all trees by 12 months so branch growth is testable
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G:
			for i in 3:
				_trees[i].age += TreeData.SEC_PER_MONTH * 12.0
				_tree_nodes[i].rebuild()
			print("[DEV] +12 months — ages: ", _trees.map(func(t): return "%.0fm" % (t.age / TreeData.SEC_PER_MONTH)))
		return

	if event is InputEventMouseButton:
		if _held_index >= 0:
			# ── Tree focused: scroll to zoom, click to branch-select / put back ──
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if event.pressed:
						_drag_origin  = event.position
						_is_dragging  = false
					else:
						# Only treat release as a click when the mouse barely moved
						if not _is_dragging:
							_try_pick_tree(event.position)
				MOUSE_BUTTON_WHEEL_UP:
					_view_zoom = clampf(_view_zoom - ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
				MOUSE_BUTTON_WHEEL_DOWN:
					_view_zoom = clampf(_view_zoom + ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
		else:
			# ── No tree held: left-click to pick one (on release, same as held case) ──
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					_drag_origin = event.position
					_is_dragging = false
				else:
					if not _is_dragging:
						_try_pick_tree(event.position)

	elif event is InputEventMouseMotion and _held_index >= 0 \
			and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Accumulate drag; mark as drag once threshold is exceeded
		if not _is_dragging and event.position.distance_to(_drag_origin) > DRAG_THRESHOLD:
			_is_dragging = true
		if _is_dragging:
			_view_yaw   -= event.relative.x * YAW_SENSITIVITY
			_view_pitch  = clampf(_view_pitch - event.relative.y * PITCH_SENSITIVITY, -50.0, 50.0)


func _setup_camera() -> void:
	_camera = Camera3D.new()
	_camera.position = Vector3(0.0, 2.2, 4.2)
	_camera.rotation_degrees = Vector3(-15.0, 0.0, 0.0)
	add_child(_camera)


func _create_trees() -> void:
	var data_instances: Array[TreeData] = [JuniperData.new(), FicusData.new(), ChineseElmData.new()]
	var mesh_classes: Array = [JuniperMesh, FicusMesh, ChineseElmMesh]
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
		mesh_node.setup(tree, i)  # pass tree index so branch areas carry tree_index meta
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
		area.collision_layer = 1  # tree-pick layer; branch areas use layer 2
		area.collision_mask  = 0
		area.set_meta("tree_index", i)
		var shape := CollisionShape3D.new()
		var capsule := CapsuleShape3D.new()
		capsule.radius = 0.7
		capsule.height = 2.2
		shape.shape = capsule
		shape.position = Vector3(0.0, 1.1, 0.0)
		area.add_child(shape)
		mesh_node.add_child(area)


func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	canvas.add_child(TopBar.new())

	for _i in 3:
		var overlay := TreeStatOverlay.new()
		canvas.add_child(overlay)
		_tree_overlays.append(overlay)

	_action_panel = ActionPanel.new()
	_action_panel.operation_requested.connect(_do_operation)
	_action_panel.put_back_requested.connect(_put_back_tree)
	canvas.add_child(_action_panel)


# ── Actions ───────────────────────────────────────────────────────────────────

func _try_pick_tree(mouse_pos: Vector2) -> void:
	if not _camera:
		return
	var space     := get_world_3d().direct_space_state
	var origin    := _camera.project_ray_origin(mouse_pos)
	var direction := _camera.project_ray_normal(mouse_pos)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 100.0)
	query.collide_with_areas = true
	query.collide_with_bodies = false

	if _held_index >= 0:
		# Tree is held — scan for branch clicks on layer 2 only
		query.collision_mask = 2
		var result := space.intersect_ray(query)
		if not result.is_empty():
			var col = result["collider"]
			if col is Area3D and col.has_meta("branch_id") and col.has_meta("tree_index"):
				if int(col.get_meta("tree_index")) == _held_index:
					var bid: String = col.get_meta("branch_id")
					var mesh_node := _tree_nodes[_held_index]
					if mesh_node.get_selected_branch() == bid:
						mesh_node.deselect_branch()
						_action_panel.set_branch_selected(false)
					else:
						mesh_node.select_branch(bid)
						_action_panel.set_branch_selected(true)
					return
		# Missed all branches — put tree back
		_put_back_tree()
	else:
		# No tree held — scan for tree capsule on layer 1
		query.collision_mask = 1
		var result := space.intersect_ray(query)
		if result.is_empty():
			return
		var col = result["collider"]
		if col is Area3D and col.has_meta("tree_index"):
			_pick_up_tree(int(col.get_meta("tree_index")))


func _pick_up_tree(index: int) -> void:
	if _held_index >= 0:
		_tree_nodes[_held_index].deselect_branch()
		# No position target to reset — trees don't move when focused
	# Reset inspect view for the new tree
	_view_yaw   = 0.0
	_view_pitch = 0.0
	_view_zoom  = 0.0
	_held_index = index
	GameClock.pause_for_interaction()
	_action_panel.visible = true
	_action_panel.set_branch_selected(false)


func _put_back_tree() -> void:
	if _held_index >= 0:
		_tree_nodes[_held_index].deselect_branch()
		# Tree never moved, nothing to reset
	_held_index = -1
	_view_yaw   = 0.0
	_view_pitch = 0.0
	_view_zoom  = 0.0
	GameClock.resume_from_interaction()
	_action_panel.visible = false
	_action_panel.set_branch_selected(false)


func _do_operation(op: String) -> void:
	if _held_index < 0:
		return
	var tree := _trees[_held_index]
	match op:
		"Water":     tree.water()
		"Prune":
			tree.prune()
			_tree_nodes[_held_index].rebuild()
		"Fertilize": tree.fertilize()
		"Repot":     tree.repot()
		"cut_branch":
			var bid: String = _tree_nodes[_held_index].get_selected_branch()
			if bid != "":
				tree.prune_branch(bid)
				_tree_nodes[_held_index].deselect_branch()
				_tree_nodes[_held_index].rebuild()
				_action_panel.set_branch_selected(false)


func _on_month_advanced(_month: int, _year: int) -> void:
	for i in 3:
		_tree_nodes[i].rebuild()
	# Branch selection is cleared on rebuild; keep panel in sync
	_action_panel.set_branch_selected(false)
