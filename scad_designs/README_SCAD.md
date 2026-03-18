# OpenSCAD Design Files

Parametric OpenSCAD (`.scad`) design files for all 3D-printed components.

---

## ★ 3-Finger Cable-Driven Robotic Hand – Bellows-Style Joints (main design)

**File:** [`robotic_hand_3finger.scad`](robotic_hand_3finger.scad)

A complete, self-contained parametric design for a 3-finger (thumb, index, middle)
cable-driven robotic hand with **bellows/accordion-style flexible joints**.
A star/sunburst-pattern web connects each pair of cylindrical segments.
Two cables per finger drive flexion; elastic bands return fingers to open position.
Designed for a 127 cm humanoid robot (arm Ø ≈ 63 mm).

Reference video: <https://youtu.be/r62dPoS-24s>

| Feature | Value |
|---------|-------|
| Palm size | 100 × 80 × 30 mm |
| Segment cross-section | Cylindrical, Ø 18 mm |
| Segment length | 25 mm (uniform) |
| Segments per finger | 4 (configurable to 5) |
| Bellows joints per finger | 3 (6-spoke star pattern) |
| Total finger length | ~125 mm (with tip dome) |
| Cables per finger | **2 × Ø 2 mm** |
| Elastic return channel | Ø 1.8 mm (dorsal side) |
| Servo (1 per finger) | SG90 / MG90S class (9–15 g) |
| Arm interface | Ø 63 mm saddle + 4 × M4 bolts |
| Material | PLA (rigid) / TPU optional for bellows |

**Modules inside the file:**

| Module | Description |
|--------|-------------|
| `rounded_box` | Utility – rounded-corner box via hull of cylinders |
| `bellows_profile` | 2-D star/sunburst cross-section (hub + 6 radial spokes) |
| `bellows_joint` | Flexible accordion connector: end-collars + star body + cable bores |
| `finger_segment` | Rigid cylindrical segment with 2 cable bores, 1 elastic bore, optional tip dome |
| `single_finger` | One complete finger (4 segments + 3 bellows joints) with cable/elastic visualisation |
| `servo_motor_block` | SG90/MG90S servo placeholder for assembly visualisation |
| `palm_base` | 100 × 80 × 30 mm palm with knuckle bosses, servo pockets, cable routing, wrist bolts |
| `robotic_hand_3finger` | **Top-level assembly** – palm + 3 fingers + servos |

**Key parameters at top of file:**

```openscad
seg_d     = 18;   // segment outer diameter (mm)
seg_len   = 25;   // segment length (mm)
seg_wall  = 2.5;  // wall thickness (mm)
num_segs  = 4;    // segments per finger
joint_len = 8;    // bellows joint length (mm)
n_spokes  = 6;    // star-pattern spokes in each joint
cable_d   = 2.0;  // cable diameter (mm)  — 2 cables per finger
palm_w    = 100;  // palm width (mm)
palm_d    = 80;   // palm depth (mm)
palm_h    = 30;   // palm height/thickness (mm)
arm_d     = 63;   // forearm tube diameter for arm interface (mm)
```

Toggle display flags before rendering:

```openscad
SHOW_SERVOS  = true;   // show servo motor blocks
SHOW_CABLES  = true;   // draw cable guide lines (red)
SHOW_ELASTIC = true;   // draw elastic band line (green)
```

---

## Humanoid Robot Support Components

This repository also contains OpenSCAD design files for a small humanoid welcoming robot (a separate project that shares the same repository). These components are listed below for reference.

## Directory Structure

```
scad_designs/
├── robotic_hand_3finger.scad         – ★ 3-finger cable-driven hand (main design)
├── joints/
│   ├── shoulder_joint_bracket.scad   – MG996R servo mount + PVC pipe adapter
│   ├── elbow_joint_bracket.scad      – MG90S servo mount + dual PVC adapters
│   ├── motor_bracket.scad            – DC motor mount + shaft coupler
│   ├── caster_wheel_bracket.scad     – Swivel caster with shock absorption (PETG)
│   └── pan_tilt_head_mount.scad      – Pan + tilt servo bracket for head
├── fingers/
│   ├── finger_segment_proximal.scad  – First finger segment (palm end)
│   ├── finger_segment_middle.scad    – Middle finger segment
│   ├── finger_segment_distal.scad    – Pre-fingertip segment (tapered)
│   ├── finger_segment_fingertip.scad – Rounded fingertip segment
│   ├── palm_structure.scad           – Servo cavity + tendon routing palm
│   └── tendon_pulley.scad            – Servo horn pulley (3-groove, 3-finger)
├── head/
│   ├── head_shell.scad               – Ellipsoid head with eye sockets + neck mount
│   └── head_internal_bracket.scad    – Internal pan-tilt servo mounts
├── assembly/
│   ├── torso_base_connector.scad     – GI base ↔ PVC torso connector plates
│   ├── elastic_band_anchor.scad      – Elastic return-band anchor points
│   ├── assembly_full_robot.scad      – Complete robot visualization
│   ├── finger_assembly_single.scad   – Single finger (all 4 segments + pins)
│   └── hand_assembly_complete.scad   – Full hand with tendons + elastic bands
└── README_SCAD.md                    – This file
```

