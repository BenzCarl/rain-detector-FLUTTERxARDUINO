class ArduinoState {
  final bool isRaining;
  final bool clothesOutside;
  final int rainValue;
  final String status;
  final bool autoMode;

  ArduinoState({
    required this.isRaining,
    required this.clothesOutside,
    required this.rainValue,
    required this.status,
    required this.autoMode,
  });

  factory ArduinoState.fromJson(Map<String, dynamic> json) {
    return ArduinoState(
      isRaining: json['isRaining'] ?? false,
      clothesOutside: json['clothesOutside'] ?? true,
      rainValue: json['rainValue'] ?? 0,
      status: json['status'] ?? 'Unknown',
      autoMode: json['autoMode'] ?? true,
    );
  }

  ArduinoState copyWith({
    bool? isRaining,
    bool? clothesOutside,
    int? rainValue,
    String? status,
    bool? autoMode,
  }) {
    return ArduinoState(
      isRaining: isRaining ?? this.isRaining,
      clothesOutside: clothesOutside ?? this.clothesOutside,
      rainValue: rainValue ?? this.rainValue,
      status: status ?? this.status,
      autoMode: autoMode ?? this.autoMode,
    );
  }
}
