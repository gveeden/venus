import "../../config"
import "../../services"
import "../../components/controls"
import "components"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    anchors.fill: parent
    anchors.margins: Appearance.padding.xlarge
    spacing: Appearance.spacing.medium

    property string currentTab: "usage"

    // Header
    Text {
        text: "Network Status"
        color: Appearance.colors.text
        font.bold: true
        font.pixelSize: Appearance.font.xlarge
        Layout.fillWidth: true
    }

    // WiFi Controls and Status (Always Visible)
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "WiFi Management"
                color: Appearance.colors.primary
                font.pixelSize: Appearance.font.large
                font.bold: true
                Layout.fillWidth: true
            }

            // Power toggle
            Button {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 25
                text: Networks.enabled ? "ON" : "OFF"
                fontSize: Appearance.font.small
                bold: true
                padding: 0
                onClicked: Networks.toggle()
            }

            // Scan toggle
            Button {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 25
                text: Networks.scanning ? "Stop" : "Scan"
                variant: "outline"
                fontSize: Appearance.font.tiny
                padding: 0
                opacity: Networks.enabled ? 1.0 : 0.5
                enabled: Networks.enabled
                onClicked: Networks.toggleScanning()
            }
        }

        // Connected network section (Always Visible)
        NetworkList {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.minimumHeight: 100
            title: "Connected Network"
            emptyMessage: "WiFi Disconnected"
            networkFilter: network => network && network.active
        }
    }

    // Tab Switcher
    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small
        
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            color: currentTab === "usage" ? Appearance.colors.surfaceHighlight : "transparent"
            radius: Appearance.rounding.small
            border.color: currentTab === "usage" ? Appearance.colors.primary : "transparent"
            border.width: 1

            Text {
                text: "Usage"
                anchors.centerIn: parent
                color: currentTab === "usage" ? Appearance.colors.primary : Appearance.colors.text
                font.bold: currentTab === "usage"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: currentTab = "usage"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            color: currentTab === "wifi" ? Appearance.colors.surfaceHighlight : "transparent"
            radius: Appearance.rounding.small
            border.color: currentTab === "wifi" ? Appearance.colors.primary : "transparent"
            border.width: 1

            Text {
                text: "Available"
                anchors.centerIn: parent
                color: currentTab === "wifi" ? Appearance.colors.primary : Appearance.colors.text
                font.bold: currentTab === "wifi"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: currentTab = "wifi"
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.colors.border
    }

    // Tab Content: Usage
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Appearance.spacing.medium
        visible: currentTab === "usage"

        // Speed details section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            Text {
                text: "Bandwidth"
                color: Appearance.colors.primary
                font.pixelSize: Appearance.font.large
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.large

                ColumnLayout {
                    spacing: 2
                    Text { text: "Download"; color: Appearance.colors.textTertiary; font.pixelSize: Appearance.font.small }
                    Text { text: NetworkSpeed.downloadStr; color: Appearance.colors.text; font.pixelSize: Appearance.font.large; font.bold: true }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: "Upload"; color: Appearance.colors.textTertiary; font.pixelSize: Appearance.font.small }
                    Text { text: NetworkSpeed.uploadStr; color: Appearance.colors.text; font.pixelSize: Appearance.font.large; font.bold: true }
                }
            }
        }

        // Top processes section
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Appearance.spacing.small

            Text {
                text: "Active Network Apps"
                color: Appearance.colors.primary
                font.pixelSize: Appearance.font.large
                font.bold: true
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: topAppsColumn.implicitHeight
                clip: true

                ColumnLayout {
                    id: topAppsColumn
                    width: parent.width
                    spacing: Appearance.spacing.small

                    Repeater {
                        model: NetworkSpeed.topApps
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            color: Appearance.colors.surfaceHighlight
                            radius: Appearance.rounding.small

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Appearance.padding.medium
                                spacing: Appearance.spacing.medium

                            Text {
                                text: modelData.name
                                color: Appearance.colors.text
                                font.pixelSize: Appearance.font.medium
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            ColumnLayout {
                                spacing: 0
                                Layout.alignment: Qt.AlignRight
                                Text { text: "↑ " + modelData.up; color: Appearance.colors.textSecondary; font.pixelSize: Appearance.font.tiny; font.bold: true; horizontalAlignment: Text.AlignRight }
                                Text { text: "↓ " + modelData.down; color: Appearance.colors.primary; font.pixelSize: Appearance.font.tiny; font.bold: true; horizontalAlignment: Text.AlignRight }
                            }
                            }
                        }
                    }
                    
                    Text {
                        text: "No active network apps found"
                        color: Appearance.colors.textTertiary
                        font.pixelSize: Appearance.font.medium
                        visible: NetworkSpeed.topApps.length === 0
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    // Tab Content: WiFi
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Appearance.spacing.medium
        visible: currentTab === "wifi"

        // Available networks section
        NetworkList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            emptyMessage: "No networks found\nClick Scan to discover"
            networkFilter: network => {
                return network && network.ssid && network.ssid.length > 0 && !network.active;
            }
        }
    }

    // Password dialog overlay
    PasswordDialog {
        anchors.fill: parent
        z: 1000
    }
}
