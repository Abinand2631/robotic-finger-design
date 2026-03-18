// ============================================================
// hand_assembly_complete.scad
// Complete Hand Assembly – 3 Fingers + Palm + Servo + Tendons
// Demonstrates assembled configuration and tendon routing
//
// Color coding:
//   Palm body     = RoyalBlue
//   Finger segs   = CornflowerBlue → DarkSlateBlue (prox→tip)
//   Hinge pins    = Silver
//   Tendon lines  = Red (fishing line simulation)
//   Elastic bands = Green (return bands)
//   Servo         = DarkGray
//   Pulley        = LightGray
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// ============================================================
// Include component modules
// ============================================================
use <../fingers/palm_structure.scad>
use <../fingers/finger_segment_proximal.scad>
use <../fingers/finger_segment_middle.scad>
use <../fingers/finger_segment_distal.scad>
use <../fingers/finger_segment_fingertip.scad>
use <../fingers/tendon_pulley.scad>
use <elastic_band_anchor.scad>

// ============================================================
// Assembly Parameters
// ============================================================
palm_length   = 60;   // mm  palm body length
palm_width    = 50;   // mm  palm body width
palm_thick    = 15;   // mm  palm thickness
seg_len       = 20;   // mm  standard finger segment length
tip_len       = 18;   // mm  fingertip length
seg_thick     = 7;    // mm  segment thickness
seg_width     = 10;   // mm  segment width
hinge_gap     = 0.5;  // mm  gap between segments
hinge_pin_d   = 2;    // mm

// Finger X-positions along palm width
finger_cx = [palm_width * 0.2,
             palm_width * 0.5,
             palm_width * 0.8];

// ============================================================
// Module: single_finger_chain
// One complete 4-segment finger in a straight (open) position
// ============================================================
module single_finger_chain() {
    x0 = 0;
    x1 = x0 + seg_len + hinge_gap;
    x2 = x1 + seg_len + hinge_gap;
    x3 = x2 + seg_len + hinge_gap;

    color("CornflowerBlue")  finger_segment_proximal();
    color("CadetBlue")   translate([x1, 0, 0]) finger_segment_middle();
    color("Teal")        translate([x2, 0, 0]) finger_segment_distal();
    color("DarkSlateBlue") translate([x3, 0, 0]) finger_segment_fingertip();

    // Hinge pins
    for (x = [x1, x2, x3])
        color("Silver")
            translate([x, seg_width / 2, seg_thick / 2])
                rotate([90, 0, 0])
                    cylinder(d = hinge_pin_d, h = seg_width + 4, center = true);
}

// ============================================================
// Module: tendon_line
// Simplified tendon line from pulley to fingertip
// ============================================================
module tendon_line(start, end_pt) {
    color("Red", 0.7)
        hull() {
            translate(start)  sphere(d = 0.8);
            translate(end_pt) sphere(d = 0.8);
        }
}

// ============================================================
// Module: elastic_band_line
// Simplified elastic band
// ============================================================
module elastic_band_line(start, end_pt) {
    color("LimeGreen", 0.7)
        hull() {
            translate(start)  sphere(d = 1.0);
            translate(end_pt) sphere(d = 1.0);
        }
}

// ============================================================
// Render Assembly
// ============================================================

// Palm body
color("RoyalBlue")
    palm_structure();

// Servo representation (simple block)
servo_x = (palm_length - 24) / 2;
servo_y = (palm_width  - 13) / 2;
color("DarkGray")
    translate([servo_x, servo_y, 2])
        cube([23, 12, 22]);

// Tendon pulley on servo horn
color("LightGray")
    translate([palm_length / 2, palm_width / 2, palm_thick + 1])
        tendon_pulley();

// Three fingers, one per socket
for (i = [0:2]) {
    cx = finger_cx[i];
    translate([palm_length + 1, cx - seg_width / 2, (palm_thick - seg_thick) / 2])
        single_finger_chain();
}

// Tendon routing lines (palm centre → each fingertip)
pulley_pos = [palm_length / 2, palm_width / 2, palm_thick + 4];
for (i = [0:2]) {
    tip_x = palm_length + 1 + seg_len * 3 + tip_len;
    tip_y = finger_cx[i];
    tip_z = (palm_thick - seg_thick) / 2 + seg_thick - 2;
    tendon_line(pulley_pos, [tip_x, tip_y, tip_z]);
}

// Elastic band anchors (bottom face)
for (i = [0:2]) {
    anchor_y = finger_cx[i] - 5;
    color("Tomato")
        translate([palm_length * 0.75, anchor_y, -6])
            elastic_band_anchor();
}

// Elastic return lines (anchor → proximal segment bottom)
for (i = [0:2]) {
    anchor_pos = [palm_length * 0.75 + 5, finger_cx[i], -2];
    prox_pos   = [palm_length + 5, finger_cx[i], (palm_thick - seg_thick) / 2];
    elastic_band_line(anchor_pos, prox_pos);
}

// ============================================================
// Assembly information
// ============================================================
echo("Hand Assembly Complete");
echo(str("Palm: ", palm_length, " x ", palm_width, " x ", palm_thick, " mm"));
echo(str("Fingers: 3 × (", seg_len, "+", seg_len, "+", seg_len, "+", tip_len,
         ") mm = ", seg_len * 3 + tip_len, " mm each"));
echo("Servo: MG90S (single servo controls all 3 fingers)");
echo("Tendons: 0.25 mm monofilament fishing line");
echo("Elastic: 1 mm flat elastic band per finger");
