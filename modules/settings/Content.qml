import "../../config"
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    color: Appearance.colors.background
    radius: Appearance.window.radius
    clip: true

    property string currentTab: "theme"
    signal closeClicked

    // Function to close all color pickers
    function closeColorPickers() {
        if (themeTab && themeTab.closeColorPickers) {
            themeTab.closeColorPickers();
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar with tabs - rounded corners on left only
        Rectangle {
            Layout.preferredWidth: SettingsConfig.sidebarWidth
            Layout.fillHeight: true
            color: Appearance.colors.surface
            radius: Appearance.window.radius
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                // Tab: Theme
                Rectangle {
                    Layout.fillWidth: true
                    height: SettingsConfig.tabHeight
                    radius: 6
                    color: root.currentTab === "theme" ? Appearance.colors.surfaceHighlight : "transparent"

                    Text {
                        text: "Theme"
                        color: root.currentTab === "theme" ? Appearance.colors.primary : Appearance.colors.text
                        font.pixelSize: 14
                        font.weight: root.currentTab === "theme" ? Font.Medium : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.currentTab = "theme"
                    }
                }
            }
            Rectangle {
                anchors.right: parent.right
                width: Appearance.window.borderThickness
                height: parent.height
                color: parent.color
            }
        }

        // Content area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Appearance.colors.background
            radius: Appearance.window.radius
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header with close button
                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    color: Appearance.colors.background
                    radius: Appearance.window.radius
                    clip: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 12

                        Text {
                            text: "Settings"
                            color: Appearance.colors.text
                            font.pixelSize: 18
                            font.weight: Font.Bold
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        // Close button
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 6
                            color: closeMouseArea.containsPress ? Appearance.colors.hover : (closeMouseArea.containsMouse ? Appearance.colors.surfaceHighlight : "transparent")

                            Text {
                                text: "x"
                                color: Appearance.colors.text
                                font.pixelSize: 20
                                font.weight: Font.Bold
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: closeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.closeClicked()
                            }
                        }
                    }
                }

                // Tab content
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Appearance.colors.background
                    radius: Appearance.window.radius
                    clip: true

                    ThemeTab {
                        id: themeTab
                        anchors.fill: parent
                        anchors.margins: 20
                        visible: root.currentTab === "theme"
                    }
                }
            }
        }
    }
}
