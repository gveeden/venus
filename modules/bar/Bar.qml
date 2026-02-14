import "../../components/widgets"
import "../../config"
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "../../services"

RowLayout {
    required property var bluetoothModule
    required property var networksModule
    required property var batteryModule
    required property var calendarModule

    anchors.fill: parent
    anchors.leftMargin: BarConfig.margins
    anchors.rightMargin: BarConfig.margins
    spacing: BarConfig.spacing

    // Spacer to push widgets to the right
    Item {
        Layout.fillWidth: true
    }

    // Network status indicator
    Rectangle {
        Layout.preferredWidth: networkIcon.implicitWidth + BarConfig.margins
        Layout.preferredHeight: BarConfig.height
        color: "transparent"

        Text {
            id: networkIcon
            property int signalStrength: networksModule.activeNetwork?.strength ?? 0
            property string signalIcon: {
                if (!networksModule.networksEnabled)
                    return "󰤭";  // WiFi off
                if (signalStrength >= 75)
                    return "󰤨";  // Excellent
                if (signalStrength >= 50)
                    return "󰤥";  // Good
                if (signalStrength >= 25)
                    return "󰤢";  // Fair
                return "󰤟";  // Weak
            }

            text: signalIcon
            color: networksModule.networksEnabled && networksModule.activeNetwork ? Appearance.colors.primary : Appearance.colors.textTertiary
            font.family: Appearance.font.family
            font.pixelSize: BarConfig.fontSize
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: networksModule.visible = !networksModule.visible
        }
    }

    // Bluetooth status indicator
    Rectangle {
        Layout.preferredWidth: bluetoothIcon.implicitWidth + BarConfig.margins
        Layout.preferredHeight: BarConfig.height
        color: "transparent"

        Text {
            id: bluetoothIcon
            text: "󰂯"
            color: bluetoothModule.bluetoothEnabled ? Appearance.colors.primary : Appearance.colors.textTertiary
            font.family: Appearance.font.family
            font.pixelSize: BarConfig.fontSize
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: bluetoothModule.visible = !bluetoothModule.visible
        }
    }

    // Battery indicator
    Rectangle {
        Layout.preferredWidth: batteryText.implicitWidth + BarConfig.margins
        Layout.preferredHeight: BarConfig.height
        color: "transparent"

        Text {
            id: batteryText
            property int batteryPercent: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) : 0
            property string batteryIcon: {
                if (!UPower.displayDevice)
                    return "󰂑";
                if (UPower.onBattery) {
                    if (batteryPercent >= 90)
                        return "󰁹";
                    if (batteryPercent >= 70)
                        return "󰂀";
                    if (batteryPercent >= 50)
                        return "󰁾";
                    if (batteryPercent >= 30)
                        return "󰁼";
                    if (batteryPercent >= 10)
                        return "󰁺";
                    return "󰂎";
                } else {
                    return "󰂄";  // Charging icon
                }
            }

            text: batteryIcon + " " + (UPower.displayDevice ? `${batteryPercent}%` : "No battery")
            color: {
                if (!UPower.displayDevice)
                    return Appearance.colors.textTertiary;
                if (batteryPercent < 20)
                    return Appearance.colors.secondary;
                return Appearance.colors.text;
            }
            font.family: Appearance.font.family
            font.pixelSize: BarConfig.fontSize
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: batteryModule.visible = !batteryModule.visible
        }
    }

    // Clock
    Rectangle {
        Layout.preferredWidth: clockWidget.implicitWidth + BarConfig.margins
        Layout.preferredHeight: BarConfig.height
        color: "transparent"

        ClockWidget {
            id: clockWidget
            fontSize: BarConfig.fontSize
            timeText: Time.fullStr
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: calendarModule.visible = !calendarModule.visible
        }
    }
}
