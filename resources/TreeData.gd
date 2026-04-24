class_name TreeData
extends Resource

const SEC_PER_DAY   := 86400.0
const SEC_PER_MONTH := 86400.0
const SEC_PER_YEAR  := 86400.0 * 12.0

# Species subclasses must override these in _init()
var MOISTURE_DRAIN_RATE   := 0.0
var HEALTH_DAMAGE_RATE    := 0.0
var HEALTH_REGEN_RATE     := 0.0
var FERTILIZER_DRAIN_RATE := 1.0 / (SEC_PER_DAY * 90.0)

# Pruning urgency maxes out after 3 months without pruning
var PRUNE_DUE_AFTER := SEC_PER_MONTH * 3.0
# Repotting due after 2 years by default
var REPOT_INTERVAL  := SEC_PER_YEAR * 2.0

@export var species: String = "Unknown"
@export var age: float = 0.0
@export var prune_count: int = 0
@export var moisture: float = 0.7
@export var health: float = 1.0
@export var fertilizer_level: float = 0.0
@export var needs_repot: bool = false
@export var time_since_pruned: float = 999.0
@export var time_since_fertilized: float = 900.0
@export var time_since_repotted: float = 0.0


func on_time_passed(dt: float) -> void:
	age += dt
	time_since_pruned += dt
	time_since_fertilized += dt
	time_since_repotted += dt

	fertilizer_level = maxf(0.0, fertilizer_level - FERTILIZER_DRAIN_RATE * dt)
	moisture = clampf(moisture - MOISTURE_DRAIN_RATE * dt, 0.0, 1.0)

	if moisture < 0.2:
		health -= HEALTH_DAMAGE_RATE * dt
	elif moisture > 0.3 and moisture < 0.9:
		health = minf(1.0, health + HEALTH_REGEN_RATE * dt)

	health = clampf(health, 0.0, 1.0)

	if time_since_repotted >= REPOT_INTERVAL and not needs_repot:
		needs_repot = true


func water() -> void:
	moisture = minf(1.0, moisture + 0.5)


func prune() -> void:
	time_since_pruned = 0.0
	prune_count += 1


func fertilize() -> void:
	time_since_fertilized = 0.0
	fertilizer_level = minf(1.0, fertilizer_level + 0.6)


func repot() -> void:
	time_since_repotted = 0.0
	needs_repot = false


func get_prune_urgency() -> float:
	return clampf(time_since_pruned / PRUNE_DUE_AFTER, 0.0, 1.0)


func get_repot_urgency() -> float:
	return clampf(time_since_repotted / REPOT_INTERVAL, 0.0, 1.0)
