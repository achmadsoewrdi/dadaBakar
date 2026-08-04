import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/device_connection_service.dart';

void showWifiConnectionModal(
  BuildContext context, {
  required void Function(String label, String protocol,
      {String? macAddress, String? host, int? port}) onDeviceSaved,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return _WifiConnectionModalContent(onDeviceSaved: onDeviceSaved);
    },
  );
}

class _WifiConnectionModalContent extends StatefulWidget {
  final void Function(String label, String protocol,
      {String? macAddress, String? host, int? port}) onDeviceSaved;

  const _WifiConnectionModalContent({required this.onDeviceSaved});

  @override
  State<_WifiConnectionModalContent> createState() =>
      _WifiConnectionModalContentState();
}

class _WifiConnectionModalContentState
    extends State<_WifiConnectionModalContent> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  bool _isConnecting = false;

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  enabled: !_isConnecting,
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
                  enabled: !_isConnecting,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isConnecting
                  ? null
                  : () async {
                      final host = _ipController.text.trim();
                      final portStr = _portController.text.trim();
                      if (host.isEmpty) return;

                      setState(() => _isConnecting = true);

                      await DeviceConnectionService.instance.connectWifi(
                        host,
                        portStr,
                      );
                      
                      if (!context.mounted) return;
                      setState(() => _isConnecting = false);

                      if (DeviceConnectionService.instance.isConnected) {
                        context.pop();
                        widget.onDeviceSaved(
                          'Xploria Wi-Fi',
                          'websocket',
                          host: host,
                          port: int.tryParse(portStr),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(DeviceConnectionService.instance.statusMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F1C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isConnecting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Hubungkan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
