#include <Servo.h>

// Pin definitions - YOUR SETUP
const int RAIN_SENSOR_PIN = 7;   // Digital Pin 7 (not A0)
const int SERVO_PIN = 8;         // Digital Pin 8 (not 9)
const int LED_PIN = 13;          // Built-in LED

Servo myServo;

// Variables
bool manualMode = false;
bool coverState = false; // false=open, true=closed
bool lastRainState = false;
unsigned long lastRainChangeTime = 0;
const unsigned long RAIN_CONFIRM_DELAY = 5000; // 5-second delay

void setup() {
  pinMode(RAIN_SENSOR_PIN, INPUT);
  myServo.attach(SERVO_PIN);
  Serial.begin(9600);
  
  // Start with cover open
  myServo.write(0);
  coverState = false;
  
  // Initialize rain state
  lastRainState = (digitalRead(RAIN_SENSOR_PIN) == LOW);
  
  // Send ready message
  Serial.println("SYSTEM:Rain Detector Ready with 5s Delay");
  Serial.println("SYSTEM:GUI Connected Successfully");
  
  delay(1000);
}

void loop() {
  // Check for commands from Python GUI
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    processCommand(command);
  }
  
  // Auto mode - use rain sensor with delay
  if (!manualMode) {
    checkRainWithDelay();
  }
  
  delay(100);
}

void checkRainWithDelay() {
  bool currentRainState = (digitalRead(RAIN_SENSOR_PIN) == LOW);
  unsigned long currentTime = millis();
  
  // If rain state changed
  if (currentRainState != lastRainState) {
    lastRainChangeTime = currentTime;
    lastRainState = currentRainState;
    
    if (currentRainState) {
      Serial.println("NOTIFICATION:Rain detected! Confirming in 5 seconds...");
    } else {
      Serial.println("NOTIFICATION:Rain stopped! Confirming in 5 seconds...");
    }
  }
  
  // Check if 5 seconds have passed since last change
  if (currentTime - lastRainChangeTime >= RAIN_CONFIRM_DELAY) {
    // Execute action based on confirmed rain state
    if (lastRainState && !coverState) {
      // Rain confirmed - close cover
      myServo.write(90);
      coverState = true;
      Serial.println("NOTIFICATION:CONFIRMED_RAINING - Cover CLOSED");
      // Send status update for GUI
      Serial.println("STATUS:Cover Status:CLOSED");
      Serial.println("STATUS:Rain Detection:RAINING");
    } else if (!lastRainState && coverState) {
      // No rain confirmed - open cover
      myServo.write(0);
      coverState = false;
      Serial.println("NOTIFICATION:CONFIRMED_DRY - Cover OPENED");
      // Send status update for GUI
      Serial.println("STATUS:Cover Status:OPEN");
      Serial.println("STATUS:Rain Detection:DRY");
    }
  }
}

void processCommand(String command) {
  command.toUpperCase();
  
  if (command == "OPEN") {
    manualMode = true;
    myServo.write(0);
    coverState = false;
    Serial.println("NOTIFICATION:MANUAL_OPENED - Cover opened manually");
    Serial.println("STATUS:Operation Mode:MANUAL");
    Serial.println("STATUS:Cover Status:OPEN");
  } 
  else if (command == "CLOSE") {
    manualMode = true;
    myServo.write(90);
    coverState = true;
    Serial.println("NOTIFICATION:MANUAL_CLOSED - Cover closed manually");
    Serial.println("STATUS:Operation Mode:MANUAL");
    Serial.println("STATUS:Cover Status:CLOSED");
  }
  else if (command == "AUTO") {
    manualMode = false;
    // Reset rain detection when switching to auto mode
    lastRainState = (digitalRead(RAIN_SENSOR_PIN) == LOW);
    lastRainChangeTime = millis();
    Serial.println("NOTIFICATION:AUTO_MODE - Rain detection active");
    Serial.println("STATUS:Operation Mode:AUTO");
  }
  else if (command == "STATUS") {
    // Send complete status for GUI
    Serial.println("STATUS:Arduino Connection:Connected");
    Serial.println("STATUS:Operation Mode:" + String(manualMode ? "MANUAL" : "AUTO"));
    Serial.println("STATUS:Cover Status:" + String(coverState ? "CLOSED" : "OPEN"));
    
    bool currentRain = (digitalRead(RAIN_SENSOR_PIN) == LOW);
    Serial.println("STATUS:Rain Detection:" + String(currentRain ? "RAINING" : "DRY"));
    Serial.println("STATUS:Confirmation Delay:5 seconds");
  }
  else {
    Serial.println("ERROR:Unknown command: " + command);
  }
}
