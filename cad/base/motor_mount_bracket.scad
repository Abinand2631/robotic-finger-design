// ============================================================
// DC Motor Mount Bracket — 12 V geared DC motor, base assembly
// ============================================================
// Clamps around a standard round-body DC geared motor
// (approx. 25 mm diameter body) and bolts to the base deck.
// Wheel axle passes through 8 mm bore of the wheel hub adapter.
//
// Motor body diameter: ~25 mm (N20 / similar round motors)
// Adjust motor_od to match your specific motor.
// ============================================================

motor_od    = 25.5;  // mm — motor body outer diameter + 0.5 tol
motor_l     = 48;    // mm — motor body length
clamp_w     = 10;    // mm — clamping band width
clamp_wall  =  3.5;  // mm — wall around motor body
screw_d     =  3.4;  // mm — M3 clearance
bolt_d      =  4.5;  // mm — M4 base bolt clearance
foot_l      = 35;    // mm — mounting foot length
foot_w      = 20;    // mm — mounting foot width
foot_h      =  4;    // mm — mounting foot thickness
bolt_sep    = 26;    // mm — bolt pattern spacing
corner_r    =  2;
$fn = 60;

motor_r = motor_od / 2;
clamp_r = motor_r + clamp_wall;

// ============================================================
module clamp_ring() {
    // Full-circumference ring with slot for tightening
    difference() {
        cylinder(r = clamp_r, h = clamp_w);
        // Motor bore
        cylinder(r = motor_r, h = clamp_w + 1);
        // Tightening slot (top, 2 mm wide)
        translate([-1, clamp_r - clamp_wall, -0.1])
            cube([2, clamp_wall + 1, clamp_w + 0.2]);
    }
    // Clamp ear with M3 bolt hole
    translate([clamp_r, -4, 0]) {
        difference() {
            cube([7, 8, clamp_w]);
            translate([3.5, 8/2, -0.1])
                cylinder(r = screw_d/2, h = clamp_w + 0.2);
        }
    }
}

module mounting_foot() {
    difference() {
        translate([-foot_w/2, -foot_l/2, 0])
            minkowski() {
                cube([foot_w - 2*corner_r,
                      foot_l - 2*corner_r,
                      foot_h - corner_r/2]);
                cylinder(r = corner_r, h = corner_r/2);
            }
        // M4 base bolt holes
        for (dy = [-bolt_sep/2, bolt_sep/2])
            translate([0, dy, -0.1])
                cylinder(r = bolt_d/2, h = foot_h + 0.2);
    }
}

// ============================================================
union() {
    // Two clamp rings along motor body
    for (y = [5, motor_l - clamp_w - 5]) {
        color("DarkGray")
            translate([0, y, 0])
                rotate([90, 0, 0])
                    clamp_ring();
    }
    // Mounting foot (centred under motor, aligned with base deck)
    color("LightGray")
        translate([0, motor_l/2, -(motor_r + clamp_wall)])
            rotate([0, 0, 0])
                mounting_foot();
}
