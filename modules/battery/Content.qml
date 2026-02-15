import "../../config"
import "../../services"
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    anchors.fill: parent
    anchors.margins: Appearance.padding.xlarge
    spacing: Appearance.spacing.medium

    // Header
    Text {
        text: "Battery Status"
        color: Appearance.colors.text
        font.pixelSize: Appearance.font.xlarge
        font.bold: true
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.colors.border
    }

    // Main battery section
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        Text {
            text: "Main Battery"
            color: Appearance.colors.primary
            font.pixelSize: Appearance.font.large
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.medium

            Text {
                text: UPower.displayDevice ? `${Math.round(UPower.displayDevice.percentage * 100)}%` : "No battery"
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.xlarge
                font.bold: true
            }

            Text {
                text: {
                    if (!UPower.displayDevice)
                        return "";
                    if (UPower.onBattery)
                        return "󱊣 Discharging";
                    return "󱊦 Charging";
                }
                color: UPower.onBattery ? Appearance.colors.secondary : Appearance.colors.primary
                font.pixelSize: Appearance.font.medium
            }
        }

        // Battery health bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            color: Appearance.colors.surfaceHighlight
            radius: Appearance.rounding.small

            Rectangle {
                width: parent.width * (UPower.displayDevice ? UPower.displayDevice.percentage : 0)
                height: parent.height
                color: {
                    if (!UPower.displayDevice)
                        return Appearance.colors.primary;
                    const percent = UPower.displayDevice.percentage * 100;
                    if (percent < 20)
                        return Appearance.colors.secondary;
                    if (percent < 50)
                        return "#FFA500";
                    return Appearance.colors.primary;
                }
                radius: parent.radius

                Behavior on width {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.colors.border
    }

    // Bluetooth devices section
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Appearance.spacing.small

        Text {
            text: "Bluetooth Devices"
            color: Appearance.colors.primary
            font.pixelSize: Appearance.font.large
            font.bold: true
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: btDevicesColumn.implicitHeight
            clip: true

            ColumnLayout {
                id: btDevicesColumn
                width: parent.width
                spacing: Appearance.spacing.small

                Repeater {
                    model: Bluetooth.devices

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: deviceLayout.implicitHeight + Appearance.spacing.medium * 2
                        color: Appearance.colors.surfaceHighlight
                        radius: Appearance.rounding.small
                        visible: modelData.paired

                        RowLayout {
                            id: deviceLayout
                            anchors.fill: parent
                            anchors.margins: Appearance.spacing.medium
                            spacing: Appearance.spacing.medium

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Appearance.spacing.tiny

                                Text {
                                    text: modelData.name || "Unknown Device"
                                    color: Appearance.colors.text
                                    font.pixelSize: Appearance.font.medium
                                    font.bold: true
                                }

                                Text {
                                    text: modelData.address
                                    color: Appearance.colors.textTertiary
                                    font.pixelSize: Appearance.font.tiny
                                }
                            }

                            ColumnLayout {
                                spacing: Appearance.spacing.tiny
                                Layout.alignment: Qt.AlignRight
                                visible: modelData.batteryAvailable

                                Text {
                                    text: Math.round(modelData.battery * 100) + "%"
                                    color: modelData.battery < 0.2 ? Appearance.colors.secondary : Appearance.colors.text
                                    font.pixelSize: Appearance.font.large
                                    font.bold: true
                                    Layout.alignment: Qt.AlignRight
                                }

                                Text {
                                    text: getBatteryIcon(modelData.battery)
                                    color: modelData.battery < 0.2 ? Appearance.colors.secondary : Appearance.colors.primary
                                    font.pixelSize: Appearance.font.medium
                                    Layout.alignment: Qt.AlignRight
                                }
                            }

                            Text {
                                visible: !modelData.batteryAvailable
                                text: "No battery info"
                                color: Appearance.colors.textTertiary
                                font.pixelSize: Appearance.font.small
                                Layout.alignment: Qt.AlignRight
                            }
                        }
                    }
                }

                // No devices message
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: "No paired bluetooth devices"
                    color: Appearance.colors.textTertiary
                    font.pixelSize: Appearance.font.medium
                    visible: !hasPairedDevices()
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
    function getBatteryIcon(level) {
        if (level >= 0.9)
            return "󰁹";
        if (level >= 0.7)
            return "󰂀";
        if (level >= 0.5)
            return "󰁾";
        if (level >= 0.3)
            return "󰁼";
        if (level >= 0.1)
            return "󰁺";
        return "󰂎";
    }

    function hasPairedDevices() {
        for (let i = 0; i < Bluetooth.devices.length; i++) {
            if (Bluetooth.devices[i].paired) {
                return true;
            }
        }
        return false;
    }
}
