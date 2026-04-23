# Bonsai Tree Care & Game Design

## Core Bonsai Operations

### 1. Pruning

- **Structural pruning**: Done once or twice a year (late winter/early spring before growth, or autumn). Removes major branches to define the tree's silhouette and style.
- **Maintenance pruning**: Done continuously through the growing season. Pinches back new shoots to keep the shape tight and encourage ramification (branching density).
- **Root pruning**: Done during repotting. Trims circling or overly long roots to keep the tree in balance with its canopy.

### 2. Wiring

- Copper or aluminum wire is wrapped around branches at a ~45° angle to bend and position them.
- Wire stays on 1–6 months depending on growth speed. Must be removed before it cuts into the bark ("wire bite").
- Done after structural pruning, when branch structure is clear.

### 3. Repotting

- Every 1–5 years depending on species and age (younger trees more frequently).
- Involves removing the tree, root-pruning, refreshing soil (coarse-grained, well-draining akadama/pumice/lava mix), and placing back in same or new pot.
- Timing is critical — usually early spring before buds break.

### 4. Watering

- The most frequent daily task. Water when the topsoil begins to dry, not on a fixed schedule.
- Technique: water thoroughly until it drains from the holes, then allow to partially dry before next watering.
- Overwatering (root rot) and underwatering are the most common causes of death.

### 5. Fertilizing

- Heavy nitrogen fertilizer in spring to encourage growth.
- Balanced fertilizer through summer.
- Low-nitrogen/high-phosphorus fertilizer in autumn to harden the tree for winter.
- No fertilizing in winter or on a sick/freshly repotted tree.

### 6. Styling Decisions

- Choosing a **style**: formal upright (chokkan), informal upright (moyogi), slanting (shakan), cascade (kengai), literati (bunjin), etc.
- Identifying the **front** of the tree — the best viewing angle.
- Deciding which branches to **sacrifice** (left to thicken the trunk) vs. **keep**.

### 7. Seasonal Dormancy

- Deciduous trees need a cold dormancy period. Outdoor species should not be kept indoors year-round.
- Tropical species need stable warmth; no frost exposure.

---

## Game Representation

### Core Gameplay Loop

| Real Operation | Game Mechanic |
|---|---|
| Structural pruning | Select-and-cut tool; removes branches permanently, changes silhouette |
| Maintenance pruning | Regular "trim" action that resets shoot growth meter |
| Wiring | Click-drag wires onto branches; angle/curve controlled by player input |
| Repotting | Periodic event with root management minigame |
| Watering | Daily resource management — moisture meter per tree |
| Fertilizing | Seasonal inventory item with stat effects |
| Dormancy | Seasonal calendar that locks certain actions in winter |

### Progression Systems

- **Ramification score**: Branches subdivide over time into finer twigs. Pruning at the right moment increases ramification level. Higher ramification = more points/aesthetics.
- **Trunk girth**: Grows slowly over seasons. Leaving a sacrifice branch accelerates growth at that junction.
- **Wire bite risk**: Wires have a visible countdown. Missing removal causes bark scarring (aesthetic penalty, or scar as a feature).
- **Health meter**: Watering/fertilizing mistakes accumulate into root rot, leaf drop, or dieback.
- **Style unlock**: The player chooses a target style at the start; deviating penalizes the score or opens an alternate style path.

### Feedback Mechanisms

- **Real-time growth simulation**: Shoots visibly extend over in-game days; dormant period resets annual growth.
- **Photo mode / judging**: End-of-season evaluation scores balance, proportion, styling fidelity (classic bonsai judging criteria: nebari/roots, trunk, branch structure, overall harmony).
- **Mistake consequences**: Overwatering causes yellowing leaves. Wrong-season pruning causes dieback on cut wounds. Wire biting leaves permanent marks (can be hidden by future bark growth).

### Design Consideration

The most interesting tension in a bonsai game is **patience vs. intervention** — the tree needs time, but incorrect timing of any operation causes setbacks. A game could represent this through a **calendar system** where every action has an optimal window, risk outside that window, and the player must learn to read the tree's state (bud swell, leaf color, soil moisture) rather than just executing on a fixed schedule.

The player can choose from three tree species at the start: **Juniper**, **Ficus**, and **Chinese Elm**. Each has different care requirements and growth characteristics. The pot is a standard **terracotta pot**, shared across all species.

The visual style is **low poly**, giving the game a clean, geometric aesthetic.
