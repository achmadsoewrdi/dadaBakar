"""
xploria_hal.py — Xploria Hardware Abstraction Layer
====================================================
Letakkan file ini di Raspberry Pi bersama Xploria Agent daemon.
Kode Python yang digenerate Blockly akan meng-import dari file ini.

Target Platform : Raspberry Pi (semua varian)
GPIO Library    : lgpio
Python          : 3.9+
Dependencies    : lgpio, adafruit-circuitpython-dht (opsional, untuk sensor DHT22)

Install:
    pip install lgpio adafruit-circuitpython-dht

Wiring default DC Motor Driver (L298N):
    M1 -> IN1=BCM11, IN2=BCM13, ENA=BCM15
    M2 -> IN1=BCM19, IN2=BCM21, ENA=BCM23

Wiring default LED digital:
    LED 1 -> BCM17 | LED 2 -> BCM27 | LED 3 -> BCM22
    Ganti _led_pins di class LEDHAL sesuai wiring fisik Anda.
"""

import time
import math
import sys
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

# _PIN_MAP kosong: angka pin di Blockly = BCM GPIO langsung (Raspberry Pi BCM mode)
_PIN_MAP = {}
_chips = {}


def _get_gpio(p):
    """Resolve nomor pin ke chip dan offset lgpio."""
    gpio = _PIN_MAP.get(int(p), int(p))
    chip_idx = 1 if gpio >= 352 else 0
    offset = gpio - 352 if chip_idx == 1 else gpio
    if chip_idx not in _chips:
        _chips[chip_idx] = _gpio.gpiochip_open(chip_idx)
    return _chips[chip_idx], offset


def _gpio_cleanup():
    """Tutup semua GPIO chip - dipanggil saat program selesai/crash."""
    for c in _chips.values():
        try:
            _gpio.gpiochip_close(c)
        except Exception:
            pass


atexit.register(_gpio_cleanup)
signal.signal(signal.SIGTERM, lambda s, f: (_gpio_cleanup(), exit(0)))
signal.signal(signal.SIGINT,  lambda s, f: (_gpio_cleanup(), exit(0)))


# =============================================================================
# MockDevice - Placeholder untuk hardware yang belum tersedia
# =============================================================================

class MockDevice:
    """
    Device palsu yang mengembalikan 0 untuk semua method.
    Dipakai untuk Audio, Display, Motion, LAN, AI yang belum diimplementasi.
    Tidak akan menyebabkan AttributeError atau crash.
    """
    def __getattr__(self, name):
        def method(*args, **kwargs):
            return 0
        return method


# =============================================================================
# PinHAL - GPIO Digital & Analog (PWM)
# =============================================================================

class PinHAL:
    """Kontrol pin GPIO Raspberry Pi secara langsung (BCM mode)."""

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
        print(f"[xploria_hal] Failed to claim output pin {p_name} (offset {offset}): {err}", file=sys.stderr)

    def set_digital(self, p, state):
        """Set pin BCM p ke HIGH atau LOW."""
        chip, offset = _get_gpio(p)
        if p not in self._out_pins:
            self._claim_out(chip, offset, p)
        val = 1 if state == 'HIGH' else 0
        _gpio.gpio_write(chip, offset, val)

    def set_analog(self, p, value):
        """PWM output via lgpio. value: 0-100 (duty cycle %)."""
        chip, offset = _get_gpio(p)
        if p not in self._out_pins:
            self._claim_out(chip, offset, p)
        _gpio.tx_pwm(chip, offset, 100, max(0, min(100, int(value))))

    def read_digital(self, p):
        """Baca pin BCM p sebagai digital (0 atau 1)."""
        chip, offset = _get_gpio(p)
        try:
            _gpio.gpio_claim_input(chip, offset)
        except Exception:
            pass
        return _gpio.gpio_read(chip, offset)

    def read_analog(self, p):
        """Placeholder: Raspberry Pi tidak punya ADC built-in. Selalu return 0."""
        return 0


