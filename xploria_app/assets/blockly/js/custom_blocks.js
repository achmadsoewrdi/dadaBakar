/**
 * Custom Blockly Block Definitions & Python Generators for mBlock Style Categories
 */

/// ==========================================================================
// HAL DEFINITIONS — dipanggil oleh generator blok hardware, bukan dari main.js
// Target Platform: Orange Pi Zero 3W (Linux SBC) menggunakan lgpio
// Blockly.Python.definitions_ secara otomatis di-deduplicate & di-prepend ke output
// ==========================================================================

function _hal_require_imports() {
    Blockly.Python.definitions_['import_time'] = 'import time';
    Blockly.Python.definitions_['import_math'] = 'import math';
    Blockly.Python.definitions_['import_sys'] = 'import sys';
    Blockly.Python.definitions_['import_warnings'] = "import warnings\nwarnings.simplefilter('ignore')";
}

function _hal_require_mock() {
    _hal_require_imports();
    Blockly.Python.definitions_['hal_MockDevice'] = [
        'class MockDevice:',
        '    def __getattr__(self, name):',
        '        def method(*args, **kwargs):',
        '            return 0',
        '        return method',
    ].join('\n');
}

function _hal_require_pin() {
    _hal_require_imports();
    Blockly.Python.definitions_['import_lgpio'] = 'import lgpio as _gpio';
    Blockly.Python.definitions_['import_atexit'] = 'import atexit';
    Blockly.Python.definitions_['hal_gpio_chip'] = [
        '_PIN_MAP = {3:35, 5:34, 7:36, 11:32, 12:37, 13:33, 15:139, 19:130, 21:131, 22:96, 23:129, 24:128, 26:132, 27:357, 28:356, 29:140, 31:141, 32:97, 33:99, 35:38, 36:98, 37:100, 38:40, 40:39}',
        '_chips = {}',
        'def _get_gpio(p):',
        '    gpio = _PIN_MAP.get(int(p), int(p))',
        '    chip_idx = 1 if gpio >= 352 else 0',
        '    offset = gpio - 352 if chip_idx == 1 else gpio',
        '    if chip_idx not in _chips:',
        '        _chips[chip_idx] = _gpio.gpiochip_open(chip_idx)',
        '    return _chips[chip_idx], offset',
        '',
        'def _gpio_cleanup():',
        '    for c in _chips.values():',
        '        try: _gpio.gpiochip_close(c)',
        '        except: pass',
        'atexit.register(_gpio_cleanup)',
        'import signal',
        'signal.signal(signal.SIGTERM, lambda s, f: (_gpio_cleanup(), exit(0)))',
        'signal.signal(signal.SIGINT,  lambda s, f: (_gpio_cleanup(), exit(0)))',
    ].join('\n');

    Blockly.Python.definitions_['hal_PinHAL'] = [
        'class PinHAL:',
        '    def __init__(self):',
        '        self._out_pins = set()',
        '',
        '    def _claim_out(self, chip, offset, p_name):',
        '        err = None',
        '        for i in range(10):',
        '            try:',
        '                _gpio.gpio_claim_output(chip, offset)',
        '                self._out_pins.add(p_name)',
        '                return',
        '            except Exception as e:',
        '                err = e',
        '                time.sleep(0.2)',
        '        print(f"Failed to claim output pin {p_name} (offset {offset}): {err}")',
        '',
        '    def set_digital(self, p, state):',
        '        chip, offset = _get_gpio(p)',
        '        if p not in self._out_pins:',
        '            self._claim_out(chip, offset, p)',
        '        # LOGIKA NORMAL (Active-High untuk LED)',
        "        val = 1 if state == 'HIGH' else 0",
        '        _gpio.gpio_write(chip, offset, val)',
        '',
        'pin = PinHAL()',
    ].join('\n');
}

