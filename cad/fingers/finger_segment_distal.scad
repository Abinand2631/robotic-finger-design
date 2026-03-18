// ============================================================
// Distal (Fingertip) Finger Segment — Tendon-Driven Hand
// ============================================================
// Shortest segment with rounded tapered tip.
// One tendon hole on top; two elastic holes on bottom.
// Closed distal end (no female lug needed).
// ============================================================

seg_length  = 15;
seg_width   =  8;
seg_height  =  6;
wall        =  1.5;
pin_dia     =  2.0;
pin_tol     =  0.1;
tendon_dia  =  1.35;
elastic_dia =  1.75;
elastic_sep =  5;
lug_h       =  3;
lug_w       =  2.5;
tip_r       =  4;    // mm — rounded tip sphere radius
corner_r    =  1.2;

$fn = 40;

pin_r    = (pin_dia + pin_tol) / 2;
body_len = seg_length - lug_w;   // only one lug (proximal end)

module proximal_lug() {
    difference() {
        translate([-seg_width/2, 0, 0])
            cube([seg_width, lug_w, lug_h + wall]);
        translate([0, lug_w/2, (lug_h + wall)/2])
            rotate([0, 90, 0])
                cylinder(r = pin_r, h = seg_width + 1, center = true);
    }
}

module tapered_body() {
    // Body tapers in width from proximal to distal end
    hull() {
        translate([0, -body_len/2 + corner_r, seg_height/2])
            minkowski() {
                cube([seg_width - 2*corner_r, 0.01, seg_height - 2*corner_r], center = true);
                sphere(r = corner_r);
            }
        translate([0, body_len/2 - tip_r/2, seg_height/4 + tip_r/2])
            sphere(r = tip_r/2 + 1);
    }
}

difference() {
    union() {
        tapered_body();
        translate([0, -body_len/2 - lug_w, 0])
            proximal_lug();
    }

    // Tendon channel (top, running toward tip)
    translate([0, 0, seg_height - wall])
        rotate([90, 0, 0])
            cylinder(r = tendon_dia/2, h = seg_length + 1, center = true);

    // Elastic holes (bottom)
    for (dx = [-elastic_sep/2, elastic_sep/2]) {
        translate([dx, 0, wall/2])
            rotate([90, 0, 0])
                cylinder(r = elastic_dia/2, h = body_len + 1, center = true);
    }

    // Hollow interior
    translate([0, 0, wall + (seg_height - 2*wall)/2])
        cube([seg_width - 2*wall,
              body_len - 2*wall,
              seg_height - 2*wall], center = true);
}
