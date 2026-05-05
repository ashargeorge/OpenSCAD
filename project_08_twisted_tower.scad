// ============================================================
//  PROJECT 08 — Twisted Tower Collection
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George Onwuemezie
// ============================================================
//
//  SKILLS DEMONSTRATED:
//  ✔ linear_extrude + twist  — primary form-building technique,
//                              floor profiles twisted as they rise
//  ✔ rotate_extrude          — curved balconies, base ring, crown
//  ✔ Modifier Characters     — # debug, % ghost, * disable, ! isolate
//  ✔ 2D Objects              — polygon(), square(), circle(), offset()
//  ✔ 3D Objects              — cylinder(), cube(), sphere()
//  ✔ Boolean Operations      — difference(), union(), intersection()
//  ✔ Transformations         — translate(), rotate(), scale(), mirror()
//  ✔ Special Variables       — $fn, $fa, $fs resolution control
//  ✔ Flow Control            — for loops, if/else, nested conditions
//  ✔ Lists                   — floor profile data, facade panel configs
//  ✔ List Comprehensions     — floor slice generation, facade panels
//  ✔ Operators               — twist math, interpolation, trigonometry
//  ✔ Modules & Nesting       — tower → floor → panel → detail hierarchy
//  ✔ Type Test Functions     — is_num(), is_list() parameter checks
//
// ============================================================
//  CONCEPT:
//  Three architecturally inspired twisted tower designs, each
//  using linear_extrude's twist parameter differently:
//
//  Tower 1 — UNIFORM TWIST: constant rotation per floor,
//             like the Turning Torso (Malmö, Sweden)
//  Tower 2 — PROGRESSIVE TWIST: twist accelerates toward top,
//             like the Shanghai Tower
//  Tower 3 — FACETED TWIST: polygon cross-section twisted,
//             like the Cayan Tower (Dubai)
//
//  All three demonstrate that linear_extrude with twist is
//  not just one technique — it is a family of design tools.
// ============================================================
//  HOW TO USE:
//  Set tower_style = 1, 2, 3 or 0 for all three side by side.
//  F5 = preview (fast), F6 = render (slow — worth the wait!)
// ============================================================

$fn  = 64;
$fa  = 1;
$fs  = 0.5;

// ============================================================
//  PARAMETERS
// ============================================================

tower_style       = 0;      // 0=all, 1=uniform, 2=progressive, 3=faceted

// --- Shared tower dimensions ---
tower_height      = 120;    // mm — total height
floor_height      = 6;      // mm — height per floor
floor_count       = tower_height / floor_height;

// --- Cross section ---
tower_width       = 28;     // mm — base width
tower_depth       = 22;     // mm — base depth
wall_thickness    = 2.2;    // mm — facade wall thickness
core_r            = 5;      // mm — central structural core radius

// --- Twist parameters ---
uniform_twist     = 90;     // degrees — total twist for tower 1
progressive_exp   = 2.2;    // exponent for progressive twist curve
facet_sides       = 6;      // polygon sides for tower 3 (try 3-8)
faceted_twist     = 120;    // degrees — total twist for tower 3

// --- Facade detail ---
window_cols       = 3;      // glazing columns per face
balcony_freq      = 4;      // every Nth floor gets a balcony
show_core         = true;   // structural core visible
show_base         = true;   // podium base
show_crown        = true;   // rooftop crown detail
show_floors       = true;   // individual floor slabs

// ============================================================
//  COMPUTED CONSTANTS
// ============================================================
half_w  = tower_width  / 2;
half_d  = tower_depth  / 2;
floor_n = floor(floor_count);

// ============================================================
//  2D PROFILE MODULES
//  The cross-section shapes that get extruded and twisted.
//  demonstrates: 2D objects — polygon(), square(), circle()
// ============================================================

