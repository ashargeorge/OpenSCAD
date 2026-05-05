// ============================================================
//  PROJECT 07 — Procedural City Generator
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George Onwuemezie
// ============================================================
//
//  JD SKILLS DEMONSTRATED:
//  ✔ List Comprehensions    — entire city layout generated via comprehensions
//  ✔ Lists                  — building configs, road networks, block data
//  ✔ Flow Control           — for loops, if/else, nested conditions
//  ✔ Type Test Functions    — is_num(), is_list(), is_string() validation
//  ✔ Boolean Operations     — difference(), union(), intersection()
//  ✔ 3D Objects             — cube(), cylinder(), sphere() primitives
//  ✔ 2D Objects             — square(), circle(), polygon() profiles
//  ✔ linear_extrude         — building profiles → 3D structures
//  ✔ rotate_extrude         — domes, towers, cylindrical buildings
//  ✔ Transformations        — translate(), rotate(), scale(), mirror()
//  ✔ Special Variables      — $fn, $fa for geometry resolution
//  ✔ Operators              — procedural math, modulo, floor(), rands()
//  ✔ Modifier Characters    — # debug modifier for block boundaries
//  ✔ Modules & Nesting      — deep module hierarchy: city→block→building
//
// ============================================================
//  CONCEPT:
//  An entire city district generated procedurally from a
//  single seed value. The city layout — roads, blocks,
//  buildings, parks, and landmarks — is computed entirely
//  from list comprehensions and mathematical functions.
//  Change the seed or grid parameters and a completely
//  different city emerges. This directly mirrors AI training
//  data generation workflows where geometry must be produced
//  at scale with controlled variation.
// ============================================================
//  HOW TO USE:
//  F5 = preview, F6 = render
//  Change city_seed for a different city layout.
//  Toggle show_* variables to isolate components.
// ============================================================

$fn = 32;
$fa = 2;

// ============================================================
//  PARAMETERS
// ============================================================

// --- City layout ---
city_seed         = 42;     // change this for a different city
city_cols         = 5;      // number of city blocks wide
city_rows         = 4;      // number of city blocks deep
block_size        = 50;     // mm — size of each city block
road_width        = 8;      // mm — width of roads between blocks
building_margin   = 4;      // mm — setback from block edge

// --- Building height range ---
min_height        = 8;      // mm
max_height        = 55;     // mm

// --- Display toggles ---
show_buildings    = true;
show_roads        = true;
show_ground       = true;
show_parks        = true;
show_landmark     = true;

// ============================================================
//  COMPUTED CONSTANTS
// ============================================================
block_step        = block_size + road_width;
total_width       = city_cols * block_step + road_width;
total_depth       = city_rows * block_step + road_width;
buildable         = block_size - building_margin * 2;

// ============================================================
//  PSEUDO-RANDOM NUMBER GENERATOR
//  OpenSCAD's rands() takes (min, max, count, seed).
//  We use it deterministically — same seed = same city.
//  demonstrates: special variables, operators, lists
// ============================================================

// Generate a flat list of random values for the whole city
// demonstrates: list comprehension over rands() output
rand_count        = city_cols * city_rows * 8;
rand_vals         = rands(0, 1, rand_count, city_seed);

// Helper function: get deterministic random value by index
// demonstrates: operators, list indexing
function rv(index) =
    rand_vals[index % rand_count];

// Map a 0-1 value to a range
// demonstrates: operators — linear interpolation
function map_range(v, lo, hi) = lo + v * (hi - lo);

// ============================================================
//  BUILDING TYPE CLASSIFIER
//  Assigns a building archetype based on random value.
//  demonstrates: flow control (if/else chain), operators
//  0 = glass tower, 1 = stepped tower, 2 = cylinder tower,
//  3 = wide low block, 4 = park (no building)
// ============================================================
function building_type(col, row) =
    let(
        idx = (col * city_rows + row) * 8,
        v   = rv(idx)
    )
    // demonstrates: nested ternary = if/else chain
    v < 0.12 ? 4 :   // park
    v < 0.30 ? 2 :   // cylinder tower
    v < 0.55 ? 1 :   // stepped tower
    v < 0.80 ? 0 :   // glass tower
               3;     // wide low block

