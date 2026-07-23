/**
 * Custom Blockly Block Definitions & Python Generators for mBlock Style Categories
 */

// ==========================================================================
// 🔊 AUDIO BLOCKS
// ==========================================================================
Blockly.Blocks['audio_play_sound'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("🔊 Mainkan Suara")
            .appendField(new Blockly.FieldDropdown([
                ["Meow", "MEOW"],
                ["Beep", "BEEP"],
                ["Siren", "SIREN"]
            ]), "SOUND");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#D65CD6"); // Pink/Purple
        this.setTooltip("Memutar suara yang dipilih");
    }
};

Blockly.Python['audio_play_sound'] = function (block) {
    return `audio.play("${block.getFieldValue('SOUND')}")\n`;
};

// ==========================================================================
// 💡 LED BLOCKS
// ==========================================================================
Blockly.Blocks['led_set_color'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("💡 Nyalakan LED warna")
            .appendField(new Blockly.FieldColour("#ff0000"), "COLOR");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#8A2BE2"); // Blue-Violet
        this.setTooltip("Menyalakan LED dengan warna spesifik");
    }
};

Blockly.Python['led_set_color'] = function (block) {
    return `led.set_color("${block.getFieldValue('COLOR')}")\n`;
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
    return `def on_start():\n`;
};
