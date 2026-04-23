class_name JuniperData
extends TreeData

# Juniper: outdoor conifer, slow grower, sensitive to overwatering
# Repots every 3 years, dries out faster than tropical species

func _init() -> void:
	species = "Juniper"
	MOISTURE_DRAIN_PER_MONTH = 0.35   # dries out faster outdoors
	HEALTH_DAMAGE_DRY = 0.20          # more sensitive to dryness than ficus
	HEALTH_REGEN_HEALTHY = 0.04       # slow to recover
	REPOT_INTERVAL_MONTHS = 36        # repot every ~3 years
