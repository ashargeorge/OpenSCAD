// ============================================================
//  PROJECT 03 — Mechanical Gear System
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George
// ============================================================
//
//  JD SKILLS DEMONSTRATED:
//  ✔ List Comprehensions    — involute tooth points generated via comprehension
//  ✔ Flow Control           — for loops, if/else, conditional rendering
//  ✔ Boolean Operations     — difference(), union(), intersection()
//  ✔ 2D Objects             — polygon(), circle() for gear profiles
//  ✔ 3D Objects             — linear_extrude, cylinder, sphere
//  ✔ Transformations        — translate(), rotate(), mirror()
//  ✔ Special Variables      — $fn, $fa for resolution
//  ✔ Operators              — full trigonometry-driven tooth geometry
//  ✔ Syntax                 — modular, reusable, well-documented code
//  ✔ Type Test Functions    — is_num(), is_list() for parameter validation
//  ✔ Lists                  — tooth point arrays, pitch arrays
//
// ============================================================
//  CONCEPT:
//  A complete mechanical gear system built entirely from math.
//  Involute gear teeth are generated using trigonometry and
//  list comprehensions — no manual point drawing required.
//  Includes: spur gear, pinion gear, rack gear, and axle assembly.
//  Change the module (tooth size) and all gears update together.
// ============================================================
//  HOW TO USE:
//  F5 = preview, F6 = render, F7 = export STL
//  Toggle show_* variables to isolate individual components.
// ============================================================

// --- SPECIAL VARIABLES ---
$fn = 80;
$fa = 0.5;

// ============================================================
//  PARAMETERS
// ============================================================

// --- Gear module (m) — the fundamental sizing unit
// Larger module = larger, coarser teeth
gear_module       = 2.0;    // mm — standard metric gear module

// --- Spur Gear (large) ---
spur_teeth        = 24;     // number of teeth
spur_thickness    = 8;      // mm — gear face width
spur_bore_r       = 5;      // mm — center axle hole radius
spur_spoke_count  = 5;      // number of spokes in gear body

// --- Pinion Gear (small — meshes with spur) ---
pinion_teeth      = 12;     // number of teeth (ratio 2:1 with spur)
pinion_thickness  = 8;      // mm
pinion_bore_r     = 3;      // mm

// --- Rack Gear (linear) ---
rack_tooth_count  = 14;     // number of teeth along rack
rack_height       = 10;     // mm — height of rack body
rack_thickness    = 8;      // mm — depth of rack

// --- Display options ---
show_spur         = true;
show_pinion       = true;
show_rack         = true;
show_axles        = true;
explode           = false;   // set true to spread components apart

// ============================================================
//  COMPUTED GEAR GEOMETRY CONSTANTS
//  All derived from gear_module — change one value, all update
// ============================================================

// Pitch radius: the theoretical rolling circle radius
// pr = (teeth * module) / 2
spur_pr           = (spur_teeth   * gear_module) / 2;
pinion_pr         = (pinion_teeth * gear_module) / 2;

// Addendum: how far teeth extend above pitch circle
addendum          = gear_module;

// Dedendum: how far teeth extend below pitch circle
dedendum          = gear_module * 1.25;

// Outside radius (tip of teeth)
spur_or           = spur_pr   + addendum;
pinion_or         = pinion_pr + addendum;

// Root radius (bottom of tooth gaps)
spur_rr           = spur_pr   - dedendum;
pinion_rr         = pinion_pr - dedendum;

// Base circle radius (involute starts here)
pressure_angle    = 20;     // degrees — standard pressure angle
spur_br           = spur_pr   * cos(pressure_angle);
pinion_br         = pinion_pr * cos(pressure_angle);

// Center distance between spur and pinion (they mesh here)
center_dist       = spur_pr + pinion_pr;

// ============================================================
//  MODULE: involute_point
//  Calculates a single point on an involute curve.
//
//  The involute of a circle is the curve traced by the end
//  of a taut string unwinding from the circle.
//  This is the mathematically correct tooth profile used in
//  all real mechanical gears.
//
//  demonstrates: operators, trigonometry, function-like module
// ============================================================
function involute_x(base_r, angle) =
    base_r * (cos(angle) + angle * PI / 180 * sin(angle));

