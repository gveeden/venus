import "../../../config"
import "../../../services"
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var device

    readonly property bool loading: device && (
        device.state === BluetoothDeviceState.Connecting 
        || device.state === BluetoothDeviceState.Disconnecting
    )
    readonly property bool connected: device && device.state === BluetoothDeviceState.Connected

    width: parent ? parent.width : 0
    height: 100
    color: connected 
        ? Appearance.colors.surfaceHighlight 
        : Appearance.colors.background
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
                    text: (root.device ? root.device.address : "") 
                        + (root.connected ? " (Connected)" : (root.device && root.device.paired) ? " (Paired)" : "")
                    color: Appearance.colors.textTertiary
                    font.pixelSize: Appearance.font.tiny
                }

                Text {
                    visible: root.device && root.device.batteryAvailable
                    text: "Battery: " + Math.round(root.device.battery * 100) + "%"
                    color: root.device && root.device.battery < 0.2 
                        ? Appearance.colors.secondary 
                        : Appearance.colors.primaryContainer
                    font.pixelSize: Appearance.font.tiny
                }

                Text {
                    visible: root.device && (root.device.trusted || root.device.blocked)
                    text: (root.device.trusted ? "Trusted" : "") 
                        + (root.device.trusted && root.device.blocked ? " | " : "") 
                        + (root.device.blocked ? "Blocked" : "")
                    color: root.device.blocked 
                        ? Appearance.colors.secondary 
                        : Appearance.colors.primary
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
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    color: root.connected 
                        ? Appearance.colors.secondary 
                        : Appearance.colors.primaryContainer
                    radius: Appearance.rounding.small

                    Text {
                        anchors.centerIn: parent
                        text: root.loading ? "Loading..." : (root.connected ? "Disconnect" : "Connect")
                        color: Appearance.colors.background
                        font.pixelSize: Appearance.font.small
                        font.bold: true
                        visible: !root.loading
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        visible: root.loading

                        Rectangle {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            radius: 8
                            color: Appearance.colors.background

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 6
                                color: Appearance.colors.secondary

                                RotationAnimation on rotation {
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !root.loading
                        onClicked: {
                            if (root.device) {
                                if (root.connected) {
                                    root.device.connected = false
                                } else if (root.device.paired) {
                                    root.device.connected = true
                                } else {
                                    root.device.pair()
                                }
                            }
                        }
                    }
                }

                // Pair/Forget button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    color: (root.device && root.device.paired) 
                        ? Appearance.colors.surfaceHighlight 
                        : Appearance.colors.primary
                    radius: Appearance.rounding.small
                    visible: root.device && !root.connected

                    Text {
                        anchors.centerIn: parent
                        text: (root.device && root.device.paired) ? "Forget" : "Pair"
                        color: Appearance.colors.text
                        font.pixelSize: Appearance.font.small
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.device) {
                                if (root.device.paired) {
                                    root.device.forget()
                                } else {
                                    root.device.pair()
                                }
                            }
                        }
                    }
                }

                // Block button (only for unpaired devices)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    color: root.device && root.device.blocked 
                        ? Appearance.colors.secondary 
                        : Appearance.colors.surfaceHighlight
                    radius: Appearance.rounding.small
                    visible: root.device && !root.device.paired

                    Text {
                        anchors.centerIn: parent
                        text: "Block"
                        color: root.device && root.device.blocked 
                            ? Appearance.colors.textTertiary 
                            : Appearance.colors.text
                        font.pixelSize: Appearance.font.small
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Bluetooth.toggleDeviceBlock(root.device)
                    }
                }
            }
        }
    }
}
