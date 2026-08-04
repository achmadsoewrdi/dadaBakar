import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/device_profile_model.dart';
import '../../data/data_sources/device_api_service.dart';

void showDeviceDetailsModal(
  BuildContext context,
  DeviceProfileModel device, {
  required VoidCallback onDeviceUpdatedOrDeleted,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return _DeviceDetailsModalContent(
        device: device,
        onDeviceUpdatedOrDeleted: onDeviceUpdatedOrDeleted,
      );
    },
  );
}

class _DeviceDetailsModalContent extends StatefulWidget {
  final DeviceProfileModel device;
  final VoidCallback onDeviceUpdatedOrDeleted;

  const _DeviceDetailsModalContent({
    required this.device,
    required this.onDeviceUpdatedOrDeleted,
  });

  @override
  State<_DeviceDetailsModalContent> createState() =>
      _DeviceDetailsModalContentState();
}

class _DeviceDetailsModalContentState extends State<_DeviceDetailsModalContent> {
  late TextEditingController _nameController;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.label);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detail Perangkat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A122C),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Detail info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Protocol',
                  device.protocol.toUpperCase(),
                ),
                const Divider(),
                _buildDetailRow(
                  device.protocol == 'bluetooth'
                      ? 'MAC Address'
                      : 'IP / Domain',
                  device.macAddress ?? device.host ?? '-',
                ),
                if (device.port != null) ...[
                  const Divider(),
                  _buildDetailRow('Port', device.port.toString()),
                ],
                const Divider(),
                _buildDetailRow(
                  'Dibuat Pada',
                  device.createdAt.toString().split('.')[0],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Ubah Nama Perangkat',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Nama Perangkat',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isDeleting || _isSaving
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Perangkat?'),
                              content: const Text(
                                'Perangkat ini akan dihapus dari daftar tersimpan.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      ctx.pop(false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      ctx.pop(true),
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            setState(() => _isDeleting = true);
                            try {
                              await DeviceApiService().deleteDevice(
                                device.id,
                              );
                              if (!context.mounted) return;
                              context.pop();
                              widget.onDeviceUpdatedOrDeleted();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                            if (mounted) {
                              setState(() => _isDeleting = false);
                            }
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Hapus',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isDeleting || _isSaving
                      ? null
                      : () async {
                          final newName = _nameController.text.trim();
                          if (newName.isEmpty ||
                              newName == device.label) {
                            context.pop();
                            return;
                          }
                          setState(() => _isSaving = true);
                          try {
                            await DeviceApiService().updateDevice(
                              device.id,
                              {'label': newName},
                            );
                            if (!context.mounted) return;
                            context.pop();
                            widget.onDeviceUpdatedOrDeleted();
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                          if (mounted) {
                            setState(() => _isSaving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003092),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
