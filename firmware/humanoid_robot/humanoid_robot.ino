/*
 * humanoid_robot.ino
 * ==========================================================
 * Small Humanoid Welcoming Robot — ESP32-S3 Firmware
 * ==========================================================
 * Hardware:
 *   - ESP32-S3 development board (dual-core, 240 MHz)
 *   - PCA9685 16-channel PWM servo driver (I²C)
 *   - 2 × 12 V DC motors (differential drive)
 *   - 8 servo motors (see channel map below)
 *
 * Servo Channel Map (PCA9685):
 *   CH 0 — Left shoulder  (MG996R, 10 kg·cm)
 *   CH 1 — Right shoulder (MG996R, 10 kg·cm)
 *   CH 2 — Left elbow     (MG90S,  1.8 kg·cm)
 *   CH 3 — Right elbow    (MG90S,  1.8 kg·cm)
 *   CH 4 — Head pan       (MG90S)
 *   CH 5 — Head tilt      (MG90S)
 *   CH 6 — Left hand grip (MG90S)
 *   CH 7 — Right hand grip(MG90S)
 *
 * GPIO Pin Map (ESP32-S3):
 *   GPIO 21 — I²C SDA → PCA9685
 *   GPIO 22 — I²C SCL → PCA9685
 *   GPIO  4 — Left motor PWM (speed)
 *   GPIO  5 — Right motor PWM (speed)
 *   GPIO 14 — Left motor forward (IN1)
 *   GPIO 16 — Left motor reverse (IN2)
 *   GPIO 15 — Right motor forward (IN3)
 *   GPIO 17 — Right motor reverse (IN4)
 *
 * Library requirements:
 *   Adafruit PWM Servo Driver Library (install via Library Manager)
 * ==========================================================
 */

#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

// ----------------------------------------------------------
// PCA9685 configuration
// ----------------------------------------------------------
#define PCA9685_ADDR   0x40      // default I²C address
#define PWM_FREQ_HZ    50        // standard servo PWM frequency

// Pulse width range for typical hobby servos
// Adjust SERVO_MIN / SERVO_MAX if your servos need calibration
#define SERVO_MIN_US   500       // microseconds — 0°
#define SERVO_MAX_US   2500      // microseconds — 180°

Adafruit_PWMServoDriver pca9685 = Adafruit_PWMServoDriver(PCA9685_ADDR);

// ----------------------------------------------------------
// Motor control GPIO
// ----------------------------------------------------------
#define PIN_MOTOR_L_PWM  4
#define PIN_MOTOR_R_PWM  5
#define PIN_MOTOR_L_FWD  14   // IN1 — left motor forward
#define PIN_MOTOR_L_REV  16   // IN2 — left motor reverse
#define PIN_MOTOR_R_FWD  15   // IN3 — right motor forward
#define PIN_MOTOR_R_REV  17   // IN4 — right motor reverse

// ----------------------------------------------------------
// Servo channel identifiers
// ----------------------------------------------------------
enum ServoChannel : uint8_t {
    CH_SHOULDER_L = 0,
    CH_SHOULDER_R = 1,
    CH_ELBOW_L    = 2,
    CH_ELBOW_R    = 3,
    CH_HEAD_PAN   = 4,
    CH_HEAD_TILT  = 5,
    CH_HAND_L     = 6,
    CH_HAND_R     = 7
};

// ----------------------------------------------------------
// Servo neutral (home) angles in degrees
// ----------------------------------------------------------
const int HOME_ANGLE[8] = {
    0,   // CH_SHOULDER_L  — arms down
    0,   // CH_SHOULDER_R
    0,   // CH_ELBOW_L     — arms straight
    0,   // CH_ELBOW_R
    90,  // CH_HEAD_PAN    — centred
    90,  // CH_HEAD_TILT   — level
    0,   // CH_HAND_L      — fingers open
    0    // CH_HAND_R
};

// ----------------------------------------------------------
// Helper: convert degrees [0–180] to PCA9685 tick count
// ----------------------------------------------------------
static uint16_t angleToPulse(int angle) {
    // Map angle to microseconds, then to 12-bit tick count
    // PCA9685 tick period = 1 000 000 µs / (PWM_FREQ_HZ × 4096)
    long us = map(angle, 0, 180, SERVO_MIN_US, SERVO_MAX_US);
    // tick = us / (1 000 000 / (freq × 4096))
    //      = us × freq × 4096 / 1 000 000
    return (uint16_t)(us * PWM_FREQ_HZ * 4096UL / 1000000UL);
}

