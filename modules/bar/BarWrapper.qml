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

    Variants {
        model: Quickshell.screens

        PanelWindow {
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
                bluetoothModule: root.bluetoothModule
                networksModule: root.networksModule
                batteryModule: root.batteryModule
                calendarModule: root.calendarModule
                soundModule: root.soundModule
            }
        }
    }
}
