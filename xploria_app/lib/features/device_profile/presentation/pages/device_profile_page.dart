import 'package:flutter/material.dart';
import '../../../devices/domain/models/device_profile_model.dart';
import '../../../dashboard/presentation/widgets/dashboard_shared_widgets.dart';
import '../../data/repositories/device_profile_repository.dart';

class DeviceProfilePage extends StatefulWidget {
  const DeviceProfilePage({super.key});

  @override
  State<DeviceProfilePage> createState() => _DeviceProfilePageState();
}

class _DeviceProfilePageState extends State<DeviceProfilePage> {
  final DeviceProfileRepository _repository = DeviceProfileRepository();
  bool _isLoading = true;
  List<DeviceProfileModel> _deviceProfiles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profiles = await _repository.getDeviceProfiles();
    if (mounted) {
      setState(() {
        _deviceProfiles = profiles;
        _isLoading = false;
      });
    }
  }

  void _showFeatureSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF005CFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showAddDeviceModal(BuildContext context) {
    _showFeatureSnackbar('Form Tambah Device Profile (WebSocket / Bluetooth)');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final topInset = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(top: topInset + 200, bottom: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                ..._deviceProfiles.map((dev) {
                  final isWebSocket = dev.protocol == 'websocket';

                  return HoverCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    onTap: () => _showFeatureSnackbar('Profil Perangkat: ${dev.label}'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isWebSocket
                                  ? const Color(0xFF005CFF).withValues(alpha: 0.1)
                                  : const Color(0xFF00C2FF).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isWebSocket ? Icons.wifi_rounded : Icons.bluetooth_rounded,
                              color: isWebSocket ? const Color(0xFF005CFF) : const Color(0xFF00C2FF),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dev.label,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A122C),
                                  ),
                                ),
                                Text(
                                  isWebSocket ? '${dev.host}:${dev.port}' : (dev.macAddress ?? 'N/A'),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF2ED9C3), size: 24),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: WavyPageHeader(
            title: 'Device Profiles',
            subtitle: 'Kelola koneksi hardware WebSocket & BLE',
            topActionWidget: IconButton(
              icon: const Icon(Icons.add_link_rounded, color: Colors.white, size: 28),
              onPressed: () => _showAddDeviceModal(context),
            ),
            categoryPillsWidget: HeaderCategoryPills(
              categories: const ['Semua', 'WebSocket', 'Bluetooth'],
              selectedIndex: 0,
              onSelect: (idx) {},
            ),
          ),
        ),
      ],
    );
  }
}
