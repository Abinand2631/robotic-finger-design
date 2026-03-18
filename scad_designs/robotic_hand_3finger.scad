// ============================================================
// robotic_hand_3finger.scad
// 3-Finger Cable-Driven Robotic Hand
//
// Design: Parametric OpenSCAD model for a 3-finger (thumb,
//   index, middle) cable-driven hand with realistic dimensions.
//   Each finger has 3 cylindrical phalanx segments connected by
//   pin hinges.  A single cable runs through each finger and is
//   pulled by a small servo mounted on the palm base.  Elastic
//   bands return the fingers to the open position.
//
// Reference video: https://youtu.be/r62dPoS-24s
//
// Print Settings:
//   Material:    PLA or ABS
//   Layer height: 0.2 mm
//   Infill:      20 % (palm), 15 % (segments)
//   Supports:    None required
//   Nozzle:      0.4 mm
//
// Assembly Order:
//   1. Print palm_base × 1
//   2. Print proximal_segment × 3, middle_segment × 3,
//      distal_segment × 3
//   3. Insert 2 mm hinge pins at every joint
//   4. Thread 1.5 mm cable through each finger
//   5. Fix cable to servo horn on palm
//   6. Attach elastic return bands on dorsal side of each joint
// ============================================================

$fn = 40;
$fa = 6;
$fs = 0.8;

// ============================================================
// ── GLOBAL PARAMETRIC VARIABLES ─────────────────────────────
// ============================================================

// Finger segment lengths (mm)
prox_len  = 40;   // proximal phalanx length
mid_len   = 25;   // middle phalanx length
dist_len  = 20;   // distal phalanx length

// Segment cross-section (cylindrical)
seg_od    = 15;   // outer diameter of each phalanx cylinder (mm)
seg_wall  = 2.0;  // minimum wall thickness (mm)

// Hinge pin
pin_d     = 2.0;  // hinge pin diameter (mm)
pin_bore  = 2.2;  // bore in segment for pin (0.2 mm clearance)
pin_len   = seg_od + 4;  // pin spans across full segment width + 2 mm each side

// Hinge fork geometry
fork_wall     = 2.0;  // thickness of each fork arm
fork_gap      = 1.5;  // clearance gap between male tongue and female fork (each side)
tongue_w      = seg_od - 2 * (fork_wall + fork_gap);  // width of male tongue

// Cable / tendon
cable_d       = 1.5;  // cable outer diameter (mm) – routing channel bore
cable_entry_d = 2.0;  // flared entry bore at proximal end
cable_offset  = seg_od / 2 - seg_wall - cable_d / 2 - 0.3;
                       // distance from segment axis → cable centre
                       // (runs along the palmar/volar side)

// Elastic return channel (dorsal side)
elastic_d     = 1.8;  // elastic band hole diameter (mm)

// Palm dimensions
palm_w        = 80;   // palm width  (finger spread direction)
palm_d        = 60;   // palm depth  (wrist ↔ knuckle direction)
palm_h        = 20;   // palm thickness (Z-axis, print height)

// Servo motor (9 g class, e.g. SG90 / MG90S)
servo_l       = 23;   // body length
servo_w       = 12.5; // body width
servo_h       = 22;   // body height (including output shaft side)
servo_flange_l = 32;  // total width including mounting flanges
servo_flange_h = 2.5; // flange thickness
servo_screw_d = 2.2;  // M2 mounting screw bore
servo_mount_spacing = 27; // distance between the two mounting screw pairs

// Finger mount positions on palm (along palm_w)
//   Thumb: 15 mm from left edge
//   Index: 40 mm from left edge
//   Middle: 65 mm from left edge
finger_x = [15, 40, 65];  // X positions of finger axes on palm top face
finger_y = palm_d;        // fingers extend from the distal edge of palm

// Wrist / forearm attachment
wrist_hole_d  = 4.2;  // M4 bolt for wrist attachment
wrist_hole_pos = [
    [12, 10],   // [x, y] on bottom face
    [palm_w - 12, 10],
    [12, palm_d - 10],
    [palm_w - 12, palm_d - 10]
];

