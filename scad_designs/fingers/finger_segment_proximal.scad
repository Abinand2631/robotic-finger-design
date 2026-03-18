// ============================================================
// finger_segment_proximal.scad
// Proximal (first) Finger Segment – closest to palm
// Humanoid Welcoming Robot – tendon-driven hand
//
// Print Settings:
//   Material:    PLA
//   Infill:      15%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~4 g
//   Print time:  ~3 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
length                = 20;   // mm  segment length (tip-to-tip)
width                 = 10;   // mm  segment width
thickness             = 7;    // mm  segment height/thickness
hinge_pin_diameter    = 2;    // mm  hinge pin outer diameter
hinge_pin_bore        = 2.1;  // mm  hinge hole diameter (0.1 mm tolerance)
tendon_hole_diameter  = 1.35; // mm  fishing-line tendon hole (top face)
elastic_hole_diameter = 1.75; // mm  elastic band return holes (bottom face)
elastic_hole_spacing  = 7;    // mm  distance between two bottom holes
outer_radius          = 5;    // mm  dorsal (top) curvature radius
wall_min              = 1.5;  // mm  minimum wall thickness
channel_radius        = 0.5;  // mm  internal channel fillet for low friction

// Derived
hinge_boss_od    = hinge_pin_bore + wall_min * 2;  // boss outer diameter
hinge_boss_depth = 3.0;                            // boss protrusion from end

// ============================================================
// Module: segment_body
// Main finger link with rounded dorsal surface
// ============================================================
module segment_body() {
    hull() {
        // Flat bottom rail
        translate([0, 0, 0])
            cube([length, width, thickness / 4]);
        // Rounded dorsal top
        translate([outer_radius, width / 2, thickness - outer_radius + 1])
            rotate([90, 0, 0])
                cylinder(r = outer_radius, h = width, center = true);
        translate([length - outer_radius, width / 2, thickness - outer_radius + 1])
            rotate([90, 0, 0])
                cylinder(r = outer_radius, h = width, center = true);
    }
}

// ============================================================
// Module: hinge_bosses
// Cylindrical boss on each end for hinge pin
// ============================================================
module hinge_bosses() {
    // Proximal (palm) end – solid boss (male pin goes through palm socket)
    for (y_pos = [width * 0.25, width * 0.75])
        translate([-hinge_boss_depth, y_pos, thickness / 2])
            rotate([0, 90, 0])
                cylinder(d = hinge_boss_od, h = hinge_boss_depth);
    // Distal end – boss with through-hole (female, receives pin from middle seg)
    for (y_pos = [width * 0.25, width * 0.75])
        translate([length, y_pos, thickness / 2])
            rotate([0, 90, 0])
                cylinder(d = hinge_boss_od, h = hinge_boss_depth);
}

// ============================================================
// Module: hinge_bore
// Drills hinge pin holes through bosses
// ============================================================
module hinge_bore_cuts() {
    // Both ends
    for (x_pos = [-hinge_boss_depth - 0.1, length - 0.1])
        for (y_pos = [width * 0.25, width * 0.75])
            translate([x_pos, y_pos, thickness / 2])
                rotate([0, 90, 0])
                    cylinder(d = hinge_pin_bore, h = hinge_boss_depth + 0.2);
}

// ============================================================
// Module: tendon_channel
// Single tendon hole on top face with smooth inner channel
// ============================================================
module tendon_channel() {
    // Vertical bore from top face, exits bottom
    translate([length / 2, width / 2, -0.1])
        cylinder(d = tendon_hole_diameter, h = thickness + 0.2);
}

// ============================================================
// Module: elastic_channels
// Two symmetric elastic band holes on bottom face
// ============================================================
module elastic_channels() {
    for (dy = [-elastic_hole_spacing / 2, elastic_hole_spacing / 2])
        translate([length / 2, width / 2 + dy, -0.1])
            cylinder(d = elastic_hole_diameter, h = thickness + 0.2);
}

// ============================================================
// Module: finger_segment_proximal
// Full proximal segment
// ============================================================
module finger_segment_proximal() {
    difference() {
        union() {
            segment_body();
            hinge_bosses();
        }
        // Hinge pin bores
        hinge_bore_cuts();
        // Tendon hole (top/dorsal face, 2 mm from outer surface)
        translate([length / 2, width / 2, thickness - 2])
            cylinder(d = tendon_hole_diameter, h = 2.1);
        // Elastic holes (bottom face)
        elastic_channels();
        // Internal lightening (keeps 1.5 mm walls)
        translate([wall_min * 2, wall_min, wall_min])
            cube([length - wall_min * 4,
                  width  - wall_min * 2,
                  thickness - wall_min * 2.5]);
    }
}

// ============================================================
// Render
// ============================================================
color("CornflowerBlue")
    finger_segment_proximal();
