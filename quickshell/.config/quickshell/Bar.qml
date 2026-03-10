// ── Top bar ──────────────────────────────────────────────────────
// One instance per monitor via Variants.  Layout mirrors the
// previous ironbar config:  workspaces | clock | tray + hw widgets
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
    id: barRoot

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            color: "transparent"
            anchors {
                top: true
                left: true
                right: true
            }
            margins {
                top: Theme.barMarginTop
                left: Theme.barMarginH - Theme.dockWidth
                right: Theme.barMarginH
            }
            implicitHeight: Theme.barHeight
            WlrLayershell.namespace: "quickshell-bar"

            // ── Bar background ───────────────────────────────────
            Rectangle {
                id: barBg
                anchors.fill: parent
                radius: Theme.barRadius
                color: Theme.backgroundPrimary
                opacity: 1.0

                // subtle bottom shadow
                layer.enabled: true
            }

            // ── Centre: Clock ────────────────────────────────────
            ClockWidget {
                anchors.centerIn: parent
            }

            // ── Left: focused app name + icon ────────────────────
            RowLayout {
                id: leftSection
                anchors {
                    left: parent.left
                    leftMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.widgetSpacing

                ActiveAppWidget {}
            }

            // ── Right: media + privacy + tray + hardware widgets ──
            RowLayout {
                id: rightSection
                anchors {
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.widgetSpacing
                layoutDirection: Qt.LeftToRight

                MediaPlayerWidget {}

                PrivacyIndicatorWidget {}

                SysTray {
                    barScreen: panel.modelData
                }

                BatteryWidget {}

                BrightnessWidget {}

                VolumeWidget {}
            }
        }
    }
}
