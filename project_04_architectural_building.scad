// ============================================================
//  PROJECT 04 — Architectural Building Block Set
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George Onwuemezie
// ============================================================
//
//  SKILLS DEMONSTRATED:
//  ✔ Modules & Nesting      — deeply nested reusable components
//  ✔ Boolean Operations     — difference(), union(), intersection()
//  ✔ Flow Control           — for loops, if/else, nested conditions
//  ✔ Lists                  — window/door configs stored as lists
//  ✔ List Comprehensions    — facade grid generation
//  ✔ Transformations        — translate(), rotate(), mirror(), scale()
//  ✔ 2D Objects             — polygon(), square(), circle() profiles
//  ✔ 3D Objects             — cube(), cylinder(), sphere() primitives
//  ✔ linear_extrude         — roof profile → 3D, arch profiles → 3D
//  ✔ Special Variables      — $fn for curved elements
//  ✔ Operators              — all dimensions math-derived
//  ✔ Modifier Characters    — % ghost modifier for design reference
//
// ============================================================
//  CONCEPT:
//  A fully modular architectural system. Each component —
//  wall, window, door, roof, arch, column — is a standalone
//  reusable module. They are assembled using lists to define
//  facade layouts, and for loops to place repeated elements.
//  Change one base unit and the entire building rescales.
// ============================================================
//  HOW TO USE:
//  F5 = preview, F6 = render, F7 = export STL
//  Toggle show_* to isolate components.
// ============================================================

$fn = 64;

// ============================================================
//  PARAMETERS — one unit drives everything
// ============================================================

// Base unit — all dimensions are multiples of this
U                 = 10;     // mm — base unit

// --- Building layout ---
building_bays     = 3;      // number of structural bays wide
building_floors   = 2;      // number of floors
bay_width         = U * 6;  // mm — width of each bay
floor_height      = U * 8;  // mm — height of each floor
wall_thickness    = U * 0.8; // mm

// --- Window parameters ---
win_width         = U * 2.8;
win_height        = U * 3.5;
win_sill_depth    = U * 0.4;
win_frame_t       = U * 0.25;

// --- Door parameters ---
door_width        = U * 3;
door_height       = U * 5.5;
door_arch_r       = door_width / 2;

// --- Roof parameters ---
roof_pitch        = U * 4;   // mm — height of roof peak above walls
roof_overhang     = U * 1.2;

// --- Column parameters ---
col_r             = U * 0.7;
col_height        = floor_height - U;
col_flute_count   = 8;

// --- Display toggles ---
show_walls        = true;
show_windows      = true;
show_door         = true;
show_roof         = true;
show_columns      = true;
show_floor_slab   = true;

// ============================================================
//  COMPUTED CONSTANTS
// ============================================================
total_width       = building_bays * bay_width;
total_height      = building_floors * floor_height;
building_depth    = bay_width * 1.4;

// ============================================================
//  MODULE: wall_panel
//  Basic solid wall panel — the fundamental building block.
//  demonstrates: cube(), operators for sizing
// ============================================================
module wall_panel(w, h, d) {
    cube([w, d, h]);
}

// ============================================================
//  MODULE: window_opening
//  A window cutout with frame and sill.
//  demonstrates: difference(), union(), translate(), cube()
// ============================================================
module window_opening(w, h) {
    // Outer cutout through wall
    // demonstrates: difference() removing material
    difference() {
        // Window frame (solid)
        cube([w, wall_thickness + win_sill_depth * 2, h]);

        // Glass opening (inner cutout)
        // demonstrates: translate() + difference()
        translate([win_frame_t, -0.1, win_frame_t])
        cube([
            w - win_frame_t * 2,
            wall_thickness + win_sill_depth * 2 + 0.2,
            h - win_frame_t * 2
        ]);

        // Horizontal glazing bar (cross divider)
        translate([-0.1, -0.1, h / 2 - win_frame_t / 2])
        cube([w + 0.2, wall_thickness + 0.2, win_frame_t]);

        // Vertical glazing bar
        translate([w / 2 - win_frame_t / 2, -0.1, win_frame_t])
        cube([win_frame_t, wall_thickness + 0.2, h - win_frame_t * 2]);
    }