// ----------------------------------------------------------
// Move a single servo to a target angle immediately
// ----------------------------------------------------------
void servoSet(ServoChannel ch, int angle) {
    angle = constrain(angle, 0, 180);
    pca9685.setPWM((uint8_t)ch, 0, angleToPulse(angle));
}

// ----------------------------------------------------------
// Smooth servo sweep from current to target angle
// duration_ms controls how long the move takes.
// Uses a simple linear interpolation with 20 ms steps.
// ----------------------------------------------------------
void servoMove(ServoChannel ch, int fromAngle, int toAngle,
               unsigned long duration_ms) {
    const unsigned long stepMs = 20;
    int steps = (int)(duration_ms / stepMs);
    if (steps < 1) steps = 1;

    for (int i = 0; i <= steps; i++) {
        int angle = fromAngle + (toAngle - fromAngle) * i / steps;
        servoSet(ch, angle);
        delay(stepMs);
    }
}

// ----------------------------------------------------------
// Motor helpers
// ----------------------------------------------------------
void motorSet(bool leftMotor, bool forward, uint8_t speed) {
    int pwmPin  = leftMotor ? PIN_MOTOR_L_PWM : PIN_MOTOR_R_PWM;
    int fwdPin  = leftMotor ? PIN_MOTOR_L_FWD : PIN_MOTOR_R_FWD;
    int revPin  = leftMotor ? PIN_MOTOR_L_REV : PIN_MOTOR_R_REV;
    digitalWrite(fwdPin, forward ? HIGH : LOW);
    digitalWrite(revPin, forward ? LOW  : HIGH);
    analogWrite(pwmPin, speed);
}

void motorStop() {
    analogWrite(PIN_MOTOR_L_PWM, 0);
    analogWrite(PIN_MOTOR_R_PWM, 0);
}

// ----------------------------------------------------------
// Return all servos to home (neutral) positions
// ----------------------------------------------------------
void gestureHome(unsigned long duration_ms = 2000) {
    // Move each servo to its home angle individually
    // For a smoother return, move them in overlapping calls.
    for (int ch = 0; ch < 8; ch++) {
        // We don't track current angles precisely; jump to home.
        servoSet((ServoChannel)ch, HOME_ANGLE[ch]);
    }
    delay(duration_ms);
}

