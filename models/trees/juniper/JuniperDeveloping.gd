class_name JuniperDeveloping
extends RefCounted

# Stage 2 (12–36 months): visible primary branches, 3 clearly separated flat tiers
# foliage2 is the lighter highlight colour passed from JuniperMesh
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t   := clampf((age - 12.0) / 24.0, 0.0, 1.0)
	var h   := lerpf(1.05, 1.65, t)
	var br  := lerpf(0.058, 0.085, t)

	# S-curve trunk: lower segment straight, upper segment leaning — lean grows with age
	mesh._visual.add_child(mesh._create_trunk(h * 0.55, br, br * 0.72, bark))
	var upper := mesh._create_trunk(h * 0.50, br * 0.72, 0.030, bark)
	upper.position.y = h * 0.55 + (h * 0.50) * 0.5  # centre so bottom aligns with lower trunk top
	upper.rotation_degrees.z = lerpf(0.0, 1.8, t)
	upper.position.x = lerpf(0.0, 0.025, t)
	mesh._visual.add_child(upper)

	if t > 0.35:
		mesh._visual.add_child(mesh._create_nebari(br * 2.0, bark.darkened(0.14)))

	var blen  := lerpf(0.28, 0.54, t) * (1.0 - compact * 0.28)
	# Juniper branches tilt steeply — droop from weight then pads face upward
	var btilt := lerpf(72.0, 82.0, t) * (1.0 - compact * 0.18)
	var bsr   := lerpf(0.016, 0.024, t)
	# Lerp branch heights toward Mature values so there is no jump at stage transition
	var low_y := h * lerpf(0.40, 0.38, t)
	var mid_y := h * lerpf(0.57, 0.52, t)
	mesh._add_branch("b_low_r", 12.0, Vector3(0.0, low_y, 0.0),  90.0, btilt, blen,        bsr,        bark)
	mesh._add_branch("b_low_l", 12.0, Vector3(0.0, low_y, 0.0), 270.0, btilt, blen * 0.90, bsr,        bark)
	mesh._add_branch("b_mid_f", 18.0, Vector3(0.0, mid_y, 0.0),   0.0, btilt, blen * 0.78, bsr * 0.80, bark)
	mesh._add_branch("b_mid_b", 18.0, Vector3(0.0, mid_y, 0.0), 180.0, btilt, blen * 0.72, bsr * 0.80, bark)

	# Foliage pads sit at branch tips — inset by pad*0.5 so sphere wraps tip cleanly
	var pad := lerpf(0.28, 0.42, t) * (1.0 - compact * 0.40)
	if age >= 12.0 and not mesh._data.is_branch_pruned("b_low_r"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, low_y, 0.0),  90.0, btilt, mesh._eff_len(12.0, blen)        - pad * 0.5), pad,        0.38, foliage,  0.7))
	if age >= 12.0 and not mesh._data.is_branch_pruned("b_low_l"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, low_y, 0.0), 270.0, btilt, mesh._eff_len(12.0, blen * 0.90) - pad * 0.45), pad * 0.90, 0.38, foliage2, 0.75))
	if age >= 18.0 and not mesh._data.is_branch_pruned("b_mid_f"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, mid_y, 0.0),   0.0, btilt, mesh._eff_len(18.0, blen * 0.78) - pad * 0.38), pad * 0.75, 0.38, foliage2, 0.75))
	if age >= 18.0 and not mesh._data.is_branch_pruned("b_mid_b"):
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, mid_y, 0.0), 180.0, btilt, mesh._eff_len(18.0, blen * 0.72) - pad * 0.36), pad * 0.72, 0.38, foliage,  0.65))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 1.05, 0.0), pad * 0.50, 0.40, foliage, 0.65))