function _hal_require_sensor() {
    _hal_require_imports();
    Blockly.Python.definitions_['import_lgpio'] = 'import lgpio as _gpio';
    Blockly.Python.definitions_['import_atexit'] = 'import atexit';
    Blockly.Python.definitions_['hal_gpio_chip'] = [
        '_PIN_MAP = {3:35, 5:34, 7:36, 11:32, 12:37, 13:33, 15:139, 19:130, 21:131, 22:96, 23:129, 24:128, 26:132, 27:357, 28:356, 29:140, 31:141, 32:97, 33:99, 35:38, 36:98, 37:100, 38:40, 40:39}',
        '_chips = {}',
        'def _get_gpio(p):',
        '    gpio = _PIN_MAP.get(int(p), int(p))',
        '    chip_idx = 1 if gpio >= 352 else 0',
        '    offset = gpio - 352 if chip_idx == 1 else gpio',
        '    if chip_idx not in _chips:',
        '        _chips[chip_idx] = _gpio.gpiochip_open(chip_idx)',
        '    return _chips[chip_idx], offset',
        '',
        'def _gpio_cleanup():',
        '    for c in _chips.values():',
        '        try: _gpio.gpiochip_close(c)',
        '        except: pass',
        'atexit.register(_gpio_cleanup)',
        'import signal',
        'signal.signal(signal.SIGTERM, lambda s, f: (_gpio_cleanup(), exit(0)))',
        'signal.signal(signal.SIGINT,  lambda s, f: (_gpio_cleanup(), exit(0)))',
    ].join('\n');
    
    Blockly.Python.definitions_['hal_SensorHAL'] = [
        'class SensorHAL:',
        '    def __init__(self):',
        '        self._in_pins = set()',
        '        self._dht_pins = {}',
        '',
        '    def _claim_in(self, chip, offset, p_name):',
        '        if p_name not in self._in_pins:',
        '            err = None',
        '            for i in range(10):',
        '                try:',
        '                    _gpio.gpio_claim_input(chip, offset)',
        '                    self._in_pins.add(p_name)',
        '                    return',
        '                except Exception as e:',
        '                    err = e',
        '                    time.sleep(0.2)',
        '            print(f"Failed to claim input pin {p_name} (offset {offset}): {err}")',
        '',
        '    def read_gas(self, p):',
        '        chip, offset = _get_gpio(p)',
        '        self._claim_in(chip, offset, p)',
        '        return _gpio.gpio_read(chip, offset) == 0',
        '',
        '    def read_motion(self, p):',
        '        chip, offset = _get_gpio(p)',
        '        self._claim_in(chip, offset, p)',
        '        return _gpio.gpio_read(chip, offset) == 1',
        '',
        '    def read_ir_obstacle(self, p):',
        '        chip, offset = _get_gpio(p)',
        '        self._claim_in(chip, offset, p)',
        '        return _gpio.gpio_read(chip, offset) == 1',
        '',
        '    def read_temperature(self, p):',
        '        try:',
        '            import adafruit_dht, board',
        '            if p not in self._dht_pins:',
        "                self._dht_pins[p] = adafruit_dht.DHT22(getattr(board, f'D{p}'))",
        '            return self._dht_pins[p].temperature',
        '        except: return 0',
        '',
        '    def read_humidity(self, p):',
        '        try:',
        '            import adafruit_dht, board',
        '            if p not in self._dht_pins:',
        "                self._dht_pins[p] = adafruit_dht.DHT22(getattr(board, f'D{p}'))",
        '            return self._dht_pins[p].humidity',
        '        except: return 0',
        '',
        '    def read_ultrasonic(self, trig, echo):',
        '        c_trig, o_trig = _get_gpio(trig)',
        '        c_echo, o_echo = _get_gpio(echo)',
        '        try:',
        '            for _ in range(10):',
        '                try: _gpio.gpio_claim_output(c_trig, o_trig); break',
        '                except: time.sleep(0.2)',
        '            for _ in range(10):',
        '                try: _gpio.gpio_claim_input(c_echo, o_echo); break',
        '                except: time.sleep(0.2)',
        '            _gpio.gpio_write(c_trig, o_trig, 0); time.sleep(0.000002)',
        '            _gpio.gpio_write(c_trig, o_trig, 1); time.sleep(0.00001)',
        '            _gpio.gpio_write(c_trig, o_trig, 0)',
        '            start = time.time()',
        '            while _gpio.gpio_read(c_echo, o_echo) == 0: start = time.time()',
        '            stop = time.time()',
        '            while _gpio.gpio_read(c_echo, o_echo) == 1: stop = time.time()',
        '            return (stop - start) * 34300 / 2',
        '        except: return 0',
        '',
        '    def read_line(self, p):',
        '        chip, offset = _get_gpio(p)',
        '        self._claim_in(chip, offset, p)',
        "        return 'BLACK' if _gpio.gpio_read(chip, offset) == 0 else 'WHITE'",
        '',
        '    def read_light(self, p): return 0',
        '',
        'sensor = SensorHAL()',
    ].join('\n');
}

function _hal_require_motor() {
    _hal_require_imports();
    Blockly.Python.definitions_['import_lgpio'] = 'import lgpio as _gpio';
    Blockly.Python.definitions_['import_atexit'] = 'import atexit';
    Blockly.Python.definitions_['hal_gpio_chip'] = [
        '_PIN_MAP = {3:35, 5:34, 7:36, 11:32, 12:37, 13:33, 15:139, 19:130, 21:131, 22:96, 23:129, 24:128, 26:132, 27:357, 28:356, 29:140, 31:141, 32:97, 33:99, 35:38, 36:98, 37:100, 38:40, 40:39}',
        '_chips = {}',
        'def _get_gpio(p):',
        '    gpio = _PIN_MAP.get(int(p), int(p))',
        '    chip_idx = 1 if gpio >= 352 else 0',
        '    offset = gpio - 352 if chip_idx == 1 else gpio',
        '    if chip_idx not in _chips:',
        '        _chips[chip_idx] = _gpio.gpiochip_open(chip_idx)',
        '    return _chips[chip_idx], offset',
        '',
        'def _gpio_cleanup():',
        '    for c in _chips.values():',
        '        try: _gpio.gpiochip_close(c)',
        '        except: pass',
        'atexit.register(_gpio_cleanup)',
        'import signal',
        'signal.signal(signal.SIGTERM, lambda s, f: (_gpio_cleanup(), exit(0)))',
        'signal.signal(signal.SIGINT,  lambda s, f: (_gpio_cleanup(), exit(0)))',
    ].join('\n');

    Blockly.Python.definitions_['hal_MotorHAL'] = [
        'class MotorHAL:',
        '    def __init__(self):',
        '        self._servo_pins = {}',
        '',
        '    def set_servo(self, p, degree):',
        '        chip, offset = _get_gpio(p)',
        '        pulse_us = int(500 + (degree / 180.0) * 2000)',
        '        if p not in self._servo_pins:',
        '            _gpio.tx_servo(chip, offset, pulse_us, 50, 500, 2500)',
        '            self._servo_pins[p] = True',
        '        else:',
        '            _gpio.tx_servo(chip, offset, pulse_us)',
        '',
        '    def run_dc(self, motor, speed): pass',
        '    def stop_dc(self, motor): pass',
        '',
        'motor = MotorHAL()',
    ].join('\n');
}

