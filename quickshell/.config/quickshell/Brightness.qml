// ── Brightness singleton ─────────────────────────────────────────
// Polls brightnessctl and exposes the current percentage.
// Both BrightnessWidget and BrightnessOsd read from here so we
// only ever run one polling process for the whole shell.
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: brightness

    // ── Public state ─────────────────────────────────────────────
    // `percentageChanged()` is auto-emitted by QML whenever this changes.
    // BrightnessOsd connects to it via Connections { onPercentageChanged }.
    readonly property bool hasBacklight: _hasBacklight
    readonly property int percentage: _percentage

    // ── Private ──────────────────────────────────────────────────
    property bool _hasBacklight: false
    property int _percentage: 0

    // ── Poll process ─────────────────────────────────────────────
    Process {
        id: briProc
        command: [
            "sh", "-c",
            "pct=\"$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')\"; [ -n \"$pct\" ] && echo $pct || exit 1"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(this.text.trim());
                if (!isNaN(val)) {
                    brightness._hasBacklight = true;
                    // QML won't re-emit percentageChanged if val is the same,
                    // so this is safe to assign unconditionally.
                    brightness._percentage = val;
                } else {
                    brightness._hasBacklight = false;
                }
            }
        }
    }

    // ── Polling timer ────────────────────────────────────────────
    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: briProc.running = true
    }
}
