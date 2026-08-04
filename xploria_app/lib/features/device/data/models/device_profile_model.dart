class DeviceProfileModel {
  final String id;
  final String ownerId;
  final String label;
  final String protocol;
  final String? hardwareTypeId;
  final String? hardwareVariant;
  final String? host;
  final int? port;
  final bool useTls;
  final String? macAddress;
  final DateTime createdAt;

  DeviceProfileModel({
    required this.id,
    required this.ownerId,
    required this.label,
    required this.protocol,
    this.hardwareTypeId,
    this.hardwareVariant,
    this.host,
    this.port,
    required this.useTls,
    this.macAddress,
    required this.createdAt,
  });

  factory DeviceProfileModel.fromJson(Map<String, dynamic> json) {
    return DeviceProfileModel(
      id: json['id'],
      ownerId: json['owner_id'],
      label: json['label'],
      protocol: json['protocol'],
      hardwareTypeId: json['hardware_type_id'],
      hardwareVariant: json['hardware_variant'],
      host: json['host'],
      port: json['port'],
      useTls: json['use_tls'] ?? false,
      macAddress: json['mac_address'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'protocol': protocol,
      'hardware_type_id': hardwareTypeId,
      'hardware_variant': hardwareVariant,
      'host': host,
      'port': port,
      'use_tls': useTls,
      'mac_address': macAddress,
    };
  }
}
