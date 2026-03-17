import "../../config"
import "../../components/containers"
import Quickshell
import QtQuick
import "." as MemoryPrivate

Scope {
    id: root
    property alias visible: memoryWindow.visible

    function startCloseTimer() {
        memoryWindow.startCloseTimer();
    }

    function stopCloseTimer() {
        memoryWindow.stopCloseTimer();
    }

    DropdownWindow {
        id: memoryWindow
        windowWidth: NetworksConfig.windowWidth
        windowHeight: NetworksConfig.windowHeight
        topMargin: NetworksConfig.topMargin
        rightMargin: NetworksConfig.rightMargin
        contentMargins: Appearance.padding.large
        
        content: MemoryPrivate.Content {}
    }
}
