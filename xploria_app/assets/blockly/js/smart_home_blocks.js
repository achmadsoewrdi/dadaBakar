/**
 * Smart Home Kid-Friendly Block Definitions & Python Generators
 * Xploria Platform - Designed for Kids
 */

// Helper to ensure HAL imports
function _sh_require_hal() {
    if (typeof Blockly !== 'undefined' && Blockly.Python) {
        Blockly.Python.definitions_['xploria_hal'] =
            'from xploria_hal import pin, sensor, motor, led, audio, display';
        Blockly.Python.definitions_['import_time'] = 'import time';
    }
}

// ==========================================================================
// 💡 LAMPU RUMAH (SMART LIGHTING)
// ==========================================================================

Blockly.Blocks['sh_light_toggle'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💡 Lampu")
            .appendField(new Blockly.FieldDropdown([
                ["Teras", "TERAS"],
                ["Kamar", "KAMAR"],
                ["Ruang Tamu", "RUANG_TAMU"],
                ["Dapur", "DAPUR"]
            ]), "LOCATION")
            .appendField("dibuat")
            .appendField(new Blockly.FieldDropdown([
                ["Nyalakan 🟢", "ON"],
                ["Matikan 🔴", "OFF"]
            ]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
        this.setTooltip("Menyalakan atau mematikan lampu rumah");
    }
};

Blockly.Python['sh_light_toggle'] = function (block) {
    _sh_require_hal();
    const loc = block.getFieldValue('LOCATION');
    const state = block.getFieldValue('STATE');
    const val = (state === 'ON') ? 1 : 0;
    let pinName = "LED1"; // Teras
    if (loc === "KAMAR" || loc === "RUANG_TAMU") pinName = "LED2";
    else if (loc === "DAPUR") pinName = "LED3";
    return `pin.set_digital("${pinName}", ${val})\n`;
};

Blockly.Blocks['sh_light_color'] = {
    init: function () {
        const colors = [
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ff0000'/></svg>", "width": 20, "height": 20, "alt": "Merah" }, "red"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ff8800'/></svg>", "width": 20, "height": 20, "alt": "Oranye" }, "orange"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffff00'/></svg>", "width": 20, "height": 20, "alt": "Kuning" }, "yellow"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%2300ff00'/></svg>", "width": 20, "height": 20, "alt": "Hijau" }, "green"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%230000ff'/></svg>", "width": 20, "height": 20, "alt": "Biru" }, "blue"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23800080'/></svg>", "width": 20, "height": 20, "alt": "Ungu" }, "purple"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffffff'/></svg>", "width": 20, "height": 20, "alt": "Putih" }, "white"]
        ];
        this.appendDummyInput()
            .appendField("🎨 Ubah Warna Lampu Hias ke")
            .appendField(new Blockly.FieldDropdown(colors), "COLOR");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
        this.setTooltip("Mengubah warna lampu hias kamar");
    }
};

Blockly.Python['sh_light_color'] = function (block) {
    _sh_require_hal();
    const color = block.getFieldValue('COLOR');
    return `led.display_color("ALL", "${color}")\n`;
};

Blockly.Blocks['sh_light_brightness'] = {
    init: function () {
        this.appendValueInput("BRIGHTNESS")
            .setCheck("Number")
            .appendField("🌟 Atur Kecerahan Lampu ke");
        this.appendDummyInput().appendField("%");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
        this.setTooltip("Mengatur tingkat redup/terang lampu");
    }
};

Blockly.Python['sh_light_brightness'] = function (block) {
    _sh_require_hal();
    const b = Blockly.Python.valueToCode(block, 'BRIGHTNESS', Blockly.Python.ORDER_ATOMIC) || "100";
    return `led.set_brightness(${b})\n`;
};

Blockly.Blocks['sh_light_turn_off_all'] = {
    init: function () {
        this.appendDummyInput().appendField("🌑 Matikan Semua Lampu Rumah");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
        this.setTooltip("Mematikan seluruh penerangan rumah");
    }
};

Blockly.Python['sh_light_turn_off_all'] = function (block) {
    _sh_require_hal();
    return `led.turn_off("ALL")\n`;
};


// ==========================================================================
// 🌡️ SENSOR RUMAH (PENDETEKSI)
// ==========================================================================

Blockly.Blocks['sh_sensor_motion'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🚶 Ada Gerakan Orang di")
            .appendField(new Blockly.FieldDropdown([
                ["Teras", "TERAS"],
                ["Ruang Tamu", "RUANG_TAMU"],
                ["Kamar", "KAMAR"]
            ]), "LOCATION")
            .appendField("?");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
        this.setTooltip("Mendeteksi apakah ada pergerakan orang di rumah");
    }
};

