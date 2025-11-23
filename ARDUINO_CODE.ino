/*
 * Clothes Hanging System - Arduino Code
 * 
 * Hardware Required:
 * - Arduino Uno or compatible
 * - WiFi Shield or ESP8266/ESP32 (recommended)
 * - Rain sensor module (analog input)
 * - Servo motor (for moving clothes)
 * - Power supply
 * 
 * Connections:
 * - Rain Sensor: A0 (analog input)
 * - Servo Motor: Pin 9 (PWM)
 * - WiFi Module: SPI pins (varies by module)
 */

#include <WiFi.h>
#include <FirebaseDatabase.h>
#include <Servo.h>

// ============ CONFIGURATION ============
const char* SSID = "YOUR_WIFI_SSID";
const char* PASSWORD = "YOUR_WIFI_PASSWORD";
const char* FIREBASE_HOST = "YOUR_PROJECT_ID.firebaseio.com";
const char* DEVICE_ID = "device_001";  // Unique ID for your device

// Pin definitions
const int RAIN_SENSOR_PIN = A0;
const int SERVO_PIN = 9;
const int LED_PIN = 13;

// Servo positions
const int SERVO_INSIDE = 0;      // Clothes inside position
const int SERVO_OUTSIDE = 180;   // Clothes outside position

// Rain threshold (adjust based on your sensor)
const int RAIN_THRESHOLD = 500;  // Values below this = raining

// ============ GLOBAL VARIABLES ============
Servo servo;
FirebaseDatabase firebaseDB;
bool clothesOutside = true;
bool autoMode = true;
bool isRaining = false;
int rainValue = 0;
unsigned long lastRainCheck = 0;
unsigned long lastStateUpdate = 0;
const unsigned long RAIN_CHECK_INTERVAL = 2000;      // Check rain every 2 seconds
const unsigned long STATE_UPDATE_INTERVAL = 5000;    // Update Firebase every 5 seconds
const unsigned long AUTO_MODE_DELAY = 1000;          // 1 second delay before moving back out

// ============ SETUP ============
void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("\n\nClothes Hanging System - Starting...");
  
  // Initialize pins
  pinMode(LED_PIN, OUTPUT);
  pinMode(RAIN_SENSOR_PIN, INPUT);
  
  // Initialize servo
  servo.attach(SERVO_PIN);
  servo.write(SERVO_OUTSIDE);  // Start with clothes outside
  
  // Connect to WiFi
  connectToWiFi();
  
  // Initialize Firebase
  initializeFirebase();
  
  Serial.println("Setup complete!");
}

// ============ MAIN LOOP ============
void loop() {
  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected, reconnecting...");
    connectToWiFi();
  }
  
  // Check rain sensor
  if (millis() - lastRainCheck >= RAIN_CHECK_INTERVAL) {
    checkRainSensor();
    lastRainCheck = millis();
  }
  
  // Handle auto mode
  if (autoMode) {
    handleAutoMode();
  }
  
  // Check for commands from Firebase
  checkCommands();
  
  // Update state to Firebase
  if (millis() - lastStateUpdate >= STATE_UPDATE_INTERVAL) {
    updateStateToFirebase();
    lastStateUpdate = millis();
  }
  
  delay(100);
}

// ============ WiFi CONNECTION ============
void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(SSID);
  
  WiFi.begin(SSID, PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi connected!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    digitalWrite(LED_PIN, HIGH);  // LED on = connected
  } else {
    Serial.println("\nFailed to connect to WiFi");
    digitalWrite(LED_PIN, LOW);   // LED off = disconnected
  }
}

// ============ FIREBASE INITIALIZATION ============
void initializeFirebase() {
  Serial.println("Initializing Firebase...");
  firebaseDB.begin(FIREBASE_HOST);
  
  // Initialize device state in Firebase
  String statePath = String("devices/") + DEVICE_ID + "/state";
  firebaseDB.setString(statePath + "/status", "Connected");
  firebaseDB.setBoolean(statePath + "/clothesOutside", clothesOutside);
  firebaseDB.setBoolean(statePath + "/autoMode", autoMode);
  firebaseDB.setInt(statePath + "/rainValue", rainValue);
  firebaseDB.setBoolean(statePath + "/isRaining", isRaining);
  
  Serial.println("Firebase initialized!");
}

