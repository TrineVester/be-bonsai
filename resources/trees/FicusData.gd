class_name FicusData
extends TreeData

# Ficus: tropical indoor tree, forgiving and fast-growing
# Repots every 2 years, handles irregular watering well

func _init() -> void:
	species = "Ficus"
	self.MOISTURE_DRAIN_PER_MONTH = 0.20   # stable indoors, dries slower
	self.HEALTH_DAMAGE_DRY = 0.10          # more tolerant of dry spells
	self.HEALTH_REGEN_HEALTHY = 0.08       # recovers quickly
	self.REPOT_INTERVAL_MONTHS = 24        # repot every ~2 years
