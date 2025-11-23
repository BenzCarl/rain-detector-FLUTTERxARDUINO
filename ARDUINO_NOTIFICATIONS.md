# Arduino Notifications Implementation

## Overview

Your Arduino will send notifications to Firebase, which are then delivered to the Flutter app in real-time.

## Notification Flow

```
Arduino (detects event)
    ↓
Sends notification to Firebase
    ↓
Firebase stores notification
    ↓
Firebase Messaging triggers
    ↓
Flutter app receives notification
    ↓
User sees notification
```

## Arduino Code Updates

### Add Notification Function

Add this function to your Arduino code:

```cpp
// Send notification to Firebase
void sendNotification(String type, String title, String message) {
  String notifPath = String("devices/") + DEVICE_ID + "/notifications";
  
  // Create notification object
  StaticJsonDocument<200> doc;
  doc["type"] = type;
  doc["title"] = title;
  doc["message"] = message;
  doc["timestamp"] = millis();
  
  // Send to Firebase
  String json;
  serializeJson(doc, json);
  
  firebaseDB.push(notifPath, json);
  
  Serial.print("Notification sent: ");
  Serial.println(title);
}
```

### Update Rain Detection

In your `checkRainSensor()` function, add:

```cpp
void checkRainSensor() {
  rainValue = analogRead(RAIN_SENSOR_PIN);
  bool wasRaining = isRaining;
  isRaining = (rainValue < RAIN_THRESHOLD);
  
  if (isRaining != wasRaining) {
    Serial.print("Rain status changed: ");
    Serial.println(isRaining ? "RAINING" : "NO RAIN");
    
    // Send notification
    if (isRaining) {
      sendNotification(
        "rain_detected",
        "Rain Detected! 🌧️",
        "Moving clothes inside automatically"
      );
    } else {
      sendNotification(
        "rain_stopped",
        "Rain Stopped! ☀️",
        "Clothes will move outside in 1 second"
      );
    }
  }
}
```

### Update Servo Control

In `moveClothesInside()` function:

```cpp
void moveClothesInside() {
  if (!clothesOutside) return;
  
  Serial.println("Moving clothes INSIDE...");
  servo.write(SERVO_INSIDE);
  clothesOutside = false;
  delay(1000);
  
  // Send notification
  sendNotification(
    "clothes_moved_inside",
    "Clothes Moved Inside 🏠",
    "Your clothes are now protected"
  );
}
```

In `moveClothesOutside()` function:

```cpp
void moveClothesOutside() {
  if (clothesOutside) return;
  
  Serial.println("Moving clothes OUTSIDE...");
  servo.write(SERVO_OUTSIDE);
  clothesOutside = true;
  delay(1000);
  
  // Send notification
  sendNotification(
    "clothes_moved_outside",
    "Clothes Moved Outside ☀️",
    "Your clothes are now drying"
  );
}
```

### Update Auto Mode Toggle

In `toggleAutoMode()` function:

```cpp
void toggleAutoMode() {
  autoMode = !autoMode;
  Serial.print("Auto mode: ");
  Serial.println(autoMode ? "ENABLED" : "DISABLED");
  
  // Send notification
  sendNotification(
    "auto_mode_toggled",
    autoMode ? "Auto Mode Enabled 🤖" : "Auto Mode Disabled 🖱️",
    autoMode 
      ? "Auto rain detection is now active"
      : "Manual control only"
  );
}
```

## Notification Types

### 1. Rain Detected
```
Type: rain_detected
Title: Rain Detected! 🌧️
Message: Moving clothes inside automatically
Trigger: When rain sensor detects water
```

### 2. Rain Stopped
```
Type: rain_stopped
Title: Rain Stopped! ☀️
Message: Clothes will move outside in 1 second
Trigger: When rain stops (after 1 second delay)
```

### 3. Clothes Moved Inside
```
Type: clothes_moved_inside
Title: Clothes Moved Inside 🏠
Message: Your clothes are now protected
Trigger: When servo moves clothes inside
```

### 4. Clothes Moved Outside
```
Type: clothes_moved_outside
Title: Clothes Moved Outside ☀️
Message: Your clothes are now drying
Trigger: When servo moves clothes outside
```

### 5. Auto Mode Toggled
```
Type: auto_mode_toggled
Title: Auto Mode Enabled 🤖 / Disabled 🖱️
Message: Auto rain detection is now active / Manual control only
Trigger: When auto mode is toggled
```

## Firebase Database Structure

After sending notifications, your Firebase will look like:

```
devices/
└── device_001/
    ├── state/
    │   ├── isRaining: false
    │   ├── clothesOutside: true
    │   ├── rainValue: 850
    │   ├── status: "Connected"
    │   ├── autoMode: true
    │   └── lastUpdate: 1700000000000
    ├── commands/
    │   └── latest: "MOVE_INSIDE"
    └── notifications/
        ├── -NxZ1234567890/
        │   ├── type: "rain_detected"
        │   ├── title: "Rain Detected!"
        │   ├── message: "Moving clothes inside"
        │   └── timestamp: 1700000000000
        └── -NxZ0987654321/
            ├── type: "clothes_moved_inside"
            ├── title: "Clothes Moved Inside"
            ├── message: "Protected from rain"
            └── timestamp: 1700000000001
```

