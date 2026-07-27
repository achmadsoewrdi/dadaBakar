/**
 * Application Entry Point & Blockly Core Service
 */

// Initialize Blockly Workspace
Blockly.Scrollbar.scrollbarThickness = 6; // Membuat scrollbar lebih tipis

const myTheme = Blockly.Theme.defineTheme('xploriaTheme', {
    base: Blockly.Themes.Zelos, // Menggunakan base Zelos (ala Scratch)
    fontStyle: {
        "family": "'Nunito', sans-serif",
        "weight": "700",
        "size": 15
    }
});

const workspace = Blockly.inject('blocklyDiv', {
    renderer: 'zelos',
    theme: myTheme,
    scrollbars: true,
    trashcan: false,
    zoom: {
        controls: false, // Custom Floating Toolbar handles Zoom
        wheel: true,
        pinch: true,
        startScale: 0.9,
        maxScale: 3,
        minScale: 0.3,
        scaleSpeed: 1.2
    },
    grid: {
        spacing: 25,
        length: 3,
        colour: '#cbd5e1',
        snap: true
    }
});

// Floating Toolbar Functions
function zoomIn() {
    const metrics = workspace.getMetrics();
    workspace.zoom(metrics.viewWidth / 2, metrics.viewHeight / 2, 1);
}

function zoomOut() {
    const metrics = workspace.getMetrics();
    workspace.zoom(metrics.viewWidth / 2, metrics.viewHeight / 2, -1);
}

function resetZoom() {
    workspace.setScale(0.9);
    workspace.scrollCenter();
}

function clearWorkspace() {
    // Jika ada blok yang sedang dipilih (tapped), hapus hanya blok tersebut
    const selectedBlock = Blockly.common ? Blockly.common.getSelected() : Blockly.selected;
    if (selectedBlock) {
        selectedBlock.dispose(true); // true = hapus anak-anaknya juga
        notifyFlutter();
        return;
    }

    // Jika tidak ada yang dipilih, hapus semua blok
    if (workspace.getAllBlocks(false).length === 0) return;
    if (confirm("Apakah kamu yakin ingin menghapus SEMUA blok di layar? 🗑️")) {
        workspace.clear();
        notifyFlutter();
    }
}

// Flutter WebViewController Bridge Listener
function notifyFlutter() {
    let pythonCode = Blockly.Python.workspaceToCode(workspace);
    
    // Injeksi otomatis import library standar Exploria di baris paling atas
    if (pythonCode.trim() !== "") {
        const standardImports = `import time
import math
import sys
import warnings
warnings.simplefilter('ignore')

# --- UNIVERSAL HARDWARE ABSTRACTION LAYER ---
class MockDevice:
    def __getattr__(self, name):
        def method(*args, **kwargs):
            return 0
        return method

try:
    _IS_ESP = sys.platform == 'esp32'
except:
    _IS_ESP = False

class SensorHAL:
    def __init__(self):
        if _IS_ESP:
            import machine, dht
            self.machine = machine
            self.dht = dht
            self._pins = {}
        else:
            try:
                from gpiozero import DigitalInputDevice, DistanceSensor
                import adafruit_dht, board
                self.DigitalInputDevice = DigitalInputDevice
                self.DistanceSensor = DistanceSensor
                self.adafruit_dht = adafruit_dht
                self.board = board
            except ImportError:
                pass
            self._pins = {}

    def _get_digital_in(self, p, pull_up=False):
        if p not in self._pins:
            if _IS_ESP:
                self._pins[p] = self.machine.Pin(p, self.machine.Pin.IN, self.machine.Pin.PULL_UP if pull_up else None)
            else:
                self._pins[p] = self.DigitalInputDevice(p, pull_up=pull_up)
        return self._pins[p]

    def read_gas(self, p):
        # MQ-9 biasanya active LOW untuk mendeteksi gas
        if _IS_ESP: return self._get_digital_in(p, True).value() == 0
        else: return self._get_digital_in(p, True).value == 0

    def read_motion(self, p):
        # PIR active HIGH saat ada gerakan
        if _IS_ESP: return self._get_digital_in(p, False).value() == 1
        else: return self._get_digital_in(p, False).value == 1

    def read_ir_obstacle(self, p):
        # MH-Sensor IR active LOW/HIGH tergantung setelan, standarnya deteksi = 1 atau 0.
        # Pada project manual disebut "Active HIGH (True saat ada objek)"
        if _IS_ESP: return self._get_digital_in(p, True).value() == 1
        else: return self._get_digital_in(p, True).value == 1

    def read_temperature(self, p):
        if _IS_ESP:
            if p not in self._pins: self._pins[p] = self.dht.DHT22(self.machine.Pin(p))
            try:
                self._pins[p].measure()
                return self._pins[p].temperature()
            except: return 0
        else:
            if p not in self._pins:
                pin_obj = getattr(self.board, f'D{p}')
                self._pins[p] = self.adafruit_dht.DHT22(pin_obj)
            try: return self._pins[p].temperature
            except: return 0

    def read_humidity(self, p):
        if _IS_ESP:
            if p not in self._pins: self._pins[p] = self.dht.DHT22(self.machine.Pin(p))
            try:
                self._pins[p].measure()
                return self._pins[p].humidity()
            except: return 0
        else:
            if p not in self._pins:
                pin_obj = getattr(self.board, f'D{p}')
                self._pins[p] = self.adafruit_dht.DHT22(pin_obj)
            try: return self._pins[p].humidity
            except: return 0

    def read_ultrasonic(self, trig, echo):
        if _IS_ESP:
            return 0 # Simplified for ESP32 without hcsr04 lib
        else:
            if trig not in self._pins:
                self._pins[trig] = self.DistanceSensor(echo=echo, trigger=trig, max_distance=2.0)
            return self._pins[trig].distance * 100

class PinHAL:
    def __init__(self):
        if _IS_ESP:
            import machine
            self.machine = machine
        else:
            try:
                from gpiozero import DigitalOutputDevice, DigitalInputDevice
                self.DigitalOutputDevice = DigitalOutputDevice
                self.DigitalInputDevice = DigitalInputDevice
            except ImportError:
                pass
        self._pins = {}

    def set_digital(self, p, state):
        val = 1 if state == "HIGH" else 0
        if p not in self._pins:
            if _IS_ESP: self._pins[p] = self.machine.Pin(p, self.machine.Pin.OUT)
            else: self._pins[p] = self.DigitalOutputDevice(p)
        if _IS_ESP: self._pins[p].value(val)
        else:
            if val: self._pins[p].on()
            else: self._pins[p].off()

class MotorHAL:
    def __init__(self):
        if _IS_ESP:
            import machine
            self.machine = machine
        else:
            try:
                from gpiozero import Servo
                self.Servo = Servo
            except ImportError:
                pass
        self._pins = {}

    def set_servo(self, p, degree):
        if _IS_ESP:
            if p not in self._pins:
                self._pins[p] = self.machine.PWM(self.machine.Pin(p), freq=50)
            duty = int(40 + (degree / 180.0) * 75)
            self._pins[p].duty(duty)
        else:
            if p not in self._pins:
                self._pins[p] = self.Servo(p)
            val = (degree - 90) / 90.0
            self._pins[p].value = val

class LEDHAL(PinHAL):
    def display_color(self, p, color):
        # Simplified: On if not black
        self.set_digital(p, "HIGH" if color != "black" else "LOW")
    def turn_off(self, p):
        self.set_digital(p, "LOW")

sensor = SensorHAL()
pin = PinHAL()
motor = MotorHAL()
led = LEDHAL()
audio = MockDevice()
display = MockDevice()
motion = MockDevice()
lan = MockDevice()
ai = MockDevice()
# ----------------------------------------------

\n`;
        pythonCode = standardImports + pythonCode;
    }

    const xmlDom = Blockly.Xml.workspaceToDom(workspace);
    const xmlText = Blockly.Xml.domToText(xmlDom);

    if (window.FlutterBlocklyBridge) {
        window.FlutterBlocklyBridge.postMessage(JSON.stringify({
            type: 'WORKSPACE_UPDATE',
            pythonCode: pythonCode,
            xmlData: xmlText
        }));
    }
}

