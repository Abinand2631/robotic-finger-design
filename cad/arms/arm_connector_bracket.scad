// ============================================================
// Arm Connector Bracket — PVC pipe to servo horn
// ============================================================
// Generic bracket connecting a 20 mm PVC arm segment to a
// standard servo horn (cross/disc horn, 4-arm style).
//
// Used at both shoulder (MG996R) and elbow (MG90S) joints.
// The horn side has a circular recess; the PVC side has a
// split collar clamp (tighten with one M3 bolt).
// ============================================================

pvc_od      = 20;    // mm — PVC outer diameter
pvc_tol     =  0.3;  // mm — diametric clearance
collar_len  = 22;    // mm — clamp length along pipe axis
collar_wall =  3;    // mm — wall around pipe
clamp_gap   =  1.2;  // mm — slot width for tightening

horn_recess_d   = 24;  // mm — servo horn boss outer diameter
horn_recess_h   =  4;  // mm — recess depth
horn_centre_d   =  5;  // mm — servo shaft spline boss
horn_bolt_d     =  2.1;// mm — M2 horn bolt clearance
horn_bolt_r     =  9;  // mm — bolt circle radius
horn_arms       =  4;  // number of horn arms

plate_w   = 30;   // mm — bridge plate width
plate_h   = 25;   // mm — bridge plate height (collar to horn)
plate_t   =  3;   // mm — plate thickness
screw_d   =  3.4; // mm — M3 clamp bolt

$fn = 48;
pvc_r    = (pvc_od + pvc_tol) / 2;
col_r    = pvc_r + collar_wall;

// ============================================================
module collar() {
    difference() {
        cylinder(r = col_r, h = collar_len);
        // PVC bore
        cylinder(r = pvc_r, h = collar_len + 1);
        // Clamp slot (radial)
        translate([-clamp_gap/2, col_r - collar_wall - 1, -0.1])
            cube([clamp_gap, collar_wall + 2, collar_len + 0.2]);
    }
    // Clamp ear
    translate([col_r, -(screw_d*2)/2, 0])
        difference() {
            cube([8, screw_d * 2, collar_len]);
            translate([4, screw_d, collar_len/2])
                rotate([0, 90, 0])
                    cylinder(r = screw_d/2, h = 9, center = true);
        }
}

module horn_plate() {
    // Bridge plate centred, with horn recess on one face
    translate([-plate_w/2, col_r, 0])
        difference() {
            cube([plate_w, plate_h, plate_t]);
            // Horn recess (circular, from top face)
            translate([plate_w/2, plate_h - horn_recess_d/2 - 2,
                        plate_t - horn_recess_h + 0.1])
                cylinder(r = horn_recess_d/2, h = horn_recess_h + 0.1);
            // Horn centre spline boss hole
            translate([plate_w/2, plate_h - horn_recess_d/2 - 2, -0.1])
                cylinder(r = horn_centre_d/2, h = plate_t + 0.2);
            // Horn bolt holes
            for (i = [0 : horn_arms - 1]) {
                rotate([0, 0, i * 360/horn_arms])
                    translate([plate_w/2 + horn_bolt_r,
                               plate_h - horn_recess_d/2 - 2,
                               -0.1])
                        cylinder(r = horn_bolt_d/2, h = plate_t + 0.2);
            }
        }
}

// ============================================================
union() {
    color("LightSlateGray") collar();
    color("SlateGray")      horn_plate();
}