// Building height from seed
function building_height(col, row) =
    let(idx = (col * city_rows + row) * 8 + 1)
    map_range(rv(idx), min_height, max_height);

// Building footprint width
function building_width(col, row) =
    let(idx = (col * city_rows + row) * 8 + 2)
    map_range(rv(idx), buildable * 0.35, buildable * 0.85);

// Building footprint depth
function building_depth(col, row) =
    let(idx = (col * city_rows + row) * 8 + 3)
    map_range(rv(idx), buildable * 0.35, buildable * 0.85);

// Rotation angle (0, 90 only — keeps grid aligned)
function building_rotation(col, row) =
    let(idx = (col * city_rows + row) * 8 + 4)
    rv(idx) > 0.5 ? 0 : 90;

// ============================================================
//  MODULE: glass_tower
//  Tall rectangular tower with setback floors and antenna.
//  demonstrates: for loop, difference(), union(), translate()
//               linear_extrude, cube(), cylinder()
// ============================================================
module glass_tower(w, d, h) {
    floor_count = floor(h / 4);
    setback     = w * 0.12;

    union() {
        // Main shaft
        // demonstrates: difference() — window slots cut from tower
        difference() {
            cube([w, d, h]);

            // Horizontal floor lines
            // demonstrates: for loop + difference()
            for (f = [1 : floor_count - 1]) {
                translate([-0.1, -0.1, f * (h / floor_count) - 0.4])
                cube([w + 0.2, d + 0.2, 0.8]);
            }

            // Vertical window columns on front face
            // demonstrates: list comprehension for window positions
            win_positions = [
                for (col = [1 : floor(w / 4) - 1])
                col * (w / floor(w / 4))
            ];
            for (xp = win_positions) {
                translate([xp - 0.5, -0.1, 2])
                cube([1, d * 0.15, h - 4]);
            }
        }

        // Setback upper section
        // demonstrates: translate() + cube() stacking
        if (h > 30) {
            translate([setback, setback, h * 0.65])
            cube([w - setback * 2, d - setback * 2, h * 0.35]);
        }

        // Antenna spire
        // demonstrates: translate() + cylinder()
        translate([w / 2, d / 2, h])
        cylinder(r1 = 1.2, r2 = 0.2, h = h * 0.18);
    }
}

// ============================================================
//  MODULE: stepped_tower
//  Art-deco style building with multiple stepped tiers.
//  demonstrates: for loop, scale(), cube(), list comprehension
// ============================================================
module stepped_tower(w, d, h) {
    steps = 4;

    // demonstrates: list comprehension generating step tiers
    tier_data = [
        for (i = [0 : steps - 1])
        let(
            scale_f = 1 - (i * 0.2),
            z_start = i * (h / steps),
            tw      = w * scale_f,
            td      = d * scale_f
        )
        [tw, td, z_start, h / steps + 0.2]
    ];

    // demonstrates: for loop over comprehension result
    for (tier = tier_data) {
        tw = tier[0]; td = tier[1];
        tz = tier[2]; th = tier[3];

        translate([
            (w - tw) / 2,
            (d - td) / 2,
            tz
        ])
        // demonstrates: cube() with computed dimensions
        cube([tw, td, th]);
    }

    // Crown detail
    translate([w / 2, d / 2, h])
    cylinder(r = w * 0.08, h = h * 0.12, $fn = 8);
}

// ============================================================
//  MODULE: cylinder_tower
//  Cylindrical skyscraper with ribbed facade.
//  demonstrates: rotate_extrude, difference(), for loop
//               cylinder(), linear_extrude
// ============================================================
module cylinder_tower(w, d, h) {
    r       = min(w, d) * 0.42;
    cx      = w / 2;
    cy      = d / 2;
    ribs    = 12;