# =============================================================================
# SensorHAL - Baca berbagai sensor
# =============================================================================

class SensorHAL:
    """Baca sensor digital: gas, PIR, IR obstacle, kelembapan tanah, DHT22, ultrasonik, cahaya."""

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
        """True = gas terdeteksi (sinyal HIGH)."""
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return _gpio.gpio_read(chip, offset) == 1

    def read_motion(self, p):
        """True = ada gerakan (PIR, sinyal HIGH)."""
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return _gpio.gpio_read(chip, offset) == 1

    def read_ir_obstacle(self, p):
        """True = ada halangan (IR Obstacle, sinyal LOW = detected)."""
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return _gpio.gpio_read(chip, offset) == 0

    def read_soil_moisture(self, p):
        """True = tanah basah/lembap (sinyal LOW)."""
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return _gpio.gpio_read(chip, offset) == 0

    def read_temperature(self, p):
        """Baca suhu dari DHT22 (dalam derajat C). Return 0 jika gagal."""
        try:
            import adafruit_dht, board
            if p not in self._dht_pins:
                self._dht_pins[p] = adafruit_dht.DHT22(getattr(board, f'D{p}'))
            val = self._dht_pins[p].temperature
            return val if val is not None else 0
        except Exception:
            return 0

    def read_humidity(self, p):
        """Baca kelembapan dari DHT22 (dalam %). Return 0 jika gagal."""
        try:
            import adafruit_dht, board
            if p not in self._dht_pins:
                self._dht_pins[p] = adafruit_dht.DHT22(getattr(board, f'D{p}'))
            val = self._dht_pins[p].humidity
            return val if val is not None else 0
        except Exception:
            return 0

    def read_ultrasonic(self, trig, echo):
        """Baca jarak ultrasonik HC-SR04 (dalam cm)."""
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
        """Baca sensor garis. Return 'BLACK' atau 'WHITE'."""
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        return 'BLACK' if _gpio.gpio_read(chip, offset) == 0 else 'WHITE'

    def read_light(self, p):
        """Baca intensitas cahaya LDR digital (0=gelap, 100=terang)."""
        chip, offset = _get_gpio(p)
        self._claim_in(chip, offset, p)
        val = _gpio.gpio_read(chip, offset)
        return 100 if val == 0 else 0


# =============================================================================
# MotorHAL - Servo & DC Motor (L298N)
# =============================================================================

class MotorHAL:
    """Kontrol servo dan motor DC via L298N motor driver."""

    def __init__(self):
        self._servo_pins = {}

    def set_servo(self, p, degree):
        """Putar servo ke sudut tertentu (0-180 derajat)."""
        chip, offset = _get_gpio(p)
        pulse_us = int(500 + (degree / 180.0) * 2000)
        if p not in self._servo_pins:
            _gpio.tx_servo(chip, offset, pulse_us, 50, 500, 2500)
            self._servo_pins[p] = True
        else:
            _gpio.tx_servo(chip, offset, pulse_us)

    def run_dc(self, motor, speed):
        """
        Jalankan motor DC.
        motor: 'M1' atau 'M2'
        speed: -100 (penuh mundur) sampai 100 (penuh maju), 0 = berhenti
        """
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
        """Hentikan motor DC. motor: 'M1', 'M2', atau 'ALL'."""
        if motor == "ALL":
            self.run_dc("M1", 0)
            self.run_dc("M2", 0)
        else:
            self.run_dc(motor, 0)


# =============================================================================
# LEDHAL - LED Digital (active-high)
# =============================================================================

