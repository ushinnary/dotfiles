// ── BrightnessOsd ────────────────────────────────────────────────
// Listens to the Brightness singleton and shows the OSD pill
// whenever screen brightness changes.

import QtQuick
import Quickshell

Scope {
    id: brightnessOsdRoot

    // ── React to brightness changes ──────────────────────────────
    Connections {
        target: Brightness

        // percentageChanged() is the auto-generated QML property signal;
        // read the new value directly from the singleton.
        function onPercentageChanged() {
            if (!Brightness.hasBacklight) return;
            osd.value = Brightness.percentage / 100.0;
            osd.trigger();
        }
    }

    // ── OSD window ───────────────────────────────────────────────
    OsdWindow {
        id: osd
        icon:      "󰃠"
        iconColor: Theme.warning
        value:     Brightness.percentage / 100.0
    }
}
