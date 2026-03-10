// ── OsdWindow ────────────────────────────────────────────────────
// Generic Android-style vertical pill OSD.
// Registers with OsdManager so multiple pills stack side-by-side
// instead of overlapping.  The rightmost slot (index 0) is the
// first/oldest visible OSD; each new pill appears to its left.
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

    // Stack slot assigned by OsdManager (0 = rightmost)
    property int  stackIndex: 0
    // Whether this pill is currently registered in the stack
    property bool _registered: false

    // Call this every time you want the OSD to appear / extend its timer.
    function trigger() {
        // If we were in the middle of fading out, cancel the pending
        // unregister so the pill stays in its current stack slot.
        postFadeTimer.stop();

        if (!_registered) {
            OsdManager.register(osdWindow);
            _registered = true;
        }
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

    // Step 1: auto-hide starts — fade the pill out.
    Timer {
        id: hideTimer
        interval: osdWindow.hideDelay
        onTriggered: osdWindow._wantVisible = false
    }

    // Step 2: once the opacity animation has finished (~280 ms) unregister
    // from the stack so the remaining pills slide right to fill the gap.
    // Fired slightly after the opacity Behavior duration (280 ms).
    Timer {
        id: postFadeTimer
        interval: 300
        onTriggered: {
            OsdManager.unregister(osdWindow);
            osdWindow._registered = false;
        }
    }

    // When _wantVisible flips to false, start the post-fade unregister.
    onVisibleChanged: {
        if (!_wantVisible && _registered) {
            postFadeTimer.restart();
        }
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
            // When visible: shift left by (stackIndex × step) so pills
            // sit side-by-side.  When hidden: park off-screen right so
            // the next trigger() produces a slide-in animation.
            x: osdWindow._wantVisible
                ? -(osdWindow.stackIndex * (OsdManager.pillWidth + OsdManager.pillGap))
                : 72
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
                Theme.backgroundSecondary.r,
                Theme.backgroundSecondary.g,
                Theme.backgroundSecondary.b,
                0.97
            )
            border {
                color: Qt.rgba(1.0, 1.0, 1.0, 0.15)
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
                        weight:    Font.SemiBold
                    }
                    color: Theme.textPrimary
                }
            }
        }
    }
}
