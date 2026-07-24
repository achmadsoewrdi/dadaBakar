import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
      appBar: AppBar(
        title: const Text('Blockly Workspace'),
        actions: [
          // Tombol Lihat Kode Python
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Lihat Kode Python',
            onPressed: _showPythonCodeModal,
          ),
          // Tombol Jalankan / Kirim Kode ke Device
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run'),
              onPressed: _state.pythonCode.trim().isEmpty
                  ? null
                  : () {
                      if (widget.onRunCode != null) {
                        widget.onRunCode!(_state.pythonCode);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mengirim kode Python ke device...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
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
