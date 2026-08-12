// Blockly Blocks spesifik untuk Drone DJI Tello
Blockly.Blocks['drone_takeoff'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🚁 Terbang (Takeoff)");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#FF4D4D');
    this.setTooltip("Menerbangkan drone ke udara.");
  }
};
Blockly.Python['drone_takeoff'] = function(block) {
  return "tello.takeoff()\n";
};

Blockly.Blocks['drone_land'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🛬 Mendarat (Land)");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#FF4D4D');
    this.setTooltip("Mendaratkan drone.");
  }
};
Blockly.Python['drone_land'] = function(block) {
  return "tello.land()\n";
};

Blockly.Blocks['drone_stop'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🛑 Berhenti & Hover (Stop)");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#FF4D4D');
    this.setTooltip("Menghentikan seluruh gerakan dan melayang di tempat.");
  }
};
Blockly.Python['drone_stop'] = function(block) {
  return "tello.stop()\n";
};

Blockly.Blocks['drone_move_direction'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Gerak")
        .appendField(new Blockly.FieldDropdown([
            ["Maju ⬆️", "forward"], 
            ["Mundur ⬇️", "back"], 
            ["Kiri ⬅️", "left"], 
            ["Kanan ➡️", "right"], 
            ["Naik 🔼", "up"], 
            ["Turun 🔽", "down"]
        ]), "DIR")
        .appendField("sejauh")
        .appendField(new Blockly.FieldNumber(20, 20, 500), "DISTANCE")
        .appendField("cm");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#FF4D4D');
    this.setTooltip("Menggerakkan drone ke arah tertentu. (Min 20cm, Max 500cm)");
  }
};
Blockly.Python['drone_move_direction'] = function(block) {
  var dir = block.getFieldValue('DIR');
  var distance = block.getFieldValue('DISTANCE');
  return "tello.move_" + dir + "(" + distance + ")\n";
};

Blockly.Blocks['drone_rotate'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Putar")
        .appendField(new Blockly.FieldDropdown([
            ["Kanan (Searah Jarum Jam) ↻", "cw"], 
            ["Kiri (Berlawanan Jarum Jam) ↺", "ccw"]
        ]), "DIR")
        .appendField("sebanyak")
        .appendField(new Blockly.FieldNumber(90, 1, 360), "DEGREE")
        .appendField("derajat");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#FF4D4D');
    this.setTooltip("Memutar drone. (Min 1°, Max 360°)");
  }
};
Blockly.Python['drone_rotate'] = function(block) {
  var dir = block.getFieldValue('DIR');
  var degree = block.getFieldValue('DEGREE');
  return "tello.rotate_" + dir + "(" + degree + ")\n";
};

Blockly.Blocks['drone_flip'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("🤸 Salto (Flip) ke")
        .appendField(new Blockly.FieldDropdown([
            ["Depan", "f"], 
            ["Belakang", "b"], 
            ["Kiri", "l"], 
            ["Kanan", "r"]
        ]), "DIR");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour('#FF4D4D');
    this.setTooltip("Melakukan gerakan salto 3D ke arah yang dipilih.");
  }
};
Blockly.Python['drone_flip'] = function(block) {
  var dir = block.getFieldValue('DIR');
  return "tello.flip('" + dir + "')\n";
};
