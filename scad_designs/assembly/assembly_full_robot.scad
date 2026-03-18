// ============================================================
// assembly_full_robot.scad
// Complete Humanoid Welcoming Robot Visualization
// All components positioned in anatomically correct layout
//
// Color coding:
//   GI frame          = DimGray
//   PVC pipes         = White
//   3D-printed parts  = SteelBlue / CornflowerBlue
//   Servos            = DarkGray
//   Head              = LightSkyBlue
//   Electronics       = DarkGreen
//
// Usage:
//   Toggle show_* variables to isolate subsystems
//   Set show_gesture_namaste = true for greeting pose
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// ============================================================
// Visibility toggles
// ============================================================
show_base            = true;
show_torso           = true;
show_arms            = true;
show_head            = true;
show_hands           = true;
show_gesture_namaste = false;  // set true for greeting pose

// ============================================================
// Include component modules
// ============================================================
use <../joints/shoulder_joint_bracket.scad>
use <../joints/elbow_joint_bracket.scad>
use <../joints/motor_bracket.scad>
use <../joints/caster_wheel_bracket.scad>
use <../joints/pan_tilt_head_mount.scad>
use <../fingers/palm_structure.scad>
use <../fingers/tendon_pulley.scad>
use <../head/head_shell.scad>
use <../head/head_internal_bracket.scad>
use <torso_base_connector.scad>
use <elastic_band_anchor.scad>
use <finger_assembly_single.scad>

// ============================================================
// Global dimensions
// ============================================================
// Base (GI square pipe frame)
base_w        = 400;   // mm
base_d        = 300;   // mm
base_h        = 120;   // mm
gi_pipe_sz    = 25;    // mm  square section

// Torso
torso_h       = 300;   // mm  torso height above base
torso_d       = 40;    // mm  PVC torso column diameter
torso_offset  = 50;    // mm  connector spacer height

// Arm geometry
upper_arm_len = 180;   // mm  PVC upper arm tube length
forearm_len   = 160;   // mm  PVC forearm tube length
pvc_od        = 25;    // mm  PVC outer diameter
pvc_bore      = 20;    // mm  PVC inner diameter

// Head
head_h        = 90;    // mm
head_d_w      = 85;    // mm

// Approximate body heights from ground
ground_z       = 0;
base_top_z     = base_h;
torso_top_z    = base_top_z + torso_offset + torso_h;
shoulder_z     = base_top_z + torso_offset + torso_h * 0.85;
elbow_z        = shoulder_z - upper_arm_len;
wrist_z        = elbow_z    - forearm_len;
head_bottom_z  = torso_top_z;

// Arm angles (neutral position)
shoulder_angle_neutral = 0;    // degrees from vertical
elbow_angle_neutral    = 0;    // degrees

// Arm angles (namaste greeting pose)
shoulder_angle_namaste  = 70;   // arms raised
elbow_angle_namaste     = 90;   // elbows bent bringing palms together

shoulder_angle = show_gesture_namaste ? shoulder_angle_namaste
                                      : shoulder_angle_neutral;
elbow_angle    = show_gesture_namaste ? elbow_angle_namaste
                                      : elbow_angle_neutral;

// ============================================================
// Module: gi_base_frame
// Rectangular GI square-pipe base perimeter
// ============================================================
module gi_base_frame() {
    color("DimGray") {
        // Four perimeter rails
        // Front & back (along X)
        for (dy = [0, base_d - gi_pipe_sz])
            translate([0, dy, 0])
                cube([base_w, gi_pipe_sz, gi_pipe_sz]);
        // Left & right (along Y)
        for (dx = [0, base_w - gi_pipe_sz])
            translate([dx, gi_pipe_sz, 0])
                cube([gi_pipe_sz, base_d - 2 * gi_pipe_sz, gi_pipe_sz]);
        // Corner vertical legs
        for (cx = [0, base_w - gi_pipe_sz])
            for (cy = [0, base_d - gi_pipe_sz])
                translate([cx, cy, gi_pipe_sz])
                    cube([gi_pipe_sz, gi_pipe_sz, base_h - gi_pipe_sz]);
        // Cross brace (diagonal) – simplified as mid-rail
        translate([gi_pipe_sz, base_d / 2 - gi_pipe_sz / 2, 0])
            cube([base_w - 2 * gi_pipe_sz, gi_pipe_sz, gi_pipe_sz]);
    }
}

// ============================================================
// Module: drive_wheel
// Simplified wheel representation
// ============================================================
module drive_wheel() {
    color("Black")
        rotate([90, 0, 0])
            cylinder(d = 80, h = 20, center = true);
    color("DimGray")
        rotate([90, 0, 0])
            cylinder(d = 30, h = 22, center = true);
}

// ============================================================
// Module: pvc_tube
// Straight PVC tube segment
// ============================================================
module pvc_tube(length) {
    color("White")
        difference() {
            cylinder(d = pvc_od, h = length);
            translate([0, 0, -0.1])
                cylinder(d = pvc_bore, h = length + 0.2);
        }
}

