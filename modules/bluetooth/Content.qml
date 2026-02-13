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
            text: "Bluetooth"
            color: Appearance.colors.text
            font.bold: true
            font.pixelSize: Appearance.font.xlarge
            Layout.fillWidth: true
        }

        // Adapter selector (if multiple adapters)
        Rectangle {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 25
            color: Appearance.colors.surfaceHighlight
            radius: Appearance.rounding.small
            visible: Bluetooth.adapters.length > 1

            Text {
                anchors.centerIn: parent
                text: (Bluetooth.defaultAdapter?.name ?? "Default").substring(0, 8) + "..."
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.tiny
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    const adapters = [...Bluetooth.adapters];
                    const currentIndex = adapters.indexOf(Bluetooth.defaultAdapter);
                    const nextIndex = (currentIndex + 1) % adapters.length;
                    Bluetooth.defaultAdapter = adapters[nextIndex];
                }
            }
        }

        // Power toggle
        Rectangle {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 25
            color: Bluetooth.enabled ? Appearance.colors.primaryContainer : Appearance.colors.secondary
            radius: Appearance.rounding.small

            Text {
                anchors.centerIn: parent
                text: Bluetooth.enabled ? "ON" : "OFF"
                color: Appearance.colors.background
                font.pixelSize: Appearance.font.small
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Bluetooth.toggle()
            }
        }

        // Scan toggle
        Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 25
            color: Bluetooth.scanning ? Appearance.colors.primary : Appearance.colors.surfaceHighlight
            radius: Appearance.rounding.small
            opacity: Bluetooth.enabled ? 1.0 : 0.5

            Text {
                anchors.centerIn: parent
                text: Bluetooth.scanning ? "Stop" : "Scan"
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.regular
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Bluetooth.toggleScanning()
            }
        }
    }

    // Device lists
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Appearance.spacing.medium

        // Paired devices section
        DeviceList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Paired Devices"
            emptyMessage: "No paired devices"
            deviceFilter: device => device && (device.paired || device.connected)
        }

        // Available devices section
        DeviceList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Available Devices"
            emptyMessage: "No devices found\nClick Scan to discover"
            deviceFilter: device => {
                return device && device.name && !Bluetooth.isNameMacAddress(device.name, device.address) && !device.paired && !device.connected;
            }
        }
    }
}
