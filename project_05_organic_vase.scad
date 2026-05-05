// ============================================================
//  PROJECT 05 — Organic Vase Collection
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George Onwuemezie
// ============================================================
//
//  SKILLS DEMONSTRATED:
//  ✔ minkowski()            — core smoothing & form-building technique
//  ✔ hull()                 — convex hull bridging between shapes
//  ✔ Special Variables      — $fn, $fs, $fa for resolution control
//  ✔ 3D Objects             — sphere(), cylinder(), cube() as primitives
//  ✔ 2D Objects             — circle(), polygon(), square() as profiles
//  ✔ linear_extrude         — profile-based vase wall construction
//  ✔ rotate_extrude         — body of revolution from 2D profile
//  ✔ Boolean Operations     — difference(), union(), intersection()
//  ✔ Transformations        — translate(), rotate(), scale(), mirror()
//  ✔ Flow Control           — for loops, if/else for variant selection
//  ✔ Lists                  — shape control point arrays
//  ✔ List Comprehensions    — decorative pattern generation
//  ✔ Operators              — all geometry math-derived
//
// ============================================================
//  CONCEPT:
//  Three vase designs, each built using a different advanced
//  technique: minkowski sum for rounded organic forms,
//  hull() for smooth bridging between profiles, and
//  rotate_extrude with a sculpted 2D profile.
//  All three demonstrate how complex organic shapes emerge
//  from simple geometric operations.
// ============================================================
//  HOW TO USE:
//  Set vase_style = 1, 2, or 3 to switch between designs.
//  F5 = preview, F6 = render (warning: minkowski is slow — be patient)
// ============================================================

// --- SPECIAL VARIABLES ---
// $fn controls polygon resolution — affects render time significantly
// For minkowski(), lower $fn speeds up preview
$fn  = 48;
$fa  = 1;
$fs  = 0.5;

// ============================================================
//  PARAMETERS
// ============================================================

// Select which vase to render: 1, 2, or 3
// Set to 0 to render all three side by side
vase_style        = 0;

// --- Shared dimensions ---
vase_height       = 80;     // mm — overall height
wall_thickness    = 2.8;    // mm — wall thickness
base_thickness    = 4;      // mm — floor thickness
neck_r            = 18;     // mm — opening radius at top
body_max_r        = 34;     // mm — widest point radius
base_r            = 22;     // mm — base radius
decoration        = true;   // show surface decoration patterns

// --- Minkowski smoothing radius ---
mink_r            = 3.5;    // mm — smoothing sphere radius
                             // larger = rounder/softer corners

// --- Hull vase control points ---
// List of [radius, height] pairs defining the vase silhouette
// demonstrates: lists as design control data
hull_profile = [
    [base_r,      0],
    [body_max_r,  vase_height * 0.35],
    [body_max_r * 0.85, vase_height * 0.55],
    [neck_r * 1.3, vase_height * 0.75],
    [neck_r,      vase_height]
];

// ============================================================
//  MODULE: smooth_sphere
//  A utility sphere used inside minkowski() calls.
//  demonstrates: special variables $fn override
// ============================================================
module smooth_sphere(r) {
    sphere(r = r, $fn = 24);
}

// ============================================================
//  VASE STYLE 1 — Minkowski Rounded Box Vase
//  demonstrates: minkowski() as the primary form builder
//
//  minkowski() takes two shapes and returns the shape you get
//  by placing the second shape at every point of the first.
//  A cube minkowski'd with a sphere becomes a rounded cuboid.
//  This is the key technique for organic, pillowy forms.
// ============================================================
module vase_1_minkowski() {

    // Outer vase body using minkowski()
    // demonstrates: minkowski() — KEY JD SKILL
    // We create a tapered prism and smooth it with a sphere
    difference() {
        // OUTER SHELL — minkowski of tapered shape + sphere
        // demonstrates: minkowski() smoothing a complex form
        minkowski() {
            // Core tapered shape (will be rounded by minkowski)
            // demonstrates: hull() inside minkowski for base shape
            hull() {
                // Wide base disc
                translate([0, 0, mink_r])
                cylinder(
                    r = base_r - mink_r,
                    h = base_thickness,
                    $fn = 6    // hexagonal base — shows $fn effect
                );

                // Narrower mid-body
                translate([0, 0, vase_height * 0.4])
                cylinder(r = body_max_r - mink_r, h = 2);

                // Neck
                translate([0, 0, vase_height - mink_r * 2])
                cylinder(r = neck_r - mink_r, h = 2);
            }

            // The smoothing element — sphere rounds all edges
            // demonstrates: minkowski() with sphere argument
            smooth_sphere(mink_r);
        }

        // INNER HOLLOW — minkowski of slightly smaller shape
        // demonstrates: difference() to hollow out the vase
        translate([0, 0, base_thickness])
        minkowski() {
            hull() {
                translate([0, 0, mink_r])
                cylinder(r = base_r - wall_thickness - mink_r * 0.5, h = 1);

                translate([0, 0, vase_height * 0.4 - base_thickness])
                cylinder(r = body_max_r - wall_thickness - mink_r * 0.5, h = 2);

                translate([0, 0, vase_height - mink_r * 2 - base_thickness])
                cylinder(r = neck_r - wall_thickness * 0.5, h = 4);
            }
            smooth_sphere(mink_r * 0.5);
        }
    }

