class DeviceProfileModel {
  final String id;
  final String ownerId;
  final String label;
  final String protocol; // 'websocket' | 'bluetooth'
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
    this.host,
    this.port,
    this.useTls = false,
    this.macAddress,
    required this.createdAt,
  });

  factory DeviceProfileModel.fromJson(Map<String, dynamic> json) {
    return DeviceProfileModel(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      protocol: json['protocol'] as String? ?? 'websocket',
      host: json['host'] as String?,
      port: json['port'] as int?,
      useTls: json['use_tls'] as bool? ?? false,
      macAddress: json['mac_address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'label': label,
      'protocol': protocol,
      'host': host,
      'port': port,
      'use_tls': useTls,
      'mac_address': macAddress,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
