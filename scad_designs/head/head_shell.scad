// ============================================================
// head_shell.scad
// Humanoid Head Shell for Welcoming Robot
// Ellipsoid/spherical shell with eye sockets + neck mount
//
// Print Settings:
//   Material:    PLA
//   Infill:      15% (lightweight)
//   Layer height: 0.2 mm
//   Supports:    None required (flat base)
//   Weight:      ~85 g
//   Print time:  ~25 minutes
// ============================================================

$fn = 64;
$fa = 4;
$fs = 1;

// --- Parametric Variables ---
head_diameter     = 85;         // mm  overall width (left-right)
head_height       = 90;         // mm  overall height
head_depth        = 75;         // mm  front-to-back depth
shape             = "ellipsoid"; // "ellipsoid" or "sphere"
wall_thickness    = 3;          // mm  shell wall thickness
eye_socket_d      = 10;         // mm  eye socket bore (for LED modules)
eye_spacing       = 30;         // mm  centre-to-centre eye distance
neck_bore_d       = 22;         // mm  neck adapter bore
neck_bore_depth   = 15;         // mm  depth of neck adapter recess
neck_flange_d     = 35;         // mm  neck flange outer diameter

// Face feature position
eye_height_frac   = 0.55;       // fraction up from base (eye level)
eye_depth_frac    = 0.48;       // fraction toward front face

// ============================================================
// Module: head_outer
// Outer ellipsoid (or sphere) shape
// ============================================================
module head_outer() {
    if (shape == "sphere") {
        sphere(d = head_diameter);
    } else {
        scale([head_diameter / head_height,
               head_depth / head_height, 1])
            sphere(d = head_height);
    }
}

// ============================================================
// Module: head_inner_cavity
// Slightly smaller ellipsoid hollows the shell
// ============================================================
module head_inner_cavity() {
    inner_d = head_diameter - 2 * wall_thickness;
    inner_h = head_height   - 2 * wall_thickness;
    inner_p = head_depth    - 2 * wall_thickness;
    if (shape == "sphere") {
        sphere(d = inner_d);
    } else {
        scale([inner_d / inner_h, inner_p / inner_h, 1])
            sphere(d = inner_h);
    }
}

// ============================================================
// Module: eye_socket_pair
// Two cylindrical bores through the front face
// ============================================================
module eye_socket_pair() {
    eye_z  =  head_height * (eye_height_frac - 0.5);
    eye_fy =  head_depth  * eye_depth_frac;
    for (ex = [-eye_spacing / 2, eye_spacing / 2])
        translate([ex, eye_fy, eye_z])
            rotate([90, 0, 0])
                cylinder(d = eye_socket_d, h = head_depth / 2 + 1);
}

// ============================================================
// Module: neck_mount
// Bottom opening with flange for pan-tilt mount ring
// ============================================================
module neck_mount() {
    base_z = -head_height / 2;   // bottom of head
    // Flange ring recessed from bottom
    translate([0, 0, base_z - neck_bore_depth + neck_bore_depth])
        difference() {
            cylinder(d = neck_flange_d, h = neck_bore_depth);
            translate([0, 0, -0.1])
                cylinder(d = neck_bore_d, h = neck_bore_depth + 0.2);
        }
}

// ============================================================
// Module: flat_base_cut
// Removes bottom hemisphere cap → creates flat bottom face
// (enables printing without support)
// ============================================================
module flat_base_cut() {
    cut_z = -head_height / 2;
    translate([-head_diameter, -head_depth, cut_z - head_height])
        cube([head_diameter * 2, head_depth * 2, head_height]);
}

// ============================================================
// Module: head_shell
// Final shell assembly
// ============================================================
module head_shell() {
    difference() {
        union() {
            // Outer shell
            difference() {
                head_outer();
                head_inner_cavity();
                flat_base_cut();
            }
            // Neck mount flange (added back to bottom)
            translate([0, 0, -head_height / 2 - neck_bore_depth])
                neck_mount();
        }
        // Eye sockets
        eye_socket_pair();
        // Neck bore through bottom
        translate([0, 0, -head_height / 2 - neck_bore_depth - 0.1])
            cylinder(d = neck_bore_d, h = neck_bore_depth + wall_thickness + 0.2);
        // Internal bottom access hole (electronics routing)
        translate([0, 0, -head_height / 2 - neck_bore_depth - 0.1])
            cylinder(d = neck_flange_d - wall_thickness * 2,
                     h = wall_thickness + 0.2);
    }
}

// ============================================================
// Render
// ============================================================
color("LightSkyBlue", 0.85)
    head_shell();