function _hal_require_led() {
    _hal_require_pin();
    Blockly.Python.definitions_['hal_LEDHAL'] = [
        'class LEDHAL(PinHAL):',
        '    def display_color(self, p, color):',
        "        self.set_digital(p, 'HIGH' if color != 'black' else 'LOW')",
        '    def turn_off(self, p):',
        "        self.set_digital(p, 'LOW')",
        '',
        'led = LEDHAL()',
    ].join('\n');
}

function _hal_require_audio() {
    _hal_require_mock();
    Blockly.Python.definitions_['hal_audio'] = 'audio = MockDevice()';
}

function _hal_require_display() {
    _hal_require_mock();
    Blockly.Python.definitions_['hal_display'] = 'display = MockDevice()';
}

function _hal_require_motion() {
    _hal_require_mock();
    Blockly.Python.definitions_['hal_motion'] = 'motion = MockDevice()';
}

function _hal_require_lan() {
    _hal_require_mock();
    Blockly.Python.definitions_['hal_lan'] = 'lan = MockDevice()';
}

function _hal_require_ai() {
    _hal_require_mock();
    Blockly.Python.definitions_['hal_ai'] = 'ai = MockDevice()';
}


// ==========================================================================
// 🔊 AUDIO BLOCKS
// ==========================================================================

