// ============================================================
// robotic_hand_3finger.scad
// 3-Finger Cable-Driven Robotic Hand – Bellows-Style Joints
//
// Design: Parametric OpenSCAD model for a 3-finger (thumb,
//   index, middle) cable-driven hand with bellows/accordion-
//   style flexible joints.  A star/sunburst-pattern web
//   connects each pair of cylindrical finger segments.
//   Two cables per finger control flexion; elastic bands
//   return fingers to the open position.
//
// Reference video: https://youtu.be/r62dPoS-24s
// Robot:           127 cm humanoid  (arm Ø ≈ 63 mm)
//
// Print Settings:
//   Material:    PLA (segments + palm) | TPU optional for bellows
//   Layer height: 0.2 mm
//   Infill:      20 % (palm), 15 % (segments), 25 % (bellows)
//   Supports:    None required
//   Nozzle:      0.4 mm
//
// Bill of Materials (per finger):
//   4 × finger segment (PLA)
//   3 × bellows joint  (PLA or TPU)
//   2 × 2 mm Dyneema/steel cable
//   1 × elastic return band
//
// Assembly Order:
//   1. Print palm_base × 1
//   2. Print finger_segment × 12  (4 per finger × 3 fingers)
//   3. Print bellows_joint  × 9   (3 per finger × 3 fingers)
//   4. Bond or clip bellows joints between segments
//   5. Thread 2 × 2 mm cable through each finger channel
//   6. Seat finger bases into palm knuckle sockets
//   7. Connect cables to servo horns on palm
//   8. Fit elastic return bands on dorsal side
// ============================================================

$fn = 60;
$fa = 4;
$fs = 0.5;

// ============================================================
// ── GLOBAL PARAMETRIC VARIABLES ─────────────────────────────
// ============================================================

// ── Finger segment ──────────────────────────────────────────
seg_d    = 18;    // outer diameter of cylindrical segments (mm)
seg_len  = 25;    // length of each segment (mm)
seg_wall = 2.5;   // wall thickness (mm)
num_segs = 4;     // segments per finger  (set to 5 for longer fingers)

// ── Bellows joint ────────────────────────────────────────────
joint_len = 8;    // total length of the bellows joint section (mm)
ring_w    = 2.0;  // width of solid end-collars that mate with segments (mm)
spoke_t   = 1.0;  // spoke / web thickness – thin = more flexible (mm)
n_spokes  = 6;    // number of spokes in the star/sunburst pattern
hub_d     = 7.0;  // central hub diameter (mm)

// ── Cable actuation  (2 cables per finger) ──────────────────
cable_d    = 2.0;   // cable outer diameter (mm)
cable_clr  = 0.3;   // routing bore clearance (mm)
cable_bore = cable_d + cable_clr;  // = 2.3 mm bore

// Both cables sit on the palmar (flexion) face, inside the
// hollow bore of the segment.  cable_y is their shared Y-offset
// from the segment axis (negative = palmar / −Y direction).
cable_y   = -(seg_d / 2 - seg_wall - cable_bore / 2 - 0.2);
cable_sep = 5;    // lateral (X-axis) centre-to-centre separation (mm)

// ── Elastic return channel (dorsal face) ────────────────────
elastic_d = 1.8;  // elastic band groove bore (mm)
elastic_y =  seg_d / 2 - seg_wall - elastic_d / 2 - 0.2;
             // Y-offset (positive = dorsal / +Y direction)

// ── Palm  100 × 80 × 30 mm ──────────────────────────────────
palm_w = 100;   // width  (X) – across fingers
palm_d =  80;   // depth  (Y) – wrist to knuckle
palm_h =  30;   // height (Z) – thickness
palm_r =   5;   // corner rounding radius

// ── Finger attachment positions on palm (X positions) ───────
finger_x = [18, 50, 82];  // thumb, index, middle