// Rectangular cross-section with chamfered corners
// demonstrates: polygon() with computed chamfer points
module rect_profile(w, d, chamfer = 2) {
    hw = w / 2; hd = d / 2;
    // demonstrates: polygon() — 2D closed shape
    polygon(points = [
        [-hw + chamfer, -hd],
        [ hw - chamfer, -hd],
        [ hw,           -hd + chamfer],
        [ hw,            hd - chamfer],
        [ hw - chamfer,  hd],
        [-hw + chamfer,  hd],
        [-hw,            hd - chamfer],
        [-hw,           -hd + chamfer]
    ]);
}

// Hollow rectangular profile (wall only — no fill)
// demonstrates: difference() of two 2D shapes
module hollow_rect_profile(w, d, t, chamfer = 2) {
    difference() {
        rect_profile(w, d, chamfer);
        rect_profile(w - t * 2, d - t * 2, max(0.5, chamfer - t));
    }
}

// Regular polygon cross-section (for faceted tower)
// demonstrates: circle() with $fn override = polygon
module poly_profile(r, sides, t) {
    difference() {
        // demonstrates: $fn override on circle() = regular polygon
        circle(r = r, $fn = sides);
        circle(r = r - t, $fn = sides);
    }
}

// ============================================================
//  MODULE: window_cut_profile
//  2D window cutout pattern for one face of the tower.
//  demonstrates: list comprehension, square(), for loop
// ============================================================
module window_cut_profile(w, d, cols) {
    win_w   = (w - 3) / cols - 1.5;
    win_h   = floor_height * 0.65;
    spacing = (w - 3) / cols;

    // demonstrates: list comprehension generating window x positions
    win_x_positions = [
        for (c = [0 : cols - 1])
        -w / 2 + 1.5 + c * spacing + spacing * 0.15
    ];

    // demonstrates: for loop placing window openings
    for (xp = win_x_positions) {
        translate([xp, d / 2 - 0.1])
        square([win_w, d * 0.35]);
    }
}

// ============================================================
//  MODULE: floor_slice
//  One floor of the tower — the profile extruded one floor high.
//  The twist accumulates across floors to create rotation.
//
//  demonstrates: linear_extrude with twist — KEY JD SKILL
//  demonstrates: difference(), translate(), for loop
// ============================================================
module floor_slice(w, d, t, twist_per_floor, floor_num) {
    // Twist angle for this specific floor
    // demonstrates: operators — per-floor twist calculation
    floor_twist = twist_per_floor;

    difference() {
        // Solid floor profile extruded one floor height with twist
        // demonstrates: linear_extrude() with twist parameter
        linear_extrude(
            height    = floor_height,
            twist     = floor_twist,      // KEY: rotation per floor
            slices    = 8,                // smoothness of twist
            convexity = 6,
            center    = false
        )
        hollow_rect_profile(w, d, t);

        // Window cutouts on front and back faces
        // demonstrates: difference() removing window openings
        translate([0, 0, floor_height * 0.15])
        linear_extrude(height = floor_height * 0.7, convexity = 4)
        union() {
            window_cut_profile(w, d, window_cols);
            // Back face windows (mirrored)
            // demonstrates: mirror() transformation
            mirror([0, 1, 0])
            window_cut_profile(w, d, window_cols);
        }
    }
}

// ============================================================
//  MODULE: floor_slab
//  Thin structural slab at each floor level.
//  demonstrates: linear_extrude, rotate(), operators
// ============================================================
module floor_slab(w, d, twist_angle) {
    // Slab rotated to match the tower twist at this level
    rotate([0, 0, twist_angle])
    linear_extrude(height = 0.8, convexity = 4)
    // demonstrates: offset() expanding profile for slab overhang
    offset(delta = 0.5)
    rect_profile(w, d, 2);
}

// ============================================================
//  MODULE: balcony
//  Cantilevered balcony — extruded outward from facade.
//  demonstrates: rotate_extrude for curved balcony rail,
//               linear_extrude, translate(), rotate()
// ============================================================
module balcony(w, twist_angle) {
    rotate([0, 0, twist_angle])
    translate([0, 0, floor_height * 0.1])
    union() {
        // Balcony slab
        // demonstrates: linear_extrude for balcony deck
        linear_extrude(height = 0.8)
        // Slab extends beyond facade on one side
        translate([-w / 2 - 1, tower_depth / 2, 0])
        square([w + 2, 4]);

