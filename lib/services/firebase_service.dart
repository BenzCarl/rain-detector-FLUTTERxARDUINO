import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/arduino_state.dart';

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reference to the device state in Firebase
  static DatabaseReference? _deviceRef;
  static String? _deviceId;
  static bool _initialized = false;

  // Initialize Firebase
  static Future<void> initialize(String deviceId) async {
    try {
      _deviceId = deviceId;
      _deviceRef = _database.ref('devices/$deviceId');

      // Enable offline persistence
      await _database.ref().keepSynced(true);

      // Sign in anonymously if not already signed in
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      
      _initialized = true;
      debugPrint('Firebase initialized successfully with device ID: $deviceId');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      _initialized = false;
    }
  }

  // Check if initialized
  static bool get isInitialized => _initialized && _deviceRef != null;

  // Ensure initialized before operations
  static Future<void> _ensureInitialized() async {
    if (!isInitialized) {
      debugPrint('Warning: FirebaseService not initialized. Initializing with default device ID...');
      await initialize('device_001');
    }
  }

  // Get current status from Firebase
  static Future<ArduinoState> getStatus() async {
    try {
      await _ensureInitialized();
      if (_deviceRef == null) throw Exception('Firebase not initialized');
      
      final snapshot = await _deviceRef!.child('state').get();

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
    if (_deviceRef == null) {
      debugPrint('Warning: FirebaseService not initialized for stream');
      return Stream.value(ArduinoState(
        isRaining: false,
        clothesOutside: true,
        rainValue: 0,
        status: 'Firebase not initialized',
        autoMode: true,
      ));
    }
    
    return _deviceRef!.child('state').onValue.map((event) {
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
      await _ensureInitialized();
      if (_deviceRef == null) throw Exception('Firebase not initialized');
      
      await _deviceRef!.child('commands').push().set({
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
      await _ensureInitialized();
      if (_deviceRef == null) throw Exception('Firebase not initialized');
      
      await _deviceRef!.child('state').set({
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
      await _ensureInitialized();
      if (_deviceRef == null) throw Exception('Firebase not initialized');
      
      await _deviceRef!.child('notifications').push().set({
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
    if (_deviceRef == null) {
      debugPrint('Warning: FirebaseService not initialized for notifications');
      return Stream.value({});
    }
    
    return _deviceRef!.child('notifications').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return data;
      }
      return {};
    });
  }

  // Log clothes movement with timestamp
  static Future<void> logClothesMovement({
    required bool movedInside,
    required DateTime timestamp,
  }) async {
    try {
      await _ensureInitialized();
      if (_deviceRef == null) throw Exception('Firebase not initialized');
      
      await _deviceRef!.child('movements').push().set({
        'action': movedInside ? 'moved_inside' : 'moved_outside',
        'timestamp': timestamp.millisecondsSinceEpoch,
        'date': timestamp.toString().split('.')[0],
        'hour': timestamp.hour,
        'minute': timestamp.minute,
        'second': timestamp.second,
        'day': timestamp.day,
        'month': timestamp.month,
        'year': timestamp.year,
      });
      debugPrint('Clothes movement logged: ${movedInside ? 'INSIDE' : 'OUTSIDE'} at $timestamp');
    } catch (e) {
      debugPrint('Error logging clothes movement: $e');
    }
  }

  // Get clothes movement history
  static Future<List<Map<String, dynamic>>> getMovementHistory() async {
    try {
      await _ensureInitialized();
      if (_deviceRef == null) throw Exception('Firebase not initialized');
      
      final snapshot = await _deviceRef!.child('movements').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.values.cast<Map<String, dynamic>>().toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting movement history: $e');
      return [];
    }
  }

  // Get device ID (for pairing)
  static String? getDeviceId() => _deviceId;

  // Set device ID
  static void setDeviceId(String deviceId) {
    _deviceId = deviceId;
    _deviceRef = _database.ref('devices/$deviceId');
    _initialized = true;
    debugPrint('Device ID set to: $deviceId');
  }
}