// ── Knuckle boss ─────────────────────────────────────────────
knuckle_h  =  8;           // boss height above palm top face (mm)
knuckle_od = seg_d + 8;    // boss outer diameter (→ 26 mm)
socket_d   = seg_d + 0.4;  // socket bore (segment slides in, 0.4 mm clearance)
socket_dep =  4;            // socket depth (mm)

// ── Servo motor  (SG90 / MG90S  9 g – 15 g class) ──────────
servo_l    = 23;    // body length (mm)
servo_w    = 12.5;  // body width (mm)
servo_h    = 22;    // body height incl. output shaft (mm)
servo_shft =  4.7;  // output shaft diameter (mm)
servo_span = 27;    // mounting-screw hole span (mm)
servo_flg  =  2.5;  // mounting flange thickness (mm)
servo_m2   =  2.2;  // M2 screw bore (mm)

// ── Arm / wrist interface (127 cm humanoid, arm ≈ 63 mm) ────
arm_d      = 63;    // forearm tube outer diameter (mm)
wrist_m4   =  4.2;  // M4 bolt bore (mm)
wrist_pts  = [      // [x, y] bolt positions on palm bottom face
    [12,          12        ],
    [palm_w - 12, 12        ],
    [12,          palm_d - 12],
    [palm_w - 12, palm_d - 12]
];

// ── Palm internal cable routing ──────────────────────────────
palm_cbl_d = cable_d + 1.0;  // palm bore diameter

// ── Display / export flags ───────────────────────────────────
SHOW_SERVOS  = true;
SHOW_CABLES  = true;
SHOW_ELASTIC = true;


// ============================================================
// ── UTILITY: Rounded rectangular box ─────────────────────────
// origin: bottom-left-front corner; extends in +X, +Y, +Z
// ============================================================
module rounded_box(w, d, h, r = 5) {
    hull()
        for (tx = [r, w - r])
            for (ty = [r, d - r])
                translate([tx, ty, 0])
                    cylinder(r = r, h = h);
}

// ============================================================
// ── MODULE: BELLOWS_PROFILE (2-D star / sunburst) ────────────
// Cross-section extruded to form the flexible bellows body.
// Shape: central hub circle + n_spokes radiating to seg_d/2.
// ============================================================
module bellows_profile() {
    // Central hub
    circle(d = hub_d);
    // Radial spokes
    for (a = [0 : 360 / n_spokes : 359])
        rotate([0, 0, a])
            translate([hub_d / 2, -spoke_t / 2])
                square([seg_d / 2 - hub_d / 2, spoke_t]);
}

// ============================================================
// ── MODULE: BELLOWS_JOINT ────────────────────────────────────
// Flexible accordion-style connector between two segments.
// Two solid end-collars (ring_w each) sandwich the star-pattern
// flexible body.  Cable and elastic bores pass straight through.
//
// Origin: bottom face; extends along +Z for joint_len.
// ============================================================
module bellows_joint() {
    difference() {
        union() {
            // Bottom collar (mates flush with top face of lower segment)
            cylinder(d = seg_d, h = ring_w);

            // Star/spoke flexible body
            translate([0, 0, ring_w])
                linear_extrude(height = joint_len - 2 * ring_w)
                    bellows_profile();

            // Top collar (mates flush with bottom face of upper segment)
            translate([0, 0, joint_len - ring_w])
                cylinder(d = seg_d, h = ring_w);
        }

        // Cable bores × 2  (palmar side, aligned with segment bores)
        for (xoff = [-cable_sep / 2, cable_sep / 2])
            translate([xoff, cable_y, -0.1])
                cylinder(d = cable_bore, h = joint_len + 0.2);

        // Elastic return bore  (dorsal side)
        translate([0, elastic_y, -0.1])
            cylinder(d = elastic_d, h = joint_len + 0.2);
    }
}

