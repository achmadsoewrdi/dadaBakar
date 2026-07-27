import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/device_connection_service.dart';
import '../../../device/presentation/pages/device_connection_screen.dart';
import '../../data/blockly_bridge.dart';
import '../../domain/workspace_state.dart';
import 'python_editor_screen.dart';

class BlocklyWorkspaceScreen extends StatefulWidget {
  final Function(String pythonCode)? onRunCode;

  const BlocklyWorkspaceScreen({super.key, this.onRunCode});

  @override
  State<BlocklyWorkspaceScreen> createState() => _BlocklyWorkspaceScreenState();
}

class _BlocklyWorkspaceScreenState extends State<BlocklyWorkspaceScreen> {
  WebViewController? _controller;
  WorkspaceState _state = const WorkspaceState();
  String _projectName = 'Project';

  void _navigateToConnection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceConnectionScreen()),
    );
  }

  void _editProjectName() {
    final TextEditingController controller = TextEditingController(
      text: _projectName,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Nama Project'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama project...',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _projectName = controller.text.trim().isNotEmpty
                      ? controller.text.trim()
                      : 'Project';
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    if (kIsWeb) {
      setState(() {
        _state = _state.copyWith(isLoading: false);
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'FlutterBlocklyBridge',
        onMessageReceived: (JavaScriptMessage message) {
          final bridgeMsg = BlocklyBridgeMessage.fromJsonString(
            message.message,
          );
          if (bridgeMsg.type == 'WORKSPACE_UPDATE') {
            setState(() {
              _state = _state.copyWith(
                pythonCode: bridgeMsg.pythonCode,
                xmlData: bridgeMsg.xmlData,
              );
            });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _state = _state.copyWith(isLoading: false);
            });
          },
        ),
      )
      ..loadFlutterAsset('assets/blockly/index.html');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: InkWell(
          onTap: _editProjectName,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _projectName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
        actions: [
          // Tombol Lihat Kode Python
          IconButton(
            icon: const Icon(Icons.code, color: Colors.white),
            tooltip: 'Lihat Kode Python',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PythonEditorScreen(
                    initialCode: _state.pythonCode,
                  ),
                ),
              );
            },
          ),
          // Tombol Connect atau Run tergantung status koneksi
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ListenableBuilder(
              listenable: DeviceConnectionService.instance,
              builder: (context, _) {
                final isDeviceConnected = DeviceConnectionService.instance.isConnected;
                return isDeviceConnected
                    ? ElevatedButton.icon(
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
                        label: const Text(
                          'Run',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _state.pythonCode.trim().isEmpty
                            ? null
                            : () {
                                if (widget.onRunCode != null) {
                                  widget.onRunCode!(_state.pythonCode);
                                }
                                // Send payload using the shared connection service
                                DeviceConnectionService.instance.sendData(_state.pythonCode);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Mengirim kode ke device...',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
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
                        label: const Text(
                          'Connect',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        onPressed: _navigateToConnection,
                      );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (kIsWeb || _controller == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.code_rounded, size: 64, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Blockly Workspace (Visual Coding)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Webview Blockly siap dijalankan di Android & iOS.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            WebViewWidget(controller: _controller!),
            if (_state.isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

