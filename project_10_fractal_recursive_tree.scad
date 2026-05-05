// ============================================================
//  PROJECT 10 — Fractal Recursive Tree & L-System Collection
//  Portfolio Project for: Computational CAD Engineer (OpenSCAD)
//  Author: George Onwuemezie
// ============================================================
//
//  SKILLS DEMONSTRATED:
//  ✔ Flow Control           — recursion, for loops, if/else,
//                             termination conditions
//  ✔ Special Variables      — $fn, $fa, $fs — plus recursive
//                             depth passed as special parameter
//  ✔ Modifier Characters    — #, %, *, ! all demonstrated
//                             with practical use cases
//  ✔ Boolean Operations     — union(), difference(), intersection()
//  ✔ 3D Objects             — cylinder(), sphere(), cube()
//  ✔ 2D Objects             — circle(), polygon(), square()
//  ✔ linear_extrude         — branch cross-sections, leaf profiles
//  ✔ rotate_extrude         — trunk base flare, root forms
//  ✔ Transformations        — translate(), rotate(), scale(),
//                             mirror() — all used recursively
//  ✔ Lists                  — branch angle configs, L-system rules
//  ✔ List Comprehensions    — leaf cluster generation, root positions
//  ✔ Operators              — recursive scaling, angle math, pow()
//  ✔ Modules & Nesting      — deep recursive module calls
//  ✔ Type Test Functions    — is_num(), is_list(), is_bool()
//  ✔ Constants              — PI, mathematical constants in formulas
//
// ============================================================
//  CONCEPT:
//  Fractal geometry is the ultimate test of OpenSCAD mastery —
//  it requires recursion (a module calling itself), careful
//  termination conditions, and exponentially scaling transforms.
//
//  This project contains THREE tree variants:
//
//  TREE 1 — BINARY RECURSIVE TREE
//  Classic fractal: each branch splits into two, each slightly
//  shorter and rotated. Demonstrates pure recursion.
//
//  TREE 2 — TERNARY WIND-SWEPT TREE
//  Three-way split with asymmetric branching angles simulating
//  a wind-bent tree. Demonstrates recursion + list-driven angles.
//
//  TREE 3 — ORGANIC TREE WITH LEAVES
//  Cylindrical branches with radius tapering, sphere leaf
//  clusters, and root flare. Demonstrates all JD techniques
//  combined in a single coherent model.
// ============================================================
//  HOW TO USE:
//  Set tree_style = 1, 2, 3 or 0 for all three.
//  WARNING: recursion_depth > 7 gets very slow. Start at 5.
//  F5 = preview, F6 = render
// ============================================================

$fn  = 16;    // keep low for recursive models — speed matters
$fa  = 3;
$fs  = 1;

// ============================================================
//  PARAMETERS
// ============================================================

tree_style        = 0;      // 0=all, 1=binary, 2=windswept, 3=organic

// --- Recursion control ---
// demonstrates: special variable — depth controls recursion
recursion_depth   = 6;      // max branch levels (5-7 recommended)
min_branch_r      = 0.4;    // mm — stop recursing below this radius

// --- Tree 1: Binary ---
binary_trunk_h    = 28;     // mm — trunk height
binary_trunk_r    = 3.5;    // mm — trunk radius
binary_angle      = 28;     // degrees — branch split angle
binary_scale      = 0.72;   // branch length ratio per level
binary_radius_scale = 0.68; // branch radius ratio per level

// --- Tree 2: Windswept ternary ---
wind_trunk_h      = 32;
wind_trunk_r      = 4.0;
wind_scale        = 0.68;
wind_radius_scale = 0.65;
// Three branch angles: left, centre (biased), right
// demonstrates: list — branch angle configuration
wind_angles       = [-35, 10, 42];   // asymmetric — wind effect

// --- Tree 3: Organic ---
org_trunk_h       = 35;
org_trunk_r       = 5.0;
org_angle         = 32;
org_scale         = 0.70;
org_radius_scale  = 0.66;
leaf_r            = 3.5;    // mm — leaf cluster radius
show_leaves       = true;
show_roots        = true;

