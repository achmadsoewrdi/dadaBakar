enum BlynkWidgetType {
  chart,  // Live Telemetry Line Chart
  gauge,  // Circular Meter (0 - 100)
  toggle, // ON/OFF Switch
  value,  // Numeric Display Box
}

class BlynkWidgetEntity {
  final String id;
  final String title;
  final BlynkWidgetType type;
  final String sensorPin; // e.g. "GPIO2", "A0", "RELAY_1"
  final String unit;      // e.g. "°C", "%", "lux", "V"
  final int primaryColorHex; // Color theme hex code
  final double minValue;
  final double maxValue;
  final bool isActuator;  // True if it controls a device (e.g. Pump/LED)
  final bool currentValueBool;
  final double currentValueNum;

  const BlynkWidgetEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.sensorPin,
    this.unit = '',
    this.primaryColorHex = 0xFF005CFF,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.isActuator = false,
    this.currentValueBool = false,
    this.currentValueNum = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'sensor_pin': sensorPin,
      'unit': unit,
      'primary_color_hex': primaryColorHex,
      'min_value': minValue,
      'max_value': maxValue,
      'is_actuator': isActuator,
      'current_value_bool': currentValueBool,
      'current_value_num': currentValueNum,
    };
  }

  factory BlynkWidgetEntity.fromJson(Map<String, dynamic> json) {
    return BlynkWidgetEntity(
      id: json['id'] as String? ?? 'w_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Widget Baru',
      type: BlynkWidgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BlynkWidgetType.value,
      ),
      sensorPin: json['sensor_pin'] as String? ?? 'A0',
      unit: json['unit'] as String? ?? '',
      primaryColorHex: json['primary_color_hex'] as int? ?? 0xFF005CFF,
      minValue: (json['min_value'] as num?)?.toDouble() ?? 0.0,
      maxValue: (json['max_value'] as num?)?.toDouble() ?? 100.0,
      isActuator: json['is_actuator'] as bool? ?? false,
      currentValueBool: json['current_value_bool'] as bool? ?? false,
      currentValueNum: (json['current_value_num'] as num?)?.toDouble() ?? 0.0,
    );
  }

  BlynkWidgetEntity copyWith({
    String? id,
    String? title,
    BlynkWidgetType? type,
    String? sensorPin,
    String? unit,
    int? primaryColorHex,
    double? minValue,
    double? maxValue,
    bool? isActuator,
    bool? currentValueBool,
    double? currentValueNum,
  }) {
    return BlynkWidgetEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      sensorPin: sensorPin ?? this.sensorPin,
      unit: unit ?? this.unit,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      isActuator: isActuator ?? this.isActuator,
      currentValueBool: currentValueBool ?? this.currentValueBool,
      currentValueNum: currentValueNum ?? this.currentValueNum,
    );
  }
}
