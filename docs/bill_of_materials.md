# Bill of Materials — Small Humanoid Welcoming Robot

All prices are approximate USD estimates (2024).  Total BOM cost: **~$150–200**.

---

## Structural Components

| Item | Specification | Qty | Unit cost | Total |
|---|---|---|---|---|
| PVC pipe, 20 mm schedule 40 | 20 mm OD, 3 m total | 1 length | $5 | $5 |
| PVC pipe, 15 mm schedule 40 | 15 mm OD, 1 m total (neck) | 1 length | $3 | $3 |
| Aluminum L-brackets | 20 × 20 × 2 mm, assorted | 10 | $0.50 | $5 |
| Stainless M3 hex bolt set | M3 × 8/10/12 mm + nuts | 1 kit | $5 | $5 |
| Stainless M4 hex bolt set | M4 × 10/16 mm + nuts | 1 kit | $4 | $4 |
| Base deck plate | 3 mm plywood, 200 × 180 mm | 1 | $2 | $2 |
| Zip ties | 100 mm, nylon, pack of 100 | 1 pack | $2 | $2 |

---

## 3D-Printed Parts (~250 g PLA total)

| Part | File | Qty | Est. mass (g) | Print time (min) |
|---|---|---|---|---|
| Finger segment — proximal | `cad/fingers/finger_segment_proximal.scad` | 6 (3L+3R) | 4 each | 20 |
| Finger segment — middle | `cad/fingers/finger_segment_middle.scad` | 6 | 3 each | 15 |
| Finger segment — distal | `cad/fingers/finger_segment_distal.scad` | 6 | 2 each | 12 |
| Palm structure (left) | `cad/palm/palm_structure.scad` | 1 | 25 | 45 |
| Palm structure (right) | `cad/palm/palm_structure.scad` (mirrored) | 1 | 25 | 45 |
| Shoulder joint bracket | `cad/joints/shoulder_joint_bracket.scad` | 2 | 20 each | 35 |
| Elbow joint bracket | `cad/joints/elbow_joint_bracket.scad` | 2 | 15 each | 25 |
| Head shell (2-part) | `cad/head/head_shell.scad` | 1 set | 80 | 120 |
| Pan-tilt bracket | `cad/head/pan_tilt_bracket.scad` | 1 | 18 | 30 |
| Motor mount bracket | `cad/base/motor_mount_bracket.scad` | 2 | 8 each | 15 |
| Caster wheel bracket | `cad/base/caster_wheel_bracket.scad` | 1 | 10 | 20 |
| Wheel hub adapter | `cad/base/wheel_hub_adapter.scad` | 2 | 6 each | 12 |
| Arm connector bracket | `cad/arms/arm_connector_bracket.scad` | 4 | 5 each | 10 |
| **Total 3D-printed** | | | **~249 g** | **~5.5 h** |

**Recommended print settings:** PLA, 0.2 mm layer height, 80 % infill (structural parts), 15 % infill (head shell), no supports required.

---

## Servo Motors

| Item | Model | Qty | Unit cost | Total |
|---|---|---|---|---|
| High-torque servo — shoulder | MG996R (10–13 kg·cm @ 6 V) | 2 | $7 | $14 |
| Micro servo — elbow, head, hand | MG90S (1.8 kg·cm @ 4.8 V) | 6 | $3.50 | $21 |
| **Servo subtotal** | | **8** | | **~$35** |

---

## Drive System

| Item | Specification | Qty | Unit cost | Total |
|---|---|---|---|---|
| 12 V DC geared motor with encoder | 150–200 RPM, ~25 mm body, 8 mm shaft | 2 | $9 | $18 |
| Rubber wheels, 120 mm | With tyre, 8 mm bore | 2 | $6 | $12 |
| Swivel caster wheel, 50 mm | Standard ball caster | 1 | $4 | $4 |
| **Drive subtotal** | | | | **~$34** |

---

## Electronics

| Item | Specification | Qty | Unit cost | Total |
|---|---|---|---|---|
| ESP32-S3 dev board | 240 MHz dual-core, WiFi + BT, USB-C | 1 | $8 | $8 |
| PCA9685 servo driver | 16-ch PWM, I²C, 5 V logic | 1 | $4 | $4 |
| LiPo battery | 5000 mAh 3S (11.1 V), XT60 | 1 | $25 | $25 |
| LiPo balance charger | 2 A, 3S compatible | 1 | $12 | $12 |
| DC motor driver | Dual-channel 2 × 15 A (e.g. L298N module) | 1 | $5 | $5 |
| Step-down regulator 5 V / 5 A | For servos (LM2596 or XL4016 module) | 1 | $3 | $3 |
| Step-down regulator 3.3 V / 1 A | For ESP32 logic (LM1117 or AMS1117) | 1 | $1 | $1 |
| XT60 connector pair | Battery main connector | 2 | $1 | $2 |
| JST-XH 3-pin connectors | Servo leads | 20 | $0.10 | $2 |
| Fuse holder + 5 A fuse | Main battery fuse | 1 | $2 | $2 |
| Hook-up wire, 18 AWG | Motor power lines, 1 m each colour | 1 set | $4 | $4 |
| Hook-up wire, 24 AWG | Signal lines, assorted | 1 set | $3 | $3 |
| **Electronics subtotal** | | | | **~$71** |

---

## Hand Mechanism

| Item | Specification | Qty | Unit cost | Total |
|---|---|---|---|---|
| Fishing line, 0.3 mm | ~5 m per hand (tendons) | 1 spool | $3 | $3 |
| Elastic cord, 1.5 mm | ~10 m (elastic return bands) | 1 spool | $3 | $3 |
| Metal hinge pins, 2 mm | 50 mm length (cut to size) | 20 | $0.10 | $2 |
| **Hand subtotal** | | | | **~$8** |

---

## Grand Total

| Category | Cost |
|---|---|
| Structural | ~$26 |
| 3D-printed (filament only, ~250 g) | ~$5 |
| Servos | ~$35 |
| Drive system | ~$34 |
| Electronics | ~$71 |
| Hand mechanism | ~$8 |
| **Total** | **~$179** |

> Prices vary by supplier. Buying from AliExpress/Banggood can reduce the total to ~$130; retail hobby shops may bring it to ~$220.
