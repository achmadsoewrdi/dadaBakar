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
    // Blockly.Python.workspaceToCode secara otomatis meng-generate kode
    // beserta semua definitions_ yang didaftarkan oleh generator blok hardware
    // (via _hal_require_* di custom_blocks.js). Tidak perlu injeksi manual apapun.
    let pythonCode = Blockly.Python.workspaceToCode(workspace);

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