    // Decorative raised rings around body
    // demonstrates: for loop + rotate_extrude torus rings
    if (decoration) {
        ring_heights = [
            vase_height * 0.25,
            vase_height * 0.50,
            vase_height * 0.72
        ];

        // demonstrates: for loop over list
        for (h = ring_heights) {
            // Ring radius interpolated at that height
            t   = h / vase_height;
            r_at_h = base_r + (body_max_r - base_r) * (1 - pow(2*t - 1, 2));

            translate([0, 0, h])
            // demonstrates: rotate_extrude() for torus ring
            rotate_extrude(angle = 360)
            translate([r_at_h - wall_thickness * 0.3, 0, 0])
            circle(r = 1.2);
        }
    }
}

// ============================================================
//  VASE STYLE 2 — Hull Bridging Vase
//  demonstrates: hull() as primary form-building technique
//
//  hull() computes the convex hull — the tightest shape that
//  wraps around all the given child objects. By hulling
//  cylinders at different heights and radii, we get smooth
//  tapered transitions impossible to achieve with primitives.
// ============================================================
module vase_2_hull() {

    difference() {
        // OUTER FORM — hull of stacked cylinders
        // demonstrates: hull() — KEY JD SKILL
        // Each cylinder is a cross-section at a different height.
        // hull() creates smooth transitions between them.
        hull() {
            // demonstrates: for loop + hull() combination
            // Generate hull slices from the profile list
            for (pt = hull_profile) {
                r = pt[0];
                h = pt[1];
                translate([0, 0, h])
                // Slight squashing on X axis for organic feel
                // demonstrates: scale() transformation
                scale([1, 0.88, 1])
                cylinder(r = r, h = 0.5);
            }
        }

        // INNER HOLLOW — smaller hull subtracted
        // demonstrates: difference() with hull()
        translate([0, 0, base_thickness])
        hull() {
            for (i = [0 : len(hull_profile) - 1]) {
                pt = hull_profile[i];
                r  = pt[0] - wall_thickness;
                h  = pt[1];

                // demonstrates: list indexing with [i]
                if (r > 2) {
                    translate([0, 0, max(0, h - base_thickness)])
                    scale([1, 0.88, 1])
                    cylinder(r = r, h = 0.5);
                }
            }
        }
    }

    // Decorative twisted ridges on body
    // demonstrates: list comprehension generating ridge positions
    if (decoration) {
        ridge_count = 8;
        ridge_points = [
            for (i = [0 : ridge_count - 1])
            let(angle = i * 360 / ridge_count)
            angle
        ];

        // demonstrates: for loop over comprehension result
        for (angle = ridge_points) {
            rotate([0, 0, angle])
            // Vertical ridge using hull between two spheres
            // demonstrates: hull() for organic ridge shape
            hull() {
                translate([body_max_r * 0.88, 0, vase_height * 0.2])
                sphere(r = 1.5);
                translate([neck_r * 0.92, 0, vase_height * 0.78])
                sphere(r = 1.0);
            }
        }
    }

    // Flared lip at top opening
    // demonstrates: rotate_extrude of offset profile
    translate([0, 0, vase_height])
    rotate_extrude(angle = 360)
    translate([neck_r * 0.88, 0, 0])
    // demonstrates: 2D circle() for torus cross-section
    scale([1, 0.5])
    circle(r = 2.5);
}

// ============================================================
//  VASE STYLE 3 — Sculpted Profile Vase
//  demonstrates: rotate_extrude of a detailed 2D polygon,
//               minkowski() for rim detail,
//               difference() for surface texture
// ============================================================
module vase_3_sculpted() {

    // Build detailed 2D profile for rotate_extrude
    // demonstrates: polygon() with many control points
    // The profile defines the outer AND inner wall shape
    outer_pts = [
        [base_r * 0.7,  0],
        [base_r,        vase_height * 0.05],
        [body_max_r,    vase_height * 0.30],
        [body_max_r * 1.05, vase_height * 0.40],
        [body_max_r,    vase_height * 0.50],
        [body_max_r * 0.75, vase_height * 0.65],
        [neck_r * 1.1,  vase_height * 0.80],
        [neck_r * 1.25, vase_height * 0.88],
        [neck_r * 1.15, vase_height * 0.95],
        [neck_r,        vase_height]
    ];

