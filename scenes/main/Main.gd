extends Node2D

const SPECIES := ["Japanese Maple", "Juniper", "Ficus"]

var _trees: Array[TreeData] = []
var _slot_moisture_bars: Array[ProgressBar] = []
var _slot_health_labels: Array[Label] = []

var _held_tree: TreeData = null

var _date_label: Label
var _month_progress_bar: ProgressBar
var _speed_buttons: Array[Button] = []

var _inspector_panel: PanelContainer
var _inspector_name_label: Label
var _moisture_bar: ProgressBar
var _health_bar: ProgressBar
var _warnings_label: Label
var _fertilize_feedback: Label


func _ready() -> void:
	_create_trees()
	_build_ui()
	GameClock.month_advanced.connect(_on_month_advanced)
	GameClock.speed_changed.connect(_on_speed_changed)
	_update_speed_buttons()


func _process(_delta: float) -> void:
	_month_progress_bar.value = GameClock.get_month_progress()


func _create_trees() -> void:
	for species: String in SPECIES:
		var tree := TreeData.new()
		tree.species = species
		tree.age_months = randi_range(12, 60)
		tree.moisture = randf_range(0.5, 0.9)
		_trees.append(tree)


# ── UI Construction ──────────────────────────────────────────────────────────

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	canvas.add_child(root)

	_build_top_bar(root)
	_build_shelf(root)
	_build_inspector(root)


func _build_top_bar(parent: Control) -> void:
	var panel := PanelContainer.new()
	parent.add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	_date_label = Label.new()
	_date_label.text = _date_text()
	_date_label.add_theme_font_size_override("font_size", 18)
	_date_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(_date_label)

	var progress_label := Label.new()
	progress_label.text = "Month progress:"
	hbox.add_child(progress_label)

	_month_progress_bar = ProgressBar.new()
	_month_progress_bar.custom_minimum_size = Vector2(120, 20)
	_month_progress_bar.max_value = 1.0
	_month_progress_bar.show_percentage = false
	hbox.add_child(_month_progress_bar)

	var sep := Control.new()
	sep.custom_minimum_size.x = 12
	hbox.add_child(sep)

	var speed_options := [["Pause", 0], ["1×", 1], ["2×", 2], ["3×", 3]]
	for entry: Array in speed_options:
		var btn := Button.new()
		btn.text = entry[0]
		btn.custom_minimum_size = Vector2(52, 32)
		btn.toggle_mode = true
		btn.pressed.connect(GameClock.set_speed.bind(entry[1]))
		hbox.add_child(btn)
		_speed_buttons.append(btn)


func _build_shelf(parent: Control) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "— Shelf —"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 24)
	vbox.add_child(hbox)

	for i in _trees.size():
		hbox.add_child(_build_tree_slot(i))