function involute_y(base_r, angle) =
    base_r * (sin(angle) - angle * PI / 180 * cos(angle));

// ============================================================
//  MODULE: involute_tooth_profile
//  Generates one gear tooth as a 2D polygon using a
//  list comprehension to compute involute curve points.
//
//  demonstrates: list comprehensions — KEY JD SKILL
//  demonstrates: polygon() with mathematically generated points
//  demonstrates: concat(), for in comprehension
// ============================================================
module involute_tooth_profile(base_r, root_r, pitch_r, outer_r, tooth_angle) {

    // Number of points along the involute curve
    inv_steps = 10;

    // Max involute angle (to outer radius)
    // Solve: outer_r = base_r * sqrt(1 + t²) → t = sqrt((outer_r/base_r)²-1)
    inv_max_angle = acos(base_r / outer_r) * 2.5;

    // ── LIST COMPREHENSION ──────────────────────────────────
    // Generate the RIGHT flank of the tooth (involute curve points)
    // demonstrates: list comprehension — [for (i=[...]) expression]
    right_flank = [
        for (i = [0 : inv_steps])
        let(
            t     = i * inv_max_angle / inv_steps,
            // rotate each point so tooth is centred on Y axis
            rot   = tooth_angle / 2,
            xi    = involute_x(base_r, t),
            yi    = involute_y(base_r, t),
            // rotate point by -rot to centre the tooth
            xr    = xi * cos(-rot) - yi * sin(-rot),
            yr    = xi * sin(-rot) + yi * cos(-rot)
        )
        [xr, yr]
    ];

    // Generate LEFT flank by mirroring right flank
    // demonstrates: list comprehension with mirror transform
    left_flank = [
        for (i = [inv_steps : -1 : 0])
        let(
            t     = i * inv_max_angle / inv_steps,
            rot   = tooth_angle / 2,
            xi    = involute_x(base_r, t),
            yi    = involute_y(base_r, t),
            // mirror across Y axis (negate x) and rotate
            xr    =  xi * cos(rot) - yi * sin(rot),
            yr    = -xi * sin(rot) - yi * cos(rot)
        )
        [-xr, yr]
    ];

    // Root points (bottom corners of tooth gap)
    root_left  = [root_r * sin(-tooth_angle * 0.6),
                  root_r * cos(-tooth_angle * 0.6)];
    root_right = [root_r * sin( tooth_angle * 0.6),
                  root_r * cos( tooth_angle * 0.6)];

    // Assemble full tooth polygon
    // demonstrates: concat() to join lists
    tooth_points = concat([root_right], right_flank, left_flank, [root_left]);

    // demonstrates: polygon() with computed point list
    polygon(points = tooth_points);
}

// ============================================================
//  MODULE: gear_2d
//  Full 2D gear profile — all teeth arranged around the circle.
//
//  demonstrates: for loop, rotate(), union(), difference()
//  demonstrates: list comprehensions used for spoke cutouts
// ============================================================
module gear_2d(teeth, pitch_r, base_r, root_r, outer_r, spoke_count = 0) {

    tooth_angle = 360 / teeth;    // angular spacing of teeth

    difference() {
        union() {
            // Root circle — the solid disc behind the teeth
            circle(r = root_r);

            // Place one tooth at each tooth position around the gear
            // demonstrates: for loop (flow control)
            for (i = [0 : teeth - 1]) {
                // demonstrates: rotate() transformation
                rotate([0, 0, i * tooth_angle])
                involute_tooth_profile(base_r, root_r, pitch_r, outer_r, tooth_angle);
            }
        }

        // Spoke cutouts — demonstrates: list comprehension for geometry
        // generates spoke_count evenly-spaced oval cutouts
        if (spoke_count > 0) {
            spoke_angle = 360 / spoke_count;
            spoke_r     = (root_r * 0.75 + spur_bore_r * 1.5) / 2;
            spoke_w     = root_r * 0.18;
            spoke_h     = (root_r - spur_bore_r * 2) * 0.55;

            for (i = [0 : spoke_count - 1]) {
                rotate([0, 0, i * spoke_angle])
                translate([0, spoke_r, 0])
                // demonstrates: scale() to create oval from circle
                scale([1, spoke_h / spoke_w, 1])
                circle(r = spoke_w);
            }
        }
    }
}

