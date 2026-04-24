class_name FicusData
extends TreeData

func _init() -> void:
	species = "Ficus"
	MOISTURE_DRAIN_RATE = 0.75 / (SEC_PER_DAY * 1.5)   # drains in 1.5 days
	HEALTH_DAMAGE_RATE  = 0.10 / SEC_PER_DAY            # tolerant of dry spells
	HEALTH_REGEN_RATE   = 0.16 / SEC_PER_DAY            # recovers quickly
	REPOT_INTERVAL      = SEC_PER_YEAR * 2.0             # repot every 2 years
