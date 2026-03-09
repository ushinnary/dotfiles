// ── SysTrayMenuEntry ─────────────────────────────────────────────
// A single row inside a tray context menu:
//   [checkbox/radio] [icon] [label] [chevron if submenu]
// Separators are rendered as a thin horizontal line.
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var menuEntry  // QsMenuEntry
    property bool forceIconColumn: false

    signal dismiss
    signal openSubmenu(handle: var) // QsMenuHandle

    implicitWidth: contentRow.implicitWidth + 16
    implicitHeight: menuEntry.isSeparator ? 9 : 32
    Layout.fillWidth: true

    // ── Separator ────────────────────────────────────────────────
    Rectangle {
        visible: menuEntry.isSeparator
        anchors.centerIn: parent
        width: parent.width - 16
        height: 1
        color: Theme.surfaceHover
    }

    // ── Normal row ───────────────────────────────────────────────
    Rectangle {
        id: rowBg
        visible: !menuEntry.isSeparator
        anchors.fill: parent
        anchors.margins: 2
        radius: 6
        color: hoverHandler.hovered && menuEntry.enabled ? Theme.surfaceHover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        enabled: !menuEntry.isSeparator && menuEntry.enabled
        onTapped: {
            if (menuEntry.hasChildren) {
                root.openSubmenu(menuEntry);
            } else {
                menuEntry.triggered();
                root.dismiss();
            }
        }
    }

    RowLayout {
        id: contentRow
        visible: !menuEntry.isSeparator
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 6

        // ── Checkbox / radio state ────────────────────────────────
        Item {
            visible: menuEntry.buttonType !== 0 // 0 = QsMenuButtonType.None
            implicitWidth: 14
            implicitHeight: 14

            Rectangle {
                anchors.centerIn: parent
                width: 10
                height: 10
                radius: menuEntry.buttonType === 2 ? 5 : 2 // 2 = RadioButton
                color: menuEntry.checkState === Qt.Checked ? Theme.accentPrimary : "transparent"
                border.width: 1.5
                border.color: menuEntry.checkState === Qt.Checked ? Theme.accentPrimary : Theme.textDim
            }
        }

        // ── Item icon ─────────────────────────────────────────────
        Item {
            visible: root.forceIconColumn || menuEntry.icon.length > 0
            implicitWidth: 16
            implicitHeight: 16

            IconImage {
                anchors.centerIn: parent
                width: 16
                height: 16
                asynchronous: true
                mipmap: true
                source: menuEntry.icon ?? ""
                visible: menuEntry.icon.length > 0
            }
        }

        // ── Label ─────────────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            text: menuEntry.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: menuEntry.enabled ? Theme.textPrimary : Theme.textDim
            elide: Text.ElideRight
        }

        // ── Submenu chevron ───────────────────────────────────────
        Text {
            visible: menuEntry.hasChildren
            text: "›"
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.textDim
        }
    }
}
