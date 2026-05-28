import "../../config"
import "../../services"
import "../../components/containers"
import Quickshell
import QtQuick
import "." as WeatherPrivate

Scope {
    id: root
    property alias visible: weatherWindow.visible

    // Public functions for timer control
    function startCloseTimer() {
        weatherWindow.startCloseTimer()
    }

    function stopCloseTimer() {
        weatherWindow.stopCloseTimer()
    }

    DropdownWindow {
        id: weatherWindow
        windowWidth: WConfig.windowWidth
        windowHeight: WConfig.windowHeight
        topMargin: WConfig.topMargin
        rightMargin: WConfig.rightMargin
        contentMargins: 10

        content: WeatherPrivate.Content {}
    }
}
