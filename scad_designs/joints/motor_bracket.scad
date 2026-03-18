// ============================================================
// motor_bracket.scad
// DC Motor Mounting Bracket for Humanoid Welcoming Robot
// Flanged motor mount + shaft coupler for 12V/24V geared motors
//
// Print Settings:
//   Material:    PLA
//   Infill:      70%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~8 g (need 2)
//   Print time:  ~5 minutes each
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
motor_diameter         = 37;   // mm  standard motor can
motor_length           = 45;   // mm  motor body length
motor_shaft_diameter   = 6;    // mm  motor output shaft
wheel_bore             = 8;    // mm  wheel hub bore
mounting_hole_diameter = 3.2;  // mm  M3 screws to base
wall_thickness         = 2.5;  // mm  bracket wall thickness
flange_thickness       = 4.0;  // mm  mounting flange thickness
flange_width           = 55;   // mm  flange width (bolt pattern)
flange_height          = 60;   // mm  flange height (bolt pattern)
bolt_inset             = 5;    // mm  bolt hole distance from edge

// Derived
motor_radius    = motor_diameter / 2;
collar_od       = motor_diameter + 2 * wall_thickness;
collar_height   = 20;   // grip length on motor body

// ============================================================
// Module: motor_collar
// Cylindrical clamp around motor body
// ============================================================
module motor_collar() {
    split_gap = 1.5;   // mm  clamp gap
    difference() {
        cylinder(d = collar_od, h = collar_height);
        // Motor bore
        translate([0, 0, -0.1])
            cylinder(d = motor_diameter, h = collar_height + 0.2);
        // Clamp split slot
        translate([-split_gap / 2, -collar_od / 2 - 0.1, -0.1])
            cube([split_gap, collar_od / 2 + 0.2, collar_height + 0.2]);
        // Clamp screw hole (M3, across split)
        translate([0, collar_od / 2, collar_height / 2])
            rotate([90, 0, 0])
                cylinder(d = mounting_hole_diameter,
                         h = collar_od + 0.2, center = true);
    }
}

// ============================================================
// Module: mounting_flange
// Flat plate with bolt holes that bolts to GI base frame
// ============================================================
module mounting_flange() {
    difference() {
        translate([-flange_width / 2, -flange_height / 2, 0])
            cube([flange_width, flange_height, flange_thickness]);
        // 4× corner bolt holes
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * (flange_width / 2 - bolt_inset),
                           sy * (flange_height / 2 - bolt_inset),
                           -0.1])
                    cylinder(d = mounting_hole_diameter,
                             h = flange_thickness + 0.2);
        // Central hole for shaft clearance
        translate([0, 0, -0.1])
            cylinder(d = motor_diameter + 2, h = flange_thickness + 0.2);
    }
}

// ============================================================
// Module: shaft_coupler
// Adapts 6 mm motor shaft to 8 mm wheel hub bore
// ============================================================
module shaft_coupler() {
    coupler_od     = 16;
    coupler_length = 25;
    set_screw_d    = 2.5;  // M2.5 set screw
    difference() {
        cylinder(d = coupler_od, h = coupler_length);
        // Motor shaft bore (6 mm)
        translate([0, 0, -0.1])
            cylinder(d = motor_shaft_diameter, h = coupler_length * 0.6 + 0.1);
        // Wheel hub bore (8 mm, other end)
        translate([0, 0, coupler_length * 0.5])
            cylinder(d = wheel_bore, h = coupler_length * 0.5 + 0.1);
        // Set screw holes (2× perpendicular)
        for (a = [0, 90])
            rotate([0, 0, a])
                translate([coupler_od / 2, 0, coupler_length * 0.25])
                    rotate([0, 90, 0])
                        cylinder(d = set_screw_d,
                                 h = coupler_od + 0.2, center = true);
    }
}

// ============================================================
// Module: motor_bracket
// Complete bracket assembly
// ============================================================
module motor_bracket() {
    // Mounting flange (bolts to base)
    mounting_flange();
    // Motor collar (rises from flange)
    translate([0, 0, flange_thickness])
        motor_collar();
}

// ============================================================
// Render  (bracket + separate coupler shown side by side)
// ============================================================
color("SteelBlue")
    motor_bracket();
color("LightSlateGray")
    translate([motor_diameter + 15, 0, 0])
        shaft_coupler();
