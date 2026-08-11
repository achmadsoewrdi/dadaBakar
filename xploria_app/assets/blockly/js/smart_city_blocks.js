// Smart City Blocks for Xploria v3

Blockly.Blocks['city_traffic_light'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🚦 Atur Lampu Lalu Lintas")
            .appendField(new Blockly.FieldDropdown([["Merah", "RED"], ["Kuning", "YELLOW"], ["Hijau", "GREEN"]]), "COLOR");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FFD700"); // Yellow/Gold
    }
};
Blockly.Python['city_traffic_light'] = function(block) {
    let color = block.getFieldValue('COLOR');
    return `city.set_traffic_light("${color}")\n`;
};
Blockly.JSON['city_traffic_light'] = function(block) {
    return { type: 'command', cmd: 'city_traffic_light', args: { color: block.getFieldValue('COLOR') } };
};

Blockly.Blocks['city_street_light'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("💡 Atur Lampu Jalan")
            .appendField(new Blockly.FieldDropdown([["Otomatis (Sensor Gelap)", "AUTO"], ["Nyala Paksa", "ON"], ["Mati Paksa", "OFF"]]), "MODE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FFD700");
    }
};
Blockly.Python['city_street_light'] = function(block) {
    let mode = block.getFieldValue('MODE');
    return `city.set_street_light("${mode}")\n`;
};
Blockly.JSON['city_street_light'] = function(block) {
    return { type: 'command', cmd: 'city_street_light', args: { mode: block.getFieldValue('MODE') } };
};

Blockly.Blocks['city_parking_gate'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🅿️ Palang Parkir")
            .appendField(new Blockly.FieldDropdown([["Buka", "OPEN"], ["Tutup", "CLOSE"]]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#FFD700");
    }
};
Blockly.Python['city_parking_gate'] = function(block) {
    let state = block.getFieldValue('STATE');
    return `city.parking_gate("${state}")\n`;
};
Blockly.JSON['city_parking_gate'] = function(block) {
    return { type: 'command', cmd: 'city_parking_gate', args: { state: block.getFieldValue('STATE') } };
};

Blockly.Blocks['city_trash_level'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🗑️ Cek Kapasitas Tempat Sampah (%)");
        this.setOutput(true, "Number");
        this.setColour("#FFD700");
    }
};
Blockly.Python['city_trash_level'] = function(block) {
    return ["city.get_trash_level()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['city_trash_level'] = function(block) {
    return { type: 'reporter', cmd: 'city_trash_level' };
};

Blockly.Blocks['city_air_quality'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("☁️ Cek Kualitas Udara (Polusi)");
        this.setOutput(true, "Number");
        this.setColour("#FFD700");
    }
};
Blockly.Python['city_air_quality'] = function(block) {
    return ["city.get_air_quality()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['city_air_quality'] = function(block) {
    return { type: 'reporter', cmd: 'city_air_quality' };
};
