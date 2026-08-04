class DeviceEntity {
  final String id;
  final String label;
  final String protocol;
  final String? host;
  final int? port;
  final String? macAddress;
  final bool isConnected;

  const DeviceEntity({
    required this.id,
    required this.label,
    required this.protocol,
    this.host,
    this.port,
    this.macAddress,
    this.isConnected = false,
  });

  factory DeviceEntity.fromJson(Map<String, dynamic> json) {
    return DeviceEntity(
      id: json['id'],
      label: json['label'],
      protocol: json['protocol'],
      host: json['host'],
      port: json['port'],
      macAddress: json['mac_address'],
    );
  }
}