## Testing Notifications

### Test 1: Rain Detection
1. Upload Arduino code
2. Open Serial Monitor (115200 baud)
3. Spray water on rain sensor
4. Check Serial Monitor for: `Notification sent: Rain Detected!`
5. Check Firebase Console for new notification
6. Check Flutter app for notification

### Test 2: Rain Stopped
1. Stop spraying water
2. Wait 1 second
3. Check Serial Monitor for: `Notification sent: Rain Stopped!`
4. Check Firebase Console
5. Check Flutter app

### Test 3: Manual Control
1. Send MOVE_INSIDE command from Flutter app
2. Check Serial Monitor for: `Notification sent: Clothes Moved Inside`
3. Check Firebase Console
4. Check Flutter app

## Optimization Tips

### Reduce Notification Spam

Add debouncing to prevent too many notifications:

```cpp
unsigned long lastRainNotification = 0;
const unsigned long NOTIFICATION_DEBOUNCE = 5000; // 5 seconds

void checkRainSensor() {
  rainValue = analogRead(RAIN_SENSOR_PIN);
  bool wasRaining = isRaining;
  isRaining = (rainValue < RAIN_THRESHOLD);
  
  if (isRaining != wasRaining) {
    // Only send notification if enough time has passed
    if (millis() - lastRainNotification > NOTIFICATION_DEBOUNCE) {
      if (isRaining) {
        sendNotification("rain_detected", "Rain Detected! 🌧️", "...");
      } else {
        sendNotification("rain_stopped", "Rain Stopped! ☀️", "...");
      }
      lastRainNotification = millis();
    }
  }
}
```

### Batch Notifications

Group multiple events into one notification:

```cpp
void sendBatchNotification() {
  String message = String("Status: ") + 
                   (isRaining ? "Raining" : "Dry") + 
                   ", Clothes: " + 
                   (clothesOutside ? "Outside" : "Inside");
  
  sendNotification("status_update", "System Status", message);
}
```

### Clean Old Notifications

In Firebase Console, set up a retention policy:
- Keep only last 100 notifications
- Delete notifications older than 7 days

## Troubleshooting

### Notifications not appearing in Firebase

**Check 1: Firebase connection**
```cpp
// In Serial Monitor, verify:
// "Firebase initialized!"
// "State updated to Firebase"
```

**Check 2: Notification path**
```cpp
// Verify device ID matches
const char* DEVICE_ID = "device_001";
// Should match what's in Flutter app
```

**Check 3: Firebase rules**
```json
// Verify notifications path is writable
"notifications": {
  ".write": true,
  ".read": true
}
```

### Notifications not reaching Flutter app

**Check 1: Firebase Messaging enabled**
- Go to Firebase Console
- Verify Cloud Messaging tab shows Server API Key

**Check 2: App permissions**
- Android: Check POST_NOTIFICATIONS permission
- iOS: Check Push Notifications capability

**Check 3: Notification listeners**
- Verify NotificationService is initialized
- Check control_screen.dart has listeners set up

### Notifications delayed

- Check internet connection on Arduino
- Verify Firebase database is accessible
- Monitor Firebase Console for data flow
- Check app is connected to Firebase

## Complete Example

Here's a complete example of the notification function:

```cpp
// ============ NOTIFICATION HANDLING ============
void sendNotification(String type, String title, String message) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Cannot send notification - WiFi disconnected");
    return;
  }
  
  String notifPath = String("devices/") + DEVICE_ID + "/notifications";
  
  try {
    // Create notification
    StaticJsonDocument<256> doc;
    doc["type"] = type;
    doc["title"] = title;
    doc["message"] = message;
    doc["timestamp"] = millis();
    doc["rainValue"] = rainValue;
    doc["clothesOutside"] = clothesOutside;
    doc["autoMode"] = autoMode;
    
    // Send to Firebase
    String json;
    serializeJson(doc, json);
    firebaseDB.push(notifPath, json);
    
    Serial.print("[NOTIFICATION] ");
    Serial.print(type);
    Serial.print(" - ");
    Serial.println(title);
  } catch (Exception e) {
    Serial.print("Error sending notification: ");
    Serial.println(e.getMessage());
  }
}
```

## Next Steps

1. ✅ Add notification function to Arduino code
2. ✅ Update rain detection to send notifications
3. ✅ Update servo control to send notifications
4. ✅ Update auto mode to send notifications
5. ⏳ Upload updated code to Arduino
6. ⏳ Test notifications in Firebase Console
7. ⏳ Test notifications in Flutter app
8. ⏳ Verify all notification types work
9. ⏳ Deploy to production

## Summary

Your Arduino now sends real-time notifications for all important events:
- Rain detection
- Clothes movements
- Auto mode changes
- System status updates

All notifications are delivered via Firebase and displayed beautifully in the Flutter app!
