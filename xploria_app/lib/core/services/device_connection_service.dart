import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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

  final StreamController<Map<String, dynamic>> _telemetryController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get telemetryStream => _telemetryController.stream;

  // Bluetooth State
  BluetoothDevice? _selectedDevice;
  BluetoothDevice? get selectedDevice => _selectedDevice;

  List<BluetoothDevice> _devicesList = [];
  List<BluetoothDevice> get devicesList => _devicesList;

  StreamSubscription<BluetoothConnectionState>? _btConnectionStateSub;
  StreamSubscription<List<int>>? _btDataSub;
  BluetoothCharacteristic? _writeCharacteristic;

  // Wi-Fi State
  WebSocketChannel? _webSocketChannel;
  String? _connectedIp;
  String? get connectedIp => _connectedIp;

  String? _connectedDeviceId;
  String? get connectedDeviceId => _connectedDeviceId;

  // Telemetry Stream
  final StreamController<Map<String, dynamic>> _telemetryController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get telemetryStream =>
      _telemetryController.stream;
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
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.off) {
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

      // Mengambil daftar perangkat yang sudah terikat sistem (bonded devices)
      final systemDevices = await FlutterBluePlus.systemDevices([]);
      _devicesList = systemDevices.toList();

      for (var dev in _devicesList) {
        final nameLower = dev.advName.toLowerCase();
        if (nameLower.contains('xploria') ||
            nameLower.contains('orange') ||
            nameLower.contains('jeruk') ||
            nameLower.contains('rpi')) {
          _selectedDevice = dev;
          break;
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
      final dev = _devicesList.firstWhere((d) => d.remoteId.str == macAddress);
      _selectedDevice = dev;
      await connectBluetooth(deviceId: deviceId);
    } catch (e) {
      // Jika tidak ditemukan di bonded devices, coba gunakan constructor RemoteId langsung
      _selectedDevice = BluetoothDevice.fromId(macAddress);
      await connectBluetooth(deviceId: deviceId);
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
        "Menghubungkan ke ${_selectedDevice!.advName.isNotEmpty ? _selectedDevice!.advName : _selectedDevice!.remoteId.str}...";
    notifyListeners();

    try {
      await _selectedDevice!.connect(
        timeout: const Duration(seconds: 15),
        license: License.nonprofit,
      );

      // Temukan characteristic untuk write/read (Contoh menggunakan standar NUS - Nordic UART Service)
      List<BluetoothService> services = await _selectedDevice!
          .discoverServices();
      _writeCharacteristic = null;
      BluetoothCharacteristic? readCharacteristic;

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
          }
          if (characteristic.properties.notify ||
              characteristic.properties.read) {
            readCharacteristic = characteristic;
          }
        }
      }

      if (readCharacteristic != null && readCharacteristic.properties.notify) {
        await readCharacteristic.setNotifyValue(true);
        _btDataSub = readCharacteristic.lastValueStream.listen((value) {
          if (value.isNotEmpty) {
            final decoded = utf8.decode(value).trim();
            if (decoded.isNotEmpty) {
              _handleIncomingMessage(decoded);
            }
          }
        });
      }

      // Memonitor status koneksi
      _btConnectionStateSub = _selectedDevice!.connectionState.listen((
        BluetoothConnectionState state,
      ) {
        if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _statusMessage = "Koneksi Terputus";
          addLog("Koneksi Bluetooth Terputus");
          _btConnectionStateSub?.cancel();
          _btDataSub?.cancel();
          notifyListeners();
        }
      });

      _isConnected = true;
      _isConnecting = false;
      _statusMessage = "Berhasil terhubung ke ${_selectedDevice!.advName}!";
      addLog(
        "Berhasil terhubung ke Bluetooth: ${_selectedDevice!.remoteId.str}",
      );
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _isConnecting = false;
      _statusMessage = "Gagal terhubung ke perangkat. $e";
      notifyListeners();
    }
  }

  void _handleIncomingMessage(String decoded) {
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
      await _webSocketChannel!.ready.timeout(const Duration(seconds: 10));

      _isConnected = true;
      _isConnecting = false;
      _connectedIp = address;
      _statusMessage = "Berhasil terhubung ke $address!";
      addLog("Berhasil terhubung ke WebSocket: $urlStr");
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
                addLog("[RX] $msgStr"); // fallback
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
      _statusMessage = "Gagal konek: $e";
      notifyListeners();
    }
  }

  void disconnect({bool silent = false}) {
    if (_connectionMode == ConnectionMode.bluetooth) {
      _btConnectionStateSub?.cancel();
      _btDataSub?.cancel();
      _selectedDevice?.disconnect();
      _writeCharacteristic = null;
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
      if (_writeCharacteristic != null) {
        try {
          await _writeCharacteristic!.write(utf8.encode("$jsonPayload\n"));
        } catch (e) {
          addLog("[ERROR] Gagal mengirim data bluetooth: $e");
        }
      } else {
        addLog("[ERROR] Device tidak mendukung Write Characteristic");
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
      if (_writeCharacteristic != null) {
        try {
          await _writeCharacteristic!.write(utf8.encode("$jsonPayload\n"));
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
    if (_connectionMode == ConnectionMode.wifi) {
      if (_webSocketChannel != null) {
        final jsonPayload = jsonEncode(payload);
        _webSocketChannel!.sink.add("$jsonPayload\n");
        addLog("[TX] Dikirim via WiFi");
      } else {
        addLog("[ERROR] WiFi belum tersambung.");
      }
    } else {
      if (_writeCharacteristic != null) {
        final jsonPayload = jsonEncode(payload);
        try {
          _writeCharacteristic!.write(utf8.encode("$jsonPayload\n"));
          addLog("[TX] Dikirim via Bluetooth");
        } catch(e) {
            addLog("[ERROR] Gagal mengirim data bluetooth: $e");
        }
      } else {
        addLog("[ERROR] Bluetooth belum tersambung atau write characteristic tidak ditemukan.");
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
