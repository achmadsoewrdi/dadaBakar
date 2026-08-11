// Blockly Blocks spesifik untuk Smart Home / IoT
Blockly.Blocks['iot_led_toggle'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("💡 Nyalakan LED di Pin")
        .appendField(new Blockly.FieldDropdown([["Pin 2","2"], ["Pin 4","4"], ["Pin 13","13"]]), "PIN");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(120);
    this.setTooltip("Menyalakan LED pada pin tertentu.");
  }
};

Blockly.Python['iot_led_toggle'] = function(block) {
  var pin = block.getFieldValue('PIN');
  return "hardware.set_pin(" + pin + ", 1)\n";
};
