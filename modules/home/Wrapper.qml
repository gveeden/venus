import "../../config"
import "../../services"
import "../../components/containers"
import Quickshell
import QtQuick
import "." as HomePrivate

Scope {
    id: root
    property alias visible: homeWindow.visible
    
    // Check if any popup is open to prevent auto-closing
    property bool isPopupOpen: false

    function startCloseTimer() {
        if (!isPopupOpen) homeWindow.startCloseTimer()
    }

    function stopCloseTimer() {
        homeWindow.stopCloseTimer()
    }

    DropdownWindow {
        id: homeWindow
        inhibitClose: root.isPopupOpen
        windowWidth: 380
        windowHeight: root.isPopupOpen ? 600 : (lightDetailVisible ? 550 : 350)
        topMargin: BarConfig.height
        rightMargin: 10
        contentMargins: 10
        
        property bool lightDetailVisible: false

        content: HomePrivate.Content {
            onPopupOpened: root.isPopupOpen = true
            onPopupClosed: root.isPopupOpen = false
            onDetailVisibleChanged: visible => homeWindow.lightDetailVisible = visible
        }
    }
}
