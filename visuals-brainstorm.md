# Tree Visuals — Description & Improvement Plan

---

## How Trees Are Currently Built

All trees share the same base class (`TreeMeshBase`) and follow the same pattern:

- **Trunk** — a single `CylinderMesh` (6 radial segments, 1 ring), tapered from bottom to top with a flat `albedo_color`
- **Branches** — `CylinderMesh` nodes parented to a `Node3D` that is rotated to the right yaw + tilt; each branch tapers sharply to 25% of the base radius at the tip
- **Foliage pads** — `SphereMesh` with a flatten factor applied to the height to make disc/cloud shapes (7 radial segments, 4 rings)
- **Nebari** — a very short, wide `CylinderMesh` at the trunk base to suggest root flare (appears at Developing and Mature stages)
- **No textures** — all colour is a single flat `albedo_color` on a `StandardMaterial3D`

Each species has **4 growth stages** (Spire → Young → Developing → Mature), each in its own file:
- `juniper/JuniperSpire.gd`, `JuniperYoung.gd`, `JuniperDeveloping.gd`, `JuniperMature.gd`
- `ficus/FicusSpire.gd`, `FicusYoung.gd`, `FicusDeveloping.gd`, `FicusMature.gd`
- `elm/ChineseElmSpire.gd`, `ChineseElmYoung.gd`, `ChineseElmDeveloping.gd`, `ChineseElmMature.gd`

Stage routing is done by age in months inside the species mesh files (`JuniperMesh.gd`, etc.).

### Species character summary (current)

| Species | Trunk colour | Silhouette | Branch style |
|---|---|---|---|
| **Juniper** | Dark reddish brown `(0.28, 0.17, 0.09)` | Tall conical, stacked layers | Near-horizontal, alternating sides |
| **Ficus** | Pale grey-beige `(0.68, 0.66, 0.60)` | Wide dome | 3 radiating primaries at 120° |
| **Chinese Elm** | Warm brown `(0.42, 0.24, 0.12)` | Very flat umbrella | Many near-horizontal, high tilt |

---

## What Looks Weak Right Now

1. **Trunks are perfectly straight cylinders** — no curve, no lean, no character
2. **Branches attach to a single invisible point** — no visible fork or joint where branch meets trunk
3. **Foliage is uniform smooth spheroids** — no texture variation, no depth, no gaps between clouds
4. **All trees of the same species + stage look identical** — no per-tree variation at all
5. **Flat solid colour throughout** — no shading variation, looks like coloured plastic
6. **Nebari is barely visible** — too thin and the same hue as the trunk
7. **Species look almost the same** — only colour and silhouette differ; bark texture, foliage type, and branch ramification are the same geometry on all three
8. **Foliage does not move** — completely static even when the game is running

---

## Species Accuracy Goals

Each species should be immediately recognisable by its real-world characteristics.

### Juniper (*Juniperus*)
Real-world features to capture:
- **Bark**: deep reddish-brown, longitudinal fibrous strips — simulate with slightly darker vertical stripe variation on the trunk colour
- **Foliage type**: scale-like or needle-like, held in dense flat sprays, not round blobs — foliage pads should be very flat (flatten ≈ 0.40) and layered horizontally like shelves, not floating clouds
- **Branch structure**: strong primary branches that angle sharply downward before curving up at the tip (drooping then rising); secondary branches fan outward in one plane (the "pad" shape)
- **Silhouette**: distinctly triangular/conical overall; each foliage tier is clearly separated with visible empty space between layers
- **Deadwood (jin)**: bare bleached-grey stubs are a classic juniper feature and make it instantly recognisable
- **Colour**: foliage is deep blue-green, almost dark — noticeably darker and cooler than the other two species

### Ficus (*Ficus retusa / microcarpa*)
Real-world features to capture:
- **Bark**: smooth, pale grey, almost silver — the smoothest of the three; aerial roots on older specimens hang down from branches (a distinctive signature feature)
- **Trunk**: often very thick and dramatically buttressed at the base; surface roots spread wide and merge into the soil
- **Foliage type**: small oval glossy leaves, held in dense rounded clouds — pads should be rounder and fuller than juniper (flatten ≈ 0.75–0.85), like stacked bubbles
- **Branch structure**: shorter, more densely branched than juniper; branches radiate in all directions giving a hemispherical dome shape; branches thicker relative to their length
- **Silhouette**: compact dome, almost as wide as it is tall; the canopy has a layered-bubble texture rather than flat tiers
- **Colour**: bright fresh green, lighter and more saturated than juniper; the pale bark provides strong contrast

### Chinese Elm (*Ulmus parvifolia*)
Real-world features to capture:
- **Bark**: the most distinctive bark of the three — mottled grey/brown/orange patches where the outer bark flakes off in irregular jigsaw shapes (like a camouflage pattern); simulate with a noticeably lighter base colour and darker patches
- **Trunk**: fine taper, relatively slender even at maturity; elegant S-curve lean is very common
- **Foliage type**: tiny serrated leaves, held in very fine twiggy sprays — the fine twig ramification is the elm's signature; foliage pads should be the flattest (flatten ≈ 0.30) with the most spread and the finest-looking edge (more irregular outline)
- **Branch structure**: the most delicate branching — many thin secondary and tertiary branches fanning out from the primary; branches are longer relative to trunk height than the other two
- **Silhouette**: wide horizontal umbrella; the outermost edge of the canopy has a loose, lacy quality rather than a hard outline
- **Seasonal behaviour**: Chinese Elm is semi-deciduous — in late autumn/winter months the canopy should thin significantly or disappear entirely, leaving the elegant bare branch structure visible (this is actually a feature, not a bug)

