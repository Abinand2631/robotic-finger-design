// ============================================================
// Caster Wheel Bracket — 50 mm swivel caster for robot base
// ============================================================
// Bolts to the underside of the base deck.
// Accepts a standard 50 mm swivel caster ball-wheel insert.
// Swivel axle: 5 mm diameter bolt through bracket pivot.
// ============================================================

deck_w      = 40;   // mm — bracket footprint width
deck_l      = 40;   // mm — bracket footprint depth
deck_h      =  4;   // mm — mounting plate thickness
bolt_d      =  4.5; // mm — M4 clearance for deck bolts
bolt_sep_x  = 30;   // mm — bolt pattern X spacing
bolt_sep_y  = 30;   // mm — bolt pattern Y spacing

swivel_h    = 18;   // mm — height of swivel post from plate
swivel_od   = 12;   // mm — swivel post outer diameter
axle_d      =  5.2; // mm — axle bolt clearance
caster_d    = 50;   // mm — caster wheel diameter (reference)
fork_w      = 14;   // mm — fork width (wheel gap + 2 mm each side)
fork_h      = 30;   // mm — fork arm length
fork_t      =  3;   // mm — fork wall thickness
wheel_axle_d =  4.2;// mm — wheel axle bolt

corner_r    = 2.0;
wall        = 3.0;
$fn = 48;

// ============================================================
module mounting_plate() {
    difference() {
        // Rounded plate
        minkowski() {
            cube([deck_w - 2*corner_r,
                  deck_l - 2*corner_r,
                  deck_h - corner_r/2], center = true);
            cylinder(r = corner_r, h = corner_r/2);
        }
        // Bolt holes
        for (dx = [-bolt_sep_x/2, bolt_sep_x/2])
            for (dy = [-bolt_sep_y/2, bolt_sep_y/2])
                translate([dx, dy, -deck_h/2 - 0.1])
                    cylinder(r = bolt_d/2, h = deck_h + 0.2);
        // Swivel axle hole (centre)
        translate([0, 0, -deck_h/2 - 0.1])
            cylinder(r = axle_d/2, h = deck_h + 0.2);
    }
}

module swivel_post() {
    // Cylindrical post below the plate that allows rotation
    translate([0, 0, -deck_h/2 - swivel_h])
        difference() {
            cylinder(r = swivel_od/2, h = swivel_h);
            translate([0, 0, -0.1])
                cylinder(r = axle_d/2, h = swivel_h + 0.2);
        }
}

module fork_arm() {
    // Two parallel arms forming a U-fork around the caster wheel
    difference() {
        translate([-fork_w/2, -fork_t/2, -deck_h/2 - swivel_h - fork_h])
            cube([fork_w, fork_t, fork_h]);
        // Wheel axle hole
        translate([0, 0, -deck_h/2 - swivel_h - fork_h + 6])
            rotate([90, 0, 0])
                cylinder(r = wheel_axle_d/2, h = fork_t + 1, center = true);
    }
}

// ============================================================
union() {
    color("LightSlateGray") translate([0, 0, deck_h/2]) mounting_plate();
    color("SlateGray")      swivel_post();
    // Fork arms (front & back of wheel)
    for (dy = [-caster_d/2 - fork_t/2 - 1, caster_d/2 + fork_t/2 + 1])
        color("DimGray")
            translate([0, dy, 0])
                fork_arm();
}
