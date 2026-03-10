// ── Media Player Widget ──────────────────────────────────────────
// Displays the currently playing track with prev / play-pause / next
// controls via the MPRIS protocol (Spotify, Rhythmbox, mpv, etc.).
// Only visible when an active player is available.
import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Item {
    id: mediaRoot

    // Find the first playing player, fall back to first available player
    readonly property var activePlayer: {
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const p = Mpris.players.values[i];
            if (p.playbackState === MprisPlaybackState.Playing)
                return p;
        }
        return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null;
    }
    readonly property bool playerAvailable: activePlayer !== null
    readonly property bool isPlaying: activePlayer !== null && activePlayer.playbackState === MprisPlaybackState.Playing

    implicitWidth: playerAvailable ? contentRow.implicitWidth + 16 : 0
    implicitHeight: parent ? parent.height : 32
    visible: playerAvailable
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    // ── Hover background ─────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mediaHover.containsMouse ? Theme.surfaceHover : "transparent"
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    // ── Content ───────────────────────────────────────────────────
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        // Music note icon
        Text {
            text: "󰎈"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: Theme.accentPrimary
            Layout.alignment: Qt.AlignVCenter
        }

        // ── Scrolling track / artist text ─────────────────────────
        Item {
            width: 140
            height: mediaRoot.implicitHeight
            Layout.alignment: Qt.AlignVCenter
            clip: true

            Text {
                id: trackText
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (!mediaRoot.activePlayer || !mediaRoot.activePlayer.track)
                        return ""
                    const trk = mediaRoot.activePlayer.track
                    const title = trk.title || "Unknown"
                    const artistList = trk.artists || []
                    const artist = artistList.length > 0 ? artistList.join(", ") : ""
                    return artist ? title + " · " + artist : title
                }
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textPrimary
                x: needsScrolling ? -scrollOffset : 0

                readonly property bool needsScrolling: implicitWidth > 140
                property real scrollOffset: 0

                onTextChanged: {
                    scrollOffset = 0
                    scrollAnim.restart()
                }

                SequentialAnimation {
                    id: scrollAnim
                    running: trackText.needsScrolling
                    loops: Animation.Infinite
                    PauseAnimation { duration: 2000 }
                    NumberAnimation {
                        target: trackText
                        property: "scrollOffset"
                        from: 0
                        to: Math.max(0, trackText.implicitWidth - 140 + 10)
                        duration: Math.max(1000, (trackText.implicitWidth - 140 + 10) * 60)
                        easing.type: Easing.Linear
                    }
                    PauseAnimation { duration: 2000 }
                    NumberAnimation {
                        target: trackText
                        property: "scrollOffset"
                        to: 0
                        duration: 600
                        easing.type: Easing.Linear
                    }
                }
            }
        }

        // ── Previous ──────────────────────────────────────────────
        Rectangle {
            width: 20
            height: 20
            radius: 10
            color: prevArea.containsMouse ? Theme.surfaceHover : "transparent"
            opacity: (mediaRoot.activePlayer && mediaRoot.activePlayer.canGoPrevious) ? 1.0 : 0.35
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "󰒮"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 12
                color: Theme.textSecondary
            }

            MouseArea {
                id: prevArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (mediaRoot.activePlayer)
                        mediaRoot.activePlayer.previous()
                }
            }
        }

        // ── Play / Pause ──────────────────────────────────────────
        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: mediaRoot.isPlaying ? Theme.accentPrimary : Theme.surface
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: mediaRoot.isPlaying ? "󰏤" : "󰐊"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 12
                color: mediaRoot.isPlaying ? Theme.backgroundPrimary : Theme.accentPrimary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (mediaRoot.activePlayer)
                        mediaRoot.activePlayer.togglePlaying()
                }
            }
        }

        // ── Next ──────────────────────────────────────────────────
        Rectangle {
            width: 20
            height: 20
            radius: 10
            color: nextArea.containsMouse ? Theme.surfaceHover : "transparent"
            opacity: (mediaRoot.activePlayer && mediaRoot.activePlayer.canGoNext) ? 1.0 : 0.35
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "󰒭"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 12
                color: Theme.textSecondary
            }

            MouseArea {
                id: nextArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (mediaRoot.activePlayer)
                        mediaRoot.activePlayer.next()
                }
            }
        }
    }

    // ── Hover detection for background ────────────────────────────
    MouseArea {
        id: mediaHover
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onClicked: mouse => mouse.accepted = false
        onPressed: mouse => mouse.accepted = false
    }
}
