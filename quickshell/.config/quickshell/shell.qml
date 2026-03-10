// ── Quickshell entry point ────────────────────────────────────────
// This is the root of the Quickshell configuration.

import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    Dock {}
    Bar {}

    // ── Unified OSD (volume + brightness share one pill) ──────────
    // A single OsdWindow is used so both sources never overlap.
    Scope {
        id: osdScope

        PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
        property var sink: Pipewire.defaultAudioSink

        OsdWindow { id: sharedOsd }

        function volumeIcon(vol, muted) {
            if (muted || vol === 0) return "󰝟"
            if (vol < 0.33) return "󰕿"
            if (vol < 0.66) return "󰖀"
            return "󰕾"
        }

        Connections {
            target: osdScope.sink?.audio ?? null

            function onVolumeChanged() {
                const v = osdScope.sink?.audio?.volume ?? 0
                const m = osdScope.sink?.audio?.muted ?? false
                sharedOsd.icon      = osdScope.volumeIcon(v, m)
                sharedOsd.iconColor = m ? Theme.textDim : Theme.accentPrimary
                sharedOsd.value     = v
                sharedOsd.trigger()
            }

            function onMutedChanged() {
                const v = osdScope.sink?.audio?.volume ?? 0
                const m = osdScope.sink?.audio?.muted ?? false
                sharedOsd.icon      = osdScope.volumeIcon(v, m)
                sharedOsd.iconColor = m ? Theme.textDim : Theme.accentPrimary
                sharedOsd.value     = v
                sharedOsd.trigger()
            }
        }

        Connections {
            target: Brightness

            function onPercentageChanged() {
                if (!Brightness.hasBacklight) return
                sharedOsd.icon      = "󰃠"
                sharedOsd.iconColor = Theme.warning
                sharedOsd.value     = Brightness.percentage / 100.0
                sharedOsd.trigger()
            }
        }
    }
}
