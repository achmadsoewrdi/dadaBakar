# 📘 XPLORIA IOT MASTER SYSTEM BLUEPRINT & IMPLEMENTATION SPECIFICATION

**Dokumen:** Master End-to-End System Blueprint  
**Versi:** 2.0 (Hardened Production & Real-Time Telemetry Edition)  
**Target Architecture:** Raspberry Pi 3 (Debian 12) ↔ Flutter App (Android/iOS/Desktop)  
**Tujuan:** Panduan cetak biru tunggal terpadu yang memuat seluruh kode master Raspberry Pi, library `xploria_hal.py`, serta spesifikasi implementasi kode Flutter App.

---

## 🎯 1. ARSITEKTUR KONEKSI TERINTEGRASI

```
                                  ┌────────────────────────────────────────┐
                                  │         RASPBERRY PI 3 SERVER          │
                                  └────────────────────────────────────────┘
                                           │            │            │
                  ┌────────────────────────┘            │            └────────────────────────┐
                  ▼                                     ▼                                     ▼
 ┌─────────────────────────────────┐   ┌─────────────────────────────────┐   ┌─────────────────────────────────┐
 │ 1. WI-FI LOKAL ROUTER           │   ┌ 2. HOTSPOT AP MANDIRI           │   │ 3. BLUETOOTH RFCOMM SERIAL      │
 │    (Station Mode wlan0)         │   │    (Access Point Mode uap0)    │   │    (Bluetooth SPP Channel 1)   │
 │                                 │   │                                 │   │                                 │
 │ - IP: 192.168.1.159 (Statis)    │   │ - SSID: Xploria_IoT_Kit         │   │ - Device Name: xploria-raspi    │
 │ - Port WS: 9001                 │   │ - Pass: Exploria123             │   │ - Class: 0x000100               │
 │ - ws://192.168.1.159:9001       │   │ - IP: 192.168.4.1               │   │ - Exclusive 1-Device Circuit    │
 └─────────────────────────────────┘   └─────────────────────────────────┘   └─────────────────────────────────┘
```

---

## 🐍 2. RASPBERRY PI MASTER CODE: `/home/xploria/iot-receiver/server.py`

