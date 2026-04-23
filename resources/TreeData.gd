class_name TreeData
extends Resource

# Per-second rates. At speed 1×, one notional "game month" ≈ 300 real seconds,
# so a full moisture drain takes ~20 minutes and is observable without being tedious.
var MOISTURE_DRAIN_RATE   := 0.000833   # 0.25 per 300 s
var HEALTH_DAMAGE_RATE    := 0.000500   # per second when dry
var HEALTH_REGEN_RATE     := 0.000167   # per second in healthy moisture range
var FERTILIZER_DRAIN_RATE := 0.001000   # 0.30 per 300 s

var PRUNE_DUE_AFTER := 900.0    # 3 game months until pruning urgency maxes out
var REPOT_INTERVAL  := 7200.0   # 24 game months between repottings

@export var species: String = "Unknown"
@export var age: float = 0.0
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
