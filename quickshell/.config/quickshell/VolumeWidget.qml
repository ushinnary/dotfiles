// ── Volume widget ────────────────────────────────────────────────
// Uses Quickshell's built-in Pipewire service.
// Scroll to adjust volume; click to mute/unmute.
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

Item {
    id: volRoot
    implicitWidth: volRow.implicitWidth + 12
    implicitHeight: parent ? parent.height : 32

    property var sink: Pipewire.defaultAudioSink
    property int volume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    property bool muted: sink && sink.audio ? sink.audio.muted : false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: volMouse.containsMouse ? Theme.surfaceHover : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    RowLayout {
        id: volRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: {
                if (volRoot.muted) return "󰝟";
                if (volRoot.volume === 0) return "󰖁";
                if (volRoot.volume < 30) return "󰕿";
                if (volRoot.volume < 70) return "󰖀";
                return "󰕾";
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: volRoot.muted ? Theme.textDim : Theme.accentPrimary
        }

        Text {
            text: volRoot.volume + "%"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.textPrimary
        }
    }

    MouseArea {
        id: volMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: {
            if (volRoot.sink && volRoot.sink.audio) {
                volRoot.sink.audio.muted = !volRoot.sink.audio.muted;
            }
        }

        onWheel: function(wheel) {
            if (!volRoot.sink || !volRoot.sink.audio) return;
            const step = 0.05; // 5%
            if (wheel.angleDelta.y > 0) {
                volRoot.sink.audio.volume = Math.min(1.0, volRoot.sink.audio.volume + step);
            } else if (wheel.angleDelta.y < 0) {
                volRoot.sink.audio.volume = Math.max(0.0, volRoot.sink.audio.volume - step);
            }
        }
    }
}
