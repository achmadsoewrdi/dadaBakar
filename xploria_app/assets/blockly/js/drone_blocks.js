// Blockly Blocks spesifik untuk Drone DJI Tello
Blockly.Blocks['drone_takeoff'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🚁 Drone Terbang (Takeoff)");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(290);
    this.setTooltip("Menerbangkan drone ke udara.");
  }
};

Blockly.Python['drone_takeoff'] = function(block) {
  return "tello.takeoff()\n";
};

Blockly.Blocks['drone_land'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🛬 Drone Mendarat (Land)");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(290);
    this.setTooltip("Mendaratkan drone.");
  }
};

Blockly.Python['drone_land'] = function(block) {
  return "tello.land()\n";
};

Blockly.Blocks['drone_move'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Drone Maju")
        .appendField(new Blockly.FieldNumber(20, 20, 500), "DISTANCE")
        .appendField("cm");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(290);
    this.setTooltip("Menggerakkan drone maju.");
  }
};

Blockly.Python['drone_move'] = function(block) {
  var distance = block.getFieldValue('DISTANCE');
  return "tello.move_forward(" + distance + ")\n";
};
