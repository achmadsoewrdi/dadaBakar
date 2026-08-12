// Blockly Blocks untuk Dasar Pemrograman yang Ramah Anak
Blockly.Blocks['friendly_print'] = {
  init: function() {
    this.appendValueInput("TEXT")
        .setCheck(null)
        .appendField("Tampilkan");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(160);
    this.setTooltip("Tampilkan pesan ke layar.");
    this.setHelpUrl("");
  }
};

Blockly.Python['friendly_print'] = function(block) {
  var value_text = Blockly.Python.valueToCode(block, 'TEXT', Blockly.Python.ORDER_ATOMIC) || "''";
  var code = 'print(' + value_text + ')\n';
  return code;
};

// Blok jeda (sleep)
Blockly.Blocks['friendly_wait'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Tunggu")
        .appendField(new Blockly.FieldNumber(1, 0), "SECONDS")
        .appendField("detik");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(230);
    this.setTooltip("Berhenti sejenak.");
  }
};

Blockly.Python['friendly_wait'] = function(block) {
  var number_seconds = block.getFieldValue('SECONDS');
  Blockly.Python.definitions_['import_time'] = 'import time';
  return 'time.sleep(' + number_seconds + ')\n';
};
