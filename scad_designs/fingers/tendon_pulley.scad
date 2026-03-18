// ============================================================
// tendon_pulley.scad
// Servo Horn Tendon Pulley for Humanoid Welcoming Robot
// Mounts to MG90S servo in palm; routes 3 finger tendons
//
// Print Settings:
//   Material:    PLA
//   Infill:      90% (precision component)
//   Layer height: 0.1 mm (high quality for smooth rotation)
//   Supports:    None required
//   Weight:      ~5 g
//   Print time:  ~4 minutes
// ============================================================

$fn = 64;   // higher resolution for smooth pulley
$fa = 4;
$fs = 0.5;

// --- Parametric Variables ---
pulley_diameter      = 15;   // mm  pulley outer diameter
pulley_width         = 8;    // mm  total pulley width
servo_horn_diameter  = 25;   // mm  MG90S servo horn engagement diameter
tendon_groove_width  = 1.5;  // mm  groove channel width
tendon_groove_depth  = 1;    // mm  groove depth
num_grooves          = 3;    // number of radial tendon grooves (one per finger)
hub_diameter         = 6;    // mm  splined hub (press-fit to servo output)
hub_length           = 6;    // mm  hub engagement depth
set_screw_d          = 2;    // mm  M2 set screw for hub retention
flange_thickness     = 1.5;  // mm  side flanges keep tendon on pulley

// ============================================================
// Module: pulley_drum
// Cylindrical drum with radial tendon grooves
// ============================================================
module pulley_drum() {
    groove_pitch = pulley_width / (num_grooves + 1);

    difference() {
        // Main cylinder
        cylinder(d = pulley_diameter, h = pulley_width);
        // Radial tendon grooves
        for (i = [1 : num_grooves]) {
            z = i * groove_pitch - tendon_groove_width / 2;
            translate([0, 0, z])
                difference() {
                    cylinder(d = pulley_diameter + 0.2,
                             h = tendon_groove_width);
                    cylinder(d = pulley_diameter - 2 * tendon_groove_depth,
                             h = tendon_groove_width);
                }
        }
        // Side flanges stay (not cut)
    }
}

// ============================================================
// Module: servo_hub
// Press-fit hub that mates with MG90S splined output shaft
// ============================================================
module servo_hub() {
    difference() {
        cylinder(d = hub_diameter + 3, h = hub_length);
        // Splined / hex bore approximation
        // MG90S uses a 4.85 mm spline; model as circle with flat
        cylinder(d = hub_diameter, h = hub_length + 0.1);
        // Flat for spline anti-rotation
        translate([hub_diameter / 2 - 0.6, -(hub_diameter / 2),
                   -0.1])
            cube([1.5, hub_diameter, hub_length + 0.2]);
        // Set-screw hole (radial)
        translate([0, 0, hub_length * 0.6])
            rotate([90, 0, 0])
                cylinder(d = set_screw_d,
                         h = hub_diameter + 4 + 0.2, center = true);
    }
}

// ============================================================
// Module: tendon_pulley
// Complete pulley assembly
// ============================================================
module tendon_pulley() {
    union() {
        pulley_drum();
        // Hub protrudes below drum
        translate([0, 0, -hub_length])
            servo_hub();
        // Top retaining flange
        translate([0, 0, pulley_width])
            cylinder(d = pulley_diameter + flange_thickness * 2,
                     h = flange_thickness);
        // Bottom retaining flange
        translate([0, 0, -flange_thickness])
            cylinder(d = pulley_diameter + flange_thickness * 2,
                     h = flange_thickness);
    }
}

// ============================================================
// Render
// ============================================================
color("LightGray")
    tendon_pulley();
