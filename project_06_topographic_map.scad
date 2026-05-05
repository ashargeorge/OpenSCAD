// ============================================================
//  PROJECT 06 — 3D Topographic Map from 2D Contours
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George Onwuemezie
// ============================================================
//
//  SKILLS DEMONSTRATED:
//  ✔ 3D from 2D Shadows     — DIRECTLY answers JD requirement:
//                             "Build up 3D shapes from 2D shadows"
//                             Each contour is a 2D polygon extruded
//                             to its elevation height, stacked to
//                             build a full 3D terrain model
//  ✔ linear_extrude         — each contour layer extruded to height
//  ✔ 2D Objects             — polygon() contour outlines
//  ✔ Lists                  — contour point data stored as lists
//  ✔ List Comprehensions    — layer generation, color mapping
//  ✔ Flow Control           — for loops, if/else, conditional logic
//  ✔ Boolean Operations     — difference(), union(), intersection()
//  ✔ Transformations        — translate(), scale(), rotate()
//  ✔ Special Variables      — $fn for smooth curved contours
//  ✔ Operators              — elevation math, scaling, interpolation
//  ✔ Modules & Nesting      — reusable contour, label, base modules
//  ✔ Type Test Functions    — is_list(), is_num() for validation
//
// ============================================================
//  CONCEPT:
//  A topographic map works by projecting 3D terrain onto 2D
//  as a series of contour lines — each line connecting points
//  of equal elevation. This project reverses that process:
//  starting from 2D contour polygons (the "shadows" of the
//  terrain slices), we extrude each one to its correct height
//  and stack them to reconstruct the full 3D terrain.
//
//  This is exactly the "3D from 2D shadows" technique the JD
//  specifies — and it maps directly to AI training workflows
//  where 2D drawings or projections are used to generate 3D
//  training geometry.
// ============================================================
//  HOW TO USE:
//  F5 = preview, F6 = render, F7 = export STL
//  Adjust parameters to change terrain style and output.
// ============================================================

$fn = 80;

// ============================================================
//  PARAMETERS
// ============================================================

// --- Map dimensions ---
map_scale         = 1.0;    // overall scale multiplier
map_base_w        = 120;    // mm — base plate width
map_base_d        = 100;    // mm — base plate depth
base_thickness    = 4;      // mm — solid base below terrain

// --- Terrain layers ---
contour_count     = 8;      // number of elevation layers
layer_height      = 4;      // mm — height of each contour layer
total_terrain_h   = contour_count * layer_height;

// --- Style options ---
show_base_plate   = true;   // flat base with border
show_contours     = true;   // the stacked terrain layers
show_peak_marker  = true;   // summit marker pin
show_grid         = false;  // reference grid on base (slow)
color_mode        = true;   // elevation-based coloring in preview

// --- Map border ---
border_w          = 6;      // mm — border frame width
border_h          = base_thickness + total_terrain_h * 0.3;

// ============================================================
//  CONTOUR DATA
//  Each entry is a list of [x, y] points defining one
//  closed contour polygon at a given elevation level.
//
//  In a real workflow these would be imported from GIS data.
//  Here they are hand-crafted to simulate a realistic island
//  terrain with a main peak, secondary ridge, and coastal bay.
//
//  demonstrates: lists — nested list of polygon point arrays
//  demonstrates: list indexing — contour_data[i] per layer
// ============================================================

// Contour 0 — coastline (sea level, largest outline)
c0 = [
    [15, 10], [30,  6], [50,  4], [70,  6], [90,  9], [105, 15],
    [112,28], [110,45], [108,60], [105,75], [95, 88], [78, 94],
    [60, 96], [42, 93], [25, 85], [12, 70], [ 8, 52], [ 9, 35],
    [12, 20]
];

// Contour 1 — first elevation band
c1 = [
    [22, 18], [38, 13], [55, 11], [72, 13], [88, 17], [100,27],
    [103,42], [101,57], [97, 71], [85, 82], [67, 87], [48, 85],
    [30, 77], [18, 63], [14, 46], [16, 30]
];

// Contour 2
c2 = [
    [28, 25], [45, 20], [60, 18], [75, 21], [87, 30], [90, 44],
    [88, 58], [82, 70], [68, 78], [50, 79], [34, 70], [24, 55],
    [22, 40], [24, 30]
];

// Contour 3
c3 = [
    [34, 32], [50, 28], [64, 27], [76, 32], [80, 44],
    [78, 56], [71, 66], [56, 71], [40, 63], [31, 50],
    [30, 38]
];

// Contour 4 — secondary ridge starts separating
c4 = [
    [38, 38], [52, 34], [64, 34], [72, 40], [73, 52],
    [66, 62], [53, 66], [41, 57], [36, 46]
];

// Contour 5 — main peak area isolates
c5 = [
    [42, 42], [54, 39], [63, 41], [67, 50],
    [62, 59], [50, 62], [42, 54], [39, 46]
];

