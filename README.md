# Clothes Remote Control

A modern Flutter application for remotely controlling an automated clothes hanging system. The app allows you to hide and show hanging clothes inside a mini house, with automatic rain detection and manual control options.

**Now with Firebase support!** Control your clothes from anywhere in the world! 🌍

## Features

✨ **Modern UI/UX Design**
- Eye-friendly interface with a beautiful gradient color scheme
- Smooth animations and transitions
- Responsive layout that works on all screen sizes
- Material Design 3 components

🎮 **Remote Control**
- Move clothes inside with one tap
- Move clothes outside with one tap
- Real-time status updates
- Visual feedback for all actions

🌧️ **Auto Rain Detection**
- Automatic mode that hides clothes when rain is detected
- Manual control mode for override
- Real-time rain sensor readings
- Visual rain status indicator

📊 **Sensor Monitoring**
- Live rain sensor value display (0-1023)
- Moisture percentage calculation
- Visual progress bar for sensor readings
- Connection status indicator

🔌 **Flexible Connectivity**
- Works without Arduino connection (Mock Mode)
- Local WiFi control when at home (fast)
- Firebase remote control from anywhere (global)
- Automatic fallback: tries local first, then Firebase
- Perfect for UI/UX testing and development

☁️ **Firebase Integration**
- Control your clothes from anywhere in the world
- Real-time status updates
- Secure cloud database
- Automatic synchronization
- Works on mobile data or any WiFi

## Quick Start

### Test Without Hardware (Mock Mode)
```bash
flutter pub get
flutter run
```
The app works immediately in mock mode! No Arduino or Firebase needed.

### Full Setup with Arduino & Firebase
See `QUICK_START.md` for step-by-step instructions.

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio or Xcode (for mobile development)
- (Optional) Arduino MKR WiFi 1010 or Arduino Uno + WiFi Shield
- (Optional) Firebase project

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd clothes_remote_control
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

4. (Optional) Set up Firebase:
   - Follow `FIREBASE_SETUP.md`
   - Update `lib/firebase_options.dart` with credentials

5. (Optional) Set up Arduino:
   - Follow `ARDUINO_HARDWARE_SETUP.md`
   - Upload `ARDUINO_CODE.ino` to your board

## Project Structure

```
lib/
├── main.dart                 # App entry point with theme configuration
├── models/
│   └── arduino_state.dart   # Data model for Arduino state
├── providers/
│   └── clothes_provider.dart # State management using Provider
├── screens/
│   └── control_screen.dart  # Main UI screen
└── services/
    └── arduino_service.dart # Arduino communication service
```

## Architecture

The app uses the **Provider** pattern for state management:

- **ArduinoState**: Immutable data model representing the current state
- **ClothesProvider**: ChangeNotifier that manages state and communicates with Arduino
- **ArduinoService**: Service layer handling HTTP communication with Arduino (with mock fallback)
- **ControlScreen**: UI layer that displays state and handles user interactions

## Mock Mode

The app includes a built-in mock mode that simulates Arduino behavior without hardware:

- Automatically activates when Arduino is not connected
- Simulates network delays for realistic behavior
- Maintains state across commands
- Easy to switch to real Arduino by changing `_useMockMode` in `arduino_service.dart`

## Connecting to Arduino

When you have the Arduino hardware ready:

1. Update the Arduino IP address in `lib/services/arduino_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_ARDUINO_IP';
```

2. Set `_useMockMode = false` to use real hardware

3. Ensure your Arduino is running the compatible firmware with these endpoints:
   - `GET /status` - Returns current state
   - `POST /command` - Accepts commands (MOVE_INSIDE, MOVE_OUTSIDE, TOGGLE_AUTO)

## Commands

The app sends these commands to Arduino:
- `MOVE_INSIDE` - Move clothes inside
- `MOVE_OUTSIDE` - Move clothes outside
- `TOGGLE_AUTO` - Toggle automatic rain detection mode

## Design System

**Color Palette:**
- Primary: Indigo (#6366F1)
- Secondary: Purple (#8B5CF6)
- Success: Green (#22C55E)
- Warning: Orange (#F97316)
- Danger: Red (#EF4444)

**Typography:**
- Headlines: Bold, dark gray (#1F2937)
- Body: Regular, medium gray (#6B7280)
- Captions: Light, light gray (#9CA3AF)

## Dependencies

- **flutter**: UI framework
- **provider**: State management
- **http**: HTTP client for local Arduino communication
- **firebase_core**: Firebase initialization
- **firebase_database**: Firebase Realtime Database
- **firebase_auth**: Firebase authentication
- **lucide_icons**: Modern icon library
- **cupertino_icons**: iOS-style icons

## Future Enhancements

- [ ] Add weather API integration
- [ ] Schedule-based automation
- [ ] Multiple device support
- [ ] Dark mode theme
- [ ] Push notifications
- [ ] History/logs of actions
- [ ] Settings screen for customization

## Troubleshooting

**App crashes on startup:**
- Run `flutter clean` and then `flutter pub get`
- Ensure you're using Flutter 3.9.2 or higher

**Can't connect to Arduino:**
- Check that Arduino IP address is correct
- Ensure Arduino and phone are on the same network
- Verify Arduino firmware is running
- The app will automatically fall back to mock mode

**UI looks different on different devices:**
- The app is responsive and adapts to different screen sizes
- Test on multiple devices to ensure consistency

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, questions, or suggestions, please open an issue on the repository.
