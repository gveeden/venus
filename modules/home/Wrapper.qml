import "../../config"
import "../../services"
import "../../components/containers"
import Quickshell
import QtQuick
import "." as HomePrivate

Scope {
    id: root
    property alias visible: homeWindow.visible

    function startCloseTimer() {
        homeWindow.startCloseTimer()
    }

    function stopCloseTimer() {
        homeWindow.stopCloseTimer()
    }

    DropdownWindow {
        id: homeWindow
        windowWidth: 350
        windowHeight: 300
        topMargin: BarConfig.height
        rightMargin: 10
        contentMargins: 10
        xMargin: 10
        yMargin: 10

        content: HomePrivate.Content {}
    }
}
