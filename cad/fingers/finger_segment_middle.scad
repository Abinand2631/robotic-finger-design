// ============================================================
// Middle Finger Segment — Tendon-Driven Robotic Hand
// ============================================================
// Slightly shorter and narrower than the proximal segment,
// sits between the proximal and distal segments.
// Uses identical hole pattern: 1 tendon top, 2 elastic bottom.
// ============================================================

seg_length  = 18;
seg_width   =  9;
seg_height  =  7;
wall        =  1.5;
pin_dia     =  2.0;
pin_tol     =  0.1;
tendon_dia  =  1.35;
elastic_dia =  1.75;
elastic_sep =  6;
lug_h       =  3;
lug_w       =  2.5;
corner_r    =  1.5;

$fn = 40;

pin_r    = (pin_dia + pin_tol) / 2;
body_len = seg_length - 2 * lug_w;

module hinge_lug(female = false) {
    difference() {
        translate([-seg_width/2, 0, 0])
            cube([seg_width, lug_w, lug_h + wall]);
        if (female) {
            translate([-seg_width/4, -0.1, -0.1])
                cube([seg_width/2, lug_w + 0.2, lug_h + wall + 0.2]);
        }
        translate([0, lug_w/2, (lug_h + wall)/2])
            rotate([0, 90, 0])
                cylinder(r = pin_r, h = seg_width + 1, center = true);
    }
}

module body() {
    minkowski() {
        cube([seg_width - 2*corner_r,
              body_len - 2*corner_r,
              seg_height - 2*corner_r], center = true);
        sphere(r = corner_r);
    }
}

difference() {
    union() {
        translate([0, 0, seg_height/2])
            body();
        translate([0, -body_len/2 - lug_w, 0])
            hinge_lug(female = false);
        translate([0, body_len/2, 0])
            hinge_lug(female = true);
    }

    translate([0, 0, seg_height - wall])
        rotate([90, 0, 0])
            cylinder(r = tendon_dia/2, h = seg_length + 1, center = true);

    for (dx = [-elastic_sep/2, elastic_sep/2]) {
        translate([dx, 0, wall/2])
            rotate([90, 0, 0])
                cylinder(r = elastic_dia/2, h = seg_length + 1, center = true);
    }

    translate([0, 0, wall + (seg_height - 2*wall)/2])
        cube([seg_width - 2*wall,
              body_len - 2*wall,
              seg_height - 2*wall], center = true);
}