workspace.addChangeListener(function (event) {
    if (event.type !== Blockly.Events.UI) {
        notifyFlutter();
    }
});

// Initialize UI
document.addEventListener('DOMContentLoaded', function () {
    renderCategories();
});

// ==========================================================================
// Custom Modals Logic
// ==========================================================================
function closeModal() {
    document.getElementById('customModalOverlay').style.display = 'none';
    document.getElementById('variableModal').style.display = 'none';
    document.getElementById('myBlockModal').style.display = 'none';
    
    // Clear inputs
    document.getElementById('varNameInput').value = '';
    document.getElementById('funcNameInput').value = '';
    document.getElementById('argsList').innerHTML = '';
}

function saveVariable() {
    const varName = document.getElementById('varNameInput').value.trim();
    if (varName) {
        workspace.createVariable(varName);
        closeModal();
        // Refresh the current category view
        if (selectedCategoryIndex !== null) {
            openCategory(selectedCategoryIndex);
        }
    }
}

// Global counter for argument names to ensure uniqueness
let argCounter = 1;

function addArgument(type) {
    const argsList = document.getElementById('argsList');
    const argId = 'arg_' + argCounter++;
    
    const argDiv = document.createElement('div');
    argDiv.className = 'arg-item';
    argDiv.id = argId;
    
    let label = '';
    if (type === 'Number') label = '🔢 (Angka)';
    else if (type === 'String') label = '💬 (Teks)';
    else if (type === 'Boolean') label = '❓ (Boolean)';
    
    argDiv.innerHTML = `
        <span style="font-size: 14px;">${label}</span>
        <input type="text" placeholder="nama_input" class="arg-name-input" />
        <span class="remove-arg" onclick="document.getElementById('${argId}').remove()">×</span>
    `;
    argsList.appendChild(argDiv);
}

function saveMyBlock() {
    const funcName = document.getElementById('funcNameInput').value.trim();
    if (!funcName) return;
    
    // Gather arguments
    const argsList = document.getElementById('argsList');
    const argInputs = argsList.getElementsByClassName('arg-name-input');
    
    let mutationXml = '';
    if (argInputs.length > 0) {
        mutationXml = '<mutation>';
        for (let i = 0; i < argInputs.length; i++) {
            const argName = argInputs[i].value.trim() || ('input_' + (i+1));
            mutationXml += `<arg name="${argName}"></arg>`;
        }
        mutationXml += '</mutation>';
    }
    
    // Create the definition block XML
    const xmlString = `<xml><block type="procedures_defnoreturn" x="100" y="100">${mutationXml}<field name="NAME">${funcName}</field></block></xml>`;
    
    // Inject to workspace
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(xmlString, "text/xml");
    Blockly.Xml.domToWorkspace(xmlDoc.documentElement, workspace);
    
    closeModal();
    // Refresh the current category view
    if (selectedCategoryIndex !== null) {
        openCategory(selectedCategoryIndex);
    }
}
