// ── Privacy Indicator Widget ─────────────────────────────────────
// macOS-style privacy dots: green when webcam is in use, orange when
// microphone is being captured by any application.
// Appears only when at least one device is active; hover shows a
// tooltip listing the offending apps.
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: privRoot

    property bool cameraActive: false
    property bool micActive: false
    property string cameraApps: ""
    property string micApps: ""

    readonly property bool anyActive: cameraActive || micActive
    readonly property string tooltipText: {
        const parts = []
        if (cameraActive)
            parts.push("󰄀  Camera: " + (cameraApps || "active"))
        if (micActive)
            parts.push("󰍬  Mic: " + (micApps || "active"))
        return parts.join("\n")
    }

    implicitWidth: anyActive ? indicatorRow.implicitWidth + 12 : 0
    implicitHeight: parent ? parent.height : 32
    visible: anyActive
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    // ── Privacy polling ───────────────────────────────────────────
    function refreshPrivacy() {
        if (!camProc.running)
            camProc.exec(["sh", "-c",
                "lsof /dev/video* 2>/dev/null | awk 'NR>1 {print $1}' | sort -u | tr '\\n' ',' | sed 's/,$//'"
            ])
        if (!micProc.running)
            micProc.exec(["sh", "-c",
                "pactl list source-outputs 2>/dev/null | grep 'application.name' | sed 's/.*= .\\(.*\\)./\\1/' | sort -u | tr '\\n' ',' | sed 's/,$//' || true"
            ])
    }

    Component.onCompleted: refreshPrivacy()

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: privRoot.refreshPrivacy()
    }

    Process {
        id: camProc
        stdout: StdioCollector {
            onStreamFinished: {
                const result = this.text.trim()
                privRoot.cameraActive = result.length > 0
                privRoot.cameraApps = result
            }
        }
    }

    Process {
        id: micProc
        stdout: StdioCollector {
            onStreamFinished: {
                const result = this.text.trim()
                privRoot.micActive = result.length > 0
                privRoot.micApps = result
            }
        }
    }

    HoverHandler {
        id: privHover
    }

    // ── Indicators ────────────────────────────────────────────────
    RowLayout {
        id: indicatorRow
        anchors.centerIn: parent
        spacing: 5

        // Camera dot – green
        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: Theme.success   // "#a6e3a1" Catppuccin green
            visible: privRoot.cameraActive
            Layout.alignment: Qt.AlignVCenter

            SequentialAnimation on opacity {
                running: privRoot.cameraActive
                loops: Animation.Infinite
                NumberAnimation { to: 0.45; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
            }
        }

        // Microphone dot – orange (Catppuccin peach)
        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: "#fab387"
            visible: privRoot.micActive
            Layout.alignment: Qt.AlignVCenter

            SequentialAnimation on opacity {
                running: privRoot.micActive
                loops: Animation.Infinite
                NumberAnimation { to: 0.45; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
            }
        }
    }

    // ── Tooltip ───────────────────────────────────────────────────
    Rectangle {
        id: tooltip
        visible: privHover.hovered && privRoot.anyActive && tooltipInner.text !== ""
        width: tooltipInner.paintedWidth + 20
        height: tooltipInner.paintedHeight + 12
        radius: 6
        color: Theme.surface
        border.color: Theme.surfaceHover
        border.width: 1
        z: 100

        anchors {
            top: parent.bottom
            topMargin: 6
            horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: tooltipInner
            anchors.centerIn: parent
            text: privRoot.tooltipText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textPrimary
            lineHeight: 1.4
        }

        // Small caret pointing up
        Rectangle {
            width: 8
            height: 8
            color: tooltip.color
            border.color: tooltip.border.color
            border.width: 1
            rotation: 45
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: -4
            z: -1
        }
    }
}
