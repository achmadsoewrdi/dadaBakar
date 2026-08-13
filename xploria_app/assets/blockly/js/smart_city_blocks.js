/**
 * Smart City Kid-Friendly Block Definitions & Python Generators
 * Xploria Platform - Designed for Kids
 */

function _sc_require_hal() {
    if (typeof Blockly !== 'undefined' && Blockly.Python) {
        Blockly.Python.definitions_['xploria_hal'] =
            'from xploria_hal import pin, sensor, motor, led, audio, display';
        Blockly.Python.definitions_['import_time'] = 'import time';
    }
}

// ==========================================================================
// 🚥 LAMPU JALAN & LALU LINTAS
// ==========================================================================

Blockly.Blocks['sc_traffic_light'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🚥 Atur Lampu Lalu Lintas ke")
            .appendField(new Blockly.FieldDropdown([
                ["Merah 🔴 (Berhenti)", "RED"],
                ["Kuning 🟡 (Hati-hati)", "YELLOW"],
                ["Hijau 🟢 (Jalan)", "GREEN"]
            ]), "COLOR");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FFD700");
        this.setTooltip("Mengatur warna lampu lalu lintas perempatan jalan");
    }
};

Blockly.Python['sc_traffic_light'] = function (block) {
    _sc_require_hal();
    const color = block.getFieldValue('COLOR');
    return `led.set_traffic_light("${color}")\n`;
};

Blockly.Blocks['sc_street_light'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🛣️ Lampu Jalan Otomatis")
            .appendField(new Blockly.FieldDropdown([
                ["Nyalakan 🟢", "ON"],
                ["Matikan 🔴", "OFF"]
            ]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FFD700");
        this.setTooltip("Nyalakan atau matikan lampu penerangan jalan utama");
    }
};

Blockly.Python['sc_street_light'] = function (block) {
    _sc_require_hal();
    const state = block.getFieldValue('STATE');
    return `led.set_street_light("${state}")\n`;
};

Blockly.Blocks['sc_park_light_color'] = {
    init: function () {
        const colors = [
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ff0000'/></svg>", "width": 20, "height": 20, "alt": "Merah" }, "red"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffff00'/></svg>", "width": 20, "height": 20, "alt": "Kuning" }, "yellow"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%2300ff00'/></svg>", "width": 20, "height": 20, "alt": "Hijau" }, "green"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%230000ff'/></svg>", "width": 20, "height": 20, "alt": "Biru" }, "blue"],
            [{ "src": "data:image/svg+xml;utf8,<svg width='20' height='20' xmlns='http://www.w3.org/2000/svg'><rect width='20' height='20' fill='%23ffffff'/></svg>", "width": 20, "height": 20, "alt": "Putih" }, "white"]
        ];
        this.appendDummyInput()
            .appendField("💡 Ubah Warna Lampu Taman Kota ke")
            .appendField(new Blockly.FieldDropdown(colors), "COLOR");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FFD700");
        this.setTooltip("Mengatur warna lampu dekorasi taman kota");
    }
};

Blockly.Python['sc_park_light_color'] = function (block) {
    _sc_require_hal();
    const color = block.getFieldValue('COLOR');
    return `led.display_color("PARK", "${color}")\n`;
};

Blockly.Blocks['sc_sensor_dark'] = {
    init: function () {
        this.appendDummyInput().appendField("💡 Suasana Jalanan Gelap / Malam?");
        this.setOutput(true, "Boolean");
        this.setColour("#FFD700");
        this.setTooltip("Mendeteksi apakah jalanan kota sudah malam/gelap");
    }
};

Blockly.Python['sc_sensor_dark'] = function (block) {
    _sc_require_hal();
    return [`sensor.read_light("STREET") < 30`, Blockly.Python.ORDER_LOGICAL_AND];
};


// ==========================================================================
// 🅿️ PARKIR & OTOMASI KOTA
// ==========================================================================

Blockly.Blocks['sc_parking_gate'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🚧 Palang Parkir Kota")
            .appendField(new Blockly.FieldDropdown([
                ["Buka 🔓", "OPEN"],
                ["Tutup 🔒", "CLOSE"]
            ]), "ACTION");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FF8C00");
        this.setTooltip("Buka atau tutup palang pintu parkir otomatis");
    }
};

Blockly.Python['sc_parking_gate'] = function (block) {
    _sc_require_hal();
    const act = block.getFieldValue('ACTION');
    const deg = (act === 'OPEN') ? '90' : '0';
    return `motor.set_servo("PARKING_GATE", ${deg})\n`;
};

Blockly.Blocks['sc_sensor_car'] = {
    init: function () {
        this.appendDummyInput().appendField("🚗 Ada Mobil Datang di Pintu Parkir?");
        this.setOutput(true, "Boolean");
        this.setColour("#FF8C00");
        this.setTooltip("Mendeteksi jika ada mobil mendekati pintu masuk parkir");
    }
};

