import "../../config"
import "../../services"
import Quickshell
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root
    property alias visible: networksWindow.visible

    // Expose network state (for bar compatibility)
    property bool networksReady: Networks.ready
    property bool networksEnabled: Networks.enabled
    property string networksStatus: Networks.status
    property bool networksScanning: Networks.scanning
    property var activeNetwork: Networks.activeNetwork

    HyprlandFocusGrab {
        active: networksWindow.visible
        windows: [networksWindow]
        onCleared: {
            networksWindow.visible = false
        }
    }

    PanelWindow {
        id: networksWindow
        visible: false

        anchors {
            top: true
            right: true
        }

        margins {
            top: NetworksConfig.topMargin
            right: NetworksConfig.rightMargin
        }

        implicitWidth: NetworksConfig.windowWidth
        implicitHeight: NetworksConfig.windowHeight
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
