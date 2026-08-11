/**
 * Smart Agriculture Kid-Friendly Block Definitions & Python Generators
 * Xploria Platform - Designed for Kids
 */

function _sa_require_hal() {
    if (typeof Blockly !== 'undefined' && Blockly.Python) {
        Blockly.Python.definitions_['xploria_hal'] =
            'from xploria_hal import pin, sensor, motor, led, audio, display';
        Blockly.Python.definitions_['import_time'] = 'import time';
    }
}

// ==========================================================================
// 🌱 TANAH & PENYIRAMAN (SOIL & IRRIGATION)
// ==========================================================================

Blockly.Blocks['sa_soil_dry'] = {
    init: function () {
        this.appendDummyInput().appendField("💧 Apakah Tanah Kering?");
        this.setOutput(true, "Boolean");
        this.setColour("#2E8B57");
        this.setTooltip("Mendeteksi apakah kebasahan tanah kurang dan butuh disiram");
    }
};

Blockly.Python['sa_soil_dry'] = function (block) {
    _sa_require_hal();
    return [`sensor.read_soil_moisture("SOIL") < 30`, Blockly.Python.ORDER_LOGICAL_AND];
};

Blockly.Blocks['sa_soil_moisture'] = {
    init: function () {
        this.appendDummyInput().appendField("💧 Kelembapan Tanah (%)");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
        this.setTooltip("Membaca persen kebasahan air dalam tanah");
    }
};

