class_name ChineseElmData
extends TreeData

func _init() -> void:
	species = "Chinese Elm"
	MOISTURE_DRAIN_RATE   = 0.000833  # 0.25 per 300 s — balanced moisture
	HEALTH_DAMAGE_RATE    = 0.000400  # 0.12 per 300 s — moderately sensitive
	HEALTH_REGEN_RATE     = 0.000200  # 0.06 per 300 s — average recovery
	REPOT_INTERVAL        = 7200.0    # 24 game months