```python
# -*- coding: utf-8 -*-
"""
Xploria IoT Multi-Tenant Hardened WebSocket Server (Port 9001)
==============================================================
Menerima skrip Python dari Flutter App, memvalidasi keamanan via AST,
mendukung Pin-Level Locking, dan memforward Telemetri Sensor Real-Time.
"""

import os
import sys
import ast
import re
import time
import asyncio
import websockets
import subprocess

# Environment Variables untuk lgpio
os.environ["PYTHONUNBUFFERED"] = "1"
os.environ["RPI_LGPIO_REVISION"] = "a02082"
os.environ["GPIOZERO_PIN_FACTORY"] = "lgpio"

HOST = "0.0.0.0"
PORT = 9001
MAX_SCRIPT_SIZE = 50 * 1024  # Max 50KB

# Whitelist Modul & Pin BCM yang diizinkan
ALLOWED_MODULES = {'RPi.GPIO', 'time', 'math', 'xploria_hal', 'random', 'sys', 'json'}
ALLOWED_BCM_PINS = {4, 5, 6, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27}

# Pin-Level Mutex Lock State
active_pin_locks = {}  # Format: { pin_number: client_ip }
pin_mutex = asyncio.Lock()
client_processes = {}  # Format: { client_ip: subprocess_instance }

# =============================================================================
# 1. AST SECURITY CHECKER (Cegah Command Injection)
# =============================================================================

class SecurityASTChecker(ast.NodeVisitor):
    def visit_Import(self, node):
        for alias in node.names:
            if alias.name not in ALLOWED_MODULES:
                raise ValueError(f"Modul terlarang di-import: '{alias.name}'")
        self.generic_visit(node)

    def visit_ImportFrom(self, node):
        if node.module not in ALLOWED_MODULES:
            raise ValueError(f"Modul terlarang di-import: '{node.module}'")
        self.generic_visit(node)

    def visit_Call(self, node):
        if isinstance(node.func, ast.Name) and node.func.id in {'eval', 'exec', 'open', '__import__', 'compile'}:
            raise ValueError(f"Fungsi terlarang dipanggil: '{node.func.id}'")
        self.generic_visit(node)

def validate_ast_security(source_code):
    if len(source_code.encode('utf-8')) > MAX_SCRIPT_SIZE:
        return False, "Ukuran skrip melebihi batas maksimum (50KB)."
    try:
        tree = ast.parse(source_code)
        checker = SecurityASTChecker()
        checker.visit(tree)
        return True, "OK"
    except ValueError as e:
        return False, str(e)
    except SyntaxError:
        return False, "Kesalahan Sintaksis Python"

def extract_used_pins(source_code):
    """ Ekstraksi otomatis nomor pin BCM yang digunakan di dalam kode """
    pins = set(map(int, re.findall(r'\b(?:pin|GPIO|BCM|read_|set_)\w*\s*\(\s*(\d+)', source_code)))
    if "'M1'" in source_code or '"M1"' in source_code:
        pins.update({11, 13, 15})
    if "'M2'" in source_code or '"M2"' in source_code:
        pins.update({19, 21, 23})
    return pins.intersection(ALLOWED_BCM_PINS)

# =============================================================================
# 2. PIN-LEVEL MUTEX LOCK & RELEASE
# =============================================================================

async def acquire_pin_locks(client_ip, target_pins):
    async with pin_mutex:
        for pin in target_pins:
            if pin in active_pin_locks and active_pin_locks[pin] != client_ip:
                return False, f"Pin BCM {pin} sedang digunakan oleh HP lain ({active_pin_locks[pin]})"
        
        for pin in target_pins:
            active_pin_locks[pin] = client_ip
        return True, "OK"

async def release_client_resources(client_ip):
    async with pin_mutex:
        to_delete = [p for p, ip in active_pin_locks.items() if ip == client_ip]
        for p in to_delete:
            del active_pin_locks[p]
            
        if client_ip in client_processes:
            proc = client_processes[client_ip]
            if proc and proc.returncode is None:
                try:
                    proc.terminate()
                    await asyncio.sleep(0.1)
                    if proc.returncode is None:
                        proc.kill()
                except Exception:
                    pass
            del client_processes[client_ip]

# =============================================================================
# 3. WEBSOCKET CLIENT HANDLER & TELEMETRY FORWARDER
# =============================================================================

async def handle_client(websocket):
    client_ip = f"{websocket.remote_address[0]}:{websocket.remote_address[1]}"
    print(f"[+] Client Terhubung: {client_ip}", flush=True)

    try:
        async for message in websocket:
            if message == "PING":
                await websocket.send("PONG")
                continue
                
            # 1. Validasi Keamanan Kode via AST
            is_safe, reason = validate_ast_security(message)
            if not is_safe:
                print(f"[⚠️ AST BLOCKED] {client_ip}: {reason}", flush=True)
                await websocket.send(f"[ERR] Keamanan: {reason}")
                continue

            # 2. Ekstraksi Pin & Penguncian Mutex
            target_pins = extract_used_pins(message)
            lock_success, lock_msg = await acquire_pin_locks(client_ip, target_pins)
            if not lock_success:
                print(f"[⚠️ PIN LOCK BUSY] {client_ip}: {lock_msg}", flush=True)
                await websocket.send(f"[ERR] Bentrok Hardware: {lock_msg}")
                continue

            await release_client_resources(client_ip)
            await acquire_pin_locks(client_ip, target_pins)
            
            temp_file = f"/tmp/exploria_{websocket.remote_address[1]}.py"
            with open(temp_file, "w") as f:
                f.write(message)
                
            # 3. Jalankan Subprocess dengan Telemetry Streamer
            proc = await asyncio.create_subprocess_exec(
                "/usr/bin/python3", temp_file,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            client_processes[client_ip] = proc
            
            async def stream_output(stream, prefix):
                while True:
                    line = await stream.readline()
                    if not line:
                        break
                    decoded = line.decode("utf-8", errors="ignore").strip()
                    
                    # Intercept Telemetri Generik JSON
                    if decoded.startswith("TELEMETRY:"):
                        json_payload = decoded.replace("TELEMETRY:", "").strip()
                        try:
                            await websocket.send(json_payload)
                        except Exception:
                            break
                    else:
                        try:
                            await websocket.send(f"[{prefix}] {decoded}")
                        except Exception:
                            break
                        
            try:
                await asyncio.wait_for(
                    asyncio.gather(
                        stream_output(proc.stdout, "OUT"),
                        stream_output(proc.stderr, "ERR")
                    ),
                    timeout=30.0
                )
            except asyncio.TimeoutError:
                print(f"[⚠️ TIMEOUT] {client_ip} Dihentikan (30s)", flush=True)
                await websocket.send("[ERR] Timeout 30s: Eksekusi dihentikan.")
                await release_client_resources(client_ip)

            await proc.wait()
            
    except websockets.exceptions.ConnectionClosed:
        print(f"[-] Client Terputus: {client_ip}", flush=True)
    finally:
        print(f"[🛡️ FAIL-SAFE] Melepas Resource & Lock milik {client_ip}...", flush=True)
        await release_client_resources(client_ip)

# =============================================================================
# 4. MAIN FUNCTION
# =============================================================================

async def main():
    print(f"[🚀 HARDENED SERVER READY] Listening di ws://{HOST}:{PORT}...", flush=True)
    async with websockets.serve(handle_client, HOST, PORT, ping_interval=None):
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## 🐍 3. RASPBERRY PI MASTER LIBRARY: `/home/xploria/iot-receiver/xploria_hal.py`

```python
"""
xploria_hal.py — Xploria Hardware Abstraction Layer (Hardened + Dynamic Telemetry)
===================================================================================
Letakkan file ini di /home/xploria/iot-receiver/xploria_hal.py dan symlink ke site-packages.
"""

