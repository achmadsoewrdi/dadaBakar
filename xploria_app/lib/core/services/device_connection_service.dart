import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:multicast_dns/multicast_dns.dart';
import '../../features/device/domain/device_entity.dart';
import '../../features/device/data/data_sources/device_remote_data_source.dart';

enum ConnectionMode { bluetooth, wifi, drone }

class DeviceConnectionService extends ChangeNotifier {
  static final DeviceConnectionService _instance =
      DeviceConnectionService._internal();
  static DeviceConnectionService get instance => _instance;

  DeviceConnectionService._internal() {
    _initBluetoothEvents();
  }

  ConnectionMode _connectionMode = ConnectionMode.wifi;
  ConnectionMode get connectionMode => _connectionMode;

  final StreamController<Map<String, dynamic>> _telemetryController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get telemetryStream =>
      _telemetryController.stream;

  // Bluetooth State
  BluetoothDevice? _selectedDevice;
  BluetoothDevice? get selectedDevice => _selectedDevice;

  List<BluetoothDevice> _devicesList = [];
  List<BluetoothDevice> get devicesList => _devicesList;

  BluetoothConnection? _bluetoothConnection;
  StreamSubscription<Uint8List>? _btDataSub;

  // Wi-Fi State
  WebSocketChannel? _webSocketChannel;
  String? _connectedIp;
  String? get connectedIp => _connectedIp;

  String? _connectedDeviceId;
  String? get connectedDeviceId => _connectedDeviceId;

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

  // Saved Devices from API
  final DeviceRemoteDataSource _remoteDataSource = DeviceRemoteDataSource();
  List<DeviceEntity> _savedDevices = [];
  List<DeviceEntity> get savedDevices => _savedDevices;
  bool _isLoadingSavedDevices = false;
  bool get isLoadingSavedDevices => _isLoadingSavedDevices;

