import "../../config"
import "../../services"
import "../../components/containers"
import Quickshell
import QtQuick
import "." as NetworksPrivate

Scope {
    id: root
    property alias visible: networksWindow.visible

    // Expose network state (for bar compatibility)
    property bool networksReady: Networks.ready
    property bool networksEnabled: Networks.enabled
    property string networksStatus: Networks.status
    property bool networksScanning: Networks.scanning
    property var activeNetwork: Networks.activeNetwork

    // Public functions for timer control
    function startCloseTimer() {
        networksWindow.startCloseTimer()
    }

    function stopCloseTimer() {
        networksWindow.stopCloseTimer()
    }

    DropdownWindow {
        id: networksWindow
        windowWidth: NetworksConfig.windowWidth
        windowHeight: NetworksConfig.windowHeight
        topMargin: NetworksConfig.topMargin
        rightMargin: NetworksConfig.rightMargin
        contentMargins: 10

        content: NetworksPrivate.Content {}
    }
}
