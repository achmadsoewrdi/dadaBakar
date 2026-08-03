/**
 * Custom Blockly Block Definitions & Python Generators — Xploria Platform
 *
 * Setiap block menghasilkan DUA output (Dual Generation Engine, sesuai plan_v2.md §1.2):
 *   1. Blockly.Python[...] → preview kode edukasi (Python) di Flutter UI
 *   2. Blockly.JSON[...]   → CommandPacket JSON → Xploria Agent via WebSocket/BLE
 *
 * Semua HAL class (PinHAL, SensorHAL, MotorHAL, LEDHAL, MockDevice) ada di:
 *   xploria_hal.py — letakkan di Raspberry Pi bersama Xploria Agent daemon.
 */

// ==========================================================================
// HAL IMPORT HELPERS
// Meng-inject satu baris import ke output Python yang digenerate.
// Semua _hal_require_* cukup memanggil _hal_require_all() — tidak perlu
// embed class definition di sini lagi.
// ==========================================================================

function _hal_require_all() {
    Blockly.Python.definitions_['xploria_hal'] =
        'from xploria_hal import pin, sensor, motor, led, audio, display, motion, lan, ai';
    Blockly.Python.definitions_['import_time'] = 'import time';
    Blockly.Python.definitions_['import_math'] = 'import math';
}

// Alias agar semua generator block yang sudah ada tidak perlu diubah
function _hal_require_imports()  { _hal_require_all(); }
function _hal_require_mock()     { _hal_require_all(); }
function _hal_require_pin()      { _hal_require_all(); }
function _hal_require_sensor()   { _hal_require_all(); }
function _hal_require_motor()    { _hal_require_all(); }
function _hal_require_led()      { _hal_require_all(); }
function _hal_require_audio()    { _hal_require_all(); }
function _hal_require_display()  { _hal_require_all(); }
function _hal_require_motion()   { _hal_require_all(); }
function _hal_require_lan()      { _hal_require_all(); }
function _hal_require_ai()       { _hal_require_all(); }

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
Blockly.Python['audio_play_until_done'] = function (block) { _hal_require_audio(); return `audio.play_until_done("${block.getFieldValue('SOUND')}")\n`; };

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
Blockly.Python['audio_play_sound'] = function (block) { _hal_require_audio(); return `audio.play("${block.getFieldValue('SOUND')}")\n`; };

