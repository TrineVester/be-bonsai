class_name ChineseElmData
extends TreeData

# Chinese Elm: semi-deciduous, moderate difficulty, good for beginners
# Repots every 2 years, balanced water needs

func _init() -> void:
	species = "Chinese Elm"
	self.MOISTURE_DRAIN_PER_MONTH = 0.25   # average moisture needs
	self.HEALTH_DAMAGE_DRY = 0.12          # moderately sensitive
	self.HEALTH_REGEN_HEALTHY = 0.06       # average recovery
	self.REPOT_INTERVAL_MONTHS = 24        # repot every ~2 years
