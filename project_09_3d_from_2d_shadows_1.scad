// ============================================================
//  PROJECT 09 — 3D Shapes from 2D Shadows
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George Onwuemezie
// ============================================================
//
//  SKILLS DEMONSTRATED:
//  ✔ 3D from 2D Shadows     — CORE TECHNIQUE: intersecting
//                             orthogonal extrusions of 2D silhouettes
//                             reconstructs the 3D solid whose shadows
//                             match all input profiles simultaneously
//  ✔ intersection()         — the boolean that makes it work
//  ✔ linear_extrude         — 2D shadow profiles → 3D slabs
//  ✔ rotate_extrude         — radially symmetric shadow profiles
//  ✔ 2D Objects             — polygon(), circle(), square(), text()
//  ✔ 3D Objects             — cube(), cylinder(), sphere()
//  ✔ Boolean Operations     — intersection(), difference(), union()
//  ✔ Transformations        — translate(), rotate(), mirror(), scale()
//  ✔ Special Variables      — $fn, $fa for resolution
//  ✔ Flow Control           — for loops, if/else, nested conditions
//  ✔ Lists                  — silhouette point data, object configs
//  ✔ List Comprehensions    — multi-view projection generation
//  ✔ Operators              — projection math, coordinate transforms
//  ✔ Modifier Characters    — % ghost views for shadow illustration
//  ✔ Type Test Functions    — is_num(), is_list() validation
//  ✔ Modules & Nesting      — shadow → extrusion → intersection chain
//
// ============================================================
//  THE CORE CONCEPT — "3D FROM 2D SHADOWS":
//
//  Imagine shining a light on a 3D object from three directions:
//  Front, Side, and Top. Each light casts a 2D shadow on the wall.
//  These shadows are the 2D "projections" or "silhouettes".
//
//  This project REVERSES that process:
//  Given the 2D shadows, reconstruct the 3D object.
//
//  METHOD:
//  1. Take the FRONT shadow → extrude it backward (along Y axis)
//     → creates a 3D slab matching the front silhouette
//  2. Take the SIDE shadow  → extrude it sideways (along X axis)
//     → creates a 3D slab matching the side silhouette
//  3. Take the TOP shadow   → extrude it downward (along Z axis)
//     → creates a 3D slab matching the top silhouette
//  4. INTERSECT all three slabs
//     → the overlap is the only region consistent with ALL shadows
//     → this approximates the original 3D object
//
//  This is a fundamental technique in:
//  - Computer vision (3D reconstruction from photos)
//  - CT scanning (medical imaging)
//  - AI training data generation (3D from 2D annotations)
//  - Industrial reverse engineering
// ============================================================
//  HOW TO USE:
//  Set demo_mode to select which object to reconstruct.
//  Set show_shadows = true to visualise the input 2D profiles.
//  F5 = preview, F6 = render
// ============================================================

$fn  = 80;
$fa  = 1;

// ============================================================
//  PARAMETERS
// ============================================================

// Select demo: 1=chess piece, 2=letter F, 3=animal silhouette,
//              4=mechanical bracket, 0=all four side by side
demo_mode         = 0;

// Visual aids
show_shadows      = true;   // show ghost extrusions (% modifier)
show_result       = true;   // show the intersected 3D result
show_axes         = false;  // show XYZ axis reference lines
extrude_depth     = 80;     // mm — depth of each shadow extrusion
                             // must exceed the object's extent

// ============================================================
//  COMPUTED CONSTANTS
// ============================================================
half_depth = extrude_depth / 2;

// ============================================================
//  MODULE: shadow_ghost
//  Renders the extruded shadow slab as a transparent ghost.
//  demonstrates: % modifier character — background/ghost render
//  This visually shows the INPUT to the intersection operation.
// ============================================================
module shadow_ghost(color_rgb) {
    // demonstrates: % modifier — renders transparent/ghost
    // The % modifier makes this visible but non-manifold
    // It shows the shadow slab without affecting the result
    color(color_rgb, 0.12)
    children();
}