    inner_pts = [
        for (i = [len(outer_pts) - 1 : -1 : 0])
        let(
            pt = outer_pts[i],
            r  = max(2, pt[0] - wall_thickness),
            h  = i == 0 ? base_thickness : pt[1]
        )
        [r, h]
    ];

    // Combine outer and inner into closed profile
    // demonstrates: concat() joining two lists
    full_profile = concat(outer_pts, inner_pts);

    difference() {
        union() {
            // Main vase body via rotate_extrude
            // demonstrates: rotate_extrude() of complex polygon
            rotate_extrude(angle = 360, convexity = 6)
            polygon(points = full_profile);

            // Rim detail — minkowski of torus profile
            // demonstrates: minkowski() for rim smoothing
            translate([0, 0, vase_height])
            minkowski() {
                rotate_extrude(angle = 360)
                translate([neck_r - 1, 0, 0])
                square([1, 2], center = true);

                // demonstrates: minkowski() with sphere
                sphere(r = 1.2, $fn = 16);
            }
        }

        // Surface texture — grid of shallow dimples
        // demonstrates: list comprehension + nested for loop
        if (decoration) {
            dimple_rows    = 6;
            dimples_per_row = 16;

            // demonstrates: list comprehension generating positions
            dimple_positions = [
                for (row = [0 : dimple_rows - 1])
                for (col = [0 : dimples_per_row - 1])
                let(
                    h     = vase_height * 0.15 + row * (vase_height * 0.55 / dimple_rows),
                    angle = col * (360 / dimples_per_row) + (row % 2) * (180 / dimples_per_row),
                    // radius at this height — interpolate from profile
                    t     = h / vase_height,
                    r_h   = base_r + (body_max_r - base_r) * sin(t * 180) - 1
                )
                [r_h, angle, h]
            ];

            // demonstrates: for loop over comprehension-generated list
            for (pos = dimple_positions) {
                r     = pos[0];
                angle = pos[1];
                h     = pos[2];

                rotate([0, 0, angle])
                translate([r, 0, h])
                // Shallow sphere dimple cut into surface
                sphere(r = 1.8, $fn = 12);
            }
        }
    }
}

// ============================================================
//  MODULE: vase_base_ring
//  Decorative base ring — shared across all vase styles.
//  demonstrates: minkowski() for a soft-edged ring
// ============================================================
module vase_base_ring(r) {
    // demonstrates: minkowski() — square profile smoothed into ring
    minkowski() {
        rotate_extrude(angle = 360)
        translate([r * 0.7, 0, 0])
        square([r * 0.25, 2], center = true);

        // demonstrates: minkowski() with sphere for edge softening
        sphere(r = 1.5, $fn = 16);
    }
}

// ============================================================
//  ASSEMBLY — render selected vase or all three
//  demonstrates: if/else flow control for variant selection
// ============================================================
module render_vases() {

    // demonstrates: if/else chain — flow control
    if (vase_style == 1 || vase_style == 0) {
        color([0.85, 0.78, 0.68])
        translate(vase_style == 0 ? [-(body_max_r * 2 + 15), 0, 0] : [0, 0, 0])
        union() {
            vase_1_minkowski();
            translate([0, 0, -2])
            vase_base_ring(base_r);
        }
    }

    if (vase_style == 2 || vase_style == 0) {
        color([0.65, 0.72, 0.78])
        translate(vase_style == 0 ? [0, 0, 0] : [0, 0, 0])
        union() {
            vase_2_hull();
            translate([0, 0, -2])
            vase_base_ring(base_r);
        }
    }

    if (vase_style == 3 || vase_style == 0) {
        color([0.72, 0.68, 0.75])
        translate(vase_style == 0 ? [body_max_r * 2 + 15, 0, 0] : [0, 0, 0])
        union() {
            vase_3_sculpted();
            translate([0, 0, -2])
            vase_base_ring(base_r * 0.85);
        }
    }
}

// --- RENDER ---
render_vases();

// ============================================================
//  TECHNIQUE DEMOS — uncomment to study each in isolation:
//
//  Minkowski smoothing demo (cube + sphere):
//  minkowski() { cube([30,20,40], center=true); sphere(4); }
//
//  Hull bridging demo (two different circles):
//  hull() { cylinder(r=30, h=1); translate([0,0,50]) cylinder(r=10,h=1); }
//
//  Profile only (2D, use F5):
//  polygon(points = concat(
//    [[base_r,0],[body_max_r, vase_height*0.4],[neck_r, vase_height]],
//    [[neck_r - wall_thickness, vase_height],[base_r - wall_thickness, 2]]
//  ));
// ============================================================

// ============================================================
//  END OF PROJECT 05
//  Key techniques: minkowski(), hull(), rotate_extrude,
//  list comprehensions for surface patterns, $fn/$fa/$fs
// ============================================================
