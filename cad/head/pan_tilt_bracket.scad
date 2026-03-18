// ============================================================
// Pan-Tilt Bracket — Two MG90S servos, head mount
// ============================================================
// Lower servo drives pan (left-right rotation around Z axis).
// Upper servo drives tilt (up-down rotation around X axis).
// Neck PVC pipe (15 mm) plugs into the bottom receiver.
// Head shell mounts on the tilt arm top face.
// ============================================================

// MG90S dimensions
srv_w  = 11.8;
srv_l  = 22.5;
srv_h  = 22.7;
tab_l  = 32.0;
tab_h  =  2.5;
tab_ew =  4.5;

// PVC neck pipe
neck_od   = 15;
neck_tol  =  0.3;
neck_wall =  3;
neck_h    = 22;   // socket depth

// Tilt arm
tilt_arm_l = 30;  // mm — from tilt servo axis to head attachment point
tilt_arm_w = 15;  // mm
tilt_arm_t =  3;  // mm

wall    = 2.5;
screw_d = 2.6;   // M2.5
$fn = 48;

neck_r     = (neck_od + neck_tol) / 2;
neck_col_r = neck_r + neck_wall;

// ============================================================
module servo_block(w, l, h, tl, th, te) {
    // Servo body with tab recesses cut out
    difference() {
        cube([w + 2*wall, l + 2*wall, h + wall], center = true);
        // Servo cavity
        cube([w, l, h + 1], center = true);
        // Tab recess
        translate([0, 0, -(h + wall)/2 + wall/2])
            cube([tl, te, th + 0.5], center = true);
        // Shaft clearance
        translate([0, -l/4, 0])
            cylinder(r = 5.5, h = h + wall + 0.2, center = true);
        // M2.5 corner screws
        for (dx = [-w/2, w/2])
            for (dy = [-l/2, l/2])
                translate([dx, dy, -(h + wall)/2 - 0.1])
                    cylinder(r = screw_d/2, h = wall + 0.2);
    }
}

module pan_base() {
    // Pan servo block + neck pipe receiver
    union() {
        color("LightGray")
            servo_block(srv_w, srv_l, srv_h, tab_l, tab_h, tab_ew);
        // Neck socket below
        translate([0, 0, -(srv_h + wall)/2 - neck_h])
            difference() {
                cylinder(r = neck_col_r, h = neck_h);
                cylinder(r = neck_r, h = neck_h + 1);
            }
    }
}

module tilt_assembly() {
    // Tilt servo block mounted on pan output (rotates with pan)
    translate([0, 0, (srv_h + wall)/2 + wall])
        color("Gray")
            servo_block(srv_w, srv_l, srv_h, tab_l, tab_h, tab_ew);

    // Tilt arm (connects tilt servo output to head shell boss)
    translate([0, -(srv_l/2 + wall + tilt_arm_l/2),
               (srv_h + wall)/2 + wall + (srv_h + wall)/2])
        color("DimGray")
            difference() {
                cube([tilt_arm_w, tilt_arm_l, tilt_arm_t], center = true);
                // M3 head-mounting holes at distal end
                for (dx = [-5, 5])
                    translate([dx, -tilt_arm_l/2 + 4, 0])
                        cylinder(r = 1.7, h = tilt_arm_t + 0.2, center = true);
            }
}

// ============================================================
union() {
    pan_base();
    tilt_assembly();
}
