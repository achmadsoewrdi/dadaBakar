// Smart Society Blocks for Xploria v3

Blockly.Blocks['society_sos_button'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🆘 Tombol SOS Darurat Ditekan?");
        this.setOutput(true, "Boolean");
        this.setColour("#FF4500"); // OrangeRed
    }
};
Blockly.Python['society_sos_button'] = function(block) {
    return ["society.is_sos_pressed()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['society_sos_button'] = function(block) {
    return { type: 'reporter', cmd: 'society_sos_button' };
};

Blockly.Blocks['society_broadcast_message'] = {
    init: function() {
        this.appendValueInput("MESSAGE")
            .setCheck("String")
            .appendField("📢 Siarkan Pesan Info/Darurat:");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FF4500");
    }
};
Blockly.Python['society_broadcast_message'] = function(block) {
    let msg = Blockly.Python.valueToCode(block, 'MESSAGE', Blockly.Python.ORDER_ATOMIC) || '""';
    return `society.broadcast(${msg})\n`;
};
Blockly.JSON['society_broadcast_message'] = function(block) {
    return { type: 'command', cmd: 'society_broadcast_message', args: { msg: _jsonGetValue(block, 'MESSAGE', '') } };
};

Blockly.Blocks['society_crowd_detection'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("👥 Cek Keramaian Area (PIR)");
        this.setOutput(true, "Boolean");
        this.setColour("#FF4500");
    }
};
Blockly.Python['society_crowd_detection'] = function(block) {
    return ["society.is_crowded()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['society_crowd_detection'] = function(block) {
    return { type: 'reporter', cmd: 'society_crowd_detection' };
};
