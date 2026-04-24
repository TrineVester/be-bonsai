class_name TopBar
extends HBoxContainer

const SPEED_OPTIONS: Array = [["Pause", 0.0], ["Slow", 1440.0], ["Normal", 8640.0], ["Fast", 86400.0]]

var _speed_buttons: Array[Button] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	add_theme_constant_override("separation", 8)
	offset_left = 8.0
	offset_top  = 8.0

	_add_clock_card()

	var sep := Control.new()
	sep.custom_minimum_size.x = 16.0
	add_child(sep)

	_add_speed_card()

	GameClock.speed_changed.connect(_on_speed_changed)
	_update_speed_buttons()


func _add_clock_card() -> void:
	var card := _make_card()
	add_child(card)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)
	card.add_child(hbox)

	var clock := AnalogClock.new()
	clock.custom_minimum_size = Vector2(48.0, 48.0)
	hbox.add_child(clock)

	var divider := ColorRect.new()
	divider.color = Color(1.0, 1.0, 1.0, 0.12)
	divider.custom_minimum_size = Vector2(1.0, 36.0)
	hbox.add_child(divider)

	hbox.add_child(CalendarPage.new())


func _add_speed_card() -> void:
	var card := _make_card()
	add_child(card)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 4)
	card.add_child(hbox)

	var style_normal := _make_btn_style(Color(0.0, 0.0, 0.0, 0.0))
	var style_pressed := _make_btn_style(Color(1.0, 1.0, 1.0, 0.12))

	for entry: Array in SPEED_OPTIONS:
		var btn := Button.new()
		btn.text = entry[0]
		btn.custom_minimum_size = Vector2(58, 30)
		btn.toggle_mode = true
		btn.flat = true
		btn.add_theme_stylebox_override("normal",  style_normal)
		btn.add_theme_stylebox_override("hover",   style_normal)
		btn.add_theme_stylebox_override("pressed", style_pressed)
		btn.add_theme_stylebox_override("focus",   style_normal)
		btn.add_theme_color_override("font_color",         Color(1.0, 1.0, 1.0, 0.45))
		btn.add_theme_color_override("font_hover_color",   Color(1.0, 1.0, 1.0, 0.75))
		btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.00))
		btn.add_theme_color_override("font_focus_color",   Color(1.0, 1.0, 1.0, 0.45))
		btn.pressed.connect(GameClock.set_speed.bind(entry[1]))
		hbox.add_child(btn)
		_speed_buttons.append(btn)


func _make_card() -> PanelContainer:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.10, 0.82)
	style.corner_radius_top_left     = 8
	style.corner_radius_top_right    = 8
	style.corner_radius_bottom_left  = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left   = 10.0
	style.content_margin_right  = 10.0
	style.content_margin_top    = 8.0
	style.content_margin_bottom = 8.0
	card.add_theme_stylebox_override("panel", style)
	return card


func _make_btn_style(bg: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left     = 5
	style.corner_radius_top_right    = 5
	style.corner_radius_bottom_left  = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left   = 8.0
	style.content_margin_right  = 8.0
	style.content_margin_top    = 4.0
	style.content_margin_bottom = 4.0
	return style


func _on_speed_changed(_speed: float) -> void:
	_update_speed_buttons()


func _update_speed_buttons() -> void:
	for i in _speed_buttons.size():
		_speed_buttons[i].button_pressed = (GameClock.speed == SPEED_OPTIONS[i][1])