Blockly.Blocks['audio_start_recording'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Mulai merekam suara");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_start_recording'] = function (block) { _hal_require_audio(); return `audio.start_recording()\n`; };

Blockly.Blocks['audio_stop_recording'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Berhenti merekam suara");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_stop_recording'] = function (block) { _hal_require_audio(); return `audio.stop_recording()\n`; };

Blockly.Blocks['audio_play_recording_until_done'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Mainkan rekaman sampai selesai");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_recording_until_done'] = function (block) { _hal_require_audio(); return `audio.play_recording_until_done()\n`; };

Blockly.Blocks['audio_play_recording'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Mainkan rekaman suara");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
    }
};
Blockly.Python['audio_play_recording'] = function (block) { _hal_require_audio(); return `audio.play_recording()\n`; };

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
Blockly.Python['audio_play_note'] = function (block) {
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
Blockly.Python['audio_play_drum'] = function (block) {
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
Blockly.Python['audio_increase_speed'] = function (block) {
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
Blockly.Python['audio_set_speed'] = function (block) {
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
Blockly.Python['audio_speed_reporter'] = function (block) { _hal_require_audio(); return [`audio.get_speed()`, Blockly.Python.ORDER_ATOMIC]; };

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
Blockly.Python['audio_increase_volume'] = function (block) {
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
Blockly.Python['audio_set_volume'] = function (block) {
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
Blockly.Python['audio_volume_reporter'] = function (block) { _hal_require_audio(); return [`audio.get_volume()`, Blockly.Python.ORDER_ATOMIC]; };

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
Blockly.Python['audio_play_sound_hz_for'] = function (block) {
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
Blockly.Python['audio_play_sound_hz'] = function (block) {
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
Blockly.Python['audio_stop_all'] = function (block) { _hal_require_audio(); return `audio.stop_all()\n`; };

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
Blockly.Python['led_play_animation_until_done'] = function (block) { _hal_require_led(); return `led.play_animation("${block.getFieldValue('ANIMATION')}")\n`; };

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
Blockly.Python['led_display_5'] = function (block) {
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
Blockly.Python['led_roll_right'] = function (block) {
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
Blockly.Python['led_display_color_for'] = function (block) {
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
Blockly.Python['led_display_color'] = function (block) {
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
Blockly.Python['led_display_rgb_for'] = function (block) {
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
Blockly.Python['led_display_rgb'] = function (block) {
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
Blockly.Python['led_increase_brightness'] = function (block) {
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
Blockly.Python['led_set_brightness'] = function (block) {
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
Blockly.Python['led_brightness_reporter'] = function (block) { _hal_require_led(); return [`led.get_brightness()`, Blockly.Python.ORDER_ATOMIC]; };

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
Blockly.Python['led_turn_off'] = function (block) {
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
Blockly.Python['pin_set_digital'] = function (block) {
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
Blockly.Python['pin_set_analog'] = function (block) {
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
Blockly.Python['pin_read_digital'] = function (block) {
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
Blockly.Python['pin_read_analog'] = function (block) {
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
Blockly.Python['motor_set_servo'] = function (block) {
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
Blockly.Python['motor_dc_speed'] = function (block) {
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
Blockly.Python['motor_dc_stop'] = function (block) {
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
Blockly.Python['sensor_ultrasonic'] = function (block) {
    _hal_require_sensor();
    let trig = block.getFieldValue('TRIG');
    let echo = block.getFieldValue('ECHO');
    return [`sensor.read_ultrasonic(${trig}, ${echo})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_ultrasonic_print'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Print Jarak Ultrasonik Trig")
            .appendField(new Blockly.FieldNumber(21, 0, 40), "TRIG")
            .appendField("Echo")
            .appendField(new Blockly.FieldNumber(20, 0, 40), "ECHO");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_ultrasonic_print'] = function (block) {
    _hal_require_sensor();
    let trig = block.getFieldValue('TRIG');
    let echo = block.getFieldValue('ECHO');
    return `print(f"[INFO] Jarak Ultrasonik: {sensor.read_ultrasonic(${trig}, ${echo}):.2f} cm")\n`;
};

Blockly.Blocks['sensor_ultrasonic_if'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Jika Jarak Ultrasonik Trig")
            .appendField(new Blockly.FieldNumber(21, 0, 40), "TRIG")
            .appendField("Echo")
            .appendField(new Blockly.FieldNumber(20, 0, 40), "ECHO");
        this.appendDummyInput()
            .appendField(new Blockly.FieldDropdown([["< (Kurang dari)", "<"], ["> (Lebih dari)", ">"], ["= (Sama dengan)", "=="]]), "OP")
            .appendField(new Blockly.FieldNumber(10), "SETPOINT")
            .appendField("cm");
        this.appendStatementInput("DO_TRUE")
            .appendField("maka (DO):");
        this.appendStatementInput("DO_FALSE")
            .appendField("selain itu (ELSE):");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_ultrasonic_if'] = function (block) {
    _hal_require_sensor();
    let trig = block.getFieldValue('TRIG');
    let echo = block.getFieldValue('ECHO');
    let op = block.getFieldValue('OP');
    let setpoint = block.getFieldValue('SETPOINT');

    let doTrue = Blockly.Python.statementToCode(block, 'DO_TRUE');
    let doFalse = Blockly.Python.statementToCode(block, 'DO_FALSE');

    let code = `if sensor.read_ultrasonic(${trig}, ${echo}) ${op} ${setpoint}:\n`;
    code += doTrue || '    pass\n';
    code += `else:\n`;
    code += doFalse || '    pass\n';
    return code;
};

Blockly.Blocks['sensor_ultrasonic_ads'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Jarak Ultrasonik (ADS1115) Trig")
            .appendField(new Blockly.FieldNumber(21, 0, 40), "TRIG")
            .appendField("Channel Echo")
            .appendField(new Blockly.FieldDropdown([["A0", "0"], ["A1", "1"], ["A2", "2"], ["A3", "3"]]), "CH")
            .appendField("(cm)");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_ultrasonic_ads'] = function (block) {
    _hal_require_sensor();
    let trig = block.getFieldValue('TRIG');
    let ch = block.getFieldValue('CH');
    return [`sensor.read_ultrasonic_ads(${trig}, ${ch})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_ultrasonic_ads_if'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Jika Jarak Ultrasonik (ADS1115) Trig")
            .appendField(new Blockly.FieldNumber(21, 0, 40), "TRIG")
            .appendField("Channel Echo")
            .appendField(new Blockly.FieldDropdown([["A0", "0"], ["A1", "1"], ["A2", "2"], ["A3", "3"]]), "CH");
        this.appendDummyInput()
            .appendField(new Blockly.FieldDropdown([["< (Kurang dari)", "<"], ["> (Lebih dari)", ">"], ["= (Sama dengan)", "=="]]), "OP")
            .appendField(new Blockly.FieldNumber(10), "SETPOINT")
            .appendField("cm");
        this.appendStatementInput("DO_TRUE")
            .appendField("maka (DO):");
        this.appendStatementInput("DO_FALSE")
            .appendField("selain itu (ELSE):");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_ultrasonic_ads_if'] = function (block) {
    _hal_require_sensor();
    let trig = block.getFieldValue('TRIG');
    let ch = block.getFieldValue('CH');
    let op = block.getFieldValue('OP');
    let setpoint = block.getFieldValue('SETPOINT');

    let doTrue = Blockly.Python.statementToCode(block, 'DO_TRUE');
    let doFalse = Blockly.Python.statementToCode(block, 'DO_FALSE');

    let code = `if sensor.read_ultrasonic_ads(${trig}, ${ch}) ${op} ${setpoint}:\n`;
    code += doTrue || '    pass\n';
    code += `else:\n`;
    code += doFalse || '    pass\n';
    return code;
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
Blockly.Python['sensor_line_follower'] = function (block) {
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
Blockly.Python['sensor_light'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_light(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_light_print'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Print Intensitas Cahaya (LDR) di")
            .appendField(new Blockly.FieldNumber(27, 0, 40), "PIN");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_light_print'] = function(block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return `print(f"[INFO] Intensitas Cahaya LDR: {sensor.read_light(${pin}):.2f} %")\n`;
};

Blockly.Blocks['sensor_light_if'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Jika Intensitas Cahaya (LDR) di")
            .appendField(new Blockly.FieldNumber(27, 0, 40), "PIN");
        this.appendDummyInput()
            .appendField(new Blockly.FieldDropdown([["< (Kurang dari)", "<"], ["> (Lebih dari)", ">"], ["= (Sama dengan)", "=="]]), "OP")
            .appendField(new Blockly.FieldNumber(50), "SETPOINT")
            .appendField("%");
        this.appendStatementInput("DO_TRUE")
            .appendField("maka (DO):");
        this.appendStatementInput("DO_FALSE")
            .appendField("selain itu (ELSE):");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_light_if'] = function(block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    let op = block.getFieldValue('OP');
    let setpoint = block.getFieldValue('SETPOINT');
    
    let doTrue = Blockly.Python.statementToCode(block, 'DO_TRUE');
    let doFalse = Blockly.Python.statementToCode(block, 'DO_FALSE');

    let code = `if sensor.read_light(${pin}) ${op} ${setpoint}:\n`;
    code += doTrue || '    pass\n';
    code += `else:\n`;
    code += doFalse || '    pass\n';
    return code;
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
Blockly.Python['sensor_temperature'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_temperature(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_gas'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Deteksi Gas (Digital) di")
            .appendField(new Blockly.FieldNumber(17, 0, 40), "PIN");
        this.appendStatementInput("DO_DETECT")
            .appendField("jika terdeteksi gas:");
        this.appendStatementInput("DO_SAFE")
            .appendField("jika aman:");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_gas'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    let doDetect = Blockly.Python.statementToCode(block, 'DO_DETECT');
    let doSafe = Blockly.Python.statementToCode(block, 'DO_SAFE');

    let code = `if sensor.read_gas(${pin}):\n`;
    code += doDetect || '    pass\n';
    code += `else:\n`;
    code += doSafe || '    pass\n';
    return code;
};

Blockly.Blocks['sensor_soil_moisture'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌱 Deteksi Kelembapan Tanah (Digital) di")
            .appendField(new Blockly.FieldNumber(24, 0, 40), "PIN");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_soil_moisture'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_soil_moisture(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_motion'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Deteksi Gerakan (PIR) di")
            .appendField(new Blockly.FieldNumber(22, 0, 40), "PIN");
        this.appendStatementInput("DO_DETECT")
            .appendField("jika ada gerakan:");
        this.appendStatementInput("DO_SAFE")
            .appendField("jika aman:");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_motion'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    let doDetect = Blockly.Python.statementToCode(block, 'DO_DETECT');
    let doSafe = Blockly.Python.statementToCode(block, 'DO_SAFE');

    let code = `if sensor.read_motion(${pin}):\n`;
    code += doDetect || '    pass\n';
    code += `else:\n`;
    code += doSafe || '    pass\n';
    return code;
};

// Definisi sensor_temperature sudah ada di atas (tidak diduplikasi)

Blockly.Blocks['sensor_humidity'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💧 Kelembapan Udara (%) di")
            .appendField(new Blockly.FieldNumber(4, 0, 40), "PIN");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_humidity'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return [`sensor.read_humidity(${pin})`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sensor_temperature_if'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Jika Suhu Udara di")
            .appendField(new Blockly.FieldNumber(4, 0, 40), "PIN");
        this.appendDummyInput()
            .appendField(new Blockly.FieldDropdown([["< (Kurang dari)", "<"], ["> (Lebih dari)", ">"], ["= (Sama dengan)", "=="]]), "OP")
            .appendField(new Blockly.FieldNumber(30), "SETPOINT")
            .appendField("°C");
        this.appendStatementInput("DO_TRUE")
            .appendField("maka (DO):");
        this.appendStatementInput("DO_FALSE")
            .appendField("selain itu (ELSE):");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_temperature_if'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    let op = block.getFieldValue('OP');
    let setpoint = block.getFieldValue('SETPOINT');

    let doTrue = Blockly.Python.statementToCode(block, 'DO_TRUE');
    let doFalse = Blockly.Python.statementToCode(block, 'DO_FALSE');

    let code = `if sensor.read_temperature(${pin}) ${op} ${setpoint}:\n`;
    code += doTrue || '    pass\n';
    code += `else:\n`;
    code += doFalse || '    pass\n';
    return code;
};

Blockly.Blocks['sensor_humidity_if'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💧 Jika Kelembapan Udara di")
            .appendField(new Blockly.FieldNumber(4, 0, 40), "PIN");
        this.appendDummyInput()
            .appendField(new Blockly.FieldDropdown([["< (Kurang dari)", "<"], ["> (Lebih dari)", ">"], ["= (Sama dengan)", "=="]]), "OP")
            .appendField(new Blockly.FieldNumber(60), "SETPOINT")
            .appendField("%");
        this.appendStatementInput("DO_TRUE")
            .appendField("maka (DO):");
        this.appendStatementInput("DO_FALSE")
            .appendField("selain itu (ELSE):");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_humidity_if'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    let op = block.getFieldValue('OP');
    let setpoint = block.getFieldValue('SETPOINT');

    let doTrue = Blockly.Python.statementToCode(block, 'DO_TRUE');
    let doFalse = Blockly.Python.statementToCode(block, 'DO_FALSE');

    let code = `if sensor.read_humidity(${pin}) ${op} ${setpoint}:\n`;
    code += doTrue || '    pass\n';
    code += `else:\n`;
    code += doFalse || '    pass\n';
    return code;
};

Blockly.Blocks['sensor_temperature_print'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Print Suhu Udara (°C) di")
            .appendField(new Blockly.FieldNumber(4, 0, 40), "PIN");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_temperature_print'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return `print(f"[INFO] Suhu Udara: {sensor.read_temperature(${pin}):.1f} °C")\n`;
};

Blockly.Blocks['sensor_humidity_print'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💧 Print Kelembapan Udara (%) di")
            .appendField(new Blockly.FieldNumber(4, 0, 40), "PIN");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_humidity_print'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    return `print(f"[INFO] Kelembapan Udara: {sensor.read_humidity(${pin}):.1f} %")\n`;
};

Blockly.Blocks['sensor_ir_obstacle'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌡️ Deteksi Halangan (IR Obstacle) di")
            .appendField(new Blockly.FieldNumber(5, 0, 40), "PIN");
        this.appendStatementInput("DO_DETECT")
            .appendField("jika terdeteksi (LOW):");
        this.appendStatementInput("DO_SAFE")
            .appendField("jika aman (HIGH):");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['sensor_ir_obstacle'] = function (block) {
    _hal_require_sensor();
    let pin = block.getFieldValue('PIN');
    let doDetect = Blockly.Python.statementToCode(block, 'DO_DETECT');
    let doSafe = Blockly.Python.statementToCode(block, 'DO_SAFE');

    let code = `if sensor.read_ir_obstacle(${pin}):  # True = terdeteksi (0/LOW)\n`;
    code += doDetect || '    pass\n';
    code += `else:\n`;
    code += doSafe || '    pass\n';
    return code;
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
Blockly.Python['display_print'] = function (block) {
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
Blockly.Python['display_print_size'] = function (block) {
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
Blockly.Python['display_clear'] = function (block) {
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
Blockly.Python['display_graph'] = function (block) {
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
Blockly.Python['delay_seconds'] = function (block) {
    let seconds = Blockly.Python.valueToCode(block, 'SECONDS', Blockly.Python.ORDER_ATOMIC) || "1";
    return `time.sleep(${seconds})\n`;
};

// ==========================================================================
// 🔷 JSON / AST GENERATORS (Dual Generation Engine — sesuai plan_v2.md §1.2)
//
// Setiap block kini menghasilkan DUA output:
//   1. Blockly.Python[...] → preview kode edukasi di Flutter UI (sudah ada di atas)
//   2. Blockly.JSON[...]   → CommandPacket JSON → dikirim ke Xploria Agent via WebSocket/BLE
//
// Format CommandPacket:
//   { "type": "command"|"query"|"control"|"event", "cmd": "...", "args": {...} }
//
// Untuk memanggil dari Flutter/Dart:
//   final ast = js.context['Blockly']['JSON'].callMethod('generateFromTopBlock', [workspace]);
// ==========================================================================

Blockly.JSON = Blockly.JSON || {};

/**
 * Traverse statement input block menjadi array CommandPacket secara rekursif.
 * @param {Blockly.Block} block - parent block
 * @param {string} inputName - nama statement input (mis. 'DO_TRUE', 'DO_FALSE')
 * @returns {Array} array of CommandPacket objects
 */
function _jsonStatementToList(block, inputName) {
    const commands = [];
    let child = block.getInputTargetBlock(inputName);
    while (child) {
        const gen = Blockly.JSON[child.type];
        if (gen) {
            const result = gen(child);
            if (Array.isArray(result)) commands.push(...result);
            else if (result !== null && result !== undefined) commands.push(result);
        }
        child = child.getNextBlock();
    }
    return commands;
}

/**
 * Ambil nilai dari value input sebagai literal (Number atau String).
 * Hanya mendukung math_number dan text block standar Blockly.
 * @param {Blockly.Block} block
 * @param {string} inputName
 * @param {*} defaultVal - nilai default jika input kosong
 */
function _jsonGetValue(block, inputName, defaultVal) {
    const target = block.getInputTargetBlock(inputName);
    if (!target) return defaultVal;
    if (target.type === 'math_number') return parseFloat(target.getFieldValue('NUM'));
    if (target.type === 'text') return target.getFieldValue('TEXT');
    return defaultVal;
}

/**
 * Generate seluruh program sebagai array CommandPacket dari top-level block.
 * Dipanggil dari Flutter via JS Channel setelah user klik tombol Run.
 * @param {Blockly.Workspace} workspace
 * @returns {Array} array of CommandPacket
 */
Blockly.JSON.generateProgram = function(workspace) {
    const commands = [];
    const topBlocks = workspace.getTopBlocks(true);
    for (const block of topBlocks) {
        let current = block;
        while (current) {
            const gen = Blockly.JSON[current.type];
            if (gen) {
                const result = gen(current);
                if (Array.isArray(result)) commands.push(...result);
                else if (result) commands.push(result);
            }
            current = current.getNextBlock();
        }
    }
    return commands;
};

// ============================================================
// 🏁 EVENTS
// ============================================================
Blockly.JSON['event_when_start'] = function(block) {
    return { type: 'event', cmd: 'program_start' };
};

// ============================================================
// ⚙️ CONTROL
// ============================================================
Blockly.JSON['delay_seconds'] = function(block) {
    const secs = _jsonGetValue(block, 'SECONDS', 1);
    return { type: 'command', cmd: 'delay', args: { seconds: secs } };
};

// ============================================================
// 🔌 PIN
// ============================================================
Blockly.JSON['pin_set_digital'] = function(block) {
    return {
        type: 'command',
        cmd: 'pin_set_digital',
        args: { pin: parseInt(block.getFieldValue('PIN')), state: block.getFieldValue('STATE') }
    };
};

Blockly.JSON['pin_set_analog'] = function(block) {
    return {
        type: 'command',
        cmd: 'pin_set_analog',
        args: { pin: parseInt(block.getFieldValue('PIN')), value: _jsonGetValue(block, 'VAL', 0) }
    };
};

Blockly.JSON['pin_read_digital'] = function(block) {
    return {
        type: 'query',
        cmd: 'pin_read_digital',
        args: { pin: parseInt(block.getFieldValue('PIN')) }
    };
};

Blockly.JSON['pin_read_analog'] = function(block) {
    return {
        type: 'query',
        cmd: 'pin_read_analog',
        args: { pin: parseInt(block.getFieldValue('PIN')) }
    };
};

// ============================================================
// ⚙️ MOTOR
// ============================================================
Blockly.JSON['motor_set_servo'] = function(block) {
    return {
        type: 'command',
        cmd: 'motor_set_servo',
        args: { pin: parseInt(block.getFieldValue('PIN')), degree: _jsonGetValue(block, 'DEGREE', 90) }
    };
};

Blockly.JSON['motor_dc_speed'] = function(block) {
    return {
        type: 'command',
        cmd: 'motor_dc_run',
        args: { motor: block.getFieldValue('MOTOR'), speed: _jsonGetValue(block, 'SPEED', 100) }
    };
};

Blockly.JSON['motor_dc_stop'] = function(block) {
    return {
        type: 'command',
        cmd: 'motor_dc_stop',
        args: { motor: block.getFieldValue('MOTOR') }
    };
};

// ============================================================
// 🌡️ SENSOR
// ============================================================
Blockly.JSON['sensor_ultrasonic'] = function(block) {
    return {
        type: 'query',
        cmd: 'sensor_read_ultrasonic',
        args: { trig: parseInt(block.getFieldValue('TRIG')), echo: parseInt(block.getFieldValue('ECHO')) }
    };
};

Blockly.JSON['sensor_ultrasonic_print'] = function(block) {
    return {
        type: 'command',
        cmd: 'sensor_print',
        args: { sensor: 'ultrasonic', trig: parseInt(block.getFieldValue('TRIG')), echo: parseInt(block.getFieldValue('ECHO')) }
    };
};

Blockly.JSON['sensor_ultrasonic_if'] = function(block) {
    return {
        type: 'control',
        cmd: 'if_sensor',
        condition: {
            cmd: 'sensor_read_ultrasonic',
            args: { trig: parseInt(block.getFieldValue('TRIG')), echo: parseInt(block.getFieldValue('ECHO')) }
        },
        op: block.getFieldValue('OP'),
        setpoint: parseFloat(block.getFieldValue('SETPOINT')),
        do_true: _jsonStatementToList(block, 'DO_TRUE'),
        do_false: _jsonStatementToList(block, 'DO_FALSE')
    };
};

Blockly.JSON['sensor_line_follower'] = function(block) {
    return {
        type: 'query',
        cmd: 'sensor_read_line',
        args: { pin: parseInt(block.getFieldValue('PIN')), expected: block.getFieldValue('STATE') }
    };
};

Blockly.JSON['sensor_light'] = function(block) {
    return { type: 'query', cmd: 'sensor_read_light', args: { pin: parseInt(block.getFieldValue('PIN')) } };
};

Blockly.JSON['sensor_light_print'] = function(block) {
    return {
        type: 'command',
        cmd: 'sensor_print',
        args: { sensor: 'light', pin: parseInt(block.getFieldValue('PIN')) }
    };
};

Blockly.JSON['sensor_light_if'] = function(block) {
    return {
        type: 'control',
        cmd: 'if_sensor',
        condition: { cmd: 'sensor_read_light', args: { pin: parseInt(block.getFieldValue('PIN')) } },
        op: block.getFieldValue('OP'),
        setpoint: parseFloat(block.getFieldValue('SETPOINT')),
        do_true: _jsonStatementToList(block, 'DO_TRUE'),
        do_false: _jsonStatementToList(block, 'DO_FALSE')
    };
};

Blockly.JSON['sensor_temperature'] = function(block) {
    return { type: 'query', cmd: 'sensor_read_temperature', args: { pin: parseInt(block.getFieldValue('PIN')) } };
};

Blockly.JSON['sensor_temperature_print'] = function(block) {
    return {
        type: 'command',
        cmd: 'sensor_print',
        args: { sensor: 'temperature', pin: parseInt(block.getFieldValue('PIN')) }
    };
};

Blockly.JSON['sensor_temperature_if'] = function(block) {
    return {
        type: 'control',
        cmd: 'if_sensor',
        condition: { cmd: 'sensor_read_temperature', args: { pin: parseInt(block.getFieldValue('PIN')) } },
        op: block.getFieldValue('OP'),
        setpoint: parseFloat(block.getFieldValue('SETPOINT')),
        do_true: _jsonStatementToList(block, 'DO_TRUE'),
        do_false: _jsonStatementToList(block, 'DO_FALSE')
    };
};

Blockly.JSON['sensor_humidity'] = function(block) {
    return { type: 'query', cmd: 'sensor_read_humidity', args: { pin: parseInt(block.getFieldValue('PIN')) } };
};

Blockly.JSON['sensor_humidity_print'] = function(block) {
    return {
        type: 'command',
        cmd: 'sensor_print',
        args: { sensor: 'humidity', pin: parseInt(block.getFieldValue('PIN')) }
    };
};

Blockly.JSON['sensor_humidity_if'] = function(block) {
    return {
        type: 'control',
        cmd: 'if_sensor',
        condition: { cmd: 'sensor_read_humidity', args: { pin: parseInt(block.getFieldValue('PIN')) } },
        op: block.getFieldValue('OP'),
        setpoint: parseFloat(block.getFieldValue('SETPOINT')),
        do_true: _jsonStatementToList(block, 'DO_TRUE'),
        do_false: _jsonStatementToList(block, 'DO_FALSE')
    };
};

Blockly.JSON['sensor_gas'] = function(block) {
    return {
        type: 'control',
        cmd: 'if_sensor',
        condition: { cmd: 'sensor_read_gas', args: { pin: parseInt(block.getFieldValue('PIN')) } },
        op: '==', setpoint: true,
        do_true: _jsonStatementToList(block, 'DO_DETECT'),
        do_false: _jsonStatementToList(block, 'DO_SAFE')
    };
};

Blockly.JSON['sensor_soil_moisture'] = function(block) {
    return { type: 'query', cmd: 'sensor_read_soil_moisture', args: { pin: parseInt(block.getFieldValue('PIN')) } };
};

Blockly.JSON['sensor_motion'] = function(block) {
    return {
        type: 'control',
        cmd: 'if_sensor',
        condition: { cmd: 'sensor_read_motion', args: { pin: parseInt(block.getFieldValue('PIN')) } },
        op: '==', setpoint: true,
        do_true: _jsonStatementToList(block, 'DO_DETECT'),
        do_false: _jsonStatementToList(block, 'DO_SAFE')
    };
};

Blockly.JSON['sensor_ir_obstacle'] = function(block) {
    return {
        type: 'control',
        cmd: 'if_sensor',
        condition: { cmd: 'sensor_read_ir_obstacle', args: { pin: parseInt(block.getFieldValue('PIN')) } },
        op: '==', setpoint: true,
        do_true: _jsonStatementToList(block, 'DO_DETECT'),
        do_false: _jsonStatementToList(block, 'DO_SAFE')
    };
};

// ============================================================
// 💡 LED
// ============================================================
Blockly.JSON['led_play_animation_until_done'] = function(block) {
    return { type: 'command', cmd: 'led_play_animation', args: { animation: block.getFieldValue('ANIMATION') } };
};

Blockly.JSON['led_display_5'] = function(block) {
    return {
        type: 'command',
        cmd: 'led_display',
        args: { colors: ['C1','C2','C3','C4','C5'].map(k => block.getFieldValue(k)) }
    };
};

Blockly.JSON['led_roll_right'] = function(block) {
    return { type: 'command', cmd: 'led_roll_right', args: { steps: _jsonGetValue(block, 'NUM', 1) } };
};

Blockly.JSON['led_display_color'] = function(block) {
    return {
        type: 'command',
        cmd: 'led_display_color',
        args: { target: block.getFieldValue('TARGET'), color: block.getFieldValue('COLOR') }
    };
};

Blockly.JSON['led_display_color_for'] = function(block) {
    return {
        type: 'command',
        cmd: 'led_display_color',
        args: { target: block.getFieldValue('TARGET'), color: block.getFieldValue('COLOR'), duration: _jsonGetValue(block, 'SECS', 1) }
    };
};

Blockly.JSON['led_display_rgb'] = function(block) {
    return {
        type: 'command',
        cmd: 'led_display_rgb',
        args: { target: block.getFieldValue('TARGET'), r: _jsonGetValue(block, 'R', 255), g: _jsonGetValue(block, 'G', 0), b: _jsonGetValue(block, 'B', 0) }
    };
};

Blockly.JSON['led_display_rgb_for'] = function(block) {
    return {
        type: 'command',
        cmd: 'led_display_rgb',
        args: { target: block.getFieldValue('TARGET'), r: _jsonGetValue(block, 'R', 255), g: _jsonGetValue(block, 'G', 0), b: _jsonGetValue(block, 'B', 0), duration: _jsonGetValue(block, 'SECS', 1) }
    };
};

Blockly.JSON['led_increase_brightness'] = function(block) {
    return { type: 'command', cmd: 'led_increase_brightness', args: { value: _jsonGetValue(block, 'BRIGHTNESS', 10) } };
};

Blockly.JSON['led_set_brightness'] = function(block) {
    return { type: 'command', cmd: 'led_set_brightness', args: { value: _jsonGetValue(block, 'BRIGHTNESS', 30) } };
};

Blockly.JSON['led_brightness_reporter'] = function(block) {
    return { type: 'query', cmd: 'led_get_brightness', args: {} };
};

Blockly.JSON['led_turn_off'] = function(block) {
    return { type: 'command', cmd: 'led_turn_off', args: { target: block.getFieldValue('TARGET') } };
};

// ============================================================
// 🔊 AUDIO (MockDevice — forwarded ke Agent sebagai stub)
// ============================================================
Blockly.JSON['audio_play_until_done'] = function(block) {
    return { type: 'command', cmd: 'audio_play', args: { sound: block.getFieldValue('SOUND'), wait: true } };
};
Blockly.JSON['audio_play_sound'] = function(block) {
    return { type: 'command', cmd: 'audio_play', args: { sound: block.getFieldValue('SOUND'), wait: false } };
};
Blockly.JSON['audio_start_recording'] = function(block) {
    return { type: 'command', cmd: 'audio_start_recording', args: {} };
};
Blockly.JSON['audio_stop_recording'] = function(block) {
    return { type: 'command', cmd: 'audio_stop_recording', args: {} };
};
Blockly.JSON['audio_play_recording_until_done'] = function(block) {
    return { type: 'command', cmd: 'audio_play_recording', args: { wait: true } };
};
Blockly.JSON['audio_play_recording'] = function(block) {
    return { type: 'command', cmd: 'audio_play_recording', args: { wait: false } };
};
Blockly.JSON['audio_play_note'] = function(block) {
    return { type: 'command', cmd: 'audio_play_note', args: { note: _jsonGetValue(block, 'NOTE', 60), beat: _jsonGetValue(block, 'BEAT', 0.25) } };
};
Blockly.JSON['audio_play_drum'] = function(block) {
    return { type: 'command', cmd: 'audio_play_drum', args: { drum: block.getFieldValue('DRUM'), beat: _jsonGetValue(block, 'BEAT', 0.25) } };
};
Blockly.JSON['audio_increase_speed'] = function(block) {
    return { type: 'command', cmd: 'audio_set_speed_relative', args: { delta: _jsonGetValue(block, 'SPEED', 10) } };
};
Blockly.JSON['audio_set_speed'] = function(block) {
    return { type: 'command', cmd: 'audio_set_speed', args: { value: _jsonGetValue(block, 'SPEED', 100) } };
};
Blockly.JSON['audio_speed_reporter'] = function(block) {
    return { type: 'query', cmd: 'audio_get_speed', args: {} };
};
Blockly.JSON['audio_increase_volume'] = function(block) {
    return { type: 'command', cmd: 'audio_set_volume_relative', args: { delta: _jsonGetValue(block, 'VOL', 10) } };
};
Blockly.JSON['audio_set_volume'] = function(block) {
    return { type: 'command', cmd: 'audio_set_volume', args: { value: _jsonGetValue(block, 'VOL', 30) } };
};
Blockly.JSON['audio_volume_reporter'] = function(block) {
    return { type: 'query', cmd: 'audio_get_volume', args: {} };
};
Blockly.JSON['audio_play_sound_hz_for'] = function(block) {
    return { type: 'command', cmd: 'audio_play_hz', args: { hz: _jsonGetValue(block, 'HZ', 700), duration: _jsonGetValue(block, 'SECS', 1) } };
};
Blockly.JSON['audio_play_sound_hz'] = function(block) {
    return { type: 'command', cmd: 'audio_play_hz', args: { hz: _jsonGetValue(block, 'HZ', 700) } };
};
Blockly.JSON['audio_stop_all'] = function(block) {
    return { type: 'command', cmd: 'audio_stop_all', args: {} };
};

// ==========================================================================
// 🧭 MOTION BLOCKS (MPU6050 accelerometer)
// ==========================================================================

Blockly.Blocks['motion_is_shaking'] = {
    init: function () {
        this.appendDummyInput().appendField("🧭 Sedang diguncang?");
        this.setOutput(true, "Boolean");
        this.setColour("#FF6B35");
    }
};
Blockly.Python['motion_is_shaking'] = function (block) {
    _hal_require_motion();
    return [`motion.is_shaking()`, Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['motion_is_shaking'] = function (block) {
    return { type: 'query', cmd: 'motion_is_shaking', args: {} };
};

Blockly.Blocks['motion_get_acceleration'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🧭 Akselerasi sumbu")
            .appendField(new Blockly.FieldDropdown([["X", "x"], ["Y", "y"], ["Z", "z"]]), "AXIS");
        this.setOutput(true, "Number");
        this.setColour("#FF6B35");
    }
};
Blockly.Python['motion_get_acceleration'] = function (block) {
    _hal_require_motion();
    let axis = block.getFieldValue('AXIS');
    let idx = { x: 0, y: 1, z: 2 }[axis];
    return [`motion.get_acceleration()[${idx}]`, Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['motion_get_acceleration'] = function (block) {
    return { type: 'query', cmd: 'motion_get_acceleration', args: { axis: block.getFieldValue('AXIS') } };
};

// ==========================================================================
// 🌐 LAN BLOCKS (UDP broadcast)
// ==========================================================================

Blockly.Blocks['lan_send_message'] = {
    init: function () {
        this.appendValueInput("MESSAGE")
            .setCheck(null)
            .appendField("🌐 Kirim pesan ke LAN:");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#00BCD4");
    }
};
Blockly.Python['lan_send_message'] = function (block) {
    _hal_require_lan();
    let msg = Blockly.Python.valueToCode(block, 'MESSAGE', Blockly.Python.ORDER_ATOMIC) || '""';
    return `lan.broadcast(${msg})\n`;
};
Blockly.JSON['lan_send_message'] = function (block) {
    return { type: 'command', cmd: 'lan_broadcast', args: { message: _jsonGetValue(block, 'MESSAGE', '') } };
};

// ==========================================================================
// 🤖 AI BLOCKS (Speech Recognition)
// ==========================================================================

Blockly.Blocks['ai_recognize_speech'] = {
    init: function () {
        this.appendDummyInput().appendField("🤖 Kenali ucapan (teks)");
        this.setOutput(true, "String");
        this.setColour("#9C27B0");
    }
};
Blockly.Python['ai_recognize_speech'] = function (block) {
    _hal_require_ai();
    return [`ai.recognize_speech()`, Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['ai_recognize_speech'] = function (block) {
    return { type: 'query', cmd: 'ai_recognize_speech', args: {} };
};

// ==========================================================================
// 📺 DISPLAY BLOCKS (OLED SSD1306 via luma.oled)
// ==========================================================================

Blockly.Blocks['display_print'] = {
    init: function () {
        this.appendValueInput("TEXT")
            .setCheck(null)
            .appendField("📺 Tampilkan teks:");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4CAF50");
    }
};
Blockly.Python['display_print'] = function (block) {
    _hal_require_display();
    let text = Blockly.Python.valueToCode(block, 'TEXT', Blockly.Python.ORDER_ATOMIC) || '""';
    return `display.print(${text})\n`;
};
Blockly.JSON['display_print'] = function (block) {
    return { type: 'command', cmd: 'display_print', args: { text: _jsonGetValue(block, 'TEXT', '') } };
};

Blockly.Blocks['display_print_size'] = {
    init: function () {
        this.appendValueInput("TEXT")
            .setCheck(null)
            .appendField("📺 Tampilkan teks:");
        this.appendDummyInput()
            .appendField("ukuran")
            .appendField(new Blockly.FieldDropdown([["Kecil", "SMALL"], ["Sedang", "MEDIUM"], ["Besar", "LARGE"]]), "SIZE");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4CAF50");
    }
};
Blockly.Python['display_print_size'] = function (block) {
    _hal_require_display();
    let text = Blockly.Python.valueToCode(block, 'TEXT', Blockly.Python.ORDER_ATOMIC) || '""';
    let size = block.getFieldValue('SIZE');
    return `display.print(${text}, "${size}")\n`;
};
Blockly.JSON['display_print_size'] = function (block) {
    return { type: 'command', cmd: 'display_print', args: { text: _jsonGetValue(block, 'TEXT', ''), size: block.getFieldValue('SIZE') } };
};

Blockly.Blocks['display_clear'] = {
    init: function () {
        this.appendDummyInput().appendField("📺 Bersihkan layar display");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4CAF50");
    }
};
Blockly.Python['display_clear'] = function (block) {
    _hal_require_display();
    return `display.clear()\n`;
};
Blockly.JSON['display_clear'] = function (block) {
    return { type: 'command', cmd: 'display_clear', args: {} };
};

Blockly.Blocks['display_graph'] = {
    init: function () {
        this.appendValueInput("VAL")
            .setCheck("Number")
            .appendField("📺 Tampilkan grafik nilai:");
        this.appendDummyInput().appendField("(0–100)");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4CAF50");
    }
};
Blockly.Python['display_graph'] = function (block) {
    _hal_require_display();
    let val = Blockly.Python.valueToCode(block, 'VAL', Blockly.Python.ORDER_ATOMIC) || "0";
    return `display.graph(${val})\n`;
};
Blockly.JSON['display_graph'] = function (block) {
    return { type: 'command', cmd: 'display_graph', args: { value: _jsonGetValue(block, 'VAL', 0) } };
};
