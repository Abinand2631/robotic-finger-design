// ============================================================
// Shoulder Joint Bracket — MG996R servo to 20 mm PVC pipe
// ============================================================
// Mounts an MG996R servo to the torso shoulder post and
// connects the output horn to the upper-arm PVC pipe.
//
// The bracket has two parts:
//   1. Servo clamp — wraps around MG996R body with M3 screws
//   2. PVC pipe collar — receives 20 mm PVC upper-arm tube
//
// Print orientation: flat face down, no supports needed.
// Material: PLA, 80 % infill for rigidity.
// ============================================================

// MG996R body dimensions
srv_w  = 20.0;  // mm
srv_l  = 40.5;  // mm
srv_h  = 36.5;  // mm
tab_l  = 54.5;  // mm — tab-to-tab
tab_h  =  3.0;  // mm — tab thickness
tab_w  =  5.0;  // mm — ear width

// PVC collar
pvc_od  = 20;   // mm
pvc_tol =  0.3; // mm — diametric clearance
collar_h = 22;  // mm — collar length (clamping zone)
collar_w =  3.5;// mm — wall around PVC

// Clamp screw holes (M3)
screw_d  = 3.4; // mm — clearance hole
screw_sep = 30; // mm — between clamp screw centres

wall     = 2.5; // mm
corner_r = 2.0;
$fn = 48;

// ---- Derived -----------------------------------------------
outer_w  = srv_w + 2 * wall;
outer_l  = srv_l + 2 * wall;
outer_h  = tab_h + wall;

pvc_r    = (pvc_od + pvc_tol) / 2;
collar_r = pvc_r + collar_w;

// ============================================================
module servo_clamp_body() {
    difference() {
        // Outer block
        translate([-outer_w/2, -outer_l/2, 0])
            cube([outer_w, outer_l, outer_h]);

        // Servo body cavity
        translate([-srv_w/2, -srv_l/2, wall])
            cube([srv_w, srv_l, srv_h + 1]);

        // Tab recesses
        translate([-tab_l/2, -tab_w/2, wall])
            cube([tab_l, tab_w, tab_h + 0.5]);

        // Clamp screw holes (for tightening around servo body)
        for (dy = [-screw_sep/2, screw_sep/2]) {
            translate([0, dy, -0.1])
                cylinder(r = screw_d/2, h = wall + 0.2);
        }

        // Output-shaft clearance hole (top face)
        translate([0, -srv_l/2 + 10, -0.1])
            cylinder(r = 7, h = wall + 0.2);
    }
}

module pvc_collar() {
    // Horizontal collar extending from the bracket side face
    // so the upper-arm PVC pipe inserts perpendicular to the servo.
    translate([outer_w/2, 0, outer_h/2])
        rotate([0, 90, 0]) {
            difference() {
                cylinder(r = collar_r, h = collar_h);
                // PVC bore
                cylinder(r = pvc_r, h = collar_h + 1);
                // Clamp slot (allows tightening with M3 bolt)
                translate([-0.75, collar_r - collar_w - 0.5, -0.1])
                    cube([1.5, collar_w + 1, collar_h + 0.2]);
            }
            // Clamp ear with M3 bolt hole
            translate([collar_r - 0.5, -collar_w/2, 0])
                difference() {
                    cube([5, collar_w, collar_h]);
                    translate([2.5, collar_w/2, collar_h/2])
                        rotate([90, 0, 0])
                            cylinder(r = screw_d/2, h = collar_w + 1, center = true);
                }
        }
}

// ============================================================
union() {
    color("LightGray") servo_clamp_body();
    color("DarkGray")  pvc_collar();
}
