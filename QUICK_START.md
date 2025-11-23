# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### For Testing WITHOUT Arduino (Mock Mode)

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app
flutter run

# 3. Test the UI
# - Click "Move Inside" button
# - Click "Move Outside" button
# - Toggle "Auto Rain Detection"
# - Check sensor readings
```

**Status:** App works in mock mode without any hardware!

---

## 🏗️ Full Setup with Arduino & Firebase

### Step 1: Firebase Setup (30 min)

1. Go to https://console.firebase.google.com/
2. Create new project: `clothes-remote-control`
3. Enable Realtime Database
4. Set database location
5. Go to Database → Rules → Copy rules from `FIREBASE_SETUP.md`
6. Get credentials:
   - Android: Download `google-services.json` → `android/app/`
   - iOS: Download `GoogleService-Info.plist` → Xcode
7. Update `lib/firebase_options.dart` with your credentials

### Step 2: Arduino Setup (1-2 hours)

1. Get hardware:
   - Arduino MKR WiFi 1010 (or Uno + WiFi Shield)
   - Rain sensor
   - Servo motor
   - 6V power supply

2. Follow wiring in `ARDUINO_HARDWARE_SETUP.md`

3. Upload `ARDUINO_CODE.ino`:
   - Update WiFi: `const char* SSID = "YOUR_SSID";`
   - Update Firebase: `const char* FIREBASE_HOST = "YOUR_PROJECT_ID.firebaseio.com";`
   - Upload to Arduino

4. Verify in Serial Monitor (115200 baud):
   ```
   Clothes Hanging System - Starting...
   Connecting to WiFi: YOUR_SSID
   WiFi connected!
   IP address: 192.168.1.100
   Initializing Firebase...
   Firebase initialized!
   ```

### Step 3: Flutter Setup (15 min)

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app
flutter run

# 3. App will automatically:
#    - Try local WiFi first
#    - Fall back to Firebase if needed
#    - Show connection status
```

### Step 4: Test Everything

**Local Test (at home):**
- Arduino and phone on same WiFi
- App shows "Connected (local)"
- Click buttons → servo moves immediately

**Remote Test (away from home):**
- Use mobile data or different WiFi
- App shows "Connected (firebase)"
- Click buttons → servo moves via Firebase

**Auto Mode Test:**
- Toggle "Auto Rain Detection" ON
- Spray water on rain sensor
- Servo moves inside automatically
- Wait 1 second → servo moves outside

---

## 📱 Connection Modes

### Mode 1: Local WiFi (Fast)
- ✅ Works at home
- ✅ Instant response
- ✅ No internet needed
- ❌ Only works on same WiFi

### Mode 2: Firebase (Remote)
- ✅ Works anywhere in world
- ✅ Works on mobile data
- ✅ Real-time updates
- ⚠️ Slight delay (1-2 seconds)

### Mode 3: Mock Mode (Testing)
- ✅ Works without hardware
- ✅ Perfect for UI testing
- ✅ No setup needed
- ❌ Simulated data only

---

## 🔧 Configuration Files

### `lib/firebase_options.dart`
Update with your Firebase credentials:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  databaseURL: 'https://YOUR_PROJECT_ID.firebaseio.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

### `ARDUINO_CODE.ino`
Update WiFi and Firebase:
```cpp
const char* SSID = "YOUR_WIFI_SSID";
const char* PASSWORD = "YOUR_WIFI_PASSWORD";
const char* FIREBASE_HOST = "YOUR_PROJECT_ID.firebaseio.com";
const char* DEVICE_ID = "device_001";
```

---

## 🐛 Troubleshooting

### App shows "Offline - No connection"
- Check internet connection
- Verify Firebase credentials in `firebase_options.dart`
- Ensure Arduino is connected to Firebase
- Check Firebase database rules

### Arduino not connecting to WiFi
- Verify SSID and password are correct
- Check WiFi signal strength
- Try 2.4GHz WiFi (not 5GHz)
- Check Serial Monitor for errors

### Servo not moving
- Check power supply (6V external)
- Verify servo is connected to Pin 9
- Check common ground (Arduino GND to servo GND)
- Test with simple servo code first

### Commands not working
- Check device ID matches: `device_001`
- Verify Firebase database rules
- Check Arduino Serial Monitor for command received
- Ensure Arduino is listening to Firebase

---

## 📊 Firebase Database Structure

After setup, your database will look like:

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
    └── commands/
        └── latest: "MOVE_INSIDE"
```

---

## 🎯 Features

- ✅ Remote control from anywhere
- ✅ Local WiFi for fast response
- ✅ Auto rain detection
- ✅ Real-time status updates
- ✅ Beautiful modern UI
- ✅ Works without Arduino (mock mode)
- ✅ Automatic fallback (local → Firebase)

---

## 📚 Documentation

- `FIREBASE_SETUP.md` - Detailed Firebase setup
- `ARDUINO_HARDWARE_SETUP.md` - Hardware assembly guide
- `ARDUINO_CODE.ino` - Complete Arduino code
- `INTEGRATION_GUIDE.md` - Full integration walkthrough
- `FIREBASE_IMPLEMENTATION_SUMMARY.md` - What's been done

---

## 🚀 You're Ready!

1. ✅ Flutter app is ready (works in mock mode now)
2. ✅ Firebase integration is complete
3. ✅ Arduino code is ready to upload
4. ✅ Documentation is comprehensive

**Next:** Follow the setup steps above and enjoy your remote control system!

---

## 💡 Tips

- Test locally first before going remote
- Use Serial Monitor to debug Arduino
- Check Firebase Console to verify data
- Start with mock mode to test UI
- Test auto mode with water bottle

---

## 📞 Need Help?

- Check the troubleshooting section above
- Read the detailed guides in documentation folder
- Check Arduino Serial Monitor for errors
- Check Firebase Console for data flow
- Verify all connections are correct

**Happy coding! 🎉**