class LEDHAL(PinHAL):
    """
    HAL untuk LED digital biasa (active-high) di Raspberry Pi.
    _led_pins: mapping nomor LED (1, 2, 3) ke nomor BCM GPIO.
    Sesuaikan _led_pins dengan wiring fisik Anda.
    """

    def __init__(self):
        super().__init__()
        self._brightness = 100
        self._led_pins = {1: 17, 2: 27, 3: 22}  # BCM GPIO default untuk 3 LED

    def _resolve_targets(self, target):
        if str(target) == "ALL":
            return list(self._led_pins.keys())
        return [int(target)]

    def display_color(self, target, color, secs=None):
        """Nyalakan LED target. Digital: non-black=ON. Opsional: matikan setelah secs detik."""
        for t in self._resolve_targets(target):
            p = self._led_pins.get(t, t)
            self.set_digital(p, "HIGH" if color != "black" else "LOW")
        if secs is not None:
            time.sleep(secs)
            for t in self._resolve_targets(target):
                p = self._led_pins.get(t, t)
                self.set_digital(p, "LOW")

    def turn_off(self, target):
        """Matikan LED target."""
        for t in self._resolve_targets(target):
            p = self._led_pins.get(t, t)
            self.set_digital(p, "LOW")

    def display(self, colors):
        """Tampilkan array warna ke LED strip (indeks 1-based, max 5)."""
        for i, color in enumerate(colors):
            p = self._led_pins.get(i + 1, 17 + i)
            self.set_digital(p, "HIGH" if color != "black" else "LOW")

    def display_rgb(self, target, r, g, b, secs=None):
        """Stub RGB untuk LED digital: r+g+b>0 = ON, = 0 = OFF."""
        on = (int(r) + int(g) + int(b)) > 0
        self.display_color(target, "white" if on else "black", secs)

    def roll_right(self, n):
        """Stub: geser animasi - tidak didukung LED digital biasa."""
        pass

    def play_animation(self, name):
        """Stub: animasi preset - tidak didukung LED digital biasa."""
        pass

    def increase_brightness(self, val):
        self._brightness = min(100, self._brightness + int(val))

    def set_brightness(self, val):
        self._brightness = max(0, min(100, int(val)))

    def get_brightness(self):
        return self._brightness


# =============================================================================
# AudioHAL — Putar suara menggunakan pygame / sox / aplay
# Install: pip install pygame
# Untuk tone: apt install sox
# =============================================================================

class AudioHAL:
    """Putar suara, rekam, dan atur volume menggunakan pygame/sox/aplay."""

    def __init__(self):
        self._volume = 50
        self._speed = 100
        self._initialized = False
        self._recording_proc = None
        try:
            import pygame
            pygame.mixer.init()
            self._initialized = True
        except Exception:
            pass

    def _play_tone(self, hz, duration):
        """Generate dan mainkan pure tone via sox (subprocess)."""
        import subprocess
        try:
            subprocess.run(
                ['sox', '-n', '-d', 'synth', str(duration), 'sine', str(hz)],
                capture_output=True, timeout=duration + 2
            )
        except Exception:
            pass

    def play(self, sound, wait=False):
        """Mainkan suara bernama (MEOW, BEEP, SIREN)."""
        tone_map = {'BEEP': (1000, 0.3), 'SIREN': (700, 1.0), 'MEOW': (500, 0.4)}
        hz, dur = tone_map.get(sound, (800, 0.5))
        import threading
        t = threading.Thread(target=self._play_tone, args=(hz, dur), daemon=True)
        t.start()
        if wait:
            t.join()

    def play_until_done(self, sound):
        self.play(sound, wait=True)

    def play_hz(self, hz, duration=0.5):
        self._play_tone(hz, duration)

    def play_note(self, note, beat):
        """Mainkan nada MIDI (0-127) selama beat ketukan."""
        hz = 440 * (2 ** ((int(note) - 69) / 12))
        self._play_tone(hz, beat * 0.5)

    def play_drum(self, drum, beat):
        drum_hz = {'SNARE': 200, 'BASS': 60, 'CRASH': 900}
        self._play_tone(drum_hz.get(drum, 200), beat * 0.25)

    def stop_all(self):
        import subprocess
        subprocess.run(['pkill', '-f', 'sox'],   capture_output=True)
        subprocess.run(['pkill', '-f', 'aplay'], capture_output=True)

    def start_recording(self):
        import subprocess
        self._recording_proc = subprocess.Popen(
            ['arecord', '-f', 'cd', '/tmp/xploria_rec.wav'], capture_output=True
        )

    def stop_recording(self):
        if self._recording_proc:
            self._recording_proc.terminate()
            self._recording_proc = None

    def play_recording(self, wait=False):
        import subprocess
        cmd = ['aplay', '/tmp/xploria_rec.wav']
        if wait:
            subprocess.run(cmd, capture_output=True)
        else:
            subprocess.Popen(cmd)

    def play_recording_until_done(self):
        self.play_recording(wait=True)

    def set_volume(self, value):
        self._volume = max(0, min(100, int(value)))
        import subprocess
        subprocess.run(['amixer', 'sset', 'Master', f'{self._volume}%'], capture_output=True)

    def increase_volume(self, delta):
        self.set_volume(self._volume + int(delta))

    def get_volume(self):
        return self._volume

    def set_speed(self, value):
        self._speed = max(10, min(300, int(value)))

    def increase_speed(self, delta):
        self.set_speed(self._speed + int(delta))

    def get_speed(self):
        return self._speed


