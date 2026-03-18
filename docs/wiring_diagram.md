# Wiring Diagram — Small Humanoid Welcoming Robot

---

## System Block Diagram

```
┌───────────────────────────────────────────────────────────────┐
│                      POWER SYSTEM                             │
│                                                               │
│  LiPo 3S 11.1 V  ──── Fuse (5 A) ──────────────────────────┐ │
│  5000 mAh (XT60)                                            │ │
│                                                             │ │
│                 ┌── 5 V / 5 A ──► PCA9685 V+ & Servo Rail  │ │
│                 │   Step-Down                                │ │
│                 │                                            │ │
│                 ├── 3.3 V / 1 A ─► ESP32-S3 3V3             │ │
│                 │   Step-Down                                │ │
│                 │                                            │ │
│                 └── 12 V direct ──► Motor Driver (12 V IN)  │ │
│                         └──────────────────────────────────◄┘ │
└───────────────────────────────────────────────────────────────┘
```

---

## ESP32-S3 Connections

```
ESP32-S3
┌──────────────────────────────────────────────────┐
│                                                  │
│  GPIO 21 (SDA) ────────────────────► PCA9685 SDA │
│  GPIO 22 (SCL) ────────────────────► PCA9685 SCL │
│  3V3           ────────────────────► PCA9685 VCC │
│  GND           ────────────────────► PCA9685 GND │
│                                                  │
│  GPIO  4 (PWM) ────────────────────► Motor Driver ENA (Left motor speed)  │
│  GPIO  5 (PWM) ────────────────────► Motor Driver ENB (Right motor speed) │
│  GPIO 14       ────────────────────► Motor Driver IN1 (Left  motor forward)   │
│  GPIO 16       ────────────────────► Motor Driver IN2 (Left  motor reverse)   │
│  GPIO 15       ────────────────────► Motor Driver IN3 (Right motor forward)   │
│  GPIO 17       ────────────────────► Motor Driver IN4 (Right motor reverse)   │
│                                                  │
│  5V (via USB/regulator) ──────────► Motor Driver logic 5 V (if required)  │
│  GND ──────────────────────────────► Motor Driver GND                     │
└──────────────────────────────────────────────────┘
```

---

## PCA9685 Servo Driver Connections

```
PCA9685 (I²C address 0x40)
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  VCC  ◄──── 3.3 V from ESP32-S3                          │
│  GND  ◄──── Common ground                                │
│  SDA  ◄──── ESP32-S3 GPIO 21                             │
│  SCL  ◄──── ESP32-S3 GPIO 22                             │
│  V+   ◄──── 5 V servo power rail (5 A step-down output) │
│                                                          │
│  CH 0  ──► Left shoulder servo  (MG996R) signal          │
│  CH 1  ──► Right shoulder servo (MG996R) signal          │
│  CH 2  ──► Left elbow servo     (MG90S)  signal          │
│  CH 3  ──► Right elbow servo    (MG90S)  signal          │
│  CH 4  ──► Head pan servo       (MG90S)  signal          │
│  CH 5  ──► Head tilt servo      (MG90S)  signal          │
│  CH 6  ──► Left hand grip servo (MG90S)  signal          │
│  CH 7  ──► Right hand grip servo(MG90S)  signal          │
│  CH 8–15  (Reserved for expansion)                       │
└──────────────────────────────────────────────────────────┘

Note: Each servo connector (3-pin) also connects:
  Red  (power) ──► 5 V servo rail
  Brown/Black (GND) ──► Common ground
```

---

## Motor Driver Connections (L298N or equivalent dual-channel H-bridge)

```
Motor Driver (L298N)
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  12V IN  ◄──── Battery main line (post-fuse, 12 V)      │
│  GND     ◄──── Common ground                            │
│  5V OUT  ──► (optional: power ESP32 5 V pin if needed)  │
│                                                         │
│  ENA     ◄──── ESP32-S3 GPIO 4  (Left  motor PWM speed) │
│  ENB     ◄──── ESP32-S3 GPIO 5  (Right motor PWM speed) │
│  IN1     ◄──── ESP32-S3 GPIO 14 (Left  motor forward)   │
│  IN2     ◄──── ESP32-S3 GPIO 16 (Left  motor reverse)   │
│  IN3     ◄──── ESP32-S3 GPIO 15 (Right motor forward)   │
│  IN4     ◄──── ESP32-S3 GPIO 17 (Right motor reverse)   │
│                                                         │
│  OUT1/OUT2 ──► Left  DC motor (+ and −)                 │
│  OUT3/OUT4 ──► Right DC motor (+ and −)                 │
└─────────────────────────────────────────────────────────┘

Motor direction logic:
  Forward:  IN1=HIGH, IN2=LOW  (left) / IN3=HIGH, IN4=LOW  (right)
  Reverse:  IN1=LOW,  IN2=HIGH (left) / IN3=LOW,  IN4=HIGH (right)
  Stop:     ENA=LOW or IN1=IN2=LOW
```

---

## Power Distribution

```
LiPo 3S 11.1 V
    │
    ├── [5 A Fuse]
    │       │
    │       ├──────────────────────────────► Motor Driver 12 V IN
    │       │
    │       ├── [5 V / 5 A Step-Down] ─────► PCA9685 V+ rail (servo power)
    │       │                           └──► All servo VCC (red wires)
    │       │
    │       └── [3.3 V / 1 A Step-Down] ──► ESP32-S3 3V3 pin
    │
    └── [GND] ─────────────────────────────► Common GND bus
                                         (all module GNDs, servo GNDs)
```

---

## Notes

1. **Servo power isolation:** The PCA9685 uses a separate V+ power rail for servo power.
   Make sure the jumper between PCA9685 VCC (logic) and V+ (servo power) is **removed** if you are supplying servo power from the 5 V step-down and logic from the 3.3 V regulator.

2. **Motor driver enable pins:** If your L298N has ENA/ENB jumpers, remove them and connect the ESP32-S3 PWM GPIO lines instead for variable speed control.

3. **Current capacity:** The 5 V servo rail must handle up to 8 servos simultaneously.
   Each MG996R can draw up to 1 A under load; MG90S up to 0.5 A.
   Total worst-case: 2 × 1 A + 6 × 0.5 A = **5 A** — use a 5 A or 6 A regulator.

4. **I²C pull-ups:** The PCA9685 module typically includes 10 kΩ pull-up resistors on SDA/SCL.
   If you see I²C communication errors, add external 4.7 kΩ pull-ups between SDA/SCL and 3.3 V.

5. **Ground loop:** Ensure all GND references (battery negative, ESP32 GND, PCA9685 GND, motor driver GND) are connected to a single common bus to avoid floating grounds.