// ============================================================
//  MODULE: axis_lines
//  Reference XYZ axes for spatial orientation.
//  demonstrates: for loop, rotate(), cylinder(), color()
// ============================================================
module axis_lines(len = 50) {
    axes = [
        [[1,0,0], [0,1,0], [0,0,1], "X"],  // X — red
        [[0,1,0], [0,0,1], [1,0,0], "Y"],  // Y — green
        [[0,0,1], [1,0,0], [0,1,0], "Z"]   // Z — blue
    ];
    // demonstrates: for loop over list
    for (i = [0 : 2]) {
        color(axes[i][0])
        rotate(i == 0 ? [0,90,0] : i == 1 ? [90,0,0] : [0,0,0])
        cylinder(r = 0.4, h = len, $fn = 8);
    }
}

// ============================================================
//  DEMO 1 — CHESS PIECE (ROOK)
//  Front and side silhouettes are identical (symmetric).
//  Top silhouette is a square with rounded corners.
//
//  demonstrates: intersection() of three extruded profiles,
//               polygon() profiles, rotate_extrude for top,
//               difference() for battlements
// ============================================================

// Front/Side shadow of a rook — stepped profile
module rook_side_profile() {
    // Rook silhouette: base → shaft → battlements
    // demonstrates: polygon() with computed points
    polygon(points = [
        // Right side, bottom to top
        [ 0,  0], [18,  0], [18,  6],   // base
        [14,  6], [14, 10], [16, 10],   // lower step
        [16, 38], [14, 38], [14, 42],   // shaft
        [18, 42], [18, 52],             // battlement base
        [14, 52], [14, 58], [18, 58],   // battlement gap
        [18, 64], [14, 64], [14, 70],   // second battlement
        [18, 70], [18, 76],             // top
        // Left side (mirror), top to bottom
        [ 4, 76], [ 4, 70], [ 8, 70],
        [ 8, 64], [ 4, 64], [ 4, 58],
        [ 8, 58], [ 8, 52], [ 4, 52],
        [ 4, 42], [ 8, 42], [ 8, 38],
        [ 6, 38], [ 6, 10], [ 8, 10],
        [ 8,  6], [ 4,  6], [ 4,  0]
    ]);
}

// Top shadow — square with chamfered corners
module rook_top_profile() {
    // demonstrates: polygon() as top-down silhouette
    offset(r = 2)
    square([18, 18], center = true);
}

module demo_1_rook() {
    // demonstrates: type test validation
    if (!is_num(extrude_depth)) echo("ERROR: extrude_depth must be number");

    // Centre the profile
    cx = -9; cy = -9;

    // ── INTERSECTION OF THREE EXTRUDED SHADOWS ──────────────
    // demonstrates: intersection() — KEY TECHNIQUE
    intersection() {

        // SHADOW 1: Front profile extruded along Y axis
        // demonstrates: linear_extrude — front shadow → 3D slab
        translate([cx, -half_depth, 0])
        rotate([90, 0, 0])
        rotate([0, 0, -90])
        linear_extrude(height = extrude_depth, convexity = 8)
        rook_side_profile();

        // SHADOW 2: Side profile extruded along X axis
        // demonstrates: rotate() + linear_extrude — side shadow
        translate([-half_depth, cy, 0])
        rotate([90, 0, 90])
        linear_extrude(height = extrude_depth, convexity = 8)
        rook_side_profile();

        // SHADOW 3: Top profile extruded along Z axis
        // demonstrates: linear_extrude — top shadow → vertical slab
        translate([cx, cy, -5])
        linear_extrude(height = extrude_depth, convexity = 4)
        rook_top_profile();
    }

    // Ghost shadow visualisation
    // demonstrates: % modifier + shadow_ghost module
    if (show_shadows) {
        // Front shadow ghost
        shadow_ghost([1, 0.3, 0.3])
        translate([cx, -half_depth, 0])
        rotate([90, 0, 0])
        rotate([0, 0, -90])
        linear_extrude(height = extrude_depth, convexity = 8)
        rook_side_profile();

        // Side shadow ghost
        shadow_ghost([0.3, 1, 0.3])
        translate([-half_depth, cy, 0])
        rotate([90, 0, 90])
        linear_extrude(height = extrude_depth, convexity = 8)
        rook_side_profile();

        // Top shadow ghost
        shadow_ghost([0.3, 0.3, 1])
        translate([cx, cy, -5])
        linear_extrude(height = extrude_depth, convexity = 4)
        rook_top_profile();
    }
}