  void _initBluetoothEvents() {
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      if (state == BluetoothState.STATE_OFF) {
        if (_connectionMode == ConnectionMode.bluetooth && _isConnected) {
          disconnect();
          _statusMessage = "Bluetooth dimatikan";
          notifyListeners();
        }
      }
    });
  }

  Future<void> fetchSavedDevices() async {
    _isLoadingSavedDevices = true;
    notifyListeners();
    try {
      _savedDevices = await _remoteDataSource.getDevices();
    } catch (e) {
      debugPrint('Failed to fetch saved devices: $e');
    } finally {
      _isLoadingSavedDevices = false;
      notifyListeners();
    }
  }

  Future<String?> saveDeviceToCloud({
    required String label,
    required String protocol,
    String? host,
    int? port,
    String? macAddress,
  }) async {
    try {
      if (protocol == 'wifi' && host != null) {
        final isDuplicate = _savedDevices.any((device) =>
            device.protocol == 'wifi' && device.host == host);
        if (isDuplicate) {
          return "Perangkat Wi-Fi dengan alamat ini sudah tersimpan.";
        }
      } else if (protocol == 'bluetooth' && macAddress != null) {
        final isDuplicate = _savedDevices.any((device) =>
            device.protocol == 'bluetooth' && device.macAddress == macAddress);
        if (isDuplicate) {
          return "Perangkat Bluetooth ini sudah tersimpan.";
        }
      }

      final newDevice = await _remoteDataSource.saveDevice(
        label: label,
        protocol: protocol,
        host: host,
        port: port,
        macAddress: macAddress,
      );
      _savedDevices.add(newDevice);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void addLog(String log) {
    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    _terminalLogs.add("[$timeStr] $log");

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
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();

      final devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      _devicesList = devices;

      for (var dev in _devicesList) {
        if (dev.name != null) {
          final nameLower = dev.name!.toLowerCase();
          if (nameLower.contains('xploria') ||
              nameLower.contains('orange') ||
              nameLower.contains('jeruk') ||
              nameLower.contains('rpi')) {
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

  Future<void> connectBluetoothByMac(
    String macAddress, {
    String? deviceId,
  }) async {
    try {
      if (_devicesList.isEmpty) {
        await loadPairedDevices(silent: true);
      }
      final dev = _devicesList.firstWhere((d) => d.address == macAddress);
      _selectedDevice = dev;
      await connectBluetooth(deviceId: deviceId);
    } catch (e) {
      _statusMessage = "Perangkat Bluetooth tidak ditemukan di daftar pairing.";
      notifyListeners();
    }
  }

  Future<void> connectBluetooth({String? deviceId}) async {
    if (_selectedDevice == null) return;

    if (_isConnected) {
      disconnect(silent: true);
    }

    _isConnecting = true;
    _connectedDeviceId = deviceId;
    _statusMessage =
        "Menghubungkan ke ${_selectedDevice!.name ?? _selectedDevice!.address}...";
    notifyListeners();

    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(
        _selectedDevice!.address,
      ).timeout(const Duration(seconds: 15));

      _bluetoothConnection = connection;
      _isConnected = true;
      _isConnecting = false;
      _statusMessage =
          "Berhasil terhubung ke ${_selectedDevice!.name ?? _selectedDevice!.address}!";
      addLog(
        "Berhasil terhubung ke Bluetooth: ${_selectedDevice!.name ?? _selectedDevice!.address}",
      );
      notifyListeners();

      _btDataSub = connection.input!.listen(
        (Uint8List data) {
          final decoded = utf8.decode(data).trim();
          if (decoded.isNotEmpty) {
            _handleIncomingMessage(decoded);
          }
        },
        onDone: () {
          _isConnected = false;
          _statusMessage = "Koneksi Terputus";
          addLog("Koneksi Bluetooth Terputus");
          _btDataSub?.cancel();
          _bluetoothConnection = null;
          notifyListeners();
        },
        onError: (error) {
          _isConnected = false;
          _statusMessage = "Koneksi Error: $error";
          addLog("Koneksi Bluetooth Error: $error");
          _btDataSub?.cancel();
          _bluetoothConnection = null;
          notifyListeners();
        },
      );
    } catch (e) {
      _isConnected = false;
      _isConnecting = false;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('read failed') ||
          errorStr.contains('socket might closed')) {
        _statusMessage =
            "Koneksi ditolak. Pastikan perangkat menyala, belum terhubung ke alat lain, dan sudah dipasangkan (paired) dengan HP ini.";
      } else if (errorStr.contains('timeout')) {
        _statusMessage =
            "Waktu koneksi habis. Pastikan perangkat berada di dekat HP Anda.";
      } else {
        _statusMessage = "Gagal terhubung ke perangkat. Silakan coba lagi.";
      }

      notifyListeners();
    }
  }

  void _handleIncomingMessage(String decoded) {
    debugPrint("Menerima Balasan: $decoded");
    try {
      final dataJson = jsonDecode(decoded);
      if (dataJson['type'] == 'telemetry') {
        _telemetryController.add(dataJson);
      } else if (dataJson['type'] == 'output') {
        addLog("[RX] ${dataJson['payload']}");
      } else if (dataJson['type'] == 'error') {
        addLog("[ERROR] ${dataJson['payload']}");
      } else if (dataJson['type'] == 'pong') {
        addLog("[RX] PONG (Koneksi Stabil)");
      } else {
        addLog("[RX] $decoded");
      }
    } catch (e) {
      addLog("[RX] $decoded");
    }
  }

  Future<void> connectWifi(
    String address,
    String port, {
    bool silent = false,
    String? deviceId,
  }) async {
    if (_isConnected) {
      disconnect(silent: true);
    }
    if (address.isEmpty) return;

    _isConnecting = true;
    _connectedDeviceId = deviceId;
    _statusMessage = port.isNotEmpty
        ? "Menghubungkan ke $address:$port..."
        : "Menghubungkan ke $address...";
    notifyListeners();

    try {
      String cleanAddress = address.replaceAll(' ', '');
      final cleanPort = port.trim();

      // 1. Konversi protocol http/https ke ws/wss jika user mengetikkannya
      if (cleanAddress.startsWith('http://')) {
        cleanAddress = cleanAddress.replaceFirst('http://', 'ws://');
      } else if (cleanAddress.startsWith('https://')) {
        cleanAddress = cleanAddress.replaceFirst('https://', 'wss://');
      } else if (!cleanAddress.startsWith('ws://') && !cleanAddress.startsWith('wss://')) {
        cleanAddress = 'ws://$cleanAddress';
      }

      final parsedUri = Uri.parse(cleanAddress);
      String hostToConnect = parsedUri.host;

      // RESOLVE MDNS UNTUK ANDROID
      if (hostToConnect.endsWith('.local')) {
        addLog("Mencari IP untuk $hostToConnect via mDNS...");
        final MDnsClient client = MDnsClient();
        await client.start();
        
        bool found = false;
        await for (final IPAddressResourceRecord ptr in client.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(hostToConnect))) {
          hostToConnect = ptr.address.address;
          found = true;
          addLog("Berhasil resolve mDNS: $hostToConnect");
          break;
        }
        client.stop();
        
        if (!found) {
          throw Exception("Gagal resolve domain .local, pastikan berada di jaringan Wi-Fi yang sama.");
        }
      }
      
      // 2. Jika port diisi secara terpisah, masukkan port ke lokasi URI yang benar
      Uri wsUrl = parsedUri.replace(host: hostToConnect);
      if (cleanPort.isNotEmpty) {
        final intPort = int.tryParse(cleanPort);
        if (intPort != null) {
          wsUrl = wsUrl.replace(port: intPort);
        }
      }

      _webSocketChannel = WebSocketChannel.connect(wsUrl);
      await _webSocketChannel!.ready.timeout(const Duration(seconds: 10));

      _isConnected = true;
      _isConnecting = false;
      _connectedIp = address;
      _statusMessage = "Berhasil terhubung ke $address!";
      addLog("Berhasil terhubung ke WebSocket: $wsUrl");
      notifyListeners();

      _webSocketChannel!.stream.listen(
        (message) {
          final msgStr = message.toString().trim();
          if (msgStr.isNotEmpty) {
            debugPrint("Menerima Balasan (WiFi): $msgStr");
            try {
              final data = jsonDecode(msgStr);
              if (data['type'] == 'telemetry') {
                _telemetryController.add(data);
              } else if (data['type'] == 'output') {
                addLog("[RX] ${data['payload']}");
              } else if (data['type'] == 'error') {
                addLog("[ERROR] ${data['payload']}");
              } else if (data['type'] == 'pong') {
                addLog("[RX] PONG (Koneksi Stabil)");
              } else {
                addLog("[RX] $msgStr");
              }
            } catch (e) {
              addLog("[RX] $msgStr");
            }
          }
        },
        onDone: () {
          _isConnected = false;
          _statusMessage = "Koneksi Terputus";
          addLog("Koneksi Wi-Fi Terputus");
          notifyListeners();
        },
        onError: (error) {
          _isConnected = false;
          _statusMessage = "Error Koneksi: $error";
          addLog("Error Koneksi Wi-Fi: $error");
          notifyListeners();
        },
      );
    } catch (e) {
      _isConnected = false;
      _isConnecting = false;
      final errStr = e.toString();
      if (errStr.contains('Failed host lookup') && address.contains('.local')) {
        _statusMessage = "Android tidak mendukung domain .local secara langsung. Gunakan IP Address Wi-Fi Raspberry Pi (contoh: 192.168.x.x).";
      } else if (errStr.contains('Failed host lookup')) {
        _statusMessage = "Domain / Hostname tidak ditemukan. Pastikan alamat IP atau domain benar.";
      } else {
        _statusMessage = "Gagal konek: $e";
      }
      notifyListeners();
    }
  }

  void disconnect({bool silent = false}) {
    if (_connectionMode == ConnectionMode.bluetooth) {
      _btDataSub?.cancel();
      _bluetoothConnection?.finish();
      _bluetoothConnection = null;
    } else {
      _webSocketChannel?.sink.close();
      _webSocketChannel = null;
    }
    _connectedDeviceId = null;

    if (!silent) {
      _isConnected = false;
      _isConnecting = false;
      _statusMessage = "Dibatalkan oleh pengguna";
      notifyListeners();
    }
  }

  Future<void> sendData(String command) async {
    if (!_isConnected) return;

    final trimmedCommand = command.trim();
    if (trimmedCommand.isEmpty) return;

    final String jsonPayload = jsonEncode({
      "type": "run",
      "code": trimmedCommand,
    });

    addLog("[TX] $jsonPayload");

    if (_connectionMode == ConnectionMode.bluetooth) {
      if (_bluetoothConnection != null && _bluetoothConnection!.isConnected) {
        try {
          _bluetoothConnection!.output.add(
            Uint8List.fromList(utf8.encode("$jsonPayload\n")),
          );
          await _bluetoothConnection!.output.allSent;
        } catch (e) {
          addLog("[ERROR] Gagal mengirim data bluetooth: $e");
        }
      } else {
        addLog("[ERROR] Bluetooth belum tersambung.");
      }
    } else {
      if (_webSocketChannel != null) {
        _webSocketChannel!.sink.add("$jsonPayload\n");
      }
    }
  }

  Future<void> stopCode() async {
    if (!_isConnected) return;

    final String jsonPayload = jsonEncode({"type": "stop"});

    addLog("[TX] $jsonPayload");

    if (_connectionMode == ConnectionMode.bluetooth) {
      if (_bluetoothConnection != null && _bluetoothConnection!.isConnected) {
        try {
          _bluetoothConnection!.output.add(
            Uint8List.fromList(utf8.encode("$jsonPayload\n")),
          );
          await _bluetoothConnection!.output.allSent;
        } catch (e) {
          addLog("[ERROR] Gagal mengirim data bluetooth: $e");
        }
      }
    } else {
      if (_webSocketChannel != null) {
        _webSocketChannel!.sink.add("$jsonPayload\n");
      }
    }
  }

  void sendCodePayload(Map<String, dynamic> payload) {
    final String jsonPayload = jsonEncode(payload);
    if (_connectionMode == ConnectionMode.wifi) {
      if (_webSocketChannel != null) {
        _webSocketChannel!.sink.add("$jsonPayload\n");
        addLog("[TX] Dikirim via WiFi");
      } else {
        addLog("[ERROR] WiFi belum tersambung.");
      }
    } else {
      if (_bluetoothConnection != null && _bluetoothConnection!.isConnected) {
        try {
          _bluetoothConnection!.output.add(
            Uint8List.fromList(utf8.encode("$jsonPayload\n")),
          );
          addLog("[TX] Dikirim via Bluetooth");
        } catch (e) {
          addLog("[ERROR] Gagal mengirim data bluetooth: $e");
        }
      } else {
        addLog("[ERROR] Bluetooth belum tersambung.");
      }
    }
  }

  void sendControl(String pin, dynamic value) {
    final payload = {"type": "control", "pin": pin, "value": value};
    sendCodePayload(payload);
  }

  Future<bool> deleteSavedDevice(String deviceId) async {
    final success = await _remoteDataSource.deleteDevice(deviceId);
    if (success) {
      _savedDevices.removeWhere((d) => d.id == deviceId);
      if (_connectedDeviceId == deviceId) {
        disconnect();
      }
      notifyListeners();
    }
    return success;
  }
}
