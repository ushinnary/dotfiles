// ── SysTrayItem ──────────────────────────────────────────────────
// One tray icon.  Handles left / middle / right click and tooltip.
// Right click opens SysTrayMenu if the item exposes a menu handle.
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    required property SystemTrayItem item
    // Propagated from the bar's Variants screen so the popup and its
    // backdrop PanelWindow land on the right screen with fractional scaling.
    property var barScreen: null

    implicitWidth: 28
    implicitHeight: 28

    // ── Hover background ──────────────────────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width: 26
        height: 26
        radius: 7
        color: mouse.containsMouse ? Theme.surfaceHover : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    // ── Icon ──────────────────────────────────────────────────────
    IconImage {
        id: icon
        anchors.centerIn: parent
        width: 16
        height: 16
        smooth: true
        asynchronous: true
        mipmap: true
        source: root.item?.icon ?? ""
        opacity: mouse.containsMouse ? 1.0 : 0.78

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }

        scale: mouse.pressed ? 0.88 : (mouse.containsMouse ? 1.1 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    // ── Mouse handling ────────────────────────────────────────────
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: function (event) {
            if (!root.item)
                return;
            if (event.button === Qt.LeftButton) {
                if (!root.item.onlyMenu)
                    root.item.activate();
                else if (root.item.hasMenu)
                    menuLoader.open();
            } else if (event.button === Qt.MiddleButton) {
                root.item.secondaryActivate();
            } else if (event.button === Qt.RightButton) {
                if (root.item.hasMenu)
                    menuLoader.open();
            }
        }
    }

    // ── Tooltip ───────────────────────────────────────────────────
    Rectangle {
        id: tt
        visible: mouse.containsMouse && !menuLoader.active

        property string label: {
            const t = root.item?.tooltipTitle ?? "";
            if (t.length > 0)
                return t;
            return root.item?.title ?? root.item?.id ?? "";
        }

        width: ttText.paintedWidth + 14
        height: ttText.paintedHeight + 8
        radius: 6
        color: Theme.surface
        border.width: 1
        border.color: Theme.surfaceHover
        z: 200

        anchors {
            top: parent.bottom
            topMargin: 6
            horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: ttText
            anchors.centerIn: parent
            text: tt.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textSecondary
        }
    }

    // ── Context menu (lazy) ───────────────────────────────────────
    Loader {
        id: menuLoader

        function open() {
            menuLoader.active = true;
        }

        active: false

        sourceComponent: SysTrayMenu {
            anchor_item: root
            menuHandle: root.item.menu
            itemScreen: root.barScreen

            Component.onCompleted: visible = true
            onMenuClosed: menuLoader.active = false
        }
    }
}