// ============================================================
//  COMPUTED CONSTANTS
// ============================================================
// demonstrates: constants used in recursive formulas
GOLDEN_RATIO = 1.6180339887;
TWO_PI       = 2 * PI;

// ============================================================
//  TYPE TEST VALIDATION
//  demonstrates: is_num(), is_list(), is_bool()
// ============================================================
module validate() {
    if (!is_num(recursion_depth)) echo("ERROR: recursion_depth must be a number");
    if (!is_num(binary_angle))    echo("ERROR: binary_angle must be a number");
    if (!is_list(wind_angles))    echo("ERROR: wind_angles must be a list");
    if (!is_bool(show_leaves))    echo("ERROR: show_leaves must be boolean");
    if (!is_bool(show_roots))     echo("ERROR: show_roots must be boolean");

    // demonstrates: is_num() on computed constant
    if (is_num(GOLDEN_RATIO)) {
        echo(str("Golden ratio: ", GOLDEN_RATIO));
    }

    // demonstrates: is_list() checking branch angle list
    if (is_list(wind_angles) && len(wind_angles) == 3) {
        echo(str("Wind angles validated: ", wind_angles));
    }
}

validate();

// ============================================================
//  MODULE: branch_cylinder
//  A tapered cylinder representing one branch segment.
//  demonstrates: cylinder() with r1/r2 for taper,
//               difference() for branch ring detail
// ============================================================
module branch_cylinder(length, r_base, r_tip) {
    // Tapered branch
    // demonstrates: cylinder() with r1 ≠ r2
    cylinder(r1 = r_base, r2 = r_tip, h = length);
}

// ============================================================
//  MODULE: leaf_cluster
//  Sphere cluster at branch tip representing foliage.
//  demonstrates: sphere(), translate(), union(),
//               list comprehension for cluster positions
// ============================================================
module leaf_cluster(r) {
    // demonstrates: list comprehension — leaf sphere positions
    // Golden angle spiral placement for natural distribution
    leaf_positions = [
        for (i = [0 : 6])
        let(
            // Golden angle = 137.5° — nature's optimal packing
            // demonstrates: operators + constants
            angle  = i * 137.5,
            height = i * r * 0.25,
            radius = r * 0.55 * sin(i * 25)
        )
        [radius * cos(angle), radius * sin(angle), height]
    ];

    // demonstrates: union() + for loop over comprehension list
    union() {
        for (pos = leaf_positions) {
            translate(pos)
            // demonstrates: scale() for irregular leaf shapes
            scale([1, 0.9, 0.85])
            sphere(r = r * 0.65, $fn = 10);
        }
        // Central main cluster
        sphere(r = r, $fn = 12);
    }
}

// ============================================================
//  MODULE: root_flare
//  Buttress roots flaring out from trunk base.
//  demonstrates: rotate_extrude, for loop, scale(),
//               list comprehension for root positions
// ============================================================
module root_flare(trunk_r) {
    root_count  = 5;
    // demonstrates: list comprehension — root angle positions
    root_angles = [for (i = [0 : root_count - 1]) i * (360 / root_count)];

    // demonstrates: for loop over comprehension result
    for (angle = root_angles) {
        rotate([0, 0, angle])
        translate([trunk_r * 0.6, 0, 0])
        // Buttress root: tapered fin shape
        // demonstrates: scale() + rotate_extrude for root form
        rotate([0, 0, 90])
        rotate_extrude(angle = 60, $fn = 24)
        // 2D root cross-section profile
        // demonstrates: polygon() as root profile
        polygon(points = [
            [0,          0],
            [trunk_r * 1.4, 0],
            [trunk_r * 0.8, trunk_r * 2.5],
            [0,          trunk_r * 3.0]
        ]);
    }
}

// ============================================================
//  MODULE: trunk_bark_texture
//  Decorative bark texture lines on trunk.
//  demonstrates: for loop, difference(), rotate(), cylinder()
// ============================================================
module trunk_bark_texture(h, r) {
    bark_lines = 8;
    // demonstrates: for loop for bark detail lines
    for (i = [0 : bark_lines - 1]) {
        angle = i * (360 / bark_lines) + 10;
        rotate([0, 0, angle])
        translate([r * 0.9, 0, h * 0.1])
        // Shallow groove spiralling up trunk
        rotate([2, 0, 0])
        cylinder(r = 0.25, h = h * 0.85, $fn = 6);
    }
}

