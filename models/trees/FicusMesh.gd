class_name FicusMesh
extends TreeMeshBase

# Ficus: smooth pale gray bark, wide dome canopy, 3 radiating primary branches

const BARK_COLOR    := Color(0.68, 0.66, 0.60)
const FOLIAGE_COLOR := Color(0.22, 0.47, 0.18)


func build_tree() -> void:
	var age     := get_age_months()
	var compact := get_compactness()
	if age < 3.0:
		FicusSpire.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)
	elif age < 12.0:
		FicusYoung.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)
	elif age < 36.0:
		FicusDeveloping.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)
	else:
		FicusMature.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)


func _build_spire() -> void:
	_visual.add_child(_create_trunk(0.55, 0.022, 0.012, BARK_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(0.0, 0.62, 0.0), 0.09, 0.90, FOLIAGE_COLOR))


func _build_young(age: float, compact: float) -> void:
	var t := clampf((age - 3.0) / 9.0, 0.0, 1.0)
	var h := lerpf(0.55, 0.98, t)
	_visual.add_child(_create_trunk(h, lerpf(0.025, 0.054, t), lerpf(0.012, 0.026, t), BARK_COLOR))
	var r := lerpf(0.15, 0.28, t) * (1.0 - compact * 0.30)
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.88, 0.0), r, 0.85, FOLIAGE_COLOR))
	if t > 0.4:
		_visual.add_child(_create_foliage_pad(Vector3(-0.18 * t, h * 0.76, 0.06), r * 0.62, 0.85, FOLIAGE_COLOR))
		_visual.add_child(_create_foliage_pad(Vector3( 0.18 * t, h * 0.76, -0.06), r * 0.62, 0.85, FOLIAGE_COLOR))


func _build_developing(age: float, compact: float) -> void:
	var t  := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h  := lerpf(0.98, 1.55, t)
	var br := lerpf(0.054, 0.085, t)
	_visual.add_child(_create_trunk(h, br, 0.034, BARK_COLOR))
	if t > 0.40:
		_visual.add_child(_create_nebari(br * 1.75, BARK_COLOR.darkened(0.06)))

	# Three radiating primary branches — ficus spreads wide
	var blen  := lerpf(0.32, 0.55, t) * (1.0 - compact * 0.25)
	var btilt := lerpf(62.0, 76.0, t) * (1.0 - compact * 0.20)
	var bsr   := lerpf(0.018, 0.026, t)
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.50, 0.0),   0.0, btilt, blen,        bsr,       BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.50, 0.0), 120.0, btilt, blen,        bsr,       BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.50, 0.0), 240.0, btilt, blen * 0.90, bsr,       BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.68, 0.0),  60.0, btilt * 0.85, blen * 0.68, bsr * 0.72, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.68, 0.0), 180.0, btilt * 0.85, blen * 0.62, bsr * 0.72, BARK_COLOR))

	var pad  := lerpf(0.28, 0.40, t) * (1.0 - compact * 0.42)
	var sp   := pad * 0.65
	_visual.add_child(_create_foliage_pad(Vector3(  0.0, h * 0.75, 0.0),   pad,        0.68, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3( -sp,  h * 0.64, 0.06),  pad * 0.76, 0.68, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(  sp,  h * 0.64, -0.06), pad * 0.76, 0.68, FOLIAGE_COLOR))


func _build_mature(age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.55, 1.80, t)
	var br := lerpf(0.085, 0.108, t)
	_visual.add_child(_create_trunk(h, br, 0.032, BARK_COLOR))
	_visual.add_child(_create_nebari(br * 2.1, BARK_COLOR.darkened(0.08)))

	# Six branches: 3 primary + 3 secondary — dome silhouette
	var blen  := lerpf(0.58, 0.72, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(78.0, 86.0, t) * (1.0 - compact * 0.18)
	var bsr   := 0.028
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.42, 0.0),   0.0, btilt,         blen,        bsr,        BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.42, 0.0), 120.0, btilt,         blen,        bsr,        BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.42, 0.0), 240.0, btilt,         blen,        bsr,        BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.62, 0.0),  60.0, btilt * 0.78,  blen * 0.70, bsr * 0.72, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.62, 0.0), 180.0, btilt * 0.78,  blen * 0.70, bsr * 0.72, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.62, 0.0), 300.0, btilt * 0.78,  blen * 0.65, bsr * 0.72, BARK_COLOR))

	# Dome canopy — overlapping round-ish pads
	var pad  := lerpf(0.42, 0.50, t) * (1.0 - compact * 0.45)
	var sp   := pad * 0.72
	_visual.add_child(_create_foliage_pad(Vector3(  0.0, h * 0.78, 0.0),    pad,        0.65, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3( -sp,  h * 0.67, 0.06),   pad * 0.80, 0.68, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(  sp,  h * 0.67, -0.06),  pad * 0.80, 0.68, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(sp * 0.55,  h * 0.64,  sp * 0.85), pad * 0.68, 0.68, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(-sp * 0.55, h * 0.64, -sp * 0.85), pad * 0.68, 0.68, FOLIAGE_COLOR))
