// ============================================================
// Wheel Hub Adapter — 8 mm bore to 120 mm rubber wheel
// ============================================================
// Press-fits onto motor shaft (8 mm D-flat or round).
// Outer spokes bolt to the wheel centre disc.
//
// Adjust shaft_d and flat_w if using a D-shaft motor.
// ============================================================

shaft_d    =  8.0;  // mm — motor shaft diameter
shaft_tol  =  0.05; // mm — diametric interference (press-fit)
flat_w     =  6.5;  // mm — D-flat chord width (set to shaft_d for round shaft)
hub_od     = 18;    // mm — hub outer diameter
hub_h      = 12;    // mm — hub height
spoke_n    =  4;    // number of spokes
spoke_w    =  4;    // mm
spoke_h    =  3;    // mm
wheel_bolt_d = 3.4; // mm — M3 bolt to wheel
wheel_bolt_r = 22;  // mm — bolt circle radius
set_screw_d  = 3.2; // mm — grub screw (M3) on hub side
$fn = 60;

bore_r = (shaft_d - shaft_tol) / 2;

// ============================================================
module hub_body() {
    difference() {
        cylinder(r = hub_od/2, h = hub_h);
        // Shaft bore
        translate([0, 0, -0.1])
            cylinder(r = bore_r, h = hub_h + 0.2);
        // D-flat (if applicable)
        translate([-shaft_d/2, flat_w/2, -0.1])
            cube([shaft_d, shaft_d, hub_h + 0.2]);
        // Grub screw hole (radial, M3)
        translate([hub_od/2, 0, hub_h/2])
            rotate([0, 90, 0])
                cylinder(r = set_screw_d/2, h = hub_od);
    }
}

module spoke_disc() {
    // Flat disc with spokes and bolt holes for wheel attachment
    difference() {
        union() {
            cylinder(r = hub_od/2, h = spoke_h);
            for (i = [0 : spoke_n - 1]) {
                rotate([0, 0, i * 360/spoke_n])
                    translate([0, -spoke_w/2, 0])
                        cube([wheel_bolt_r + 3, spoke_w, spoke_h]);
            }
        }
        // Wheel bolt holes
        for (i = [0 : spoke_n - 1]) {
            rotate([0, 0, i * 360/spoke_n + 360/(2*spoke_n)])
                translate([wheel_bolt_r, 0, -0.1])
                    cylinder(r = wheel_bolt_d/2, h = spoke_h + 0.2);
        }
        // Central shaft bore through disc
        translate([0, 0, -0.1])
            cylinder(r = bore_r, h = spoke_h + 0.2);
    }
}

// ============================================================
union() {
    color("Silver")    hub_body();
    color("LightGray") translate([0, 0, hub_h]) spoke_disc();
}
