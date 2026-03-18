// ============================================================
// palm_structure.scad
// Palm Housing for Humanoid Welcoming Robot
// Servo cavity + tendon routing + 3-finger socket interfaces
//
// Print Settings:
//   Material:    PLA
//   Infill:      20% (adequate strength for servo mounting)
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~25 g
//   Print time:  ~12 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
palm_length              = 60;   // mm  palm body length (wrist to knuckles)
palm_width               = 50;   // mm  palm body width
palm_thickness           = 15;   // mm  palm body depth
servo_width              = 23;   // mm  MG90S servo
servo_depth              = 12;   // mm  MG90S servo depth
servo_height             = 22;   // mm  MG90S servo height
finger_socket_diameter   = 10;   // mm  socket bore for finger proximal boss
tendon_channel_diameter  = 1.5;  // mm  internal tendon routing channel
mounting_hole_diameter   = 3;    // mm  M3 assembly screws
wall_min                 = 1.5;  // mm  minimum wall

// Derived
servo_pocket_x  = servo_width  + 1;   // clearance
servo_pocket_y  = servo_depth  + 1;
servo_pocket_z  = servo_height + 1;
// Finger sockets: 3 fingers in a row across palm width
finger_spacing  = palm_width / 4;     // spacing between finger centres
finger_cx       = [palm_width * 0.2,
                   palm_width * 0.5,
                   palm_width * 0.8];  // X positions of the 3 fingers

// ============================================================
// Module: palm_body
// Main solid block with rounded edges
// ============================================================
module palm_body() {
    r = 3;  // edge rounding
    hull()
        for (sx = [r, palm_length - r])
            for (sy = [r, palm_width - r])
                translate([sx, sy, 0])
                    cylinder(r = r, h = palm_thickness);
}

// ============================================================
// Module: servo_cavity
// Recessed slot for MG90S servo with screw retention holes
// ============================================================
module servo_cavity() {
    cx = (palm_length - servo_pocket_x) / 2;
    cy = (palm_width  - servo_pocket_y) / 2;
    // Servo body pocket (from bottom face)
    translate([cx, cy, wall_min])
        cube([servo_pocket_x, servo_pocket_y, servo_pocket_z]);
    // Servo wire exit slot
    translate([cx + servo_pocket_x / 2 - 3, -0.1, wall_min])
        cube([6, cy + 0.2, servo_pocket_z / 2]);
    // Servo mounting screw holes (4-point flanges)
    for (sx = [cx - 2, cx + servo_pocket_x + 2 - mounting_hole_diameter])
        for (sy = [cy + 2, cy + servo_pocket_y - 2 - mounting_hole_diameter])
            translate([sx, sy, -0.1])
                cylinder(d = mounting_hole_diameter,
                         h = wall_min + 0.2);
}

// ============================================================
// Module: finger_sockets
// Three cylindrical sockets on the knuckle (distal) face
// Receives the proximal finger segment hinge bosses
// ============================================================
module finger_sockets() {
    for (cx = finger_cx)
        translate([palm_length - 0.1, cx, palm_thickness / 2])
            rotate([0, 90, 0])
                cylinder(d = finger_socket_diameter,
                         h = wall_min * 3 + 0.2);
}

// ============================================================
// Module: tendon_channels
// Internal routed channels from servo horn pulley to each finger socket
// ============================================================
module tendon_channels() {
    pulley_x = palm_length / 2;  // servo horn at palm centre
    pulley_y = palm_width  / 2;
    pulley_z = palm_thickness - wall_min - 1;

    for (cx = finger_cx) {
        // Diagonal internal channel (from pulley to socket)
        hull() {
            translate([pulley_x, pulley_y, pulley_z])
                sphere(d = tendon_channel_diameter + 0.5);
            translate([palm_length - wall_min * 3 - 0.5, cx, palm_thickness / 2])
                sphere(d = tendon_channel_diameter + 0.5);
        }
    }
}

// ============================================================
// Module: pulley_mount_boss
// Boss on top face where servo horn pulley sits
// ============================================================
module pulley_mount_boss() {
    boss_d = 10;
    boss_h = 4;
    translate([palm_length / 2, palm_width / 2, palm_thickness])
        cylinder(d = boss_d, h = boss_h);
}

// ============================================================
// Module: elastic_anchor_holes
// Four holes on bottom face for elastic band anchors
// ============================================================
module elastic_anchor_holes() {
    for (i = [0 : 2])
        for (side = [-1, 1])
            translate([palm_length * 0.7 + i * 3,
                       palm_width / 2 + side * 8,
                       -0.1])
                cylinder(d = 2.1, h = wall_min + 0.2);
}

// ============================================================
// Module: wrist_mount_plate
// Bottom plate with holes for forearm PVC attachment
// ============================================================
module wrist_mount_holes() {
    for (sy = [palm_width * 0.25, palm_width * 0.75])
        translate([8, sy, -0.1])
            cylinder(d = mounting_hole_diameter, h = palm_thickness + 0.2);
}

// ============================================================
// Module: palm_structure
// Complete palm assembly
// ============================================================
module palm_structure() {
    difference() {
        union() {
            palm_body();
            pulley_mount_boss();
        }
        servo_cavity();
        finger_sockets();
        tendon_channels();
        elastic_anchor_holes();
        wrist_mount_holes();
    }
}

// ============================================================
// Render
// ============================================================
color("RoyalBlue")
    palm_structure();