import time
import math
import sys
import json
import warnings
import atexit
import signal

warnings.simplefilter('ignore')

# === GPIO Init ===
try:
    import lgpio as _gpio
except ImportError:
    _gpio = None
    print("[xploria_hal] WARNING: lgpio tidak ditemukan - GPIO tidak akan berfungsi.", file=sys.stderr)

_PIN_MAP = {}
_chips = {}

def _get_gpio(p):
    gpio = _PIN_MAP.get(int(p), int(p))
    chip_idx = 1 if gpio >= 352 else 0
    offset = gpio - 352 if chip_idx == 1 else gpio
    if chip_idx not in _chips:
        _chips[chip_idx] = _gpio.gpiochip_open(chip_idx)
    return _chips[chip_idx], offset

def _gpio_cleanup():
    for c in _chips.values():
        try:
            _gpio.gpiochip_close(c)
        except Exception:
            pass

atexit.register(_gpio_cleanup)
signal.signal(signal.SIGTERM, lambda s, f: (_gpio_cleanup(), exit(0)))
signal.signal(signal.SIGINT,  lambda s, f: (_gpio_cleanup(), exit(0)))

class MockDevice:
    def __getattr__(self, name):
        def method(*args, **kwargs):
            return 0
        return method

# =============================================================================
# TelemetryHAL - Modul Telemetri Generik Real-Time (Blynk-like)
# =============================================================================

class TelemetryHAL:
    """Modul Pengirim Telemetri Generik ke Aplikasi Flutter."""
    
    def send(self, **kwargs):
        """
        Kirim data telemetri generik jenis apa pun.
        Contoh:
            telemetry.send(suhu=28.5, kelembapan=65)
            telemetry.send(jarak=14.2, terhalang=True)
            telemetry.send(cahaya=80, gas=False, voltase=3.3)
        """
        payload = {
            "type": "telemetry",
            "telemetry": kwargs
        }
        print(f"TELEMETRY:{json.dumps(payload)}", flush=True)

# =============================================================================
# PinHAL - GPIO Digital & Analog (PWM)
# =============================================================================

class PinHAL:
    def __init__(self):
        self._out_pins = set()

    def _claim_out(self, chip, offset, p_name):
        err = None
        for _ in range(10):
            try:
                _gpio.gpio_claim_output(chip, offset)
                self._out_pins.add(p_name)
                return
            except Exception as e:
                err = e
                time.sleep(0.2)
        print(f"[xploria_hal] Failed to claim output pin {p_name}: {err}", file=sys.stderr)

    def set_digital(self, p, state):
        chip, offset = _get_gpio(p)
        if p not in self._out_pins:
            self._claim_out(chip, offset, p)
        val = 1 if state == 'HIGH' else 0
        _gpio.gpio_write(chip, offset, val)

    def set_analog(self, p, value):
        chip, offset = _get_gpio(p)
        if p not in self._out_pins:
            self._claim_out(chip, offset, p)
        _gpio.tx_pwm(chip, offset, 100, max(0, min(100, int(value))))

    def read_digital(self, p):
        chip, offset = _get_gpio(p)
        try:
            _gpio.gpio_claim_input(chip, offset)
        except Exception:
            pass
        return _gpio.gpio_read(chip, offset)

    def read_analog(self, p):
        return 0

# =============================================================================
# SensorHAL - Baca berbagai sensor
# =============================================================================

