# OpenSCAD Portfolio — Computational CAD Engineer

### Prepared for: micro1 — Computational CAD Engineer (OpenSCAD) Role

---

## About This Portfolio

This portfolio contains 10 original OpenSCAD projects built to demonstrate
full proficiency in every skill listed in the micro1 Computational CAD Engineer
job description. Each project is a standalone `.scad` file — fully parametric,
heavily commented, and structured to show both technical depth and code clarity.

Every project maps explicitly to one or more JD requirements. Comments inside
each file label which JD skill each section demonstrates, making it easy for
reviewers to verify coverage.

---

## Quick Reference — JD Skills Coverage

| JD Requirement                    | Projects Covering It   |
| --------------------------------- | ---------------------- |
| OpenSCAD Syntax                   | All projects           |
| Constants & Operators             | 01, 02, 03, 05, 08     |
| Special Variables ($fn, $fa, $fs) | All projects           |
| Modifier Characters (#, %, \*, !) | 08, 09, 10             |
| 2D Objects                        | 02, 03, 04, 06, 09     |
| 3D Objects                        | 01, 03, 04, 07, 10     |
| Transformations                   | All projects           |
| Boolean Operations                | All projects           |
| linear_extrude                    | 02, 04, 06, 08, 09     |
| rotate_extrude                    | 02, 05, 08, 10         |
| minkowski()                       | 05, 08                 |
| hull()                            | 05, 07, 08             |
| 3D from 2D Shadows                | 06, 09                 |
| Lists                             | 03, 04, 06, 07, 08     |
| List Comprehensions               | 03, 04, 07, 08, 09, 10 |
| Flow Control                      | All projects           |
| Type Test Functions               | 03, 06, 07, 08, 09, 10 |
| Recursion                         | 10                     |

---

## Projects

---

### Project 01 — Parametric Bolt & Nut Generator

**File:** `project_01_bolt_and_nut.scad`

A fully parametric fastener system modelling an M8 bolt, matching nut, and
washer. Change `bolt_diameter` at the top of the file and every dimension —
thread pitch, head size, nut clearance — updates automatically.

**JD Skills Demonstrated:**

- `Syntax` — clean, readable module structure throughout
- `Constants & Operators` — all dimensions derived mathematically from `bolt_diameter`
- `Special Variables` — `$fn` controls circular geometry resolution
- `3D Objects` — `cylinder()`, `sphere()` used as core primitives
- `Transformations` — `translate()`, `rotate()`, `mirror()`
- `Boolean Operations` — `difference()` for thread grooves and holes, `union()` for assembly, `intersection()` for chamfered tip
- `Flow Control` — `if/else` switches between hex and round head types; `for` loop generates thread helix
- `Modifier Characters` — `#` modifier documented for thread debugging

**Key Techniques:**
Thread simulation using a `for` loop of angled cylinder cuts. Bolt head type
selected via `if/else` — set `bolt_head_type = "hex"` or `"round"`.

**How to Use:**

```
bolt_diameter = 8;       // change this — everything updates
bolt_head_type = "hex";  // or "round"
bolt_length = 40;
```

---

### Project 02 — Geometric Lampshade

**File:** `project_02_geometric_lampshade.scad`

A decorative lampshade built entirely by sweeping 2D profiles into 3D.
The main body is a `rotate_extrude` of a polygon silhouette. The base collar
uses `linear_extrude` with twist. The rim detail is a torus built from
`rotate_extrude` of an offset circle.

**JD Skills Demonstrated:**

- `rotate_extrude` — lampshade body swept 360° from 2D polygon profile
- `linear_extrude with twist` — base collar spirals as it rises
- `2D Objects` — `polygon()` defines the shade silhouette; `circle()` for torus cross-section
- `Boolean Operations` — `difference()` punches vent slots through shade wall
- `Flow Control` — `for` loop places 12 evenly-spaced vent cutouts
- `Special Variables` — `$fn`, `$fa` for smooth curves

**Key Techniques:**
The entire lampshade body comes from one 2D polygon. Change the polygon
points and the shape changes completely — this is the power of `rotate_extrude`.
A torus (the rim ring) is built by revolving a `circle()` offset from the axis.

**How to Use:**

```
shade_top_r = 12;       // opening radius
shade_bottom_r = 55;    // base radius — controls flare
vent_count = 12;        // decorative slots around body
collar_twist = 45;      // twist angle of base collar
```

---

### Project 03 — Mechanical Gear System

**File:** `project_03_mechanical_gear_system.scad`

A complete gear system with a large spur gear, meshing pinion gear, linear
rack, and axles. All gear teeth are mathematically correct involute profiles
generated entirely from list comprehensions — no manual drawing.

**JD Skills Demonstrated:**

- `List Comprehensions` — both tooth flanks generated via `[for (i=[...]) let(...) [x,y]]`
- `Flow Control` — `for` loops place every tooth, spoke, and rack tooth
- `Boolean Operations` — `difference()` cuts bore holes, spoke cutouts, chamfers
- `Type Test Functions` — `is_num()` and `is_list()` validate parameters with `echo()` output
- `Lists` — tooth point arrays assembled and passed to `polygon()`
- `linear_extrude` — converts 2D gear profiles to 3D wheels
- `Operators` — full involute trigonometry: `cos()`, `sin()`, `acos()`

**Key Techniques:**
Involute gear geometry from first principles. The `involute_x()` and
`involute_y()` functions compute the mathematically correct tooth curve.
Change `gear_module` and all gears rescale proportionally.

**How to Use:**

```
gear_module = 2.0;      // tooth size — all gears scale from this
spur_teeth = 24;        // large gear tooth count
pinion_teeth = 12;      // small gear (2:1 ratio)
explode = false;        // set true for exploded view
```

---

### Project 04 — Architectural Building Block Set

**File:** `project_04_architectural_building.scad`

A modular architectural system with walls, windows, arched doors, fluted
columns, and a gabled roof. The entire facade layout is generated from a
nested list comprehension — geometry driven by data.

**JD Skills Demonstrated:**

- `Modules & Nesting` — `building` → `facade_wall` → `window_opening` → `arched_door` deep hierarchy
- `Lists` — facade layout stored as `[[bay, floor, has_window, has_door], ...]`
- `List Comprehensions` — nested `[for (bay=...) for (floor=...) let(...) [...]]` generates full layout
- `Boolean Operations` — `difference()` carves openings from walls and flutes from columns
- `linear_extrude` — gabled roof extruded from a 2D triangle polygon
- `Flow Control` — `for` loops over layout list, `if/else` for conditional door/window placement
- `mirror()` — side walls reflected for symmetry

**Key Techniques:**
The layout list comprehension is the architectural highlight — it generates
every window and door position from pure logic. `linear_extrude` of a triangle
polygon produces the entire gabled roof.

**How to Use:**

```
U = 10;                 // base unit — all dimensions scale from this
building_bays = 3;      // number of bays wide
building_floors = 2;    // number of floors
```

---

### Project 05 — Organic Vase Collection

**File:** `project_05_organic_vase.scad`

Three vase designs, each using a different advanced technique: `minkowski()`
for smooth rounded forms, `hull()` for tapered bridging, and `rotate_extrude`
of a sculpted polygon for a classical profile. Set `vase_style = 0` to render
all three side by side.

**JD Skills Demonstrated:**

- `minkowski()` — smooths a tapered hull form into an organic rounded vase
- `hull()` — bridges stacked cylinders at different heights and radii into a smooth taper
- `rotate_extrude` — sweeps a detailed polygon profile 360° for Vase 3
- `List Comprehensions` — generates inner wall profile from outer profile; surface dimple grid
- `concat()` — joins outer and inner profile point lists into one closed polygon
- `Special Variables` — `$fn`, `$fa`, `$fs` all used and explained
- `scale()` — squashes the hull vase for organic non-circular feel

**Key Techniques:**
`minkowski()` with a sphere rounds every edge and corner of the base shape.
`hull()` of cylinders creates transitions impossible with primitives.
The dimple texture grid uses a nested list comprehension to place spherical
cutouts at golden-angle-distributed positions across the surface.

**How to Use:**

```
vase_style = 0;         // 0=all three, 1=minkowski, 2=hull, 3=sculpted
vase_height = 80;       // mm
body_max_r = 34;        // widest point
decoration = true;      // surface decoration patterns
```

---

### Project 06 — 3D Topographic Map from 2D Contours

**File:** `project_06_topographic_map.scad`

A 3D terrain model built by stacking 2D contour polygon layers at increasing
elevations. This directly demonstrates the JD requirement: _"Build up 3D
shapes from 2D shadows"_ — each contour is the 2D shadow of the terrain at
that height, extruded to reconstruct the 3D surface.

**JD Skills Demonstrated:**

- `3D from 2D Shadows` — 8 contour polygons extruded and stacked = full 3D terrain
- `linear_extrude` — every terrain layer is a `linear_extrude` of a `polygon()`
- `Lists` — all contour data stored as nested lists, retrieved by index
- `List Comprehensions` — layer indices, grid positions, color stops generated
- `Type Test Functions` — `is_num()` and `is_list()` validate contour data
- `Flow Control` — `for` loop stacks all 8 elevation layers
- `Boolean Operations` — `difference()` creates base frame recess and border

**Key Techniques:**
The core idea: a 2D contour polygon is the "shadow" of the terrain at one
elevation. `linear_extrude` lifts it to that height. Stack all 8 layers
and the 3D terrain emerges. Elevation-based color mapping using a list of
RGB stops communicates altitude visually.

**How to Use:**

```
contour_count = 8;      // number of elevation layers
layer_height = 4;       // mm per layer
map_scale = 1.0;        // overall scale
color_mode = true;      // elevation colour mapping
```

---

### Project 07 — Procedural City Generator

**File:** `project_07_procedural_city.scad`

An entire city district generated from a single seed value. Roads, blocks,
buildings, parks, and a central landmark are all computed procedurally using
list comprehensions and deterministic randomness. Change `city_seed` and a
completely different city is produced.

**JD Skills Demonstrated:**

- `List Comprehensions` — nested `[for (col=...) for (row=...) [...]]` generates the full block grid
- `Lists` — `gear_train`-style building config list; structured data driving geometry
- `Flow Control` — `if/else` chain classifies building types; nested `for` loops for facade details
- `Type Test Functions` — `is_num()` validates all city parameters
- `Boolean Operations` — `difference()` punches windows, doors, and slots throughout
- `Special Variables` — `rands()` with seed for deterministic procedural variation
- `rotate_extrude` — landmark observation ring, dome cap

**Key Techniques:**
`rands(0, 1, count, seed)` produces a deterministic list of random values —
same seed always gives the same city. The `building_type()` function uses
these values to classify each block as glass tower, stepped tower, cylinder
tower, low block, or park. The entire layout is data-driven.

**How to Use:**

```
city_seed = 42;         // change for a different city
city_cols = 5;          // blocks wide
city_rows = 4;          // blocks deep
block_size = 50;        // mm per block
```

---

### Project 08 — Twisted Tower Collection

**File:** `project_08_twisted_tower.scad`

Three architecturally inspired towers each using `linear_extrude` with `twist`
differently: uniform twist (Turning Torso), progressive twist (Shanghai Tower),
and faceted polygon twist (Cayan Tower). All four modifier characters are fully
documented with practical use cases.

**JD Skills Demonstrated:**

- `linear_extrude with twist` — three distinct applications in one file
- `rotate_extrude` — balcony rails, crown observation ring, antenna dish
- `Modifier Characters` — `#`, `%`, `*`, `!` all documented with real use cases
- `List Comprehensions` — progressive twist curve via `pow()`, window positions, facade panel angles
- `Type Test Functions` — `is_num()`, `is_list()`, `is_string()` in validation module
- `offset()` — expands floor slab profiles for slight overhang
- `Flow Control` — `for` loops for balcony placement, windows, floor slabs

**Key Techniques:**
The progressive twist uses `pow(t, exponent)` to create a non-linear rotation
curve — slow at the base, accelerating toward the top. The faceted tower uses
`circle(r=r, $fn=6)` to produce a hexagonal cross-section that twists as it
rises, catching light on its edges.

**How to Use:**

```
tower_style = 0;        // 0=all three, 1=uniform, 2=progressive, 3=faceted
tower_height = 120;     // mm
uniform_twist = 90;     // total degrees of rotation
facet_sides = 6;        // polygon sides for tower 3 (try 3-8)
```

---

### Project 09 — 3D Shapes from 2D Shadows

**File:** `project_09_3d_from_2d_shadows.scad`

Four objects reconstructed from their 2D orthographic shadow projections using
`intersection()` of extruded slabs. Demonstrates the formal space-carving
technique used in CT scanning, computer vision, and AI 3D training data
generation.

**JD Skills Demonstrated:**

- `intersection()` — three orthogonal extruded slabs intersected = 3D solid
- `linear_extrude` — every shadow projection extruded through space
- `2D Objects` — `polygon()` for chess piece, letter F, bird silhouette, L-bracket
- `Modifier Characters` — `%` modifier renders transparent shadow ghosts alongside the result
- `mirror()` — bird wing symmetry
- `Type Test Functions` — `is_bool()` validates display toggle parameters
- `List Comprehensions` — bolt hole positions, facet angles

**Key Techniques:**
Front shadow extruded along Y axis + side shadow along X axis + top shadow
along Z axis. Their `intersection()` is the only region consistent with all
three views — approximating the original 3D object. The `shadow_ghost()`
module uses `%` to render all three input slabs transparently alongside
the result so the technique is visually clear.

**How to Use:**

```
demo_mode = 0;          // 0=all four, 1=rook, 2=letter F, 3=bird, 4=bracket
show_shadows = true;    // show ghost extrusion slabs
extrude_depth = 80;     // mm — must exceed object extent
```

---

### Project 10 — Fractal Recursive Tree Collection

**File:** `project_10_fractal_recursive_tree.scad`

Three recursive tree variants demonstrating OpenSCAD's recursion capability:
a binary fractal tree, a wind-swept ternary tree with list-driven branch
angles, and a full organic tree with leaf clusters, root flare, and bark
texture.

**JD Skills Demonstrated:**

- `Recursion` — modules calling themselves with decremented depth parameter
- `Flow Control` — `if/else` termination conditions; `for` loops inside recursive modules
- `Special Variables` — `$fn`, `$fa`, `$fs`; depth as a controlling parameter
- `Modifier Characters` — all four demonstrated; `%` actively used on bounding box ghosts
- `List Comprehensions` — leaf cluster positions via golden angle spiral; root angles
- `rotate_extrude` — root flare buttresses swept from 2D profile
- `Lists` — `wind_angles` list drives three-way branch split angles
- `Type Test Functions` — `is_num()`, `is_list()`, `is_bool()` in validation module

**Key Techniques:**
Each recursive module has two cases: if `depth <= 0` draw a leaf and stop;
otherwise draw a branch and call itself with `depth - 1`. The golden angle
(137.5°) is used for leaf cluster placement — nature's optimal packing angle,
demonstrating mathematical awareness beyond the OpenSCAD basics.

**How to Use:**

```
tree_style = 0;         // 0=all three, 1=binary, 2=windswept, 3=organic
recursion_depth = 6;    // branch levels — keep 5-7 for speed
show_leaves = true;
show_roots = true;
```

---

## Bonus Project — Mechanical Watch Movement

**File:** `bonus_watch_movement.scad`

A complete top-view mechanical watch movement including barrel, gear train,
escape wheel with club-tooth profile, lever pallet fork, balance wheel with
hairspring, jewel bearings, balance cock bridge, and main plate. The most
technically complex project in the portfolio.

**Key Techniques:** Involute teeth with root fillets, club-tooth escape wheel
profile, Archimedean spiral hairspring from list comprehension, rotate_extrude
jewel bearings, full movement layered assembly with `explode_z` parameter.

---

## How to Run Any Project

1. Download and install OpenSCAD from [openscad.org](https://openscad.org)
2. Open any `.scad` file
3. Press `F5` for a fast preview
4. Press `F6` for a full render
5. Go to `File > Export > Export as STL` to save a printable file
6. Adjust parameters at the top of each file — the model updates live

---

## File List

```
project_01_bolt_and_nut.scad
project_02_geometric_lampshade.scad
project_03_mechanical_gear_system.scad
project_04_architectural_building.scad
project_05_organic_vase.scad
project_06_topographic_map.scad
project_07_procedural_city.scad
project_08_twisted_tower.scad
project_09_3d_from_2d_shadows.scad
project_10_fractal_recursive_tree.scad
bonus_watch_movement.scad
README.md
```

---

## Notes

- All projects use only built-in OpenSCAD features — no external libraries required
- Each file is self-contained and runs independently
- Parameters are always at the top of each file for easy adjustment
- Comments throughout each file label which JD skill each section demonstrates
- Quick demo sections at the bottom of each file let you isolate individual techniques

---

_Portfolio prepared for the micro1 Computational CAD Engineer (OpenSCAD) application._