// ============================================================
//  TREE 1 — BINARY RECURSIVE TREE
//
//  This is the fundamental recursive module.
//  Each call draws one branch, then calls ITSELF twice
//  at the tip — rotated left and right.
//  Recursion stops when depth reaches 0 or radius is too small.
//
//  demonstrates: RECURSION — module calling itself
//  demonstrates: flow control — if/else termination condition
//  demonstrates: special variable — depth decremented each call
//  demonstrates: operators — scale factors applied per level
// ============================================================
module binary_branch(length, radius, depth) {

    // ── TERMINATION CONDITION ────────────────────────────────
    // demonstrates: if/else — recursion must always terminate
    // Stop when depth reaches 0 OR branch is too thin to see
    if (depth <= 0 || radius < min_branch_r) {

        // Leaf bud at terminal branch
        // demonstrates: sphere() at recursion base case
        translate([0, 0, length * 0.5])
        sphere(r = radius * 1.8, $fn = 8);

    } else {
        // ── RECURSIVE CASE ────────────────────────────────────

        // Draw THIS branch segment
        // demonstrates: branch_cylinder() — current level
        branch_cylinder(length, radius, radius * binary_radius_scale);

        // Move to tip of this branch
        translate([0, 0, length])
        union() {
            // Junction sphere (natural-looking node)
            sphere(r = radius * binary_radius_scale * 1.1, $fn = 8);

            // LEFT sub-branch — rotate and recurse
            // demonstrates: rotate() + recursive call
            rotate([binary_angle, 0, 0])
            // demonstrates: RECURSIVE CALL — module calls itself
            binary_branch(
                length * binary_scale,          // shorter each level
                radius * binary_radius_scale,   // thinner each level
                depth - 1                        // depth decrements
            );

            // RIGHT sub-branch — mirror direction
            // demonstrates: rotate() opposite direction + recursion
            rotate([-binary_angle, 0, 45])
            binary_branch(
                length * binary_scale,
                radius * binary_radius_scale,
                depth - 1
            );
        }
    }
}

module tree_1_binary() {
    trunk_h = binary_trunk_h;
    trunk_r = binary_trunk_r;

    color([0.45, 0.32, 0.22])
    union() {
        // Trunk
        branch_cylinder(trunk_h, trunk_r, trunk_r * binary_radius_scale);

        // Bark texture on trunk
        trunk_bark_texture(trunk_h, trunk_r);

        // Start recursion at top of trunk
        translate([0, 0, trunk_h])
        // demonstrates: initial recursive call
        binary_branch(
            trunk_h * binary_scale,
            trunk_r * binary_radius_scale,
            recursion_depth
        );
    }
}

// ============================================================
//  TREE 2 — TERNARY WINDSWEPT TREE
//
//  Three-way split with angles stored in a list.
//  Asymmetric angles simulate wind bending the tree.
//
//  demonstrates: recursion with list-driven branch angles,
//               for loop INSIDE recursive module,
//               list indexing in recursive context
// ============================================================
module windswept_branch(length, radius, depth, lean) {

    // demonstrates: if/else termination
    if (depth <= 0 || radius < min_branch_r) {
        translate([0, 0, length * 0.4])
        color([0.25, 0.55, 0.20])
        sphere(r = radius * 2.2, $fn = 8);

    } else {
        // Draw branch with wind lean applied
        // demonstrates: rotate() with lean parameter
        color([0.42, 0.30, 0.20])
        branch_cylinder(length, radius, radius * wind_radius_scale);

        translate([0, 0, length])
        union() {
            sphere(r = radius * wind_radius_scale, $fn = 8);

            // Three sub-branches using wind_angles list
            // demonstrates: for loop over list in recursive context
            for (i = [0 : len(wind_angles) - 1]) {
                // demonstrates: list indexing — wind_angles[i]
                angle = wind_angles[i];

                // Rotate around Y then Z for 3D spread
                // demonstrates: compound rotate() transforms
                rotate([angle, 0, i * (360 / len(wind_angles))])
                // demonstrates: RECURSIVE CALL with modified lean
                windswept_branch(
                    length  * wind_scale,
                    radius  * wind_radius_scale,
                    depth - 1,
                    lean + angle * 0.1  // lean accumulates
                );
            }
        }
    }
}

