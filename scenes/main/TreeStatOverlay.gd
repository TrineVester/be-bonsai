class_name TreeStatOverlay
extends PanelContainer

const STAT_NAMES  := ["Water", "Health", "Fert", "Prune", "Repot", "Wire!"]
const STAT_COLORS := [
	Color(0.25, 0.55, 1.00),
	Color(0.25, 0.85, 0.35),
	Color(1.00, 0.60, 0.20),
	Color(1.00, 0.90, 0.20),
	Color(0.70, 0.30, 1.00),
	Color(1.00, 0.30, 0.10),
]

var _bars: Array[ProgressBar] = []
var _rows: Array[HBoxContainer] = []
var _health_fill:   StyleBoxFlat = null
var _moisture_fill: StyleBoxFlat = null


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
		_rows.append(row)
		if j == 0:
			_moisture_fill = style
		elif j == 1:
			_health_fill = style


func refresh(tree: TreeData) -> void:
	var m := tree.moisture
	_bars[0].value = m
	if _moisture_fill:
		if m > 0.4:
			_moisture_fill.bg_color = Color(0.25, 0.55, 1.00).lerp(Color(0.45, 0.75, 1.00), clampf((m - 0.4) / 0.6, 0.0, 1.0))
		else:
			_moisture_fill.bg_color = Color(0.25, 0.55, 1.00).lerp(Color(1.00, 0.50, 0.10), clampf((0.4 - m) / 0.4, 0.0, 1.0))
	var h := tree.health
	_bars[1].value = h
	if _health_fill:
		if h > 0.6:
			_health_fill.bg_color = Color(0.25, 0.85, 0.35).lerp(Color(0.90, 0.85, 0.15), (1.0 - h) / 0.4)
		else:
			_health_fill.bg_color = Color(0.90, 0.85, 0.15).lerp(Color(0.90, 0.20, 0.15), (0.6 - h) / 0.6)
	_bars[2].value = tree.fertilizer_level
	_bars[3].value = tree.get_prune_urgency()
	var repot_urgency := tree.get_repot_urgency()
	_bars[4].value = repot_urgency
	_rows[4].visible = repot_urgency > 0.05