// Cable routing channel in palm (from servo to each finger socket)
palm_cable_d  = cable_d + 0.5;  // palm internal cable bore

// Knuckle boss (connects finger to palm)
knuckle_boss_od  = seg_od + 4;    // boss outer diameter
knuckle_boss_h   = 6;             // boss height above palm
knuckle_pin_d    = pin_d;
knuckle_pin_bore = pin_bore;
// Small Z-offset so knuckle pin bore enters boss interior properly
knuckle_pin_z_offset = 1;  // mm inset from boss base before boring

// Segment spacing inside a finger: fork protrusion = seg_od/2; extra 5 % clearance
fork_clearance_factor = 1.05;

// ============================================================
// ── UTILITY MODULE ───────────────────────────────────────────
// ============================================================

// Rounded box helper (uses hull of 8 spheres)
module rounded_box(x, y, z, r = 2) {
    hull()
        for (tx = [r, x - r])
            for (ty = [r, y - r])
                for (tz = [r, z - r])
                    translate([tx, ty, tz])
                        sphere(r = r);
}

// ============================================================
// ── MODULE: HINGE FORK (female, two arms) ───────────────────
// ── Placed at the DISTAL end of each phalanx that receives   
// ── the tongue of the next phalanx.                         
// ============================================================
module hinge_fork() {
    arm_h  = seg_od / 2 + 2;  // arm height (along segment axis)
    arm_od = fork_wall * 2 + pin_bore; // arm outer diameter around pin bore

