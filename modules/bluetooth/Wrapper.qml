import "../../config"
import "../../services"
import Quickshell
import Quickshell.Hyprland
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

    HyprlandFocusGrab {
        active: bluetoothWindow.visible
        windows: [bluetoothWindow]
        onCleared: {
            bluetoothWindow.visible = false;
        }
    }

    PanelWindow {
        id: bluetoothWindow
        visible: false

        anchors {
            top: true
            right: true
        }

        margins {
            top: BluetoothConfig.topMargin
            right: BluetoothConfig.rightMargin
        }

        implicitWidth: BluetoothConfig.windowWidth
        implicitHeight: BluetoothConfig.windowHeight
        color: "transparent"

        // Background with radius
        Rectangle {
            anchors.fill: parent
            color: Appearance.colors.background
            radius: Appearance.window.radius
        }

        // Border
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Appearance.colors.windowBorder
            border.width: Appearance.window.borderThickness
            radius: Appearance.window.radius
        }

        BluetoothPrivate.Content {
            anchors.fill: parent
            anchors.margins: Appearance.window.borderThickness + 10
        }
    }
}
