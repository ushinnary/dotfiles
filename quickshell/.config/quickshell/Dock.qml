// ── Left dock ───────────────────────────────────────────────────
// Shows pinned apps (user-managed, persisted) plus currently running
// applications.  Right-click any icon for a context menu.  Pinned
// apps can be reordered via drag-and-drop.
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

Scope {
    id: dockRoot

    // ── Pinned apps – persisted to ~/.config/quickshell/pinned-apps.json
    property var manualPinnedDesktopIds: []

    // ── Window / workspace state ──────────────────────────────────
    property var windows: []
    property var workspaces: []

    // ── Drag-and-drop state ───────────────────────────────────────
    property int  dragSourceIndex: -1   // index in manualPinnedDesktopIds
    property bool dragActive: false
    property real dragCurrentY: 0       // Y in panel-window coords

    // ── Context menu state ────────────────────────────────────────
    // Shared across panel instances; the overlay Variants reads these.
    property var  menuContextItem:  null
    property bool menuVisible:      false
    property real menuY:            0        // Y in dock-panel coordinates
    property var  menuTargetScreen: null

    // ── Persistence helpers ───────────────────────────────────────

    function loadPinnedApps(text) {
        if (!text || !text.trim())
            return;
        try {
            const arr = JSON.parse(text.trim());
            if (Array.isArray(arr))
                dockRoot.manualPinnedDesktopIds = arr;
        } catch (e) {
            console.warn("Dock: failed to parse pinned-apps.json:", e);
        }
    }

    function savePinnedApps() {
        const json = JSON.stringify(dockRoot.manualPinnedDesktopIds);
        // Use printf to avoid echo interpretation; single-quote wrap is safe
        // because desktop IDs never contain single quotes.
        writePinnedProc.exec(["sh", "-c",
            "printf '%s' '" + json + "' > ~/.config/quickshell/pinned-apps.json"]);
    }

    // ── Pin management ────────────────────────────────────────────

    function isPinned(desktopId) {
        return !!desktopId && dockRoot.manualPinnedDesktopIds.indexOf(desktopId) >= 0;
    }

    function pinApp(desktopId) {
        if (!desktopId)
            return;
        const ids = dockRoot.manualPinnedDesktopIds.slice();
        if (ids.indexOf(desktopId) < 0) {
            ids.push(desktopId);
            dockRoot.manualPinnedDesktopIds = ids;
            dockRoot.savePinnedApps();
        }
    }

    function unpinApp(desktopId) {
        if (!desktopId)
            return;
        dockRoot.manualPinnedDesktopIds =
            dockRoot.manualPinnedDesktopIds.filter(function(id) { return id !== desktopId; });
        dockRoot.savePinnedApps();
    }

    function movePinnedApp(fromIndex, toIndex) {
        if (fromIndex === toIndex || fromIndex < 0 || toIndex < 0)
            return;
        const ids = dockRoot.manualPinnedDesktopIds.slice();
        if (fromIndex >= ids.length || toIndex >= ids.length)
            return;
        const removed = ids.splice(fromIndex, 1)[0];
        ids.splice(toIndex, 0, removed);
        dockRoot.manualPinnedDesktopIds = ids;
        dockRoot.savePinnedApps();
    }

    // ── General utilities ─────────────────────────────────────────

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
        return dockRoot.uniqueStrings(dockRoot.manualPinnedDesktopIds);
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
                    sortLaunchId: Number(window.id || Number.MAX_SAFE_INTEGER),
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
            let earliestWindowId = Number.MAX_SAFE_INTEGER;

            for (let windowIndex = 0; windowIndex < current.windows.length; windowIndex++) {
                const candidateId = Number(current.windows[windowIndex].id || Number.MAX_SAFE_INTEGER);
                if (candidateId < earliestWindowId)
                    earliestWindowId = candidateId;
            }

            current.primaryWindowId = primaryWindow ? Number(primaryWindow.id || -1) : -1;
            current.sortLaunchId = earliestWindowId;
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
                sortLaunchId: Number.MAX_SAFE_INTEGER,
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
            if (a.sortLaunchId !== b.sortLaunchId)
                return a.sortLaunchId - b.sortLaunchId;

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
        readPinnedProc.exec(["sh", "-c",
            "cat ~/.config/quickshell/pinned-apps.json 2>/dev/null || echo '[]'"]);
        dockRoot.refreshNiriState();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dockRoot.refreshNiriState()
    }

    Process {
        id: readPinnedProc

        stdout: StdioCollector {
            onStreamFinished: dockRoot.loadPinnedApps(this.text)
        }
    }

    Process { id: writePinnedProc }

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

    Process {
        id: closeWindowProc
    }

    Process {
        id: switchWsProc
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            // ── Per-panel drag state ───────────────────────────────────
            property int    panelDragSourceIndex: -1   // index in manualPinnedDesktopIds
            property bool   panelDragActive: false
            property real   panelDragY: 0              // cursor Y in panel coords
            property string panelDragDesktopId: ""

            function pinnedDropIndex(cursorY) {
                // account for workspace section + divider sitting above the app list
                const topOff = wsSection.height + 7 + Theme.dockPadding;
                const itemH  = Theme.dockItemSize + Theme.dockItemSpacing;
                const relY   = cursorY - topOff;
                const count  = dockRoot.manualPinnedDesktopIds.length;
                return Math.max(0, Math.min(count - 1, Math.round(relY / itemH)));
            }

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

            // ── Background ────────────────────────────────────────────
            Rectangle {
                anchors.fill: parent
                color: Theme.backgroundPrimary
                opacity: 1.0

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

            // ── Drag-and-drop overlay ─────────────────────────────────
            Item {
                visible: panel.panelDragActive
                anchors.fill: parent
                z: 100

                // Insertion indicator line
                Rectangle {
                    width: Theme.dockItemSize
                    height: 2
                    radius: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.accentPrimary
                    y: {
                        const idx    = panel.pinnedDropIndex(panel.panelDragY);
                        const topOff = wsSection.height + 7 + Theme.dockPadding;
                        const itemH  = Theme.dockItemSize + Theme.dockItemSpacing;
                        return topOff + idx * itemH - Theme.dockItemSpacing * 0.5;
                    }
                    Behavior on y { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                }

                // Floating icon preview following cursor
                Rectangle {
                    width: Theme.dockItemSize
                    height: Theme.dockItemSize
                    radius: Theme.dockItemSize / 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.surfaceHover || Theme.surface
                    opacity: 0.88
                    y: Math.max(0, Math.min(panel.height - height, panel.panelDragY - height / 2))

                    IconImage {
                        property string iconSrc: {
                            const did = panel.panelDragDesktopId;
                            if (!did) return "";
                            const entry = dockRoot.resolveDesktopEntry(did);
                            if (entry && entry.icon) {
                                const r = Quickshell.iconPath(entry.icon, true);
                                if (r) return r;
                            }
                            return Quickshell.iconPath("application-x-executable", true) || "";
                        }
                        anchors.centerIn: parent
                        width: Theme.dockIconSize
                        height: Theme.dockIconSize
                        implicitSize: Theme.dockIconSize
                        source: iconSrc
                        asynchronous: true
                        mipmap: true
                    }
                }
            }

            // ── Workspace pills ───────────────────────────────────────
            Column {
                id: wsSection
                width: parent.width
                anchors {
                    top: parent.top
                    topMargin: Theme.dockPadding
                }
                spacing: 5

                Repeater {
                    model: {
                        const sn = panel.modelData ? panel.modelData.name.toLowerCase() : "";
                        return dockRoot.workspaces.filter(function(ws) {
                            return !sn || (ws.output && ws.output.toLowerCase() === sn);
                        });
                    }

                    Item {
                        required property var modelData
                        width: wsSection.width
                        // active pill is tall enough to fit rotated text (⩾ longest ws name)
                        height: modelData.is_focused ? 80 : 8

                        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                        Rectangle {
                            width: modelData.is_focused ? parent.width - 10 : 26
                            height: parent.height
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: modelData.is_focused ? 9 : height / 2
                            color: {
                                if (modelData.is_focused) return Theme.accentPrimary;
                                if (wsPillMouse.containsMouse) return Theme.accentSecondary;
                                return Theme.surface;
                            }

                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                            Text {
                                visible: modelData.is_focused
                                anchors.centerIn: parent
                                // After rotation the layout width becomes the visual vertical extent,
                                // so set it to the pill height minus a little breathing room.
                                width: parent.height - 12
                                rotation: -90   // reads top → bottom
                                text: modelData.name || ("WS " + modelData.idx)
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.backgroundPrimary
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: wsPillMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: switchWsProc.exec([
                                "niri", "msg", "action", "focus-workspace",
                                String(modelData.idx)
                            ])
                        }
                    }
                }
            }

            // ── Divider between workspaces and app list ───────────────
            Rectangle {
                id: wsDivider
                anchors {
                    top: wsSection.bottom
                    topMargin: 6
                    left: parent.left
                    leftMargin: 8
                    right: parent.right
                    rightMargin: 8
                }
                height: 1
                color: Theme.surface
                opacity: 0.6
            }

            // ── Scroll list ───────────────────────────────────────────
            Flickable {
                id: dockFlick
                anchors {
                    top: wsDivider.bottom
                    topMargin: Theme.dockPadding
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: Theme.dockPadding
                }
                clip: true
                contentWidth: width
                contentHeight: dockColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick
                // Disable scroll grab while user is dragging an app
                interactive: contentHeight > height && !panel.panelDragActive

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

                            // Ghost the item being dragged (overlay takes its place visually)
                            opacity: panel.panelDragActive
                                && panel.panelDragDesktopId === dockButton.dockItem.desktopId
                                ? 0.2 : 1.0
                            Behavior on opacity { NumberAnimation { duration: 120 } }

                            width: dockColumn.width
                            height: Theme.dockItemSize

                            // ── Running indicator dot ─────────────────────────────
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

                                Behavior on height  { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                                Behavior on color   { ColorAnimation  { duration: 180 } }
                                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            }

                            // ── Icon background ───────────────────────────────────
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
                                scale: !panel.panelDragActive && mouseArea.containsMouse ? 1.04 : 1.0
                                transformOrigin: Item.Center

                                Behavior on color { ColorAnimation  { duration: 180 } }
                                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
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

                            // ── Interaction ───────────────────────────────────────
                            // Left-click: launch/focus  |  Right-click: context menu
                            // Left-press + drag (pinned only): drag-to-reorder
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: panel.panelDragActive && panel.panelDragDesktopId === dockButton.dockItem.desktopId
                                    ? Qt.ClosedHandCursor
                                    : Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                preventStealing: true

                                property real pressLocalY: 0
                                property bool isDragging: false

                                onPressed: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        const pos = mapToItem(panel, mouse.x, mouse.y);
                                        dockRoot.menuContextItem  = dockButton.dockItem;
                                        dockRoot.menuY            = pos.y;
                                        dockRoot.menuTargetScreen = panel.modelData;
                                        dockRoot.menuVisible      = true;
                                        mouse.accepted = true;
                                        return;
                                    }
                                    pressLocalY = mouse.y;
                                    isDragging  = false;
                                }

                                onPositionChanged: function(mouse) {
                                    if (!pressed || mouse.buttons !== Qt.LeftButton)
                                        return;
                                    if (!dockButton.dockItem.pinned)
                                        return;
                                    if (!isDragging && Math.abs(mouse.y - pressLocalY) > 6) {
                                        isDragging = true;
                                        panel.panelDragActive      = true;
                                        panel.panelDragSourceIndex =
                                            dockRoot.manualPinnedDesktopIds.indexOf(
                                                dockButton.dockItem.desktopId);
                                        panel.panelDragDesktopId   = dockButton.dockItem.desktopId;
                                    }
                                    if (isDragging) {
                                        const pos = mapToItem(panel, mouse.x, mouse.y);
                                        panel.panelDragY = pos.y;
                                    }
                                }

                                onReleased: function(mouse) {
                                    if (isDragging) {
                                        const targetIdx = panel.pinnedDropIndex(panel.panelDragY);
                                        dockRoot.movePinnedApp(panel.panelDragSourceIndex, targetIdx);
                                        panel.panelDragActive      = false;
                                        panel.panelDragSourceIndex = -1;
                                        panel.panelDragDesktopId   = "";
                                        isDragging = false;
                                        return;
                                    }
                                    if (mouse.button === Qt.LeftButton)
                                        dockRoot.activateItem(dockButton.dockItem);
                                }

                                onCanceled: {
                                    if (isDragging) {
                                        panel.panelDragActive      = false;
                                        panel.panelDragSourceIndex = -1;
                                        panel.panelDragDesktopId   = "";
                                        isDragging = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Context menu overlay ──────────────────────────────────────
    // A separate layer-shell surface starting just to the right of the
    // dock (margins.left: Theme.dockWidth) so the card is never clipped
    // by the narrow dock window.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: dockRoot.menuVisible
                     && (dockRoot.menuTargetScreen?.name ?? "") === (modelData?.name ?? "")

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            anchors { top: true; left: true; bottom: true }
            margins {
                top:  Theme.barMarginTop + Theme.barHeight
                left: Theme.dockWidth
            }
            implicitWidth: 192
            WlrLayershell.namespace: "quickshell-dock-menu"

            // Transparent backdrop – click anywhere outside card to dismiss.
            // Must be disabled when hidden, otherwise it swallows all
            // clicks to the right of the dock even while the menu is closed.
            MouseArea {
                anchors.fill: parent
                z: 0
                enabled: dockRoot.menuVisible
                onPressed: dockRoot.menuVisible = false
            }

            // Menu card
            Rectangle {
                x: 4
                y: Math.max(4, Math.min(parent.height - height - 4,
                                        dockRoot.menuY - 12))
                width: 184
                height: menuCol.implicitHeight + 12
                radius: 8
                color: Theme.backgroundSecondary
                border.color: Theme.surface
                border.width: 1
                z: 1
                layer.enabled: true

                Column {
                    id: menuCol
                    anchors {
                        top: parent.top; topMargin: 6
                        left: parent.left; leftMargin: 4
                        right: parent.right; rightMargin: 4
                    }
                    spacing: 1

                    // ── Pin / Unpin ────────────────────────────────────
                    Rectangle {
                        width: menuCol.width
                        height: 32
                        radius: 6
                        visible: !!dockRoot.menuContextItem && !!dockRoot.menuContextItem.desktopId
                        color: pinRow.containsMouse ? Theme.surface : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                            text: dockRoot.menuContextItem?.pinned ? "Unpin from Dock" : "Pin to Dock"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.textPrimary
                        }
                        MouseArea {
                            id: pinRow
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (!dockRoot.menuContextItem) return;
                                if (dockRoot.menuContextItem.pinned)
                                    dockRoot.unpinApp(dockRoot.menuContextItem.desktopId);
                                else
                                    dockRoot.pinApp(dockRoot.menuContextItem.desktopId);
                                dockRoot.menuVisible = false;
                            }
                        }
                    }

                    // ── Separator ──────────────────────────────────────
                    Rectangle {
                        width: menuCol.width - 8
                        height: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: !!dockRoot.menuContextItem && !!dockRoot.menuContextItem.desktopId
                        color: Theme.surface
                        opacity: 0.7
                    }

                    // ── Launch ─────────────────────────────────────────
                    Rectangle {
                        width: menuCol.width
                        height: 32
                        radius: 6
                        visible: !!dockRoot.menuContextItem && !!dockRoot.menuContextItem.entry
                        color: launchRow.containsMouse ? Theme.surface : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                            text: "Launch"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.textPrimary
                        }
                        MouseArea {
                            id: launchRow
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (dockRoot.menuContextItem?.entry)
                                    dockRoot.menuContextItem.entry.execute();
                                dockRoot.menuVisible = false;
                            }
                        }
                    }

                    // ── Close window ───────────────────────────────────
                    Rectangle {
                        width: menuCol.width
                        height: 32
                        radius: 6
                        visible: !!dockRoot.menuContextItem
                                 && dockRoot.menuContextItem.running
                                 && dockRoot.menuContextItem.primaryWindowId > 0
                        color: closeRow.containsMouse ? Theme.surface : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                            text: "Close"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.error
                        }
                        MouseArea {
                            id: closeRow
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                closeWindowProc.exec([
                                    "niri", "msg", "action", "close-window",
                                    "--id", String(dockRoot.menuContextItem.primaryWindowId)
                                ]);
                                dockRoot.menuVisible = false;
                            }
                        }
                    }
                }
            }
        }
    }
}