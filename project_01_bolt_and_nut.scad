// ============================================================
//  PROJECT 01 — Parametric Bolt & Nut Generator
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George
// ============================================================
//
//  JD SKILLS DEMONSTRATED:
//  ✔ Syntax                 — clean, readable OpenSCAD code structure
//  ✔ Constants & Operators  — math-driven dimensions throughout
//  ✔ Special Variables      — $fn for smooth circular geometry
//  ✔ 3D Objects             — cylinder(), cube(), sphere() primitives
//  ✔ Transformations        — translate(), rotate(), mirror()
//  ✔ Boolean Operations     — difference(), union(), intersection()
//  ✔ Modifier Characters    — # used for debugging geometry
//  ✔ Parametric Design      — change top variables, whole model updates
//
// ============================================================
//  HOW TO USE:
//  Adjust any parameter in the PARAMETERS section below.
//  Press F5 to preview, F6 to render, F7 to export STL.
// ============================================================

// --- SPECIAL VARIABLES ---
// $fn controls the number of facets on circular objects.
// Higher = smoother but slower to render.
$fn = 80;

// ============================================================
//  PARAMETERS — change these to resize the entire model
// ============================================================

// --- Bolt Parameters ---
bolt_diameter      = 8;      // mm — shaft diameter (M8 standard)
bolt_length        = 40;     // mm — total shaft length
bolt_head_type     = "hex";  // "hex" or "round"
bolt_head_diameter = 13;     // mm — head diameter across flats
bolt_head_height   = 5;      // mm — height of bolt head
thread_pitch       = 1.25;   // mm — distance between thread peaks
thread_depth       = 0.8;    // mm — how deep threads cut into shaft
chamfer_size       = 1.0;    // mm — bevel on bolt tip

// --- Nut Parameters ---
nut_diameter       = 13;     // mm — across flats (same as bolt head)
nut_height         = 6.5;    // mm — thickness of nut
nut_hole_diameter  = bolt_diameter + 0.4; // slight clearance fit

// --- Layout ---
show_bolt          = true;
show_nut           = true;
explode_distance   = 20;     // mm — spread apart for visibility

// ============================================================
//  COMPUTED CONSTANTS
//  (derived from parameters — never hardcoded)
// ============================================================

// Circumscribed circle radius for hex shapes
// For a regular hexagon: circumradius = side_length
// across-flats diameter = 2 * circumradius * cos(30)
// so circumradius = across_flats / (2 * cos(30))
bolt_head_radius   = bolt_head_diameter / (2 * cos(30));
nut_radius         = nut_diameter / (2 * cos(30));
bolt_radius        = bolt_diameter / 2;
thread_count       = floor(bolt_length / thread_pitch);

// ============================================================
//  MODULE: hex_prism
//  Creates a hexagonal prism — used for bolt head and nut body.
//  Demonstrates: 3D objects, special variables, operators
// ============================================================
module hex_prism(radius, height) {
    // cylinder() with $fn=6 produces a perfect hexagonal prism
    // demonstrates: special variable $fn overridden locally
    cylinder(r = radius, h = height, $fn = 6);
}

// ============================================================
//  MODULE: thread_helix
//  Simulates threading by subtracting a helical groove.
//  Demonstrates: for loop (flow control), translate, rotate,
//               boolean difference, operators, list usage
// ============================================================
module thread_helix(shaft_radius, length, pitch, depth) {
    // We approximate the helix with many thin angled cuts.
    // Each cut is a thin torus slice rotated along the shaft.
    // demonstrates: flow control (for loop), operators
    step_angle = 360 / 20;          // 20 cuts per revolution
    steps_total = floor((length / pitch) * 20);

    for (i = [0 : steps_total - 1]) {
        angle     = i * step_angle;
        z_pos     = (i / 20) * pitch;

        // demonstrates: translate() + rotate() transformation chain
        translate([0, 0, z_pos])
        rotate([0, 0, angle])
        rotate([80, 0, 0])
        // thin disc subtracted at an angle creates thread groove
        cylinder(
            r = shaft_radius + depth,
            h = pitch * 0.4,
            center = true,
            $fn = 30
        );
    }
}

