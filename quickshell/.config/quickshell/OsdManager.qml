// ── OsdManager ───────────────────────────────────────────────────
// Singleton that coordinates multiple visible OSD pills so they
// stack side-by-side rather than overlapping.
//
// Ordering: index 0 = rightmost (first to appear / screen edge),
//           higher indices extend left.
//
// OsdWindow instances call register() / unregister() to join or
// leave the stack.  The manager then writes stackIndex back on each
// live pill so their x-translation animates to the correct slot.

pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // ── Layout constants (kept in sync with OsdWindow dimensions) ─
    readonly property int pillWidth: 56   // OsdWindow.implicitWidth
    readonly property int pillGap:   12   // horizontal gap between pills

    // ── Active OSD list ──────────────────────────────────────────
    // Ordered: [0] = oldest / rightmost, [n-1] = newest / leftmost.
    property var activeOsds: []

    // Called by OsdWindow.trigger() when the pill first becomes visible.
    function register(osd) {
        const idx = activeOsds.indexOf(osd)
        if (idx !== -1) return            // already in the stack

        const list = activeOsds.slice()
        list.push(osd)
        activeOsds = list
        _sync()
    }

    // Called by OsdWindow after its fade-out animation completes.
    function unregister(osd) {
        const idx = activeOsds.indexOf(osd)
        if (idx === -1) return

        const list = activeOsds.slice()
        list.splice(idx, 1)
        activeOsds = list
        _sync()
    }

    // Assign each pill its stack slot.
    function _sync() {
        for (let i = 0; i < activeOsds.length; i++) {
            activeOsds[i].stackIndex = i
        }
    }
}