// Contour 6 — near summit
c6 = [
    [46, 45], [55, 43], [61, 47],
    [59, 55], [50, 58], [44, 52]
];

// Contour 7 — summit (smallest, highest)
c7 = [
    [49, 47], [55, 46], [58, 50],
    [54, 55], [49, 53]
];

// ============================================================
//  CONTOUR REGISTRY
//  All contours collected into one list for iteration.
//  demonstrates: list of lists — data-driven geometry
// ============================================================
contour_data = [c0, c1, c2, c3, c4, c5, c6, c7];

// ============================================================
//  ELEVATION COLOR MAP
//  Maps layer index to an RGB color simulating terrain:
//  deep green (low) → olive → tan → grey → white (peak)
//
//  demonstrates: list comprehension generating color values,
//               list indexing, operators for interpolation
// ============================================================

// Color stops: [r, g, b] at key elevations
color_stops = [
    [0.20, 0.55, 0.25],   // 0 — coastal green
    [0.35, 0.62, 0.22],   // 1
    [0.52, 0.68, 0.25],   // 2 — mid green
    [0.68, 0.70, 0.30],   // 3 — olive
    [0.75, 0.68, 0.40],   // 4 — tan/brown
    [0.72, 0.65, 0.55],   // 5 — rocky brown
    [0.82, 0.80, 0.78],   // 6 — grey rock
    [0.95, 0.95, 0.97]    // 7 — snow/peak
];

// demonstrates: function returning color for a layer index
function layer_color(i) =
    // demonstrates: is_num() type test + list indexing
    is_num(i) && i >= 0 && i < len(color_stops)
    ? color_stops[i]
    : [0.5, 0.5, 0.5];

// ============================================================
//  MODULE: contour_layer
//  Extrudes a single 2D contour polygon to the correct height.
//
//  THIS IS THE CORE "3D FROM 2D" TECHNIQUE:
//  The contour polygon is the "2D shadow" (projection) of
//  the terrain at that elevation. linear_extrude lifts it
//  to its correct height, reconstructing the 3D slice.
//
//  demonstrates: linear_extrude(), polygon(), translate()
//               list indexing, operators
// ============================================================
module contour_layer(layer_index) {
    // demonstrates: type test — validate input
    if (!is_num(layer_index)) {
        echo("ERROR: layer_index must be a number");
    } else {
        z_bottom = layer_index * layer_height;
        z_top    = (layer_index + 1) * layer_height;
        h        = z_top - z_bottom;

        // Get the contour polygon for this layer
        // demonstrates: list indexing — contour_data[layer_index]
        pts = contour_data[layer_index];

        // demonstrates: is_list() type test
        if (!is_list(pts)) {
            echo(str("WARNING: No contour data for layer ", layer_index));
        } else {
            translate([0, 0, z_bottom])
            // demonstrates: linear_extrude — 2D polygon → 3D layer
            // This is the "2D shadow → 3D solid" operation
            linear_extrude(
                height    = h + 0.1,  // slight overlap prevents gaps
                convexity = 8
            )
            // demonstrates: scale() — fit contour to map dimensions
            scale([
                map_base_w / 120 * map_scale,
                map_base_d / 100 * map_scale,
                1
            ])
            // demonstrates: polygon() — 2D contour outline
            polygon(points = pts);
        }
    }
}

// ============================================================
//  MODULE: terrain
//  Stacks all contour layers to build the full 3D terrain.
//
//  demonstrates: for loop over list, union(),
//               list comprehension for layer indices,
//               conditional coloring
// ============================================================
module terrain() {
    // Generate list of layer indices via list comprehension
    // demonstrates: list comprehension
    layer_indices = [for (i = [0 : contour_count - 1]) i];

    // demonstrates: for loop iterating comprehension result
    for (i = layer_indices) {
        // demonstrates: conditional color assignment
        if (color_mode) {
            c = layer_color(i);
            color([c[0], c[1], c[2]])
            contour_layer(i);
        } else {
            contour_layer(i);
        }
    }
}

// ============================================================
//  MODULE: base_plate
//  The map base with border frame and recessed centre.
//
//  demonstrates: difference(), union(), cube(), translate()
// ============================================================
module base_plate() {
    bw = map_base_w * map_scale;
    bd = map_base_d * map_scale;

    difference() {
        union() {
            // Main base slab
            // demonstrates: cube() 3D primitive
            color([0.85, 0.82, 0.76])
            cube([bw, bd, base_thickness]);

            // Border frame rising around edge
            // demonstrates: difference() of two cubes = frame
            color([0.75, 0.72, 0.66])
            difference() {
                cube([bw, bd, border_h]);
                translate([border_w, border_w, base_thickness])
                cube([
                    bw - border_w * 2,
                    bd - border_w * 2,
                    border_h + 0.1
                ]);
            }
        }

        // Recess for compass rose (bottom right corner)
        // demonstrates: difference() + cylinder()
        translate([bw - border_w * 0.5, border_w * 0.5, -0.1])
        cylinder(r = border_w * 0.4, h = base_thickness * 0.5);
    }
}

