import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionMode { bluetooth, wifi }

class DeviceConnectionService extends ChangeNotifier {
  // Singleton instance
  static final DeviceConnectionService _instance = DeviceConnectionService._internal();
  static DeviceConnectionService get instance => _instance;

  DeviceConnectionService._internal();

  ConnectionMode _connectionMode = ConnectionMode.wifi;
  ConnectionMode get connectionMode => _connectionMode;

  // Bluetooth State
  BluetoothConnection? _bluetoothConnection;
  List<BluetoothDevice> _devicesList = [];
  List<BluetoothDevice> get devicesList => _devicesList;
  
  BluetoothDevice? _selectedDevice;
  BluetoothDevice? get selectedDevice => _selectedDevice;

  // Wi-Fi State
  WebSocketChannel? _webSocketChannel;
  String? _connectedIp;
  String? get connectedIp => _connectedIp;

  // Generic State
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  String _statusMessage = "Belum ada device tersambung";
  String get statusMessage => _statusMessage;

  // Terminal Logs State
  final List<String> _terminalLogs = [];
  List<String> get terminalLogs => _terminalLogs;

  void addLog(String log) {
    // Prefix with timestamp
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    _terminalLogs.add("[$timeStr] $log");
    
    // Keep only last 100 logs to prevent memory bloat
    if (_terminalLogs.length > 100) {
      _terminalLogs.removeAt(0);
    }
    notifyListeners();
  }

  void clearLogs() {
    _terminalLogs.clear();
    notifyListeners();
  }

  void setConnectionMode(ConnectionMode mode) {
    if (_isConnected || _isConnecting) return;
    _connectionMode = mode;
    _statusMessage = "Belum ada device tersambung";
    notifyListeners();
  }

  void setSelectedDevice(BluetoothDevice? device) {
    _selectedDevice = device;
    notifyListeners();
  }

