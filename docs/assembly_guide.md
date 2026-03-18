# Assembly Guide — Small Humanoid Welcoming Robot

Estimated total assembly time: **4–5 hours**

---

## Tools Required

- Hacksaw or PVC pipe cutter
- Hand drill + 2 mm, 3.5 mm, 4.5 mm bits
- Flathead & Phillips screwdrivers
- Hex/Allen key set (M3, M4)
- Wire stripper & crimping tool
- Soldering iron + solder
- Zip ties (provided in BOM)
- Hot glue gun (optional, for cable management)
- Multimeter (for wiring verification)

---

## Phase 1 — Base Assembly (~30 minutes)

### 1.1 Cut PVC Base Frame
Cut two lengths of 20 mm PVC pipe to 200 mm (longitudinal rails).
Cut two lengths to 180 mm (lateral cross-members).
Use PVC tee-joints or 3D-printed corner brackets to form a rectangular frame.

### 1.2 Mount DC Motors
Print two `motor_mount_bracket.scad` parts.
Clamp each motor into the bracket and bolt to the base frame lateral members with M4 bolts.
Motor shafts should extend outward (left and right).

### 1.3 Attach Wheels
Press the printed `wheel_hub_adapter.scad` onto each motor shaft (8 mm bore, light interference fit).
Tighten the grub/set screw (M3) to lock the hub.
Bolt the 120 mm rubber wheels to the hub spoke disc with M3 bolts.

### 1.4 Install Caster Wheel
Print `caster_wheel_bracket.scad`.
Bolt the caster bracket to the front of the base deck with M4 bolts (4 holes pattern).
Insert the 50 mm swivel caster wheel into the fork and secure with the 5 mm axle bolt.

### 1.5 Install Base Deck
Cut a 200 × 180 mm piece of 3 mm plywood.
Drill M4 clearance holes at the motor and caster bracket bolt positions.
Secure the deck on top of the PVC frame with M4 bolts.

### 1.6 Mount Electronics (Base)
Mount the motor driver module centrally on the base deck.
Mount the LiPo battery on the base deck using hook-and-loop (velcro) straps or a printed battery tray.
Connect XT60 main power connector between battery and fuse holder.

---

## Phase 2 — Torso Assembly (~45 minutes)

### 2.1 Build PVC Torso Frame
Cut four vertical PVC columns (20 mm pipe × 300 mm each).
Cut two lateral cross-braces (20 mm pipe × 140 mm each) for upper and lower torso levels.
Join with printed or PVC elbow/tee fittings at each corner to form a rectangular 3D frame.

### 2.2 Attach Torso to Base
Secure the four vertical columns to the base deck corners using M4 bolts through printed PVC collars or standard PVC floor flanges.

### 2.3 Mount Electronics Tray
Print or cut a flat mounting tray (plywood or 3 mm PETG sheet).
Secure inside the torso frame at mid-height (~150 mm from base).
Mount ESP32-S3 board, PCA9685 servo driver, and 5 V/3.3 V regulators on the tray using M3 standoffs.

### 2.4 Power Distribution
Connect 5 V step-down output to PCA9685 VCC and servo power rail.
Connect 3.3 V step-down output to ESP32-S3 3V3 pin.
Connect all grounds to a common ground bus.
Run 12 V directly from battery through fuse to motor driver.

---

## Phase 3 — Arm Assembly (~60 minutes)

### 3.1 Cut Arm PVC Pipes
Upper arm: 20 mm PVC × 150 mm (2 pieces, left and right).
Forearm: 20 mm PVC × 140 mm (2 pieces, left and right).

### 3.2 Shoulder Joint
Print two `shoulder_joint_bracket.scad` parts.
Insert MG996R servo into the clamp on the bracket.
Tighten the two M3 clamp bolts to secure the servo.
Attach the servo horn (cross type) with the supplied horn screw.
Slide the upper-arm PVC pipe into the collar on the other side and tighten the M3 clamp bolt.
Bolt the bracket to the top of the torso frame using M4 bolts.

### 3.3 Elbow Joint
Print two `elbow_joint_bracket.scad` parts.
Insert MG90S servo into the bracket pocket and secure with M2.5 screws.
Slide the upper-arm distal end into the fixed collar; slide the forearm into the pivot collar.
The pivot collar connects to the servo output horn so the forearm rotates with the servo.

### 3.4 Arm Connector Brackets
Print four `arm_connector_bracket.scad` parts.
Attach at each end of the arm PVC pipes to provide a secure mechanical connection to the joint brackets.

### 3.5 Test Range of Motion
Manually rotate each servo horn through its range.
Upper arm should raise and lower freely (0°–180°).
Forearm should flex/extend freely at the elbow.
Ensure there is no binding or cable fouling.

---

## Phase 4 — Head Assembly (~30 minutes)

### 4.1 Print Head Parts
Print `head_shell.scad` as two halves (front and rear, split at the vertical centre plane).
Print `pan_tilt_bracket.scad`.

### 4.2 Install Pan-Tilt Servos
Insert the lower MG90S (pan servo) into the pan servo pocket of the pan-tilt bracket.
Insert the upper MG90S (tilt servo) into the tilt servo pocket.
Secure with M2.5 screws through the tab mounting ears.

### 4.3 Assemble Head Shell
Route servo wires through the rear hatch opening.
Glue or snap the two head shell halves together around the pan-tilt bracket.
Optionally, glue 10 mm LEDs into the eye sockets for visual indicators.