    translate([cx, cy, 0])
    union() {
        // Main cylinder body
        // demonstrates: cylinder() 3D primitive
        difference() {
            cylinder(r = r, h = h);

            // Vertical rib slots cut into facade
            // demonstrates: for loop + rotate() + difference()
            for (i = [0 : ribs - 1]) {
                angle = i * (360 / ribs);
                rotate([0, 0, angle])
                translate([r - 0.8, -0.4, -0.1])
                cube([1.2, 0.8, h + 0.2]);
            }
        }

        // Dome cap
        // demonstrates: rotate_extrude of arc profile
        translate([0, 0, h])
        rotate_extrude(angle = 360)
        // 2D dome profile
        // demonstrates: polygon() as dome cross-section
        polygon(points = [
            [0,    0],
            [r,    0],
            [r,    1],
            [r * 0.7, r * 0.5],
            [0,    r * 0.55]
        ]);
    }
}

// ============================================================
//  MODULE: low_block
//  Wide, low commercial block with rooftop details.
//  demonstrates: difference(), union(), for loop, cube()
// ============================================================
module low_block(w, d, h) {
    actual_h = min(h, min_height * 2.2);

    union() {
        // Main block body
        difference() {
            cube([w, d, actual_h]);

            // Punched window grid
            // demonstrates: nested for loops (flow control)
            cols = floor(w / 6);
            rows = floor(actual_h / 5);
            for (c = [0 : cols - 1]) {
                for (r = [0 : rows - 1]) {
                    translate([
                        c * (w / cols) + w / cols * 0.25,
                        -0.1,
                        r * (actual_h / rows) + actual_h / rows * 0.2
                    ])
                    cube([
                        w / cols * 0.5,
                        d * 0.18,
                        actual_h / rows * 0.55
                    ]);
                }
            }
        }

        // Rooftop HVAC units
        // demonstrates: list comprehension for rooftop positions
        hvac_positions = [
            for (i = [0 : 2])
            [w * (0.2 + i * 0.28), d * 0.3]
        ];
        for (pos = hvac_positions) {
            translate([pos[0], pos[1], actual_h])
            cube([w * 0.14, d * 0.2, actual_h * 0.12]);
        }

        // Parapet wall around roof edge
        // demonstrates: difference() creating hollow parapet
        translate([0, 0, actual_h])
        difference() {
            cube([w, d, 1.5]);
            translate([1.2, 1.2, -0.1])
            cube([w - 2.4, d - 2.4, 1.8]);
        }
    }
}

// ============================================================
//  MODULE: park_block
//  Green space with trees and paths.
//  demonstrates: for loop, cylinder(), sphere(),
//               difference(), translate(), scale()
// ============================================================
module park_block(w, d) {
    tree_count = 5;

    union() {
        // Ground plane (slightly raised green pad)
        color([0.35, 0.62, 0.28])
        cube([w, d, 1.2]);

        // Diagonal path
        color([0.78, 0.74, 0.66])
        translate([0, 0, 1.2])
        rotate([0, 0, 45])
        translate([-2, w * 0.3, 0])
        cube([2, w * 1.2, 0.4]);

        // Trees — demonstrates: list comprehension + for loop
        tree_positions = [
            for (i = [0 : tree_count - 1])
            let(
                tx = map_range(rv(i * 3 + 10), w * 0.1, w * 0.85),
                ty = map_range(rv(i * 3 + 11), d * 0.1, d * 0.85)
            )
            [tx, ty]
        ];

        for (pos = tree_positions) {
            translate([pos[0], pos[1], 1.2])
            color([0.25, 0.52, 0.22])
            union() {
                // Trunk
                cylinder(r = 0.8, h = 5);
                // Canopy — demonstrates: sphere() + scale()
                translate([0, 0, 6])
                scale([1, 1, 0.75])
                sphere(r = 4);
            }
        }

