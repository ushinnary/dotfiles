// ── Left dock ───────────────────────────────────────────────────
// Ubuntu-style icon dock that shows pinned apps plus currently
// running applications for each monitor.
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

Scope {
    id: dockRoot

    // Add extra desktop IDs here if you want persistent pins regardless of
    // GNOME favorites.
    property var manualPinnedDesktopIds: []
    readonly property var defaultPinnedDesktopIds: [
        "firefox.desktop",
        "org.gnome.Nautilus.desktop",
        "com.mitchellh.ghostty.desktop"
    ]

    property var gnomeFavoriteDesktopIds: []
    property var windows: []
    property var workspaces: []

    function uniqueStrings(values) {
        const seen = {};
        const result = [];

        if (!values)
            return result;

        for (let i = 0; i < values.length; i++) {
            const value = String(values[i] || "").trim();
            if (!value || seen[value])
                continue;

            seen[value] = true;
            result.push(value);
        }

        return result;
    }

    function parseFavoriteApps(text) {
        const matches = text ? text.match(/'([^']+)'/g) : null;
        if (!matches)
            return [];

        return dockRoot.uniqueStrings(matches.map(function(match) {
            return match.substring(1, match.length - 1);
        }));
    }

    function parseNiriArray(text, label) {
        if (!text)
            return [];

        try {
            const parsed = JSON.parse(text);
            if (Array.isArray(parsed))
                return parsed;

            if (parsed && Array.isArray(parsed[label]))
                return parsed[label];
        } catch (e) {
            console.warn("Dock: failed to parse", label, e);
        }

        return [];
    }

    function normalizedText(value) {
        return String(value || "").trim();
    }

    function stripDesktopSuffix(value) {
        const text = dockRoot.normalizedText(value);
        if (text.endsWith(".desktop"))
            return text.slice(0, -8);
        return text;
    }

    function sameScreenOutput(outputName, screenName) {
        if (!screenName)
            return true;

        return dockRoot.normalizedText(outputName).toLowerCase() === dockRoot.normalizedText(screenName).toLowerCase();
    }

    function resolveDesktopEntry(appId) {
        const normalized = dockRoot.normalizedText(appId);
        if (!normalized)
            return null;

        let entry = DesktopEntries.byId(normalized);
        if (!entry && !normalized.endsWith(".desktop"))
            entry = DesktopEntries.byId(normalized + ".desktop");
        if (!entry)
            entry = DesktopEntries.heuristicLookup(normalized);

        return entry;
    }

    function desktopIdFor(entry, fallbackId) {
        if (entry && entry.id)
            return entry.id;

        const normalized = dockRoot.normalizedText(fallbackId);
        if (!normalized)
            return "";

        return normalized.endsWith(".desktop") ? normalized : normalized + ".desktop";
    }

    function compareWindowPriority(a, b) {
        if (!!a.is_focused !== !!b.is_focused)
            return a.is_focused ? -1 : 1;

        const aTimestamp = a.focus_timestamp || {};
        const bTimestamp = b.focus_timestamp || {};
        const aSecs = Number(aTimestamp.secs || 0);
        const bSecs = Number(bTimestamp.secs || 0);
        if (aSecs !== bSecs)
            return bSecs - aSecs;

        const aNanos = Number(aTimestamp.nanos || 0);
        const bNanos = Number(bTimestamp.nanos || 0);
        if (aNanos !== bNanos)
            return bNanos - aNanos;

        return Number(a.id || 0) - Number(b.id || 0);
    }

    function iconSourceFor(item) {
        if (item.entry && item.entry.icon) {
            const resolved = Quickshell.iconPath(item.entry.icon, true);
            if (resolved)
                return resolved;
        }

        const genericIcon = Quickshell.iconPath("application-x-executable", true);
        if (genericIcon)
            return genericIcon;

        return Quickshell.iconPath("applications-other", true);
    }

    function effectivePinnedDesktopIds() {
        const basePinnedIds = dockRoot.gnomeFavoriteDesktopIds.length > 0
            ? dockRoot.gnomeFavoriteDesktopIds
            : dockRoot.defaultPinnedDesktopIds;

        return dockRoot.uniqueStrings(basePinnedIds.concat(dockRoot.manualPinnedDesktopIds));
    }

    function buildDockItems(screenName) {
        const visibleWorkspaceIds = {};
        const grouped = {};
        const ordered = [];
        const pinnedDesktopIds = dockRoot.effectivePinnedDesktopIds();

        for (let i = 0; i < dockRoot.workspaces.length; i++) {
            const workspace = dockRoot.workspaces[i];
            if (!workspace)
                continue;

            if (dockRoot.sameScreenOutput(workspace.output, screenName))
                visibleWorkspaceIds[String(workspace.id)] = true;
        }

        for (let i = 0; i < dockRoot.windows.length; i++) {
            const window = dockRoot.windows[i];
            if (!window)
                continue;

            const workspaceId = window.workspace_id === undefined || window.workspace_id === null
                ? ""
                : String(window.workspace_id);
            if (screenName && workspaceId && !visibleWorkspaceIds[workspaceId])
                continue;

            const appId = dockRoot.normalizedText(window.app_id);
            const entry = dockRoot.resolveDesktopEntry(appId);
            const desktopId = dockRoot.desktopIdFor(entry, appId);
            const groupKey = desktopId || (appId ? "app:" + appId : "window:" + String(window.id));

            if (!grouped[groupKey]) {
                grouped[groupKey] = {
                    appId: appId,
                    desktopId: desktopId,
                    entry: entry,
                    focused: false,
                    label: entry && entry.name
                        ? entry.name
                        : (dockRoot.normalizedText(window.title) || appId || "App"),
                    pinned: false,
                    primaryWindowId: -1,
                    running: true,
                    sortFocusNanos: 0,
                    sortFocusSecs: 0,
                    urgent: false,
                    windows: []
                };
            }

            const current = grouped[groupKey];
            if (!current.entry && entry)
                current.entry = entry;
            if (!current.desktopId)
                current.desktopId = desktopId;
            if (!current.appId)
                current.appId = appId;

            current.focused = current.focused || !!window.is_focused;
            current.urgent = current.urgent || !!window.is_urgent;
            current.running = true;
            current.windows.push(window);
        }

        for (const key of Object.keys(grouped)) {
            const current = grouped[key];
            current.windows.sort(dockRoot.compareWindowPriority);
            const primaryWindow = current.windows.length > 0 ? current.windows[0] : null;

            current.primaryWindowId = primaryWindow ? Number(primaryWindow.id || -1) : -1;
            current.sortFocusSecs = primaryWindow && primaryWindow.focus_timestamp
                ? Number(primaryWindow.focus_timestamp.secs || 0)
                : 0;
            current.sortFocusNanos = primaryWindow && primaryWindow.focus_timestamp
                ? Number(primaryWindow.focus_timestamp.nanos || 0)
                : 0;
            current.windowCount = current.windows.length;
        }

        for (let i = 0; i < pinnedDesktopIds.length; i++) {
            const pinnedId = pinnedDesktopIds[i];
            const entry = dockRoot.resolveDesktopEntry(pinnedId);
            const desktopId = dockRoot.desktopIdFor(entry, pinnedId);
            const groupKey = desktopId || pinnedId;

            if (grouped[groupKey]) {
                grouped[groupKey].pinned = true;
                if (!grouped[groupKey].entry && entry)
                    grouped[groupKey].entry = entry;
                if (!grouped[groupKey].label && entry && entry.name)
                    grouped[groupKey].label = entry.name;
                ordered.push(grouped[groupKey]);
                delete grouped[groupKey];
                continue;
            }

            ordered.push({
                appId: dockRoot.stripDesktopSuffix(pinnedId),
                desktopId: desktopId,
                entry: entry,
                focused: false,
                label: entry && entry.name ? entry.name : dockRoot.stripDesktopSuffix(pinnedId),
                pinned: true,
                primaryWindowId: -1,
                running: false,
                sortFocusNanos: 0,
                sortFocusSecs: 0,
                urgent: false,
                windowCount: 0,
                windows: []
            });
        }

        const runningOnly = Object.keys(grouped).map(function(key) {
            return grouped[key];
        });

        runningOnly.sort(function(a, b) {
            if (!!a.focused !== !!b.focused)
                return a.focused ? -1 : 1;
            if (!!a.urgent !== !!b.urgent)
                return a.urgent ? -1 : 1;
            if (a.sortFocusSecs !== b.sortFocusSecs)
                return b.sortFocusSecs - a.sortFocusSecs;
            if (a.sortFocusNanos !== b.sortFocusNanos)
                return b.sortFocusNanos - a.sortFocusNanos;

            return String(a.label || "").localeCompare(String(b.label || ""));
        });

        return ordered.concat(runningOnly);
    }

    function activateItem(item) {
        if (!item)
            return;

        if (item.running && item.primaryWindowId > 0) {
            focusProc.exec([
                "niri",
                "msg",
                "action",
                "focus-window",
                "--id",
                String(item.primaryWindowId)
            ]);
            return;
        }

        if (item.entry)
            item.entry.execute();
    }

    function refreshNiriState() {
        if (!windowsProc.running)
            windowsProc.exec(["niri", "msg", "--json", "windows"]);

        if (!workspacesProc.running)
            workspacesProc.exec(["niri", "msg", "--json", "workspaces"]);
    }

    Component.onCompleted: {
        favoriteAppsProc.exec(["gsettings", "get", "org.gnome.shell", "favorite-apps"]);
        dockRoot.refreshNiriState();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dockRoot.refreshNiriState()
    }

    Process {
        id: favoriteAppsProc

        stdout: StdioCollector {
            onStreamFinished: {
                dockRoot.gnomeFavoriteDesktopIds = dockRoot.parseFavoriteApps(this.text);
            }
        }
    }

    Process {
        id: windowsProc

        stdout: StdioCollector {
            onStreamFinished: {
                dockRoot.windows = dockRoot.parseNiriArray(this.text, "Windows");
            }
        }
    }

    Process {
        id: workspacesProc

        stdout: StdioCollector {
            onStreamFinished: {
                dockRoot.workspaces = dockRoot.parseNiriArray(this.text, "Workspaces");
            }
        }
    }

    Process {
        id: focusProc
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            color: "transparent"
            exclusionMode: ExclusionMode.Auto
            focusable: false
            anchors {
                top: true
                left: true
                bottom: true
            }
            margins {
                top: Theme.barMarginTop + Theme.barHeight
            }
            implicitWidth: Theme.dockWidth
            WlrLayershell.namespace: "quickshell-dock"

            Rectangle {
                anchors.fill: parent
                color: Theme.backgroundPrimary
                opacity: 0.94

                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                    }
                    width: 1
                    color: Theme.surface
                    opacity: 0.7
                }
            }

            Flickable {
                id: dockFlick
                anchors {
                    fill: parent
                    topMargin: Theme.dockPadding
                    bottomMargin: Theme.dockPadding
                }
                clip: true
                contentWidth: width
                contentHeight: dockColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick
                interactive: contentHeight > height

                Column {
                    id: dockColumn
                    width: dockFlick.width
                    spacing: Theme.dockItemSpacing

                    Repeater {
                        model: dockRoot.buildDockItems(panel.modelData ? panel.modelData.name : "")

                        delegate: Item {
                            id: dockButton
                            required property var modelData
                            property var dockItem: modelData

                            width: dockColumn.width
                            height: Theme.dockItemSize

                            Rectangle {
                                anchors {
                                    right: buttonBg.left
                                    rightMargin: 6
                                    verticalCenter: buttonBg.verticalCenter
                                }
                                width: Theme.dockIndicatorWidth
                                height: dockButton.dockItem.focused ? 22 : 12
                                radius: Theme.dockIndicatorWidth / 2
                                color: dockButton.dockItem.urgent
                                    ? Theme.error
                                    : (dockButton.dockItem.focused ? Theme.accentPrimary : Theme.accentSecondary)
                                opacity: dockButton.dockItem.running ? 1 : 0

                                Behavior on height {
                                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                                }
                                Behavior on color {
                                    ColorAnimation { duration: 180 }
                                }
                                Behavior on opacity {
                                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                                }
                            }

                            Rectangle {
                                id: buttonBg
                                width: Theme.dockItemSize
                                height: Theme.dockItemSize
                                radius: Theme.dockItemSize / 3
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: {
                                    if (dockButton.dockItem.focused)
                                        return Theme.surfaceHover;
                                    if (mouseArea.containsMouse)
                                        return Theme.surface;
                                    return "transparent";
                                }
                                border.width: dockButton.dockItem.focused ? 1 : 0
                                border.color: dockButton.dockItem.focused ? Theme.accentPrimary : "transparent"
                                scale: mouseArea.containsMouse ? 1.04 : 1.0
                                transformOrigin: Item.Center

                                Behavior on color {
                                    ColorAnimation { duration: 180 }
                                }
                                Behavior on scale {
                                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                                }
                            }

                            IconImage {
                                anchors.centerIn: buttonBg
                                width: Theme.dockIconSize
                                height: Theme.dockIconSize
                                implicitSize: Theme.dockIconSize
                                source: dockRoot.iconSourceFor(dockButton.dockItem)
                                asynchronous: true
                                mipmap: true
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: dockRoot.activateItem(dockButton.dockItem)
                            }
                        }
                    }
                }
            }
        }
    }
}