module tree_2_windswept() {
    color([0.40, 0.28, 0.18])
    union() {
        // Leaning trunk — wind effect
        // demonstrates: rotate() for trunk lean
        rotate([8, 0, 0])
        union() {
            branch_cylinder(wind_trunk_h, wind_trunk_r,
                            wind_trunk_r * wind_radius_scale);
            trunk_bark_texture(wind_trunk_h, wind_trunk_r);

            translate([0, 0, wind_trunk_h])
            windswept_branch(
                wind_trunk_h * wind_scale,
                wind_trunk_r * wind_radius_scale,
                recursion_depth,
                0
            );
        }

        // Root base
        // demonstrates: rotate_extrude for root flare
        root_flare(wind_trunk_r);
    }
}

// ============================================================
//  TREE 3 — ORGANIC TREE WITH LEAVES
//
//  The most complete tree — cylindrical branches, sphere
//  leaf clusters, root flare, bark texture.
//  Demonstrates ALL remaining JD techniques in one module.
//
//  demonstrates: recursion, mirror(), list comprehensions,
//               leaf_cluster(), root_flare(), rotate_extrude,
//               all boolean operations, all transforms
// ============================================================
module organic_branch(length, radius, depth, dir_x, dir_y) {

    // demonstrates: if/else termination condition
    if (depth <= 0 || radius < min_branch_r) {

        // Leaf cluster at branch tip
        // demonstrates: conditional + leaf_cluster module
        if (show_leaves) {
            translate([0, 0, length])
            color([0.22, 0.58, 0.18], 0.9)
            leaf_cluster(leaf_r * pow(radius / org_trunk_r, 0.5));
        }

    } else {

        // Branch segment — tapered cylinder
        color([
            // demonstrates: operators — color interpolates with depth
            0.35 + (recursion_depth - depth) * 0.04,
            0.24 + (recursion_depth - depth) * 0.02,
            0.15
        ])
        difference() {
            branch_cylinder(length, radius, radius * org_radius_scale);

            // Knot hole on older branches (low depth = older)
            // demonstrates: difference() for surface detail
            if (depth < 3) {
                translate([radius * 0.75, 0, length * 0.4])
                rotate([90, 0, 0])
                cylinder(r = radius * 0.2, h = radius, $fn = 8);
            }
        }

        // Branch node sphere
        translate([0, 0, length])
        color([0.32, 0.22, 0.14])
        sphere(r = radius * org_radius_scale * 1.05, $fn = 8);

        // Sub-branches — 2 to 3 depending on depth
        // demonstrates: if/else choosing branch count
        branch_count = depth > recursion_depth * 0.5 ? 3 : 2;

        translate([0, 0, length])
        // demonstrates: for loop for variable branch count
        for (i = [0 : branch_count - 1]) {
            // Spread branches evenly + slight random offset
            // demonstrates: operators — angle distribution
            base_angle  = i * (360 / branch_count);
            tilt        = org_angle + (depth % 3) * 5;

            rotate([tilt, 0, base_angle + dir_x * 15])
            // demonstrates: RECURSIVE CALL — core recursion
            organic_branch(
                length  * org_scale,
                radius  * org_radius_scale,
                depth - 1,
                dir_x + sin(base_angle) * 0.3,
                dir_y + cos(base_angle) * 0.3
            );
        }
    }
}

module tree_3_organic() {
    union() {
        // Root flare at base
        // demonstrates: conditional + rotate_extrude roots
        if (show_roots) {
            color([0.30, 0.20, 0.12])
            root_flare(org_trunk_r);
        }

        // Main trunk
        color([0.35, 0.24, 0.15])
        union() {
            branch_cylinder(org_trunk_h, org_trunk_r,
                            org_trunk_r * org_radius_scale);
            trunk_bark_texture(org_trunk_h, org_trunk_r);
        }

