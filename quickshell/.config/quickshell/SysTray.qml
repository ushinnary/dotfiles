// ── System tray ──────────────────────────────────────────────────
// Uses Quickshell's built-in StatusNotifierItem / SystemTray service.
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: trayRoot
    implicitWidth: trayRow.implicitWidth
    implicitHeight: parent ? parent.height : 32

    Row {
        id: trayRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: SystemTray.items

            Item {
                id: trayItem
                required property var modelData
                width: 20
                height: 20

                visible: modelData !== null

                IconImage {
                    id: trayIcon
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    smooth: true
                    asynchronous: true
                    source: {
                        if (!modelData || !modelData.icon) return "";
                        let icon = modelData.icon;
                        // Handle freedesktop icon lookup paths
                        if (icon.includes("?path=")) {
                            const parts = icon.split("?path=");
                            const name = parts[0].substring(parts[0].lastIndexOf("/") + 1);
                            return "file://" + parts[1] + "/" + name;
                        }
                        return icon;
                    }
                    opacity: trayMouse.containsMouse ? 1.0 : 0.8

                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }

                // Subtle hover scale
                scale: trayMouse.containsMouse ? 1.15 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: function(mouse) {
                        if (!modelData) return;
                        if (mouse.button === Qt.LeftButton) {
                            if (!modelData.onlyMenu) modelData.activate();
                        } else if (mouse.button === Qt.MiddleButton) {
                            if (modelData.secondaryActivate) modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
