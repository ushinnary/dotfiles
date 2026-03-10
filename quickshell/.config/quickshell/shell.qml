// ── Quickshell entry point ────────────────────────────────────────
// This is the root of the Quickshell configuration.
// Add new top-level widgets (notification popups, lock screen, etc.)
// as siblings of Bar {} here.
//
// Future: you can write Rust helper binaries (for heavy computation,
// custom IPC, etc.) and call them via Process {} from any QML file.

import Quickshell

Scope {
    id: root

    Dock {}

    Bar {}

    // ── On-screen display overlays ────────────────────────────────
    // Shown on change only; each auto-hides after 3 s.
    VolumeOsd {}
    BrightnessOsd {}
}