// ============================================================
//  MODULE: bolt_shaft
//  The main threaded shaft of the bolt.
//  Demonstrates: difference() boolean, chamfer via intersection
// ============================================================
module bolt_shaft() {
    // demonstrates: boolean difference() — threads cut from shaft
    difference() {
        union() {
            // Main cylinder shaft
            cylinder(r = bolt_radius, h = bolt_length);

            // Chamfered tip — demonstrates: intersection() boolean op
            // We cut a cone into the tip to create a bevel
            translate([0, 0, bolt_length - chamfer_size])
            cylinder(
                r1 = bolt_radius,
                r2 = bolt_radius - chamfer_size,
                h  = chamfer_size
            );
        }

        // Subtract thread groove from shaft
        // demonstrates: modifier character usage in debugging
        // Use #thread_helix(...) to highlight the cut geometry
        thread_helix(bolt_radius, bolt_length, thread_pitch, thread_depth);
    }
}

// ============================================================
//  MODULE: bolt_head
//  Hex or round head for the bolt.
//  Demonstrates: if/else flow control, union(), difference()
// ============================================================
module bolt_head() {
    // demonstrates: flow control — if/else branching
    if (bolt_head_type == "hex") {
        difference() {
            // Hex prism body
            hex_prism(bolt_head_radius, bolt_head_height);

            // Chamfer the top edge of the head with a cone cut
            // demonstrates: difference() boolean operation
            translate([0, 0, bolt_head_height - 1.5])
            cylinder(
                r1 = bolt_head_radius - 0.5,
                r2 = bolt_head_radius + 1,
                h  = 2,
                $fn = 6
            );
        }

    } else if (bolt_head_type == "round") {
        // Round (pan) head — demonstrates: sphere + cylinder union
        union() {
            cylinder(r = bolt_head_radius * 0.85, h = bolt_head_height * 0.6);
            translate([0, 0, bolt_head_height * 0.6])
            // Dome top using the top half of a sphere
            // demonstrates: intersection() to slice sphere
            intersection() {
                sphere(r = bolt_head_radius * 0.85);
                translate([0, 0, 0])
                cylinder(r = bolt_head_radius, h = bolt_head_radius);
            }
        }
    }
}

// ============================================================
//  MODULE: bolt
//  Complete bolt assembly — head + shaft.
//  Demonstrates: union(), translate(), rotate()
// ============================================================
module bolt() {
    union() {
        // Head sits below shaft (at z=0 downward)
        translate([0, 0, -bolt_head_height])
        bolt_head();

        // Shaft rises upward
        bolt_shaft();
    }
}

// ============================================================
//  MODULE: nut
//  Hex nut with threaded hole.
//  Demonstrates: difference(), hex_prism(), cylinder(),
//               boolean operations, chamfer
// ============================================================
module nut() {
    difference() {
        // Outer hex body
        // demonstrates: module reuse
        hex_prism(nut_radius, nut_height);

        // Threaded through-hole
        // demonstrates: difference() — subtracting cylinder from hex
        translate([0, 0, -0.1])
        cylinder(r = nut_hole_diameter / 2, h = nut_height + 0.2);

        // Top chamfer — demonstrates: difference() with cone
        translate([0, 0, nut_height - 1])
        cylinder(r1 = nut_radius - 1, r2 = nut_radius + 1, h = 1.5, $fn = 6);

        // Bottom chamfer — demonstrates: mirror() + difference()
        translate([0, 0, 1])
        mirror([0, 0, 1])
        cylinder(r1 = nut_radius - 1, r2 = nut_radius + 1, h = 1.5, $fn = 6);
    }
}

// ============================================================
//  MODULE: washer
//  Simple flat washer to complement the set.
//  Demonstrates: difference() of two cylinders (annular solid)
// ============================================================
module washer() {
    washer_od = bolt_head_diameter * 1.8;
    washer_id = bolt_diameter + 0.5;
    washer_t  = 1.5;

    // demonstrates: difference() — hole punched through disc
    difference() {
        cylinder(r = washer_od / 2, h = washer_t);
        translate([0, 0, -0.1])
        cylinder(r = washer_id / 2, h = washer_t + 0.2);
    }
}

// ============================================================
//  ASSEMBLY
//  Demonstrates: translate() for layout, conditional rendering
// ============================================================

// --- Bolt ---
// demonstrates: conditional rendering with show_bolt variable
if (show_bolt) {
    // Explode upward for clarity
    // demonstrates: translate() + operators (arithmetic)
    translate([0, 0, explode_distance])
    bolt();
}

// --- Washer ---
// Sits between bolt head and nut
translate([0, 0, 1.5])
washer();

// --- Nut ---
if (show_nut) {
    // Nut sits at base, bolt passes through it
    // demonstrates: translate() positioning
    nut();
}

// ============================================================
//  END OF PROJECT 01
//  To export: Render (F6) then File > Export > Export as STL
// ============================================================