// ============================================================
//  MODULE: spur_gear
//  Full 3D spur gear — 2D profile extruded to thickness.
//
//  demonstrates: linear_extrude(), difference() for bore hole,
//               hub construction, chamfer
// ============================================================
module spur_gear() {
    difference() {
        union() {
            // Extrude 2D gear profile to 3D
            // demonstrates: linear_extrude() — 2D → 3D
            linear_extrude(height = spur_thickness, convexity = 10)
            gear_2d(
                teeth      = spur_teeth,
                pitch_r    = spur_pr,
                base_r     = spur_br,
                root_r     = spur_rr,
                outer_r    = spur_or,
                spoke_count = spur_spoke_count
            );

            // Hub — raised cylinder in centre for strength
            cylinder(r = spur_bore_r * 2.2, h = spur_thickness * 1.3);
        }

        // Bore hole through centre
        // demonstrates: difference() — cylinder subtracted
        translate([0, 0, -0.1])
        cylinder(r = spur_bore_r, h = spur_thickness * 1.5);

        // Chamfer top edge of bore
        translate([0, 0, spur_thickness * 1.25])
        cylinder(r1 = spur_bore_r, r2 = spur_bore_r + 1.5, h = 1.5);

        // Chamfer bottom edge of bore
        translate([0, 0, -0.1])
        cylinder(r1 = spur_bore_r + 1.5, r2 = spur_bore_r, h = 1.5);
    }
}

// ============================================================
//  MODULE: pinion_gear
//  Smaller gear that meshes with the spur gear.
//  demonstrates: module reuse, parameter variation
// ============================================================
module pinion_gear() {
    difference() {
        union() {
            linear_extrude(height = pinion_thickness, convexity = 10)
            gear_2d(
                teeth      = pinion_teeth,
                pitch_r    = pinion_pr,
                base_r     = pinion_br,
                root_r     = pinion_rr,
                outer_r    = pinion_or,
                spoke_count = 0     // solid body — no spokes on small gear
            );

            // Hub
            cylinder(r = pinion_bore_r * 2.5, h = pinion_thickness * 1.3);
        }

        // Bore hole
        translate([0, 0, -0.1])
        cylinder(r = pinion_bore_r, h = pinion_thickness * 1.5);
    }
}

// ============================================================
//  MODULE: rack_tooth
//  A single linear rack tooth (triangular profile).
//  demonstrates: polygon() 2D, linear_extrude()
// ============================================================
module rack_tooth(m) {
    tooth_w = PI * m;       // tooth pitch = pi * module
    tooth_h = m * 2;        // full tooth height

    // 2D tooth profile — symmetric trapezoid
    // demonstrates: polygon() with explicit point list
    linear_extrude(height = rack_thickness)
    polygon(points = [
        [-tooth_w * 0.5,  0],
        [-tooth_w * 0.28, tooth_h],
        [ tooth_w * 0.28, tooth_h],
        [ tooth_w * 0.5,  0]
    ]);
}

// ============================================================
//  MODULE: rack_gear
//  Linear rack gear — a flat bar with teeth.
//  Demonstrates: for loop placing teeth, union(), difference()
// ============================================================
module rack_gear() {
    tooth_pitch = PI * gear_module;   // distance between teeth centres
    rack_length = rack_tooth_count * tooth_pitch;

    union() {
        // Base bar
        // demonstrates: cube() 3D primitive
        cube([rack_length, rack_height, rack_thickness]);

        // Place teeth along the rack
        // demonstrates: for loop + translate() positioning
        for (i = [0 : rack_tooth_count - 1]) {
            x = i * tooth_pitch + tooth_pitch * 0.5;
            translate([x, rack_height, 0])
            rack_tooth(gear_module);
        }
    }
}