// ----------------------------------------------------------
// "Namaste" Greeting Gesture
// ----------------------------------------------------------
// Timeline (approximate):
//   0.0 – 2.0 s  : Raise both shoulders to 90°
//   1.5 – 3.0 s  : Head pans 30° right then back (side glance)
//   2.0 – 4.0 s  : Bend both elbows to 90°
//   3.5 – 5.0 s  : Tilt head forward (tilt from 90° → 70°)
//   4.0 – 6.0 s  : Close both hands (grip 0° → 80°)
//   6.0 – 8.0 s  : Hold greeting position
//   8.0 – 10.0 s : Release in reverse order
// ----------------------------------------------------------
void gestureNamaste() {
    // --- Phase 1: Raise shoulders (0° → 90°, 2 s) -----------
    // Both shoulders move simultaneously
    // We use a manual loop to update both channels in lockstep
    const unsigned long raiseDuration = 2000;
    const unsigned long stepMs = 20;
    int raiseSteps = (int)(raiseDuration / stepMs);
    for (int i = 0; i <= raiseSteps; i++) {
        int ang = map(i, 0, raiseSteps, 0, 90);
        servoSet(CH_SHOULDER_L, ang);
        servoSet(CH_SHOULDER_R, ang);
        delay(stepMs);
    }

    delay(500); // brief pause before next phase

    // --- Phase 2: Head pan left-right + elbow bend -----------
    // Run elbow bend while head pans (overlapping, 2 s each)
    const unsigned long elbowDuration = 2000;
    int elbowSteps = (int)(elbowDuration / stepMs);

    // Head pan: 90° → 120° → 60° → 90° (left-right sweep)
    // We interleave head pan with elbow movement
    for (int i = 0; i <= elbowSteps; i++) {
        int elbowAng = map(i, 0, elbowSteps, 0, 90);
        servoSet(CH_ELBOW_L, elbowAng);
        servoSet(CH_ELBOW_R, elbowAng);

        // Head pan oscillates: 90 → 120 → 60 → 90 over the duration
        int panAng;
        if (i < elbowSteps / 3) {
            panAng = map(i, 0, elbowSteps / 3, 90, 120);
        } else if (i < 2 * elbowSteps / 3) {
            panAng = map(i, elbowSteps / 3, 2 * elbowSteps / 3, 120, 60);
        } else {
            panAng = map(i, 2 * elbowSteps / 3, elbowSteps, 60, 90);
        }
        servoSet(CH_HEAD_PAN, panAng);

        delay(stepMs);
    }

    delay(500);

    // --- Phase 3: Head tilt forward (90° → 70°, 1.5 s) ------
    servoMove(CH_HEAD_TILT, 90, 70, 1500);

    delay(300);

    // --- Phase 4: Close hands (0° → 80°, 2 s) ---------------
    const unsigned long gripDuration = 2000;
    int gripSteps = (int)(gripDuration / stepMs);
    for (int i = 0; i <= gripSteps; i++) {
        int gripAng = map(i, 0, gripSteps, 0, 80);
        servoSet(CH_HAND_L, gripAng);
        servoSet(CH_HAND_R, gripAng);
        delay(stepMs);
    }

    // --- Phase 5: Hold greeting position (2 s) ---------------
    delay(2000);

    // --- Phase 6: Release — reverse order --------------------
    // 6a. Open hands
    const unsigned long openDuration = 1500;
    int openSteps = (int)(openDuration / stepMs);
    for (int i = 0; i <= openSteps; i++) {
        int gripAng = map(i, 0, openSteps, 80, 0);
        servoSet(CH_HAND_L, gripAng);
        servoSet(CH_HAND_R, gripAng);
        delay(stepMs);
    }

    delay(500);

    // 6b. Straighten elbows + reset head tilt
    const unsigned long lowerElbow = 2000;
    int lowerSteps = (int)(lowerElbow / stepMs);
    for (int i = 0; i <= lowerSteps; i++) {
        int elbowAng = map(i, 0, lowerSteps, 90, 0);
        servoSet(CH_ELBOW_L, elbowAng);
        servoSet(CH_ELBOW_R, elbowAng);
        // Restore head tilt
        int tiltAng = map(i, 0, lowerSteps, 70, 90);
        servoSet(CH_HEAD_TILT, tiltAng);
        delay(stepMs);
    }

    delay(300);

    // 6c. Lower shoulders
    const unsigned long lowerShoulder = 3000;
    int lowerShSteps = (int)(lowerShoulder / stepMs);
    for (int i = 0; i <= lowerShSteps; i++) {
        int ang = map(i, 0, lowerShSteps, 90, 0);
        servoSet(CH_SHOULDER_L, ang);
        servoSet(CH_SHOULDER_R, ang);
        delay(stepMs);
    }
}

// ----------------------------------------------------------
// setup()
// ----------------------------------------------------------
void setup() {
    Serial.begin(115200);
    Serial.println("[BOOT] Humanoid Welcoming Robot — ESP32-S3");

    // I²C for PCA9685
    Wire.begin(21, 22);  // SDA = GPIO21, SCL = GPIO22

    // Initialise PCA9685
    pca9685.begin();
    pca9685.setPWMFreq(PWM_FREQ_HZ);
    delay(10);

    // Motor GPIO
    pinMode(PIN_MOTOR_L_PWM, OUTPUT);
    pinMode(PIN_MOTOR_R_PWM, OUTPUT);
    pinMode(PIN_MOTOR_L_FWD, OUTPUT);
    pinMode(PIN_MOTOR_L_REV, OUTPUT);
    pinMode(PIN_MOTOR_R_FWD, OUTPUT);
    pinMode(PIN_MOTOR_R_REV, OUTPUT);

    // Move all servos to home positions
    Serial.println("[INIT] Homing all servos...");
    gestureHome(1500);

    Serial.println("[READY] Robot ready. Starting greeting gesture.");
}

// ----------------------------------------------------------
// loop()
// ----------------------------------------------------------
void loop() {
    // Perform greeting gesture
    gestureNamaste();

    // Wait 5 seconds before repeating
    Serial.println("[GESTURE] Namaste complete. Waiting 5 s...");
    delay(5000);
}
