pragma Singleton

import QtQuick

QtObject {
    // Match mako dimensions
    readonly property int width: 300
    readonly property int height: 110
    readonly property int topMargin: 50
    readonly property int rightMargin: 20
    readonly property int iconSize: 64
    readonly property int borderSize: 2
    readonly property int borderRadius: 15

    // Default timeout (mako: default-timeout=5000)
    readonly property int defaultTimeout: 5000

    // Timeout overrides by urgency (mako: urgency=high has default-timeout=0)
    function getTimeout(urgency, category): int {
        // MPD category has shorter timeout (mako: category=mpd has default-timeout=2000)
        if (category === "mpd")
            return 2000;

        switch (urgency) {
        case 2: // Critical - never timeout (0 means no timeout)
            return 0;
        case 0: // Low
        case 1: // Normal
        default:
            return defaultTimeout;
        }
    }

    // Border colors by urgency (mako config)
    function getBorderColor(urgency, colors): color {
        switch (urgency) {
        case 0: // Low
            return "#cccccc";  // mako: border-color=#cccccc
        case 2: // Critical/High
            return "#bf616a";  // mako: border-color=#bf616a
        case 1: // Normal
        default:
            return "#d08770";  // mako: border-color=#d08770
        }
    }

    // Maximum notifications to show at once
    readonly property int maxVisible: 5

    // Spacing between stacked notifications
    readonly property int notificationSpacing: 10
}
