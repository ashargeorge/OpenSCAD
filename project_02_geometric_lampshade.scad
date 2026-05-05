// ============================================================
//  PROJECT 02 — Geometric Lampshade
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George
// ============================================================
//
//  JD SKILLS DEMONSTRATED:
//  ✔ 2D Objects             — polygon(), circle(), square()
//  ✔ 3D Objects             — cylinder(), sphere() as base primitives
//  ✔ linear_extrude         — 2D profile extruded with twist into 3D
//  ✔ rotate_extrude         — 2D profile swept 360° to create solid of revolution
//  ✔ Transformations        — translate(), rotate(), mirror(), scale()
//  ✔ Boolean Operations     — difference(), union() for cutouts & assembly
//  ✔ Special Variables      — $fn, $fa for resolution control
//  ✔ Syntax & Operators     — math-driven profile points, trigonometry
//  ✔ Flow Control           — for loops generating decorative vent slots
//  ✔ 3D from 2D Shadows     — entire lamp body built by sweeping a 2D cross-section
//
// ============================================================
//  CONCEPT:
//  This lampshade is built the way industrial designers think —
//  draw the 2D silhouette (cross-section profile), then sweep
//  it around the vertical axis using rotate_extrude() to
//  instantly create a perfect solid of revolution.
//  The base uses linear_extrude() with a twist parameter to
//  create a spiralled geometric collar.
// ============================================================
//  HOW TO USE:
//  Adjust parameters below. F5 = preview, F6 = render, F7 = export STL.
// ============================================================

// --- SPECIAL VARIABLES ---
$fn = 120;   // high resolution for smooth curves
$fa = 1;     // minimum angle for arcs

// ============================================================
//  PARAMETERS
// ============================================================

// --- Shade dimensions ---
shade_top_r       = 12;    // mm — radius at top opening
shade_bottom_r    = 55;    // mm — radius at bottom opening
shade_height      = 80;    // mm — total height of shade
shade_thickness   = 2.5;   // mm — wall thickness
shade_flare       = 18;    // mm — outward curve/flare of profile

// --- Vent slots (decorative cutouts around shade) ---
vent_count        = 12;    // number of slots around circumference
vent_width        = 6;     // mm — width of each slot
vent_height       = 25;    // mm — height of each slot
vent_radius       = 3;     // mm — rounded ends on slots
vent_z_offset     = 20;    // mm — height from bottom where vents start

// --- Collar / base ring (linear_extrude with twist) ---
collar_height     = 18;    // mm — height of twisted collar
collar_r          = shade_bottom_r + 4;  // outer radius
collar_thickness  = 4;     // mm — wall thickness
collar_twist      = 45;    // degrees — twist applied during extrusion
collar_sides      = 16;    // polygon sides for collar cross-section

// --- Cap (top closure with hanging hole) ---
cap_height        = 8;     // mm — height of top cap
cap_hole_r        = 5;     // mm — radius of cord/hanging hole

// ============================================================
//  COMPUTED CONSTANTS
// ============================================================
shade_inner_top_r    = shade_top_r - shade_thickness;
shade_inner_bottom_r = shade_bottom_r - shade_thickness;

// ============================================================
//  MODULE: shade_profile
//  The 2D cross-section of the lampshade wall.
//  This is the core of the rotate_extrude technique —
//  define the shape in 2D, sweep it to get the 3D form.
//
//  demonstrates: 2D polygon(), operators, math-driven points
// ============================================================
module shade_profile() {
    // The profile is a 2D closed polygon representing
    // a vertical slice through the shade wall.
    // X axis = radial distance from center
    // Y axis = height (Z after rotate_extrude)
    //
    // We use a bezier-like curve approximation with extra
    // midpoints to create the gentle flare/bell shape.
    //
    // demonstrates: polygon() 2D object with computed points
    polygon(points = [
        // Outer profile — bottom to top (the flared outer wall)
        [shade_bottom_r,              0],
        [shade_bottom_r + shade_flare * 0.15,  shade_height * 0.15],
        [shade_bottom_r + shade_flare * 0.05,  shade_height * 0.35],
        [shade_bottom_r - shade_flare * 0.3,   shade_height * 0.55],
        [shade_bottom_r - shade_flare * 0.6,   shade_height * 0.75],
        [shade_top_r,                           shade_height],

        // Inner profile — top to bottom (offset inward by thickness)
        [shade_inner_top_r,                     shade_height],
        [shade_inner_top_r + shade_flare * 0.25, shade_height * 0.75],
        [shade_inner_bottom_r + shade_flare * 0.35, shade_height * 0.55],
        [shade_inner_bottom_r + shade_flare * 0.1,  shade_height * 0.35],
        [shade_inner_bottom_r + shade_flare * 0.2,  shade_height * 0.15],
        [shade_inner_bottom_r,                  0]
    ]);
}

