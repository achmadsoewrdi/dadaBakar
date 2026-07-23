/**
 * Custom Slide-Up Bottom Sheet Component UI Logic
 */
let selectedCategoryIndex = null;

const bottomSheet = document.getElementById('bottomSheet');
const sheetHeader = document.getElementById('sheetHeader');
const sheetTitle = document.getElementById('sheetTitle');
const sheetToggleBtn = document.getElementById('sheetToggleBtn');
const sheetContent = document.getElementById('sheetContent');

function toggleSheet() {
    bottomSheet.classList.toggle('expanded');
    const isExpanded = bottomSheet.classList.contains('expanded');
    document.getElementById('icon-chevron').style.display = isExpanded ? 'none' : 'block';
    document.getElementById('icon-close').style.display = isExpanded ? 'block' : 'none';
}

function collapseSheet() {
    bottomSheet.classList.remove('expanded');
    document.getElementById('icon-chevron').style.display = 'block';
    document.getElementById('icon-close').style.display = 'none';
}

if (sheetHeader) {
    sheetHeader.addEventListener('click', toggleSheet);
}

// Render Category List View
function renderCategories() {
    selectedCategoryIndex = null;
    sheetTitle.innerText = 'Tambah Blok';
    sheetContent.innerHTML = '';

    BLOCK_CATEGORIES.forEach((cat, index) => {
        const card = document.createElement('div');
        card.className = 'category-card';
        card.onclick = function() { openCategory(index); };
        card.innerHTML = `
            <div class="category-icon-box" style="background: ${cat.color}22; color: ${cat.color};">
                ${cat.icon}
            </div>
            <div class="category-info">
                <div class="category-name">${cat.name}</div>
                <div class="category-desc">${cat.desc}</div>
            </div>
            <div class="chevron-icon">›</div>
        `;
        sheetContent.appendChild(card);
    });
}

// Open Specific Category View
function openCategory(index) {
    selectedCategoryIndex = index;
    const cat = BLOCK_CATEGORIES[index];
    sheetTitle.innerText = `${cat.icon} ${cat.name}`;
    sheetContent.innerHTML = '';

    const backBtn = document.createElement('div');
    backBtn.className = 'nav-back-btn';
    backBtn.innerHTML = '⬅️ Kembali ke Kategori';
    backBtn.onclick = renderCategories;
    sheetContent.appendChild(backBtn);

    // If it's a special Variables category
    if (cat.isVariableCategory) {
        const createBtn = document.createElement('button');
        createBtn.className = 'btn-save';
        createBtn.style.marginBottom = '12px';
        createBtn.style.background = '#FF8C1A';
        createBtn.innerText = 'Buat Variabel Baru';
        createBtn.onclick = function() {
            document.getElementById('customModalOverlay').style.display = 'flex';
            document.getElementById('variableModal').style.display = 'flex';
            document.getElementById('myBlockModal').style.display = 'none';
        };
        sheetContent.appendChild(createBtn);

        // Fetch dynamic variables from workspace
        const variables = workspace.getAllVariables();
        if (variables.length === 0) {
            const emptyMsg = document.createElement('div');
            emptyMsg.style.textAlign = 'center';
            emptyMsg.style.color = '#94a3b8';
            emptyMsg.innerText = 'Belum ada variabel.';
            sheetContent.appendChild(emptyMsg);
        } else {
            variables.forEach(v => {
                // Set block
                const setCard = createBlockCard(cat, `Set ${v.name} ke`, 'Set nilai variabel', `<block type="variables_set"><field name="VAR" id="${v.getId()}">${v.name}</field></block>`);
                sheetContent.appendChild(setCard);
                // Get block
                const getCard = createBlockCard(cat, v.name, 'Gunakan nilai variabel', `<block type="variables_get"><field name="VAR" id="${v.getId()}">${v.name}</field></block>`);
                sheetContent.appendChild(getCard);
            });
        }
        return;
    }

    // If it's a special My Blocks category
    if (cat.isMyBlocksCategory) {
        const createBtn = document.createElement('button');
        createBtn.className = 'btn-save';
        createBtn.style.marginBottom = '12px';
        createBtn.style.background = '#FF6680';
        createBtn.innerText = 'Buat Blok Baru';
        createBtn.onclick = function() {
            document.getElementById('customModalOverlay').style.display = 'flex';
            document.getElementById('myBlockModal').style.display = 'flex';
            document.getElementById('variableModal').style.display = 'none';
        };
        sheetContent.appendChild(createBtn);

        // Fetch dynamic procedures from workspace (only Definitions)
        const procedures = Blockly.Procedures.allProcedures(workspace)[0]; // [0] is no-return procedures
        if (procedures.length === 0) {
            const emptyMsg = document.createElement('div');
            emptyMsg.style.textAlign = 'center';
            emptyMsg.style.color = '#94a3b8';
            emptyMsg.innerText = 'Belum ada blok kustom.';
            sheetContent.appendChild(emptyMsg);
        } else {
            procedures.forEach(proc => {
                const procName = proc[0];
                const procArgs = proc[1];
                let mutationStr = '';
                if (procArgs.length > 0) {
                    mutationStr = '<mutation>';
                    procArgs.forEach(arg => { mutationStr += `<arg name="${arg}"></arg>`; });
                    mutationStr += '</mutation>';
                }
                const callXml = `<block type="procedures_callnoreturn">${mutationStr}<field name="NAME">${procName}</field></block>`;
                
                const callCard = createBlockCard(cat, procName, 'Panggil fungsi ini', callXml);
                sheetContent.appendChild(callCard);
            });
        }
        return;
    }

    // Normal Categories
    cat.blocks.forEach(block => {
        const card = createBlockCard(cat, block.name, block.desc, block.xml);
        sheetContent.appendChild(card);
    });
}

function createBlockCard(cat, name, desc, xml) {
    const card = document.createElement('div');
    card.className = 'block-card';
    card.innerHTML = `
        <div class="category-icon-box" style="background: ${cat.color}22; color: ${cat.color};">
            ${cat.icon || '🧩'}
        </div>
        <div class="category-info">
            <div class="category-name">${name}</div>
            <div class="category-desc">${desc}</div>
        </div>
    `;
    attachBlockDragAndDrop(card, xml);
    return card;
}

// Programmatically Add Block to Workspace Center
function addBlock(xmlString) {
    try {
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString('<xml>' + xmlString + '</xml>', "text/xml");
        const newBlockIds = Blockly.Xml.domToWorkspace(xmlDoc.documentElement, workspace);
        if (newBlockIds && newBlockIds.length > 0) {
            const block = workspace.getBlockById(newBlockIds[0]);
            if (block) {
                const metrics = workspace.getMetrics();
                const x = metrics.viewLeft + (metrics.viewWidth / 3);
                const y = metrics.viewTop + (metrics.viewHeight / 3);
                block.moveTo(new Blockly.utils.Coordinate(x, y));
                block.select();
            }
        }
        collapseSheet();
        notifyFlutter();
    } catch (e) {
        console.error("Error adding block:", e);
    }
}
