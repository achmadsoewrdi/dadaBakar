// Smart Industry Blocks for Xploria v3

Blockly.Blocks['industry_conveyor'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("⚙️ Ban Berjalan (Conveyor)")
            .appendField(new Blockly.FieldDropdown([["Jalankan", "RUN"], ["Hentikan", "STOP"]]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#708090"); // SlateGray
    }
};
Blockly.Python['industry_conveyor'] = function(block) {
    let state = block.getFieldValue('STATE');
    return `industry.conveyor("${state}")\n`;
};
Blockly.JSON['industry_conveyor'] = function(block) {
    return { type: 'command', cmd: 'industry_conveyor', args: { state: block.getFieldValue('STATE') } };
};

Blockly.Blocks['industry_item_counter'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("📦 Hitung Jumlah Barang Lewat");
        this.setOutput(true, "Number");
        this.setColour("#708090");
    }
};
Blockly.Python['industry_item_counter'] = function(block) {
    return ["industry.get_item_count()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['industry_item_counter'] = function(block) {
    return { type: 'reporter', cmd: 'industry_item_counter' };
};

Blockly.Blocks['industry_machine_temp'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🌡️ Cek Suhu Mesin (°C)");
        this.setOutput(true, "Number");
        this.setColour("#708090");
    }
};
Blockly.Python['industry_machine_temp'] = function(block) {
    return ["industry.get_machine_temperature()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['industry_machine_temp'] = function(block) {
    return { type: 'reporter', cmd: 'industry_machine_temp' };
};

Blockly.Blocks['industry_emergency_stop'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🛑 Tombol Darurat Ditekan?");
        this.setOutput(true, "Boolean");
        this.setColour("#708090");
    }
};
Blockly.Python['industry_emergency_stop'] = function(block) {
    return ["industry.is_emergency_stop()", Blockly.Python.ORDER_ATOMIC];
};
Blockly.JSON['industry_emergency_stop'] = function(block) {
    return { type: 'reporter', cmd: 'industry_emergency_stop' };
};

Blockly.Blocks['industry_siren'] = {
    init: function() {
        this.appendDummyInput()
            .appendField("🚨 Sirine Pabrik")
            .appendField(new Blockly.FieldDropdown([["Nyalakan", "ON"], ["Matikan", "OFF"]]), "STATE");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour("#708090");
    }
};
Blockly.Python['industry_siren'] = function(block) {
    let state = block.getFieldValue('STATE');
    return `industry.siren("${state}")\n`;
};
Blockly.JSON['industry_siren'] = function(block) {
    return { type: 'command', cmd: 'industry_siren', args: { state: block.getFieldValue('STATE') } };
};
