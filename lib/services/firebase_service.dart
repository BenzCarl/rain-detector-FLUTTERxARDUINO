import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/arduino_state.dart';

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reference to the device state in Firebase
  static late DatabaseReference _deviceRef;
  static String? _deviceId;

  // Initialize Firebase
  static Future<void> initialize(String deviceId) async {
    _deviceId = deviceId;
    _deviceRef = _database.ref('devices/$deviceId');

    // Enable offline persistence
    await _database.ref().keepSynced(true);

    // Sign in anonymously if not already signed in
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  // Get current status from Firebase
  static Future<ArduinoState> getStatus() async {
    try {
      final snapshot = await _deviceRef.child('state').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return ArduinoState.fromJson(data);
      } else {
        // Return default state if not found
        return ArduinoState(
          isRaining: false,
          clothesOutside: true,
          rainValue: 0,
          status: 'No data from device',
          autoMode: true,
        );
      }
    } catch (e) {
      throw Exception('Firebase error: $e');
    }
  }

  // Listen to real-time updates
  static Stream<ArduinoState> getStatusStream() {
    return _deviceRef.child('state').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return ArduinoState.fromJson(data);
      } else {
        return ArduinoState(
          isRaining: false,
          clothesOutside: true,
          rainValue: 0,
          status: 'Waiting for device...',
          autoMode: true,
        );
      }
    });
  }

  // Send command to Arduino via Firebase
  static Future<bool> sendCommand(String command) async {
    try {
      await _deviceRef.child('commands').push().set({
        'command': command,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      debugPrint('Error sending command: $e');
      return false;
    }
  }

  // Move clothes inside
  static Future<bool> moveInside() async {
    return await sendCommand('MOVE_INSIDE');
  }

  // Move clothes outside
  static Future<bool> moveOutside() async {
    return await sendCommand('MOVE_OUTSIDE');
  }

  // Toggle auto mode
  static Future<bool> toggleAutoMode() async {
    return await sendCommand('TOGGLE_AUTO');
  }

  // Update device state (called by Arduino)
  static Future<void> updateDeviceState(ArduinoState state) async {
    try {
      await _deviceRef.child('state').set({
        'isRaining': state.isRaining,
        'clothesOutside': state.clothesOutside,
        'rainValue': state.rainValue,
        'status': state.status,
        'autoMode': state.autoMode,
        'lastUpdate': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Error updating device state: $e');
    }
  }

  // Send notification to all users
  static Future<void> sendNotification({
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _deviceRef.child('notifications').push().set({
        'type': type,
        'title': title,
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data ?? {},
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  // Listen to notifications
  static Stream<Map<String, dynamic>> getNotificationStream() {
    return _deviceRef.child('notifications').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return data;
      }
      return {};
    });
  }

  // Get device ID (for pairing)
  static String? getDeviceId() => _deviceId;

  // Set device ID
  static void setDeviceId(String deviceId) {
    _deviceId = deviceId;
    _deviceRef = _database.ref('devices/$deviceId');
  }
}
