import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/blockly_bridge.dart';
import '../domain/workspace_state.dart';

class BlocklyWorkspaceScreen extends StatefulWidget {
  final Function(String pythonCode)? onRunCode;

  const BlocklyWorkspaceScreen({super.key, this.onRunCode});

  @override
  State<BlocklyWorkspaceScreen> createState() => _BlocklyWorkspaceScreenState();
}

class _BlocklyWorkspaceScreenState extends State<BlocklyWorkspaceScreen> {
  late final WebViewController _controller;
  WorkspaceState _state = const WorkspaceState();
  String _projectName = 'Project';

  // Flag status koneksi device
  bool _isDeviceConnected = false;

  // TODO: Integrasikan fungsi ini dengan SDK/Package Bluetooth/WiFi nyata nantinya
  void _connectToDevice() async {
    // Tampilkan indikator proses menghubungkan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mencari dan menghubungkan ke device...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulasi delay koneksi (2 detik)
    await Future.delayed(const Duration(seconds: 2));

    // Update state menjadi terkoneksi
    if (mounted) {
      setState(() {
        _isDeviceConnected = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil terhubung ke device!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
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

  void _showPythonCodeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generated Python Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _state.pythonCode.isEmpty
                          ? '# Susun blok untuk menghasilkan kode'
                          : _state.pythonCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFF9CDCFE),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
              color: AppColors.primaryLight.withOpacity(0.2),
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
            onPressed: _showPythonCodeModal,
          ),
          // Tombol Connect atau Run tergantung status koneksi
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _isDeviceConnected
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mengirim kode Python ke device...',
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
                    icon: const Icon(Icons.bluetooth, size: 20),
                    label: const Text(
                      'Connect',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    onPressed: _connectToDevice,
                  ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_state.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
