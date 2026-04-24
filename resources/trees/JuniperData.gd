class_name JuniperData
extends TreeData

func _init() -> void:
	species = "Juniper"
	MOISTURE_DRAIN_RATE = 0.75 / (SEC_PER_DAY * 0.7)   # drains in 0.7 days
	HEALTH_DAMAGE_RATE  = 0.30 / SEC_PER_DAY            # more sensitive to dryness
	HEALTH_REGEN_RATE   = 0.06 / SEC_PER_DAY            # slow to recover
	REPOT_INTERVAL      = SEC_PER_YEAR * 3.0             # repot every 3 years
