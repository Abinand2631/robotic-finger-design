// ============================================================
// caster_wheel_bracket.scad
// Swivel Caster Wheel Bracket for Humanoid Welcoming Robot
// Swivel mount for 50 mm caster wheel with shock-absorbing base
//
// Print Settings:
//   Material:    PETG (flexible properties)
//   Infill:      60%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~12 g
//   Print time:  ~7 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
wheel_diameter         = 50;   // mm  caster wheel outer diameter
wheel_bore             = 5;    // mm  caster axle diameter
base_mount_holes       = 4;    // number of M4 mounting bolts
swivel_bearing_diameter = 25;  // mm  ball bearing outer diameter
mounting_hole_diameter = 4.2;  // mm  M4 bolt clearance
wall_thickness         = 2.5;  // mm  bracket wall thickness
plate_thickness        = 4.0;  // mm  mounting plate thickness
fork_thickness         = 3.0;  // mm  fork arm thickness
fork_height            = 30;   // mm  fork arm height (wheel clearance)
axle_boss_height       = 6;    // mm  axle boss length each side

// Derived
wheel_radius    = wheel_diameter / 2;
bearing_radius  = swivel_bearing_diameter / 2;
plate_size      = 50;          // mm  square mounting plate side

// ============================================================
// Module: mounting_plate
// Flat base plate with 4-hole M4 bolt pattern
// ============================================================
module mounting_plate() {
    bolt_offset = plate_size / 2 - 6;
    difference() {
        // Rounded rectangle plate
        hull()
            for (sx = [-1, 1])
                for (sy = [-1, 1])
                    translate([sx * (plate_size / 2 - 4),
                               sy * (plate_size / 2 - 4), 0])
                        cylinder(r = 4, h = plate_thickness);
        // Central swivel bearing recess
        translate([0, 0, plate_thickness - 2])
            cylinder(d = swivel_bearing_diameter + 0.4, h = 2.1);
        // Bearing through-hole for swivel pin
        translate([0, 0, -0.1])
            cylinder(d = 8, h = plate_thickness + 0.2);
        // 4× mounting bolt holes
        for (a = [0, 90, 180, 270])
            rotate([0, 0, a + 45])
                translate([bolt_offset, 0, -0.1])
                    cylinder(d = mounting_hole_diameter,
                             h = plate_thickness + 0.2);
    }
}

// ============================================================
// Module: swivel_yoke
// Rotating U-shaped fork that holds the wheel
// ============================================================
module swivel_yoke() {
    fork_width   = wheel_diameter + 2 * fork_thickness + 4;
    fork_inner_w = wheel_diameter + 4;

    difference() {
        union() {
            // Top swivel hub (mates with bearing)
            cylinder(d = swivel_bearing_diameter - 0.4, h = 8);
            // Fork body
            translate([-fork_width / 2, -fork_thickness, 8])
                cube([fork_width, fork_thickness + wheel_radius + 2,
                      fork_height]);
            // Fork arms (two sides holding axle)
            for (sx = [-1, 1])
                translate([sx * (fork_inner_w / 2),
                           0, 8 + fork_height - axle_boss_height])
                    cube([fork_thickness, wheel_radius + 2,
                          axle_boss_height]);
        }
        // Swivel pin bore
        translate([0, 0, -0.1])
            cylinder(d = 8.2, h = 9);
        // Wheel axle bore (through both fork arms)
        translate([0, wheel_radius / 2 + 2,
                   8 + fork_height - axle_boss_height / 2])
            rotate([0, 90, 0])
                cylinder(d = wheel_bore + 0.2,
                         h = fork_width + 0.2, center = true);
        // Wheel clearance slot in fork body
        translate([-fork_inner_w / 2,
                   wheel_radius / 2 - wheel_radius,
                   8 + fork_height - wheel_radius - 2])
            cube([fork_inner_w, wheel_diameter + 2, wheel_diameter + 2]);
    }
}

// ============================================================
// Module: elastomer_bushing
// Soft bushing ring between plate and yoke for shock absorption
// ============================================================
module elastomer_bushing() {
    bushing_h  = 4;
    bushing_id = 8.4;
    bushing_od = swivel_bearing_diameter - 1;
    difference() {
        cylinder(d = bushing_od, h = bushing_h);
        translate([0, 0, -0.1])
            cylinder(d = bushing_id, h = bushing_h + 0.2);
    }
}

// ============================================================
// Module: caster_wheel_bracket
// Complete bracket assembly
// ============================================================
module caster_wheel_bracket() {
    mounting_plate();
    translate([0, 0, plate_thickness + 0.5])
        elastomer_bushing();
    translate([0, 0, plate_thickness + 5])
        swivel_yoke();
}

// ============================================================
// Render
// ============================================================
color("DarkSeaGreen")
    caster_wheel_bracket();
