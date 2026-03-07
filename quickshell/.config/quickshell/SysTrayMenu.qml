// ── SysTrayMenu ──────────────────────────────────────────────────
// Context menu popup anchored below the tray icon that triggered it.
// Supports nested submenus via an internal StackView.
// Close by clicking outside, hovering away, or when an entry is triggered.
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PopupWindow {
    id: root

    required property var menuHandle  // QsMenuHandle from the tray item
    required property Item anchor_item // the tray icon Item to anchor to
    // Set to the bar's ShellScreen for correct placement under fractional scaling.
    property var itemScreen: null

    screen: root.itemScreen

    // Anchor below the icon
    anchor {
        item: root.anchor_item
        edges: Edges.Bottom
        gravity: Edges.Bottom
        adjustment: PopupAdjustment.SlideX
    }

    color: "transparent"
    visible: true

    implicitWidth: Math.max(menuBg.implicitWidth + menuBg.padding * 2, 180)
    implicitHeight: menuBg.implicitHeight + menuBg.padding * 2

    signal menuClosed()

    function close() {
        root.visible = false;
        root.menuClosed();
    }

    // ── Click-outside dismissal ───────────────────────────────────
    // A full-screen transparent panel behind the popup catches outside clicks.
    PanelWindow {
        id: dismissBackdrop
        screen: root.itemScreen
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell:trayMenuBackdrop"
        exclusiveZone: 0

        MouseArea {
            anchors.fill: parent
            onPressed: root.close()
        }
    }

    // ── Menu background ───────────────────────────────────────────
    Rectangle {
        id: menuBg

        readonly property real padding: 5

        anchors {
            top: parent.top
            topMargin: padding
            left: parent.left
            leftMargin: padding
            right: parent.right
            rightMargin: padding
            bottom: parent.bottom
            bottomMargin: padding
        }

        radius: 10
        color: Theme.backgroundSecondary
        border.width: 1
        border.color: Theme.surface

        // Size to content
        implicitWidth: stack.currentItem ? stack.currentItem.implicitWidth : 180
        implicitHeight: stack.currentItem ? stack.currentItem.implicitHeight : 40

        Behavior on implicitWidth  { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on implicitHeight { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        // ── Submenu stack ─────────────────────────────────────────
        StackView {
            id: stack
            anchors.fill: parent
            anchors.margins: menuBg.padding

            pushEnter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 } }
            pushExit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 80 } }
            popEnter:  Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 } }
            popExit:   Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 80 } }

            implicitWidth: currentItem ? currentItem.implicitWidth : 0
            implicitHeight: currentItem ? currentItem.implicitHeight : 0

            // ── Root menu page ─────────────────────────────────────
            initialItem: menuPageComponent.createObject(stack, {
                handle: root.menuHandle,
                isSubMenu: false
            })
        }
    }

    // ── Menu page component (reused for every submenu level) ──────
    Component {
        id: menuPageComponent

        Item {
            id: page
            required property var handle   // QsMenuHandle
            property bool isSubMenu: false

            property bool hasIconColumn: false

            implicitWidth: pageCol.implicitWidth
            implicitHeight: pageCol.implicitHeight

            QsMenuOpener {
                id: opener
                menu: page.handle

                // Determine if any entry has an icon so we align all rows
                onChildrenChanged: {
                    let found = false;
                    for (let i = 0; i < opener.children.values.length; i++) {
                        if ((opener.children.values[i].icon ?? "").length > 0) {
                            found = true;
                            break;
                        }
                    }
                    page.hasIconColumn = found;
                }
            }

            ColumnLayout {
                id: pageCol
                spacing: 0

                // ── Back button (submenus only) ───────────────────
                Item {
                    visible: page.isSubMenu
                    Layout.fillWidth: true
                    implicitHeight: visible ? 32 : 0

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 6
                        color: backHover.hovered ? Theme.surfaceHover : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    HoverHandler { id: backHover }
                    TapHandler { onTapped: stack.pop() }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
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

                    // separator after back
                    Rectangle {
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: 4 }
                        height: 1
                        color: Theme.surfaceHover
                    }
                }

                // ── Entries ───────────────────────────────────────
                Repeater {
                    model: opener.children

                    SysTrayMenuEntry {
                        required property var modelData
                        menuEntry: modelData
                        forceIconColumn: page.hasIconColumn
                        Layout.fillWidth: true

                        onDismiss: root.close()
                        onOpenSubmenu: function(handle) {
                            stack.push(menuPageComponent.createObject(stack, {
                                handle: handle,
                                isSubMenu: true
                            }));
                        }
                    }
                }
            }
        }
    }
}
