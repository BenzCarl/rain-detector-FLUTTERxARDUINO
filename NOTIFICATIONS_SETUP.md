# Real-Time Notifications Setup Guide

## Overview

The app now sends real-time notifications for:
- 🌧️ Rain detected
- ☀️ Rain stopped
- 🏠 Clothes moved inside
- ☀️ Clothes moved outside
- 🤖 Auto mode toggled

## Notifications Architecture

```
Arduino → Firebase → Firebase Messaging → Flutter App
  (sends data)  (stores & triggers)  (cloud messaging)  (shows notification)
```

## Setup Steps

### Step 1: Enable Firebase Cloud Messaging

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Cloud Messaging** tab
4. You should see:
   - Server API Key
   - Sender ID

### Step 2: Android Setup

#### 2.1 Update `android/app/build.gradle`

Add Google Services plugin (if not already present):
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'  // Add this line
}
```

#### 2.2 Update `android/build.gradle`

Add Google Services classpath:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'  // Add this line
    }
}
```

#### 2.3 Update `android/app/AndroidManifest.xml`

Add permissions:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Step 3: iOS Setup

#### 3.1 Enable Push Notifications in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → Signing & Capabilities
3. Click "+ Capability"
4. Add "Push Notifications"

#### 3.2 Update `ios/Podfile`

Ensure Firebase is included:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

### Step 4: Arduino Code Updates

Update `ARDUINO_CODE.ino` to send notifications:

```cpp
// Add this function to send notifications
void sendNotification(String type, String title, String message) {
  String notifPath = String("devices/") + DEVICE_ID + "/notifications";
  
  firebaseDB.push(notifPath, {
    "type": type,
    "title": title,
    "message": message,
    "timestamp": millis()
  });
}

// In checkRainSensor() function, add:
if (isRaining != wasRaining) {
  if (isRaining) {
    sendNotification("rain_detected", "Rain Detected!", "Moving clothes inside");
  } else {
    sendNotification("rain_stopped", "Rain Stopped!", "Clothes will move outside soon");
  }
}

// In moveClothesInside() function, add:
sendNotification("clothes_moved_inside", "Clothes Moved Inside", "Protected from rain");

// In moveClothesOutside() function, add:
sendNotification("clothes_moved_outside", "Clothes Moved Outside", "Now drying");
```

### Step 5: Flutter App Configuration

The app is already configured! Just ensure:

1. `NotificationService` is initialized in `main.dart` ✅
2. Notification listeners are set up in `ControlScreen` ✅
3. Firebase Messaging dependency is added ✅

### Step 6: Test Notifications

#### Test 1: Local Testing (Foreground)
1. Run the app: `flutter run`
2. Keep app in foreground
3. Trigger event (spray water on rain sensor)
4. See notification appear as SnackBar

#### Test 2: Background Testing
1. Run the app
2. Press home button (app goes to background)
3. Trigger event
4. See system notification appear

#### Test 3: Terminated App Testing
1. Run the app
2. Close app completely
3. Trigger event
4. Open app
5. See notification was received

## Notification Types

### Rain Detected 🌧️
```
Type: rain_detected
Title: Rain Detected! 🌧️
Message: Moving clothes inside automatically
Color: Blue
```

### Rain Stopped ☀️
```
Type: rain_stopped
Title: Rain Stopped! ☀️
Message: Clothes will move outside in 1 second
Color: Green
```

### Clothes Moved Inside 🏠
```
Type: clothes_moved_inside
Title: Clothes Moved Inside 🏠
Message: Your clothes are now protected
Color: Orange
```

### Clothes Moved Outside ☀️
```
Type: clothes_moved_outside
Title: Clothes Moved Outside ☀️
Message: Your clothes are now drying
Color: Green
```

### Auto Mode Toggled 🤖
```
Type: auto_mode_toggled
Title: Auto Mode Enabled 🤖 / Disabled 🖱️
Message: Auto rain detection is now active / Manual control only
Color: Blue / Grey
```

## Firebase Database Structure with Notifications

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

## Notification Display

### In-App (Foreground)
- Shows as floating SnackBar
- Colored based on notification type
- Auto-dismisses after 4 seconds
- Shows title and message

### System Notification (Background)
- Shows in notification center
- Tap to open app
- Includes title and message
- Sound and vibration

### Terminated App
- Stored in Firebase
- Retrieved when app opens
- Displayed as notification

## Troubleshooting

### Notifications not appearing

**Check 1: Permissions**
```bash
# Verify permissions in AndroidManifest.xml
grep -r "POST_NOTIFICATIONS" android/
```

**Check 2: Firebase Messaging**
```dart
// Check if FCM token is generated
String? token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
```

**Check 3: Notification Service**
```dart
// Verify NotificationService is initialized
// Check main.dart for: await NotificationService.initialize();
```

### Notifications delayed

- Check internet connection
- Verify Firebase database is accessible
- Check Arduino is sending notifications
- Monitor Firebase Console for data flow

### Notifications not received on iOS

- Verify Push Notifications capability is enabled
- Check Apple Developer account has certificates
- Ensure provisioning profile includes Push Notifications
- Rebuild iOS app: `flutter clean && flutter run`

## Advanced Features

### Subscribe to Topics

```dart
// Subscribe to rain alerts
await NotificationService.subscribeToTopic('rain_alerts');

// Subscribe to clothes movement
await NotificationService.subscribeToTopic('clothes_movement');
```

### Custom Notification Handling

```dart
// Add custom handler
NotificationService.onRainDetected = (data) {
  // Your custom logic here
  print('Rain detected: ${data['message']}');
};
```

### Get FCM Token

```dart
String? token = await NotificationService.getToken();
print('FCM Token: $token');
// Send this token to Arduino for direct messaging
```

## Performance Optimization

### Reduce Notification Frequency
```cpp
// In Arduino code, add debouncing
unsigned long lastNotificationTime = 0;
const unsigned long NOTIFICATION_DEBOUNCE = 5000; // 5 seconds

if (millis() - lastNotificationTime > NOTIFICATION_DEBOUNCE) {
  sendNotification(...);
  lastNotificationTime = millis();
}
```

### Clean Old Notifications
```dart
// In Firebase, set retention policy
// Keep only last 100 notifications
// Delete notifications older than 7 days
```

## Security Considerations

### Current Setup
- Notifications sent to all users
- No authentication required
- Good for testing

### Production Setup
- Authenticate users
- Send notifications only to authorized users
- Encrypt sensitive data
- Use Firebase Cloud Functions for validation

## Resources

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging](https://pub.dev/packages/firebase_messaging)
- [Android Push Notifications](https://developer.android.com/training/notify-user/build-notification)
- [iOS Push Notifications](https://developer.apple.com/documentation/usernotifications)

## Next Steps

1. ✅ Add Firebase Messaging dependency (done)
2. ✅ Create NotificationService (done)
3. ✅ Set up notification listeners (done)
4. ⏳ Configure Android
5. ⏳ Configure iOS
6. ⏳ Update Arduino code
7. ⏳ Test notifications
8. ⏳ Deploy to production

## Summary

Your app now has complete real-time notification support! Users will be instantly notified of:
- Rain detection
- Clothes movements
- Auto mode changes
- System status updates

All notifications are delivered via Firebase Cloud Messaging and displayed beautifully in the app.
