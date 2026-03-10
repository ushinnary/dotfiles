// ── ContextMenu ──────────────────────────────────────────────────
// Generic popup context menu used by both the dock sidebar and the
// system-tray icons.  Shares ContextMenuEntry for all rows so both
// places look and behave identically.
//
// Usage – plain items (dock / any static list):
//   ContextMenu {
//     anchorItem: someItem
//     menuItems: [
//       { label: "Pin to Dock" },
//       { separator: true },
//       { label: "Close", destructive: true }
//     ]
//     onTriggered: function(index) { ... }
//   }
//
// Usage – tray / QsMenuHandle (dynamic protocol menu with submenus):
//   ContextMenu {
//     anchorItem: trayIcon
//     menuHandle: trayItem.menu
//     itemScreen: barScreen
//   }
//
// Anchor orientation (default is below-anchor, suitable for top bar):
//   Set anchorEdges + anchorGravity + slideAdjust for the dock:
//     anchorEdges: Edges.Right
//     anchorGravity: Edges.Right
//     slideAdjust: PopupAdjustment.SlideY
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PopupWindow {
    id: root

    // ── Mode A: plain static items ────────────────────────────────
    // Each item: { label?, icon?, destructive?, separator?, enabled? }
    property var menuItems: null

    // ── Mode B: QsMenuHandle (system-tray protocol) ───────────────
    property var menuHandle: null

    // ── Placement ─────────────────────────────────────────────────
    required property Item anchorItem
    property var itemScreen: null
    property int anchorEdges: Edges.Bottom
    property int anchorGravity: Edges.Bottom
    property int slideAdjust: PopupAdjustment.SlideX

    // ── Signals ───────────────────────────────────────────────────
    signal menuClosed
    // Emitted only in menuItems mode
    signal triggered(int index)

    // ── Internal ──────────────────────────────────────────────────
    function close() {
        root.visible = false;
        root.menuClosed();
    }

    // ── PopupWindow config ────────────────────────────────────────
    screen: root.itemScreen
    anchor {
        item: root.anchorItem
        edges: root.anchorEdges
        gravity: root.anchorGravity
        adjustment: root.slideAdjust
    }
    color: "transparent"
    visible: true
    implicitWidth: Math.max(card.implicitWidth + card.outerPad * 2, 192)
    implicitHeight: card.implicitHeight + card.outerPad * 2

    // ── Full-screen backdrop (click outside to dismiss) ───────────
    PanelWindow {
        id: backdrop
        screen: root.itemScreen
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell:contextMenuBackdrop"
        exclusiveZone: 0

        MouseArea {
            anchors.fill: parent
            onPressed: root.close()
        }
    }

    // ── Card ──────────────────────────────────────────────────────
    Rectangle {
        id: card

        readonly property real outerPad: 5
        readonly property real innerPad: 5

        anchors {
            top: parent.top
            topMargin: outerPad
            left: parent.left
            leftMargin: outerPad
            right: parent.right
            rightMargin: outerPad
            bottom: parent.bottom
            bottomMargin: outerPad
        }

        radius: 10
        color: Theme.backgroundSecondary
        border.width: 1
        border.color: Theme.surface
        clip: true

        implicitWidth: (stack.currentItem ? stack.currentItem.implicitWidth : 180) + innerPad * 2
        implicitHeight: (stack.currentItem ? stack.currentItem.implicitHeight : 40) + innerPad * 2

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        Behavior on implicitHeight {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        // ── StackView (enables push/pop for submenus) ─────────────
        StackView {
            id: stack
            anchors.fill: parent
            anchors.margins: card.innerPad

            pushEnter: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 100
                }
            }
            pushExit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 80
                }
            }
            popEnter: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 100
                }
            }
            popExit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 80
                }
            }

            implicitWidth: currentItem ? currentItem.implicitWidth : 0
            implicitHeight: currentItem ? currentItem.implicitHeight : 0

            // Pick initial page based on mode
            initialItem: root.menuHandle !== null ? trayPageComponent.createObject(stack, {
                handle: root.menuHandle,
                isSubMenu: false
            }) : plainPageComponent.createObject(stack)
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Mode A: plain items page
    // ─────────────────────────────────────────────────────────────
    Component {
        id: plainPageComponent

        Item {
            implicitWidth: plainCol.implicitWidth
            implicitHeight: plainCol.implicitHeight

            ColumnLayout {
                id: plainCol
                spacing: 1

                Repeater {
                    model: root.menuItems

                    ContextMenuEntry {
                        required property var modelData
                        required property int index

                        label: modelData.label ?? ""
                        icon: modelData.icon ?? ""
                        destructive: modelData.destructive ?? false
                        separator: modelData.separator ?? false
                        enabled: modelData.enabled !== false
                        Layout.fillWidth: true
                        Layout.minimumWidth: 180

                        onTriggered: {
                            root.triggered(index);
                            root.close();
                        }
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Mode B: tray / QsMenuHandle page (supports submenus)
    // ─────────────────────────────────────────────────────────────
    Component {
        id: trayPageComponent

        Item {
            id: trayPage

            required property var handle  // QsMenuHandle
            property bool isSubMenu: false
            property bool hasIconColumn: false
            // Items are populated asynchronously one-by-one; defer
            // rendering until the burst of additions settles.
            property bool itemsReady: false

            implicitWidth: trayCol.implicitWidth
            implicitHeight: trayCol.implicitHeight

            QsMenuOpener {
                id: opener
                menu: trayPage.handle

                onChildrenChanged: {
                    // Check if any entry has an icon so we can align columns
                    let found = false;
                    for (let i = 0; i < opener.children.values.length; i++) {
                        if ((opener.children.values[i].icon ?? "").length > 0) {
                            found = true;
                            break;
                        }
                    }
                    trayPage.hasIconColumn = found;
                    // Debounce: wait for the burst of item additions to settle
                    readyTimer.restart();
                }
            }

            // Fires once the item list stops changing for 60 ms
            Timer {
                id: readyTimer
                interval: 60
                repeat: false
                onTriggered: trayPage.itemsReady = true
            }

            ColumnLayout {
                id: trayCol
                spacing: 0

                // Fade in all-at-once when ready (avoids one-by-one appearance)
                opacity: trayPage.itemsReady ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }

                // ── Back button (submenus only) ───────────────────
                Item {
                    visible: trayPage.isSubMenu
                    Layout.fillWidth: true
                    implicitHeight: visible ? 32 : 0

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 6
                        color: backHover.hovered ? Theme.surfaceHover : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }
                    }

                    HoverHandler {
                        id: backHover
                    }
                    TapHandler {
                        onTapped: stack.pop()
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        spacing: 6

                        Text {
                            text: "‹"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.textSecondary
                        }
                        Text {
                            text: "Back"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                        }
                    }

                    // Separator under back button
                    Rectangle {
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                            margins: 4
                        }
                        height: 1
                        color: Theme.surfaceHover
                    }
                }

                // ── Menu entries ──────────────────────────────────
                Repeater {
                    model: opener.children

                    ContextMenuEntry {
                        required property var modelData

                        label: modelData.text ?? ""
                        icon: modelData.icon ?? ""
                        forceIconColumn: trayPage.hasIconColumn
                        separator: modelData.isSeparator ?? false
                        enabled: modelData.enabled ?? true
                        buttonType: modelData.buttonType ?? 0
                        checked: (modelData.checkState ?? 0) === Qt.Checked
                        hasSubmenu: modelData.hasChildren ?? false
                        Layout.fillWidth: true
                        Layout.minimumWidth: 180

                        onTriggered: {
                            modelData.triggered();
                            root.close();
                        }
                        onOpenSubmenu: {
                            stack.push(trayPageComponent.createObject(stack, {
                                handle: modelData,
                                isSubMenu: true
                            }));
                        }
                    }
                }
            }
        }
    }
}