  Future<void> loadPairedDevices({bool silent = false}) async {
    try {
      // Request permissions required for Android 12+
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();
      
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      _devicesList = devices;
      for (var dev in devices) {
        if (dev.name != null) {
          final nameLower = dev.name!.toLowerCase();
          if (nameLower.contains('xploria') || nameLower.contains('orange') || nameLower.contains('jeruk')) {
            _selectedDevice = dev;
            break;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      if (!silent) {
        _statusMessage = "Gagal membaca Bluetooth: $e";
        notifyListeners();
      }
    }
  }

  Future<void> connectBluetoothByMac(String macAddress) async {
    try {
      final dev = _devicesList.firstWhere((d) => d.address == macAddress);
      _selectedDevice = dev;
      await connectBluetooth();
    } catch (e) {
      _statusMessage = "Perangkat Bluetooth tidak ditemukan di daftar pairing.";
      notifyListeners();
    }
  }

  Future<void> connectBluetooth() async {
    if (_selectedDevice == null) return;
    
    _isConnecting = true;
    _statusMessage = "Menghubungkan ke ${_selectedDevice!.name}...";
    notifyListeners();

    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(_selectedDevice!.address);
      
      _bluetoothConnection = connection;
      _isConnected = true;
      _isConnecting = false;
      _statusMessage = "Berhasil terhubung ke ${_selectedDevice!.name}!";
      addLog("Berhasil terhubung ke Bluetooth: ${_selectedDevice!.name}");
      notifyListeners();

      connection.input!.listen((Uint8List data) {
        final decoded = utf8.decode(data).trim();
        if (decoded.isNotEmpty) {
          debugPrint("Menerima Balasan: $decoded");
          try {
            final dataJson = jsonDecode(decoded);
            if (dataJson['type'] == 'output') {
              addLog("[RX] ${dataJson['payload']}");
            } else if (dataJson['type'] == 'error') {
              addLog("[ERROR] ${dataJson['payload']}");
            } else if (dataJson['type'] == 'pong') {
              addLog("[RX] PONG (Koneksi Stabil)");
            } else {
              addLog("[RX] $decoded"); // fallback
            }
          } catch (e) {
            addLog("[RX] $decoded");
          }
        }
      }).onDone(() {
        _isConnected = false;
        _statusMessage = "Koneksi Terputus";
        addLog("Koneksi Bluetooth Terputus");
        notifyListeners();
      });
    } catch (e) {
      _isConnected = false;
      _isConnecting = false;
      
      //eror handling ketika bluetooth tidak terhubung, tapi di flutter mencoba menghubungkan
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('read failed') || errorStr.contains('socket might closed')) {
        _statusMessage = "Koneksi ditolak. Pastikan perangkat menyala, belum terhubung ke alat lain, dan sudah dipasangkan (paired) dengan HP ini.";
      } else if (errorStr.contains('timeout')) {
        _statusMessage = "Waktu koneksi habis. Pastikan perangkat berada di dekat HP Anda.";
      } else {
        _statusMessage = "Gagal terhubung ke perangkat. Silakan coba lagi.";
      }
      
      notifyListeners();
    }
  }

  Future<void> connectWifi(String address, String port) async {
    if (address.isEmpty) return;

    _isConnecting = true;
    _statusMessage = port.isNotEmpty ? "Menghubungkan ke $address:$port..." : "Menghubungkan ke $address...";
    notifyListeners();

    try {
      final cleanAddress = address.trim();
      final cleanPort = port.trim();
      String urlStr = cleanAddress;
      if (!urlStr.startsWith('ws://') && !urlStr.startsWith('wss://')) {
        urlStr = 'ws://$cleanAddress';
      }
      if (cleanPort.isNotEmpty && !urlStr.contains(':$cleanPort')) {
        urlStr = '$urlStr:$cleanPort';
      }

      final wsUrl = Uri.parse(urlStr);
      _webSocketChannel = WebSocketChannel.connect(wsUrl);

      _isConnected = true;
      _isConnecting = false;
      _connectedIp = address;
      _statusMessage = "Berhasil terhubung ke $address!";
      addLog("Berhasil terhubung ke WebSocket: $urlStr");
      notifyListeners();

      _webSocketChannel!.stream.listen((message) {
        final msgStr = message.toString().trim();
        if (msgStr.isNotEmpty) {
          debugPrint("Menerima Balasan (WiFi): $msgStr");
          try {
            final data = jsonDecode(msgStr);
            if (data['type'] == 'output') {
              addLog("[RX] ${data['payload']}");
            } else if (data['type'] == 'error') {
              addLog("[ERROR] ${data['payload']}");
            } else if (data['type'] == 'pong') {
              addLog("[RX] PONG (Koneksi Stabil)");
            } else {
              addLog("[RX] $msgStr"); // fallback
            }
          } catch (e) {
            addLog("[RX] $msgStr");
          }
        }
      }, onDone: () {
        _isConnected = false;
        _statusMessage = "Koneksi Terputus";
        addLog("Koneksi Wi-Fi Terputus");
        notifyListeners();
      }, onError: (error) {
        _isConnected = false;
        _statusMessage = "Error Koneksi: $error";
        addLog("Error Koneksi Wi-Fi: $error");
        notifyListeners();
      });
    } catch (e) {
      _isConnected = false;
      _isConnecting = false;
      _statusMessage = "Gagal konek: $e";
      notifyListeners();
    }
  }

  void disconnect({bool silent = false}) {
    if (_connectionMode == ConnectionMode.bluetooth) {
      _bluetoothConnection?.finish();
      _bluetoothConnection = null;
    } else {
      _webSocketChannel?.sink.close();
      _webSocketChannel = null;
    }
    
    if (!silent) {
      _isConnected = false;
      _isConnecting = false;
      _statusMessage = "Dibatalkan oleh pengguna";
      notifyListeners();
    }
  }

  void sendData(String command) {
    if (!_isConnected) return;

    final trimmedCommand = command.trim();
    if (trimmedCommand.isEmpty) return;

    // Wrap the command in a JSON payload matching the Raspberry Pi / Orange Pi server
    final String jsonPayload = jsonEncode({
      "type": "run",
      "code": trimmedCommand,
    });

    addLog("[TX] $jsonPayload");

    if (_connectionMode == ConnectionMode.bluetooth) {
      if (_bluetoothConnection != null) {
        _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("$jsonPayload\n")));
      }
    } else {
      if (_webSocketChannel != null) {
        _webSocketChannel!.sink.add("$jsonPayload\n");
      }
    }
  }

  void stopCode() {
    if (!_isConnected) return;

    final String jsonPayload = jsonEncode({
      "type": "stop"
    });

    addLog("[TX] $jsonPayload");

    if (_connectionMode == ConnectionMode.bluetooth) {
      if (_bluetoothConnection != null) {
        _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("$jsonPayload\n")));
      }
    } else {
      if (_webSocketChannel != null) {
        _webSocketChannel!.sink.add("$jsonPayload\n");
      }
    }
  }
}