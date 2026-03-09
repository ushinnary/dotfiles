// ── Clock widget ─────────────────────────────────────────────────
// Displays current time; click to toggle full date; hover tooltip.
import QtQuick

Item {
    id: clockRoot
    width: clockText.paintedWidth + 16
    height: parent ? parent.height : 32

    property bool showDate: false

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: clockMouse.containsMouse ? Theme.surfaceHover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: clockRoot.showDate ? Time.dateShort : Time.time
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.textPrimary
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: clockRoot.showDate = !clockRoot.showDate
    }

    // ── Tooltip (full date on hover) ─────────────────────────────
    Rectangle {
        id: tooltip
        visible: clockMouse.containsMouse && !clockRoot.showDate
        width: tooltipText.paintedWidth + 16
        height: tooltipText.paintedHeight + 8
        radius: 6
        color: Theme.surface
        anchors {
            top: parent.bottom
            topMargin: 6
            horizontalCenter: parent.horizontalCenter
        }
        z: 100

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: Time.date_
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textSecondary
        }
    }
}
