// ============================================================
// shoulder_joint_bracket.scad
// Shoulder Joint Bracket for Humanoid Welcoming Robot
// Servo mount interface for MG996R servo + PVC pipe adapter
//
// Print Settings:
//   Material:    PLA
//   Infill:      80%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~20 g
//   Print time:  ~8 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
servo_width            = 40.5; // mm  MG996R body width
servo_depth            = 20;   // mm  MG996R body depth
servo_height           = 37;   // mm  MG996R body height
servo_flange_thickness = 2.5;  // mm  mounting flange thickness
pvc_bore               = 20;   // mm  PVC pipe inner diameter
pvc_wall               = 2.5;  // mm  PVC pipe wall thickness (OD ~25 mm)
mounting_hole_diameter = 3.2;  // mm  M3 screw holes
wall_thickness         = 2.0;  // mm  bracket wall thickness
corner_radius          = 1.5;  // mm  reinforced bearing surface radius

// Derived
pvc_od = pvc_bore + 2 * pvc_wall;            // outer diameter ~25 mm
servo_mount_length = servo_width + 2 * wall_thickness;
servo_mount_width  = servo_depth + 2 * wall_thickness;
servo_mount_height = servo_height + wall_thickness;

// Horn mounting hole positions (4-point, 8 mm from servo centre)
horn_hole_offset = 8;

// ============================================================
// Module: servo_pocket
// Recessed cavity for MG996R servo body
// ============================================================
module servo_pocket() {
    translate([wall_thickness, wall_thickness, wall_thickness])
        cube([servo_width, servo_depth, servo_height + 1]);
}

// ============================================================
// Module: servo_horn_holes
// 4-point servo horn mounting holes on top face
// ============================================================
module servo_horn_holes() {
    cx = servo_mount_length / 2;
    cy = servo_mount_width  / 2;
    z  = servo_mount_height - 0.1;
    for (dx = [-horn_hole_offset, horn_hole_offset])
        for (dy = [-horn_hole_offset, horn_hole_offset])
            translate([cx + dx, cy + dy, z])
                cylinder(d = mounting_hole_diameter, h = wall_thickness + 0.2);
}

// ============================================================
// Module: pvc_adapter
// Cylindrical PVC adapter collar with screw-mount tabs
// ============================================================
module pvc_adapter() {
    adapter_height = 25;
    collar_od      = pvc_od + 2 * wall_thickness * 2; // thick collar
    tab_width      = 8;
    tab_thickness  = wall_thickness;

    difference() {
        union() {
            // Main collar
            cylinder(d = collar_od, h = adapter_height);
            // Side mounting tabs
            for (a = [0, 180])
                rotate([0, 0, a])
                    translate([collar_od / 2 - 0.5, -tab_width / 2, 0])
                        cube([tab_width, tab_width, adapter_height]);
        }
        // PVC bore through entire height
        translate([0, 0, -0.1])
            cylinder(d = pvc_bore, h = adapter_height + 0.2);
        // Screw holes in tabs
        for (a = [0, 180])
            rotate([0, 0, a])
                translate([collar_od / 2 + tab_width / 2, 0, adapter_height / 2])
                    rotate([0, 90, 0])
                        cylinder(d = mounting_hole_diameter, h = tab_width + 1,
                                 center = true);
    }
}

// ============================================================
// Module: shoulder_joint_bracket
// Main bracket body
// ============================================================
module shoulder_joint_bracket() {
    difference() {
        union() {
            // Servo mount block
            cube([servo_mount_length, servo_mount_width, servo_mount_height]);
            // PVC adapter – positioned on the side face
            translate([servo_mount_length, servo_mount_width / 2,
                       servo_mount_height / 2])
                rotate([0, 90, 0])
                    pvc_adapter();
        }
        // Remove servo cavity
        servo_pocket();
        // Remove servo horn mounting holes
        servo_horn_holes();
        // Round inside corners for bearing surface
        translate([corner_radius, corner_radius, -0.1])
            cylinder(r = corner_radius, h = servo_mount_height + 0.2);
        translate([servo_mount_length - corner_radius, corner_radius, -0.1])
            cylinder(r = corner_radius, h = servo_mount_height + 0.2);
    }
}

// ============================================================
// Render
// ============================================================
color("SteelBlue")
    shoulder_joint_bracket();
