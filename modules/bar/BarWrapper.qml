import "../../config"
import Quickshell
import QtQuick
import "." as BarPrivate

Scope {
    id: root
    property var bluetoothModule
    property var networksModule
    property var batteryModule
    property var calendarModule
    property var soundModule
    property var homeModule
    property var memoryModule

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData
            visible: true

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: BarConfig.height
            color: Appearance.colors.background

            BarPrivate.Bar {
                anchors.fill: parent
                bluetoothModule: root.bluetoothModule
                networksModule: root.networksModule
                batteryModule: root.batteryModule
                calendarModule: root.calendarModule
                soundModule: root.soundModule
                homeModule: root.homeModule
                memoryModule: root.memoryModule
                trayWindow: barWindow
            }
        }
    }
}
