// ── VolumeOsd ────────────────────────────────────────────────────
// Listens to the Pipewire default audio sink and shows the OSD pill
// whenever volume or mute state changes.

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: volumeOsdRoot

    // Keep the default sink tracked so its properties stay live
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // ── Helpers ──────────────────────────────────────────────────
    property var sink: Pipewire.defaultAudioSink
    property real currentVolume: sink?.audio?.volume ?? 0
    property bool isMuted: sink?.audio?.muted ?? false

    function volumeIcon(): string {
        if (isMuted || currentVolume === 0) return "󰝟";
        if (currentVolume < 0.33) return "󰕿";
        if (currentVolume < 0.66) return "󰖀";
        return "󰕾";
    }

    // ── React to changes ─────────────────────────────────────────
    Connections {
        target: volumeOsdRoot.sink?.audio ?? null

        function onVolumeChanged() {
            osd.icon      = volumeOsdRoot.volumeIcon();
            osd.iconColor = Theme.accentPrimary;
            osd.value     = volumeOsdRoot.currentVolume;
            osd.trigger();
        }

        function onMutedChanged() {
            osd.icon      = volumeOsdRoot.volumeIcon();
            osd.iconColor = volumeOsdRoot.isMuted ? Theme.textDim : Theme.accentPrimary;
            osd.value     = volumeOsdRoot.currentVolume;
            osd.trigger();
        }
    }

    // ── OSD window ───────────────────────────────────────────────
    OsdWindow {
        id: osd
        icon:      volumeOsdRoot.volumeIcon()
        iconColor: volumeOsdRoot.isMuted ? Theme.textDim : Theme.accentPrimary
        value:     volumeOsdRoot.currentVolume
    }
}