class SensorHAL:
    def __init__(self):
        self._in_pins = set()
        self._dht_pins = {}

    def _claim_in(self, chip, offset, p_name):
        if p_name not in self._in_pins:
            err = None
            for _ in range(10):
                try:
                    _gpio.gpio_claim_input(chip, offset)
                    self._in_pins.add(p_name)
                    return
                except Exception as e:
                    err = e
                    time.sleep(0.2)
            print(f"[xploria_hal] Failed to claim input pin {p_name}: {err}", file=sys.stderr)

    def read_gas(self, p):
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return _gpio.gpio_read(chip, offset) == 1

    def read_motion(self, p):
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return _gpio.gpio_read(chip, offset) == 1

    def read_ir_obstacle(self, p):
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return _gpio.gpio_read(chip, offset) == 0

    def read_soil_moisture(self, p):
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return _gpio.gpio_read(chip, offset) == 0

    def read_temperature(self, p):
        try:
            import adafruit_dht, board
            if p not in self._dht_pins:
                self._dht_pins[p] = adafruit_dht.DHT22(getattr(board, f'D{p}'))
            val = self._dht_pins[p].temperature
            return val if val is not None else 0
        except Exception:
            return 0

    def read_humidity(self, p):
        try:
            import adafruit_dht, board
            if p not in self._dht_pins:
                self._dht_pins[p] = adafruit_dht.DHT22(getattr(board, f'D{p}'))
            val = self._dht_pins[p].humidity
            return val if val is not None else 0
        except Exception:
            return 0

    def read_ultrasonic(self, trig, echo):
        c_trig, o_trig = _get_gpio(trig)
        c_echo, o_echo = _get_gpio(echo)
        try:
            for _ in range(10):
                try:
                    _gpio.gpio_claim_output(c_trig, o_trig)
                    break
                except Exception:
                    time.sleep(0.2)
            for _ in range(10):
                try:
                    _gpio.gpio_claim_input(c_echo, o_echo)
                    break
                except Exception:
                    time.sleep(0.2)
            _gpio.gpio_write(c_trig, o_trig, 0)
            time.sleep(0.000002)
            _gpio.gpio_write(c_trig, o_trig, 1)
            time.sleep(0.00001)
            _gpio.gpio_write(c_trig, o_trig, 0)
            start = time.time()
            while _gpio.gpio_read(c_echo, o_echo) == 0:
                start = time.time()
            stop = time.time()
            while _gpio.gpio_read(c_echo, o_echo) == 1:
                stop = time.time()
            return (stop - start) * 34300 / 2
        except Exception:
            return 0

    def read_line(self, p):
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return 'BLACK' if _gpio.gpio_read(chip, offset) == 0 else 'WHITE'

    def read_light(self, p):
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        val = _gpio.gpio_read(chip, offset)
        return 100 if val == 0 else 0

# =============================================================================
# MotorHAL - Servo & DC Motor (L298N)
# =============================================================================

class MotorHAL:
    def __init__(self):
        self._servo_pins = {}

    def set_servo(self, p, degree):
        chip, offset = _get_gpio(p)
        pulse_us = int(500 + (degree / 180.0) * 2000)
        if p not in self._servo_pins:
            _gpio.tx_servo(chip, offset, pulse_us, 50, 500, 2500)
            self._servo_pins[p] = True
        else:
            _gpio.tx_servo(chip, offset, pulse_us)

    def run_dc(self, motor, speed):
        pins = {"M1": (11, 13, 15), "M2": (19, 21, 23)}
        if motor not in pins:
            return
        in1, in2, ena = pins[motor]
        c1, o1 = _get_gpio(in1)
        c2, o2 = _get_gpio(in2)
        ce, oe = _get_gpio(ena)
        try:
            _gpio.gpio_claim_output(c1, o1)
            _gpio.gpio_claim_output(c2, o2)
        except Exception:
            pass
        speed = max(-100, min(100, int(speed)))
        if speed > 0:
            _gpio.gpio_write(c1, o1, 1)
            _gpio.gpio_write(c2, o2, 0)
            _gpio.tx_pwm(ce, oe, 100, speed)
        elif speed < 0:
            _gpio.gpio_write(c1, o1, 0)
            _gpio.gpio_write(c2, o2, 1)
            _gpio.tx_pwm(ce, oe, 100, -speed)
        else:
            _gpio.gpio_write(c1, o1, 0)
            _gpio.gpio_write(c2, o2, 0)
            _gpio.tx_pwm(ce, oe, 100, 0)

    def stop_dc(self, motor):
        if motor == "ALL":
            self.run_dc("M1", 0)
            self.run_dc("M2", 0)
        else:
            self.run_dc(motor, 0)

# =============================================================================
# LEDHAL - LED Digital (active-high)
# =============================================================================