Blockly.Python['sc_sensor_car'] = function (block) {
    _sc_require_hal();
    return [`sensor.read_ultrasonic("PARKING_ENTRANCE") < 15`, Blockly.Python.ORDER_LOGICAL_AND];
};

Blockly.Blocks['sc_parking_available'] = {
    init: function () {
        this.appendDummyInput().appendField("🅿️ Apakah Area Parkir Masih Kosong?");
        this.setOutput(true, "Boolean");
        this.setColour("#FF8C00");
        this.setTooltip("Mengecek ketersediaan tempat parkir kendaraan");
    }
};

Blockly.Python['sc_parking_available'] = function (block) {
    _sc_require_hal();
    return [`sensor.read_parking_available()`, Blockly.Python.ORDER_ATOMIC];
};


// ==========================================================================
// 🗑️ KEBERSIHAN & LINGKUNGAN KOTA
// ==========================================================================

Blockly.Blocks['sc_trash_full'] = {
    init: function () {
        this.appendDummyInput().appendField("🗑️ Apakah Tempat Sampah Sudah Penuh?");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
        this.setTooltip("Mendeteksi apakah tempat sampah publik sudah 100% penuh");
    }
};

Blockly.Python['sc_trash_full'] = function (block) {
    _sc_require_hal();
    return [`sensor.read_trash_level() >= 90`, Blockly.Python.ORDER_LOGICAL_AND];
};

Blockly.Blocks['sc_air_quality'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌫️ Kualitas Udara Kota")
            .appendField(new Blockly.FieldDropdown([
                ["Berpolusi 😷", "POLLUTED"],
                ["Bersih / Segar 🌿", "CLEAN"]
            ]), "STATUS")
            .appendField("?");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
        this.setTooltip("Cek apakah kondisi polusi udara di kota sedang tinggi");
    }
};

Blockly.Python['sc_air_quality'] = function (block) {
    _sc_require_hal();
    const st = block.getFieldValue('STATUS');
    return [`sensor.read_air_quality() == "${st}"`, Blockly.Python.ORDER_LOGICAL_AND];
};

Blockly.Blocks['sc_sensor_flood'] = {
    init: function () {
        this.appendDummyInput().appendField("🌧️ Apakah Terdeteksi Genangan Air / Hujan?");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
        this.setTooltip("Mendeteksi adanya genangan air banjir di jalanan kota");
    }
};

Blockly.Python['sc_sensor_flood'] = function (block) {
    _sc_require_hal();
    return [`sensor.read_water_level() > 50`, Blockly.Python.ORDER_LOGICAL_AND];
};


// ==========================================================================
// 🚨 KEAMANAN & SIRINE KOTA
// ==========================================================================

Blockly.Blocks['sc_siren_start'] = {
    init: function () {
        this.appendDummyInput().appendField("🚨 Bunyikan Sirine Darurat Kota");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#E53E3E");
        this.setTooltip("Membunyikan alarm sirine peringatan kota");
    }
};

Blockly.Python['sc_siren_start'] = function (block) {
    _sc_require_hal();
    return `audio.play("CITY_SIREN")\n`;
};

Blockly.Blocks['sc_emergency_light'] = {
    init: function () {
        this.appendDummyInput().appendField("💡 Nyalakan Lampu Darurat Peringatan");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#E53E3E");
        this.setTooltip("Nyalakan lampu kilat merah darurat");
    }
};

Blockly.Python['sc_emergency_light'] = function (block) {
    _sc_require_hal();
    return `led.display_color("EMERGENCY", "red")\n`;
};

Blockly.Blocks['sc_siren_stop'] = {
    init: function () {
        this.appendDummyInput().appendField("🔇 Matikan Sirine & Peringatan Kota");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#E53E3E");
        this.setTooltip("Matikan sirine dan lampu darurat kota");
    }
};

Blockly.Python['sc_siren_stop'] = function (block) {
    _sc_require_hal();
    return `audio.stop_all()\nled.turn_off("EMERGENCY")\n`;
};


// ==========================================================================
// 📺 PAPAN PENGUMUMAN KOTA (PUBLIC DISPLAY)
// ==========================================================================

Blockly.Blocks['sc_display_announce'] = {
    init: function () {
        this.appendValueInput("TEXT")
            .setCheck(["String", "Number"])
            .appendField("📢 Siarkan Pengumuman di Layar Kota");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
        this.setTooltip("Menampilkan pesan pengumuman pada layar jalanan publik");
    }
};

Blockly.Python['sc_display_announce'] = function (block) {
    _sc_require_hal();
    const text = Blockly.Python.valueToCode(block, 'TEXT', Blockly.Python.ORDER_ATOMIC) || '"Lalu Lintas Lancar"';
    return `display.print(${text})\n`;
};

Blockly.Blocks['sc_display_clear'] = {
    init: function () {
        this.appendDummyInput().appendField("🧹 Bersihkan Papan Pengumuman");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
        this.setTooltip("Kosongkan layar pengumuman jalanan");
    }
};

Blockly.Python['sc_display_clear'] = function (block) {
    _sc_require_hal();
    return `display.clear()\n`;
};