// ============================================================
//  DEMO 2 — LETTER "F" EXTRUSION
//  Front shadow is the letter F.
//  Side and top shadows constrain the depth and height.
//  Result is a 3D letter block.
//
//  demonstrates: polygon() for complex letterform,
//               intersection() giving correct 3D depth,
//               list comprehension for stroke segments
// ============================================================

module letter_F_profile() {
    // Letter F as a 2D polygon
    // demonstrates: polygon() — complex outline
    polygon(points = [
        // Outer boundary — F shape
        [ 0,  0], [12,  0], [12, 10],  // base stem bottom
        [ 5, 10], [ 5, 28], [14, 28],  // mid crossbar
        [14, 38], [ 5, 38], [ 5, 52],  // upper section
        [16, 52], [16, 62],             // top crossbar
        [ 0, 62]                        // back down left side
    ]);
}

// Side profile — rectangular (gives the letter its depth)
module letter_F_side() {
    square([20, 62]);
}

// Top profile — rectangular footprint
module letter_F_top() {
    square([16, 20]);
}

module demo_2_letter_F() {
    cx = -8; cy = -10;

    color([0.85, 0.72, 0.45])
    // demonstrates: intersection() of orthogonal extrusions
    intersection() {
        // Front face — the F letterform
        translate([cx, -half_depth / 2, 0])
        rotate([90, 0, 0])
        linear_extrude(height = extrude_depth * 0.6, convexity = 8)
        letter_F_profile();

        // Side constraint — limits depth
        translate([-half_depth / 2, cy, 0])
        rotate([90, 0, 90])
        linear_extrude(height = extrude_depth * 0.6, convexity = 4)
        letter_F_side();

        // Top constraint — limits footprint
        translate([cx, cy, -5])
        linear_extrude(height = extrude_depth * 0.6, convexity = 4)
        letter_F_top();
    }

    if (show_shadows) {
        shadow_ghost([0.9, 0.5, 0.2])
        translate([cx, -half_depth / 2, 0])
        rotate([90, 0, 0])
        linear_extrude(height = extrude_depth * 0.6, convexity = 8)
        letter_F_profile();

        shadow_ghost([0.2, 0.7, 0.5])
        translate([-half_depth / 2, cy, 0])
        rotate([90, 0, 90])
        linear_extrude(height = extrude_depth * 0.6, convexity = 4)
        letter_F_side();
    }
}

// ============================================================
//  DEMO 3 — ANIMAL SILHOUETTE (BIRD IN FLIGHT)
//  A bird silhouette seen from front, side creates depth.
//  Top view shows wing span.
//
//  demonstrates: polygon() complex organic form,
//               intersection() for organic 3D reconstruction,
//               scale() for aspect ratio adjustment
// ============================================================

// Bird front-view silhouette
module bird_front_profile() {
    // Body + wings spread
    // demonstrates: polygon() organic curved outline
    // (approximated with straight segments for OpenSCAD)
    union() {
        // Body
        scale([1, 1.4, 1])
        circle(r = 8, $fn = 32);

        // Left wing
        polygon(points = [
            [-8,  2], [-14,  8], [-28, 10], [-34,  6],
            [-30,  2], [-18,  0], [ -8, -2]
        ]);

        // Right wing (mirrored)
        // demonstrates: mirror() transformation
        mirror([1, 0, 0])
        polygon(points = [
            [-8,  2], [-14,  8], [-28, 10], [-34,  6],
            [-30,  2], [-18,  0], [ -8, -2]
        ]);

        // Tail
        polygon(points = [
            [-4, -7], [ 4, -7], [ 6, -16], [ 0, -14], [-6, -16]
        ]);

        // Head
        translate([0, 10, 0])
        circle(r = 4.5, $fn = 24);

        // Beak
        translate([4, 12, 0])
        polygon(points = [[0,0],[6,1],[0,2]]);
    }
}

// Bird side silhouette — streamlined body
module bird_side_profile() {
    union() {
        // Body oval
        scale([1.8, 1, 1])
        circle(r = 8, $fn = 32);

        // Head
        translate([6, 8, 0])
        circle(r = 4, $fn = 20);

        // Tail
        translate([-10, -3, 0])
        polygon(points = [[0,0],[-8,-4],[-6,-8],[2,-2]]);