class LEDHAL(PinHAL):
    def __init__(self):
        super().__init__()
        self._brightness = 100
        self._led_pins = {1: 17, 2: 27, 3: 22}

    def _resolve_targets(self, target):
        if str(target) == "ALL":
            return list(self._led_pins.keys())
        return [int(target)]

    def display_color(self, target, color, secs=None):
        for t in self._resolve_targets(target):
            p = self._led_pins.get(t, t)
            self.set_digital(p, "HIGH" if color != "black" else "LOW")
        if secs is not None:
            time.sleep(secs)
            for t in self._resolve_targets(target):
                p = self._led_pins.get(t, t)
                self.set_digital(p, "LOW")

    def turn_off(self, target):
        for t in self._resolve_targets(target):
            p = self._led_pins.get(t, t)
            self.set_digital(p, "LOW")

# Mock Devices
class AudioHAL(MockDevice): pass
class DisplayHAL(MockDevice): pass
class MotionHAL(MockDevice): pass
class LANHAL(MockDevice): pass
class AIHAL(MockDevice): pass

# Instances Siap Pakai
pin       = PinHAL()
sensor    = SensorHAL()
motor     = MotorHAL()
led       = LEDHAL()
audio     = AudioHAL()
display   = DisplayHAL()
motion    = MotionHAL()
lan       = LANHAL()
ai        = AIHAL()
telemetry = TelemetryHAL()
```

---

## 📱 4. SPESIFIKASI IMPLEMENTASI FLUTTER APP

### A. Izin Bluetooth di `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Izin Bluetooth Android 12+ (API 31+) -->
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
</manifest>
```

### B. Service Listener Telemetri Generik di Flutter (`telemetry_service.dart`):

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TelemetryService extends ChangeNotifier {
  WebSocketChannel? _channel;
  final Map<String, dynamic> _liveTelemetryData = {};
  bool _isConnected = false;

  Map<String, dynamic> get liveTelemetryData => _liveTelemetryData;
  bool get isConnected => _isConnected;

  void connectWebSocket(String ipAddress) {
    try {
      final wsUrl = Uri.parse('ws://$ipAddress:9001');
      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;
      notifyListeners();

      _channel!.stream.listen((message) {
        _handleIncomingMessage(message);
      }, onDone: () {
        _isConnected = false;
        notifyListeners();
      }, onError: (error) {
        _isConnected = false;
        notifyListeners();
      });
    } catch (e) {
      _isConnected = false;
      notifyListeners();
    }
  }

  void _handleIncomingMessage(String message) {
    try {
      final Map<String, dynamic> payload = jsonDecode(message);
      if (payload['type'] == 'telemetry') {
        final Map<String, dynamic> newTelemetry = payload['telemetry'];
        
        // Update Map Telemetri Generik
        newTelemetry.forEach((key, value) {
          _liveTelemetryData[key] = value;
        });
        
        notifyListeners(); // Memicu UI Rebuild secara Real-Time
      }
    } catch (e) {
      // Log console biasa dari Python
    }
  }

  void sendScriptToDevice(String pythonScript) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(pythonScript);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
  }
}
```

### C. Widget UI Dashboard Telemetri Dynamic (`telemetry_dashboard_screen.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'telemetry_service.dart';

class TelemetryDashboardScreen extends StatelessWidget {
  const TelemetryDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final telemetryService = Provider.of<TelemetryService>(context);
    final telemetryData = telemetryService.liveTelemetryData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xploria Live IoT Dashboard'),
        backgroundColor: Colors.indigo,
      ),
      body: telemetryData.isEmpty
          ? const Center(
              child: Text(
                'Belum Ada Data Telemetri Stream\nSilakan Jalankan Skrip Blockly di Raspberry Pi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: telemetryData.length,
              itemBuilder: (context, index) {
                final key = telemetryData.keys.elementAt(index);
                final value = telemetryData[key];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          key.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
```

---

## 🛠️ 5. PERINCIAN LANGKAH EKSEKUSI DI RASPBERRY PI

```bash
# 1. Update File server.py dan xploria_hal.py di /home/xploria/iot-receiver/
sudo nano /home/xploria/iot-receiver/server.py
sudo nano /home/xploria/iot-receiver/xploria_hal.py

# 2. Update Symlink Site-Packages Global
sudo ln -sf /home/xploria/iot-receiver/xploria_hal.py /usr/local/lib/python3.11/dist-packages/xploria_hal.py

# 3. Restart Service WebSocket Server
sudo systemctl restart iot-websocket
```