// ============================================================
//  MODULE: shade_body
//  Sweeps the 2D profile 360° around the Z axis.
//
//  demonstrates: rotate_extrude() — KEY JD SKILL
//  This is the most important technique in this project.
//  rotate_extrude takes any 2D shape defined in the XY plane
//  and revolves it around the Y axis to produce a 3D solid.
// ============================================================
module shade_body() {
    // demonstrates: rotate_extrude() — 2D profile → 3D solid of revolution
    rotate_extrude(angle = 360, convexity = 4)
    shade_profile();
}

// ============================================================
//  MODULE: vent_slot
//  A single rounded-rectangle vent cutout.
//  demonstrates: 2D objects, linear_extrude, union, circle
// ============================================================
module vent_slot() {
    // Build the vent shape as a 2D rounded rectangle
    // then extrude it radially outward through the shade wall.
    //
    // demonstrates: linear_extrude() — 2D shape → 3D solid
    // demonstrates: union() of circles and square for stadium shape
    linear_extrude(height = shade_bottom_r * 2 + 20, center = true)
    union() {
        // Stadium shape: rectangle + semicircle top + semicircle bottom
        square([vent_width - vent_radius * 2, vent_height], center = true);

        translate([0,  vent_height / 2]) circle(r = vent_width / 2 - 0.5);
        translate([0, -vent_height / 2]) circle(r = vent_width / 2 - 0.5);
    }
}

// ============================================================
//  MODULE: vent_ring
//  Places vent_count slots evenly around the shade.
//
//  demonstrates: for loop (flow control), rotate(), operators
// ============================================================
module vent_ring() {
    // demonstrates: flow control — for loop with angle calculation
    for (i = [0 : vent_count - 1]) {
        angle = i * (360 / vent_count);   // evenly distribute

        // demonstrates: rotate() transformation
        rotate([0, 0, angle])
        translate([0, 0, vent_z_offset + vent_height / 2])
        // Rotate slot so it cuts radially through the shade wall
        rotate([90, 0, 0])
        vent_slot();
    }
}

// ============================================================
//  MODULE: shade_with_vents
//  Combines shade body with vent cutouts.
//
//  demonstrates: difference() boolean operation
// ============================================================
module shade_with_vents() {
    // demonstrates: difference() — subtract vent slots from shade body
    difference() {
        shade_body();
        vent_ring();
    }
}

// ============================================================
//  MODULE: collar_cross_section
//  The 2D polygon cross-section for the twisted collar.
//  A regular polygon that will be extruded with twist.
//
//  demonstrates: 2D polygon(), circle(), special variables
// ============================================================
module collar_cross_section() {
    // Ring cross-section: outer polygon minus inner circle
    // demonstrates: 2D boolean — difference on 2D shapes
    difference() {
        // Outer polygon — regular n-sided shape
        // demonstrates: circle() with $fn override for polygon effect
        circle(r = collar_r, $fn = collar_sides);

        // Inner cutout — creates the ring/tube wall
        circle(r = collar_r - collar_thickness, $fn = collar_sides);
    }
}

