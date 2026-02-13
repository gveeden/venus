pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property date currentDate: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    readonly property string timeStr: Qt.formatDateTime(currentDate, "hh:mm")
    readonly property string dateStr: Qt.formatDateTime(currentDate, "ddd dd MMM")
    readonly property string fullStr: Qt.formatDateTime(currentDate, "hh:mm ddd dd MMM")

    function format(fmt: string): string {
        return Qt.formatDateTime(currentDate, fmt)
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
