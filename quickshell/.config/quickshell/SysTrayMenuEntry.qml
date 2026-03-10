// ── SysTrayMenuEntry ─────────────────────────────────────────────
// Thin adapter that maps a QsMenuEntry onto the shared ContextMenuEntry
// visual component.  Kept for any legacy call-sites; new code should
// use ContextMenu directly (which handles tray entries inline).
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var menuEntry  // QsMenuEntry
    property bool forceIconColumn: false

    signal dismiss
    signal openSubmenu(handle: var)  // QsMenuHandle

    implicitWidth: entry.implicitWidth
    implicitHeight: entry.implicitHeight
    Layout.fillWidth: true

    ContextMenuEntry {
        id: entry
        anchors.fill: parent

        label: root.menuEntry.text ?? ""
        icon: root.menuEntry.icon ?? ""
        forceIconColumn: root.forceIconColumn
        separator: root.menuEntry.isSeparator ?? false
        enabled: root.menuEntry.enabled ?? true
        buttonType: root.menuEntry.buttonType ?? 0
        checked: (root.menuEntry.checkState ?? 0) === Qt.Checked
        hasSubmenu: root.menuEntry.hasChildren ?? false

        onTriggered: {
            root.menuEntry.triggered();
            root.dismiss();
        }
        onOpenSubmenu: root.openSubmenu(root.menuEntry)
    }
}
