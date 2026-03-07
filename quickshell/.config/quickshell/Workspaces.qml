// ── Workspaces widget ────────────────────────────────────────────
// Queries niri IPC for workspace state and shows numbered pills.
// Click a pill to switch workspace.
//
// Future: replace the polling Process with a persistent
// `niri msg event-stream` reader for instant updates, or write
// a small Rust binary that proxies the niri socket.
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: wsRoot
    required property var screen

    property var workspaces: []
    property int focusedId: -1

    implicitWidth: wsRow.implicitWidth
    implicitHeight: parent ? parent.height : 32

    // ── Poll niri IPC ────────────────────────────────────────────
    Process {
        id: wsProc
        command: ["niri", "msg", "-j", "workspaces"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const all = JSON.parse(this.text);
                    // Filter workspaces for this screen's output
                    const screenName = wsRoot.screen ? wsRoot.screen.name : "";
                    const filtered = all.filter(function(ws) {
                        if (!screenName) return true;
                        return ws.output && ws.output.toLowerCase() === screenName.toLowerCase();
                    });
                    // Sort by idx
                    filtered.sort(function(a, b) { return a.idx - b.idx; });
                    wsRoot.workspaces = filtered;
                    for (let i = 0; i < filtered.length; i++) {
                        if (filtered[i].is_focused) {
                            wsRoot.focusedId = filtered[i].id;
                            break;
                        }
                    }
                } catch (e) {
                    console.warn("Workspaces: failed to parse niri IPC:", e);
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: wsProc.running = true
    }

    // ── Visual pills ─────────────────────────────────────────────
    Row {
        id: wsRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Repeater {
            model: wsRoot.workspaces

            Rectangle {
                required property var modelData
                required property int index

                width: modelData.is_focused ? 28 : 14
                height: 8
                radius: 4
                color: {
                    if (modelData.is_focused)
                        return Theme.accentPrimary;
                    if (modelData.is_active)
                        return Theme.accentSecondary;
                    return Theme.surfaceHover;
                }

                Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        switchProc.command = ["niri", "msg", "action", "focus-workspace", String(modelData.idx)];
                        switchProc.running = true;
                    }
                }
            }
        }
    }

    // ── Helper: workspace switch command ─────────────────────────
    Process {
        id: switchProc
    }
}
