# Arduino Hardware Setup Guide

## Overview

Your Arduino system needs these components to work with Firebase and the Flutter app:

## Hardware Components Required

### 1. **Microcontroller** (Choose One)
- **Arduino Uno** (basic, needs WiFi shield)
- **Arduino MKR WiFi 1010** (built-in WiFi) ⭐ **RECOMMENDED**
- **ESP8266** (cheap WiFi option)
- **ESP32** (most powerful, built-in WiFi)

### 2. **WiFi Module** (If using Arduino Uno)
- **Arduino WiFi Shield R3**
- **ESP8266 WiFi Module**
- **Arduino MKR WiFi Shield**

### 3. **Rain Sensor Module**
- Capacitive rain sensor module
- Analog output (0-1023)
- Operating voltage: 3.3V - 5V
- Cost: $5-15

### 4. **Servo Motor**
- Standard servo (SG90 or MG90S)
- Torque: 2-3 kg/cm minimum
- Operating voltage: 4.8V - 6V
- Cost: $5-10

### 5. **Power Supply**
- 5V USB power for Arduino
- 6V battery or power supply for servo
- Power bank works for prototyping

### 6. **Wiring & Connectors**
- Jumper wires (male-to-male, male-to-female)
- Breadboard (optional, for prototyping)
- USB cable for programming

## Wiring Diagram

```
Arduino Uno / MKR WiFi 1010
├── 5V ────────────────────────────────┐
│                                      │
├── GND ────────────────────────────────┼─────────────┐
│                                      │             │
├── A0 ──── Rain Sensor (Signal) ──────┤             │
│                                      │             │
├── Pin 9 ─ Servo (Signal) ────────────┤             │
│                                      │             │
├── SPI Pins (if using WiFi Shield)    │             │
│                                      │             │
└─ USB Power ──────────────────────────┘             │
                                                     │
                                    Servo Power ─────┘
                                    (6V external)
```

## Detailed Connections

### Rain Sensor Connection
```
Rain Sensor Module
├── VCC ──────→ Arduino 5V
├── GND ──────→ Arduino GND
└── AO (Analog Out) ──→ Arduino A0
```

**How it works:**
- Dry: ~800-1023 (high value)
- Wet: ~0-500 (low value)
- Threshold: 500 (adjustable in code)

### Servo Motor Connection
```
Servo Motor
├── Red (Power) ──────→ 6V Power Supply
├── Brown (GND) ──────→ Arduino GND (common ground)
└── Yellow (Signal) ──→ Arduino Pin 9 (PWM)
```

**Important:** Use external power for servo, not Arduino power!

### WiFi Shield Connection (if using Arduino Uno)
```
WiFi Shield
├── Stacked on top of Arduino
├── Uses SPI pins (10, 11, 12, 13)
├── Uses Pin 7 for chip select
└── Powered from Arduino 5V
```

## Complete Wiring List

| Component | Arduino Pin | Notes |
|-----------|------------|-------|
| Rain Sensor VCC | 5V | Power |
| Rain Sensor GND | GND | Ground |
| Rain Sensor Signal | A0 | Analog input |
| Servo Signal | 9 | PWM output |
| Servo Power | External 6V | NOT from Arduino |
| Servo GND | GND | Common ground |
| WiFi Shield | Stacked | SPI communication |

## Step-by-Step Assembly

### Step 1: Prepare Arduino
1. Connect USB cable to Arduino
2. Install Arduino IDE
3. Select board: Tools → Board → Arduino Uno (or your board)
4. Select port: Tools → Port → COM3 (or your port)

### Step 2: Connect Rain Sensor
1. Connect VCC (red) to Arduino 5V
2. Connect GND (black) to Arduino GND
3. Connect AO (yellow) to Arduino A0
4. Test: Open Serial Monitor, should see values 0-1023

### Step 3: Connect Servo Motor
1. **IMPORTANT:** Connect external 6V power supply
2. Connect servo GND (brown) to Arduino GND
3. Connect servo GND (brown) to 6V GND (common ground)
4. Connect servo power (red) to 6V power
5. Connect servo signal (yellow) to Arduino Pin 9
6. Test: Upload servo test code, should see movement