    // Window sill — projects outward below window
    // demonstrates: translate() + cube() for additive geometry
    translate([-win_sill_depth * 0.5, -win_sill_depth, -win_sill_depth * 0.6])
    cube([w + win_sill_depth, win_sill_depth * 1.5, win_sill_depth]);
}

// ============================================================
//  MODULE: arched_door
//  A door with a semicircular arch top.
//  demonstrates: linear_extrude(), polygon(), circle(),
//               union(), difference(), boolean ops
// ============================================================
module arched_door(w, h, arch_r) {
    straight_h = h - arch_r;  // height of rectangular portion

    // Door opening shape — rectangle + semicircle arch
    // demonstrates: linear_extrude of 2D union shape
    linear_extrude(height = wall_thickness + 0.2)
    union() {
        // Rectangular lower portion
        // demonstrates: 2D square()
        square([w, straight_h]);

        // Semicircular arch top
        // demonstrates: 2D circle() clipped to semicircle
        translate([w / 2, straight_h, 0])
        circle(r = arch_r);
    }

    // Door frame (slightly larger than opening)
    difference() {
        linear_extrude(height = wall_thickness)
        union() {
            square([w + U * 0.6, straight_h + U * 0.3]);
            translate([w / 2 + U * 0.3, straight_h, 0])
            circle(r = arch_r + U * 0.3);
        }

        // Hollow out the frame
        translate([0, 0, -0.1])
        linear_extrude(height = wall_thickness + 0.2)
        union() {
            square([w, straight_h]);
            translate([w / 2, straight_h, 0])
            circle(r = arch_r);
        }
    }

    // Door panels (decorative inset rectangles)
    // demonstrates: for loop placing repeated elements
    panel_w = w * 0.38;
    panel_h = straight_h * 0.38;
    panel_positions = [
        [w * 0.08,  straight_h * 0.08],
        [w * 0.54,  straight_h * 0.08],
        [w * 0.08,  straight_h * 0.52],
        [w * 0.54,  straight_h * 0.52]
    ];

    // demonstrates: for loop over a list of positions
    for (pos = panel_positions) {
        translate([pos[0], -0.1, pos[1]])
        difference() {
            cube([panel_w, U * 0.3, panel_h]);
            translate([U * 0.15, -0.1, U * 0.15])
            cube([panel_w - U * 0.3, U * 0.4, panel_h - U * 0.3]);
        }
    }
}

// ============================================================
//  MODULE: fluted_column
//  A classical column with fluted shaft, base and capital.
//  demonstrates: difference(), for loop, cylinder(),
//               rotate(), linear_extrude, rotate_extrude
// ============================================================
module fluted_column(r, h, flutes) {
    // Column base (plinth)
    // demonstrates: cylinder() primitive
    cylinder(r = r * 1.8, h = U * 0.6);

    // Fluted shaft — cylinder with grooves cut around perimeter
    translate([0, 0, U * 0.6])
    difference() {
        cylinder(r = r, h = h);

        // Cut flute grooves around the shaft
        // demonstrates: for loop + rotate() for radial placement
        for (i = [0 : flutes - 1]) {
            angle = i * (360 / flutes);
            rotate([0, 0, angle])
            translate([r * 0.82, 0, -0.1])
            // demonstrates: cylinder as a cutting tool
            cylinder(r = r * 0.18, h = h + 0.2);
        }
    }

    // Column capital (top)
    // demonstrates: translate() + cylinder with r1/r2
    translate([0, 0, U * 0.6 + h])
    union() {
        // Echinus (curved swell) — tapered cylinder
        cylinder(r1 = r, r2 = r * 1.7, h = U * 0.5);
        // Abacus (flat slab on top)
        translate([0, 0, U * 0.5])
        cylinder(r = r * 1.9, h = U * 0.4, $fn = 4);
    }
}

