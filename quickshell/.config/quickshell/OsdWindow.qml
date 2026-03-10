// ── OsdWindow ────────────────────────────────────────────────────
// Generic Android-style vertical pill OSD.
// Place on center-right of screen; slides in/out from the right edge.
//
// Usage:
//   OsdWindow {
//       id: myOsd
//       icon: "󰕾"
//       iconColor: Theme.accentPrimary
//       value: 0.65        // 0.0 – 1.0
//   }
//   // To show: myOsd.trigger()
//   // Value updates animate in real-time while visible.

import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: osdWindow

    // ── Public API ───────────────────────────────────────────────
    property string icon: "󰕾"
    property color  iconColor: Theme.accentPrimary
    property real   value: 0.5      // clamped 0.0 – 1.0
    property int    hideDelay: 3000 // ms before auto-hide

    // Call this every time you want the OSD to appear / extend its timer
    function trigger() {
        _wantVisible = true;
        hideTimer.restart();
    }

    // ── Window settings ──────────────────────────────────────────
    // Always resident; zero exclusive zone + empty mask means it takes
    // no space and blocks no input events.
    exclusiveZone: 0
    mask: Region {}
    color: "transparent"

    anchors.right: true
    anchors.top: true
    margins {
        right: 24
        // Push window so its centre aligns with screen vertical-centre
        top: screen ? Math.round((screen.height - implicitHeight) / 2) : 200
    }

    implicitWidth:  56
    implicitHeight: 200

    // ── Internal state ───────────────────────────────────────────
    property bool _wantVisible: false

    Timer {
        id: hideTimer
        interval: osdWindow.hideDelay
        onTriggered: osdWindow._wantVisible = false
    }

    // ── Visual layer ─────────────────────────────────────────────
    Item {
        id: osdContent
        anchors.fill: parent

        // Slide + fade animations driven by _wantVisible
        opacity: osdWindow._wantVisible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }

        transform: Translate {
            x: osdWindow._wantVisible ? 0 : 72
            Behavior on x {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutCubic
                }
            }
        }

        // ── Pill background ──────────────────────────────────────
        Rectangle {
            anchors.fill: parent
            // Full radius = width/2 gives a pill shape
            radius: width / 2
            color: Qt.rgba(
                Theme.backgroundPrimary.r,
                Theme.backgroundPrimary.g,
                Theme.backgroundPrimary.b,
                0.93
            )
            border {
                color: Qt.rgba(1.0, 1.0, 1.0, 0.07)
                width: 1
            }

            // ── Content column ───────────────────────────────────
            ColumnLayout {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    bottom: parent.bottom
                    topMargin: 18
                    bottomMargin: 18
                }
                spacing: 10

                // Icon
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: osdWindow.icon
                    font {
                        family: "Symbols Nerd Font"
                        pixelSize: 18
                    }
                    color: osdWindow.iconColor
                }

                // Vertical progress bar
                Item {
                    id: trackContainer
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillHeight: true
                    width: 6

                    // Track (background)
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    }

                    // Fill — grows from bottom upward
                    Rectangle {
                        id: fillBar
                        anchors {
                            bottom: parent.bottom
                            left:   parent.left
                            right:  parent.right
                        }
                        // Clamp value so we never overshoot or underflow
                        height: trackContainer.height * Math.max(0, Math.min(1, osdWindow.value))
                        radius: parent.width / 2

                        color: Theme.accentPrimary

                        Behavior on height {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }

                // Percentage label
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Math.round(Math.max(0, Math.min(1, osdWindow.value)) * 100) + "%"
                    font {
                        family:    Theme.fontFamily
                        pixelSize: Theme.fontSizeSmall
                        weight:    Font.Medium
                    }
                    color: Theme.textSecondary
                }
            }
        }
    }
}
