// ── Time singleton ───────────────────────────────────────────────
// Provides formatted time and date strings to any widget.
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm AP")
    readonly property string date_: Qt.formatDateTime(clock.date, "dddd, MMMM d yyyy")
    readonly property string dateShort: Qt.formatDateTime(clock.date, "ddd, MMM d")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