// ============================================================
//  MODULE: facade_wall
//  A complete wall facade for one floor of one bay.
//  Uses a list to define which openings appear.
//
//  demonstrates: lists, if/else flow control,
//               difference(), translate()
// ============================================================
module facade_wall(bay, floor, has_window, has_door) {
    w = bay_width;
    h = floor_height;

    difference() {
        // Solid wall panel
        wall_panel(w, h, wall_thickness);

        // Window opening — centred in bay
        // demonstrates: if/else flow control
        if (has_window && !has_door) {
            translate([
                (w - win_width) / 2,
                -0.1,
                (h - win_height) / 2
            ])
            cube([win_width, wall_thickness + 0.2, win_height]);
        }

        // Door opening at ground floor
        if (has_door) {
            translate([
                (w - door_width) / 2,
                -0.1,
                0
            ])
            cube([door_width, wall_thickness + 0.2, door_height]);
        }
    }

    // Add window frame into the opening
    if (has_window && !has_door) {
        translate([
            (w - win_width) / 2,
            0,
            (h - win_height) / 2
        ])
        color([0.85, 0.9, 0.95], 0.6)
        window_opening(win_width, win_height);
    }

    // Add door into the opening
    if (has_door) {
        translate([
            (w - door_width) / 2,
            0,
            0
        ])
        color([0.55, 0.38, 0.25])
        arched_door(door_width, door_height, door_arch_r);
    }
}

// ============================================================
//  MODULE: roof
//  Gabled roof generated from a 2D triangular profile.
//
//  demonstrates: linear_extrude(), polygon() 2D profile,
//               mirror(), translate(), difference()
// ============================================================
module roof() {
    w = total_width + roof_overhang * 2;
    d = building_depth + roof_overhang * 2;

    // 2D gable cross-section profile
    // demonstrates: polygon() — 2D triangle profile
    gable_profile = [
        [0,             0],
        [w,             0],
        [w / 2, roof_pitch]
    ];

    // Extrude gable profile along building depth
    // demonstrates: linear_extrude() — 2D → 3D
    translate([-roof_overhang, -roof_overhang, 0])
    rotate([90, 0, 0])
    translate([0, 0, -d])
    linear_extrude(height = d)
    polygon(points = gable_profile);

    // Roof ridge cap
    // demonstrates: translate() + cube()
    translate([w / 2 - U * 0.3 - roof_overhang, -roof_overhang, roof_pitch - U * 0.1])
    cube([U * 0.6, d, U * 0.4]);

    // Eave fascia boards (front and back)
    // demonstrates: for loop + mirror()
    for (y_pos = [-roof_overhang, building_depth]) {
        translate([-roof_overhang, y_pos - U * 0.3, -U * 0.5])
        cube([w, U * 0.3, U * 0.5]);
    }
}

// ============================================================
//  MODULE: floor_slab
//  Horizontal floor/ceiling slab with edge detail.
//  demonstrates: cube(), translate(), difference()
// ============================================================
module floor_slab(w, d, floor_num) {
    z = floor_num * floor_height;
    slab_t = U * 0.8;

    translate([0, 0, z])
    difference() {
        cube([w, d, slab_t]);
        // Recess around perimeter (soffit detail)
        translate([U * 0.5, U * 0.5, -0.1])
        cube([w - U, d - U, slab_t * 0.4 + 0.1]);
    }
}

// ============================================================
//  MODULE: building_facade
//  Assembles the complete front facade using list-driven layout.
//
//  demonstrates: list comprehensions, nested for loops,
//               lists storing layout config, flow control
// ============================================================
module building_facade() {

