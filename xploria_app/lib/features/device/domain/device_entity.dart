// Device Entity Placeholder
class DeviceEntity {
  final String ipAddress;
  final int port;
  final bool isConnected;

  const DeviceEntity({
    required this.ipAddress,
    required this.port,
    this.isConnected = false,
  });
}
