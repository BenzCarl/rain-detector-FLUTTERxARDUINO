import 'package:flutter/foundation.dart';
import '../models/arduino_state.dart';
import '../services/arduino_service.dart';
import '../services/firebase_service.dart';

class ClothesProvider with ChangeNotifier {
  ArduinoState _currentState = ArduinoState(
    isRaining: false,
    clothesOutside: true,
    rainValue: 0,
    status: 'Initializing...',
    autoMode: true,
  );

  bool _isLoading = false;
  bool _isConnected = false;
  bool _useFirebase = false;
  String? _connectionMode; // 'local', 'firebase', or 'offline'

  // Getters
  ArduinoState get currentState => _currentState;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  bool get useFirebase => _useFirebase;
  String? get connectionMode => _connectionMode;

  // Update status from Arduino (local first, then Firebase)
  Future<void> updateStatus() async {
    _setLoading(true);
    try {
      // Try local connection first
      try {
        final newState = await ArduinoService.getStatus();
        _currentState = newState;
        _isConnected = true;
        _connectionMode = 'local';
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('Local connection failed: $e');
      }

      // If local fails, try Firebase
      if (_useFirebase) {
        try {
          final newState = await FirebaseService.getStatus();
          _currentState = newState;
          _isConnected = true;
          _connectionMode = 'firebase';
          notifyListeners();
          return;
        } catch (e) {
          debugPrint('Firebase connection failed: $e');
        }
      }

      // If both fail, show offline
      _isConnected = false;
      _connectionMode = 'offline';
      _currentState = ArduinoState(
        isRaining: false,
        clothesOutside: true,
        rainValue: 0,
        status: 'Offline - No connection',
        autoMode: _currentState.autoMode,
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Manual control methods (try local first, then Firebase)
  Future<void> moveClothesInside() async {
    _setLoading(true);
    try {
      bool success = false;

      // Try local first
      try {
        success = await ArduinoService.moveInside();
        if (success) {
          _connectionMode = 'local';
        }
      } catch (e) {
        debugPrint('Local move failed: $e');
      }

      // If local fails, try Firebase
      if (!success && _useFirebase) {
        try {
          success = await FirebaseService.moveInside();
          if (success) {
            _connectionMode = 'firebase';
          }
        } catch (e) {
          debugPrint('Firebase move failed: $e');
        }
      }

      if (success) {
        _currentState = _currentState.copyWith(
          clothesOutside: false,
          status: 'Moved inside',
        );
        notifyListeners();
      } else {
        _currentState = _currentState.copyWith(status: 'Failed to move inside');
        notifyListeners();
      }
    } catch (e) {
      _currentState = _currentState.copyWith(status: 'Error: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> moveClothesOutside() async {
    _setLoading(true);
    try {
      bool success = false;

      // Try local first
      try {
        success = await ArduinoService.moveOutside();
        if (success) {
          _connectionMode = 'local';
        }
      } catch (e) {
        debugPrint('Local move failed: $e');
      }

      // If local fails, try Firebase
      if (!success && _useFirebase) {
        try {
          success = await FirebaseService.moveOutside();
          if (success) {
            _connectionMode = 'firebase';
          }
        } catch (e) {
          debugPrint('Firebase move failed: $e');
        }
      }

      if (success) {
        _currentState = _currentState.copyWith(
          clothesOutside: true,
          status: 'Moved outside',
        );
        notifyListeners();
      } else {
        _currentState = _currentState.copyWith(status: 'Failed to move outside');
        notifyListeners();
      }
    } catch (e) {
      _currentState = _currentState.copyWith(status: 'Error: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleAutoMode() async {
    _setLoading(true);
    try {
      bool success = false;

      // Try local first
      try {
        success = await ArduinoService.toggleAutoMode();
        if (success) {
          _connectionMode = 'local';
        }
      } catch (e) {
        debugPrint('Local toggle failed: $e');
      }

      // If local fails, try Firebase
      if (!success && _useFirebase) {
        try {
          success = await FirebaseService.toggleAutoMode();
          if (success) {
            _connectionMode = 'firebase';
          }
        } catch (e) {
          debugPrint('Firebase toggle failed: $e');
        }
      }

      if (success) {
        _currentState = _currentState.copyWith(
          autoMode: !_currentState.autoMode,
          status: !_currentState.autoMode
              ? 'Auto mode enabled'
              : 'Auto mode disabled',
        );
        notifyListeners();
      }
    } catch (e) {
      _currentState = _currentState.copyWith(
        status: 'Error toggling auto mode: $e',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Initialize Firebase
  Future<void> initializeFirebase(String deviceId) async {
    try {
      await FirebaseService.initialize(deviceId);
      _useFirebase = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      _useFirebase = false;
    }
  }

  // Enable/disable Firebase
  void setFirebaseEnabled(bool enabled) {
    _useFirebase = enabled;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
