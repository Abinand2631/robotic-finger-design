# Small Humanoid Welcoming Robot — PVC Pipe Frame & Tendon-Driven Hand System

A complete small humanoid welcoming robot with a mobile differential drive base, lightweight PVC pipe frame, and tendon-driven robotic hands for "namaste" greeting gestures. Designed for fast prototyping with minimal 3D printing.

## System Overview

| Property | Value |
|---|---|
| Total height | ~450–500 mm (base + torso + head) |
| Total weight | ~1.85 kg |
| Drive | Differential drive (2× DC motors + caster) |
| Arms | PVC pipes + MG996R shoulder + MG90S elbow |
| Hands | 3-finger tendon-driven, single servo per hand |
| Head | Pan-tilt with 2× MG90S servos |
| Controller | ESP32-S3 + PCA9685 16-ch servo driver |
| Power | 5000 mAh 3S LiPo (~5 h typical duty) |
| BOM cost | ~$150–200 USD |
| Assembly time | 4–5 hours |

## Repository Layout

```
robotic-finger-design/
├── cad/
│   ├── fingers/          # Finger segment OpenSCAD models
│   ├── palm/             # Palm housing OpenSCAD models
│   ├── joints/           # Shoulder, elbow, caster bracket models
│   ├── head/             # Head shell & pan-tilt bracket models
│   ├── base/             # Motor mount & wheel hub models
│   └── arms/             # Arm connector bracket models
├── firmware/
│   └── humanoid_robot/   # ESP32-S3 Arduino sketch
└── docs/
    ├── bill_of_materials.md
    ├── assembly_guide.md
    └── wiring_diagram.md
```

## Quick Start

### Prerequisites
- [OpenSCAD](https://openscad.org/) ≥ 2021.01 (to render/export CAD files)
- [Arduino IDE](https://www.arduino.cc/en/software) ≥ 2.x with ESP32 board support
- Libraries: `Adafruit PWM Servo Driver Library` (PCA9685)

### Build the CAD Files
Open any `.scad` file in `cad/` with OpenSCAD and press **F6** to render, then export as STL.

### Flash the Firmware
1. Open `firmware/humanoid_robot/humanoid_robot.ino` in Arduino IDE.
2. Select board **ESP32S3 Dev Module**.
3. Install the `Adafruit PWM Servo Driver Library` via Library Manager.
4. Upload to your ESP32-S3 board.

## Parts Summary

### Servo Channels (PCA9685)
| Channel | Function | Servo |
|---|---|---|
| 0 | Left shoulder | MG996R |
| 1 | Right shoulder | MG996R |
| 2 | Left elbow | MG90S |
| 3 | Right elbow | MG90S |
| 4 | Head pan | MG90S |
| 5 | Head tilt | MG90S |
| 6 | Left hand grip | MG90S |
| 7 | Right hand grip | MG90S |

### ESP32-S3 GPIO
| GPIO | Function |
|---|---|
| 21 | I²C SDA → PCA9685 |
| 22 | I²C SCL → PCA9685 |
| 4 | Left motor PWM |
| 5 | Right motor PWM |
| 14 | Left motor forward (IN1) |
| 16 | Left motor reverse (IN2) |
| 15 | Right motor forward (IN3) |
| 17 | Right motor reverse (IN4) |

## Namaste Gesture Timeline

| Time (s) | Action |
|---|---|
| 0–2 | Shoulder servos raise arms to 90° |
| 1.5–3 | Head pans ±30° |
| 2–4 | Elbows bend to 90° |
| 3.5–5 | Head tilts forward –20° |
| 4–6 | Finger flexion 0° → 80° |
| 6–8 | Hold greeting position |
| 8–10 | Release & return to neutral |

## Documentation
- [Bill of Materials](docs/bill_of_materials.md)
- [Assembly Guide](docs/assembly_guide.md)
- [Wiring Diagram](docs/wiring_diagram.md)

## Design Philosophy
- **Fast prototyping** using PVC pipes as primary structure
- **Minimal 3D printing** (~250 g total: only joints, palms, fingers, head shell)
- **Visible mechanics** — prototyping aesthetic with functional design
- **Modular assembly** — arms and head easily swappable
- **Cost-effective** — complete robot under $200