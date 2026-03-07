// ── Battery widget ───────────────────────────────────────────────
// Reads from /sys/class/power_supply/BAT*.
// Only visible when a battery actually exists on the system.
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: batRoot
    implicitWidth: batRow.implicitWidth + 12
    implicitHeight: parent ? parent.height : 32
    visible: hasBattery

    property bool hasBattery: false
    property int percentage: 0
    property string status: "" // "Charging", "Discharging", "Full", "Not charging"

    // ── Poll battery ─────────────────────────────────────────────
    Process {
        id: batProc
        command: ["sh", "-c",
            "for d in /sys/class/power_supply/BAT*; do " +
            "  [ -d \"$d\" ] || exit 1; " +
            "  echo \"{\\\"capacity\\\": $(cat $d/capacity), \\\"status\\\": \\\"$(cat $d/status)\\\"}\"; " +
            "  exit 0; " +
            "done; exit 1"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text);
                    batRoot.hasBattery = true;
                    batRoot.percentage = data.capacity;
                    batRoot.status = data.status;
                } catch (e) {
                    batRoot.hasBattery = false;
                }
            }
        }
    }

    Timer {
        interval: 10000 // every 10s
        running: true
        repeat: true
        onTriggered: batProc.running = true
    }

    HoverHandler { id: batHover }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: batHover.hovered ? Theme.surfaceHover : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    RowLayout {
        id: batRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: {
                if (batRoot.status === "Charging") return "󰂄";
                if (batRoot.percentage > 90) return "󰁹";
                if (batRoot.percentage > 70) return "󰂁";
                if (batRoot.percentage > 50) return "󰁿";
                if (batRoot.percentage > 30) return "󰁽";
                if (batRoot.percentage > 10) return "󰁻";
                return "󰂃";
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: {
                if (batRoot.status === "Charging") return Theme.success;
                if (batRoot.percentage <= 15) return Theme.error;
                if (batRoot.percentage <= 30) return Theme.warning;
                return Theme.textPrimary;
            }
        }

        Text {
            text: batRoot.percentage + "%"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.textPrimary
        }
    }
}
