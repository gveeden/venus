import "../../config"
import Quickshell
import QtQuick
import "." as SettingsPrivate

Scope {
    id: root
    property bool visible: false
    property string currentTab: "general"
    property var targetScreen: null

    onVisibleChanged: {
        if (!visible) {
            targetScreen = null;
        }
    }

    function toggle(): void {
        visible = !visible
    }

    function close(): void {
        visible = false
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: settingsWindow
                required property var modelData
                screen: modelData
                visible: root.visible && (modelData === root.targetScreen)

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                margins {
                    top: screen ? Math.round((screen.height - SettingsConfig.windowHeight) / 2) : 0
                    bottom: screen ? Math.round((screen.height - SettingsConfig.windowHeight) / 2) : 0
                    left: screen ? Math.round((screen.width - SettingsConfig.windowWidth) / 2) : 0
                    right: screen ? Math.round((screen.width - SettingsConfig.windowWidth) / 2) : 0
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
                    currentTab: root.currentTab
                    onCurrentTabChanged: root.currentTab = currentTab
                }

                // Handle visibility changes
                onVisibleChanged: {
                    if (!visible && (modelData === root.targetScreen)) {
                        root.visible = false;
                    }
                    if (!visible && content) {
                        content.closeColorPickers()
                    }
                }

                // Handle escape key at window level
                Keys.onEscapePressed: root.close()
            }
        }
    }
}
