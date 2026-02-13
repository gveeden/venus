import "../../config"
import "../../services"
import "components"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    anchors.margins: Appearance.padding.xlarge
    spacing: Appearance.spacing.medium

    // Header with power and scan buttons
    RowLayout {
        Layout.fillWidth: true

        Text {
            text: "Networks"
            color: Appearance.colors.text
            font.bold: true
            font.pixelSize: Appearance.font.xlarge
            Layout.fillWidth: true
        }

        // Power toggle
        Rectangle {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 25
            color: Networks.enabled ? Appearance.colors.primaryContainer : Appearance.colors.secondary
            radius: Appearance.rounding.small

            Text {
                anchors.centerIn: parent
                text: Networks.enabled ? "ON" : "OFF"
                color: Appearance.colors.background
                font.pixelSize: Appearance.font.small
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Networks.toggle()
            }
        }

        // Scan toggle
        Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 25
            color: Networks.scanning ? Appearance.colors.primary : Appearance.colors.surfaceHighlight
            radius: Appearance.rounding.small
            opacity: Networks.enabled ? 1.0 : 0.5

            Text {
                anchors.centerIn: parent
                text: Networks.scanning ? "Scanning..." : "Scan"
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.tiny
            }

            MouseArea {
                anchors.fill: parent
                enabled: Networks.enabled
                onClicked: Networks.toggleScanning()
            }
        }
    }

    // Network lists
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Appearance.spacing.medium

        // Connected network section
        NetworkList {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.minimumHeight: 140
            title: "Connected"
            emptyMessage: "Not connected to any network"
            networkFilter: network => network && network.active
        }

        // Available networks section (includes saved networks at the top)
        NetworkList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Available Networks"
            emptyMessage: "No networks found\nClick Scan to discover"
            networkFilter: network => {
                return network && network.ssid && network.ssid.length > 0 && !network.active
            }
        }
    }

    // Password dialog overlay
    PasswordDialog {
        anchors.fill: parent
        z: 1000
    }
}
