// ── ContextMenuEntry ─────────────────────────────────────────────
// Generic reusable menu row.  Used by both the dock context menu and
// the system-tray context menu so both spots share the exact same
// look and interaction model.
//
// Properties
//   label          – display text
//   icon           – icon name / path (empty = no icon column)
//   forceIconColumn– always reserve icon column width (alignment)
//   destructive    – true → label rendered in Theme.error (red)
//   separator      – true → render a thin horizontal divider line
//   enabled        – false → dimmed, not interactive
//   buttonType     – 0 none | 1 checkbox | 2 radio  (tray extras)
//   checked        – current check/radio state
//   hasSubmenu     – shows › chevron on the right
//
// Signals
//   triggered      – user tapped this item (not emitted for separators)
//   openSubmenu    – user tapped a submenu item (hasSubmenu = true)
pragma ComponentBehavior: Bound

import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string label: ""
    property string icon: ""
    property bool forceIconColumn: false
    property bool destructive: false
    property bool separator: false
    property bool enabled: true
    property int buttonType: 0   // 0=none 1=checkbox 2=radio
    property bool checked: false
    property bool hasSubmenu: false

    signal triggered
    signal openSubmenu

    implicitWidth: contentRow.implicitWidth + 16
    implicitHeight: root.separator ? 9 : 32
    Layout.fillWidth: true

    // ── Separator line ────────────────────────────────────────────
    Rectangle {
        visible: root.separator
        anchors.centerIn: parent
        width: parent.width - 16
        height: 1
        color: Theme.surfaceHover
    }

    // ── Hover background ──────────────────────────────────────────
    Rectangle {
        id: rowBg
        visible: !root.separator
        anchors.fill: parent
        anchors.margins: 2
        radius: 6
        color: hoverHandler.hovered && root.enabled ? Theme.surfaceHover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    // HoverHandler never steals events from, or yields to, MouseArea.
    // Using it here means the backdrop's MouseArea can't swallow hover.
    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        enabled: !root.separator && root.enabled
        onTapped: {
            if (root.hasSubmenu)
                root.openSubmenu();
            else
                root.triggered();
        }
    }

    // ── Row content ───────────────────────────────────────────────
    RowLayout {
        id: contentRow
        visible: !root.separator
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 6

        // ── Checkbox / radio indicator ────────────────────────────
        Item {
            visible: root.buttonType !== 0
            implicitWidth: 14
            implicitHeight: 14

            Rectangle {
                anchors.centerIn: parent
                width: 10
                height: 10
                radius: root.buttonType === 2 ? 5 : 2
                color: root.checked ? Theme.accentPrimary : "transparent"
                border.width: 1.5
                border.color: root.checked ? Theme.accentPrimary : Theme.textDim
            }
        }

        // ── Icon ──────────────────────────────────────────────────
        Item {
            visible: root.forceIconColumn || root.icon.length > 0
            implicitWidth: 16
            implicitHeight: 16

            IconImage {
                anchors.centerIn: parent
                width: 16
                height: 16
                asynchronous: true
                mipmap: true
                source: root.icon
                visible: root.icon.length > 0
            }
        }

        // ── Label ─────────────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: root.destructive ? Theme.error : (root.enabled ? Theme.textPrimary : Theme.textDim)
            elide: Text.ElideRight
        }

        // ── Submenu chevron ───────────────────────────────────────
        Text {
            visible: root.hasSubmenu
            text: "›"
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.textDim
        }
    }
}