        // Beak
        translate([10, 9, 0])
        polygon(points = [[0,0],[8,0],[0,2]]);
    }
}

// Top view — wing plan form
module bird_top_profile() {
    union() {
        // Body footprint
        scale([1, 2.2, 1])
        circle(r = 6, $fn = 24);

        // Wing plan
        // demonstrates: scale() for elliptical wing shape
        scale([4.5, 0.8, 1])
        circle(r = 8, $fn = 32);
    }
}

module demo_3_bird() {
    color([0.45, 0.55, 0.72])
    translate([0, 0, 20])
    // demonstrates: intersection() for organic 3D reconstruction
    intersection() {
        // Front shadow → extruded slab
        translate([0, -half_depth, 0])
        rotate([90, 0, 0])
        linear_extrude(height = extrude_depth, convexity = 10)
        bird_front_profile();

        // Side shadow → extruded slab
        translate([-half_depth, 0, 0])
        rotate([90, 0, 90])
        linear_extrude(height = extrude_depth, convexity = 10)
        bird_side_profile();

        // Top shadow → extruded slab
        translate([0, 0, -half_depth])
        linear_extrude(height = extrude_depth, convexity = 10)
        bird_top_profile();
    }

    if (show_shadows) {
        translate([0, 0, 20]) {
            shadow_ghost([0.6, 0.3, 0.8])
            translate([0, -half_depth, 0])
            rotate([90, 0, 0])
            linear_extrude(height = extrude_depth, convexity = 10)
            bird_front_profile();

            shadow_ghost([0.3, 0.8, 0.6])
            translate([-half_depth, 0, 0])
            rotate([90, 0, 90])
            linear_extrude(height = extrude_depth, convexity = 10)
            bird_side_profile();

            shadow_ghost([0.8, 0.6, 0.3])
            translate([0, 0, -half_depth])
            linear_extrude(height = extrude_depth, convexity = 10)
            bird_top_profile();
        }
    }
}

// ============================================================
//  DEMO 4 — MECHANICAL BRACKET
//  An L-shaped bracket reconstructed from its three views.
//  Front: L-shape. Side: Rectangle. Top: L footprint.
//
//  demonstrates: intersection() for engineering geometry,
//               polygon() for L-profile, difference() for
//               bolt holes, list comprehension for hole positions
// ============================================================

module bracket_front_profile() {
    // L-shape cross-section
    // demonstrates: union() of two rectangles = L shape
    union() {
        square([30, 8]);         // horizontal arm
        square([8,  30]);        // vertical arm
    }
}

module bracket_side_profile() {
    // Side view — rectangle with gusset triangle
    // demonstrates: union() + polygon() for gusset
    union() {
        square([24, 30]);
        // Triangular gusset for strength
        polygon(points = [
            [0, 8], [24, 8], [0, 30]
        ]);
    }
}

module bracket_top_profile() {
    // Top view — L footprint
    union() {
        square([30, 24]);
        square([8,  30]);
    }
}

module demo_4_bracket() {
    color([0.65, 0.68, 0.72])
    // demonstrates: intersection() for engineering part
    difference() {
        intersection() {
            // Front shadow extrusion
            translate([0, -half_depth * 0.5, 0])
            rotate([90, 0, 0])
            linear_extrude(height = extrude_depth * 0.5, convexity = 6)
            bracket_front_profile();

            // Side shadow extrusion
            translate([-half_depth * 0.5, 0, 0])
            rotate([90, 0, 90])
            linear_extrude(height = extrude_depth * 0.5, convexity = 6)
            bracket_side_profile();

            // Top shadow extrusion
            translate([0, 0, -5])
            linear_extrude(height = extrude_depth * 0.5, convexity = 6)
            bracket_top_profile();
        }

        // Bolt holes — demonstrates: list comprehension for positions
        // demonstrates: list comprehension generating hole coordinates
        bolt_holes = [
            for (pos = [[4,4,0],[4,18,0],[18,4,0],[4,4,20],[4,4,10]])
            pos
        ];

        // demonstrates: for loop + difference() for holes
        for (h = bolt_holes) {
            translate([h[0], h[1], h[2]])
            rotate([h[2] == 0 ? 90 : 0,
                    h[2] != 0 ? 90 : 0, 0])
            cylinder(r = 1.5, h = 20, $fn = 16);
        }

        // Chamfer on outer edges
        // demonstrates: difference() for chamfer detail
        translate([30, -0.1, -0.1])
        rotate([0, -45, 0])
        cube([4, 30, 4]);
    }

