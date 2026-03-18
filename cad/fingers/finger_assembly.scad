// ============================================================
// Full Finger Assembly — Tendon-Driven Robotic Hand
// ============================================================
// Visualises proximal + middle + distal segments in assembly
// position for verification.  Not for printing (use individual
// segment files).
// ============================================================

use <finger_segment_proximal.scad>
use <finger_segment_middle.scad>
use <finger_segment_distal.scad>

// Segment lengths (must match individual files)
prox_len = 20;
mid_len  = 18;
dist_len = 15;
lug_w    =  2.5;
gap      =  0.2;   // assembly clearance between segments

// Place segments end-to-end along Y axis
// Proximal at origin
color("SteelBlue")
    finger_segment_proximal();

// Middle segment (shifted along Y by prox_len + gap)
color("CornflowerBlue")
    translate([0, prox_len + gap, 0])
        finger_segment_middle();

// Distal segment
color("LightSteelBlue")
    translate([0, prox_len + mid_len + 2*gap, 0])
        finger_segment_distal();
