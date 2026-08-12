# 📌 Dokumentasi Pin Mapping Xploria (Raspberry Pi)

Secara default, Xploria menggunakan penomoran **BCM GPIO** pada Raspberry Pi. Semua pemetaan pin (Pin Mapping) dapat dikonfigurasi melalui file `agent/xploria_hal.py` di dalam perangkat keras / Raspberry Pi Anda. 

Berikut adalah dokumentasi wiring dan daftar pin yang didukung secara default:

## 🔌 1. Daftar Pin BCM yang Diizinkan (Whitelist Server)
Demi keamanan dari *short-circuit* atau penyalahgunaan *command*, server Xploria membatasi pin BCM yang bisa dikendalikan oleh aplikasi via jaringan.
Pin yang **diizinkan (Allowed Pins):**
`4, 5, 6, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27`

> [!WARNING]
> Jangan pernah menyambungkan pin GPIO ke tegangan 5V secara langsung (GPIO Raspberry Pi beroperasi di logika 3.3V).

---

## ⚙️ 2. Konfigurasi Wiring Default Bawaan Xploria

Jika Anda tidak mendefinisikan custom nama pin secara manual, maka program akan menggunakan konfigurasi kelistrikan *hardcoded* berikut:

### 💡 Lampu LED Digital (Modul LEDHAL)
Lampu LED eksternal dapat diakses dengan index target `1`, `2`, atau `3`.
- **LED 1** ➔ BCM 17
- **LED 2** ➔ BCM 27
- **LED 3** ➔ BCM 22

### 🏎️ Driver Motor DC (L298N - Modul MotorHAL)
- **Motor 1 (M1)**:
  - IN1 ➔ BCM 11
  - IN2 ➔ BCM 13
  - ENA ➔ BCM 15 (PWM Speed Control)
- **Motor 2 (M2)**:
  - IN1 ➔ BCM 19
  - IN2 ➔ BCM 21
  - ENA ➔ BCM 23 (PWM Speed Control)

### 📺 Modul I2C (Display OLED & Sensor Gerak MPU6050)
Komunikasi I2C menggunakan port 1 standar Raspberry Pi.
- **SDA** ➔ BCM 2
- **SCL** ➔ BCM 3
- *Display OLED (SSD1306)* berada di Address `0x3C`
- *Gyro/Accel (MPU6050)* berada di Address `0x68`

---

## 🛠️ 3. Cara Mengubah Custom Pin Mapping (`_PIN_MAP`)
Untuk menyambungkan nama blok (misalnya: "TERAS", "KAMAR", "KIPAS") yang ada di aplikasi Flutter ke perangkat keras (Sensor/Relay), Anda harus mendeklarasikannya di dictionary `_PIN_MAP` yang ada di dalam `agent/xploria_hal.py`:

```python
# Tambahkan mapping ini di bagian atas file xploria_hal.py pada alat Raspberry Pi
_PIN_MAP = {
    # 🏠 Smart Home Pintu & Lampu
    "TERAS": 17,       # Lampu Teras di GPIO 17
    "KAMAR": 27,       # Lampu Kamar di GPIO 27
    "RUANG_TAMU": 22,  # Lampu Ruang Tamu di GPIO 22
    "DAPUR": 24,       # Sensor Asap Dapur di GPIO 24
    
    # 🚪 Penggerak / Aktuator
    "DOOR": 18,        # Motor Servo Pintu Depan di GPIO 18
    "FAN": 23,         # Relay Kipas Angin di GPIO 23
    "CURTAIN": 12,     # Servo Gorden di GPIO 12

    # 🏙️ Smart City
    "LAMPU_JALAN_1": 5, 
    "LAMPU_JALAN_2": 6
}
```

> [!TIP]
> **Praktik Terbaik Untuk Edukasi:**
> Saat menyusun kit untuk dirakit oleh murid, buat diagram gambar yang menyuruh anak memasang kabel "Kipas" ke port nomor "23" (sesuai `_PIN_MAP` yang sudah guru atur di atas). Dengan begini, logika kode aplikasi (`Nyala = ON`) bisa berjalan tanpa murid repot memikirkan teknis *low-level*.
