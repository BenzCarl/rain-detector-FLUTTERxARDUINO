# Firebase Setup Guide

This guide will help you set up Firebase for remote control of your clothes hanging system.

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: `clothes-remote-control`
4. Accept the terms and click **"Create project"**
5. Wait for the project to be created

## Step 2: Enable Realtime Database

1. In Firebase Console, go to **"Build"** → **"Realtime Database"**
2. Click **"Create Database"**
3. Choose location closest to you
4. Select **"Start in test mode"** (for development)
5. Click **"Enable"**

## Step 3: Set Database Rules

1. Go to **"Realtime Database"** → **"Rules"** tab
2. Replace the rules with:

```json
{
  "rules": {
    "devices": {
      "$deviceId": {
        ".read": true,
        ".write": true,
        "state": {
          ".validate": "newData.hasChildren(['isRaining', 'clothesOutside', 'rainValue', 'status', 'autoMode'])"
        },
        "commands": {
          ".indexOn": ["timestamp"]
        }
      }
    }
  }
}
```

3. Click **"Publish"**

## Step 4: Get Firebase Credentials

### For Android:

1. In Firebase Console, click **"Project Settings"** (gear icon)
2. Go to **"Your apps"** section
3. Click **"Android"** to add Android app
4. Enter package name: `com.example.clothes_remote_control`
5. Download `google-services.json`
6. Place it in `android/app/` directory

### For iOS:

1. Click **"iOS"** to add iOS app
2. Enter bundle ID: `com.example.clothesRemoteControl`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Add the plist file to the project

### For Web:

1. Click **"Web"** to add web app
2. Copy the config object
3. Update `lib/firebase_options.dart` with the credentials

## Step 5: Update Firebase Options

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with your Firebase credentials:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',           // From google-services.json
  appId: 'YOUR_ANDROID_APP_ID',             // From google-services.json
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',             // From Firebase Console
  databaseURL: 'https://YOUR_PROJECT_ID.firebaseio.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

## Step 6: Update Flutter App

1. Run `flutter pub get` to install Firebase packages
2. The app will now use Firebase for remote control

## Firebase Database Structure

Your database will look like this:

```
devices/
  ├── device_001/
  │   ├── state/
  │   │   ├── isRaining: false
  │   │   ├── clothesOutside: true
  │   │   ├── rainValue: 800
  │   │   ├── status: "Ready"
  │   │   ├── autoMode: true
  │   │   └── lastUpdate: 1700000000000
  │   └── commands/
  │       ├── -NxZ1234567890/
  │       │   ├── command: "MOVE_INSIDE"
  │       │   └── timestamp: 1700000000000
  │       └── -NxZ0987654321/
  │           ├── command: "MOVE_OUTSIDE"
  │           └── timestamp: 1700000000001
```

## How It Works

1. **Arduino** reads commands from `devices/{deviceId}/commands/`
2. **Arduino** updates state in `devices/{deviceId}/state/`
3. **Flutter App** listens to state changes in real-time
4. **Flutter App** sends commands to `devices/{deviceId}/commands/`

## Testing

1. Open the app
2. The app will try local WiFi first
3. If local fails, it will use Firebase
4. You can control the device from anywhere in the world

## Troubleshooting

**Firebase not connecting:**
- Check internet connection
- Verify Firebase credentials in `firebase_options.dart`
- Check Firebase database rules are correct
- Ensure Arduino is sending data to Firebase

**Commands not working:**
- Check if Arduino is listening to commands
- Verify device ID matches in Arduino code
- Check Firebase database rules allow write access

**Real-time updates not working:**
- Ensure `keepSynced(true)` is enabled
- Check internet connection
- Verify database path is correct
