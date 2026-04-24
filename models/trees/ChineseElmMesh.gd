class_name ChineseElmMesh
extends TreeMeshBase

# Chinese Elm: wide flat umbrella canopy, reddish flaky bark, many near-horizontal branches

const BARK_COLOR    := Color(0.42, 0.24, 0.12)
const FOLIAGE_COLOR := Color(0.27, 0.50, 0.20)


func build_tree() -> void:
	var age     := get_age_months()
	var compact := get_compactness()
	if age < 3.0:
		ChineseElmSpire.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)
	elif age < 12.0:
		ChineseElmYoung.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)
	elif age < 36.0:
		ChineseElmDeveloping.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)
	else:
		ChineseElmMature.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)


func _build_spire() -> void:
	_visual.add_child(_create_trunk(0.60, 0.022, 0.010, BARK_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(0.0, 0.67, 0.0), 0.09, 0.85, FOLIAGE_COLOR))


func _build_young(age: float, compact: float) -> void:
	var t := clampf((age - 3.0) / 9.0, 0.0, 1.0)
	var h := lerpf(0.60, 1.02, t)
	_visual.add_child(_create_trunk(h, lerpf(0.025, 0.052, t), lerpf(0.010, 0.022, t), BARK_COLOR))
	var r := lerpf(0.14, 0.26, t) * (1.0 - compact * 0.28)
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.86, 0.0), r, 0.80, FOLIAGE_COLOR))
	if t > 0.45:
		_visual.add_child(_create_foliage_pad(Vector3(-0.16 * t, h * 0.75, 0.08), r * 0.64, 0.80, FOLIAGE_COLOR))
		_visual.add_child(_create_foliage_pad(Vector3( 0.16 * t, h * 0.75, -0.08), r * 0.64, 0.80, FOLIAGE_COLOR))


func _build_developing(age: float, compact: float) -> void:
	var t  := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h  := lerpf(1.02, 1.58, t)
	var br := lerpf(0.052, 0.082, t)
	_visual.add_child(_create_trunk(h, br, 0.032, BARK_COLOR))
	if t > 0.40:
		_visual.add_child(_create_nebari(br * 1.80, BARK_COLOR.darkened(0.10)))

	# Elm branches outward very horizontally — flat umbrella character
	var blen  := lerpf(0.38, 0.64, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(72.0, 84.0, t) * (1.0 - compact * 0.18)
	var bsr   := lerpf(0.018, 0.025, t)
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.44, 0.0),  90.0, btilt, blen,        bsr,       BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.44, 0.0), 270.0, btilt, blen * 0.95, bsr,       BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.60, 0.0),   0.0, btilt, blen * 0.80, bsr * 0.8, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.60, 0.0), 180.0, btilt, blen * 0.75, bsr * 0.8, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.72, 0.0),  45.0, btilt * 0.88, blen * 0.62, bsr * 0.65, BARK_COLOR))

	# Wide flat canopy — very low flatten factor
	var pad := lerpf(0.28, 0.40, t) * (1.0 - compact * 0.48)
	var sp  := pad * 0.95
	_visual.add_child(_create_foliage_pad(Vector3( 0.0, h * 0.72,  0.0),    pad,        0.52, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(-sp,  h * 0.62,  0.0),    pad * 0.82, 0.52, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3( sp,  h * 0.62,  0.0),    pad * 0.82, 0.52, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3( 0.0, h * 0.62,  sp * 0.7), pad * 0.68, 0.54, FOLIAGE_COLOR))


func _build_mature(age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.58, 1.82, t)
	var br := lerpf(0.082, 0.108, t)
	_visual.add_child(_create_trunk(h, br, 0.030, BARK_COLOR))
	_visual.add_child(_create_nebari(br * 2.35, BARK_COLOR.darkened(0.14)))

	# Many near-horizontal branches — elm has fine, dense branching
	var blen  := lerpf(0.66, 0.82, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(82.0, 88.0, t) * (1.0 - compact * 0.16)
	var bsr   := 0.026
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.36, 0.0),  90.0, btilt,         blen,        bsr,        BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.36, 0.0), 270.0, btilt,         blen,        bsr,        BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.50, 0.0),   0.0, btilt,         blen * 0.85, bsr,        BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.50, 0.0), 180.0, btilt,         blen * 0.85, bsr,        BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.62, 0.0),  45.0, btilt * 0.88,  blen * 0.70, bsr * 0.78, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.62, 0.0), 225.0, btilt * 0.88,  blen * 0.68, bsr * 0.78, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.70, 0.0), 135.0, btilt * 0.75,  blen * 0.55, bsr * 0.62, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.70, 0.0), 315.0, btilt * 0.75,  blen * 0.52, bsr * 0.62, BARK_COLOR))

	# Very wide flat umbrella canopy — Chinese Elm signature look
	var pad := lerpf(0.40, 0.48, t) * (1.0 - compact * 0.52)
	var sp  := pad * 1.12
	_visual.add_child(_create_foliage_pad(Vector3(  0.0,  h * 0.75,  0.0),      pad * 0.82, 0.48, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3( -sp,   h * 0.64,  0.0),      pad,        0.48, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(  sp,   h * 0.64,  0.0),      pad,        0.48, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(  0.0,  h * 0.64,  sp * 0.85), pad * 0.84, 0.50, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(  0.0,  h * 0.64, -sp * 0.85), pad * 0.84, 0.50, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3( -sp * 0.7, h * 0.61,  sp * 0.55), pad * 0.66, 0.52, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(  sp * 0.7, h * 0.61, -sp * 0.55), pad * 0.66, 0.52, FOLIAGE_COLOR))
