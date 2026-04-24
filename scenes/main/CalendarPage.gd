class_name CalendarPage
extends VBoxContainer

const SEASON_NAMES := ["Winter", "Spring", "Summer", "Autumn"]

var _time_label: Label
var _date_label: Label
var _sub_label: Label


func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 1)

	_time_label = Label.new()
	_time_label.add_theme_font_size_override("font_size", 18)
	_time_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.95))
	add_child(_time_label)

	_date_label = Label.new()
	_date_label.add_theme_font_size_override("font_size", 12)
	_date_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.75))
	add_child(_date_label)

	_sub_label = Label.new()
	_sub_label.add_theme_font_size_override("font_size", 10)
	_sub_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.45))
	add_child(_sub_label)


func _process(_delta: float) -> void:
	_time_label.text = "%02d:%02d" % [GameClock.get_hour(), GameClock.get_minute()]
	_date_label.text = "%s %d" % [GameClock.MONTH_NAMES[GameClock.get_month() - 1], GameClock.get_day()]
	_sub_label.text  = "%s  ·  Year %d" % [_get_season_name(), GameClock.get_year()]


func _get_season_name() -> String:
	var m := GameClock.get_month()
	if m in [12, 1, 2]: return SEASON_NAMES[0]
	if m in [3, 4, 5]:  return SEASON_NAMES[1]
	if m in [6, 7, 8]:  return SEASON_NAMES[2]
	return SEASON_NAMES[3]
