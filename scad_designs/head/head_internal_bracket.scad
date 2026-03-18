// ============================================================
// head_internal_bracket.scad
// Internal Pan-Tilt Servo Bracket inside Head Shell
// Mounts two MG90S servos in perpendicular orientation
//
// Print Settings:
//   Material:    PLA
//   Infill:      70%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~12 g
//   Print time:  ~8 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
servo_width       = 23;   // mm  MG90S body width
servo_depth       = 12;   // mm  MG90S body depth
servo_height      = 22;   // mm  MG90S body height
linkage_rod_d     = 3;    // mm  servo horn linkage rod diameter
wall_thickness    = 2.0;  // mm  bracket wall
screw_d           = 2.5;  // mm  M2.5 mounting screw
neck_bore_d       = 22;   // mm  matches head_shell neck_bore
cross_bar_w       = 8;    // mm  cross-beam width

// Derived
servo_box_x = servo_width  + 2 * wall_thickness;
servo_box_y = servo_depth  + 2 * wall_thickness;
servo_box_z = servo_height + wall_thickness;

// ============================================================
// Module: servo_mount_block
// Generic MG90S mount block
// ============================================================
module servo_mount_block() {
    difference() {
        cube([servo_box_x, servo_box_y, servo_box_z]);
        // Servo cavity
        translate([wall_thickness, wall_thickness, wall_thickness])
            cube([servo_width, servo_depth, servo_height + 1]);
        // Horn output hole (top)
        translate([servo_box_x / 2, servo_box_y / 2, servo_box_z - 0.1])
            cylinder(d = 5, h = wall_thickness + 0.2);
        // Side retention screw holes
        for (side = [-1, 1])
            translate([servo_box_x / 2 + side * (servo_width / 2 + 0.5),
                       servo_box_y / 2, -0.1])
                cylinder(d = screw_d, h = servo_box_z + 0.2);
    }
}

// ============================================================
// Module: cross_frame
// Central cross-shaped structural frame that both servo blocks
// attach to, and which fixes to the neck bore flange
// ============================================================
module cross_frame() {
    frame_w = servo_box_x * 2 + 10;  // total span
    frame_h = 6;                      // frame thickness

    difference() {
        union() {
            // Horizontal beam
            translate([-frame_w / 2, -cross_bar_w / 2, 0])
                cube([frame_w, cross_bar_w, frame_h]);
            // Vertical beam
            translate([-cross_bar_w / 2, -frame_w / 2, 0])
                cube([cross_bar_w, frame_w, frame_h]);
            // Central neck collar
            cylinder(d = neck_bore_d + wall_thickness * 2, h = frame_h * 1.5);
        }
        // Neck bore
        translate([0, 0, -0.1])
            cylinder(d = neck_bore_d, h = frame_h * 1.5 + 0.2);
        // 4× mounting screw holes in collar
        for (a = [0, 90, 180, 270])
            rotate([0, 0, a + 45])
                translate([neck_bore_d / 2 + wall_thickness / 2, 0, frame_h / 2])
                    rotate([0, 90, 0])
                        cylinder(d = screw_d, h = wall_thickness + 0.2,
                                 center = true);
    }
}

// ============================================================
// Module: linkage_connector
// Small pivot/clevis that attaches linkage rod to servo horn
// ============================================================
module linkage_connector() {
    length = 20;
    ear_w  = 5;
    ear_h  = linkage_rod_d + wall_thickness * 2;
    difference() {
        union() {
            cylinder(d = 6, h = 3);   // horn attachment disc
            translate([0, -ear_w / 2, 0])
                cube([length, ear_w, ear_h]);
        }
        // Horn centre
        translate([0, 0, -0.1])
            cylinder(d = 4, h = 3.2);
        // Linkage rod bore at far end
        translate([length, 0, ear_h / 2])
            rotate([90, 0, 0])
                cylinder(d = linkage_rod_d + 0.2, h = ear_w + 0.2,
                         center = true);
    }
}

// ============================================================
// Module: head_internal_bracket
// Complete assembly
// ============================================================
module head_internal_bracket() {
    // Cross frame at base (mounts to neck)
    cross_frame();

    // Pan servo block (horizontal – left/right rotation)
    translate([-servo_box_x / 2, -servo_box_y / 2, 6])
        servo_mount_block();

    // Tilt servo block (vertical – up/down tilt, perpendicular)
    translate([-servo_box_y / 2,
               servo_box_x / 2 + 4,
               6])
        rotate([0, 0, 90])
            servo_mount_block();

    // Linkage connectors
    color("Silver")
        translate([0, 0, 6 + servo_box_z])
            linkage_connector();
    color("Silver")
        translate([servo_box_x / 2 + 4, 0, 6 + servo_box_z])
            rotate([0, 0, 90])
                linkage_connector();
}

// ============================================================
// Render
// ============================================================
color("SteelBlue")
    head_internal_bracket();
