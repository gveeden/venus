import "../../config"
import "../../services"
import "../../components/containers"
import Quickshell
import QtQuick
import "." as BluetoothPrivate

Scope {
    id: root
    property alias visible: bluetoothWindow.visible

    // Expose bluetooth state (for bar compatibility)
    property bool bluetoothReady: Bluetooth.ready
    property bool bluetoothEnabled: Bluetooth.enabled
    property string bluetoothStatus: Bluetooth.status
    property bool bluetoothScanning: Bluetooth.scanning

    // Public functions for timer control
    function startCloseTimer() {
        bluetoothWindow.startCloseTimer()
    }

    function stopCloseTimer() {
        bluetoothWindow.stopCloseTimer()
    }

    DropdownWindow {
        id: bluetoothWindow
        windowWidth: BluetoothConfig.windowWidth
        windowHeight: BluetoothConfig.windowHeight
        topMargin: BluetoothConfig.topMargin
        rightMargin: BluetoothConfig.rightMargin
        contentMargins: 10

        content: BluetoothPrivate.Content {}
    }
}
