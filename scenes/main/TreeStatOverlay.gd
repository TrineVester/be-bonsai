class_name TreeStatOverlay
extends PanelContainer

const STAT_NAMES  := ["Water", "Health", "Fert", "Prune", "Repot"]
const STAT_COLORS := [
	Color(0.25, 0.55, 1.00),
	Color(0.25, 0.85, 0.35),
	Color(1.00, 0.60, 0.20),
	Color(1.00, 0.90, 0.20),
	Color(0.70, 0.30, 1.00),
]

var _bars: Array[ProgressBar] = []


func _ready() -> void:
	custom_minimum_size = Vector2(136.0, 0.0)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	add_child(vbox)

	for j in STAT_NAMES.size():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		vbox.add_child(row)

		var lbl := Label.new()
		lbl.text = STAT_NAMES[j]
		lbl.custom_minimum_size.x = 38.0
		lbl.add_theme_font_size_override("font_size", 10)
		row.add_child(lbl)

		var bar := ProgressBar.new()
		bar.max_value = 1.0
		bar.custom_minimum_size = Vector2(76.0, 10.0)
		bar.show_percentage = false
		var style := StyleBoxFlat.new()
		style.bg_color = STAT_COLORS[j]
		bar.add_theme_stylebox_override("fill", style)
		row.add_child(bar)

		_bars.append(bar)


func refresh(tree: TreeData) -> void:
	_bars[0].value = tree.moisture
	_bars[1].value = tree.health
	_bars[2].value = tree.fertilizer_level
	_bars[3].value = tree.get_prune_urgency()
	_bars[4].value = tree.get_repot_urgency()
