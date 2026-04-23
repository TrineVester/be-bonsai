class_name FicusData
extends TreeData

func _init() -> void:
	species = "Ficus"
	MOISTURE_DRAIN_RATE   = 0.000667  # 0.20 per 300 s — stable indoors
	HEALTH_DAMAGE_RATE    = 0.000333  # 0.10 per 300 s — tolerant of dry spells
	HEALTH_REGEN_RATE     = 0.000267  # 0.08 per 300 s — recovers quickly
	REPOT_INTERVAL        = 7200.0    # 24 game months
