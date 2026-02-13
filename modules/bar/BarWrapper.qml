import "../../config"
import Quickshell
import QtQuick

Scope {
    id: root
    property var bluetoothModule
    property var networksModule
    property var batteryModule
    property var calendarModule

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: BarConfig.height
            color: Appearance.colors.background

            Bar {
                bluetoothModule: root.bluetoothModule
                networksModule: root.networksModule
                batteryModule: root.batteryModule
                calendarModule: root.calendarModule
            }
        }
    }
}
