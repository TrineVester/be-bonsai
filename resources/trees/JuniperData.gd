class_name JuniperData
extends TreeData

func _init() -> void:
	species = "Juniper"
	MOISTURE_DRAIN_RATE   = 0.001167  # 0.35 per 300 s — dries faster outdoors
	HEALTH_DAMAGE_RATE    = 0.000667  # 0.20 per 300 s — sensitive to dryness
	HEALTH_REGEN_RATE     = 0.000133  # 0.04 per 300 s — slow to recover
	REPOT_INTERVAL        = 10800.0   # 36 game months