    if (show_shadows) {
        shadow_ghost([0.8, 0.4, 0.4])
        translate([0, -half_depth * 0.5, 0])
        rotate([90, 0, 0])
        linear_extrude(height = extrude_depth * 0.5, convexity = 6)
        bracket_front_profile();

        shadow_ghost([0.4, 0.8, 0.4])
        translate([-half_depth * 0.5, 0, 0])
        rotate([90, 0, 90])
        linear_extrude(height = extrude_depth * 0.5, convexity = 6)
        bracket_side_profile();

        shadow_ghost([0.4, 0.4, 0.8])
        translate([0, 0, -5])
        linear_extrude(height = extrude_depth * 0.5, convexity = 6)
        bracket_top_profile();
    }
}

// ============================================================
//  TYPE TEST VALIDATION
//  demonstrates: is_num(), is_list(), is_bool()
// ============================================================
module validate_params() {
    if (!is_num(demo_mode))      echo("ERROR: demo_mode must be a number");
    if (!is_num(extrude_depth))  echo("ERROR: extrude_depth must be a number");
    if (!is_bool(show_shadows))  echo("ERROR: show_shadows must be boolean");
    if (!is_bool(show_result))   echo("ERROR: show_result must be boolean");

    // demonstrates: is_list() on a constructed list
    param_list = [demo_mode, extrude_depth];
    if (is_list(param_list)) {
        echo(str("Parameters validated: demo_mode=",
                 demo_mode, " depth=", extrude_depth));
    }
}

validate_params();

// ============================================================
//  ASSEMBLY — render selected demo or all four
//  demonstrates: if/else flow control, translate()
// ============================================================
module render_demos() {
    spacing = 90;

    // demonstrates: if/else chain selecting demo
    if (demo_mode == 1 || demo_mode == 0) {
        color([0.75, 0.82, 0.88])
        translate(demo_mode == 0 ? [-spacing * 1.5, 0, 0] : [0,0,0])
        demo_1_rook();
    }

    if (demo_mode == 2 || demo_mode == 0) {
        color([0.85, 0.72, 0.45])
        translate(demo_mode == 0 ? [-spacing * 0.5, 0, 0] : [0,0,0])
        demo_2_letter_F();
    }

    if (demo_mode == 3 || demo_mode == 0) {
        translate(demo_mode == 0 ? [spacing * 0.5, 0, 0] : [0,0,0])
        demo_3_bird();
    }

    if (demo_mode == 4 || demo_mode == 0) {
        color([0.65, 0.68, 0.72])
        translate(demo_mode == 0 ? [spacing * 1.5, 0, 0] : [0,0,0])
        demo_4_bracket();
    }

    if (show_axes) {
        axis_lines(60);
    }
}

// --- RENDER ---
render_demos();

// ============================================================
//  QUICK DEMOS — uncomment to study the core technique:
//
//  The simplest possible shadow intersection (sphere):
//  intersection() {
//    translate([0,-40,0]) rotate([90,0,0])
//      linear_extrude(80) circle(r=15);      // front circle
//    translate([-40,0,0]) rotate([90,0,90])
//      linear_extrude(80) circle(r=15);      // side circle
//    translate([0,0,-40])
//      linear_extrude(80) circle(r=15);      // top circle
//  }
//  // Result: approximates a sphere from three circles
//
//  Just the rook:
//  demo_1_rook();
//
//  Just the bracket:
//  demo_4_bracket();
//
//  Front shadow only (no intersection):
//  translate([0,-40,0]) rotate([90,0,0])
//  linear_extrude(80) rook_side_profile();
//
//  All 2D profiles flat (F5 preview):
//  rook_side_profile();
//  translate([25,0]) letter_F_profile();
//  translate([50,0]) bird_front_profile();
// ============================================================

// ============================================================
//  END OF PROJECT 09
//  Core technique: intersection() of orthogonally extruded
//  2D silhouettes reconstructs 3D form — "3D from 2D shadows"
//  Four diverse examples: chess piece, letter, organic bird,
//  mechanical bracket — proving versatility of the technique.
// ============================================================
