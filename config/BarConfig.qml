pragma Singleton

import QtQuick

QtObject {
    readonly property int height: 30
    readonly property int spacing: 15
    readonly property int margins: 10
    readonly property int fontSize: 14

    property var widgetOrder: ["tray", "memory", "network", "bluetooth", "sound", "home", "battery", "clock"]
    property var hiddenWidgets: []
    readonly property var allWidgets: ["tray", "memory", "network", "bluetooth", "sound", "home", "battery", "clock"]
}
