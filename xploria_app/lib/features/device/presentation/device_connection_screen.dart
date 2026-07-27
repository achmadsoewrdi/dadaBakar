import 'package:flutter/material.dart';
import '../../../core/services/device_connection_service.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  final TextEditingController _ipController = TextEditingController(text: "192.168.4.1");
  final TextEditingController _portController = TextEditingController(text: "9001");

  @override
  void initState() {
    super.initState();
    // Load Bluetooth devices on screen open if not already loaded
    DeviceConnectionService.instance.loadPairedDevices(silent: true);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _showDeviceSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: DeviceConnectionService.instance,
          builder: (context, _) {
            final service = DeviceConnectionService.instance;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Perangkat Bluetooth',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A122C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (service.devicesList.isEmpty)
                    const Text('Tidak ada perangkat tersimpan.')
                  else
                    ...service.devicesList.map((d) {
                      final isSelected = service.selectedDevice?.address == d.address;
                      return ListTile(
                        title: Text(d.name ?? "Unknown Device"),
                        subtitle: Text(d.address),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFF005CFF))
                            : null,
                        onTap: () {
                          service.setSelectedDevice(d);
                        },
                      );
                    }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: service.selectedDevice == null
                          ? null
                          : () {
                              Navigator.pop(context);
                              service.connectBluetooth();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005CFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Hubungkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showWifiConnectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hubungkan ke Wi-Fi (WebSocket)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A122C),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: TextField(
                      controller: _ipController,
                      decoration: InputDecoration(
                        labelText: 'IP Address',
                        hintText: 'e.g. 192.168.4.1',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.router),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _portController,
                      decoration: InputDecoration(
                        labelText: 'Port',
                        hintText: '9001',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    DeviceConnectionService.instance.connectWifi(
                      _ipController.text.trim(), 
                      _portController.text.trim()
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Hubungkan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleOption({
    required String title,
    required IconData icon,
    required ConnectionMode mode,
    required DeviceConnectionService service,
  }) {
    final isSelected = service.connectionMode == mode;
    return GestureDetector(
      onTap: () {
        service.setConnectionMode(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DeviceConnectionService.instance,
      builder: (context, _) {
        final service = DeviceConnectionService.instance;
        return Scaffold(
          backgroundColor: const Color(0xFFF0F6FF),
          appBar: AppBar(
            title: const Text('Koneksi Device', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: const Color(0xFF0A122C),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Toggle Bluetooth vs Wi-Fi
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleOption(
                          title: 'Wi-Fi',
                          icon: Icons.wifi,
                          mode: ConnectionMode.wifi,
                          service: service,
                        ),
                        _buildToggleOption(
                          title: 'Bluetooth',
                          icon: Icons.bluetooth,
                          mode: ConnectionMode.bluetooth,
                          service: service,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Status Image or Icon
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: service.isConnected
                          ? const Color(0xFFE8F5E9)
                          : service.isConnecting
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        service.isConnected
                            ? (service.connectionMode == ConnectionMode.bluetooth ? Icons.bluetooth_connected_rounded : Icons.wifi)
                            : service.isConnecting
                                ? (service.connectionMode == ConnectionMode.bluetooth ? Icons.bluetooth_searching_rounded : Icons.wifi_find)
                                : (service.connectionMode == ConnectionMode.bluetooth ? Icons.bluetooth_disabled_rounded : Icons.wifi_off_rounded),
                        size: 60,
                        color: service.isConnected
                            ? Colors.green
                            : service.isConnecting
                                ? Colors.orange
                                : const Color(0xFF005CFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Status Text
                  Text(
                    service.isConnected
                        ? "Tersambung ke ${service.connectionMode == ConnectionMode.bluetooth ? service.selectedDevice?.name ?? 'Device' : service.connectedIp}"
                        : "Belum ada device tersambung",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0A122C),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Connect / Disconnect Button
                  if (!service.isConnected)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: service.isConnecting
                            ? null
                            : (service.connectionMode == ConnectionMode.bluetooth
                                ? _showDeviceSelectionModal
                                : _showWifiConnectionModal),
                        icon: service.isConnecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add_link_rounded),
                        label: Text(
                          service.isConnecting ? 'Menghubungkan...' : 'Tambahkan Device',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005CFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // Send Ping Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => service.sendData('{"action":"TEST_PING"}'),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text(
                          'Kirim Data Konfigurasi Test',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9F1C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Disconnect Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton.icon(
                        onPressed: service.disconnect,
                        icon: Icon(service.connectionMode == ConnectionMode.bluetooth
                            ? Icons.bluetooth_disabled_rounded
                            : Icons.wifi_off_rounded),
                        label: const Text(
                          'Putuskan Device',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
