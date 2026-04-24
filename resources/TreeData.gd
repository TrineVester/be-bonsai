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

# Per-branch state: maps branch_id → {pruned, wire_enabled, wired_yaw, wired_tilt}
@export var branch_states: Dictionary = {}

func is_branch_pruned(id: String) -> bool:
	return branch_states.get(id, {}).get("pruned", false)

func get_branch_angles(id: String, default_yaw: float, default_tilt: float) -> Array:
	var s: Dictionary = branch_states.get(id, {})
	if s.get("wire_enabled", false):
		return [s.get("wired_yaw", default_yaw), s.get("wired_tilt", default_tilt)]
	return [default_yaw, default_tilt]

func prune_branch(id: String) -> void:
	if not branch_states.has(id):
		branch_states[id] = {}
	branch_states[id]["pruned"] = true
	time_since_pruned = 0.0
	prune_count += 1
	var m := GameClock.get_month()
	if m in [6, 7, 8]:
		health = maxf(0.0, health - 0.03)


func on_time_passed(dt: float) -> void:
	age += dt
	time_since_pruned += dt
	time_since_fertilized += dt
	time_since_repotted += dt

	fertilizer_level = maxf(0.0, fertilizer_level - FERTILIZER_DRAIN_RATE * dt)
	moisture = clampf(moisture - MOISTURE_DRAIN_RATE * dt, 0.0, 1.0)

	if moisture < 0.2:
		health -= HEALTH_DAMAGE_RATE * dt
	elif moisture >= 0.25 and moisture < 0.95:
		health = minf(1.0, health + HEALTH_REGEN_RATE * dt)

	health = clampf(health, 0.0, 1.0)

	if time_since_repotted >= REPOT_INTERVAL and not needs_repot:
		needs_repot = true


func water() -> void:
	moisture = minf(1.0, moisture + 0.5)


func prune() -> void:
	time_since_pruned = 0.0
	prune_count += 1
	# Pruning in summer (peak growth) stresses the tree slightly
	var m := GameClock.get_month()
	if m in [6, 7, 8]:
		health = maxf(0.0, health - 0.04)


func fertilize() -> void:
	time_since_fertilized = 0.0
	# Fertilizing in winter is mostly wasted — tree cannot absorb nutrients
	var m := GameClock.get_month()
	if m in [12, 1, 2]:
		fertilizer_level = minf(1.0, fertilizer_level + 0.15)
	else:
		fertilizer_level = minf(1.0, fertilizer_level + 0.6)


func repot() -> void:
	time_since_repotted = 0.0
	needs_repot = false
	# Repotting outside early spring (months 2–4) causes slight stress
	var m := GameClock.get_month()
	if not m in [2, 3, 4]:
		health = maxf(0.0, health - 0.06)


func get_prune_urgency() -> float:
	return clampf(time_since_pruned / PRUNE_DUE_AFTER, 0.0, 1.0)


func get_repot_urgency() -> float:
	return clampf(time_since_repotted / REPOT_INTERVAL, 0.0, 1.0)