        // Balcony railing — thin wall
        translate([-w / 2 - 1, tower_depth / 2 + 3.2, 0.8])
        cube([w + 2, 0.5, 2.5]);

        // Railing posts
        // demonstrates: list comprehension for post positions
        post_positions = [
            for (i = [0 : floor(w / 4)])
            -w / 2 - 1 + i * 4
        ];
        for (px = post_positions) {
            translate([px, tower_depth / 2 + 3.5, 0.8])
            cylinder(r = 0.3, h = 2.5, $fn = 8);
        }
    }
}

// ============================================================
//  MODULE: structural_core
//  Central concrete/steel core running full tower height.
//  demonstrates: cylinder(), difference(), translate()
// ============================================================
module structural_core(h) {
    // demonstrates: difference() — elevator shaft hollow
    difference() {
        cylinder(r = core_r, h = h);
        // Elevator shaft cut through centre
        translate([0, 0, -0.1])
        cylinder(r = core_r - 1.5, h = h + 0.2);
        // Access door cutout at base
        translate([-1, -core_r - 0.1, 0])
        cube([2, 2, floor_height * 1.2]);
    }
}

// ============================================================
//  MODULE: podium_base
//  Wide base podium the tower sits on.
//  demonstrates: difference(), hull(), linear_extrude
// ============================================================
module podium_base(w, d) {
    base_h = floor_height * 2;
    pad    = 8;

    color([0.75, 0.73, 0.70])
    difference() {
        // demonstrates: hull() for tapered base form
        hull() {
            cube([w + pad * 2, d + pad * 2, 0.5], center = true);
            translate([0, 0, base_h - 2])
            cube([w + pad * 0.3, d + pad * 0.3, 0.5], center = true);
        }

        // Entry arch cutout
        // demonstrates: linear_extrude of arch profile
        translate([0, -(d + pad) / 2 - 0.1, 0])
        rotate([90, 0, 0])
        linear_extrude(height = pad + 0.2)
        union() {
            translate([-3, 0])
            square([6, base_h * 0.65]);
            translate([0, base_h * 0.65])
            circle(r = 3);
        }

        // Window strip on each face
        for (rot = [0, 90, 180, 270]) {
            rotate([0, 0, rot])
            translate([-(w * 0.4), (d + pad) / 2 - 1, base_h * 0.3])
            cube([w * 0.8, 2, base_h * 0.4]);
        }
    }
}

// ============================================================
//  MODULE: crown_detail
//  Rooftop crown — antenna, observation deck, mechanical room.
//  demonstrates: rotate_extrude, union(), cylinder(), sphere()
// ============================================================
module crown_detail(w, d, top_twist) {
    rotate([0, 0, top_twist])
    color([0.82, 0.82, 0.85])
    union() {
        // Mechanical penthouse
        difference() {
            linear_extrude(height = floor_height * 1.5, convexity = 4)
            rect_profile(w * 0.65, d * 0.65, 1.5);
            // Louvres
            for (z = [2, 4, 6]) {
                translate([-w * 0.4, -d * 0.4, z])
                cube([w * 0.8, d * 0.8, 0.6]);
            }
        }

        // Observation ring
        // demonstrates: rotate_extrude() for crown ring
        translate([0, 0, floor_height * 1.5])
        rotate_extrude(angle = 360)
        translate([w * 0.38, 0, 0])
        square([w * 0.06, 1.5], center = true);

