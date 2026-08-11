// Smart Mobility Blocks for Xploria v3

Blockly.Blocks['mobility_drive'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🏎️ Jalankan Kendaraan")
            .appendField(new Blockly.FieldDropdown([["Maju", "FORWARD"], ["Mundur", "BACKWARD"]]), "DIR")
            .appendField("Kecepatan:")
            .appendField(new Blockly.FieldNumber(100, 0, 255), "SPEED");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4169E1"); // RoyalBlue
    }
};
Blockly.Python['mobility_drive'] = function(block) {
    let dir = block.getFieldValue('DIR');
    let speed = block.getFieldValue('SPEED');
    return `mobility.drive("${dir}", ${speed})\n`;
};
Blockly.JSON['mobility_drive'] = function(block) {
    return { type: 'command', cmd: 'mobility_drive', args: { dir: block.getFieldValue('DIR'), speed: block.getFieldValue('SPEED') } };
};

Blockly.Blocks['mobility_turn'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("↩️ Belok")
            .appendField(new Blockly.FieldDropdown([["Kanan", "RIGHT"], ["Kiri", "LEFT"]]), "DIR")
            .appendField("Kecepatan:")
            .appendField(new Blockly.FieldNumber(100, 0, 255), "SPEED");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4169E1");
    }
};
Blockly.Python['mobility_turn'] = function(block) {
    let dir = block.getFieldValue('DIR');
    let speed = block.getFieldValue('SPEED');
    return `mobility.turn("${dir}", ${speed})\n`;
};
Blockly.JSON['mobility_turn'] = function(block) {
    return { type: 'command', cmd: 'mobility_turn', args: { dir: block.getFieldValue('DIR'), speed: block.getFieldValue('SPEED') } };
};

Blockly.Blocks['mobility_stop'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🛑 Rem Darurat (Stop Kendaraan)");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#4169E1");
    }
};
Blockly.Python['mobility_stop'] = function(block) {
    return `mobility.stop()\n`;
};
Blockly.JSON['mobility_stop'] = function(block) {
    return { type: 'command', cmd: 'mobility_stop', args: {} };
};

Blockly.Blocks['mobility_check_line'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🛣️ Cek Garis Hitam di Bawah")
            .appendField(new Blockly.FieldDropdown([["Kanan", "RIGHT"], ["Kiri", "LEFT"], ["Tengah", "CENTER"]]), "SENSOR");
        this.setOutput(true, "Boolean");
        this.setColour("#4169E1");
    }
};
Blockly.Python['mobility_check_line'] = function(block) {
    let sensor = block.getFieldValue('SENSOR');
    return [`mobility.is_on_line("${sensor}")`, Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['mobility_check_line'] = function(block) {
    return { type: 'reporter', cmd: 'mobility_check_line', args: { sensor: block.getFieldValue('SENSOR') } };
};

Blockly.Blocks['mobility_obstacle_distance'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🚧 Jarak Halangan di Depan (cm)");
        this.setOutput(true, "Number");
        this.setColour("#4169E1");
    }
};
Blockly.Python['mobility_obstacle_distance'] = function(block) {
    return ["mobility.get_obstacle_distance()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['mobility_obstacle_distance'] = function(block) {
    return { type: 'reporter', cmd: 'mobility_obstacle_distance' };
};