Blockly.Python['sh_sensor_motion'] = function (block) {
    _sh_require_hal();
    const loc = block.getFieldValue('LOCATION');
    return [`sensor.read_motion("${loc}")`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sh_sensor_gas'] = {
    init: function () {
        this.appendDummyInput().appendField("🚨 Deteksi Asap / Gas Bahaya di Dapur?");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
        this.setTooltip("Mendeteksi adanya kebocoran gas atau asap kebakaran");
    }
};

Blockly.Python['sh_sensor_gas'] = function (block) {
    _sh_require_hal();
    return [`sensor.read_gas("DAPUR")`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sh_sensor_dark'] = {
    init: function () {
        this.appendDummyInput().appendField("💡 Suasana Rumah Sudah Gelap / Malam?");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
        this.setTooltip("Mendeteksi apakah kondisi ruangan/teras sudah gelap");
    }
};

Blockly.Python['sh_sensor_dark'] = function (block) {
    _sh_require_hal();
    return [`sensor.read_light("TERAS") < 30`, Blockly.Python.ORDER_LOGICAL_AND];
};

Blockly.Blocks['sh_sensor_temperature'] = {
    init: function () {
        this.appendDummyInput().appendField("🌡️ Suhu Ruangan (°C)");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
        this.setTooltip("Membaca suhu udara di dalam rumah dalam derajat Celsius");
    }
};

Blockly.Python['sh_sensor_temperature'] = function (block) {
    _sh_require_hal();
    return [`sensor.read_temperature("RUANGAN")`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sh_sensor_door'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🚪 Pintu Rumah sedang")
            .appendField(new Blockly.FieldDropdown([
                ["Terbuka 🔓", "OPEN"],
                ["Terkunci 🔒", "LOCKED"]
            ]), "STATE")
            .appendField("?");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
        this.setTooltip("Mengecek apakah pintu rumah sedang terbuka atau terkunci");
    }
};

Blockly.Python['sh_sensor_door'] = function (block) {
    _sh_require_hal();
    const state = block.getFieldValue('STATE');
    return [`sensor.read_door_status() == "${state}"`, Blockly.Python.ORDER_LOGICAL_AND];
};


// ==========================================================================
// 🔊 BUNYI & ALARM
// ==========================================================================

Blockly.Blocks['sh_audio_doorbell'] = {
    init: function () {
        this.appendDummyInput().appendField("🔔 Bunyikan Bel Pintu Rumah");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
        this.setTooltip("Membunyikan suara bel pintu depan");
    }
};

Blockly.Python['sh_audio_doorbell'] = function (block) {
    _sh_require_hal();
    return `audio.play("DOORBELL")\n`;
};

Blockly.Blocks['sh_audio_alarm'] = {
    init: function () {
        this.appendDummyInput().appendField("🚨 Bunyikan Alarm Bahaya (Sirine)");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
        this.setTooltip("Membunyikan alarm suara peringatan bahaya");
    }
};

Blockly.Python['sh_audio_alarm'] = function (block) {
    _sh_require_hal();
    return `audio.play("SIREN")\n`;
};

Blockly.Blocks['sh_audio_stop'] = {
    init: function () {
        this.appendDummyInput().appendField("🔇 Matikan Semua Suara & Alarm");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6");
        this.setTooltip("Hentikan semua bunyi bel dan alarm");
    }
};

Blockly.Python['sh_audio_stop'] = function (block) {
    _sh_require_hal();
    return `pin.set_digital("BUZZER", 0)\n`;
};


// ==========================================================================
// 🚪 PINTU, GORDEN & KIPAS (PENGGERAK RUMAH)
// ==========================================================================

Blockly.Blocks['sh_door_lock'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🚪 Pintu Rumah")
            .appendField(new Blockly.FieldDropdown([
                ["Buka 🔓", "OPEN"],
                ["Kunci 🔒", "LOCK"]
            ]), "ACTION");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4169E1");
        this.setTooltip("Buka atau kunci pintu rumah otomatis");
    }
};

Blockly.Python['sh_door_lock'] = function (block) {
    _sh_require_hal();
    const act = block.getFieldValue('ACTION');
    const deg = (act === 'OPEN') ? '90' : '0';
    return `motor.set_servo("DOOR", ${deg})\n`;
};

Blockly.Blocks['sh_curtain'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🪟 Gorden Rumah")
            .appendField(new Blockly.FieldDropdown([
                ["Buka ☀️", "OPEN"],
                ["Tutup 🌙", "CLOSE"]
            ]), "ACTION");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4169E1");
        this.setTooltip("Buka atau tutup gorden jendela");
    }
};

Blockly.Python['sh_curtain'] = function (block) {
    _sh_require_hal();
    const act = block.getFieldValue('ACTION');
    const deg = (act === 'OPEN') ? '180' : '0';
    return `motor.set_servo("CURTAIN", ${deg})\n`;
};

Blockly.Blocks['sh_fan_toggle'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌀 Kipas Angin Rumah")
            .appendField(new Blockly.FieldDropdown([
                ["Nyalakan 🟢", "ON"],
                ["Matikan 🔴", "OFF"]
            ]), "ACTION");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4169E1");
        this.setTooltip("Menyalakan atau mematikan kipas angin rumah");
    }
};

Blockly.Python['sh_fan_toggle'] = function (block) {
    _sh_require_hal();
    const act = block.getFieldValue('ACTION');
    const spd = (act === 'ON') ? '100' : '0';
    return `motor.run_dc("FAN", ${spd})\n`;
};


// ==========================================================================
// 📺 LAYAR DISPLAY
// ==========================================================================

Blockly.Blocks['sh_display_print'] = {
    init: function () {
        this.appendValueInput("TEXT")
            .setCheck(["String", "Number"])
            .appendField("📺 Tampilkan Pesan");
        this.appendDummyInput().appendField("di Layar Display");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
        this.setTooltip("Menampilkan teks di layar display rumah");
    }
};

Blockly.Python['sh_display_print'] = function (block) {
    _sh_require_hal();
    const text = Blockly.Python.valueToCode(block, 'TEXT', Blockly.Python.ORDER_ATOMIC) || '"Halo!"';
    return `display.print(${text})\n`;
};

Blockly.Blocks['sh_display_clear'] = {
    init: function () {
        this.appendDummyInput().appendField("🧹 Bersihkan Layar Display");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
        this.setTooltip("Kosongkan layar display");
    }
};

Blockly.Python['sh_display_clear'] = function (block) {
    _sh_require_hal();
    return `display.clear()\n`;
};