// ============================================================
// ── MODULE: FINGER_SEGMENT ───────────────────────────────────
// Rigid cylindrical phalanx with 2 cable bores and 1 elastic
// bore.  The last segment (is_tip = true) has a rounded dome
// cap and cable-anchor pockets instead of exit holes.
//
// Origin: bottom face; extends along +Z for seg_len
//         (+ seg_d/2 dome height when is_tip = true).
// ============================================================
module finger_segment(is_tip = false) {
    // Extra height contributed by the hemisphere cap on the fingertip
    tip_dome_height = is_tip ? seg_d / 2 : 0;

    difference() {
        union() {
            // Outer cylinder
            cylinder(d = seg_d, h = seg_len);

            // Hemisphere dome cap (fingertip only – upper half of sphere)
            if (is_tip)
                translate([0, 0, seg_len])
                    intersection() {
                        sphere(d = seg_d);
                        cylinder(d = seg_d + 1,
                                 h = seg_d / 2 + 0.1);
                    }
        }

        // Hollow interior  (weight-saving; keeps seg_wall outer shell)
        translate([0, 0, seg_wall])
            cylinder(d = seg_d - 2 * seg_wall,
                     h = seg_len - seg_wall + tip_dome_height + 0.1);

        // ── Cable bores × 2  (palmar face, −Y side) ──────────
        for (xoff = [-cable_sep / 2, cable_sep / 2]) {
            if (!is_tip)
                // Through-bore: enters bottom face, exits top face
                translate([xoff, cable_y, -0.1])
                    cylinder(d = cable_bore, h = seg_len + 0.2);
            else {
                // For the fingertip: bore runs to anchor depth then widens
                translate([xoff, cable_y, -0.1])
                    cylinder(d = cable_bore,
                             h = seg_len + seg_d / 5 + 0.1);
                // Spherical cable-anchor pocket (cable knotted here)
                translate([xoff, cable_y, seg_len + seg_d / 5])
                    sphere(d = cable_d * 2.8);
            }
        }

        // ── Elastic return bore (dorsal face, +Y side) ────────
        translate([0, elastic_y, -0.1])
            cylinder(d = elastic_d, h = seg_len + 0.2);
    }
}

// ============================================================
// ── MODULE: SINGLE_FINGER ────────────────────────────────────
// Assembles num_segs rigid segments connected by (num_segs − 1)
// bellows joints.  Optionally renders cable and elastic guides.
//
// Origin: base of first segment; finger extends along +Z.
// ============================================================
module single_finger(show_cables = true, show_elastic = true) {
    for (i = [0 : num_segs - 1]) {
        base_z = i * (seg_len + joint_len);

        // Rigid segment  (colour gradient: base → tip)
        color(i == 0 ? "CornflowerBlue" :
              i == 1 ? "SteelBlue"      :
              i == 2 ? "CadetBlue"      : "DodgerBlue")
            translate([0, 0, base_z])
                finger_segment(is_tip = (i == num_segs - 1));

        // Bellows joint after each segment except the last
        if (i < num_segs - 1)
            color("LightSkyBlue", 0.9)
                translate([0, 0, base_z + seg_len])
                    bellows_joint();
    }

    // Visual cable lines (thin red cylinders)
    total_z = num_segs * seg_len + (num_segs - 1) * joint_len
              + seg_d / 2;  // includes tip dome

    if (show_cables)
        for (xoff = [-cable_sep / 2, cable_sep / 2])
            color("Red", 0.65)
                translate([xoff, cable_y, 0])
                    cylinder(d = cable_d * 0.55, h = total_z);

    // Visual elastic band line (thin green cylinder)
    if (show_elastic)
        color("LimeGreen", 0.65)
            translate([0, elastic_y, 0])
                cylinder(d = elastic_d * 0.55, h = total_z);
}

