import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/device_connection_service.dart';
import '../../../device/presentation/pages/device_connection_screen.dart';

class PythonEditorScreen extends StatefulWidget {
  final String initialCode;

  const PythonEditorScreen({super.key, required this.initialCode});

  @override
  State<PythonEditorScreen> createState() => _PythonEditorScreenState();
}

class _PythonEditorScreenState extends State<PythonEditorScreen> {
  late TextEditingController _codeController;
  final ScrollController _terminalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _terminalScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_terminalScrollController.hasClients) {
      _terminalScrollController.animateTo(
        _terminalScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _runCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    if (!DeviceConnectionService.instance.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device belum terhubung. Silakan hubungkan terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DeviceConnectionScreen()),
      );
      return;
    }

    DeviceConnectionService.instance.sendData(code);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode dikirim ke device!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        title: const Text('Python Editor', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0A122C),
        actions: [
          ListenableBuilder(
            listenable: DeviceConnectionService.instance,
            builder: (context, _) {
              final isConnected = DeviceConnectionService.instance.isConnected;
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: isConnected
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            icon: const Icon(Icons.stop, size: 20),
                            label: const Text('Stop', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                               DeviceConnectionService.instance.stopCode();
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Perintah stop dikirim ke device!'),
                                   duration: Duration(seconds: 1),
                                 ),
                               );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            icon: const Icon(Icons.play_arrow, size: 20),
                            label: const Text('Run', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: _runCode,
                          ),
                        ],
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        icon: const Icon(Icons.link, size: 20),
                        label: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DeviceConnectionScreen()),
                          );
                        },
                      ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Code Editor Section
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // VS Code Dark Theme color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: const Color(0xFF2D2D2D),
                      width: double.infinity,
                      child: const Row(
                        children: [
                          Icon(Icons.code, color: Colors.grey, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'main.py',
                            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _codeController,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF9CDCFE),
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '# Tulis kode Python kamu di sini...',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Terminal Section
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Terminal Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF333333),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.terminal, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Terminal',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            DeviceConnectionService.instance.clearLogs();
                          },
                          child: const Icon(Icons.delete_sweep, color: Colors.grey, size: 20),
                        ),
                      ],
                    ),
                  ),
                  // Terminal Logs
                  Expanded(
                    child: ListenableBuilder(
                      listenable: DeviceConnectionService.instance,
                      builder: (context, _) {
                        final logs = DeviceConnectionService.instance.terminalLogs;
                        
                        // Auto scroll to bottom when new logs arrive
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });

                        if (logs.isEmpty) {
                          return const Center(
                            child: Text(
                              'Tidak ada output terminal.',
                              style: TextStyle(color: Colors.grey, fontFamily: 'monospace'),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _terminalScrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            Color logColor = Colors.white;
                            if (log.contains('[ERROR]')) {
                              logColor = Colors.redAccent;
                            } else if (log.contains('[TX]')) {
                              logColor = Colors.greenAccent;
                            } else if (log.contains('[RX]')) {
                              logColor = Colors.lightBlueAccent;
                            } else if (log.toLowerCase().contains('error') || log.toLowerCase().contains('gagal')) {
                              logColor = Colors.redAccent;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                log,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: logColor,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

