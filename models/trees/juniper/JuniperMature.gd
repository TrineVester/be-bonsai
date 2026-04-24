class_name JuniperMature
extends RefCounted

# Stage 3 (36+ months): full bonsai — S-curve trunk, dramatic nebari, 4 flat tiers, jin deadwood
# foliage2 is the lighter highlight colour passed from JuniperMesh
static func build(mesh: TreeMeshBase, bark: Color, foliage: Color, foliage2: Color, age: float, compact: float) -> void:
	var t  := clampf((age - 36.0) / 36.0, 0.0, 1.0)
	var h  := lerpf(1.65, 2.0, t)
	var br := lerpf(0.085, 0.108, t)

	# Lower trunk — thick, strong
	mesh._visual.add_child(mesh._create_trunk(h * 0.52, br, br * 0.65, bark))
	# Upper trunk — leans slightly (classic juniper S-curve)
	var upper := mesh._create_trunk(h * 0.52, br * 0.65, 0.026, bark)
	upper.position.y = h * 0.52 - (h * 0.52) * 0.5
	upper.rotation_degrees.z = 3.2
	upper.position.x = 0.04
	mesh._visual.add_child(upper)
	mesh._visual.add_child(mesh._create_nebari(br * 2.6, bark.darkened(0.16)))

	# Jin deadwood stubs — bleached grey, lower trunk, defining Juniper character
	mesh._visual.add_child(mesh._create_jin(Vector3(0.0, h * 0.18, 0.0), 160.0, 75.0, 0.18))
	mesh._visual.add_child(mesh._create_jin(Vector3(0.0, h * 0.25, 0.0),  35.0, 70.0, 0.12))

	var blen  := lerpf(0.55, 0.70, t) * (1.0 - compact * 0.30)
	var btilt := lerpf(76.0, 84.0, t) * (1.0 - compact * 0.18)
	var bsr   := 0.028
	mesh._add_branch("b_low_r",  12.0, Vector3(0.0, h * 0.30, 0.0),  90.0, btilt,        blen,        bsr,        bark)
	mesh._add_branch("b_low_l",  12.0, Vector3(0.0, h * 0.30, 0.0), 270.0, btilt,        blen * 0.88, bsr,        bark)
	mesh._add_branch("b_mid_f",  18.0, Vector3(0.0, h * 0.46, 0.0),   0.0, btilt,        blen * 0.76, bsr * 0.80, bark)
	mesh._add_branch("b_mid_b",  18.0, Vector3(0.0, h * 0.46, 0.0), 180.0, btilt,        blen * 0.70, bsr * 0.80, bark)
	mesh._add_branch("b_up_45",  30.0, Vector3(0.0, h * 0.61, 0.0),  45.0, btilt * 0.88, blen * 0.58, bsr * 0.65, bark)
	mesh._add_branch("b_up_225", 30.0, Vector3(0.0, h * 0.61, 0.0), 225.0, btilt * 0.88, blen * 0.52, bsr * 0.65, bark)

	# Foliage pads at branch tips — one per branch, plus fixed apex
	var pad := lerpf(0.40, 0.48, t) * (1.0 - compact * 0.45)
	if age >= 12.0:
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.30, 0.0),  90.0, btilt,        blen),        pad,        0.36, foliage,  0.6))
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.30, 0.0), 270.0, btilt,        blen * 0.88), pad * 0.88, 0.36, foliage2, 0.65))
	if age >= 18.0:
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.46, 0.0),   0.0, btilt,        blen * 0.76), pad * 0.76, 0.36, foliage2, 0.65))
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.46, 0.0), 180.0, btilt,        blen * 0.70), pad * 0.70, 0.36, foliage,  0.6))
	if age >= 30.0:
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.61, 0.0),  45.0, btilt * 0.88, blen * 0.58), pad * 0.56, 0.38, foliage,  0.7))
		mesh._visual.add_child(mesh._create_foliage_pad(mesh._branch_tip(Vector3(0.0, h * 0.61, 0.0), 225.0, btilt * 0.88, blen * 0.52), pad * 0.52, 0.38, foliage2, 0.6))
	mesh._visual.add_child(mesh._create_foliage_pad(Vector3(0.0, h * 0.92, 0.0), pad * 0.35, 0.40, foliage2, 0.6))