---

## Getting Started

1. **Install OpenSCAD** – download from [openscad.org](https://openscad.org)
2. **Open any `.scad` file** in OpenSCAD
3. **Press `F5`** to render a preview (fast)
4. **Press `F6`** for final render (slower, use before export)
5. **Press `F7`** to export as STL for slicing
6. **Load STL into your slicer** (Cura, PrusaSlicer, OrcaSlicer, etc.)
7. **Apply print settings** specified in the file header

---

## File-by-File Summary

### Joints & Brackets

| File | Servo | PVC Bore | Material | Infill | Weight | Print Time |
|------|-------|----------|----------|--------|--------|------------|
| `shoulder_joint_bracket.scad` | MG996R | 20 mm | PLA | 80% | ~20 g | ~8 min |
| `elbow_joint_bracket.scad` | MG90S | 20 mm | PLA | 80% | ~15 g | ~6 min |
| `motor_bracket.scad` | – | – | PLA | 70% | ~8 g×2 | ~5 min each |
| `caster_wheel_bracket.scad` | – | – | PETG | 60% | ~12 g | ~7 min |
| `pan_tilt_head_mount.scad` | MG90S×2 | 20 mm neck | PLA | 70% | ~18 g | ~10 min |

### Finger Segments

| File | Length | Infill | Weight | Print Time |
|------|--------|--------|--------|------------|
| `finger_segment_proximal.scad` | 20 mm | 15% | ~4 g | ~3 min |
| `finger_segment_middle.scad` | 20 mm | 15% | ~3 g | ~2.5 min |
| `finger_segment_distal.scad` | 20 mm | 15% | ~2.5 g | ~2 min |
| `finger_segment_fingertip.scad` | 18 mm | 15% | ~2 g | ~2 min |
| `palm_structure.scad` | 60 mm | 20% | ~25 g | ~12 min |
| `tendon_pulley.scad` | – | 90% | ~5 g | ~4 min |

### Head Components

| File | Material | Infill | Weight | Print Time |
|------|----------|--------|--------|------------|
| `head_shell.scad` | PLA | 15% | ~85 g | ~25 min |
| `head_internal_bracket.scad` | PLA | 70% | ~12 g | ~8 min |

### Assembly & Utility

| File | Material | Infill | Weight | Print Time |
|------|----------|--------|--------|------------|
| `torso_base_connector.scad` | PLA | 80% | ~15 g total | ~8 min |
| `elastic_band_anchor.scad` | PLA | 70% | ~2 g each | ~2 min each |

---

## Key Parametric Variables

All files use consistent parameter naming at the top of each file. Common variables:

```openscad
// Servo dimensions (adjust for different servo model)
servo_width  = 23;    // mm  (MG90S = 23, MG996R = 40.5)
servo_depth  = 12;    // mm

// PVC pipe
pvc_bore     = 20;    // mm  inner diameter
pvc_wall     = 2.5;   // mm  wall thickness

// Mounting
mounting_hole_diameter = 3.2; // mm  (M3 = 3.2, M2.5 = 2.7, M4 = 4.2)
wall_thickness         = 2.0; // mm  minimum structural wall

// Finger
length       = 20;   // mm  segment length
width        = 10;   // mm  segment width
thickness    = 7;    // mm  segment height
hinge_pin_bore = 2.1; // mm  (2 mm pin + 0.1 mm tolerance)
tendon_hole_diameter  = 1.35; // mm  fishing line hole
elastic_hole_diameter = 1.75; // mm  elastic band hole
```

---

## Customisation Examples

| Goal | Change |
|------|--------|
| Longer fingers | Increase `length` variable in segment files |
| Thicker finger walls | Increase `wall_min` |
| Different servo | Update `servo_width` + `servo_depth` |
| Larger hand | Proportionally scale `palm_length` + `palm_width` |
| Sphere head | Set `shape = "sphere"` in `head_shell.scad` |
| Different PVC size | Update `pvc_bore` + `pvc_wall` |
| Namaste pose view | Set `show_gesture_namaste = true` in assembly |

---

## Render Quality

Each file includes standard quality settings at the top:

```openscad
$fn = 32;   // circle fragments (increase to 64 for smoother curves)
$fa = 6;    // angle per fragment
$fs = 1;    // fragment size in mm
```

- Use `$fn = 16` for fast preview
- Use `$fn = 64` for high-quality final export (especially `head_shell.scad` and `tendon_pulley.scad`)

---

## Print Settings Summary

| Setting | Value |
|---------|-------|
| Layer height | 0.2 mm |
| Wall count | ≥ 3 (≥ 1.5 mm) |
| Supports | None required |
| Bed adhesion | Brim (for small parts) |
| Nozzle | 0.4 mm |
| Temperature | PLA: 200–210 °C / PETG: 230–240 °C |
| Bed temperature | PLA: 60 °C / PETG: 70–80 °C |

---

## Hand Mechanics (Bellows-Style Finger)

```
Servo horn (in palm)
      │
      ╠══ Cable 1 ══╗     ← 2 mm Dyneema/steel cable
      ╠══ Cable 2 ══╣
      │             │
  ┌───────┐  ┌─────────┐  ┌───────┐  ┌─────────┐  ┌───────┐  ┌─────────┐  ┌─────────┐
  │ Seg 0 │··│  Bell.  │··│ Seg 1 │··│  Bell.  │··│ Seg 2 │··│  Bell.  │··│ Seg 3  ●│
  │(base) │  │(6-spoke)│  │       │  │(6-spoke)│  │       │  │(6-spoke)│  │  (tip)  │
  └───────┘  └─────────┘  └───────┘  └─────────┘  └───────┘  └─────────┘  └─────────┘

  ● = hemisphere dome cap with cable-anchor pockets
  Bellows joint = solid end-collars + 6 radial spokes (star cross-section)
  Cable bores pass through every segment and joint (palmar side, −Y)
  Elastic bore on dorsal side (+Y) returns finger to open pose
```

- **Flexion (grasp):** Servo pulls cable → bellows joints compress on palmar side → finger curls
- **Extension (release):** Servo reverses or cable slackens → elastic band springs finger open
- **Cable material:** 2 mm Dyneema braided line or 2 mm steel cable
- **Elastic material:** 1.5 mm round elastic cord

---

## Assembly Order

1. **Base frame** – Weld or bolt GI square pipe (400×300×120 mm)
2. **Motor brackets** – Print 2×, bolt motors to base corners
3. **Caster wheel** – Print 1×, bolt to rear centre
4. **Torso connectors** – Print 4×, bolt to base top and PVC torso
5. **Torso** – Insert PVC columns, route wiring internally
6. **Shoulder joints** – Print 2×, attach MG996R servos + upper arm PVC
7. **Elbow joints** – Print 2×, attach MG90S servos + forearm PVC
8. **Palm structures** – Print 2×, install MG90S servo + tendon pulley
9. **Finger segments** – Print 18 segments (9 per hand), assemble with 2 mm hinge pins
10. **Elastic anchors** – Print 8×, route elastic bands
11. **Pan-tilt mount** – Print 1×, install on top of torso
12. **Head shell + bracket** – Print head shell, mount internal bracket
13. **Wiring** – Connect all servos to PCA9685, wire to ESP32-S3

---

## Bill of Materials (3D-Printed Parts Only)

| Part | Qty | Weight | Print Time |
|------|-----|--------|------------|
| Shoulder joint bracket | 2 | 40 g | 16 min |
| Elbow joint bracket | 2 | 30 g | 12 min |
| Motor bracket | 2 | 16 g | 10 min |
| Caster wheel bracket | 1 | 12 g | 7 min |
| Pan-tilt head mount | 1 | 18 g | 10 min |
| Finger segment (Ø18 mm × 25 mm) | 12 | ~4 g ea. | ~3 min ea. |
| Bellows joint (6-spoke star) | 9 | ~1 g ea. | ~1.5 min ea. |
| Palm base (100 × 80 × 30 mm) | 1 | ~40 g | ~18 min |
| Head shell | 1 | 85 g | 25 min |
| Head internal bracket | 1 | 12 g | 8 min |
| Torso base connector | 4 | 15 g | 8 min |
| Elastic band anchor | 8 | 16 g | 16 min |
| **TOTAL** | **44** | **~385 g** | **~185 min** |

---

## Licence

These design files are provided for the purpose of building the humanoid welcoming robot described in this repository. All designs are parametric and intended for modification and adaptation.