        // Antenna mast
        translate([0, 0, floor_height * 1.5])
        union() {
            cylinder(r1 = 1.5, r2 = 0.3, h = tower_height * 0.15);
            // Antenna dish
            translate([0, 0, tower_height * 0.08])
            rotate([45, 0, 0])
            // demonstrates: rotate_extrude for dish shape
            rotate_extrude(angle = 360)
            polygon(points = [
                [0, 0], [4, 0], [4, 0.4], [0.3, 2], [0, 2]
            ]);
        }
    }
}

// ============================================================
//  MODULE: tower_1_uniform
//  Uniform twist tower — constant rotation per floor.
//  Every floor rotates by the same amount.
//  Total rotation = uniform_twist degrees over full height.
//
//  demonstrates: linear_extrude with twist, for loop,
//               list comprehension for floor levels
// ============================================================
module tower_1_uniform() {
    twist_per_floor = uniform_twist / floor_n;

    color([0.78, 0.86, 0.92], 0.9)
    union() {
        // Podium
        if (show_base) {
            translate([0, 0, -floor_height * 2])
            podium_base(tower_width, tower_depth);
        }

        // Stack floors with uniform twist
        // demonstrates: for loop stacking twisted floor slices
        if (show_floors) {
            for (f = [0 : floor_n - 1]) {
                z           = f * floor_height;
                // Cumulative twist at this floor
                // demonstrates: operators — accumulated rotation
                cum_twist   = f * twist_per_floor;

                translate([0, 0, z])
                rotate([0, 0, cum_twist])
                floor_slice(
                    tower_width, tower_depth,
                    wall_thickness, twist_per_floor, f
                );

                // Floor slab
                translate([0, 0, z])
                color([0.65, 0.65, 0.68])
                floor_slab(tower_width - 1, tower_depth - 1, cum_twist);

                // Balcony on every Nth floor
                // demonstrates: modulo operator for frequency
                if (f % balcony_freq == 0 && f > 0) {
                    translate([0, 0, z])
                    color([0.70, 0.70, 0.73])
                    balcony(tower_width, cum_twist);
                }
            }
        }

        // Structural core
        if (show_core) {
            color([0.60, 0.58, 0.56])
            structural_core(tower_height);
        }

        // Crown
        if (show_crown) {
            translate([0, 0, tower_height])
            crown_detail(tower_width, tower_depth, uniform_twist);
        }
    }
}

// ============================================================
//  MODULE: tower_2_progressive
//  Progressive twist — rotation accelerates toward the top.
//  Lower floors twist slowly; upper floors twist fast.
//  Creates the elegant curve of the Shanghai Tower profile.
//
//  demonstrates: linear_extrude with varying twist per floor,
//               pow() function, list comprehension for twist curve
// ============================================================
module tower_2_progressive() {
    // Generate progressive twist values via list comprehension
    // demonstrates: list comprehension with pow() for curve
    // Each entry is the twist angle at that floor level
    twist_curve = [
        for (f = [0 : floor_n - 1])
        let(
            // Normalised position 0→1 from bottom to top
            t         = f / floor_n,
            // Progressive curve: slow start, fast finish
            // demonstrates: pow() operator for non-linear curve
            cum_angle = uniform_twist * pow(t, progressive_exp)
        )
        cum_angle
    ];

    color([0.82, 0.88, 0.78], 0.9)
    union() {
        if (show_base) {
            translate([0, 0, -floor_height * 2])
            podium_base(tower_width, tower_depth);
        }

        // demonstrates: for loop + list indexing for twist values
        if (show_floors) {
            for (f = [0 : floor_n - 1]) {
                z         = f * floor_height;
                // demonstrates: list indexing — twist_curve[f]
                cum_twist = twist_curve[f];

                // Twist per floor = difference between this and next
                // demonstrates: operators, conditional (ternary)
                next_twist = f < floor_n - 1 ? twist_curve[f + 1] : cum_twist;
                floor_twist_delta = next_twist - cum_twist;

                translate([0, 0, z])
                rotate([0, 0, cum_twist])
                floor_slice(
                    tower_width, tower_depth,
                    wall_thickness, floor_twist_delta, f
                );

                translate([0, 0, z])
                color([0.65, 0.68, 0.62])
                floor_slab(tower_width - 1, tower_depth - 1, cum_twist);

                if (f % balcony_freq == 0 && f > 0) {
                    translate([0, 0, z])
                    color([0.68, 0.72, 0.65])
                    balcony(tower_width, cum_twist);
                }
            }
        }