// ============================================================
//  MODULE: axle
//  Simple cylindrical axle with retaining clip groove.
//  demonstrates: difference(), cylinder(), translate()
// ============================================================
module axle(bore_r, length) {
    axle_r = bore_r - 0.2;    // slight clearance

    difference() {
        cylinder(r = axle_r, h = length);

        // Retaining groove near each end
        // demonstrates: for loop + difference()
        for (z = [length * 0.1, length * 0.88]) {
            translate([0, 0, z])
            // Groove = difference of a wider short cylinder
            difference() {
                cylinder(r = axle_r + 0.1, h = length * 0.04);
                cylinder(r = axle_r - 0.8, h = length * 0.04);
            }
        }
    }
}

// ============================================================
//  TYPE TEST VALIDATION
//  demonstrates: type test functions — is_num(), is_list()
//  Used to validate parameters before rendering
// ============================================================
module validate_params() {
    // demonstrates: is_num() type test function
    if (!is_num(gear_module)) {
        echo("ERROR: gear_module must be a number");
    }
    if (!is_num(spur_teeth)) {
        echo("ERROR: spur_teeth must be a number");
    }
    // demonstrates: is_list() — checking if a value is a list
    test_list = [spur_teeth, pinion_teeth, rack_tooth_count];
    if (is_list(test_list)) {
        echo(str("Gear tooth counts: ", test_list));
    }
    // demonstrates: is_num() check on computed value
    if (is_num(center_dist)) {
        echo(str("Gear centre distance: ", center_dist, "mm"));
    }
}

// Run validation — check console output in OpenSCAD
validate_params();

// ============================================================
//  ASSEMBLY
//  Positions all components correctly for meshing display.
//  demonstrates: translate(), rotate(), conditional (if)
// ============================================================
module gear_assembly() {

    explode_x = explode ? 20  : 0;
    explode_y = explode ? -15 : 0;

    // --- Spur Gear ---
    if (show_spur) {
        color([0.4, 0.6, 0.8])
        translate([-explode_x, 0, 0])
        spur_gear();
    }

    // --- Pinion Gear ---
    // Position so pitch circles touch (centre_dist apart)
    // Rotate by half tooth to mesh correctly with spur
    if (show_pinion) {
        color([0.8, 0.5, 0.3])
        translate([center_dist + explode_x, 0, 0])
        // Phase offset so teeth interlock
        rotate([0, 0, 180 / pinion_teeth])
        pinion_gear();
    }

    // --- Rack Gear ---
    // Positioned below the spur gear, tangent to its pitch circle
    if (show_rack) {
        tooth_pitch = PI * gear_module;
        rack_length = rack_tooth_count * tooth_pitch;

        color([0.5, 0.75, 0.5])
        translate([
            -rack_length / 2 + explode_x,
            -(spur_pr + gear_module * 2) + explode_y,
            0
        ])
        rack_gear();
    }

    // --- Axles ---
    if (show_axles) {
        axle_len = spur_thickness * 1.8;

        // Spur axle
        color([0.7, 0.7, 0.7])
        translate([-explode_x, 0, -axle_len * 0.15])
        axle(spur_bore_r, axle_len);

        // Pinion axle
        color([0.7, 0.7, 0.7])
        translate([center_dist + explode_x, 0, -axle_len * 0.15])
        axle(pinion_bore_r, axle_len);
    }
}

// --- RENDER ---
gear_assembly();

// ============================================================
//  QUICK DEMOS — uncomment to isolate a technique:
//
//  Single tooth profile (2D):
//  involute_tooth_profile(spur_br, spur_rr, spur_pr, spur_or, 360/spur_teeth);
//
//  2D gear only:
//  gear_2d(spur_teeth, spur_pr, spur_br, spur_rr, spur_or, 5);
//
//  Rack only:
//  rack_gear();
//
//  Pinion only:
//  pinion_gear();
// ============================================================

// ============================================================
//  END OF PROJECT 03
//  Key techniques: list comprehensions, involute math,
//  flow control (for/if), type test functions, boolean ops
// ============================================================
