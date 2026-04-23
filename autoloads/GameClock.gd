extends Node

signal month_advanced(month: int, year: int)
signal speed_changed(speed: int)

# Time scale: at speed 1, 1 real second = 1 game minute.
# One game day (1440 minutes) = one bonsai month.
const MINUTES_PER_MONTH := 1440.0

const SPEED_PAUSED := 0
const SPEED_NORMAL := 1
const SPEED_DOUBLE := 2
const SPEED_TRIPLE := 3

const MONTH_NAMES := [
	"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"
]

var speed: int = SPEED_NORMAL
var paused_by_interaction := false

var _accumulated_minutes: float = 0.0
var current_month: int = 3  # Start in March
var current_year: int = 1


func _process(delta: float) -> void:
	if speed == SPEED_PAUSED or paused_by_interaction:
		return

	_accumulated_minutes += delta * float(speed)

	while _accumulated_minutes >= MINUTES_PER_MONTH:
		_accumulated_minutes -= MINUTES_PER_MONTH
		_advance_month()


func _advance_month() -> void:
	current_month += 1
	if current_month > 12:
		current_month = 1
		current_year += 1
	month_advanced.emit(current_month, current_year)


func set_speed(new_speed: int) -> void:
	speed = new_speed
	speed_changed.emit(speed)


func pause_for_interaction() -> void:
	paused_by_interaction = true


func resume_from_interaction() -> void:
	paused_by_interaction = false


func get_month_progress() -> float:
	return _accumulated_minutes / MINUTES_PER_MONTH


func get_month_name() -> String:
	return MONTH_NAMES[current_month - 1]