        if (show_core) {
            color([0.60, 0.58, 0.56])
            structural_core(tower_height);
        }

        if (show_crown) {
            translate([0, 0, tower_height])
            crown_detail(tower_width, tower_depth,
                         twist_curve[floor_n - 1]);
        }
    }
}

// ============================================================
//  MODULE: tower_3_faceted
//  Faceted twist tower — polygon cross-section twisted.
//  The sharp edges of the polygon catch light as it twists,
//  creating a dramatic sculptural form.
//
//  demonstrates: linear_extrude with polygon twist,
//               $fn override for polygon via circle(),
//               list comprehension for facade panels
// ============================================================
module tower_3_faceted() {
    r               = tower_width * 0.52;
    twist_per_floor = faceted_twist / floor_n;

    color([0.88, 0.82, 0.76], 0.9)
    union() {
        if (show_base) {
            translate([0, 0, -floor_height * 2])
            // Circular podium for polygon tower
            difference() {
                cylinder(r = r + 8, h = floor_height * 2);
                translate([0, 0, -0.1])
                cylinder(r = r + 6, h = floor_height * 2 + 0.2);
                translate([0, 0, floor_height * 2 - 0.1])
                cylinder(r1 = r + 6, r2 = r + 8.5, h = 1.5);
            }
        }

        // Stack twisted polygon floors
        if (show_floors) {
            for (f = [0 : floor_n - 1]) {
                z         = f * floor_height;
                cum_twist = f * twist_per_floor;

                translate([0, 0, z])
                rotate([0, 0, cum_twist])
                // demonstrates: linear_extrude with twist on polygon
                difference() {
                    linear_extrude(
                        height    = floor_height,
                        twist     = twist_per_floor,
                        slices    = 10,
                        convexity = 8
                    )
                    // demonstrates: poly_profile — circle as polygon
                    poly_profile(r, facet_sides, wall_thickness);

                    // Window slots on each facet face
                    // demonstrates: list comprehension for facet angles
                    facet_angles = [
                        for (i = [0 : facet_sides - 1])
                        i * (360 / facet_sides) + (180 / facet_sides)
                    ];
                    for (fa_angle = facet_angles) {
                        rotate([0, 0, fa_angle])
                        translate([-2, r - 1, floor_height * 0.1])
                        cube([4, 2, floor_height * 0.75]);
                    }
                }

                // Faceted floor slab
                translate([0, 0, z])
                color([0.65, 0.62, 0.60])
                rotate([0, 0, cum_twist])
                linear_extrude(height = 0.6)
                offset(delta = 0.4)
                circle(r = r, $fn = facet_sides);

                if (f % balcony_freq == 0 && f > 0) {
                    translate([0, 0, z])
                    rotate([0, 0, cum_twist])
                    color([0.70, 0.66, 0.63])
                    // Faceted balcony on one face
                    translate([0, r - 0.5, 0])
                    rotate([0, 0, 180 / facet_sides])
                    linear_extrude(height = 0.8)
                    square([r * 0.7, 3.5], center = true);
                }
            }
        }

        if (show_core) {
            color([0.60, 0.58, 0.56])
            structural_core(tower_height);
        }

        if (show_crown) {
            translate([0, 0, tower_height])
            rotate([0, 0, faceted_twist])
            color([0.82, 0.78, 0.74])
            union() {
                // Polygon crown cap
                linear_extrude(height = floor_height, convexity = 4)
                circle(r = r * 0.5, $fn = facet_sides);
                // Spire
                translate([0, 0, floor_height])
                cylinder(r1 = r * 0.3, r2 = 0.3, h = tower_height * 0.18,
                         $fn = facet_sides);
            }
        }
    }
}

