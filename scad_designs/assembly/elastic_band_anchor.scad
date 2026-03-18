// ============================================================
// elastic_band_anchor.scad
// Elastic Band Anchor Points for Palm Return System
// Mounts to bottom face of palm; anchors elastic return bands
//
// Print Settings:
//   Material:    PLA
//   Infill:      70%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~2 g each (4 total = ~8 g)
//   Print time:  ~2 minutes each
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
anchor_width        = 10;  // mm  anchor body width
anchor_height       = 8;   // mm  anchor body height
anchor_thickness    = 4;   // mm  anchor body depth
band_hole_diameter  = 2;   // mm  elastic band loop hole
mount_screw_d       = 2.5; // mm  M2.5 screw to attach to palm
corner_radius       = 1.5; // mm  smooth rounded edges (no band chafing)

// ============================================================
// Module: anchor_body
// Rounded rectangular body
// ============================================================
module anchor_body() {
    hull()
        for (sx = [corner_radius, anchor_width - corner_radius])
            for (sz = [corner_radius, anchor_height - corner_radius])
                translate([sx, 0, sz])
                    rotate([-90, 0, 0])
                        cylinder(r = corner_radius, h = anchor_thickness);
}

// ============================================================
// Module: elastic_band_anchor
// Body with two band holes and one mount screw hole
// ============================================================
module elastic_band_anchor() {
    difference() {
        anchor_body();
        // Two elastic band holes (side-by-side on the narrow face)
        for (hx = [anchor_width * 0.3, anchor_width * 0.7])
            translate([hx, -0.1, anchor_height * 0.55])
                rotate([-90, 0, 0])
                    cylinder(d = band_hole_diameter,
                             h = anchor_thickness + 0.2);
        // Mount screw hole (centred, through bottom into palm)
        translate([anchor_width / 2, anchor_thickness / 2, -0.1])
            cylinder(d = mount_screw_d, h = anchor_height * 0.5 + 0.1);
        // Screw countersink
        translate([anchor_width / 2, anchor_thickness / 2, -0.1])
            cylinder(d1 = mount_screw_d * 2,
                     d2 = mount_screw_d,
                     h = mount_screw_d);
    }
}

// ============================================================
// Render – show 4 anchors in typical palm layout
// ============================================================
positions = [
    [0, 0],
    [anchor_width + 5, 0],
    [0, anchor_thickness + 5],
    [anchor_width + 5, anchor_thickness + 5]
];

for (i = [0:3]) {
    color("Tomato")
        translate([positions[i][0], positions[i][1], 0])
            elastic_band_anchor();
}
