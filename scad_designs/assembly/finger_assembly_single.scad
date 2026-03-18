// ============================================================
// finger_assembly_single.scad
// Single Complete Finger Assembly
// Shows all 4 segments + hinge pins in assembly order
// Color-coded: proximal=blue, middle=cyan, distal=teal,
//              fingertip=navy, pins=silver
//
// Open this file in OpenSCAD to verify segment alignment
// and hinge-pin clearances before printing.
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// ============================================================
// Include segment modules
// ============================================================
use <../fingers/finger_segment_proximal.scad>
use <../fingers/finger_segment_middle.scad>
use <../fingers/finger_segment_distal.scad>
use <../fingers/finger_segment_fingertip.scad>

// ============================================================
// Assembly Parameters
// ============================================================
seg_length     = 20;   // mm  standard segment length
seg_thickness  = 7;    // mm  segment thickness
seg_width      = 10;   // mm  segment width
tip_length     = 18;   // mm  fingertip length
hinge_gap      = 0.5;  // mm  inter-segment gap (print clearance)
hinge_pin_d    = 2;    // mm  hinge pin diameter
hinge_pin_len  = seg_width + 4; // mm  pin protrudes slightly

// Cumulative X positions for each segment
x0 = 0;
x1 = x0 + seg_length + hinge_gap;
x2 = x1 + seg_length + hinge_gap;
x3 = x2 + seg_length + hinge_gap;

// ============================================================
// Module: hinge_pin
// Steel wire pin (shown in silver) through both bosses
// ============================================================
module hinge_pin() {
    color("Silver")
        translate([0, -1, seg_thickness / 2])
            rotate([0, 90, 0])
                cylinder(d = hinge_pin_d, h = hinge_pin_len, center = true);
}

// ============================================================
// Render Assembly
// ============================================================

// 1. Proximal segment (palm end)
color("CornflowerBlue")
    translate([x0, 0, 0])
        finger_segment_proximal();

// Hinge pin between proximal and middle
translate([x1, 0, 0])
    hinge_pin();

// 2. Middle segment
color("CadetBlue")
    translate([x1, 0, 0])
        finger_segment_middle();

// Hinge pin between middle and distal
translate([x2, 0, 0])
    hinge_pin();

// 3. Distal segment
color("Teal")
    translate([x2, 0, 0])
        finger_segment_distal();

// Hinge pin between distal and fingertip
translate([x3, 0, 0])
    hinge_pin();

// 4. Fingertip
color("DarkSlateBlue")
    translate([x3, 0, 0])
        finger_segment_fingertip();

// ============================================================
// Dimension annotations (echo to console)
// ============================================================
total_length = x3 + tip_length;
echo(str("Total finger length: ", total_length, " mm"));
echo(str("Segments: proximal(", seg_length, ") + ",
         "middle(", seg_length, ") + ",
         "distal(", seg_length, ") + ",
         "fingertip(", tip_length, ")"));
echo(str("Hinge pin diameter: ", hinge_pin_d, " mm"));
