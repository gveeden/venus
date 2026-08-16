import "../../config"
import "../../services"
import "../../components/controls"
import "components"
import QtQuick
import QtQuick.Layouts

Item {
    anchors.fill: parent

    // ── Main bluetooth panel ──────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.xlarge
        spacing: Appearance.spacing.medium
        visible: !BluetoothService.pairingPending

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
                visible: BluetoothService.adapters.length > 1

                Text {
                    anchors.centerIn: parent
                    text: (BluetoothService.defaultAdapter?.name ?? "Default").substring(0, 8) + "..."
                    color: Appearance.colors.text
                    font.pixelSize: Appearance.font.tiny
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        const adapters = [...BluetoothService.adapters];
                        const currentIndex = adapters.indexOf(BluetoothService.defaultAdapter);
                        const nextIndex = (currentIndex + 1) % adapters.length;
                        BluetoothService.defaultAdapter = adapters[nextIndex];
                    }
                }
            }

            // Power toggle
            Button {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 25
                text: BluetoothService.enabled ? "ON" : "OFF"
                fontSize: Appearance.font.small
                bold: true
                padding: 0
                onClicked: BluetoothService.toggle()
            }

            // Scan toggle
            Button {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 25
                text: BluetoothService.scanning ? "Stop" : "Scan"
                variant: "outline"
                fontSize: Appearance.font.regular
                padding: 0
                opacity: BluetoothService.enabled ? 1.0 : 0.5
                onClicked: BluetoothService.toggleScanning()
            }
        }

        // Device lists
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Appearance.spacing.medium

            // Connected devices section
            DeviceList {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Connected"
                emptyMessage: "No connected devices"
                deviceFilter: device => device && device.connected
            }

            // Available devices section — paired (disconnected) + nearby unpaired
            DeviceList {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Available Devices"
                emptyMessage: "No devices found\nClick Scan to discover"
                deviceFilter: device => {
                    if (!device) return false
                    if (device.connected) return false
                    // Always show paired/bonded devices (even if temporarily unnamed)
                    if (device.paired || device.bonded) return true
                    // Show unnamed devices while scanning — they may fill in a name shortly
                    if (!device.name) return BluetoothService.scanning
                    // Hide unpaired devices whose "name" is just their MAC address
                    return !BluetoothService.isNameMacAddress(device.name, device.address)
                }
            }
        }
    }

    // ── Passkey confirmation overlay ──────────────────────────────────────────
    // Shown when the Python agent intercepts a BlueZ RequestConfirmation call.
    Rectangle {
        anchors.fill: parent
        visible: BluetoothService.pairingPending
        color: Appearance.colors.surface
        radius: Appearance.rounding.medium

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Appearance.spacing.large

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Confirm Pairing"
                color: Appearance.colors.text
                font.bold: true
                font.pixelSize: Appearance.font.xlarge
                font.family: Appearance.font.family
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Make sure this code matches\nthe one shown on the device:"
                color: Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.regular
                font.family: Appearance.font.family
                horizontalAlignment: Text.AlignHCenter
            }

            // Passkey display
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 180
                Layout.preferredHeight: 64
                color: Appearance.colors.surfaceHighlight
                radius: Appearance.rounding.medium

                Text {
                    anchors.centerIn: parent
                    text: BluetoothService.pairingPasskey
                    color: Appearance.colors.primary
                    font.bold: true
                    font.pixelSize: 32
                    font.letterSpacing: 6
                    font.family: Appearance.font.family
                }
            }

            // Device identifier (human-readable from D-Bus path)
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: BluetoothService.pairingDevice
                    .split("/").pop()
                    .replace(/^dev_/i, "")
                    .replace(/_/g, ":")
                color: Appearance.colors.textTertiary
                font.pixelSize: Appearance.font.tiny
                font.family: Appearance.font.family
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Appearance.spacing.medium

                Button {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    text: "Reject"
                    variant: "outline"
                    fontSize: Appearance.font.regular
                    padding: 0
                    onClicked: BluetoothService.rejectPairing()
                }

                Button {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    text: "Confirm"
                    variant: "solid"
                    fontSize: Appearance.font.regular
                    padding: 0
                    onClicked: BluetoothService.confirmPairing()
                }
            }
        }
    }
}
