// ============================================================
// elbow_joint_bracket.scad
// Elbow Joint Bracket for Humanoid Welcoming Robot
// Servo mount interface for MG90S servo + dual PVC pipe adapters
//
// Print Settings:
//   Material:    PLA
//   Infill:      80%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~15 g
//   Print time:  ~6 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
servo_width            = 23;   // mm  MG90S body width
servo_depth            = 12;   // mm  MG90S body depth
servo_height           = 22;   // mm  MG90S body height
pvc_bore               = 20;   // mm  PVC pipe inner diameter
pvc_wall               = 2.5;  // mm  PVC pipe wall thickness
mounting_hole_diameter = 2.5;  // mm  M2.5 screw holes
wall_thickness         = 2.0;  // mm  bracket wall thickness

// Derived
pvc_od             = pvc_bore + 2 * pvc_wall;
servo_mount_length = servo_width  + 2 * wall_thickness;
servo_mount_width  = servo_depth  + 2 * wall_thickness;
servo_mount_height = servo_height + wall_thickness;

// ============================================================
// Module: pvc_side_adapter
// Single-side PVC collar
// ============================================================
module pvc_side_adapter(h = 20) {
    collar_od = pvc_od + 2 * wall_thickness * 1.5;
    difference() {
        cylinder(d = collar_od, h = h);
        translate([0, 0, -0.1])
            cylinder(d = pvc_bore, h = h + 0.2);
        // Retention screw hole
        translate([0, 0, h / 2])
            rotate([90, 0, 0])
                cylinder(d = mounting_hole_diameter,
                         h = collar_od + 0.2, center = true);
    }
}

// ============================================================
// Module: servo_pocket_mg90s
// Recessed pocket for MG90S servo body
// ============================================================
module servo_pocket_mg90s() {
    translate([wall_thickness, wall_thickness, wall_thickness])
        cube([servo_width, servo_depth, servo_height + 1]);
}

// ============================================================
// Module: elbow_joint_bracket
// Central servo block flanked by two PVC adapters
// ============================================================
module elbow_joint_bracket() {
    adapter_h  = 22;
    total_span = adapter_h + servo_mount_length + adapter_h;

    difference() {
        union() {
            // Central servo mount block
            translate([adapter_h, 0, 0])
                cube([servo_mount_length, servo_mount_width, servo_mount_height]);
            // Left PVC adapter (upper arm side)
            translate([adapter_h / 2, servo_mount_width / 2,
                       servo_mount_height / 2])
                rotate([0, 90, 0])
                    rotate([0, 0, 90])
                        pvc_side_adapter(adapter_h);
            // Right PVC adapter (forearm side)
            translate([adapter_h + servo_mount_length +
                       servo_mount_height / 2,
                       servo_mount_width / 2,
                       servo_mount_height / 2])
                rotate([0, 90, 0])
                    rotate([0, 0, 90])
                        pvc_side_adapter(adapter_h);
        }
        // Servo cavity
        translate([adapter_h, 0, 0])
            servo_pocket_mg90s();
        // Servo horn centre hole
        cx = adapter_h + servo_mount_length / 2;
        cy = servo_mount_width / 2;
        translate([cx, cy, servo_mount_height - 0.1])
            cylinder(d = 5, h = wall_thickness + 0.2);
        // Servo mounting screw holes (2 each side of servo)
        for (side = [-1, 1])
            translate([adapter_h + servo_mount_length / 2 +
                       side * (servo_width / 2 + wall_thickness / 2),
                       servo_mount_width / 2,
                       -0.1])
                cylinder(d = mounting_hole_diameter,
                         h = servo_mount_height + 0.2);
    }
}

// ============================================================
// Render
// ============================================================
color("SteelBlue")
    elbow_joint_bracket();
