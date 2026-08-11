import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class TelloService extends ChangeNotifier {
  static final TelloService _instance = TelloService._internal();
  static TelloService get instance => _instance;

  TelloService._internal();

  RawDatagramSocket? _socket;
  final String telloIp = '192.168.10.1';
  final int telloPort = 8889;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String _statusMessage = 'Belum terhubung ke Tello';
  String get statusMessage => _statusMessage;

  final List<String> _logs = [];
  List<String> get logs => _logs;

  // Queue system for sequential commands
  final List<String> _commandQueue = [];
  bool _isWaitingForResponse = false;
  Completer<bool>? _currentCommandCompleter;
  Timer? _commandTimeout;

  void addLog(String log) {
    final timeStr = DateTime.now().toIso8601String().split('T')[1].substring(0, 8);
    _logs.add("[$timeStr] $log");
    if (_logs.length > 50) _logs.removeAt(0);
    notifyListeners();
  }

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  Future<bool> connect() async {
    if (_isConnecting) return false;
    
    _isConnecting = true;
    notifyListeners();

    try {
      _socket?.close();
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket!.listen(_onReceiveData);

      _statusMessage = 'Mencoba terhubung...';
      notifyListeners();

      // Cancel previous command if any
      if (_currentCommandCompleter != null && !_currentCommandCompleter!.isCompleted) {
        _currentCommandCompleter!.complete(false);
        _currentCommandCompleter = null;
      }

      // Send initial "command" to enter SDK mode
      final success = await sendCommand('command');
      
      _isConnecting = false;
      if (success) {
        _isConnected = true;
        _statusMessage = 'Tersambung ke Tello (UDP)';
        addLog('Tello SDK Mode: OK');
        notifyListeners();
        return true;
      } else {
        _isConnected = false;
        _statusMessage = 'Gagal masuk ke SDK Mode. Pastikan Wi-Fi TELLO terhubung.';
        addLog('Tello SDK Mode: Gagal (No Response)');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      _statusMessage = 'Error UDP Bind: $e';
      addLog('Error: $e');
      notifyListeners();
      return false;
    }
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
    _isConnected = false;
    _statusMessage = 'Terputus dari Tello';
    _commandQueue.clear();
    _isWaitingForResponse = false;
    addLog('Koneksi UDP ditutup');
    notifyListeners();
  }

  void _onReceiveData(RawSocketEvent event) {
    if (event == RawSocketEvent.read && _socket != null) {
      Datagram? datagram = _socket!.receive();
      if (datagram != null) {
        // Gunakan allowMalformed agar tidak crash jika ada byte aneh dari drone
        final message = utf8.decode(datagram.data, allowMalformed: true).trim().toLowerCase();
        
        // Jangan melog semua paket sampah, hanya log ok/error agar console bersih
        if (message == 'ok' || message.contains('error')) {
          addLog('Tello Response: $message');
        }

        if (_isWaitingForResponse && _currentCommandCompleter != null) {
          // Drone Tello HANYA membalas "ok" atau "error" untuk perintah pergerakan.
          // Abaikan paket biner aneh / telemetri yang nyasar ke port ini.
          if (message == 'ok' || message.contains('error')) {
            _commandTimeout?.cancel();
            _currentCommandCompleter!.complete(message == 'ok');
            _currentCommandCompleter = null;
            _isWaitingForResponse = false;
            _processQueue(); // Process next command if any
          }
        }
      }
    }
  }

  Future<bool> sendCommand(String cmd) async {
    if (_socket == null) return false;

    // Tello commands usually take < 15 secs (takeoff/land takes longer, up to 15s)
    final timeout = (cmd == 'takeoff' || cmd == 'land') ? 15 : 5;

    _isWaitingForResponse = true;
    _currentCommandCompleter = Completer<bool>();
    
    addLog('Mengirim: $cmd');
    _socket!.send(utf8.encode(cmd), InternetAddress(telloIp), telloPort);

    _commandTimeout = Timer(Duration(seconds: timeout), () {
      if (_currentCommandCompleter != null && !_currentCommandCompleter!.isCompleted) {
        addLog('Timeout untuk perintah: $cmd');
        _currentCommandCompleter!.complete(false);
        _currentCommandCompleter = null;
        _isWaitingForResponse = false;
        _processQueue();
      }
    });

    return await _currentCommandCompleter!.future;
  }

  // Queue system for sequential execution of multiple blocks
  void queueSequence(List<String> commands) {
    _commandQueue.clear();
    _commandQueue.addAll(commands);
    if (!_isWaitingForResponse) {
      _processQueue();
    }
  }

  // Parse Python code generated by Blockly and convert to SDK commands
  void parseAndQueuePython(String pythonCode) {
    final List<String> commands = [];
    final lines = pythonCode.split('\n');
    
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      
      if (line.contains('tello.takeoff()')) commands.add('takeoff');
      else if (line.contains('tello.land()')) commands.add('land');
      else if (line.contains('tello.stop()')) commands.add('stop');
      else if (line.contains('tello.move_forward(')) {
        final val = _extractNumber(line);
        if (val != null) commands.add('forward $val');
      }
      else if (line.contains('tello.move_back(')) {
        final val = _extractNumber(line);
        if (val != null) commands.add('back $val');
      }
      else if (line.contains('tello.move_left(')) {
        final val = _extractNumber(line);
        if (val != null) commands.add('left $val');
      }
      else if (line.contains('tello.move_right(')) {
        final val = _extractNumber(line);
        if (val != null) commands.add('right $val');
      }
      else if (line.contains('tello.move_up(')) {
        final val = _extractNumber(line);
        if (val != null) commands.add('up $val');
      }
      else if (line.contains('tello.move_down(')) {
        final val = _extractNumber(line);
        if (val != null) commands.add('down $val');
      }
      else if (line.contains('tello.rotate_cw(')) {
        final val = _extractNumber(line);
        if (val != null) commands.add('cw $val');
      }
      else if (line.contains('tello.rotate_ccw(')) {
        final val = _extractNumber(line);
        if (val != null) commands.add('ccw $val');
      }
      else if (line.contains('tello.flip(')) {
        if (line.contains('"l"') || line.contains("'l'")) commands.add('flip l');
        else if (line.contains('"r"') || line.contains("'r'")) commands.add('flip r');
        else if (line.contains('"f"') || line.contains("'f'")) commands.add('flip f');
        else if (line.contains('"b"') || line.contains("'b'")) commands.add('flip b');
      }
    }
    
    if (commands.isNotEmpty) {
      addLog('Menjalankan ${commands.length} perintah:');
      for (var i = 0; i < commands.length; i++) {
        addLog('${i + 1}. ${commands[i]}');
      }
      queueSequence(commands);
    } else {
      addLog('Tidak ada perintah valid untuk drone.');
    }
  }

  String? _extractNumber(String line) {
    final regExp = RegExp(r'\d+');
    final match = regExp.firstMatch(line);
    return match?.group(0);
  }

  Future<void> _processQueue() async {
    if (_commandQueue.isEmpty) {
      addLog('Semua perintah selesai dieksekusi.');
      return;
    }
    
    // Beri jeda 500ms agar Tello sempat memproses state sebelum menerima command baru.
    // Jika tidak ada jeda, Tello sering menolak/drop paket UDP yang datang terlalu cepat setelah balasan 'ok'.
    await Future.delayed(const Duration(milliseconds: 500));

    final nextCmd = _commandQueue.removeAt(0);
    await sendCommand(nextCmd);
  }
}