# =============================================================================
# DisplayHAL — OLED/LCD via luma.oled (SSD1306 I2C)
# Install: pip install luma.oled pillow
# =============================================================================

class DisplayHAL:
    """Tampilkan teks dan grafik di OLED SSD1306 via I2C (default address 0x3C)."""

    def __init__(self, i2c_address=0x3C):
        self._device = None
        try:
            from luma.core.interface.serial import i2c
            from luma.oled.device import ssd1306
            serial = i2c(port=1, address=i2c_address)
            self._device = ssd1306(serial)
        except Exception as e:
            print(f"[xploria_hal] Display init failed: {e}", file=sys.stderr)

    def print(self, text, size="MEDIUM"):
        """Tampilkan teks di pojok kiri atas OLED."""
        if not self._device:
            return
        try:
            from luma.core.render import canvas
            font_size_map = {'LARGE': 20, 'MEDIUM': 14, 'SMALL': 10}
            px = font_size_map.get(size, 14)
            with canvas(self._device) as draw:
                draw.rectangle(self._device.bounding_box, fill='black')
                draw.text((2, 2), str(text), fill='white')
        except Exception as e:
            print(f"[xploria_hal] Display print error: {e}", file=sys.stderr)

    def clear(self):
        """Bersihkan layar OLED."""
        if not self._device:
            return
        try:
            from luma.core.render import canvas
            with canvas(self._device) as draw:
                draw.rectangle(self._device.bounding_box, fill='black')
        except Exception:
            pass

    def graph(self, value):
        """Tampilkan bar chart vertikal dari nilai 0-100."""
        if not self._device:
            return
        try:
            from luma.core.render import canvas
            w = self._device.width
            h = self._device.height
            bar_h = int(max(0, min(100, float(value))) / 100.0 * h)
            with canvas(self._device) as draw:
                draw.rectangle([0, 0, w, h], fill='black')
                draw.rectangle([10, h - bar_h, w - 10, h], fill='white')
        except Exception:
            pass


# =============================================================================
# MotionHAL — Accelerometer/Gyro MPU6050 via I2C
# Install: pip install smbus2
# =============================================================================

