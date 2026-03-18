// ============================================================
// finger_segment_distal.scad
// Distal Finger Segment – second-to-last, before fingertip
// Slightly tapered (1–2° taper angle)
//
// Print Settings:
//   Material:    PLA
//   Infill:      15%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~2.5 g
//   Print time:  ~2 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
length                = 20;   // mm  segment length
width                 = 10;   // mm  proximal-end width
thickness             = 7;    // mm  segment thickness
hinge_pin_diameter    = 2;    // mm
hinge_pin_bore        = 2.1;  // mm  (0.1 mm tolerance)
tendon_hole_diameter  = 1.35; // mm
elastic_hole_diameter = 1.75; // mm
elastic_hole_spacing  = 7;    // mm
outer_radius          = 5;    // mm
taper_angle           = 1.5;  // degrees  side taper
wall_min              = 1.5;  // mm

// Derived
taper_offset     = length * tan(taper_angle);
distal_width     = width - 2 * taper_offset;
hinge_boss_od    = hinge_pin_bore + wall_min * 2;
hinge_boss_depth = 3.0;

// ============================================================
// Module: segment_body_distal
// Tapered body geometry
// ============================================================
module segment_body_distal() {
    hull() {
        // Proximal end (full width)
        cube([2, width, thickness / 4]);
        translate([outer_radius, width / 2, thickness - outer_radius + 1])
            rotate([90, 0, 0])
                cylinder(r = outer_radius, h = width, center = true);
        // Distal end (tapered width)
        translate([length - 2, taper_offset, 0])
            cube([2, distal_width, thickness / 4]);
        translate([length - outer_radius,
                   width / 2,
                   thickness - outer_radius + 1])
            rotate([90, 0, 0])
                cylinder(r = outer_radius - taper_offset / 2,
                         h = distal_width, center = true);
    }
}

// ============================================================
// Module: finger_segment_distal
// ============================================================
module finger_segment_distal() {
    difference() {
        union() {
            segment_body_distal();
            // Proximal hinge bosses
            for (y_pos = [width * 0.25, width * 0.75])
                translate([-hinge_boss_depth, y_pos, thickness / 2])
                    rotate([0, 90, 0])
                        cylinder(d = hinge_boss_od, h = hinge_boss_depth);
            // Distal hinge bosses (narrower due to taper)
            for (y_pos = [taper_offset + distal_width * 0.25,
                          taper_offset + distal_width * 0.75])
                translate([length, y_pos, thickness / 2])
                    rotate([0, 90, 0])
                        cylinder(d = hinge_boss_od, h = hinge_boss_depth);
        }
        // Proximal hinge bores
        for (y_pos = [width * 0.25, width * 0.75])
            translate([-hinge_boss_depth - 0.1, y_pos, thickness / 2])
                rotate([0, 90, 0])
                    cylinder(d = hinge_pin_bore, h = hinge_boss_depth + 0.2);
        // Distal hinge bores
        for (y_pos = [taper_offset + distal_width * 0.25,
                      taper_offset + distal_width * 0.75])
            translate([length - 0.1, y_pos, thickness / 2])
                rotate([0, 90, 0])
                    cylinder(d = hinge_pin_bore, h = hinge_boss_depth + 0.2);
        // Tendon hole (top face)
        translate([length / 2, width / 2, thickness - 2])
            cylinder(d = tendon_hole_diameter, h = 2.1);
        // Elastic holes (bottom face)
        for (dy = [-elastic_hole_spacing / 2, elastic_hole_spacing / 2])
            translate([length / 2, width / 2 + dy, -0.1])
                cylinder(d = elastic_hole_diameter, h = thickness + 0.2);
        // Internal lightening
        translate([wall_min * 2, wall_min + taper_offset / 2, wall_min])
            cube([length - wall_min * 4,
                  distal_width - wall_min,
                  thickness - wall_min * 2.5]);
    }
}

// ============================================================
// Render
// ============================================================
color("CornflowerBlue")
    finger_segment_distal();