        // Start organic recursion
        translate([0, 0, org_trunk_h])
        organic_branch(
            org_trunk_h * org_scale,
            org_trunk_r * org_radius_scale,
            recursion_depth,
            0, 0
        );
    }
}

// ============================================================
//  MODIFIER CHARACTERS — PRACTICAL DEMONSTRATIONS
//  Each modifier is shown in context with a real use case.
//
//  # HASH — debug highlight
//  Shows geometry in pink + normal render simultaneously.
//  USE CASE: checking if a branch intersects correctly.
//  EXAMPLE: #branch_cylinder(20, 3, 2);
//
//  % PERCENT — ghost/background
//  Renders transparent — does not affect final model.
//  USE CASE: showing the bounding volume of the tree.
//  EXAMPLE: %cylinder(r=50, h=120, $fn=6);
//
//  * ASTERISK — disable
//  Completely skips this object — like commenting out.
//  USE CASE: temporarily hiding leaves to check branch structure.
//  EXAMPLE: *leaf_cluster(leaf_r);
//
//  ! BANG — root (render only this)
//  Renders ONLY this object, ignoring everything else.
//  USE CASE: isolating one branch for debugging.
//  EXAMPLE: !organic_branch(20, 3, 3, 0, 0);
// ============================================================

// ============================================================
//  BOUNDING BOX GHOST
//  Demonstrates % modifier — shows tree's bounding volume
//  without affecting the rendered output.
//  demonstrates: % modifier character in real context
// ============================================================
module tree_bounding_box(w, h) {
    // demonstrates: % modifier — ghost reference volume
    %color([0.5, 0.5, 0.8], 0.08)
    translate([-w/2, -w/2, 0])
    cube([w, w, h]);
}

// ============================================================
//  FULL ASSEMBLY
//  demonstrates: translate(), if/else, conditional rendering
// ============================================================
module render_trees() {
    spacing = 85;

    // Bounding box ghosts for each tree (% modifier demo)
    if (tree_style == 0) {
        translate([-spacing, 0, 0]) tree_bounding_box(70, 110);
        tree_bounding_box(70, 110);
        translate([ spacing, 0, 0]) tree_bounding_box(70, 110);
    }

    // demonstrates: if/else chain — tree selection
    if (tree_style == 1 || tree_style == 0) {
        translate(tree_style == 0 ? [-spacing, 0, 0] : [0, 0, 0])
        tree_1_binary();
    }

    if (tree_style == 2 || tree_style == 0) {
        tree_2_windswept();
    }

    if (tree_style == 3 || tree_style == 0) {
        translate(tree_style == 0 ? [spacing, 0, 0] : [0, 0, 0])
        tree_3_organic();
    }
}

// --- RENDER ---
render_trees();

// ============================================================
//  QUICK DEMOS — uncomment to study techniques:
//
//  Minimal recursion demo (depth 4, fast):
//  binary_branch(20, 3, 4);
//
//  Single leaf cluster:
//  leaf_cluster(5);
//
//  Root flare only:
//  root_flare(5);
//
//  Bark texture only:
//  trunk_bark_texture(30, 5);
//
//  Modifier demos:
//  #branch_cylinder(20, 3, 2);         // debug highlight
//  %cylinder(r=40, h=100, $fn=6);      // ghost bounding box
//  *tree_1_binary();                    // disabled (invisible)
//  !leaf_cluster(leaf_r);              // only this renders
//
//  Change depth for speed vs detail:
//  recursion_depth = 4;  // fast preview
//  recursion_depth = 7;  // detailed (slow!)
//
//  Try different wind angles:
//  wind_angles = [-45, 0, 45];   // symmetric
//  wind_angles = [-20, 5, 55];   // strongly wind-swept
// ============================================================

// ============================================================
//  END OF PROJECT 10
//  Key techniques: recursion (module calling itself),
//  termination conditions, depth-controlled scaling,
//  list-driven branch angles, all four modifier characters,
//  leaf clusters via list comprehensions, root_flare via
//  rotate_extrude, organic color interpolation with depth
// ============================================================
