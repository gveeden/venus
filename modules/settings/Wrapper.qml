import "../../config"
import Quickshell
import QtQuick
import "." as SettingsPrivate

Scope {
    id: root
    property alias visible: settingsWindow.visible

    function toggle(): void {
        settingsWindow.visible = !settingsWindow.visible
    }

    function close(): void {
        settingsWindow.visible = false
    }

    PanelWindow {
        id: settingsWindow
        visible: false

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        margins {
            top: Math.round((screen.height - SettingsConfig.windowHeight) / 2)
            bottom: Math.round((screen.height - SettingsConfig.windowHeight) / 2)
            left: Math.round((screen.width - SettingsConfig.windowWidth) / 2)
            right: Math.round((screen.width - SettingsConfig.windowWidth) / 2)
        }

        implicitWidth: SettingsConfig.windowWidth
        implicitHeight: SettingsConfig.windowHeight

        color: "transparent"

        // Background with radius
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            radius: Appearance.window.radius
            color: Qt.rgba(Appearance.colors.background.r, Appearance.colors.background.g, Appearance.colors.background.b, Appearance.window.opacity)
        }

        // Border
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Appearance.colors.windowBorder
            border.width: Appearance.window.borderThickness
            radius: Appearance.window.radius
        }

        SettingsPrivate.Content {
            id: content
            anchors.fill: parent
            anchors.leftMargin: Appearance.window.borderThickness
            anchors.rightMargin: Appearance.window.borderThickness
            anchors.topMargin: Appearance.window.borderThickness
            anchors.bottomMargin: Appearance.window.borderThickness
            onCloseClicked: root.close()
        }

        // Handle visibility changes
        onVisibleChanged: {
            if (!visible && content) {
                content.closeColorPickers()
            }
        }

        // Handle escape key at window level
        Keys.onEscapePressed: root.close()
    }
}
