// ============================================================
// Palm Structure — Tendon-Driven Robotic Hand
// ============================================================
// Houses a single MG90S servo that drives all three finger
// tendons simultaneously via a central tendon pulley.
//
// Dimensions  :  60 mm (L) × 50 mm (W) × 15 mm (H)
// Servo mount : MG90S (22.5 × 11.8 × 22.7 mm body)
// Finger sockets: 3 × rectangular slots along distal edge
// Tendon channels: 3 smooth internal paths from servo pulley
//                  exit to finger socket entry holes
// Forearm mount : 20 mm PVC pipe receiver on proximal face
// ============================================================

// ---- Parameters -------------------------------------------
palm_l      = 60;    // mm — palm length (proximal–distal)
palm_w      = 50;    // mm — palm width (finger spread)
palm_h      = 15;    // mm — palm thickness
wall        =  2;    // mm — minimum wall

// MG90S servo dimensions
srv_l       = 22.5;
srv_w       = 11.8;
srv_h       = 22.7;
srv_tab_l   = 32;    // mm — tab-to-tab length
srv_tab_h   =  2.5;  // mm — tab thickness
srv_tab_w   =  4;    // mm — tab width (mounting ear)

// Finger socket (fits finger proximal-lug width + tolerance)
finger_w    = 11;    // mm — socket width
finger_h    =  8;    // mm — socket height
finger_sep  = 13;    // mm — centre-to-centre spacing
n_fingers   =  3;

// Tendon routing hole in palm exit (slightly larger than finger tendon hole)
tendon_hole_dia  =  1.6;  // mm — slightly larger than 1.35 mm

// PVC pipe receiver (forearm attachment, proximal face)
pvc_od      = 20;    // mm — PVC outer diameter
pvc_wall    =  2;    // mm — receiver socket wall

// Pin holes for finger segment attachment
pin_dia     =  2.0;
pin_tol     =  0.1;

// Pulley post (servo horn connector reference point)
pulley_x    =  0;    // centred in X
pulley_y    = 10;    // mm from proximal edge (centre of servo bay)
pulley_z    = palm_h + 2;  // mm — above palm top surface (horn height)
pulley_r    =  6;    // mm — effective tendon wrap radius

corner_r    =  2;
$fn = 48;

// ---- Derived -----------------------------------------------
pin_r = (pin_dia + pin_tol) / 2;

// Finger socket Y positions (along palm width, centred)
function finger_y(i) = -finger_sep + i * finger_sep;  // i = 0,1,2

// ============================================================
module servo_bay() {
    // Cavity for MG90S with mounting tabs
    union() {
        // Main body cavity
        translate([-srv_w/2, -srv_l/2, 0])
            cube([srv_w, srv_l, srv_h + 2]);
        // Tab recesses (left and right)
        for (dx = [-srv_tab_l/2, srv_tab_l/2 - srv_tab_w]) {
            translate([dx, -srv_tab_w/2, srv_h - srv_tab_h])
                cube([srv_tab_w, srv_tab_w, srv_tab_h + 1]);
        }
        // Horn exit hole (top)
        translate([0, 0, -1])
            cylinder(r = 6, h = palm_h + 3);
    }
}

module tendon_channel(finger_idx) {
    // Smooth curved channel from servo bay to finger socket exit.
    // Approximated as a cylinder tangent path (simplified as straight).
    fy = finger_y(finger_idx);
    hull() {
        translate([pulley_x, pulley_y, palm_h - wall - 0.1])
            cylinder(r = tendon_hole_dia/2 + 0.3, h = 0.2);
        translate([0, fy, palm_h - wall - 0.1])
            cylinder(r = tendon_hole_dia/2 + 0.3, h = 0.2);
    }
    // Vertical exit hole at finger socket
    translate([0, fy, 0])
        cylinder(r = tendon_hole_dia/2, h = palm_h + 1);
}

module finger_socket(finger_idx) {
    fy = finger_y(finger_idx);
    // Rectangular slot for proximal lug insertion
    translate([-finger_w/2, fy - finger_w/4, palm_h - finger_h])
        cube([finger_w, finger_w/2 + 0.5, finger_h + 1]);
    // Pin hole (horizontal, through socket walls)
    translate([0, fy, palm_h - finger_h/2])
        rotate([0, 90, 0])
            cylinder(r = pin_r, h = finger_w + 2, center = true);
}

module pvc_receiver() {
    // Cylindrical socket on proximal face for 20 mm PVC pipe
    translate([-palm_w/2 - pvc_wall, 0, palm_h/2])
        rotate([0, 90, 0]) {
            difference() {
                cylinder(r = pvc_od/2 + pvc_wall, h = 18);
                cylinder(r = pvc_od/2, h = 20);
            }
        }
}

// ============================================================
// Main palm body
// ============================================================
difference() {
    union() {
        // Main palm block (rounded)
        minkowski() {
            cube([palm_w - 2*corner_r,
                  palm_l - 2*corner_r,
                  palm_h - corner_r], center = true);
            cylinder(r = corner_r, h = corner_r, center = false);
        }
        // PVC receiver boss on proximal face
        translate([0, -palm_l/2, 0])
            pvc_receiver();
    }

    // Servo bay (centred in X, offset toward proximal side)
    translate([pulley_x, pulley_y - palm_l/2, -0.1])
        servo_bay();

    // Tendon channels & finger socket exit holes
    for (i = [0 : n_fingers - 1]) {
        translate([0, -palm_l/2, 0]) {
            tendon_channel(i);
            finger_socket(i);
        }
    }

    // Cable exit slot on proximal face (servo wire routing)
    translate([-3, -palm_l/2 - 0.1, 2])
        cube([6, wall + 0.2, palm_h - 3]);
}
