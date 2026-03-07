// ── Theme singleton ──────────────────────────────────────────────
// Central place for every colour / size token used across widgets.
// Swap these values to re-skin the entire bar.
pragma Singleton

import Quickshell

Singleton {
    // ── Palette (dark, loosely Adwaita-dark) ─────────────────────
    readonly property color backgroundPrimary: "#1e1e2e"
    readonly property color backgroundSecondary: "#181825"
    readonly property color surface: "#313244"
    readonly property color surfaceHover: "#45475a"
    readonly property color accentPrimary: "#89b4fa"
    readonly property color accentSecondary: "#74c7ec"
    readonly property color textPrimary: "#cdd6f4"
    readonly property color textSecondary: "#a6adc8"
    readonly property color textDim: "#6c7086"
    readonly property color success: "#a6e3a1"
    readonly property color warning: "#f9e2af"
    readonly property color error: "#f38ba8"

    // ── Typography ───────────────────────────────────────────────
    readonly property string fontFamily: "Quicksand"
    readonly property string monoFontFamily: "Google Sans Code"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeMedium: 13

    // ── Geometry ─────────────────────────────────────────────────
    readonly property int barHeight: 32
    readonly property int barRadius: 10
    readonly property int widgetSpacing: 10
    readonly property int barMarginH: 14
    readonly property int barMarginTop: 4
}
