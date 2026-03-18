// ============================================================
// Elbow Joint Bracket — MG90S servo between upper arm & forearm
// ============================================================
// Connects two 20 mm PVC pipes (upper arm & forearm) via an
// MG90S micro servo.  One pipe is fixed (upper arm); the other
// (forearm) pivots on the servo output shaft.
//
// Print orientation: flat face down.
// Material: PLA, 80 % infill.
// ============================================================

// MG90S dimensions
srv_w  = 11.8;
srv_l  = 22.5;
srv_h  = 22.7;
tab_l  = 32.0;
tab_h  =  2.5;
tab_ew =  4.5;  // ear width

// PVC collars
pvc_od   = 20;
pvc_tol  =  0.3;
collar_h = 20;
collar_w =  3;

wall     = 2.0;
screw_d  = 2.6;  // M2.5 clearance
corner_r = 1.5;
$fn = 48;

pvc_r    = (pvc_od + pvc_tol) / 2;
collar_r = pvc_r + collar_w;
outer_w  = srv_w + 2*wall;
outer_l  = srv_l + 2*wall;

// ============================================================
module servo_pocket() {
    translate([-srv_w/2, -srv_l/2, 0])
        cube([srv_w, srv_l, srv_h + 2]);
    // Tab
    translate([-tab_l/2, -tab_ew/2, 0])
        cube([tab_l, tab_ew, tab_h + 0.5]);
    // Shaft clearance
    translate([0, -srv_l/2 + 7, -0.1])
        cylinder(r = 5.5, h = wall + 0.2);
}

module body_block() {
    difference() {
        // Outer rounded block
        minkowski() {
            cube([outer_w - 2*corner_r,
                  outer_l - 2*corner_r,
                  wall], center = true);
            cylinder(r = corner_r, h = 0.01);
        }
        // Servo pocket from above
        translate([0, 0, -wall/2])
            servo_pocket();
        // M2.5 mounting screws
        for (s = [[-outer_w/2 + 3, -outer_l/2 + 3],
                  [ outer_w/2 - 3, -outer_l/2 + 3],
                  [-outer_w/2 + 3,  outer_l/2 - 3],
                  [ outer_w/2 - 3,  outer_l/2 - 3]]) {
            translate([s[0], s[1], -wall/2 - 0.1])
                cylinder(r = screw_d/2, h = wall + 0.2);
        }
    }
}

module fixed_collar() {
    // Upper-arm collar (servo body side)
    translate([0, outer_l/2 + collar_h/2, 0])
        rotate([90, 0, 0])
            difference() {
                cylinder(r = collar_r, h = collar_h);
                cylinder(r = pvc_r, h = collar_h + 1);
                // Clamp slot
                translate([-0.75, collar_r - collar_w - 0.5, -0.1])
                    cube([1.5, collar_w + 1, collar_h + 0.2]);
            }
}

module pivot_collar() {
    // Forearm collar (output shaft side) — rotates with servo horn
    translate([0, -outer_l/2 - collar_h/2, 0])
        rotate([90, 0, 0])
            difference() {
                cylinder(r = collar_r, h = collar_h);
                cylinder(r = pvc_r, h = collar_h + 1);
                translate([-0.75, collar_r - collar_w - 0.5, -0.1])
                    cube([1.5, collar_w + 1, collar_h + 0.2]);
            }
}

// ============================================================
union() {
    color("Silver") translate([0, 0, wall/2]) body_block();
    color("DimGray") fixed_collar();
    color("Gray")    pivot_collar();
}
