# Robotic Finger Design

This repository contains the design and implementation details for a cable-driven robotic hand.

## Overview
The project aims to create a functional model of a 3-finger cable-driven robotic hand (thumb, index, middle) that mimics the movement and dexterity of a human hand. Each finger is actuated by a small servo motor that pulls a cable routed through the finger segments, while elastic bands return the fingers to the open position.

## Features
- **Parametric OpenSCAD design** – all dimensions are variables, easy to customise
- **3-finger configuration** – thumb, index, and middle fingers
- **3 phalanx segments per finger** – proximal (40 mm), middle (25 mm), distal (20 mm)
- **Cylindrical segments** – 15 mm outer diameter, hollow for weight reduction
- **Cable-driven actuation** – 1.5 mm cable per finger routed through tendon channels
- **Servo motor mounts** – one 9 g–15 g servo (SG90/MG90S class) per finger
- **Realistic palm base** – 80 mm × 60 mm × 20 mm with knuckle bosses and wrist bolt holes
- **3D printable** – PLA or ABS, no supports required

## Main Design File

| File | Description |
|------|-------------|
| [`scad_designs/robotic_hand_3finger.scad`](scad_designs/robotic_hand_3finger.scad) | Complete 3-finger hand – palm, segments, joints, servo mounts, cable routing |

See [`scad_designs/README_SCAD.md`](scad_designs/README_SCAD.md) for the full file listing, key parameters, and print settings.

## Getting Started

1. **Install OpenSCAD** – download from [openscad.org](https://openscad.org)
2. **Open** `scad_designs/robotic_hand_3finger.scad` in OpenSCAD
3. **Press `F5`** for a fast preview, **`F6`** for a final render
4. **Export STL** with `F7` and slice with Cura, PrusaSlicer, or OrcaSlicer

## Reference
- Design inspired by cable-driven finger mechanisms – see [reference video](https://youtu.be/r62dPoS-24s)