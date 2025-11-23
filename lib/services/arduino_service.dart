import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/arduino_state.dart';

class ArduinoService {
  static const String baseUrl =
      'http://192.168.1.100'; // Change to your Arduino IP
  static const int port = 80;

  // Mock state for offline development
  static ArduinoState _mockState = ArduinoState(
    isRaining: false,
    clothesOutside: true,
    rainValue: 800,
    status: 'Ready',
    autoMode: true,
  );

  static bool _useMockMode = true; // Set to false when Arduino is connected

  // Get current status from Arduino or mock
  static Future<ArduinoState> getStatus() async {
    if (_useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return _mockState;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl:$port/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _mockState = ArduinoState.fromJson(data);
        _useMockMode = false;
        return _mockState;
      } else {
        throw Exception('Failed to get status: ${response.statusCode}');
      }
    } catch (e) {
      // Fall back to mock mode if connection fails
      _useMockMode = true;
      return _mockState;
    }
  }

  // Send manual command to Arduino or mock
  static Future<bool> sendCommand(String command) async {
    if (_useMockMode) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      _handleMockCommand(command);
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl:$port/command'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'command': command}),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      // Fall back to mock mode
      _useMockMode = true;
      _handleMockCommand(command);
      return true;
    }
  }

  // Handle mock commands
  static void _handleMockCommand(String command) {
    switch (command) {
      case 'MOVE_INSIDE':
        _mockState = _mockState.copyWith(
          clothesOutside: false,
          status: 'Clothes moved inside',
        );
        break;
      case 'MOVE_OUTSIDE':
        _mockState = _mockState.copyWith(
          clothesOutside: true,
          status: 'Clothes moved outside',
        );
        break;
      case 'TOGGLE_AUTO':
        _mockState = _mockState.copyWith(
          autoMode: !_mockState.autoMode,
          status: _mockState.autoMode ? 'Auto mode disabled' : 'Auto mode enabled',
        );
        break;
    }
  }

  // Move clothes inside manually
  static Future<bool> moveInside() async {
    return await sendCommand('MOVE_INSIDE');
  }

  // Move clothes outside manually
  static Future<bool> moveOutside() async {
    return await sendCommand('MOVE_OUTSIDE');
  }

  // Toggle auto mode
  static Future<bool> toggleAutoMode() async {
    return await sendCommand('TOGGLE_AUTO');
  }

  // Check if using mock mode
  static bool get isMockMode => _useMockMode;

  // Switch between mock and real mode (for testing)
  static void setMockMode(bool mock) {
    _useMockMode = mock;
  }
}