// ============================================================
//  MODULE: twisted_collar
//  Extrudes the collar cross-section with a twist.
//
//  demonstrates: linear_extrude() with twist parameter — KEY JD SKILL
//  The twist parameter rotates the 2D profile as it rises,
//  creating a helical/spiralled 3D form from a flat 2D shape.
// ============================================================
module twisted_collar() {
    // demonstrates: linear_extrude() with twist — 2D → twisted 3D solid
    linear_extrude(
        height   = collar_height,
        twist    = collar_twist,    // degrees of rotation over height
        slices   = 40,              // smoothness of twist
        convexity = 6
    )
    collar_cross_section();
}

// ============================================================
//  MODULE: top_cap
//  Closes the top of the shade with a cap and hanging hole.
//
//  demonstrates: difference(), cylinder(), 3D primitives
// ============================================================
module top_cap() {
    difference() {
        union() {
            // Flat disc cap
            cylinder(r = shade_top_r, h = cap_height);

            // Decorative dome on top
            // demonstrates: translate() + sphere() primitive
            translate([0, 0, cap_height])
            sphere(r = shade_top_r * 0.7);
        }

        // Hanging cord hole through center
        // demonstrates: difference() — cylinder subtracted for hole
        translate([0, 0, -0.1])
        cylinder(r = cap_hole_r, h = cap_height + shade_top_r + 0.2);
    }
}

// ============================================================
//  MODULE: rim_detail
//  Decorative ring around the bottom opening.
//
//  demonstrates: rotate_extrude() of a simple circle (torus)
//  This creates a torus — a donut shape — which is the
//  simplest and most elegant use of rotate_extrude.
// ============================================================
module rim_detail() {
    // A torus is made by revolving a circle around an axis.
    // demonstrates: rotate_extrude() with translate() offset
    rotate_extrude(angle = 360, convexity = 4)
    translate([shade_bottom_r - shade_thickness / 2, 0, 0])
    circle(r = shade_thickness * 0.8);
}

// ============================================================
//  MODULE: cord_grip
//  Small gripping ridges at the top cap.
//  demonstrates: for loop, rotate_extrude, scale()
// ============================================================
module cord_grip() {
    ridge_count = 5;
    for (i = [0 : ridge_count - 1]) {
        z = cap_height * 0.3 + i * (cap_height * 0.12);
        translate([0, 0, z])
        // demonstrates: rotate_extrude of offset circle = torus ring
        rotate_extrude(angle = 360)
        translate([cap_hole_r + 0.8, 0, 0])
        circle(r = 0.6);
    }
}

// ============================================================
//  ASSEMBLY
//  demonstrates: translate(), union(), color() for visualization
// ============================================================
module lampshade_assembly() {
    // Main shade with vents
    // demonstrates: color() for visual clarity in preview
    color([0.9, 0.85, 0.7], 0.85)
    shade_with_vents();

    // Bottom rim detail ring
    color([0.6, 0.5, 0.3])
    rim_detail();

    // Twisted collar sits below the shade
    // demonstrates: translate() + mirror() for positioning
    color([0.7, 0.65, 0.5])
    translate([0, 0, -collar_height])
    twisted_collar();

    // Top cap — sits at top of shade
    color([0.6, 0.5, 0.3])
    translate([0, 0, shade_height])
    top_cap();

    // Cord grip rings inside the cap hole
    color([0.4, 0.35, 0.25])
    translate([0, 0, shade_height])
    cord_grip();
}

// --- RENDER ---
lampshade_assembly();

// ============================================================
//  VARIATIONS — uncomment to explore individual components:
//
//  rotate_extrude demo only:
//  rotate_extrude(angle=360) shade_profile();
//
//  linear_extrude with twist demo only:
//  linear_extrude(height=30, twist=90, slices=40) collar_cross_section();
//
//  Just the 2D profile (F5 only):
//  shade_profile();
//
//  Torus rim only:
//  rim_detail();
// ============================================================

// ============================================================
//  END OF PROJECT 02
//  Key techniques: rotate_extrude, linear_extrude with twist,
//  2D polygon profiles, boolean difference for vents
// ============================================================
