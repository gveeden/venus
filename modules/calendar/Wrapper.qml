import "../../config"
import Quickshell
import Quickshell.Hyprland
import QtQuick
import "." as CalendarPrivate

Scope {
    id: root
    property alias visible: calendarWindow.visible

    HyprlandFocusGrab {
        active: calendarWindow.visible
        windows: [calendarWindow]
        onCleared: {
            calendarWindow.visible = false
        }
    }

    PanelWindow {
        id: calendarWindow
        visible: false

        anchors {
            top: true
            right: true
        }

        margins {
            top: CalendarConfig.topMargin
            right: CalendarConfig.rightMargin
        }

        implicitWidth: CalendarConfig.windowWidth
        implicitHeight: CalendarConfig.windowHeight
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

        CalendarPrivate.Content {
            anchors.fill: parent
            anchors.margins: Appearance.window.borderThickness + 16
        }
    }
}