    // Two fork arms, symmetric about the XZ-plane
    for (sign = [-1, 1])
        translate([0, sign * (tongue_w / 2 + fork_gap + fork_wall / 2), 0])
            difference() {
                // Arm block
                hull() {
                    cylinder(d = seg_od, h = 0.5, center = true);
                    translate([arm_h, 0, 0])
                        cylinder(d = arm_od, h = fork_wall, center = true);
                }
                // Pin bore through arm
                translate([arm_h, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(d = pin_bore, h = fork_wall + 0.2, center = true);
            }
}

// ============================================================
// ── MODULE: HINGE TONGUE (male, single blade) ──────────────
// ── Placed at the PROXIMAL end of each phalanx that plugs   
// ── into the fork of the previous phalanx.                  
// ============================================================
module hinge_tongue() {
    tongue_h = seg_od / 2 + 2;  // tongue protrusion (along segment axis)
    translate([0, 0, 0])
        difference() {
            // Tongue blade
            hull() {
                cylinder(d = seg_od, h = 0.5, center = true);
                translate([-tongue_h, 0, 0])
                    cube([tongue_h * 2, tongue_w, seg_od / 2], center = true);
            }
            // Pin bore through tongue
            translate([-tongue_h, 0, 0])
                rotate([0, 90, 0])
                    cylinder(d = pin_bore, h = tongue_w + 0.2, center = true);
        }
}

// ============================================================
// ── MODULE: FINGER SEGMENT BODY ─────────────────────────────
// Creates a cylindrical phalanx of a given length.
// Cable channel runs along the palmar (volar) side (−Z offset).
// Elastic channel runs along the dorsal side (+Z offset).
//   length     – segment body length (mm)
//   prox_type  – "palm" | "tongue" | "none"  (proximal end)
//   dist_type  – "fork"  | "none"             (distal end)
// ============================================================
module finger_segment(length, prox_type = "tongue", dist_type = "fork") {
    // Body
    difference() {
        // Main cylinder
        rotate([0, 90, 0])
            cylinder(d = seg_od, h = length, center = true);

        // Hollow interior (weight reduction, keeps seg_wall walls)
        rotate([0, 90, 0])
            cylinder(d = seg_od - 2 * seg_wall, h = length - 2 * seg_wall, center = true);

        // Cable channel (palmar / −Z side)
        translate([0, 0, -cable_offset])
            rotate([0, 90, 0])
                cylinder(d = cable_d, h = length + 0.2, center = true);

        // Flared cable entry at proximal end (−X end)
        if (prox_type != "palm")
            translate([-(length / 2 + 0.1), 0, -cable_offset])
                rotate([0, 90, 0])
                    cylinder(d1 = cable_entry_d, d2 = cable_d, h = 3);

        // Elastic channel (dorsal / +Z side)
        translate([0, 0, cable_offset])
            rotate([0, 90, 0])
                cylinder(d = elastic_d, h = length + 0.2, center = true);
    }

    // Proximal end feature
    if (prox_type == "tongue")
        translate([-length / 2, 0, 0])
            rotate([0, 180, 0])
                hinge_tongue();

    // Distal end feature
    if (dist_type == "fork")
        translate([length / 2, 0, 0])
            hinge_fork();
}

// ============================================================
// ── MODULE: PROXIMAL SEGMENT (with palm socket boss) ────────
// The proximal phalanx attaches to the palm knuckle boss.
// Its proximal end is a flat circular face (no tongue) with
// a bore that receives the knuckle pin.
// ============================================================
module proximal_segment() {
    difference() {
        finger_segment(prox_len, prox_type = "palm", dist_type = "fork");

        // Knuckle pin bore at proximal end
        translate([-(prox_len / 2), 0, 0])
            rotate([0, 90, 0])
                cylinder(d = pin_bore, h = seg_od + 0.2, center = true);
    }
}

// ============================================================
// ── MODULE: MIDDLE SEGMENT ───────────────────────────────────
// Standard tongue-and-fork segment.
// ============================================================
module middle_segment() {
    finger_segment(mid_len, prox_type = "tongue", dist_type = "fork");
}

// ============================================================
// ── MODULE: DISTAL SEGMENT (rounded fingertip, no fork) ─────
// ============================================================
module distal_segment() {
    difference() {
        union() {
            // Body (tongue at proximal, rounded tip at distal)
            finger_segment(dist_len, prox_type = "tongue", dist_type = "none");

            // Rounded fingertip cap
            translate([dist_len / 2, 0, 0])
                sphere(d = seg_od);
        }
        // Cable termination recess at fingertip (cable anchors here)
        translate([dist_len / 2 + seg_od / 4, 0, -cable_offset])
            sphere(d = cable_d * 2.5);

        // Re-cut cable channel exit through tip
        translate([dist_len / 2, 0, -cable_offset])
            rotate([0, 90, 0])
                cylinder(d = cable_d, h = seg_od / 2 + 0.2);
    }
}

// ============================================================
// ── MODULE: HINGE PIN ────────────────────────────────────────
// Simple cylinder for the 2 mm steel / brass pin.
// ============================================================
module hinge_pin() {
    color("Silver")
        cylinder(d = pin_d, h = pin_len, center = true);
}

// ============================================================
// ── MODULE: SINGLE FINGER ASSEMBLY ──────────────────────────
// Assembles proximal + middle + distal segments with hinge
// pins shown (flat / open position).
//
// origin: centre of proximal end face of proximal segment
// ============================================================
module single_finger(show_pins = true, show_tendon = true) {
    // Segment positions along X-axis
    x_prox = 0;
    x_mid  = prox_len + seg_od / 2 * fork_clearance_factor;  // gap for fork clearance
    x_dist = x_mid + mid_len + seg_od / 2 * fork_clearance_factor;

    // Proximal
    color("CornflowerBlue")
        translate([prox_len / 2, 0, 0])
            proximal_segment();

    // Middle
    color("SteelBlue")
        translate([x_mid + mid_len / 2, 0, 0])
            middle_segment();

    // Distal
    color("DodgerBlue")
        translate([x_dist + dist_len / 2, 0, 0])
            distal_segment();

    // Hinge pins (visible in assembly view)
    if (show_pins) {
        // Prox→Mid joint
        translate([x_mid, 0, 0])
            rotate([90, 0, 0])
                hinge_pin();

        // Mid→Dist joint
        translate([x_dist, 0, 0])
            rotate([90, 0, 0])
                hinge_pin();
    }

    // Tendon path (thin red line along the palmar side)
    if (show_tendon) {
        total_len = x_dist + dist_len + seg_od / 2;
        color("Red", 0.6)
            translate([total_len / 2, 0, -cable_offset])
                rotate([0, 90, 0])
                    cylinder(d = cable_d * 0.6, h = total_len, center = true);
    }
}

// ============================================================
// ── MODULE: SERVO MOTOR BLOCK (9g SG90 class) ───────────────
// Visual placeholder + mounting bosses.
// origin: bottom face of servo, centred on body.
// ============================================================
module servo_motor_block() {
    color("DimGray") {
        // Servo body
        cube([servo_l, servo_w, servo_h], center = true);

        // Output shaft stub
        translate([0, 0, servo_h / 2 + 2])
            cylinder(d = 4.7, h = 4, center = true);

        // Servo horn (cross shape, simplified disc)
        translate([0, 0, servo_h / 2 + 6])
            cylinder(d = 18, h = 2, center = true);
    }

    // Mounting flanges
    color("DarkGray")
        for (sx = [-servo_mount_spacing / 2, servo_mount_spacing / 2])
            translate([sx, 0, -servo_h / 2 + servo_flange_h / 2])
                difference() {
                    cube([4, servo_w, servo_flange_h], center = true);
                    cylinder(d = servo_screw_d, h = servo_flange_h + 0.2,
                             center = true);
                }
}

// ============================================================
// ── MODULE: PALM BASE ────────────────────────────────────────
// Rectangular palm with:
//   - 3 knuckle bosses on the distal face
//   - 3 servo motor recesses (one per finger)
//   - Internal cable routing channels
//   - 4 wrist bolt holes
//   - Rounded edges for comfort and print quality
// ============================================================
module palm_base(show_servos = true) {
    difference() {
        // Palm solid body
        rounded_box(palm_w, palm_d, palm_h, r = 3);

        // ── Knuckle pin bores: pin runs across Y at each finger pos ──
        for (i = [0 : 2]) {
            translate([finger_x[i],
                       finger_y - knuckle_boss_h + knuckle_pin_z_offset,
                       palm_h])
                // bore through knuckle boss and slightly into palm
                cylinder(d = knuckle_pin_bore,
                         h = knuckle_boss_h + palm_h / 2, center = false);
        }

        // ── Servo pockets (open on the bottom face) ──
        // Three small servos seated under the palm, one per finger.
        // Pocket size: servo body + 0.5 mm clearance.
        for (i = [0 : 2]) {
            srv_cx = finger_x[i];
            srv_cy = palm_d * 0.45;
            translate([srv_cx - servo_l / 2 - 0.25,
                       srv_cy - servo_w / 2 - 0.25,
                       -0.1])
                cube([servo_l + 0.5, servo_w + 0.5, servo_h - 3]);

            // Flange slots (let flanges sit flush)
            for (sx = [-servo_mount_spacing / 2, servo_mount_spacing / 2])
                translate([srv_cx + sx - 2.5,
                           srv_cy - servo_w / 2 - 0.25,
                           servo_h - 3 - 0.1])
                    cube([5, servo_w + 0.5, servo_flange_h + 0.3]);

            // M2 servo screw holes through bottom of pocket
            for (sx = [-servo_mount_spacing / 2, servo_mount_spacing / 2])
                translate([srv_cx + sx, srv_cy, -0.1])
                    cylinder(d = servo_screw_d, h = 5);

            // Cable exit slot: from servo horn → top face
            translate([srv_cx - palm_cable_d / 2,
                       srv_cy - palm_cable_d / 2,
                       servo_h - 3])
                cube([palm_cable_d, palm_cable_d, palm_h - servo_h + 4]);
        }

        // ── Internal cable routing channels (servo → finger socket) ──
        for (i = [0 : 2]) {
            // Vertical riser from servo horn level to top face
            translate([finger_x[i], palm_d * 0.45, palm_h * 0.5])
                cylinder(d = palm_cable_d, h = palm_h * 0.6);
            // Diagonal run from riser to knuckle boss cable entry
            hull() {
                translate([finger_x[i], palm_d * 0.45, palm_h - 1])
                    sphere(d = palm_cable_d);
                translate([finger_x[i],
                           palm_d - knuckle_boss_h - 1,
                           palm_h - 2])
                    sphere(d = palm_cable_d);
            }
        }

        // ── Wrist bolt holes (4 × M4) ──
        for (pos = wrist_hole_pos)
            translate([pos[0], pos[1], -0.1])
                cylinder(d = wrist_hole_d, h = palm_h + 0.2);

        // ── Wire/cable passage between servo compartments ──
        translate([finger_x[0], palm_d * 0.45, 3])
            rotate([0, 90, 0])
                cylinder(d = 4, h = finger_x[2] - finger_x[0]);
    }

    // ── Knuckle bosses on distal face (top of palm) ──
    for (i = [0 : 2])
        translate([finger_x[i], palm_d, palm_h])
            difference() {
                // Boss body
                hull() {
                    cylinder(d = knuckle_boss_od, h = 0.5);
                    translate([0, 0, knuckle_boss_h])
                        cylinder(d = seg_od + 1, h = 0.5);
                }
                // Through-bore for hinge pin (Y-direction, using rotate)
                rotate([90, 0, 0])
                    cylinder(d = knuckle_pin_bore,
                             h = knuckle_boss_od + 0.2,
                             center = true);
                // Cable entry into boss from palm routing channel
                translate([0, -knuckle_boss_h / 2, knuckle_boss_h * 0.6])
                    cylinder(d = palm_cable_d, h = knuckle_boss_h + 0.2,
                             center = true);
            }
}

// ============================================================
// ── MODULE: COMPLETE 3-FINGER HAND ASSEMBLY ─────────────────
// Renders palm + 3 fingers in the open (straight) position.
//   show_pins    – show hinge pin cylinders
//   show_tendons – draw tendon cable lines
//   show_servos  – draw servo motor blocks inside palm
// ============================================================
module robotic_hand_3finger(
    show_pins    = true,
    show_tendons = true,
    show_servos  = true
) {
    // Palm
    color("RoyalBlue", 0.9)
        palm_base(show_servos);

    // Servo motors (in-palm, palmar side facing down)
    if (show_servos)
        for (i = [0 : 2]) {
            srv_cx = finger_x[i];
            srv_cy = palm_d * 0.45;
            srv_cz = (servo_h - 3) / 2;
            translate([srv_cx, srv_cy, srv_cz + 0.5])
                servo_motor_block();
        }

    // Three fingers: thumb (i=0), index (i=1), middle (i=2)
    for (i = [0 : 2]) {
        // Finger base: knuckle pin is at palm_d, palm_h + knuckle_boss_h
        translate([finger_x[i],
                   palm_d + knuckle_boss_h,
                   palm_h + knuckle_boss_h / 2])
            rotate([90, 0, 0])  // finger axis = −Y in world space
                rotate([0, -90, 0])  // align segment axis with Y
                    single_finger(
                            show_pins    = show_pins,
                            show_tendon  = show_tendons
                        );
    }
}

// ============================================================
// ── DEFAULT RENDER ───────────────────────────────────────────
// Toggle these flags to control what is shown.
// ============================================================
SHOW_PINS    = true;
SHOW_TENDONS = true;
SHOW_SERVOS  = true;

robotic_hand_3finger(
    show_pins    = SHOW_PINS,
    show_tendons = SHOW_TENDONS,
    show_servos  = SHOW_SERVOS
);

// ============================================================
// ── ASSEMBLY INFORMATION (printed to console) ─────────────────
// ============================================================
echo("=== 3-Finger Cable-Driven Robotic Hand ===");
echo(str("Palm base:       ", palm_w, " × ", palm_d, " × ", palm_h, " mm"));
echo(str("Segment diameters:  ", seg_od, " mm"));
echo(str("Proximal length: ", prox_len, " mm"));
echo(str("Middle length:   ", mid_len,  " mm"));
echo(str("Distal length:   ", dist_len, " mm"));
echo(str("Total finger reach: ", prox_len + mid_len + dist_len,
         " mm (fully extended)"));
echo(str("Cable diameter:  ", cable_d, " mm"));
echo(str("Hinge pin:       ", pin_d,   " mm diameter × ",
         pin_len, " mm long"));
echo("Servo:           SG90 / MG90S class  (9–15 g)");
echo("Actuation:       Cable-driven (1 servo per finger)");
echo("Return:          Elastic bands on dorsal side");
echo("Material:        PLA or ABS");
echo("===========================================");
