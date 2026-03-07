// ── SysTray ───────────────────────────────────────────────────────
// Renders all StatusNotifierItem icons as a horizontal row.
// Each icon is a SysTrayItem that handles clicks, tooltip, and menu.
// Passive items (background daemons with no meaningful interaction)
// are shown slightly dimmed but still visible — filter on
// `item.status !== SystemTrayStatus.Passive` here if you prefer.
import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Item {
    id: root

    // Pass the bar's ShellScreen down so tray menus can set it on their popup
    // windows — required for correct positioning with fractional scaling.
    property var barScreen: null

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: SystemTray.items.values

            SysTrayItem {
                required property SystemTrayItem modelData
                item: modelData
                barScreen: root.barScreen

                // Dim passive items slightly (e.g. background helpers)
                opacity: modelData.status === SystemTrayStatus.Passive ? 0.55 : 1.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }
}