Blockly.Blocks['audio_play_until_done'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🔊 Mainkan suara")
            .appendField(new Blockly.FieldDropdown([["Meow", "MEOW"], ["Beep", "BEEP"], ["Siren", "SIREN"]]), "SOUND")
            .appendField("sampai selesai");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_until_done'] = function(block) { _hal_require_audio(); return `audio.play_until_done("${block.getFieldValue('SOUND')}")\n`; };

Blockly.Blocks['audio_play_sound'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🔊 Mainkan suara")
            .appendField(new Blockly.FieldDropdown([["Meow", "MEOW"], ["Beep", "BEEP"], ["Siren", "SIREN"]]), "SOUND");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_sound'] = function(block) { _hal_require_audio(); return `audio.play("${block.getFieldValue('SOUND')}")\n`; };

Blockly.Blocks['audio_start_recording'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Mulai merekam suara");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_start_recording'] = function(block) { _hal_require_audio(); return `audio.start_recording()\n`; };

Blockly.Blocks['audio_stop_recording'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Berhenti merekam suara");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_stop_recording'] = function(block) { _hal_require_audio(); return `audio.stop_recording()\n`; };

Blockly.Blocks['audio_play_recording_until_done'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Mainkan rekaman sampai selesai");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_recording_until_done'] = function(block) { _hal_require_audio(); return `audio.play_recording_until_done()\n`; };

Blockly.Blocks['audio_play_recording'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Mainkan rekaman suara");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_recording'] = function(block) { _hal_require_audio(); return `audio.play_recording()\n`; };

Blockly.Blocks['audio_play_note'] = {
    init: function () {
        this.appendValueInput("NOTE").setCheck("Number").appendField("🔊 Mainkan nada");
        this.appendValueInput("BEAT").setCheck("Number").appendField("selama");
        this.appendDummyInput().appendField("ketukan");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_note'] = function(block) {
    _hal_require_audio();
    let note = Blockly.Python.valueToCode(block, 'NOTE', Blockly.Python.ORDER_ATOMIC) || "60";
    let beat = Blockly.Python.valueToCode(block, 'BEAT', Blockly.Python.ORDER_ATOMIC) || "0.25";
    return `audio.play_note(${note}, ${beat})\n`;
};

Blockly.Blocks['audio_play_drum'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Mainkan drum")
            .appendField(new Blockly.FieldDropdown([["Snare", "SNARE"], ["Bass", "BASS"], ["Crash", "CRASH"]]), "DRUM");
        this.appendValueInput("BEAT").setCheck("Number").appendField("selama");
        this.appendDummyInput().appendField("ketukan");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_drum'] = function(block) {
    _hal_require_audio();
    let drum = block.getFieldValue('DRUM');
    let beat = Blockly.Python.valueToCode(block, 'BEAT', Blockly.Python.ORDER_ATOMIC) || "0.25";
    return `audio.play_drum("${drum}", ${beat})\n`;
};

Blockly.Blocks['audio_increase_speed'] = {
    init: function () {
        this.appendValueInput("SPEED").setCheck("Number").appendField("🔊 Tambah kecepatan audio sebesar");
        this.appendDummyInput().appendField("%");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_increase_speed'] = function(block) {
    _hal_require_audio();
    let speed = Blockly.Python.valueToCode(block, 'SPEED', Blockly.Python.ORDER_ATOMIC) || "10";
    return `audio.increase_speed(${speed})\n`;
};

Blockly.Blocks['audio_set_speed'] = {
    init: function () {
        this.appendValueInput("SPEED").setCheck("Number").appendField("🔊 Atur kecepatan audio menjadi");
        this.appendDummyInput().appendField("%");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_set_speed'] = function(block) {
    _hal_require_audio();
    let speed = Blockly.Python.valueToCode(block, 'SPEED', Blockly.Python.ORDER_ATOMIC) || "100";
    return `audio.set_speed(${speed})\n`;
};

Blockly.Blocks['audio_speed_reporter'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Kecepatan audio");
        this.setOutput(true, "Number");
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_speed_reporter'] = function(block) { _hal_require_audio(); return [`audio.get_speed()`, Blockly.Python.ORDER_ATOMIC]; };

Blockly.Blocks['audio_increase_volume'] = {
    init: function () {
        this.appendValueInput("VOL").setCheck("Number").appendField("🔊 Tambah volume sebesar");
        this.appendDummyInput().appendField("%");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_increase_volume'] = function(block) {
    _hal_require_audio();
    let vol = Blockly.Python.valueToCode(block, 'VOL', Blockly.Python.ORDER_ATOMIC) || "10";
    return `audio.increase_volume(${vol})\n`;
};

Blockly.Blocks['audio_set_volume'] = {
    init: function () {
        this.appendValueInput("VOL").setCheck("Number").appendField("🔊 Atur volume menjadi");
        this.appendDummyInput().appendField("%");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_set_volume'] = function(block) {
    _hal_require_audio();
    let vol = Blockly.Python.valueToCode(block, 'VOL', Blockly.Python.ORDER_ATOMIC) || "30";
    return `audio.set_volume(${vol})\n`;
};

Blockly.Blocks['audio_volume_reporter'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Volume (%)");
        this.setOutput(true, "Number");
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_volume_reporter'] = function(block) { _hal_require_audio(); return [`audio.get_volume()`, Blockly.Python.ORDER_ATOMIC]; };

Blockly.Blocks['audio_play_sound_hz_for'] = {
    init: function () {
        this.appendValueInput("HZ").setCheck("Number").appendField("🔊 Mainkan suara pada");
        this.appendValueInput("SECS").setCheck("Number").appendField("Hz selama");
        this.appendDummyInput().appendField("detik");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_sound_hz_for'] = function(block) {
    _hal_require_audio();
    let hz = Blockly.Python.valueToCode(block, 'HZ', Blockly.Python.ORDER_ATOMIC) || "700";
    let secs = Blockly.Python.valueToCode(block, 'SECS', Blockly.Python.ORDER_ATOMIC) || "1";
    return `audio.play_hz(${hz}, ${secs})\n`;
};

Blockly.Blocks['audio_play_sound_hz'] = {
    init: function () {
        this.appendValueInput("HZ").setCheck("Number").appendField("🔊 Mainkan suara pada");
        this.appendDummyInput().appendField("Hz");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_sound_hz'] = function(block) {
    _hal_require_audio();
    let hz = Blockly.Python.valueToCode(block, 'HZ', Blockly.Python.ORDER_ATOMIC) || "700";
    return `audio.play_hz(${hz})\n`;
};

Blockly.Blocks['audio_stop_all'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Hentikan semua suara");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_stop_all'] = function(block) { _hal_require_audio(); return `audio.stop_all()\n`; };

// ==========================================================================
// 💡 LED BLOCKS
// ==========================================================================
Blockly.Blocks['led_play_animation_until_done'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💡 Mainkan animasi LED")
            .appendField(new Blockly.FieldDropdown([["Pelangi", "RAINBOW"], ["Berkedip", "BLINK"], ["Menyapu", "WIPE"]]), "ANIMATION")
            .appendField("sampai selesai");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_play_animation_until_done'] = function(block) { _hal_require_led(); return `led.play_animation("${block.getFieldValue('ANIMATION')}")\n`; };

Blockly.Blocks['led_display_5'] = {
    init: function () {
        var colors = [
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ff0000'/></svg>", "width": 20, "height": 20, "alt": "Merah" }, "red"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ff8800'/></svg>", "width": 20, "height": 20, "alt": "Oranye" }, "orange"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffff00'/></svg>", "width": 20, "height": 20, "alt": "Kuning" }, "yellow"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%2300ff00'/></svg>", "width": 20, "height": 20, "alt": "Hijau" }, "green"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%2300ffff'/></svg>", "width": 20, "height": 20, "alt": "Cyan" }, "cyan"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%230000ff'/></svg>", "width": 20, "height": 20, "alt": "Biru" }, "blue"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23800080'/></svg>", "width": 20, "height": 20, "alt": "Ungu" }, "purple"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffffff'/></svg>", "width": 20, "height": 20, "alt": "Putih" }, "white"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23000000'/></svg>", "width": 20, "height": 20, "alt": "Hitam" }, "black"]
        ];
        this.appendDummyInput()
            .appendField("💡 Tampilkan")
            .appendField(new Blockly.FieldDropdown(colors), "C1")
            .appendField(new Blockly.FieldDropdown(colors), "C2")
            .appendField(new Blockly.FieldDropdown(colors), "C3")
            .appendField(new Blockly.FieldDropdown(colors), "C4")
            .appendField(new Blockly.FieldDropdown(colors), "C5");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_display_5'] = function(block) {
    _hal_require_led();
    let c1 = block.getFieldValue('C1');
    let c2 = block.getFieldValue('C2');
    let c3 = block.getFieldValue('C3');
    let c4 = block.getFieldValue('C4');
    let c5 = block.getFieldValue('C5');
    return `led.display(["${c1}", "${c2}", "${c3}", "${c4}", "${c5}"])\n`;
};

Blockly.Blocks['led_roll_right'] = {
    init: function () {
        this.appendValueInput("NUM").setCheck("Number").appendField("💡 Geser");
        this.appendDummyInput().appendField("LED ke kanan");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_roll_right'] = function(block) {
    _hal_require_led();
    let num = Blockly.Python.valueToCode(block, 'NUM', Blockly.Python.ORDER_ATOMIC) || "1";
    return `led.roll_right(${num})\n`;
};

Blockly.Blocks['led_display_color_for'] = {
    init: function () {
        var colors = [
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ff0000'/></svg>", "width": 20, "height": 20, "alt": "Merah" }, "red"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ff8800'/></svg>", "width": 20, "height": 20, "alt": "Oranye" }, "orange"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffff00'/></svg>", "width": 20, "height": 20, "alt": "Kuning" }, "yellow"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%2300ff00'/></svg>", "width": 20, "height": 20, "alt": "Hijau" }, "green"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%2300ffff'/></svg>", "width": 20, "height": 20, "alt": "Cyan" }, "cyan"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%230000ff'/></svg>", "width": 20, "height": 20, "alt": "Biru" }, "blue"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23800080'/></svg>", "width": 20, "height": 20, "alt": "Ungu" }, "purple"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffffff'/></svg>", "width": 20, "height": 20, "alt": "Putih" }, "white"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23000000'/></svg>", "width": 20, "height": 20, "alt": "Hitam" }, "black"]
        ];
        this.appendDummyInput()
            .appendField("💡 LED")
            .appendField(new Blockly.FieldDropdown([["Semua", "ALL"], ["1", "1"], ["2", "2"], ["3", "3"]]), "TARGET")
            .appendField("tampilkan")
            .appendField(new Blockly.FieldDropdown(colors), "COLOR");
        this.appendValueInput("SECS").setCheck("Number").appendField("selama");
        this.appendDummyInput().appendField("detik");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_display_color_for'] = function(block) {
    _hal_require_led();
    let target = block.getFieldValue('TARGET');
    let color = block.getFieldValue('COLOR');
    let secs = Blockly.Python.valueToCode(block, 'SECS', Blockly.Python.ORDER_ATOMIC) || "1";
    return `led.display_color("${target}", "${color}", ${secs})\n`;
};

Blockly.Blocks['led_display_color'] = {
    init: function () {
        var colors = [
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ff0000'/></svg>", "width": 20, "height": 20, "alt": "Merah" }, "red"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ff8800'/></svg>", "width": 20, "height": 20, "alt": "Oranye" }, "orange"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffff00'/></svg>", "width": 20, "height": 20, "alt": "Kuning" }, "yellow"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%2300ff00'/></svg>", "width": 20, "height": 20, "alt": "Hijau" }, "green"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%2300ffff'/></svg>", "width": 20, "height": 20, "alt": "Cyan" }, "cyan"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%230000ff'/></svg>", "width": 20, "height": 20, "alt": "Biru" }, "blue"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23800080'/></svg>", "width": 20, "height": 20, "alt": "Ungu" }, "purple"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffffff'/></svg>", "width": 20, "height": 20, "alt": "Putih" }, "white"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23000000'/></svg>", "width": 20, "height": 20, "alt": "Hitam" }, "black"]
        ];
        this.appendDummyInput()
            .appendField("💡 LED")
            .appendField(new Blockly.FieldDropdown([["Semua", "ALL"], ["1", "1"], ["2", "2"], ["3", "3"]]), "TARGET")
            .appendField("tampilkan")
            .appendField(new Blockly.FieldDropdown(colors), "COLOR");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_display_color'] = function(block) {
    _hal_require_led();
    let target = block.getFieldValue('TARGET');
    let color = block.getFieldValue('COLOR');
    return `led.display_color("${target}", "${color}")\n`;
};

Blockly.Blocks['led_display_rgb_for'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💡 LED")
            .appendField(new Blockly.FieldDropdown([["Semua", "ALL"], ["1", "1"], ["2", "2"], ["3", "3"]]), "TARGET")
            .appendField("tampilkan R");
        this.appendValueInput("R").setCheck("Number");
        this.appendValueInput("G").setCheck("Number").appendField("G");
        this.appendValueInput("B").setCheck("Number").appendField("B");
        this.appendValueInput("SECS").setCheck("Number").appendField("selama");
        this.appendDummyInput().appendField("detik");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_display_rgb_for'] = function(block) {
    _hal_require_led();
    let target = block.getFieldValue('TARGET');
    let r = Blockly.Python.valueToCode(block, 'R', Blockly.Python.ORDER_ATOMIC) || "255";
    let g = Blockly.Python.valueToCode(block, 'G', Blockly.Python.ORDER_ATOMIC) || "0";
    let b = Blockly.Python.valueToCode(block, 'B', Blockly.Python.ORDER_ATOMIC) || "0";
    let secs = Blockly.Python.valueToCode(block, 'SECS', Blockly.Python.ORDER_ATOMIC) || "1";
    return `led.display_rgb("${target}", ${r}, ${g}, ${b}, ${secs})\n`;
};

Blockly.Blocks['led_display_rgb'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💡 LED")
            .appendField(new Blockly.FieldDropdown([["Semua", "ALL"], ["1", "1"], ["2", "2"], ["3", "3"]]), "TARGET")
            .appendField("tampilkan R");
        this.appendValueInput("R").setCheck("Number");
        this.appendValueInput("G").setCheck("Number").appendField("G");
        this.appendValueInput("B").setCheck("Number").appendField("B");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_display_rgb'] = function(block) {
    _hal_require_led();
    let target = block.getFieldValue('TARGET');
    let r = Blockly.Python.valueToCode(block, 'R', Blockly.Python.ORDER_ATOMIC) || "255";
    let g = Blockly.Python.valueToCode(block, 'G', Blockly.Python.ORDER_ATOMIC) || "0";
    let b = Blockly.Python.valueToCode(block, 'B', Blockly.Python.ORDER_ATOMIC) || "0";
    return `led.display_rgb("${target}", ${r}, ${g}, ${b})\n`;
};

Blockly.Blocks['led_increase_brightness'] = {
    init: function () {
        this.appendValueInput("BRIGHTNESS").setCheck("Number").appendField("💡 Tambah kecerahan LED sebesar");
        this.appendDummyInput().appendField("%");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_increase_brightness'] = function(block) {
    _hal_require_led();
    let b = Blockly.Python.valueToCode(block, 'BRIGHTNESS', Blockly.Python.ORDER_ATOMIC) || "10";
    return `led.increase_brightness(${b})\n`;
};

Blockly.Blocks['led_set_brightness'] = {
    init: function () {
        this.appendValueInput("BRIGHTNESS").setCheck("Number").appendField("💡 Atur kecerahan menjadi");
        this.appendDummyInput().appendField("%");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_set_brightness'] = function(block) {
    _hal_require_led();
    let b = Blockly.Python.valueToCode(block, 'BRIGHTNESS', Blockly.Python.ORDER_ATOMIC) || "30";
    return `led.set_brightness(${b})\n`;
};

Blockly.Blocks['led_brightness_reporter'] = {
    init: function () {
        this.appendDummyInput().appendField("💡 Kecerahan LED (%)");
        this.setOutput(true, "Number");
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_brightness_reporter'] = function(block) { _hal_require_led(); return [`led.get_brightness()`, Blockly.Python.ORDER_ATOMIC]; };

Blockly.Blocks['led_turn_off'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💡 Matikan LED")
            .appendField(new Blockly.FieldDropdown([["Semua", "ALL"], ["1", "1"], ["2", "2"], ["3", "3"]]), "TARGET");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
    }
};
Blockly.Python['led_turn_off'] = function(block) {
    _hal_require_led();
    let target = block.getFieldValue('TARGET');
    return `led.turn_off("${target}")\n`;
};

// ==========================================================================
// 🧭 MOTION SENSING BLOCKS
// ==========================================================================
Blockly.Blocks['motion_is_shaking'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🧭 Apakah diguncang?");
        this.setOutput(true, "Boolean");
        this.setColour("#4C97FF"); // Light Blue
        this.setTooltip("Mendeteksi guncangan pada perangkat (True/False)");
    }
};

Blockly.Python['motion_is_shaking'] = function (block) {
    _hal_require_motion();
    return [`motion.is_shaking()`, Blockly.Python.ORDER_ATOMIC];
};

// ==========================================================================
// 🌐 LAN BLOCKS
// ==========================================================================
Blockly.Blocks['lan_send_message'] = {
    init: function () {
        this.appendValueInput("MESSAGE")
            .setCheck("String")
            .appendField("🌐 Kirim pesan LAN");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#0FBD8C"); // Teal
        this.setTooltip("Mengirimkan pesan ke perangkat lain di jaringan lokal");
    }
};

Blockly.Python['lan_send_message'] = function (block) {
    _hal_require_lan();
    const msg = Blockly.Python.valueToCode(block, 'MESSAGE', Blockly.Python.ORDER_ATOMIC) || '""';
    return `lan.broadcast(${msg})\n`;
};

// ==========================================================================
// 🤖 AI BLOCKS
// ==========================================================================
Blockly.Blocks['ai_recognize_speech'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🤖 Kenali Suara (Teks)");
        this.setOutput(true, "String");
        this.setColour("#00C3DA"); // Cyan
        this.setTooltip("Merekam dan mengenali suara menjadi teks");
    }
};

Blockly.Python['ai_recognize_speech'] = function (block) {
    _hal_require_ai();
    return [`ai.recognize_speech()`, Blockly.Python.ORDER_ATOMIC];
};

// ==========================================================================
// 🏁 EVENTS BLOCKS
// ==========================================================================
Blockly.Blocks['event_when_start'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🏁 Saat program dimulai");
        this.setNextStatement(true, null);
        this.setColour("#FFBF00"); // Yellow (Hat block color)
        this.setTooltip("Blok awal saat program dijalankan");
    }
};

Blockly.Python['event_when_start'] = function (block) {
    return `# Program dimulai\n`;
};
// ==========================================================================
// 🔌 PIN BLOCKS (Hardware I/O)
// ==========================================================================
Blockly.Blocks['pin_set_digital'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🔌 Setel Pin Digital")
            .appendField(new Blockly.FieldNumber(17, 0, 40), "PIN")
            .appendField("menjadi")
            .appendField(new Blockly.FieldDropdown([["Nyala (HIGH)", "HIGH"], ["Mati (LOW)", "LOW"]]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FF6347");
    }
};
Blockly.Python['pin_set_digital'] = function(block) {
    _hal_require_pin();
    let pin = block.getFieldValue('PIN');
    let state = block.getFieldValue('STATE');
    return `pin.set_digital(${pin}, "${state}")\n`;
};

Blockly.Blocks['pin_set_analog'] = {
    init: function () {
        this.appendValueInput("VAL")
            .setCheck("Number")
            .appendField("🔌 Setel Pin Analog (PWM)")
            .appendField(new Blockly.FieldNumber(18, 0, 40), "PIN")
            .appendField("ke nilai");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FF6347");
    }
};
Blockly.Python['pin_set_analog'] = function(block) {
    _hal_require_pin();
    let pin = block.getFieldValue('PIN');
    let val = Blockly.Python.valueToCode(block, 'VAL', Blockly.Python.ORDER_ATOMIC) || "0";
    return `pin.set_analog(${pin}, ${val})\n`;
};

Blockly.Blocks['pin_read_digital'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🔌 Baca Pin Digital")
            .appendField(new Blockly.FieldNumber(17, 0, 40), "PIN");
        this.setOutput(true, ["Number", "Boolean"]);
        this.setColour("#FF6347");
    }
};
Blockly.Python['pin_read_digital'] = function(block) {
    _hal_require_pin();
    let pin = block.getFieldValue('PIN');
    return [`pin.read_digital(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['pin_read_analog'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🔌 Baca Pin Analog")
            .appendField(new Blockly.FieldNumber(36, 0, 40), "PIN");
        this.setOutput(true, "Number");
        this.setColour("#FF6347");
    }
};
Blockly.Python['pin_read_analog'] = function(block) {
    _hal_require_pin();
    let pin = block.getFieldValue('PIN');
    return [`pin.read_analog(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

// ==========================================================================
// ⚙️ MOTOR BLOCKS
// ==========================================================================
Blockly.Blocks['motor_set_servo'] = {
    init: function () {
        this.appendValueInput("DEGREE")
            .setCheck("Number")
            .appendField("⚙️ Putar Servo")
            .appendField(new Blockly.FieldNumber(18, 0, 40), "PIN")
            .appendField("ke sudut");
        this.appendDummyInput()
            .appendField("derajat");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4169E1");
    }
};
Blockly.Python['motor_set_servo'] = function(block) {
    _hal_require_motor();
    let pin = block.getFieldValue('PIN');
    let deg = Blockly.Python.valueToCode(block, 'DEGREE', Blockly.Python.ORDER_ATOMIC) || "90";
    return `motor.set_servo(${pin}, ${deg})\n`;
};

Blockly.Blocks['motor_dc_speed'] = {
    init: function () {
        this.appendValueInput("SPEED")
            .setCheck("Number")
            .appendField("⚙️ Jalankan Motor DC")
            .appendField(new Blockly.FieldDropdown([["M1", "M1"], ["M2", "M2"]]), "MOTOR")
            .appendField("kecepatan");
        this.appendDummyInput()
            .appendField("%");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4169E1");
    }
};
Blockly.Python['motor_dc_speed'] = function(block) {
    _hal_require_motor();
    let motor = block.getFieldValue('MOTOR');
    let speed = Blockly.Python.valueToCode(block, 'SPEED', Blockly.Python.ORDER_ATOMIC) || "100";
    return `motor.run_dc("${motor}", ${speed})\n`;
};

Blockly.Blocks['motor_dc_stop'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("⚙️ Hentikan Motor DC")
            .appendField(new Blockly.FieldDropdown([["Semua", "ALL"], ["M1", "M1"], ["M2", "M2"]]), "MOTOR");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4169E1");
    }
};
Blockly.Python['motor_dc_stop'] = function(block) {
    _hal_require_motor();
    let motor = block.getFieldValue('MOTOR');
    return `motor.stop_dc("${motor}")\n`;
};

// ==========================================================================
// 🌡️ SENSOR BLOCKS
// ==========================================================================
Blockly.Blocks['sensor_ultrasonic'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Jarak Ultrasonik Trig")
            .appendField(new Blockly.FieldNumber(21, 0, 40), "TRIG")
            .appendField("Echo")
            .appendField(new Blockly.FieldNumber(20, 0, 40), "ECHO")
            .appendField("(cm)");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_ultrasonic'] = function(block) {
    _hal_require_sensor();
    let trig = block.getFieldValue('TRIG');
    let echo = block.getFieldValue('ECHO');
    return [`sensor.read_ultrasonic(${trig}, ${echo})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_line_follower'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Sensor Garis di")
            .appendField(new Blockly.FieldNumber(5, 0, 40), "PIN")
            .appendField("mendeteksi")
            .appendField(new Blockly.FieldDropdown([["Hitam", "BLACK"], ["Putih", "WHITE"]]), "STATE");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_line_follower'] = function(block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    let state = block.getFieldValue('STATE');
    return [`sensor.read_line(${pin}) == "${state}"`, Blockly.Python.ORDER_LOGICAL_AND];
};

Blockly.Blocks['sensor_light'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Intensitas Cahaya (LDR) % di")
            .appendField(new Blockly.FieldNumber(27, 0, 40), "PIN");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_light'] = function(block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_light(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_temperature'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Suhu Udara (°C) di")
            .appendField(new Blockly.FieldNumber(4, 0, 40), "PIN");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_temperature'] = function(block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_temperature(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_gas'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Deteksi Gas (MQ-9) di")
            .appendField(new Blockly.FieldNumber(17, 0, 40), "PIN");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_gas'] = function(block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_gas(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_motion'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Deteksi Gerakan (PIR) di")
            .appendField(new Blockly.FieldNumber(22, 0, 40), "PIN");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_motion'] = function(block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_motion(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_humidity'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Kelembapan Udara (%) di")
            .appendField(new Blockly.FieldNumber(4, 0, 40), "PIN");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_humidity'] = function(block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_humidity(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_ir_obstacle'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Halangan (IR Obstacle) di")
            .appendField(new Blockly.FieldNumber(5, 0, 40), "PIN");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_ir_obstacle'] = function(block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_ir_obstacle(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

// ==========================================================================
// 📺 DISPLAY BLOCKS (OLED/LCD)
// ==========================================================================
Blockly.Blocks['display_print'] = {
    init: function () {
        this.appendValueInput("TEXT")
            .setCheck(["String", "Number"])
            .appendField("📺 Tampilkan Teks");
        this.appendDummyInput()
            .appendField("di Layar");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
    }
};
Blockly.Python['display_print'] = function(block) {
    _hal_require_display();
    let text = Blockly.Python.valueToCode(block, 'TEXT', Blockly.Python.ORDER_ATOMIC) || '""';
    return `display.print(${text})\n`;
};

Blockly.Blocks['display_print_size'] = {
    init: function () {
        this.appendValueInput("TEXT")
            .setCheck(["String", "Number"])
            .appendField("📺 Tampilkan Teks");
        this.appendDummyInput()
            .appendField("ukuran")
            .appendField(new Blockly.FieldDropdown([["Besar", "LARGE"], ["Sedang", "MEDIUM"], ["Kecil", "SMALL"]]), "SIZE");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
    }
};
Blockly.Python['display_print_size'] = function(block) {
    _hal_require_display();
    let text = Blockly.Python.valueToCode(block, 'TEXT', Blockly.Python.ORDER_ATOMIC) || '""';
    let size = block.getFieldValue('SIZE');
    return `display.print(${text}, size="${size}")\n`;
};

Blockly.Blocks['display_clear'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("📺 Bersihkan Layar");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
    }
};
Blockly.Python['display_clear'] = function(block) {
    _hal_require_display();
    return `display.clear()\n`;
};

Blockly.Blocks['display_graph'] = {
    init: function () {
        this.appendValueInput("VAL")
            .setCheck("Number")
            .appendField("📺 Tampilkan Grafik Data");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
    }
};
Blockly.Python['display_graph'] = function(block) {
    _hal_require_display();
    let val = Blockly.Python.valueToCode(block, 'VAL', Blockly.Python.ORDER_ATOMIC) || "0";
    return `display.graph(${val})\n`;
};

// ==========================================================================
// ⚙️ CONTROL BLOCKS (Custom Additions)
// ==========================================================================
Blockly.Blocks['delay_seconds'] = {
    init: function () {
        this.appendValueInput("SECONDS")
            .setCheck("Number")
            .appendField("⚙️ Tunggu");
        this.appendDummyInput()
            .appendField("detik");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FFAB19");
    }
};
Blockly.Python['delay_seconds'] = function(block) {
    let seconds = Blockly.Python.valueToCode(block, 'SECONDS', Blockly.Python.ORDER_ATOMIC) || "1";
    return `time.sleep(${seconds})\n`;
};
