// ============================================================
// Proximal Finger Segment — Tendon-Driven Robotic Hand
// ============================================================
// Segment position: first (base) segment, closest to palm.
// Hinge pins connect this segment to the palm at the proximal
// end and to the middle segment at the distal end.
//
// Key holes:
//   top_hole   — 1.35 mm dia, tendon (fishing line) routing
//   bot_holes  — 1.75 mm dia × 2, elastic band anchors
//   pin_holes  — 2.00 mm dia, hinge pin (press-fit)
// ============================================================

// ---- Parameters (edit here for customisation) --------------
seg_length  = 20;    // mm — segment body length
seg_width   = 10;    // mm — segment width
seg_height  =  7;    // mm — segment body height
wall        =  1.5;  // mm — minimum wall thickness
pin_dia     =  2.0;  // mm — hinge pin diameter
pin_tol     =  0.1;  // mm — diametric tolerance on pin hole
tendon_dia  =  1.35; // mm — tendon routing hole
elastic_dia =  1.75; // mm — elastic-band anchor hole
elastic_sep =  7;    // mm — centre-to-centre spacing of elastic holes
lug_h       =  3;    // mm — hinge lug height (each side)
lug_w       =  2.5;  // mm — hinge lug width (along segment axis)
corner_r    =  1.5;  // mm — body corner radius

$fn = 40;

// ---- Derived values ----------------------------------------
pin_r    = (pin_dia + pin_tol) / 2;
body_len = seg_length - 2 * lug_w;   // clear span between lugs

// ============================================================
module hinge_lug(female = false) {
    // Single hinge lug at the origin, protruding in +Y.
    difference() {
        translate([-seg_width/2, 0, 0])
            cube([seg_width, lug_w, lug_h + wall]);
        if (female) {
            // Slot for mating lug (clearance gap each side)
            translate([-seg_width/4, -0.1, -0.1])
                cube([seg_width/2, lug_w + 0.2, lug_h + wall + 0.2]);
        }
        // Hinge pin hole (through full width)
        translate([0, lug_w/2, (lug_h + wall)/2])
            rotate([0, 90, 0])
                cylinder(r = pin_r, h = seg_width + 1, center = true);
    }
}

module body() {
    // Rounded-rectangle extrusion (main segment body)
    minkowski() {
        cube([seg_width - 2*corner_r,
              body_len - 2*corner_r,
              seg_height - 2*corner_r], center = true);
        sphere(r = corner_r);
    }
}

// ============================================================
// Main segment assembly
// ============================================================
difference() {
    union() {
        // Body
        translate([0, 0, seg_height/2])
            body();

        // Proximal hinge lugs (palm side)
        translate([0, -body_len/2 - lug_w, 0])
            hinge_lug(female = false);

        // Distal hinge lugs (middle segment side)
        translate([0, body_len/2, 0])
            hinge_lug(female = true);
    }

    // --- Tendon hole (top centre, runs full length) ---
    translate([0, 0, seg_height - wall])
        rotate([90, 0, 0])
            cylinder(r = tendon_dia/2, h = seg_length + 1, center = true);

    // --- Elastic band holes (bottom, symmetric) ---
    for (dx = [-elastic_sep/2, elastic_sep/2]) {
        translate([dx, 0, wall/2])
            rotate([90, 0, 0])
                cylinder(r = elastic_dia/2, h = seg_length + 1, center = true);
    }

    // --- Lighten interior (hollow pocket) ---
    translate([0, 0, wall + (seg_height - 2*wall)/2])
        cube([seg_width - 2*wall,
              body_len - 2*wall,
              seg_height - 2*wall], center = true);
}