### Step 4: Connect WiFi Shield (if needed)
1. Stack WiFi shield on top of Arduino
2. Ensure all pins align properly
3. Connect antenna (if included)
4. Test: Upload WiFi connection code

### Step 5: Upload Arduino Code
1. Copy code from `ARDUINO_CODE.ino`
2. Update WiFi credentials:
   ```cpp
   const char* SSID = "YOUR_WIFI_SSID";
   const char* PASSWORD = "YOUR_WIFI_PASSWORD";
   ```
3. Update Firebase host:
   ```cpp
   const char* FIREBASE_HOST = "YOUR_PROJECT_ID.firebaseio.com";
   ```
4. Upload to Arduino
5. Open Serial Monitor (9600 baud) to see debug messages

## Testing

### Test 1: Rain Sensor
```cpp
// Upload this to test rain sensor
void setup() {
  Serial.begin(9600);
}

void loop() {
  int rainValue = analogRead(A0);
  Serial.println(rainValue);
  delay(1000);
}
```
Expected output: 0-1023 values, changes when wet

### Test 2: Servo Motor
```cpp
// Upload this to test servo
#include <Servo.h>

Servo servo;

void setup() {
  servo.attach(9);
}

void loop() {
  servo.write(0);    // Move to inside
  delay(2000);
  servo.write(180);  // Move to outside
  delay(2000);
}
```
Expected: Servo moves back and forth

### Test 3: WiFi Connection
```cpp
// Upload this to test WiFi
#include <WiFi.h>

const char* SSID = "YOUR_SSID";
const char* PASSWORD = "YOUR_PASSWORD";

void setup() {
  Serial.begin(115200);
  WiFi.begin(SSID, PASSWORD);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("\nConnected!");
  Serial.println(WiFi.localIP());
}

void loop() {}
```
Expected: Arduino connects to WiFi and shows IP address

## Troubleshooting

### Rain Sensor not working
- Check connections (VCC, GND, AO)
- Verify A0 is selected in code
- Test with multimeter: should show 0-5V

### Servo not moving
- Check servo power supply (6V external)
- Verify common ground (Arduino GND to servo GND)
- Check signal wire on Pin 9
- Ensure servo library is included

### WiFi not connecting
- Verify SSID and password are correct
- Check WiFi signal strength
- Ensure WiFi module is properly connected
- Try connecting to 2.4GHz WiFi (not 5GHz)

### Firebase not updating
- Check internet connection
- Verify Firebase credentials
- Check database rules allow write access
- Monitor Serial output for errors

## Power Considerations

**Arduino Power:**
- USB 5V (500mA max)
- Good for development
- Not enough for servo + WiFi

**Recommended Setup:**
- Arduino: USB 5V
- Servo: External 6V battery or power supply
- WiFi: Powered from Arduino (if shield)

**For Production:**
- Use 12V power supply
- Voltage regulator to 5V for Arduino
- Separate 6V for servo
- Capacitors for power stability

## Component Costs (Approximate)

| Component | Cost |
|-----------|------|
| Arduino MKR WiFi 1010 | $30 |
| Rain Sensor | $8 |
| Servo Motor | $8 |
| Power Supply | $10 |
| Wiring & Connectors | $5 |
| **Total** | **~$61** |

## Next Steps

1. Assemble hardware according to wiring diagram
2. Upload Arduino code with your WiFi credentials
3. Verify all components work (rain sensor, servo, WiFi)
4. Set up Firebase project
5. Update Flutter app with Firebase credentials
6. Test remote control from Flutter app

## Resources

- [Arduino Official Documentation](https://www.arduino.cc/reference/en/)
- [Servo Library](https://www.arduino.cc/reference/en/libraries/servo/)
- [WiFi Shield Documentation](https://www.arduino.cc/en/Guide/ArduinoWiFiShield)
- [Firebase Realtime Database](https://firebase.google.com/docs/database)
