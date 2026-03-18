// ============================================================
// pan_tilt_head_mount.scad
// Pan-Tilt Head Servo Mount for Humanoid Welcoming Robot
// Pan (left-right) + Tilt (up-down) dual MG90S servo bracket
//
// Print Settings:
//   Material:    PLA
//   Infill:      70%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~18 g
//   Print time:  ~10 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
servo_width         = 23;   // mm  MG90S body width
servo_depth         = 12;   // mm  MG90S body depth
servo_height        = 22;   // mm  MG90S body height
head_mount_diameter = 80;   // mm  head shell interface diameter
neck_diameter       = 20;   // mm  neck tube / torso mount diameter
wall_thickness      = 2.0;  // mm  bracket wall thickness
screw_d             = 2.5;  // mm  M2.5 mounting screw diameter

// Derived
servo_box_x = servo_width  + 2 * wall_thickness;
servo_box_y = servo_depth  + 2 * wall_thickness;
servo_box_z = servo_height + wall_thickness;

// ============================================================
// Module: servo_pocket
// Standard MG90S recessed cavity
// ============================================================
module servo_pocket() {
    translate([wall_thickness, wall_thickness, wall_thickness])
        cube([servo_width, servo_depth, servo_height + 1]);
}

// ============================================================
// Module: pan_servo_mount
// Horizontal servo block (rotates the whole head left-right)
// ============================================================
module pan_servo_mount() {
    difference() {
        cube([servo_box_x, servo_box_y, servo_box_z]);
        servo_pocket();
        // Horn output hole (top face)
        translate([servo_box_x / 2, servo_box_y / 2, servo_box_z - 0.1])
            cylinder(d = 5, h = wall_thickness + 0.2);
        // Side screw holes for servo retention
        for (side = [-1, 1])
            translate([servo_box_x / 2 + side * (servo_width / 2 + 0.5),
                       servo_box_y / 2, -0.1])
                cylinder(d = screw_d, h = servo_box_z + 0.2);
    }
}

// ============================================================
// Module: tilt_servo_mount
// Vertical servo block (tilts head forward-back)
// ============================================================
module tilt_servo_mount() {
    difference() {
        cube([servo_box_x, servo_box_z, servo_box_y]);
        // Servo pocket (rotated 90° around X)
        translate([wall_thickness, wall_thickness, wall_thickness])
            cube([servo_width, servo_height + 1, servo_depth]);
        // Horn output hole (front face)
        translate([servo_box_x / 2, servo_box_z - 0.1, servo_box_y / 2])
            rotate([-90, 0, 0])
                cylinder(d = 5, h = wall_thickness + 0.2);
        // Side screw holes
        for (side = [-1, 1])
            translate([servo_box_x / 2 + side * (servo_width / 2 + 0.5),
                       -0.1, servo_box_y / 2])
                rotate([-90, 0, 0])
                    cylinder(d = screw_d, h = servo_box_z + 0.2);
    }
}

// ============================================================
// Module: neck_collar
// Collar that connects to the torso neck tube
// ============================================================
module neck_collar() {
    collar_h  = 20;
    collar_od = neck_diameter + 2 * wall_thickness * 1.5;
    difference() {
        cylinder(d = collar_od, h = collar_h);
        translate([0, 0, -0.1])
            cylinder(d = neck_diameter, h = collar_h + 0.2);
        // Retention screw
        translate([0, 0, collar_h / 2])
            rotate([90, 0, 0])
                cylinder(d = screw_d, h = collar_od + 0.2, center = true);
    }
}

// ============================================================
// Module: head_adapter_ring
// Ring that interfaces with the head shell bottom
// ============================================================
module head_adapter_ring() {
    ring_h    = 8;
    ring_wall = wall_thickness * 1.5;
    difference() {
        cylinder(d = head_mount_diameter, h = ring_h);
        translate([0, 0, ring_wall])
            cylinder(d = head_mount_diameter - 2 * ring_wall, h = ring_h);
        translate([0, 0, -0.1])
            cylinder(d = head_mount_diameter - 2 * ring_wall, h = ring_h + 0.2);
        // 4× screw holes for head attachment
        for (a = [0, 90, 180, 270])
            rotate([0, 0, a])
                translate([head_mount_diameter / 2 - ring_wall / 2, 0, ring_h / 2])
                    rotate([0, 90, 0])
                        cylinder(d = screw_d, h = ring_wall + 0.2, center = true);
    }
}

// ============================================================
// Module: link_arm
// Short arm connecting pan servo output to tilt servo frame
// ============================================================
module link_arm() {
    arm_length = 30;
    arm_w      = 8;
    arm_h      = 4;
    difference() {
        hull() {
            cylinder(d = arm_w, h = arm_h);
            translate([arm_length, 0, 0])
                cylinder(d = arm_w, h = arm_h);
        }
        translate([0, 0, -0.1])
            cylinder(d = 4, h = arm_h + 0.2);       // horn shaft
        translate([arm_length, 0, -0.1])
            cylinder(d = screw_d, h = arm_h + 0.2); // pivot pin
    }
}

// ============================================================
// Module: pan_tilt_head_mount
// Full assembly in default (neutral) position
// ============================================================
module pan_tilt_head_mount() {
    // Neck collar (bottom)
    neck_collar();
    // Pan servo (sits on neck collar, mounted horizontally)
    translate([-servo_box_x / 2, -servo_box_y / 2, 20])
        pan_servo_mount();
    // Link arm from pan servo horn
    translate([0, 0, 20 + servo_box_z])
        link_arm();
    // Tilt servo (perpendicular, mounted above link)
    translate([-servo_box_x / 2,
               servo_box_y + 4,
               20 + servo_box_z + 5])
        rotate([0, 0, 90])
            tilt_servo_mount();
    // Head adapter ring (top)
    translate([0, 0, 20 + servo_box_z + 5 + servo_box_y + 6])
        head_adapter_ring();
}

// ============================================================
// Render
// ============================================================
color("SteelBlue")
    pan_tilt_head_mount();