    // Layout configuration stored as a list of lists
    // Each entry: [bay_index, floor_index, has_window, has_door]
    // demonstrates: lists — structured data driving geometry
    layout = [
        for (bay   = [0 : building_bays   - 1])
        for (floor = [0 : building_floors - 1])
        // demonstrates: list comprehension with conditional
        let(
            is_door   = (bay == floor(building_bays / 2) && floor == 0),
            is_window = !is_door
        )
        [bay, floor, is_window, is_door]
    ];

    // demonstrates: for loop iterating over generated list
    for (entry = layout) {
        bay       = entry[0];
        floor_num = entry[1];
        has_win   = entry[2];
        has_door  = entry[3];

        // Position each facade panel
        // demonstrates: translate() with list-derived coordinates
        translate([bay * bay_width, 0, floor_num * floor_height])
        color(has_door ? [0.88, 0.82, 0.74] : [0.92, 0.88, 0.82])
        facade_wall(bay, floor_num, has_win, has_door);
    }
}

// ============================================================
//  MODULE: side_wall
//  Plain side wall (no openings) — demonstrates mirror()
// ============================================================
module side_wall() {
    color([0.85, 0.80, 0.75])
    difference() {
        cube([building_depth, wall_thickness, total_height]);

        // Side window openings — demonstrates for loop
        for (floor = [0 : building_floors - 1]) {
            translate([
                building_depth / 2 - win_width / 2,
                -0.1,
                floor * floor_height + (floor_height - win_height) / 2
            ])
            cube([win_width, wall_thickness + 0.2, win_height]);
        }
    }
}

// ============================================================
//  MODULE: column_row
//  Places columns across the facade.
//  demonstrates: for loop, translate(), module reuse
// ============================================================
module column_row() {
    // demonstrates: for loop placing columns at bay boundaries
    for (i = [0 : building_bays]) {
        translate([i * bay_width - col_r, wall_thickness, 0])
        color([0.95, 0.93, 0.88])
        fluted_column(col_r, col_height * building_floors, col_flute_count);
    }
}

// ============================================================
//  FULL BUILDING ASSEMBLY
//  demonstrates: union(), translate(), mirror(), rotate()
//               conditional rendering, color()
// ============================================================
module building() {

    // --- Front facade ---
    if (show_walls) {
        building_facade();

        // Back wall — demonstrates: translate() + mirror()
        translate([0, building_depth, 0])
        color([0.82, 0.78, 0.73])
        wall_panel(total_width, total_height, wall_thickness);

        // Left side wall
        translate([0, 0, 0])
        rotate([0, 0, 90])
        translate([0, -wall_thickness, 0])
        side_wall();

        // Right side wall — demonstrates: mirror()
        translate([total_width, 0, 0])
        rotate([0, 0, 90])
        translate([0, -wall_thickness, 0])
        side_wall();
    }

    // --- Floor slabs ---
    if (show_floor_slab) {
        // demonstrates: for loop generating floor slabs
        for (f = [0 : building_floors]) {
            color([0.78, 0.75, 0.70])
            floor_slab(total_width, building_depth, f);
        }
    }

    // --- Columns ---
    if (show_columns) {
        column_row();
    }

    // --- Roof ---
    if (show_roof) {
        color([0.55, 0.35, 0.28])
        translate([0, 0, total_height])
        roof();
    }
}

// --- RENDER ---
building();

// ============================================================
//  QUICK DEMOS — uncomment to isolate components:
//
//  Single window:
//  window_opening(win_width, win_height);
//
//  Arched door:
//  arched_door(door_width, door_height, door_arch_r);
//
//  Single column:
//  fluted_column(col_r, col_height, col_flute_count);
//
//  Roof only:
//  roof();
//
//  One facade bay:
//  facade_wall(0, 0, true, false);
// ============================================================

// ============================================================
//  END OF PROJECT 04
//  Key techniques: modules & nesting, lists driving layout,
//  list comprehensions, for loops, boolean ops, linear_extrude
// ============================================================