// ============================================================
// ── MODULE: SERVO_MOTOR_BLOCK ────────────────────────────────
// Visual placeholder for a 9 g – 15 g servo (SG90 / MG90S).
// Origin: centre of servo body, on the body bottom face.
// ============================================================
module servo_motor_block() {
    color("DimGray") {
        // Servo body
        cube([servo_l, servo_w, servo_h], center = true);
        // Output shaft stub
        translate([0, 0, servo_h / 2 + 2])
            cylinder(d = servo_shft, h = 4, center = true);
        // Servo horn disc
        translate([0, 0, servo_h / 2 + 6])
            cylinder(d = 16, h = 2, center = true);
    }
    // Mounting flanges with M2 screw holes
    color("DarkGray")
        for (sx = [-servo_span / 2, servo_span / 2])
            translate([sx, 0, -servo_h / 2 + servo_flg / 2])
                difference() {
                    cube([4, servo_w, servo_flg], center = true);
                    cylinder(d = servo_m2,
                             h = servo_flg + 0.2,
                             center = true);
                }
}

// ============================================================
// ── MODULE: PALM_BASE ────────────────────────────────────────
// 100 × 80 × 30 mm palm with:
//   • 3 knuckle bosses on the distal (front) face
//   • 3 servo motor recesses open from the bottom face
//   • Internal cable routing bores (servo horn → knuckle)
//   • 4 × M4 wrist bolt holes (bottom face)
//   • Arm-interface saddle cutout at the proximal (rear) face
//   • Wire duct connecting all servo bays
// ============================================================
module palm_base() {
    difference() {
        // Palm body
        rounded_box(palm_w, palm_d, palm_h, r = palm_r);

        // ── Servo pockets  (open from bottom face, 1 per finger) ──
        for (i = [0 : 2]) {
            let (cx = finger_x[i], cy = palm_d * 0.40) {
                // Servo body pocket (+0.3 mm clearance each side)
                translate([cx - servo_l / 2 - 0.3,
                           cy - servo_w / 2 - 0.3,
                           -0.1])
                    cube([servo_l + 0.6,
                          servo_w + 0.6,
                          servo_h - 3]);

                // Mounting flange slots
                for (sx = [-servo_span / 2, servo_span / 2])
                    translate([cx + sx - 2.5,
                               cy - servo_w / 2 - 0.3,
                               servo_h - 3 - 0.1])
                        cube([5, servo_w + 0.6, servo_flg + 0.4]);

                // M2 mounting screw holes
                for (sx = [-servo_span / 2, servo_span / 2])
                    translate([cx + sx, cy, -0.1])
                        cylinder(d = servo_m2, h = 5.5);
            }
        }

        // ── Cable routing channels: servo horn → knuckle ──────────
        for (i = [0 : 2]) {
            let (cx = finger_x[i], cy = palm_d * 0.40) {
                // Vertical riser from servo-horn level to top face
                translate([cx, cy, servo_h - 3])
                    cylinder(d = palm_cbl_d,
                             h = palm_h - (servo_h - 3) + 2);

                // Diagonal channel: riser top → base of knuckle boss
                hull() {
                    translate([cx, cy, palm_h - 4])
                        sphere(d = palm_cbl_d);
                    translate([cx, palm_d - knuckle_h - 2, palm_h - 2])
                        sphere(d = palm_cbl_d);
                }
            }
        }

        // ── Wrist bolt holes  (4 × M4, bottom face) ──────────────
        for (pt = wrist_pts)
            translate([pt[0], pt[1], -0.1])
                cylinder(d = wrist_m4, h = palm_h + 0.2);

        // ── Arm-interface saddle (proximal face, Y = 0) ───────────
        // Semi-cylindrical groove so the hand slides onto the arm
        translate([palm_w / 2, -0.1, palm_h / 2])
            rotate([-90, 0, 0])
                cylinder(d = arm_d, h = palm_r + 0.2);

        // ── Wire duct  (connects all three servo bays) ────────────
        translate([finger_x[0], palm_d * 0.40, 5])
            rotate([0, 90, 0])
                cylinder(d = 5,
                         h = finger_x[2] - finger_x[0]);
    }

