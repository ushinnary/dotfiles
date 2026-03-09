// ── Brightness widget ────────────────────────────────────────────
// Uses brightnessctl.  Only visible when a backlight device exists.
// Scroll to adjust brightness.
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: briRoot
    implicitWidth: briRow.implicitWidth + 12
    implicitHeight: parent ? parent.height : 32
    visible: hasBacklight

    property bool hasBacklight: false
    property int percentage: 0

    // ── Poll brightness ──────────────────────────────────────────
    Process {
        id: briProc
        command: ["sh", "-c", "pct=\"$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')\"; " + "[ -n \"$pct\" ] && echo $pct || exit 1"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(this.text.trim());
                if (!isNaN(val)) {
                    briRoot.hasBacklight = true;
                    briRoot.percentage = val;
                } else {
                    briRoot.hasBacklight = false;
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: briProc.running = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: briMouse.containsMouse ? Theme.surfaceHover : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    RowLayout {
        id: briRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: "󰃠"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: Theme.warning
        }

        Text {
            text: briRoot.percentage + "%"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.textPrimary
        }
    }

    MouseArea {
        id: briMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton

        onWheel: function (wheel) {
            if (wheel.angleDelta.y > 0) {
                briUpProc.running = true;
            } else if (wheel.angleDelta.y < 0) {
                briDownProc.running = true;
            }
        }
    }

    Process {
        id: briUpProc
        command: ["brightnessctl", "set", "+5%"]
    }

    Process {
        id: briDownProc
        command: ["brightnessctl", "set", "5%-"]
    }
}
