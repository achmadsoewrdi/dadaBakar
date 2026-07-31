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
  final TextEditingController _ipController = TextEditingController(text: "192.168.4.1");
  final TextEditingController _portController = TextEditingController(text: "9001");
  final TextEditingController _labelController = TextEditingController(text: "Robot Xploria");

  @override
  void initState() {
    super.initState();
    DeviceConnectionService.instance.loadPairedDevices(silent: true);
    DeviceConnectionService.instance.fetchSavedDevices();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _confirmDelete(String id, String label) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Perangkat'),
        content: Text('Apakah Anda yakin ingin menghapus "$label"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await DeviceConnectionService.instance.deleteSavedDevice(id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label berhasil dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceModal() {
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
                'Daftarkan Perangkat Wi-Fi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A122C),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'Label (Nama Device)',
                  hintText: 'Robot Xploria',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon: const Icon(Icons.label_rounded),
                ),
              ),
              const SizedBox(height: 12),
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
                child: ElevatedButton(
                  onPressed: () async {
                    final error = await DeviceConnectionService.instance.saveDeviceToCloud(
                      label: _labelController.text.trim(),
                      protocol: 'websocket',
                      host: _ipController.text.trim(),
                      port: int.tryParse(_portController.text.trim()),
                    );
                    if (context.mounted) {
                      if (error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Perangkat berhasil didaftarkan!')),
                        );
                        Navigator.pop(context);
                        DeviceConnectionService.instance.fetchSavedDevices();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005CFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Simpan Perangkat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
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

  Widget _buildWifiDashboard(DeviceConnectionService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Perangkat Saya',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A122C)),
            ),
            if (service.isLoadingSavedDevices)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => service.fetchSavedDevices(),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (service.savedDevices.isEmpty && !service.isLoadingSavedDevices)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.devices_other_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada perangkat terdaftar.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambahkan.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          ...service.savedDevices.map((d) {
            final isConnected = service.isConnected && service.connectedDeviceId == d.id;
            final isConnecting = service.isConnecting && service.connectedDeviceId == d.id;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isConnected ? Colors.green : Colors.grey.shade200, 
                  width: isConnected ? 2 : 1
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green.withOpacity(0.1) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi,
                        color: isConnected ? Colors.green : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.label, 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A122C))
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${d.host ?? ''}:${d.port ?? ''}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (isConnecting)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else if (isConnected)
                      IconButton(
                        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.red, size: 28),
                        onPressed: () => service.disconnect(),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF005CFF), size: 36),
                        onPressed: () {
                          service.connectWifi(d.host ?? '', d.port?.toString() ?? '', deviceId: d.id);
                        },
                      ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(d.id, d.label);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBluetoothLayout(DeviceConnectionService service) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
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
                  ? Icons.bluetooth_connected_rounded
                  : service.isConnecting
                      ? Icons.bluetooth_searching_rounded
                      : Icons.bluetooth_disabled_rounded,
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
        Text(
          service.isConnected
              ? "Tersambung ke ${service.selectedDevice?.name ?? 'Device'}"
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

        if (!service.isConnected)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: service.isConnecting ? null : _showDeviceSelectionModal,
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
                    service.isConnecting ? 'Menghubungkan...' : 'Pilih Device',
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
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton.icon(
              onPressed: service.disconnect,
              icon: const Icon(Icons.bluetooth_disabled_rounded),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DeviceConnectionService.instance,
      builder: (context, _) {
        final service = DeviceConnectionService.instance;
        final isWifi = service.connectionMode == ConnectionMode.wifi;

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
                  child: isWifi ? _buildWifiDashboard(service) : _buildBluetoothLayout(service),
                ),
              ), 
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
              if (isWifi)
                Positioned(
                  right: 24,
                  bottom: 120, // Above the custom floating navbar
                  child: FloatingActionButton(
                    onPressed: _showAddDeviceModal,
                    backgroundColor: const Color(0xFF005CFF),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.add_rounded, size: 32),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}