### 4.4 Attach Neck
Cut a 40 mm length of 15 mm PVC pipe for the neck.
Insert the neck pipe into the neck socket at the bottom of the head shell.
Insert the other end into the neck boss on top of the torso frame.

### 4.5 Test Head Motion
Connect pan and tilt servos to PCA9685 channels 4 and 5 and test with a simple sweep.

---

## Phase 5 — Hand Assembly (~90 minutes)

### 5.1 Print Finger Segments
Print 3× `finger_segment_proximal.scad`, 3× `finger_segment_middle.scad`, 3× `finger_segment_distal.scad` per hand (18 segments total for both hands).

### 5.2 Assemble Finger Chains
Align proximal + middle + distal segments end-to-end.
Thread a 2 mm metal pin through the aligned hinge holes at each joint (one pin per joint = two pins per three-segment finger).
Bend the pin ends slightly or apply a drop of CA glue to retain.

### 5.3 Route Tendons
Cut three lengths of 0.3 mm fishing line, ~250 mm each.
Thread each line through the top hole of the distal, middle, and proximal segments of one finger (running from fingertip toward palm).
Leave ~80 mm of line extending from the proximal end to connect to the servo pulley.

### 5.4 Install Elastic Return Bands
Cut six lengths of 1.5 mm elastic cord, ~60 mm each (two per finger).
Thread each through one bottom hole of each segment and tie off at the distal end.
Pull snug and tie at the proximal end so the elastic provides extension force.
Elastic tension should be enough to open the finger but not overpower the servo (~200–300 g force).

### 5.5 Print and Assemble Palm
Print `palm_structure.scad`.
Insert MG90S servo into the servo bay, with the servo horn facing upward toward the tendon pulley exit.
Secure with the servo's self-tapping screws through the palm structure tabs.
Thread the three tendons through the internal channels in the palm (routed from finger socket exits to the servo horn area).
Tie or crimp all three tendon lines to the servo horn (equally spaced, so all three fingers flex simultaneously).

### 5.6 Mount Fingers to Palm
Insert the proximal lug of each finger into its socket on the palm distal face.
Push a 2 mm pin through the palm pin hole and finger lug hole to secure.

### 5.7 Attach Hands to Forearms
Slide the palm PVC receiver socket onto the distal end of the forearm PVC pipe.
Secure with one M3 bolt through the collar.

---

## Phase 6 — Wiring & Testing (~60 minutes)

### 6.1 Servo Wiring
Connect servo signal wires to PCA9685:

| Servo | PCA9685 Channel | Signal colour |
|---|---|---|
| Left shoulder (MG996R) | CH 0 | Orange/Yellow |
| Right shoulder (MG996R) | CH 1 | Orange/Yellow |
| Left elbow (MG90S) | CH 2 | Orange/Yellow |
| Right elbow (MG90S) | CH 3 | Orange/Yellow |
| Head pan (MG90S) | CH 4 | Orange/Yellow |
| Head tilt (MG90S) | CH 5 | Orange/Yellow |
| Left hand (MG90S) | CH 6 | Orange/Yellow |
| Right hand (MG90S) | CH 7 | Orange/Yellow |

Connect servo power (red) and ground (brown/black) to the PCA9685 5 V rail.

### 6.2 I²C Wiring
Connect ESP32-S3 GPIO 21 (SDA) → PCA9685 SDA.
Connect ESP32-S3 GPIO 22 (SCL) → PCA9685 SCL.
Connect ESP32-S3 GND → PCA9685 GND.
Connect ESP32-S3 3.3 V → PCA9685 VCC (logic).

### 6.3 Motor Driver Wiring
Connect motor driver IN1/IN2 → ESP32-S3 GPIO 14/15 (direction).
Connect motor driver ENA → ESP32-S3 GPIO 4 (left motor PWM).
Connect motor driver ENB → ESP32-S3 GPIO 5 (right motor PWM).
Connect motor driver 12 V power from battery main line (post-fuse).
Connect left motor wires to motor driver OUT1/OUT2.
Connect right motor wires to motor driver OUT3/OUT4.

### 6.4 Flash Firmware
Open `firmware/humanoid_robot/humanoid_robot.ino` in Arduino IDE.
Select board **ESP32S3 Dev Module**, correct COM port.
Install **Adafruit PWM Servo Driver Library** via Tools → Manage Libraries.
Click Upload.

### 6.5 Calibration
After flashing, watch the serial monitor at 115200 baud.
Verify "Homing all servos..." appears and all servos move to neutral.
Adjust `SERVO_MIN_US` and `SERVO_MAX_US` in the sketch if any servo does not reach 0° or 180° correctly.
Verify the "Namaste complete" message prints after each gesture cycle.

### 6.6 Full System Test
Power cycle the robot.
Confirm the greeting gesture completes without binding.
Confirm fingers close and open smoothly.
Confirm the head pans and tilts correctly.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Servo twitches at neutral | Incorrect PWM calibration | Adjust `SERVO_MIN_US`/`SERVO_MAX_US` |
| Finger does not close fully | Tendon too long or slack | Shorten tendon and retie |
| Finger does not open | Elastic too weak or tendon too tight | Replace elastic or loosen tendon |
| Head does not move | I²C address mismatch | Check PCA9685 A0–A5 solder bridges (default 0x40) |
| Motors do not turn | Motor driver not enabled | Check EN pin connections and motor driver power |
| Robot tips forward | Centre of mass too far forward | Move battery rearward or add ballast to rear |
