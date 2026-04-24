class_name ChineseElmData
extends TreeData

func _init() -> void:
	species = "Chinese Elm"
	MOISTURE_DRAIN_RATE = 0.75 / SEC_PER_DAY            # drains in 1 day
	HEALTH_DAMAGE_RATE  = 0.20 / SEC_PER_DAY            # moderately sensitive
	HEALTH_REGEN_RATE   = 0.12 / SEC_PER_DAY            # average recovery
	REPOT_INTERVAL      = SEC_PER_YEAR * 2.0             # repot every 2 years