// ============================================================
// Module: torso_column
// Main vertical PVC torso (2 side-by-side columns)
// ============================================================
module torso_column() {
    color("White")
        for (dx = [-20, 20])
            translate([dx, 0, 0])
                difference() {
                    cylinder(d = pvc_od, h = torso_h);
                    translate([0, 0, -0.1])
                        cylinder(d = pvc_bore, h = torso_h + 0.2);
                }
}

// ============================================================
// Module: electronics_box
// Simplified enclosure for ESP32-S3 + PCA9685 + battery
// ============================================================
module electronics_box() {
    color("DarkGreen", 0.7)
        cube([120, 80, 60], center = true);
    // PCB label
    color("LimeGreen")
        translate([-55, -35, 25])
            cube([110, 70, 2]);
}

// ============================================================
// Module: arm_assembly
// One complete arm (upper arm + elbow + forearm)
// side = 1 for right, -1 for left
// ============================================================
module arm_assembly(side = 1) {
    // Shoulder bracket
    color("SteelBlue")
        rotate([0, side * shoulder_angle, 0])
            translate([-20, 0, 0])
                shoulder_joint_bracket();

    // Upper arm PVC
    color("White")
        rotate([0, side * shoulder_angle, 0])
            translate([0, -pvc_od / 2, -upper_arm_len])
                pvc_tube(upper_arm_len);

    // Elbow bracket
    color("SteelBlue")
        rotate([0, side * shoulder_angle, 0])
            translate([0, 0, -upper_arm_len])
                rotate([0, side * elbow_angle, 0])
                    elbow_joint_bracket();

    // Forearm PVC
    color("White")
        rotate([0, side * shoulder_angle, 0])
            translate([0, -pvc_od / 2, -upper_arm_len])
                rotate([0, side * elbow_angle, 0])
                    translate([0, 0, -forearm_len])
                        pvc_tube(forearm_len);

    // Palm (end of forearm)
    color("RoyalBlue")
        rotate([0, side * shoulder_angle, 0])
            translate([-30, -pvc_od / 2, -upper_arm_len])
                rotate([0, side * elbow_angle, 0])
                    translate([-0, 0, -forearm_len - 15])
                        palm_structure();
}

// ============================================================
// Render Full Robot
// ============================================================

// --- Base Frame ---
if (show_base) {
    // GI base
    gi_base_frame();
    // Drive wheels (left and right)
    translate([base_w * 0.25, -10, base_h / 2])
        drive_wheel();
    translate([base_w * 0.75, -10, base_h / 2])
        drive_wheel();
    // Caster wheel (rear centre)
    color("DarkSeaGreen")
        translate([base_w / 2, base_d + 10, 30])
            caster_wheel_bracket();
    // Motor brackets
    for (bx = [base_w * 0.25, base_w * 0.75])
        color("SteelBlue")
            translate([bx - 18, gi_pipe_sz, base_h - 15])
                motor_bracket();
}

// --- Torso ---
if (show_torso) {
    // Connector plates (4 corners)
    for (cx = [base_w * 0.25, base_w * 0.75])
        for (cy = [base_d * 0.3, base_d * 0.7])
            color("Crimson")
                translate([cx - 35, cy - 25, base_h])
                    torso_base_connector();
    // Torso PVC columns
    translate([base_w / 2, base_d / 2, base_h + torso_offset])
        torso_column();
    // Electronics enclosure (mid-torso)
    translate([base_w / 2, base_d / 2, base_h + torso_offset + torso_h * 0.4])
        electronics_box();
}

// --- Arms ---
if (show_arms) {
    // Right arm
    translate([base_w / 2 + 60, base_d / 2, shoulder_z])
        arm_assembly(side = 1);
    // Left arm
    translate([base_w / 2 - 60, base_d / 2, shoulder_z])
        arm_assembly(side = -1);
}

// --- Head ---
if (show_head) {
    // Pan-tilt mount
    color("SteelBlue")
        translate([base_w / 2, base_d / 2, head_bottom_z])
            pan_tilt_head_mount();
    // Head shell
    color("LightSkyBlue", 0.85)
        translate([base_w / 2, base_d / 2, head_bottom_z + 80])
            head_shell();
    // Internal bracket (inside head, shown separately)
    color("SteelBlue", 0.5)
        translate([base_w / 2, base_d / 2, head_bottom_z + 60])
            head_internal_bracket();
}

// ============================================================
// Dimension annotations (echo to console)
// ============================================================
echo("=== Full Robot Assembly ===");
echo(str("Base (GI pipe): ", base_w, " x ", base_d, " x ", base_h, " mm"));
echo(str("Torso height: ", torso_h, " mm"));
echo(str("Total robot height: ~", base_h + torso_offset + torso_h + head_h, " mm"));
echo(str("Shoulder height: ~", shoulder_z, " mm from ground"));
echo(str("Namaste mode: ", show_gesture_namaste ? "ON" : "OFF"));
