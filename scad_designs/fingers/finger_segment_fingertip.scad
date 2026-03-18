// ============================================================
// finger_segment_fingertip.scad
// Rounded Fingertip – final segment of the finger
// Smooth, natural-looking tip with gradual taper
//
// Print Settings:
//   Material:    PLA
//   Infill:      15%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~2 g
//   Print time:  ~2 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
length                = 18;   // mm  slightly shorter than other segments
width                 = 10;   // mm
thickness             = 7;    // mm
tip_radius            = 1.5;  // mm  rounded endpoint radius
taper_angle           = 10;   // degrees  gradual taper to tip
hinge_pin_diameter    = 2;    // mm  connects to distal segment
hinge_pin_bore        = 2.1;  // mm  (0.1 mm tolerance)
tendon_hole_diameter  = 1.35; // mm
elastic_hole_diameter = 1.75; // mm
wall_min              = 1.5;  // mm

// Derived
taper_offset  = length * tan(taper_angle);
tip_width     = max(width - 2 * taper_offset, tip_radius * 3);
hinge_boss_od = hinge_pin_bore + wall_min * 2;
hinge_boss_depth = 3.0;

// ============================================================
// Module: fingertip_body
// Tapered body ending in a smooth hemispherical tip
// ============================================================
module fingertip_body() {
    hull() {
        // Proximal (hinge) end – full width rectangle
        cube([2, width, thickness / 4]);
        translate([4, width / 2, thickness - 4])
            rotate([90, 0, 0])
                cylinder(r = 4, h = width, center = true);
        // Mid-section
        translate([length * 0.6, width / 2, thickness / 2])
            rotate([90, 0, 0])
                cylinder(r = thickness / 2 - 0.5, h = width * 0.6, center = true);
        // Rounded tip (sphere-ish)
        translate([length - tip_radius,
                   width / 2,
                   thickness / 2])
            sphere(r = tip_radius + 0.5);
    }
}

// ============================================================
// Module: finger_segment_fingertip
// ============================================================
module finger_segment_fingertip() {
    difference() {
        union() {
            fingertip_body();
            // Proximal hinge bosses
            for (y_pos = [width * 0.25, width * 0.75])
                translate([-hinge_boss_depth, y_pos, thickness / 2])
                    rotate([0, 90, 0])
                        cylinder(d = hinge_boss_od, h = hinge_boss_depth);
        }
        // Proximal hinge pin bores
        for (y_pos = [width * 0.25, width * 0.75])
            translate([-hinge_boss_depth - 0.1, y_pos, thickness / 2])
                rotate([0, 90, 0])
                    cylinder(d = hinge_pin_bore, h = hinge_boss_depth + 0.2);
        // Tendon hole (top face, near proximal end)
        translate([length * 0.35, width / 2, thickness - 2])
            cylinder(d = tendon_hole_diameter, h = 2.1);
        // Elastic holes (bottom face)
        for (dy = [-3, 3])
            translate([length * 0.35, width / 2 + dy, -0.1])
                cylinder(d = elastic_hole_diameter, h = thickness + 0.2);
        // Internal lightening cavity
        translate([wall_min * 2, wall_min, wall_min])
            cube([length - wall_min * 4 - tip_radius * 2,
                  width  - wall_min * 2,
                  thickness - wall_min * 2.5]);
    }
}

// ============================================================
// Render
// ============================================================
color("CornflowerBlue")
    finger_segment_fingertip();
