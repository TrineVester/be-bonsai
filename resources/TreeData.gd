class_name TreeData
extends Resource

var MOISTURE_DRAIN_PER_MONTH := 0.25
var HEALTH_DAMAGE_DRY := 0.15
var HEALTH_REGEN_HEALTHY := 0.05
var REPOT_INTERVAL_MONTHS := 24

@export var species: String = "Unknown"
@export var age_months: int = 0
@export var moisture: float = 0.7       # 0.0–1.0
@export var health: float = 1.0         # 0.0–1.0
@export var fertilizer_level: float = 0.0
@export var needs_repot: bool = false
@export var months_since_pruned: int = 999
@export var months_since_fertilized: int = 3
@export var months_since_repotted: int = 0


func on_month_passed(month: int) -> void:
	age_months += 1
	months_since_pruned += 1
	months_since_fertilized += 1
	months_since_repotted += 1
	fertilizer_level = maxf(0.0, fertilizer_level - 0.3)

	moisture -= MOISTURE_DRAIN_PER_MONTH
	moisture = clampf(moisture, 0.0, 1.0)

	if moisture < 0.2:
		health -= HEALTH_DAMAGE_DRY
	elif moisture > 0.3 and moisture < 0.9:
		health = minf(1.0, health + HEALTH_REGEN_HEALTHY)

	health = clampf(health, 0.0, 1.0)

	if months_since_repotted >= REPOT_INTERVAL_MONTHS and not needs_repot:
		needs_repot = true

	# Fertilizing in winter (Dec–Feb) causes damage each month it's active
	if fertilizer_level > 0.0 and month in [12, 1, 2]:
		health -= 0.05
		health = clampf(health, 0.0, 1.0)


func water() -> void:
	moisture = minf(1.0, moisture + 0.5)


func prune(_month: int) -> void:
	months_since_pruned = 0


func fertilize(month: int) -> String:
	months_since_fertilized = 0
	fertilizer_level = minf(1.0, fertilizer_level + 0.6)
	if month in [12, 1, 2]:
		return "warning"
	return "ok"


func repot() -> void:
	months_since_repotted = 0
	needs_repot = false


func get_status_warnings() -> Array[String]:
	var warnings: Array[String] = []
	if moisture < 0.25:
		warnings.append("Needs water!")
	if health < 0.4:
		warnings.append("Health critical!")
	if months_since_pruned > 3:
		warnings.append("Due for pruning")
	if months_since_fertilized > 2:
		warnings.append("Needs fertilizer")
	if needs_repot:
		warnings.append("Needs repotting")
	return warnings
