extends Node3D

const GreenhouseEnvironment := preload("res://scenes/greenhouse/GreenhouseEnvironment.gd")
const ShelfMesh := preload("res://models/environment/ShelfMesh.gd")

const TREE_POSITIONS   := [Vector3(-2.2, 0.2, 0.0), Vector3(0.0, 0.2, 0.0), Vector3(2.2, 0.2, 0.0)]
const FOCUSED_POSITION := Vector3(0.0, 0.6, 1.0)
const LERP_SPEED       := 6.0

var _trees:        Array[TreeData] = []
var _tree_nodes:   Array[Node3D]   = []
var _tree_targets: Array[Vector3]  = []
var _pot_nodes:    Array[Node3D]   = []

var _held_index: int = -1

var _tree_overlays: Array[TreeStatOverlay] = []
var _action_panel:  ActionPanel


func _ready() -> void:
	add_child(GreenhouseEnvironment.new())
	add_child(ShelfMesh.new())
	_setup_camera()
	_create_trees()
	_build_ui()


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
			_tree_overlays[i].refresh(_trees[i])


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_pick_tree(event.position)


func _setup_camera() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 2.2, 4.2)
	camera.rotation_degrees = Vector3(-15.0, 0.0, 0.0)
	add_child(camera)


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
