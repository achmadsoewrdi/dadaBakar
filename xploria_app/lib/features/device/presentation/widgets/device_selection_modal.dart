import 'package:flutter/material.dart';
import '../../../../core/services/device_connection_service.dart';

void showDeviceSelectionModal(
  BuildContext context, {
  required void Function(String label, String protocol,
      {String? macAddress, String? host, int? port}) onDeviceSaved,
}) {
  DeviceConnectionService.instance.loadPairedDevices();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      bool isConnecting = false;
      String? errorMessage;
      return StatefulBuilder(
        builder: (context, setState) {
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
                            maxHeight: MediaQuery.of(context).size.height * 0.5,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: service.devicesList.length,
                            itemBuilder: (context, index) {
                              final d = service.devicesList[index];
                              final isSelected =
                                  service.selectedDevice?.address == d.address;
                              return ListTile(
                                title: Text(d.name ?? "Unknown Device"),
                                subtitle: Text(d.address),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF005CFF),
                                      )
                                    : null,
                                onTap: isConnecting
                                    ? null
                                    : () {
                                        service.setSelectedDevice(d);
                                        setState(() => errorMessage = null);
                                      },
                              );
                            },
                          ),
                        ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.5)),
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: service.selectedDevice == null || isConnecting
                              ? null
                              : () async {
                                  setState(() {
                                    isConnecting = true;
                                    errorMessage = null;
                                  });

                                  await service.connectBluetooth();
                                  
                                  if (!context.mounted) return;

                                  if (service.isConnected) {
                                    Navigator.pop(context);
                                    onDeviceSaved(
                                      service.selectedDevice?.name ?? 'Xploria Bluetooth',
                                      'bluetooth',
                                      macAddress: service.selectedDevice?.address,
                                    );
                                  } else {
                                    setState(() {
                                      isConnecting = false;
                                      errorMessage = service.statusMessage;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005CFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isConnecting
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
            },
          );
        },
      );
    },
  );
}
