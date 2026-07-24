/**
 * Unified Drag & Drop & Tap Handler using PointerEvents API
 */
function attachBlockDragAndDrop(element, xmlString) {
    let createdBlock = null;
    let isDragging = false;
    let startX = 0;
    let startY = 0;
    let activePointerId = null;
    let longPressTimer = null;
    let canDrag = false;

    function getPt(e) {
        return { x: e.clientX, y: e.clientY };
    }

    function onPointerDown(e) {
        if (e.button && e.button !== 0) return;
        
        activePointerId = e.pointerId;
        const pt = getPt(e);
        startX = pt.x;
        startY = pt.y;
        isDragging = false;
        canDrag = false;
        createdBlock = null;

        // Visual feedback reset
        element.style.transform = 'scale(0.98)';
        
        // Wait 150ms before allowing drag
        longPressTimer = setTimeout(() => {
            canDrag = true;
            // Haptic/visual cue that it's draggable
            element.style.transform = 'scale(1.05)';
            element.style.boxShadow = '0 8px 24px rgba(79, 70, 229, 0.3)';
            element.style.borderColor = '#4f46e5';
            element.style.zIndex = '100';
            
            // If the device supports vibration
            if (navigator.vibrate) navigator.vibrate(50);
        }, 150);

        window.addEventListener('pointermove', onPointerMove, { passive: false });
        window.addEventListener('pointerup', onPointerUp);
        window.addEventListener('pointercancel', onPointerUp);
    }

    function onPointerMove(e) {
        if (e.pointerId !== activePointerId) return;

        const pt = getPt(e);
        const dist = Math.hypot(pt.x - startX, pt.y - startY);

        // If moved significantly before the 150ms timer, they are trying to scroll!
        if (dist > 10 && !canDrag) {
            clearTimeout(longPressTimer);
            resetCardStyle();
            return; // Let the browser scroll natively
        }

        if (canDrag && dist > 5) {
            if (e.cancelable) e.preventDefault();

            if (!isDragging) {
                isDragging = true;
                collapseSheet();
                resetCardStyle();

                try {
                    const parser = new DOMParser();
                    const xmlDoc = parser.parseFromString('<xml>' + xmlString + '</xml>', "text/xml");
                    const newIds = Blockly.Xml.domToWorkspace(xmlDoc.documentElement, workspace);
                    if (newIds && newIds.length > 0) {
                        createdBlock = workspace.getBlockById(newIds[0]);
                    }
                } catch (err) {
                    console.error("Error creating block on drag:", err);
                }
            }

            if (createdBlock) {
                const injectionDiv = workspace.getParentSvg().parentNode;
                const rect = injectionDiv.getBoundingClientRect();
                
                const wsX = (pt.x - rect.left - workspace.scrollX) / workspace.scale;
                const wsY = (pt.y - rect.top - workspace.scrollY) / workspace.scale;

                createdBlock.moveTo(new Blockly.utils.Coordinate(wsX - 20, wsY - 15));
                createdBlock.select();
            }
        }
    }

    function resetCardStyle() {
        element.style.transform = '';
        element.style.boxShadow = '';
        element.style.borderColor = '';
        element.style.zIndex = '';
    }

    function onPointerUp(e) {
        if (e.pointerId !== activePointerId) return;

        clearTimeout(longPressTimer);
        resetCardStyle();

        window.removeEventListener('pointermove', onPointerMove);
        window.removeEventListener('pointerup', onPointerUp);
        window.removeEventListener('pointercancel', onPointerUp);

        // If they tapped quickly without dragging
        if (!isDragging && !canDrag && e.type !== 'pointercancel') {
            const dist = Math.hypot(e.clientX - startX, e.clientY - startY);
            if (dist < 10) {
                addBlock(xmlString);
            }
        } else if (createdBlock) {
            notifyFlutter();
        }
    }

    element.addEventListener('pointerdown', onPointerDown);
}
