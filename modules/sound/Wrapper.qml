import "../../config"
import "../../services"
import "../../components/containers"
import Quickshell
import QtQuick
import "." as SoundPrivate

Scope {
    id: root
    property alias visible: soundWindow.visible
    
    function startCloseTimer() {
        soundWindow.startCloseTimer()
    }
    
    function stopCloseTimer() {
        soundWindow.stopCloseTimer()
    }
    
    DropdownWindow {
        id: soundWindow
        windowWidth: SoundConfig.windowWidth
        windowHeight: SoundConfig.windowHeight
        topMargin: SoundConfig.topMargin
        rightMargin: SoundConfig.rightMargin
        contentMargins: 10
        
        content: SoundPrivate.Content {}
    }
}
