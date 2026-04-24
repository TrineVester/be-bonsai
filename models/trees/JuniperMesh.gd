class_name JuniperMesh
extends TreeMeshBase

# Juniper: tall conical silhouette, stacked horizontal foliage layers, reddish bark

const BARK_COLOR    := Color(0.28, 0.17, 0.09)
const FOLIAGE_COLOR := Color(0.13, 0.33, 0.13)


func build_tree() -> void:
	var age     := get_age_months()
	var compact := get_compactness()
	if age < 3.0:
		JuniperSpire.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)
	elif age < 12.0:
		JuniperYoung.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)
	elif age < 36.0:
		JuniperDeveloping.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)
	else:
		JuniperMature.build(self, BARK_COLOR, FOLIAGE_COLOR, age, compact)


# Stage 0: bare seedling spire — just a thin trunk and tiny apex tuft
func _build_spire() -> void:
	_visual.add_child(_create_trunk(0.65, 0.025, 0.010, BARK_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(0.0, 0.72, 0.0), 0.10, 0.80, FOLIAGE_COLOR))


# Stage 1: thickening trunk, first hint of layered foliage
func _build_young(age: float, compact: float) -> void:
	var t := clampf((age - 3.0) / 9.0, 0.0, 1.0)
	var h := lerpf(0.65, 1.05, t)
	_visual.add_child(_create_trunk(h, lerpf(0.030, 0.058, t), lerpf(0.010, 0.024, t), BARK_COLOR))
	var r := lerpf(0.16, 0.26, t) * (1.0 - compact * 0.3)
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.70, 0.0), r,         0.72, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.90, 0.0), r * 0.60,  0.72, FOLIAGE_COLOR))


# Stage 2: visible primary branches, defined 3-tier foliage
func _build_developing(age: float, compact: float) -> void:
	var t    := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h    := lerpf(1.05, 1.65, t)
	var br   := lerpf(0.058, 0.085, t)
	_visual.add_child(_create_trunk(h, br, 0.032, BARK_COLOR))
	if t > 0.45:
		_visual.add_child(_create_nebari(br * 1.9, BARK_COLOR.darkened(0.12)))

	# Primary branches — alternating sides, near-horizontal
	var blen := lerpf(0.28, 0.52, t) * (1.0 - compact * 0.28)
	var btilt := lerpf(70.0, 80.0, t) * (1.0 - compact * 0.18)
	var bsr  := lerpf(0.016, 0.024, t)
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.35, 0.0),  90.0, btilt, blen,        bsr, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.35, 0.0), 270.0, btilt, blen * 0.90, bsr, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.54, 0.0),   0.0, btilt, blen * 0.78, bsr * 0.8, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.54, 0.0), 180.0, btilt, blen * 0.72, bsr * 0.8, BARK_COLOR))

	# Three stacked foliage tiers — classic juniper silhouette
	var pad := lerpf(0.26, 0.40, t) * (1.0 - compact * 0.40)
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.43, 0.0), pad,        0.62, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.62, 0.0), pad * 0.75, 0.62, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.80, 0.0), pad * 0.52, 0.65, FOLIAGE_COLOR))


# Stage 3: full bonsai form — two-segment trunk, 4 branch layers, 4 defined pads
func _build_mature(age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.65, 2.0, t)
	var br := lerpf(0.085, 0.105, t)

	# Two trunk segments for subtle movement
	_visual.add_child(_create_trunk(h * 0.55, br, br * 0.62, BARK_COLOR))
	var upper := _create_trunk(h * 0.50, br * 0.62, 0.026, BARK_COLOR)
	upper.position.y += h * 0.55 - (h * 0.50) * 0.5
	upper.rotation_degrees.z = 2.5
	_visual.add_child(upper)
	_visual.add_child(_create_nebari(br * 2.3, BARK_COLOR.darkened(0.15)))

	# Four branch levels — tighter with more pruning
	var blen  := lerpf(0.55, 0.68, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(74.0, 82.0, t) * (1.0 - compact * 0.18)
	var bsr   := 0.028
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.30, 0.0),  90.0, btilt,         blen,        bsr,       BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.30, 0.0), 270.0, btilt,         blen * 0.88, bsr,       BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.47, 0.0),   0.0, btilt,         blen * 0.76, bsr * 0.8, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.47, 0.0), 180.0, btilt,         blen * 0.70, bsr * 0.8, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.62, 0.0),  45.0, btilt * 0.88,  blen * 0.58, bsr * 0.65, BARK_COLOR))
	_visual.add_child(_create_branch(Vector3(0.0, h * 0.62, 0.0), 225.0, btilt * 0.88,  blen * 0.52, bsr * 0.65, BARK_COLOR))

	# Four flat layered foliage pads
	var pad := lerpf(0.40, 0.46, t) * (1.0 - compact * 0.45)
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.38, 0.0), pad,        0.54, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.55, 0.0), pad * 0.76, 0.56, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.70, 0.0), pad * 0.57, 0.60, FOLIAGE_COLOR))
	_visual.add_child(_create_foliage_pad(Vector3(0.0, h * 0.84, 0.0), pad * 0.38, 0.65, FOLIAGE_COLOR))