class MotionHAL:
    """Baca data accelerometer dan gyroscope dari MPU6050 via I2C."""

    MPU6050_ADDR = 0x68
    REG_ACCEL_X  = 0x3B
    REG_PWR_MGMT = 0x6B

    def __init__(self):
        self._bus = None
        try:
            import smbus2
            self._bus = smbus2.SMBus(1)
            # Wake up MPU6050 (keluar dari sleep mode)
            self._bus.write_byte_data(self.MPU6050_ADDR, self.REG_PWR_MGMT, 0)
        except Exception as e:
            print(f"[xploria_hal] MPU6050 init failed: {e}", file=sys.stderr)

    def _read_word_2c(self, reg):
        """Baca 2 byte (signed) dari register MPU6050."""
        high = self._bus.read_byte_data(self.MPU6050_ADDR, reg)
        low  = self._bus.read_byte_data(self.MPU6050_ADDR, reg + 1)
        val  = (high << 8) + low
        return val - 65536 if val >= 0x8000 else val

    def get_acceleration(self):
        """Return (ax, ay, az) dalam satuan g (gravitasi)."""
        if not self._bus:
            return (0.0, 0.0, 1.0)
        try:
            ax = self._read_word_2c(0x3B) / 16384.0
            ay = self._read_word_2c(0x3D) / 16384.0
            az = self._read_word_2c(0x3F) / 16384.0
            return (ax, ay, az)
        except Exception:
            return (0.0, 0.0, 1.0)

    def is_shaking(self):
        """True jika terdeteksi guncangan (threshold 0.5g dari nilai diam)."""
        ax, ay, az = self.get_acceleration()
        magnitude = (ax**2 + ay**2 + az**2) ** 0.5
        return abs(magnitude - 1.0) > 0.5


# =============================================================================
# LANHAL — Kirim/terima pesan via UDP broadcast
# (tidak butuh install tambahan, pakai socket bawaan Python)
# =============================================================================

class LANHAL:
    """Kirim pesan ke semua device di jaringan lokal via UDP broadcast."""

    def __init__(self, port=9999):
        self._port = port
        self._sock = None
        try:
            import socket
            self._sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self._sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
            self._sock.settimeout(2)
        except Exception as e:
            print(f"[xploria_hal] LAN init failed: {e}", file=sys.stderr)

    def broadcast(self, message):
        """Kirim pesan ke semua perangkat di jaringan (UDP broadcast)."""
        if not self._sock:
            return
        try:
            self._sock.sendto(str(message).encode('utf-8'), ('<broadcast>', self._port))
        except Exception as e:
            print(f"[xploria_hal] LAN broadcast error: {e}", file=sys.stderr)


# =============================================================================
# AIHAL — Speech Recognition menggunakan SpeechRecognition + Google API
# Install: pip install SpeechRecognition pyaudio
# =============================================================================

class AIHAL:
    """Kenali suara dari mikrofon menjadi teks (Bahasa Indonesia)."""

    def recognize_speech(self):
        """
        Rekam dari mikrofon dan kembalikan teks (string).
        Menggunakan Google Speech Recognition API (butuh internet).
        Return string kosong jika gagal atau tidak dikenali.
        """
        try:
            import speech_recognition as sr
            recognizer = sr.Recognizer()
            with sr.Microphone() as source:
                recognizer.adjust_for_ambient_noise(source, duration=0.5)
                print("[xploria_hal] Mendengarkan...", file=sys.stderr)
                audio = recognizer.listen(source, timeout=5, phrase_time_limit=10)
            result = recognizer.recognize_google(audio, language='id-ID')
            print(f"[xploria_hal] Dikenali: {result}", file=sys.stderr)
            return result
        except Exception as e:
            print(f"[xploria_hal] Speech recognition gagal: {e}", file=sys.stderr)
            return ""


# =============================================================================
# Instances siap pakai
# from xploria_hal import pin, sensor, motor, led, audio, display, motion, lan, ai
# =============================================================================

pin     = PinHAL()
sensor  = SensorHAL()
motor   = MotorHAL()
led     = LEDHAL()
audio   = AudioHAL()
display = DisplayHAL()
motion  = MotionHAL()
lan     = LANHAL()
ai      = AIHAL()