// ============ RAIN SENSOR CHECK ============
void checkRainSensor() {
  rainValue = analogRead(RAIN_SENSOR_PIN);
  bool wasRaining = isRaining;
  isRaining = (rainValue < RAIN_THRESHOLD);
  
  if (isRaining != wasRaining) {
    Serial.print("Rain status changed: ");
    Serial.println(isRaining ? "RAINING" : "NO RAIN");
  }
  
  Serial.print("Rain value: ");
  Serial.print(rainValue);
  Serial.print(" (");
  Serial.print(isRaining ? "RAINING" : "DRY");
  Serial.println(")");
}

// ============ AUTO MODE HANDLING ============
void handleAutoMode() {
  if (isRaining && clothesOutside) {
    // It's raining and clothes are outside - move inside
    Serial.println("Auto mode: Moving clothes inside (rain detected)");
    moveClothesInside();
  } else if (!isRaining && !clothesOutside) {
    // Not raining and clothes are inside - move outside after delay
    static unsigned long rainStoppedTime = 0;
    
    if (rainStoppedTime == 0) {
      rainStoppedTime = millis();
    }
    
    if (millis() - rainStoppedTime >= AUTO_MODE_DELAY) {
      Serial.println("Auto mode: Moving clothes outside (rain stopped)");
      moveClothesOutside();
      rainStoppedTime = 0;
    }
  } else {
    rainStoppedTime = 0;
  }
}

// ============ SERVO CONTROL ============
void moveClothesInside() {
  if (!clothesOutside) return;  // Already inside
  
  Serial.println("Moving clothes INSIDE...");
  servo.write(SERVO_INSIDE);
  clothesOutside = false;
  delay(1000);  // Wait for servo to complete
}

void moveClothesOutside() {
  if (clothesOutside) return;  // Already outside
  
  Serial.println("Moving clothes OUTSIDE...");
  servo.write(SERVO_OUTSIDE);
  clothesOutside = true;
  delay(1000);  // Wait for servo to complete
}

// ============ COMMAND HANDLING ============
void checkCommands() {
  String commandPath = String("devices/") + DEVICE_ID + "/commands";
  
  // Read the latest command
  String command = firebaseDB.getString(commandPath + "/latest");
  
  if (command.length() > 0) {
    Serial.print("Received command: ");
    Serial.println(command);
    
    if (command == "MOVE_INSIDE") {
      moveClothesInside();
    } 
    else if (command == "MOVE_OUTSIDE") {
      moveClothesOutside();
    } 
    else if (command == "TOGGLE_AUTO") {
      autoMode = !autoMode;
      Serial.print("Auto mode: ");
      Serial.println(autoMode ? "ENABLED" : "DISABLED");
    }
    
    // Clear the command
    firebaseDB.setString(commandPath + "/latest", "");
  }
}

// ============ STATE UPDATE ============
void updateStateToFirebase() {
  if (WiFi.status() != WL_CONNECTED) {
    return;  // Can't update if not connected
  }
  
  String statePath = String("devices/") + DEVICE_ID + "/state";
  
  firebaseDB.setBoolean(statePath + "/clothesOutside", clothesOutside);
  firebaseDB.setBoolean(statePath + "/autoMode", autoMode);
  firebaseDB.setInt(statePath + "/rainValue", rainValue);
  firebaseDB.setBoolean(statePath + "/isRaining", isRaining);
  firebaseDB.setString(statePath + "/status", "Connected");
  firebaseDB.setLong(statePath + "/lastUpdate", millis());
  
  Serial.println("State updated to Firebase");
}

// ============ HELPER FUNCTIONS ============
void blinkLED(int times) {
  for (int i = 0; i < times; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(100);
    digitalWrite(LED_PIN, LOW);
    delay(100);
  }
}
