import 'package:flutter/material.dart';
import '../../data/models/device_profile_model.dart';
import '../../../../core/services/device_connection_service.dart';

class SavedDeviceCard extends StatelessWidget {
  final DeviceProfileModel device;
  final DeviceConnectionService service;
  final bool isConnecting;
  final VoidCallback onTap;
  final VoidCallback onDisconnect;
  final VoidCallback onShowDetails;

  const SavedDeviceCard({
    super.key,
    required this.device,
    required this.service,
    required this.isConnecting,
    required this.onTap,
    required this.onDisconnect,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isBluetooth = device.protocol == 'bluetooth';
    final isOnline = isBluetooth
        ? (service.isConnected &&
              service.connectionMode == ConnectionMode.bluetooth &&
              service.selectedDevice?.address == device.macAddress)
        : (service.isConnected &&
              service.connectionMode == ConnectionMode.wifi &&
              service.connectedIp == device.host);

    final iconColor = isBluetooth
        ? const Color(0xFF2A5EE8)
        : const Color(0xFFF79E66);
    final iconBgColor = iconColor.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: isOnline ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isBluetooth ? Icons.bluetooth : Icons.wifi,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0A122C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${device.hardwareVariant ?? 'Hardware Kit'} • ${device.macAddress ?? device.host ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFFE8F5E9)
                    : (isConnecting
                          ? Colors.blue.shade50
                          : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOnline
                      ? Colors.green.shade200
                      : (isConnecting
                            ? Colors.blue.shade200
                            : Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  if (isConnecting)
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    isConnecting
                        ? 'Connecting...'
                        : (isOnline ? 'Online' : 'Offline'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isConnecting
                          ? Colors.blue.shade700
                          : (isOnline
                                ? Colors.green.shade700
                                : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            if (isOnline) ...[
              const SizedBox(width: 12),
              InkWell(
                onTap: onDisconnect,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            InkWell(
              onTap: onShowDetails,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