Blockly.Python['sa_soil_moisture'] = function (block) {
    _sa_require_hal();
    return [`sensor.read_soil_moisture("SOIL")`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sa_water_pump'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🚰 Pompa Air (Siram Tanaman)")
            .appendField(new Blockly.FieldDropdown([
                ["Nyalakan 🟢", "ON"],
                ["Matikan 🔴", "OFF"]
            ]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
        this.setTooltip("Menyalakan atau mematikan pompa penyiraman air tanaman");
    }
};

Blockly.Python['sa_water_pump'] = function (block) {
    _sa_require_hal();
    const st = block.getFieldValue('STATE');
    const spd = (st === 'ON') ? '100' : '0';
    return `motor.run_pump("WATER_PUMP", ${spd})\n`;
};


// ==========================================================================
// ☀️ CUACA & RUMAH KACA (GREENHOUSE CLIMATE)
// ==========================================================================

Blockly.Blocks['sa_temp'] = {
    init: function () {
        this.appendDummyInput().appendField("🌡️ Suhu Rumah Kaca (°C)");
        this.setOutput(true, "Number");
        this.setColour("#3CB371");
        this.setTooltip("Membaca derajat suhu udara di dalam green house");
    }
};

Blockly.Python['sa_temp'] = function (block) {
    _sa_require_hal();
    return [`sensor.read_temperature("GREENHOUSE")`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sa_humidity'] = {
    init: function () {
        this.appendDummyInput().appendField("💧 Kelembapan Udara (%)");
        this.setOutput(true, "Number");
        this.setColour("#3CB371");
        this.setTooltip("Membaca persentase kelembapan udara di green house");
    }
};

Blockly.Python['sa_humidity'] = function (block) {
    _sa_require_hal();
    return [`sensor.read_humidity("GREENHOUSE")`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sa_fan'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🌀 Kipas Pendingin Kebun")
            .appendField(new Blockly.FieldDropdown([
                ["Nyalakan 🟢", "ON"],
                ["Matikan 🔴", "OFF"]
            ]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#3CB371");
        this.setTooltip("Menyalakan kipas mendinginkan suhu greenhouse");
    }
};

Blockly.Python['sa_fan'] = function (block) {
    _sa_require_hal();
    const st = block.getFieldValue('STATE');
    const spd = (st === 'ON') ? '100' : '0';
    return `motor.run_dc("COOLING_FAN", ${spd})\n`;
};

Blockly.Blocks['sa_sensor_cloudy'] = {
    init: function () {
        this.appendDummyInput().appendField("💡 Cuaca Mendung / Redup?");
        this.setOutput(true, "Boolean");
        this.setColour("#3CB371");
        this.setTooltip("Mendeteksi jika sinar matahari di kebun sedang redup");
    }
};

Blockly.Python['sa_sensor_cloudy'] = function (block) {
    _sa_require_hal();
    return [`sensor.read_light("GREENHOUSE") < 30`, Blockly.Python.ORDER_LOGICAL_AND];
};


// ==========================================================================
// 💡 LAMPU TANAMAN (GROW LIGHT)
// ==========================================================================

Blockly.Blocks['sa_grow_light'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💡 Lampu Tumbuh (Grow Light)")
            .appendField(new Blockly.FieldDropdown([
                ["Nyalakan 🟢", "ON"],
                ["Matikan 🔴", "OFF"]
            ]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
        this.setTooltip("Nyalakan lampu khusus fotosintesis pertumbuhan tanaman");
    }
};

Blockly.Python['sa_grow_light'] = function (block) {
    _sa_require_hal();
    const st = block.getFieldValue('STATE');
    return `led.set_light("GROW_LIGHT", "${st}")\n`;
};

Blockly.Blocks['sa_grow_light_color'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🎨 Ubah Warna Lampu Tanaman ke")
            .appendField(new Blockly.FieldDropdown([
                ["Merah-Biru (UV Growth)", "UV_PURPLE"],
                ["Putih Terang", "WHITE"],
                ["Kuning Hangat", "WARM_YELLOW"]
            ]), "COLOR");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
        this.setTooltip("Mengatur spektrum warna lampu fotosintesis tanaman");
    }
};

Blockly.Python['sa_grow_light_color'] = function (block) {
    _sa_require_hal();
    const color = block.getFieldValue('COLOR');
    return `led.display_color("GROW_LIGHT", "${color}")\n`;
};

Blockly.Blocks['sa_grow_light_brightness'] = {
    init: function () {
        this.appendValueInput("BRIGHTNESS")
            .setCheck("Number")
            .appendField("🌟 Atur Kecerahan Lampu Tanaman ke");
        this.appendDummyInput().appendField("%");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2");
        this.setTooltip("Mengatur tingkat intensitas cahaya lampu tanaman");
    }
};

Blockly.Python['sa_grow_light_brightness'] = function (block) {
    _sa_require_hal();
    const b = Blockly.Python.valueToCode(block, 'BRIGHTNESS', Blockly.Python.ORDER_ATOMIC) || "100";
    return `led.set_brightness(${b})\n`;
};


// ==========================================================================
// 🦝 PENGUSIR HAMA & ALARM (FARM SECURITY)
// ==========================================================================

Blockly.Blocks['sa_sensor_pest'] = {
    init: function () {
        this.appendDummyInput().appendField("🚶 Ada Hewan / Hama Masuk Kebun?");
        this.setOutput(true, "Boolean");
        this.setColour("#E53E3E");
        this.setTooltip("Mendeteksi jika ada burung atau hewan liar masuk kebun");
    }
};

Blockly.Python['sa_sensor_pest'] = function (block) {
    _sa_require_hal();
    return [`sensor.read_motion("FARM_FIELD")`, Blockly.Python.ORDER_ATOMIC];
};

Blockly.Blocks['sa_pest_repeller'] = {
    init: function () {
        this.appendDummyInput().appendField("🔊 Bunyikan Suara Pengusir Hama");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#E53E3E");
        this.setTooltip("Membunyikan frekuensi suara khusus mengusir burung/hama");
    }
};

Blockly.Python['sa_pest_repeller'] = function (block) {
    _sa_require_hal();
    return `audio.play("PEST_REPELLER")\n`;
};

Blockly.Blocks['sa_alarm_start'] = {
    init: function () {
        this.appendDummyInput().appendField("🚨 Bunyikan Sirine Kebun");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#E53E3E");
        this.setTooltip("Membunyikan sirine bahaya gangguan kebun");
    }
};

Blockly.Python['sa_alarm_start'] = function (block) {
    _sa_require_hal();
    return `audio.play("FARM_SIREN")\n`;
};

Blockly.Blocks['sa_alarm_stop'] = {
    init: function () {
        this.appendDummyInput().appendField("🔇 Matikan Alarm Kebun");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#E53E3E");
        this.setTooltip("Matikan suara pengusir hama dan sirine kebun");
    }
};

Blockly.Python['sa_alarm_stop'] = function (block) {
    _sa_require_hal();
    return `audio.stop_all()\n`;
};


// ==========================================================================
// 📺 MONITOR KEBUN (FARM DISPLAY)
// ==========================================================================

Blockly.Blocks['sa_display_print'] = {
    init: function () {
        this.appendValueInput("TEXT")
            .setCheck(["String", "Number"])
            .appendField("📺 Tampilkan Status Kebun di Layar");
        this.setInputsInline(true);
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
        this.setTooltip("Print pesan status kebun ke monitor display");
    }
};

Blockly.Python['sa_display_print'] = function (block) {
    _sa_require_hal();
    const text = Blockly.Python.valueToCode(block, 'TEXT', Blockly.Python.ORDER_ATOMIC) || '"Tanah Lembap"';
    return `display.print(${text})\n`;
};

Blockly.Blocks['sa_display_clear'] = {
    init: function () {
        this.appendDummyInput().appendField("🧹 Bersihkan Layar Monitor Kebun");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8B008B");
        this.setTooltip("Kosongkan monitor status kebun");
    }
};

Blockly.Python['sa_display_clear'] = function (block) {
    _sa_require_hal();
    return `display.clear()\n`;
};
