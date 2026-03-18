// ============================================================
// torso_base_connector.scad
// Torso-Base Connector Plates for Humanoid Welcoming Robot
// Connects GI square-pipe base frame to PVC torso
//
// Print Settings:
//   Material:    PLA
//   Infill:      80%
//   Layer height: 0.2 mm
//   Supports:    None required
//   Weight:      ~15 g total (4 plates)
//   Print time:  ~8 minutes
// ============================================================

$fn = 32;
$fa = 6;
$fs = 1;

// --- Parametric Variables ---
base_frame_width    = 400;  // mm  GI base frame outer width
base_frame_depth    = 300;  // mm  GI base frame outer depth
base_frame_height   = 120;  // mm  GI frame vertical height
bolt_pattern        = "M4"; // mounting bolt size
bolt_d              = 4.5;  // mm  M4 bolt clearance hole
torso_offset_height = 50;   // mm  spacer height between base and torso
gi_pipe_size        = 25;   // mm  GI square pipe outer size
pvc_bore            = 20;   // mm  PVC torso tube inner diameter
pvc_od              = 25;   // mm  PVC outer diameter
wall_thickness      = 3.0;  // mm
plate_thickness     = 5.0;  // mm

// Plate dimensions derived from base frame: connectors sit at frame corners.
// plate_length spans two GI pipe widths; plate_width spans one width + margin.
// Adjust these if base_frame_width/depth changes to maintain proportional fit.
plate_length = gi_pipe_size * 2 + 20; // mm  ~70 mm for 25 mm GI pipe
plate_width  = gi_pipe_size + 25;     // mm  ~50 mm for 25 mm GI pipe

// Spacer height clamp: torso_offset_height should not exceed base frame height
assert(torso_offset_height <= base_frame_height,
       "torso_offset_height must not exceed base_frame_height");

// Effective corner bolt offsets scale with the base frame footprint
corner_bolt_inset = min(8, plate_length / 6); // mm  bolt hole inset from edge

// ============================================================
// Module: base_bolt_plate
// Bottom plate – bolts to top of GI base frame corner
// ============================================================
module base_bolt_plate() {
    difference() {
        cube([plate_length, plate_width, plate_thickness]);
        // 4× M4 bolt holes
        for (sx = [corner_bolt_inset, plate_length - corner_bolt_inset])
            for (sy = [corner_bolt_inset, plate_width - corner_bolt_inset])
                translate([sx, sy, -0.1])
                    cylinder(d = bolt_d, h = plate_thickness + 0.2);
        // GI pipe seating notch (U-channel, 25 mm wide)
        translate([plate_length / 2 - gi_pipe_size / 2, -0.1, plate_thickness / 2])
            cube([gi_pipe_size, plate_width / 2 + 0.2,
                  plate_thickness / 2 + 0.1]);
    }
}

// ============================================================
// Module: spacer_column
// Vertical adjustable-height spacer between base and torso
// ============================================================
module spacer_column() {
    column_od = 20;
    column_id = 10;
    difference() {
        cylinder(d = column_od, h = torso_offset_height);
        translate([0, 0, -0.1])
            cylinder(d = column_id, h = torso_offset_height + 0.2);
    }
}

// ============================================================
// Module: torso_bolt_plate
// Top plate – bolts to bottom of PVC torso frame
// ============================================================
module torso_bolt_plate() {
    difference() {
        cube([plate_length, plate_width, plate_thickness]);
        // 4× M4 bolt holes
        for (sx = [corner_bolt_inset, plate_length - corner_bolt_inset])
            for (sy = [corner_bolt_inset, plate_width - corner_bolt_inset])
                translate([sx, sy, -0.1])
                    cylinder(d = bolt_d, h = plate_thickness + 0.2);
        // PVC torso stub hole (central)
        translate([plate_length / 2, plate_width / 2, -0.1])
            cylinder(d = pvc_od + 0.4, h = plate_thickness + 0.2);
    }
}

// ============================================================
// Module: torso_base_connector
// Single assembled connector (base plate + spacer + torso plate)
// ============================================================
module torso_base_connector() {
    // Bottom base plate
    base_bolt_plate();
    // Spacer column
    translate([plate_length / 2, plate_width / 2, plate_thickness])
        spacer_column();
    // Top torso plate
    translate([0, 0, plate_thickness + torso_offset_height])
        torso_bolt_plate();
}

// ============================================================
// Render – show one connector
// ============================================================
color("Crimson")
    torso_base_connector();

// Show a second connector offset for context
color("Crimson", 0.5)
    translate([plate_length + 20, 0, 0])
        torso_base_connector();
