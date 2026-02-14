import "../../../config"
import "../../../services"
import "../../../components/controls"
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var device

    readonly property bool loading: device && (device.state === BluetoothDeviceState.Connecting || device.state === BluetoothDeviceState.Disconnecting)
    readonly property bool connected: device && device.state === BluetoothDeviceState.Connected

    width: parent ? parent.width : 0
    height: 100
    color: connected ? Appearance.colors.surfaceHighlight : Appearance.colors.background
    radius: Appearance.rounding.small

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.spacing.medium
        spacing: Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true
            anchors.fill: parent

            // Device info column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width / 3
                spacing: Appearance.spacing.tiny

                Text {
                    text: root.device ? (root.device.name || "Unknown Device") : "Unknown"
                    color: Appearance.colors.text
                    font.pixelSize: Appearance.font.medium
                    font.bold: true
                }

                Text {
                    text: (root.device ? root.device.address : "") + (root.connected ? " (Connected)" : (root.device && root.device.paired) ? " (Paired)" : "")
                    color: Appearance.colors.textTertiary
                    font.pixelSize: Appearance.font.tiny
                }

                Text {
                    visible: root.device && root.device.batteryAvailable
                    text: "Battery: " + Math.round(root.device.battery * 100) + "%"
                    color: root.device && root.device.battery < 0.2 ? Appearance.colors.secondary : Appearance.colors.primaryContainer
                    font.pixelSize: Appearance.font.tiny
                }

                Text {
                    visible: root.device && (root.device.trusted || root.device.blocked)
                    text: (root.device.trusted ? "Trusted" : "") + (root.device.trusted && root.device.blocked ? " | " : "") + (root.device.blocked ? "Blocked" : "")
                    color: root.device.blocked ? Appearance.colors.secondary : Appearance.colors.primary
                    font.pixelSize: Appearance.font.tiny
                }
            }

            // Action buttons column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width / 3
                Layout.fillHeight: true
                spacing: Appearance.spacing.small
                Layout.alignment: Qt.AlignRight

                // Connect/Disconnect button
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    text: root.connected ? "Disconnect" : "Connect"
                    fontSize: Appearance.font.small
                    bold: true
                    padding: 0
                    loading: root.loading
                    variant: root.connected ? "outline" : "solid"
                    onClicked: {
                        if (root.device) {
                            if (root.connected) {
                                root.device.connected = false;
                            } else if (root.device.paired) {
                                root.device.connected = true;
                            } else {
                                root.device.pair();
                            }
                        }
                    }
                }

                // Pair/Forget button
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    text: (root.device && root.device.paired) ? "Forget" : "Pair"
                    variant: (root.device && root.device.paired) ? "ghost" : "outline"
                    fontSize: Appearance.font.small
                    padding: 0
                    visible: root.device && !root.connected
                    onClicked: {
                        if (root.device) {
                            if (root.device.paired) {
                                root.device.forget();
                            } else {
                                root.device.pair();
                            }
                        }
                    }
                }

                // Block button (only for unpaired devices)
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    text: "Block"
                    variant: "ghost"
                    fontSize: Appearance.font.small
                    padding: 0
                    visible: root.device && !root.device.paired
                    onClicked: Bluetooth.toggleDeviceBlock(root.device)
                }
            }
        }
    }
}