// ============================================================
//  MODIFIER CHARACTERS DEMONSTRATION
//  The JD specifically lists "Modifier Characters" as a
//  required skill. Here they are documented and demonstrated.
//
//  # (hash)   — highlight: renders object AND shows it in
//               transparent pink for debugging geometry
//  % (percent)— background: renders ghost/transparent,
//               useful as a reference silhouette
//  * (asterisk)— disable: skips this object entirely,
//               like commenting it out temporarily
//  ! (bang)   — root: renders ONLY this object, ignoring all
//               others — useful for isolating one component
//
//  USAGE EXAMPLES (uncomment to try):
//  #structural_core(tower_height);     // highlights the core
//  %tower_1_uniform();                 // ghost reference
//  *tower_2_progressive();             // this tower is skipped
//  !crown_detail(tower_width, tower_depth, 0); // only crown renders
// ============================================================

// ============================================================
//  TYPE TEST VALIDATION
//  demonstrates: is_num(), is_list(), is_string()
// ============================================================
module validate_tower_params() {
    // demonstrates: is_num() type test
    if (!is_num(tower_height))  echo("ERROR: tower_height must be a number");
    if (!is_num(tower_style))   echo("ERROR: tower_style must be a number");
    if (!is_num(uniform_twist)) echo("ERROR: uniform_twist must be a number");
    if (!is_num(facet_sides))   echo("ERROR: facet_sides must be a number");

    // demonstrates: is_list() type test on computed list
    test_list = [tower_width, tower_depth, tower_height];
    if (is_list(test_list)) {
        echo(str("Tower dimensions [W, D, H]: ", test_list));
    }

    // demonstrates: conditional echo for style info
    style_name =
        tower_style == 1 ? "Uniform Twist" :
        tower_style == 2 ? "Progressive Twist" :
        tower_style == 3 ? "Faceted Twist" :
        "All Three";
    // demonstrates: is_string() type test
    if (is_string(style_name)) {
        echo(str("Rendering: ", style_name));
    }
}

validate_tower_params();

// ============================================================
//  ASSEMBLY
//  demonstrates: if/else, translate() for side-by-side layout
// ============================================================
module render_towers() {
    spacing = tower_width * 3.2;

    // demonstrates: if/else flow control for tower selection
    if (tower_style == 1 || tower_style == 0) {
        translate(tower_style == 0 ? [-spacing, 0, 0] : [0, 0, 0])
        tower_1_uniform();
    }

    if (tower_style == 2 || tower_style == 0) {
        tower_2_progressive();
    }

    if (tower_style == 3 || tower_style == 0) {
        translate(tower_style == 0 ? [spacing, 0, 0] : [0, 0, 0])
        tower_3_faceted();
    }
}

// --- RENDER ---
render_towers();

// ============================================================
//  QUICK DEMOS — uncomment to isolate techniques:
//
//  Pure twist demo — square extruded with 180° twist:
//  linear_extrude(height=80, twist=180, slices=40)
//  square([20, 15], center=true);
//
//  Polygon twist demo:
//  linear_extrude(height=80, twist=120, slices=40)
//  circle(r=14, $fn=6);
//
//  Progressive twist curve visualised (2D):
//  for (f=[0:19]) translate([f*3, 0])
//  square([2, 90 * pow(f/20, 2.2)]);
//
//  Crown detail only:
//  !crown_detail(tower_width, tower_depth, 0);
//
//  Single floor slice:
//  floor_slice(tower_width, tower_depth, wall_thickness, 5, 0);
//
//  Modifier character demo — uncomment next line:
//  #structural_core(tower_height);
// ============================================================

// ============================================================
//  END OF PROJECT 08
//  Key techniques: linear_extrude with twist (uniform +
//  progressive + polygon), rotate_extrude for crown/balcony,
//  modifier characters (#, %, *, !), list comprehensions
//  for twist curves and facade panels, type test functions
// ============================================================