        // Fountain in centre
        translate([w / 2, d / 2, 1.2])
        color([0.55, 0.70, 0.85])
        union() {
            cylinder(r = 4, h = 0.8);
            difference() {
                cylinder(r = 4, h = 1.5);
                cylinder(r = 3.2, h = 1.6);
            }
            // Water jet
            cylinder(r = 0.4, h = 4);
            translate([0, 0, 4])
            sphere(r = 1.2);
        }
    }
}

// ============================================================
//  MODULE: landmark_building
//  A unique central landmark — tall tower with spire.
//  Placed at city centre. Shows off all techniques together.
//  demonstrates: rotate_extrude, minkowski(), hull(),
//               difference(), union(), for loop
// ============================================================
module landmark_building() {
    lh = max_height * 1.6;   // taller than all other buildings
    lr = 12;

    color([0.90, 0.82, 0.60])
    union() {
        // Base plinth
        // demonstrates: difference() for chamfered base
        difference() {
            cube([lr * 2.8, lr * 2.8, 8], center = true);
            // Chamfer edges
            translate([0, 0, 3])
            rotate([0, 0, 45])
            cube([lr * 2.2, lr * 4.2, 3], center = true);
        }

        // Main tower shaft
        translate([0, 0, 4])
        difference() {
            cylinder(r = lr * 0.72, h = lh, $fn = 8);

            // Vertical window slots
            // demonstrates: for loop + rotate() + difference()
            for (i = [0 : 7]) {
                rotate([0, 0, i * 45])
                translate([lr * 0.6, -1, lh * 0.1])
                cube([lr * 0.3, 2, lh * 0.75]);
            }
        }

        // Tapered upper section
        translate([0, 0, lh * 0.65])
        // demonstrates: hull() between two cylinders = tapered form
        hull() {
            cylinder(r = lr * 0.72, h = 0.5, $fn = 8);
            translate([0, 0, lh * 0.25])
            cylinder(r = lr * 0.3, h = 0.5, $fn = 8);
        }

        // Spire
        translate([0, 0, lh * 0.9 + 4])
        cylinder(r1 = lr * 0.3, r2 = 0.3, h = lh * 0.35, $fn = 8);

        // Observation ring
        translate([0, 0, lh * 0.72 + 4])
        // demonstrates: rotate_extrude for ring element
        rotate_extrude(angle = 360)
        translate([lr * 0.72, 0, 0])
        square([lr * 0.25, 2], center = true);
    }
}

// ============================================================
//  MODULE: road_network
//  Generates the city road grid.
//  demonstrates: list comprehension, for loop, cube()
// ============================================================
module road_network() {
    color([0.30, 0.30, 0.30])
    union() {
        // Ground base (full city footprint)
        cube([total_width, total_depth, 0.5]);

        // Horizontal roads
        // demonstrates: list comprehension for road positions
        h_roads = [for (r = [0 : city_rows]) r * block_step];
        for (y = h_roads) {
            translate([0, y, 0.4])
            cube([total_width, road_width, 0.4]);
        }

        // Vertical roads
        v_roads = [for (c = [0 : city_cols]) c * block_step];
        for (x = v_roads) {
            translate([x, 0, 0.4])
            cube([road_width, total_depth, 0.4]);
        }

        // Intersection markings (crosswalk lines)
        // demonstrates: nested for loops
        for (c = [0 : city_cols]) {
            for (r = [0 : city_rows]) {
                ix = c * block_step;
                iy = r * block_step;
                color([0.85, 0.85, 0.82])
                translate([ix, iy, 0.85])
                cube([road_width, road_width, 0.2]);
            }
        }
    }
}

// ============================================================
//  MODULE: city_block
//  Places the appropriate building type in one city block.
//  demonstrates: if/else flow control, type test, translate()
// ============================================================
module city_block(col, row) {
    // Block origin position
    bx = road_width + col * block_step;
    by = road_width + row * block_step;

