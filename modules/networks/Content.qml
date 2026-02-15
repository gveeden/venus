import "../../config"
import "../../services"
import "../../components/controls"
import "components"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    anchors.fill: parent
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
