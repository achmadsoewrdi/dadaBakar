import 'package:flutter/material.dart';
import '../../../../core/services/device_connection_service.dart';
import '../../../dashboard/presentation/widgets/dashboard_shared_widgets.dart';

class DeviceConnectionScreen extends StatefulWidget {
  final bool showBackButton;

  const DeviceConnectionScreen({super.key, this.showBackButton = false});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

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
    DeviceConnectionService.instance.loadPairedDevices();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: DeviceConnectionService.instance,
          builder: (context, _) {
            final service = DeviceConnectionService.instance;
            return SafeArea(
              child: Padding(
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
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: service.devicesList.length,
                          itemBuilder: (context, index) {
                            final d = service.devicesList[index];
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
                          },
                        ),
                      ),
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
                        labelText: 'IP / Domain',
                        hintText: '192.168.4.1 atau domain.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.language_rounded),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _portController,
                      decoration: InputDecoration(
                        labelText: 'Port (Opsional)',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
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
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.textScalerOf(context).scale(widget.showBackButton ? 266 : 236) + 24, 
                  bottom: 120,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    const SizedBox(height: 16),
  
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
                      Column(
                        children: [
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
                          ),
                          if (service.isConnecting) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => service.disconnect(),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade500,
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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
            ), // Closing SingleChildScrollView
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: WavyPageHeader(
                title: 'Koneksi Device',
                subtitle: 'Hubungkan Xploria App dengan Robot atau Perangkat IoT Anda.',
                showBackButton: widget.showBackButton,
                categoryPillsWidget: Padding(
                  padding: EdgeInsets.only(
                    left: widget.showBackButton ? 84.0 : 24.0, 
                    right: 24.0
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
                  ),
                ),
              ),
            ),
            ],
          ),
        );
      }
    );
  }
}
