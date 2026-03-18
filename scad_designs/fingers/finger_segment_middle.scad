// ============================================================
// finger_segment_middle.scad
// Middle Finger Segment – Humanoid Welcoming Robot
// Identical geometry to proximal but with tapered/reduced mass
//
// Print Settings:
//   Material:    PLA
//   Infill:      15%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~3 g
//   Print time:  ~2.5 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
length                = 20;   // mm  segment length
width                 = 10;   // mm  segment width
thickness             = 7;    // mm  segment thickness
hinge_pin_diameter    = 2;    // mm  hinge pin outer diameter
hinge_pin_bore        = 2.1;  // mm  hinge hole diameter (0.1 mm tolerance)
tendon_hole_diameter  = 1.35; // mm  tendon hole (top face)
elastic_hole_diameter = 1.75; // mm  elastic band holes (bottom face)
elastic_hole_spacing  = 7;    // mm  distance between two bottom holes
outer_radius          = 5;    // mm  dorsal curvature radius
wall_min              = 1.5;  // mm  minimum wall thickness

// Taper: middle segment is slightly narrower at the distal end
taper_amount = 0.5;           // mm  width reduction at distal end

// Derived
hinge_boss_od    = hinge_pin_bore + wall_min * 2;
hinge_boss_depth = 3.0;

// ============================================================
// Module: segment_body_tapered
// Slightly tapered body for reduced mass
// ============================================================
module segment_body_tapered() {
    hull() {
        // Proximal (palm) end – full width
        translate([0, 0, 0])
            cube([1, width, thickness / 4]);
        translate([outer_radius, width / 2, thickness - outer_radius + 1])
            rotate([90, 0, 0])
                cylinder(r = outer_radius, h = width, center = true);
        // Distal end – slightly tapered
        translate([length - 1, taper_amount / 2, 0])
            cube([1, width - taper_amount, thickness / 4]);
        translate([length - outer_radius,
                   width / 2,
                   thickness - outer_radius + 1])
            rotate([90, 0, 0])
                cylinder(r = outer_radius - taper_amount / 2,
                         h = width - taper_amount, center = true);
    }
}

// ============================================================
// Module: hinge_bosses
// ============================================================
module hinge_bosses() {
    for (y_pos = [width * 0.25, width * 0.75]) {
        // Proximal boss (solid)
        translate([-hinge_boss_depth, y_pos, thickness / 2])
            rotate([0, 90, 0])
                cylinder(d = hinge_boss_od, h = hinge_boss_depth);
        // Distal boss
        translate([length, y_pos - taper_amount / 4, thickness / 2])
            rotate([0, 90, 0])
                cylinder(d = hinge_boss_od, h = hinge_boss_depth);
    }
}

// ============================================================
// Module: finger_segment_middle
// ============================================================
module finger_segment_middle() {
    difference() {
        union() {
            segment_body_tapered();
            hinge_bosses();
        }
        // Hinge pin bores (both ends)
        for (x_pos = [-hinge_boss_depth - 0.1, length - 0.1])
            for (y_pos = [width * 0.25, width * 0.75])
                translate([x_pos, y_pos, thickness / 2])
                    rotate([0, 90, 0])
                        cylinder(d = hinge_pin_bore, h = hinge_boss_depth + 0.2);
        // Tendon hole (top face, 2 mm from surface)
        translate([length / 2, width / 2, thickness - 2])
            cylinder(d = tendon_hole_diameter, h = 2.1);
        // Elastic holes (bottom face)
        for (dy = [-elastic_hole_spacing / 2, elastic_hole_spacing / 2])
            translate([length / 2, width / 2 + dy, -0.1])
                cylinder(d = elastic_hole_diameter, h = thickness + 0.2);
        // Internal lightening cavity
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
    finger_segment_middle();
