class_name ActionPanel
extends PanelContainer

signal operation_requested(op: String)
signal put_back_requested


func _ready() -> void:
	visible = false
	anchor_left   = 0.0
	anchor_right  = 1.0
	anchor_top    = 1.0
	anchor_bottom = 1.0
	offset_top    = -56.0
	offset_bottom = -4.0

	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)

	for op: String in ["Water", "Prune", "Fertilize", "Repot"]:
		var btn := Button.new()
		btn.text = op
		btn.custom_minimum_size = Vector2(80, 36)
		btn.pressed.connect(operation_requested.emit.bind(op))
		hbox.add_child(btn)

	var put_back := Button.new()
	put_back.text = "← Put Back"
	put_back.custom_minimum_size = Vector2(90, 36)
	put_back.pressed.connect(put_back_requested.emit)
	hbox.add_child(put_back)