// ============================================================
//  MODULE: compass_rose
//  Simple compass indicator on the base.
//  demonstrates: for loop, rotate(), linear_extrude, polygon()
// ============================================================
module compass_rose() {
    bw = map_base_w * map_scale;
    bd = map_base_d * map_scale;

    translate([bw - border_w * 0.5, border_w * 0.5, base_thickness * 0.5])
    color([0.4, 0.35, 0.3])
    // demonstrates: for loop + rotate() for 4 compass points
    for (angle = [0, 90, 180, 270]) {
        rotate([0, 0, angle])
        translate([0, 0, 0])
        // demonstrates: linear_extrude of arrow polygon
        linear_extrude(height = 0.8)
        polygon(points = [
            [ 0,    0.5],
            [ 1.2,  3.5],
            [ 0,    2.8],
            [-1.2,  3.5]
        ]);
    }
}

// ============================================================
//  MODULE: peak_marker
//  Summit pin marker at the highest point.
//  demonstrates: union(), cylinder(), sphere(), translate()
// ============================================================
module peak_marker() {
    // Summit is at approximately contour c7 centre
    // demonstrates: operators for position calculation
    peak_x = 53 * (map_base_w / 120) * map_scale;
    peak_y = 50 * (map_base_d / 100) * map_scale;
    peak_z = base_thickness + total_terrain_h;

    translate([peak_x, peak_y, peak_z])
    color([0.85, 0.15, 0.15])
    union() {
        // Pin shaft
        cylinder(r = 0.8, h = 8);
        // Pin head sphere
        // demonstrates: translate() + sphere()
        translate([0, 0, 9])
        sphere(r = 2.5);
    }
}

// ============================================================
//  MODULE: contour_lines_on_base
//  Engraves contour line numbers on the base border.
//  demonstrates: for loop, translate(), rotate()
// ============================================================
module elevation_markers() {
    bw = map_base_w * map_scale;

    // demonstrates: for loop generating elevation labels
    for (i = [0 : contour_count - 1]) {
        elevation_m = i * 100;   // simulate 100m contour intervals
        z_pos = base_thickness + i * layer_height;

        // Small tick mark on side of model at each layer
        translate([bw * map_scale + 0.5, 20, z_pos])
        color([0.3, 0.3, 0.3])
        cube([border_w * 0.4, 3, 0.6]);
    }
}

// ============================================================
//  MODULE: grid_overlay
//  Optional reference grid on base plate.
//  demonstrates: for loop, cube(), list comprehension
// ============================================================
module grid_overlay() {
    bw   = map_base_w * map_scale;
    bd   = map_base_d * map_scale;
    step = 10;

    color([0.6, 0.6, 0.58], 0.5)
    // demonstrates: list comprehension for grid positions
    for (x = [for (i = [0 : floor(bw / step)]) i * step]) {
        translate([x, 0, base_thickness - 0.2])
        cube([0.3, bd, 0.3]);
    }
    for (y = [for (j = [0 : floor(bd / step)]) j * step]) {
        translate([0, y, base_thickness - 0.2])
        cube([bw, 0.3, 0.3]);
    }
}

// ============================================================
//  FULL ASSEMBLY
//  demonstrates: conditional rendering, translate(), union()
// ============================================================
module topo_map() {

    // demonstrates: is_num() validation on parameters
    if (!is_num(contour_count) || contour_count < 1) {
        echo("ERROR: contour_count must be a positive number");
    } else {

        // Base plate
        if (show_base_plate) {
            base_plate();
            compass_rose();
            elevation_markers();
        }

        // Optional grid
        if (show_grid) {
            grid_overlay();
        }

        // Terrain layers — the core "2D → 3D" demonstration
        if (show_contours) {
            translate([0, 0, base_thickness])
            terrain();
        }

        // Summit marker
        if (show_peak_marker) {
            peak_marker();
        }
    }
}

// --- RENDER ---
topo_map();

// ============================================================
//  QUICK DEMOS — uncomment to study techniques in isolation:
//
//  Single contour layer (layer 0 — coastline):
//  contour_layer(0);
//
//  Just terrain no base:
//  terrain();
//
//  Single 2D contour polygon (F5 preview):
//  polygon(points = c3);
//
//  All contours as flat 2D (F5 preview — shows the "shadows"):
//  for (i=[0:7]) { c=contour_data[i]; polygon(points=c); }
//
//  Base plate only:
//  base_plate();
// ============================================================

// ============================================================
//  END OF PROJECT 06
//  Key technique: linear_extrude of 2D contour polygons
//  stacked at increasing heights = 3D terrain from 2D shadows.
//  This directly demonstrates the JD requirement:
//  "Build up 3D shapes from 2D shadows"
// ============================================================
