import "../../config"
import "../../services"
import Quickshell
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root
    property alias visible: batteryWindow.visible

    HyprlandFocusGrab {
        active: batteryWindow.visible
        windows: [batteryWindow]
        onCleared: {
            batteryWindow.visible = false;
        }
    }

    PanelWindow {
        id: batteryWindow
        visible: false

        anchors {
            top: true
            right: true
        }

        margins {
            top: BatteryConfig.topMargin
            right: BatteryConfig.rightMargin
        }

        implicitWidth: BatteryConfig.windowWidth
        implicitHeight: BatteryConfig.windowHeight
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

        Content {
            anchors.fill: parent
            anchors.margins: Appearance.window.borderThickness + 10
        }
    }
}