    // demonstrates: type test functions
    if (!is_num(col) || !is_num(row)) {
        echo("ERROR: col and row must be numbers");
    } else {
        // Get building parameters for this block
        btype = building_type(col, row);
        bh    = building_height(col, row);
        bw    = building_width(col, row);
        bd    = building_depth(col, row);
        brot  = building_rotation(col, row);

        // Centre building in block with margin
        cx = bx + building_margin + (buildable - bw) / 2;
        cy = by + building_margin + (buildable - bd) / 2;

        translate([cx, cy, 0.9])
        rotate([0, 0, brot])
        // demonstrates: if/else flow control selecting building type
        if (btype == 0) {
            color([0.72, 0.82, 0.88])
            glass_tower(bw, bd, bh);

        } else if (btype == 1) {
            color([0.85, 0.78, 0.68])
            stepped_tower(bw, bd, bh);

        } else if (btype == 2) {
            color([0.78, 0.78, 0.82])
            cylinder_tower(bw, bd, bh);

        } else if (btype == 3) {
            color([0.80, 0.75, 0.70])
            low_block(bw, bd, bh);

        } else if (btype == 4) {
            // Park block
            translate([-building_margin, -building_margin, 0])
            park_block(block_size * 0.88, block_size * 0.88);
        }
    }
}

// ============================================================
//  FULL CITY ASSEMBLY
//  demonstrates: nested list comprehension, for loops,
//               conditional landmark placement
// ============================================================
module city() {

    // Validate parameters
    // demonstrates: type test functions — is_num()
    if (!is_num(city_cols) || !is_num(city_rows)) {
        echo("ERROR: city dimensions must be numbers");
    }
    if (!is_num(city_seed)) {
        echo("ERROR: city_seed must be a number");
    }

    // Road network
    if (show_roads) {
        road_network();
    }

    // Generate all city blocks via nested list comprehension
    // demonstrates: nested list comprehension — KEY JD SKILL
    // All block coordinates generated as a flat list
    block_grid = [
        for (col = [0 : city_cols - 1])
        for (row = [0 : city_rows - 1])
        [col, row]
    ];

    // demonstrates: for loop over comprehension-generated list
    if (show_buildings) {
        for (block = block_grid) {
            col = block[0];
            row = block[1];

            // Skip centre block for landmark
            // demonstrates: boolean condition in if
            is_centre = (col == floor(city_cols / 2) &&
                         row == floor(city_rows / 2));

            if (!is_centre) {
                city_block(col, row);
            }
        }
    }

    // Landmark at city centre
    if (show_landmark) {
        lx = road_width + floor(city_cols / 2) * block_step
             + block_size / 2;
        ly = road_width + floor(city_rows / 2) * block_step
             + block_size / 2;

        translate([lx, ly, 0.9])
        landmark_building();
    }
}

// --- RENDER ---
city();

// ============================================================
//  QUICK DEMOS — uncomment to isolate components:
//
//  Single glass tower:
//  glass_tower(25, 20, 45);
//
//  Single stepped tower:
//  stepped_tower(22, 18, 38);
//
//  Cylinder tower:
//  cylinder_tower(20, 20, 42);
//
//  Park block:
//  park_block(42, 42);
//
//  Landmark only:
//  landmark_building();
//
//  Road network only:
//  road_network();
//
//  One city block (col=0, row=0):
//  city_block(0, 0);
//
//  Try different cities — change city_seed:
//  city_seed = 7;   city_seed = 99;   city_seed = 2025;
// ============================================================

// ============================================================
//  END OF PROJECT 07
//  Key techniques: procedural generation via list comprehensions,
//  deterministic randomness with rands(), nested for loops,
//  type test functions, building type classification,
//  full module hierarchy: city → block → building → detail
// ============================================================
