// ============================================================
// Head Shell — Pan-Tilt Humanoid Robot Head
// ============================================================
// Ellipsoidal shell with:
//   • Eye sockets (LED indicator cutouts, 10 mm diameter)
//   • Neck socket (15 mm PVC pipe receiver, bottom face)
//   • Internal pan-tilt servo pockets (two MG90S servos)
//   • Access hatch on rear for wiring
//
// Approximate outer dimensions: 90 × 75 × 100 mm (W × D × H)
// Print in PLA, 15 % infill to keep weight ≤ 80 g.
// Print as two halves (front / rear) and glue together.
// ============================================================

// Outer ellipsoid radii
rx = 45;   // mm — half-width
ry = 38;   // mm — half-depth
rz = 50;   // mm — half-height (vertical)
shell_t =  2.5;  // mm — shell wall thickness

// Eye sockets
eye_d      = 10;  // mm — LED cutout diameter
eye_y      =  ry - 1;  // mm — forward placement (on front face)
eye_z_off  =  8;  // mm — above centre
eye_x_off  = 18;  // mm — lateral offset

// Neck socket (bottom)
neck_pvc_od = 15;  // mm — 15 mm PVC OD
neck_depth  = 18;  // mm — socket depth
neck_wall   =  3;  // mm

// MG90S pan servo (horizontal, inside head, near bottom)
srv_w  = 11.8;  srv_l = 22.5;  srv_h = 22.7;

// Split plane for printing halves
split_y = 0;  // YZ plane splits head front/rear

corner_r = 3;
$fn = 72;

// ============================================================
module outer_shell() {
    scale([rx, ry, rz]) sphere(r = 1);
}

module inner_cavity() {
    // Hollow out with uniform shell_t
    scale([rx - shell_t, ry - shell_t, rz - shell_t]) sphere(r = 1);
}

module eye_sockets() {
    for (sx = [-1, 1]) {
        translate([sx * eye_x_off, eye_y, eye_z_off])
            rotate([90, 0, 0])
                cylinder(r = eye_d/2, h = shell_t * 3 + 2, center = true);
    }
}

module neck_socket() {
    // Receiver boss on bottom of head
    translate([0, 0, -rz - neck_depth + neck_depth])
        cylinder(r = neck_pvc_od/2 + neck_wall, h = neck_depth);
    // Bore through boss
    translate([0, 0, -rz - 0.1])
        cylinder(r = neck_pvc_od/2 + 0.3, h = neck_depth + 0.2);
}

module servo_pocket_pan() {
    // Pan servo pocket (horizontal inside head lower section)
    translate([-srv_w/2, -srv_l/2, -rz + shell_t + 2])
        cube([srv_w, srv_l, srv_h + 1]);
}

module rear_hatch() {
    // Rectangular opening on the rear face for wiring
    translate([0, -ry - 0.1, 5])
        rotate([90, 0, 0])
            cube([30, 20, shell_t * 2 + 0.2], center = true);
}

// ============================================================
difference() {
    union() {
        outer_shell();
        neck_socket();
    }
    inner_cavity();
    eye_sockets();
    servo_pocket_pan();
    rear_hatch();
    // Cut to front half only (for printing); remove this line for full view
    // translate([0, -100, -100]) cube([200, 100, 200]);
}
