// ── Active App Widget ────────────────────────────────────────────
// Shows the focused window's icon + title via Niri IPC.
// Polls `niri msg --json focused-window` every 500 ms.
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: appRoot

    property string appId: ""
    property string appTitle: ""
    property string iconSource: ""

    readonly property bool hasApp: appTitle !== "" || appId !== ""

    implicitWidth: hasApp ? appRow.implicitWidth + 16 : 0
    implicitHeight: parent ? parent.height : 32
    visible: hasApp
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    // ── Niri IPC poll ─────────────────────────────────────────────
    function refreshFocused() {
        if (!focusedProc.running)
            focusedProc.running = true
    }

    Component.onCompleted: refreshFocused()

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: appRoot.refreshFocused()
    }

    Process {
        id: focusedProc
        command: ["niri", "msg", "--json", "focused-window"]

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = this.text.trim()

                // ── 1. Parse niri JSON ────────────────────────────
                let win = null
                try {
                    if (raw && raw !== "null") {
                        const data = JSON.parse(raw)
                        // niri msg --json focused-window returns
                        // {"FocusedWindow": {...}} or {"FocusedWindow": null}
                        win = (data && data.FocusedWindow !== undefined)
                            ? data.FocusedWindow
                            : data
                    }
                } catch (_) {}

                if (!win) {
                    appRoot.appId    = ""
                    appRoot.appTitle = ""
                    appRoot.iconSource = ""
                    return
                }

                // ── 2. Set title & id unconditionally ────────────
                appRoot.appId    = String(win.app_id || "")
                appRoot.appTitle = String(win.title || win.app_id || "")

                // ── 3. Resolve icon separately (never kills title) ─
                try {
                    const entry = appRoot.appId
                        ? DesktopEntries.heuristicLookup(appRoot.appId)
                        : null
                    const iconName = (entry && entry.icon) ? entry.icon : ""
                    appRoot.iconSource = iconName
                        ? (Quickshell.iconPath(iconName, true) || "")
                        : ""
                } catch (_) {
                    appRoot.iconSource = ""
                }
            }
        }
    }

    // ── Hover background ─────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: appHover.containsMouse ? Theme.surfaceHover : "transparent"
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    // ── Content row ───────────────────────────────────────────────
    RowLayout {
        id: appRow
        anchors.centerIn: parent
        spacing: 6

        Image {
            id: appIcon
            width: 18
            height: 18
            source: appRoot.iconSource
            smooth: true
            mipmap: true
            visible: source !== "" && status === Image.Ready
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignVCenter
        }

        // Fallback glyph when no icon or loading failed
        Text {
            visible: appIcon.source === "" || appIcon.status !== Image.Ready
            text: "󰣆"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
            color: Theme.accentPrimary
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: appRoot.appTitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.textPrimary
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.maximumWidth: 180
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: appHover
        anchors.fill: parent
        hoverEnabled: true
    }
}
