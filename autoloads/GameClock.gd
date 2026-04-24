extends Node

signal speed_changed(speed: float)
signal month_advanced(month: int, year: int)

const SPEED_PAUSED  := 0.0
const SPEED_SLOW    := 1440.0    # 1 game day per real minute
const SPEED_NORMAL  := 8640.0    # 1 game day per 10 real seconds
const SPEED_FAST    := 86400.0   # 1 game day per real second

const MONTH_NAMES := [
	"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"
]

var speed: float = SPEED_NORMAL
var paused_by_interaction := false
var _elapsed: float = 0.0
var _last_month: int = -1


func _process(delta: float) -> void:
	if not paused_by_interaction and speed != SPEED_PAUSED:
		_elapsed += delta * speed
		var m := get_month()
		if _last_month != -1 and m != _last_month:
			month_advanced.emit(m, get_year())
		_last_month = m


func get_scaled_delta(delta: float) -> float:
	if paused_by_interaction or speed == SPEED_PAUSED:
		return 0.0
	return delta * speed


func get_second() -> int:
	return int(_elapsed) % 60


func get_minute() -> int:
	return int(_elapsed / 60.0) % 60


func get_hour() -> int:
	return int(_elapsed / 3600.0) % 24


func get_day() -> int:
	return (int(_elapsed / 86400.0) % 30) + 1


func get_month() -> int:
	return (int(_elapsed / 86400.0) % 12) + 1


func get_year() -> int:
	return int(_elapsed / 1036800.0) + 1


func get_time_string() -> String:
	return "%02d:%02d:%02d" % [get_hour(), get_minute(), get_second()]


func get_date_string() -> String:
	return "%s, Year %d" % [MONTH_NAMES[get_month() - 1], get_year()]


func get_day_fraction() -> float:
	return fmod(_elapsed, 86400.0) / 86400.0


func set_speed(new_speed: float) -> void:
	speed = new_speed
	speed_changed.emit(speed)


func pause_for_interaction() -> void:
	paused_by_interaction = true


func resume_from_interaction() -> void:
	paused_by_interaction = false