---

## Improvement Plan

### Phase 1 — Species differentiation (highest priority)

The goal is to make each species immediately recognisable without reading a label.

- **Juniper foliage**: replace round pads with flat horizontal spray shapes — very low flatten (0.40), stacked with clear gaps between tiers; darken foliage colour to `Color(0.10, 0.28, 0.12)`
- **Juniper bark**: add 2–3 thin vertical darker-stripe `CylinderMesh` overlays along the trunk to suggest fibrous texture (very subtle, same hue but darkened 0.15)
- **Juniper jin**: add bleached dead-branch stubs at Mature stage — thin cylinders (`Color(0.78, 0.75, 0.70)`) angled downward from the lower trunk
- **Ficus aerial roots**: at Developing and Mature stage, add 1–2 thin hanging root strands (`CylinderMesh`, near-zero radius, slightly wavy via two-segment offset) dropping from low branches toward the soil
- **Ficus bubble canopy**: replace single large pads with clusters of 3 overlapping rounder spheres per zone — tighter, fuller, more hemispherical overall
- **Ficus bark colour**: lighten to near-silver `Color(0.76, 0.74, 0.70)` at Mature stage to emphasise the smooth pale trunk
- **Chinese Elm bark patches**: simulate flaky bark by adding a second `CylinderMesh` trunk overlay with `Color(0.62, 0.44, 0.22)` (the exposed inner bark orange) scaled slightly smaller than the main trunk — gives a two-tone mottled look
- **Chinese Elm foliage spread**: make pads much wider and flatter (flatten ≈ 0.30), extend the horizontal reach of the outermost pads beyond the branch tips so they hang slightly over the edge
- **Seasonal elm bare stage**: when `GameClock.get_month()` is in Nov–Feb, skip foliage pads entirely and add extra fine tertiary branch sub-segments to show the bare twig structure

### Phase 2 — Trunk character

- **S-curve / lean via two-segment trunk**: split the trunk into a lower and upper `CylinderMesh`; offset the upper segment's X/Z origin slightly to create a visible curve or lean. The offset amount scales with age.
- **More rings on trunk**: increase `rings` from 1 to 3–4 so the trunk has volume that catches light from different angles.
- **Thicker, more dramatic nebari**: widen the nebari disc and add 3–4 individual root-spur cylinders splaying out at ground level (Developing and Mature stages only).

### Phase 3 — Foliage movement (wind animation)

The foliage should gently sway to make the greenhouse feel alive. Godot has no built-in wind system for procedural meshes, but we can fake it in GDScript:

- **Approach**: in `TreeMeshBase._process()`, apply a slow sinusoidal `rotation_degrees.z` offset to each foliage pad `MeshInstance3D`. Each pad gets a slightly different phase offset so they don't all move in sync.
- **Amplitude**: very subtle — ±1.5° on foliage pads, ±0.4° on branch nodes; smaller/higher pads sway slightly more than lower ones
- **Frequency**: ~0.4–0.7 Hz base, slightly different per pad
- **Species variation**: Juniper pads are stiff and barely move (±0.8°); Ficus bubbles rock gently (±1.5°); Chinese Elm has the most movement, especially the outermost fine pads (±2.5°)
- **Implementation**: store a list of `{node, phase_offset, amplitude}` dicts during `build_tree()`; iterate in `_process()` with `Time.get_ticks_msec()`
- **Interaction boost**: when a tree is picked up or watered, temporarily increase amplitude to ±5° then damp back over ~2 seconds (suggest health/moisture feedback through motion)

### Phase 4 — Per-tree variation

- **Deterministic seed per tree**: each `TreeData` instance gets a seed integer; the mesh builder uses it to slightly randomise branch yaw offsets (±15°), branch length (±10%), and foliage pad positions (±5%).
- **Asymmetric branch counts**: Mature stage uses the seed to decide whether to place 5 or 6 primary branches, and which side gets the extra one.

### Phase 5 — Material quality (once shape is good)

- **Bark roughness**: set `roughness = 0.88` and `metallic = 0.0` on bark materials so they absorb light properly instead of looking plastic.
- **Foliage roughness + subsurface scatter**: `roughness = 0.95`, `subsurf_scatter_enabled = true`, `subsurf_scatter_strength = 0.2` to let light bleed through leaf clouds.
- **Foliage dual colour**: two-colour foliage per species — a shadow colour (darker, used on lower/inner pads) and a highlight colour (lighter, used on upper/outer pads).

---

## Implementation Order

1. **Phase 1 — species differentiation** — this is the most impactful change; each tree should look like its real-world counterpart
2. **Phase 2 — trunk character** — S-curves, root flare, deadwood
3. **Phase 3 — foliage movement** — subtle wind sway in `_process()`
4. **Phase 4 — per-tree seed variation** — no two trees the same
5. **Phase 5 — material quality** — roughness, subsurface scatter, dual-tone foliage

