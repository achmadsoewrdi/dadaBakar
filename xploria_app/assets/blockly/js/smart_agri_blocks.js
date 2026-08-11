// Smart Agriculture Blocks for Xploria v3

Blockly.Blocks['agri_soil_moisture'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🌱 Baca Kelembapan Tanah (%)");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57"); // SeaGreen
    }
};
Blockly.Python['agri_soil_moisture'] = function(block) {
    return ["agri.get_soil_moisture()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['agri_soil_moisture'] = function(block) {
    return { type: 'reporter', cmd: 'agri_soil_moisture' };
};

Blockly.Blocks['agri_water_pump'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("💧 Pompa Air (Siram Tanaman)")
            .appendField(new Blockly.FieldDropdown([["Nyalakan", "ON"], ["Matikan", "OFF"]]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['agri_water_pump'] = function(block) {
    let state = block.getFieldValue('STATE');
    return `agri.water_pump("${state}")\n`;
};
Blockly.JSON['agri_water_pump'] = function(block) {
    return { type: 'command', cmd: 'agri_water_pump', args: { state: block.getFieldValue('STATE') } };
};

Blockly.Blocks['agri_grow_light'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("💡 Lampu Tumbuh (Grow Light)")
            .appendField(new Blockly.FieldDropdown([["Nyalakan", "ON"], ["Matikan", "OFF"]]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#2E8B57");
    }
};
Blockly.Python['agri_grow_light'] = function(block) {
    let state = block.getFieldValue('STATE');
    return `agri.grow_light("${state}")\n`;
};
Blockly.JSON['agri_grow_light'] = function(block) {
    return { type: 'command', cmd: 'agri_grow_light', args: { state: block.getFieldValue('STATE') } };
};

Blockly.Blocks['agri_greenhouse_temp'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🌡️ Baca Suhu Rumah Kaca (°C)");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['agri_greenhouse_temp'] = function(block) {
    return ["agri.get_temperature()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['agri_greenhouse_temp'] = function(block) {
    return { type: 'reporter', cmd: 'agri_greenhouse_temp' };
};

Blockly.Blocks['agri_greenhouse_humidity'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("☁️ Baca Kelembapan Udara (%)");
        this.setOutput(true, "Number");
        this.setColour("#2E8B57");
    }
};
Blockly.Python['agri_greenhouse_humidity'] = function(block) {
    return ["agri.get_humidity()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['agri_greenhouse_humidity'] = function(block) {
    return { type: 'reporter', cmd: 'agri_greenhouse_humidity' };
};