func _build_tree_slot(index: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(180, 230)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var name_label := Label.new()
	name_label.text = _trees[index].species
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(name_label)

	var visual := ColorRect.new()
	visual.color = Color(0.18, 0.45, 0.18)
	visual.custom_minimum_size = Vector2(160, 120)
	visual.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(visual)

	var moisture_bar := ProgressBar.new()
	moisture_bar.max_value = 1.0
	moisture_bar.value = _trees[index].moisture
	moisture_bar.show_percentage = false
	moisture_bar.custom_minimum_size.y = 14
	vbox.add_child(moisture_bar)
	_slot_moisture_bars.append(moisture_bar)

	var health_label := Label.new()
	health_label.text = _health_text(_trees[index].health)
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(health_label)
	_slot_health_labels.append(health_label)

	var btn := Button.new()
	btn.text = "Pick Up"
	btn.pressed.connect(_pick_up_tree.bind(index))
	vbox.add_child(btn)

	return panel


func _build_inspector(parent: Control) -> void:
	_inspector_panel = PanelContainer.new()
	_inspector_panel.visible = false
	parent.add_child(_inspector_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_inspector_panel.add_child(vbox)

	_inspector_name_label = Label.new()
	_inspector_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_inspector_name_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_inspector_name_label)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	vbox.add_child(grid)

	for stat: String in ["Moisture", "Health"]:
		var lbl := Label.new()
		lbl.text = stat + ":"
		grid.add_child(lbl)

		var bar := ProgressBar.new()
		bar.max_value = 1.0
		bar.custom_minimum_size.x = 220
		grid.add_child(bar)

		if stat == "Moisture":
			_moisture_bar = bar
		else:
			_health_bar = bar

	_warnings_label = Label.new()
	_warnings_label.add_theme_color_override("font_color", Color(1.0, 0.65, 0.0))
	_warnings_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_warnings_label)

	var ops_label := Label.new()
	ops_label.text = "Operations:"
	vbox.add_child(ops_label)

	var ops_hbox := HBoxContainer.new()
	ops_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	ops_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(ops_hbox)

	for op: String in ["Water", "Prune", "Fertilize", "Repot"]:
		var btn := Button.new()
		btn.text = op
		btn.custom_minimum_size = Vector2(80, 32)
		btn.pressed.connect(_do_operation.bind(op))
		ops_hbox.add_child(btn)

	_fertilize_feedback = Label.new()
	_fertilize_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fertilize_feedback.visible = false
	vbox.add_child(_fertilize_feedback)

	var put_back := Button.new()
	put_back.text = "← Put Back on Shelf"
	put_back.custom_minimum_size.y = 36
	put_back.pressed.connect(_put_back_tree)
	vbox.add_child(put_back)


# ── Actions ──────────────────────────────────────────────────────────────────

func _pick_up_tree(index: int) -> void:
	_held_tree = _trees[index]
	GameClock.pause_for_interaction()
	_inspector_panel.visible = true
	_fertilize_feedback.visible = false
	_refresh_inspector()


func _put_back_tree() -> void:
	_held_tree = null
	GameClock.resume_from_interaction()
	_inspector_panel.visible = false
	_refresh_shelf()


func _do_operation(op: String) -> void:
	if not _held_tree:
		return

	_fertilize_feedback.visible = false

	match op:
		"Water":
			_held_tree.water()
		"Prune":
			_held_tree.prune(GameClock.current_month)
		"Fertilize":
			var result := _held_tree.fertilize(GameClock.current_month)
			_fertilize_feedback.visible = true
			if result == "warning":
				_fertilize_feedback.text = "Warning: fertilizing in winter can harm the tree."
				_fertilize_feedback.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
			else:
				_fertilize_feedback.text = "Fertilized successfully."
				_fertilize_feedback.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
		"Repot":
			_held_tree.repot()

	_refresh_inspector()


# ── Signals ──────────────────────────────────────────────────────────────────

func _on_month_advanced(month: int, _year: int) -> void:
	for tree: TreeData in _trees:
		tree.on_month_passed(month)
	_date_label.text = _date_text()
	_refresh_shelf()
	if _held_tree:
		_refresh_inspector()


func _on_speed_changed(_speed: int) -> void:
	_update_speed_buttons()


# ── Refresh ───────────────────────────────────────────────────────────────────

func _refresh_shelf() -> void:
	for i in _trees.size():
		_slot_moisture_bars[i].value = _trees[i].moisture
		_slot_health_labels[i].text = _health_text(_trees[i].health)


func _refresh_inspector() -> void:
	if not _held_tree:
		return
	_inspector_name_label.text = "%s  (Age: %d months)" % [_held_tree.species, _held_tree.age_months]
	_moisture_bar.value = _held_tree.moisture
	_health_bar.value = _held_tree.health
	var warnings := _held_tree.get_status_warnings()
	_warnings_label.text = "  •  ".join(warnings) if warnings.size() > 0 else ""


func _update_speed_buttons() -> void:
	for i in _speed_buttons.size():
		_speed_buttons[i].button_pressed = (GameClock.speed == i)


# ── Helpers ───────────────────────────────────────────────────────────────────

func _date_text() -> String:
	return "%s, Year %d" % [GameClock.get_month_name(), GameClock.current_year]


func _health_text(health: float) -> String:
	if health > 0.8:
		return "Healthy"
	elif health > 0.5:
		return "Stressed"
	elif health > 0.2:
		return "Poor"
	return "Critical"
