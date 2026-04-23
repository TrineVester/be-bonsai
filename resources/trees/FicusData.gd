class_name FicusData
extends TreeData

# Ficus: tropical indoor tree, forgiving and fast-growing
# Repots every 2 years, handles irregular watering well

func _init() -> void:
	species = "Ficus"
	MOISTURE_DRAIN_PER_MONTH = 0.20   # stable indoors, dries slower
	HEALTH_DAMAGE_DRY = 0.10          # more tolerant of dry spells
	HEALTH_REGEN_HEALTHY = 0.08       # recovers quickly
	REPOT_INTERVAL_MONTHS = 24        # repot every ~2 years