    // ── Knuckle bosses on the distal (front, Y = palm_d) face ────
    for (i = [0 : 2])
        translate([finger_x[i], palm_d, palm_h])
            difference() {
                // Tapered boss body (wider at base → narrower at top)
                hull() {
                    cylinder(d = knuckle_od, h = 0.5);
                    translate([0, 0, knuckle_h])
                        cylinder(d = seg_d + 2, h = 0.5);
                }
                // Socket bore: finger base slides in socket_dep mm
                translate([0, 0, knuckle_h - socket_dep])
                    cylinder(d = socket_d, h = socket_dep + 0.1);
                // Cable entry bore (aligns with internal routing channel)
                translate([0, 0, -0.1])
                    cylinder(d = palm_cbl_d * 1.2, h = knuckle_h + 0.2);
            }
}

// ============================================================
// ── MODULE: ROBOTIC_HAND_3FINGER ─────────────────────────────
// Top-level assembly: palm + 3 fingers (open / extended pose).
// Thumb = finger 0, Index = finger 1, Middle = finger 2.
// ============================================================
module robotic_hand_3finger(
    show_servos  = SHOW_SERVOS,
    show_cables  = SHOW_CABLES,
    show_elastic = SHOW_ELASTIC
) {
    // Palm
    color("RoyalBlue", 0.9)
        palm_base();

    // Servo motors (seated inside palm, one per finger)
    if (show_servos)
        for (i = [0 : 2]) {
            let (cx = finger_x[i], cy = palm_d * 0.40)
                // Servo body centre at mid-height of pocket
                translate([cx, cy, (servo_h - 3) / 2 + 0.3])
                    servo_motor_block();
        }

    // Three fingers – each attached to its knuckle boss and
    // extending away from the palm in the +Y direction.
    for (i = [0 : 2])
        // Finger base is in the knuckle socket; origin placed at
        // the bottom of the first segment (top of the socket).
        translate([finger_x[i],
                   palm_d + knuckle_h + 0.5,
                   palm_h + knuckle_h / 2])
            rotate([-90, 0, 0])   // +Z finger axis → +Y world axis
                single_finger(
                    show_cables  = show_cables,
                    show_elastic = show_elastic
                );
}

// ============================================================
// ── DEFAULT RENDER ───────────────────────────────────────────
// Toggle the flags near the top of the file to control what
// is included in the view / STL export.
// ============================================================
robotic_hand_3finger();

// ============================================================
// ── ASSEMBLY INFORMATION (printed to OpenSCAD console) ───────
// ============================================================
total_finger_len = num_segs * seg_len
                  + (num_segs - 1) * joint_len
                  + seg_d / 2;   // includes tip dome

echo("========================================================");
echo("  3-Finger Bellows-Joint Cable-Driven Robotic Hand");
echo("  Reference: https://youtu.be/r62dPoS-24s");
echo("  Robot:     127 cm humanoid  (arm Ø ≈ 63 mm)");
echo("========================================================");
echo(str("  Palm:                ", palm_w, " × ", palm_d,
                                   " × ", palm_h, " mm"));
echo(str("  Segment Ø:           ", seg_d, " mm"));
echo(str("  Segment length:      ", seg_len, " mm"));
echo(str("  Segments per finger: ", num_segs));
echo(str("  Bellows joints:      ", num_segs - 1,
         "  (", n_spokes, "-spoke star pattern)"));
echo(str("  Total finger length: ~", total_finger_len, " mm"));
echo(str("  Cables per finger:   2 × Ø", cable_d, " mm"));
echo(str("  Elastic channel:     Ø", elastic_d, " mm"));
echo(str("  Arm interface:       Ø", arm_d, " mm"));
echo("  Servo:               SG90 / MG90S  (9–15 g)");
echo("  Material:            PLA (rigid) | TPU (bellows, opt.)");
echo("========================================================");
