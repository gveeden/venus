import "../../config"
import "../../services"
import "../../components/containers"
import Quickshell
import QtQuick
import "." as BatteryPrivate

Scope {
    id: root
    property alias visible: batteryWindow.visible

    // Public functions for timer control
    function startCloseTimer() {
        batteryWindow.startCloseTimer()
    }

    function stopCloseTimer() {
        batteryWindow.stopCloseTimer()
    }

    DropdownWindow {
        id: batteryWindow
        windowWidth: BatteryConfig.windowWidth
        windowHeight: BatteryConfig.windowHeight
        topMargin: BatteryConfig.topMargin
        rightMargin: BatteryConfig.rightMargin
        contentMargins: 10

        content: BatteryPrivate.Content {}
    }
}
