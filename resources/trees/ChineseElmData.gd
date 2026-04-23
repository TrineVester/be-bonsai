class_name ChineseElmData
extends TreeData

# Chinese Elm: semi-deciduous, moderate difficulty, good for beginners
# Repots every 2 years, balanced water needs

func _init() -> void:
	species = "Chinese Elm"
	MOISTURE_DRAIN_PER_MONTH = 0.25   # average moisture needs
	HEALTH_DAMAGE_DRY = 0.12          # moderately sensitive
	HEALTH_REGEN_HEALTHY = 0.06       # average recovery
	REPOT_INTERVAL_MONTHS = 24        # repot every ~2 years
