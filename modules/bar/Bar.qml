import "../../components/widgets"
import "../../config"
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "../../services"

RowLayout {
    id: root
    required property var bluetoothModule
    required property var networksModule
    required property var batteryModule
    required property var calendarModule
    required property var soundModule

    property int hoverDelay: 300

    function hideOtherModals(exceptModule) {
        if (exceptModule !== networksModule) {
            networksHoverTimer.stop();
            networksModule.stopCloseTimer();
            networksModule.visible = false;
        }
        if (exceptModule !== bluetoothModule) {
            bluetoothHoverTimer.stop();
            bluetoothModule.stopCloseTimer();
            bluetoothModule.visible = false;
        }
        if (exceptModule !== batteryModule) {
            batteryHoverTimer.stop();
            batteryModule.stopCloseTimer();
            batteryModule.visible = false;
        }
        if (exceptModule !== calendarModule) {
            calendarHoverTimer.stop();
            calendarModule.stopCloseTimer();
            calendarModule.visible = false;
        }
        if (exceptModule !== soundModule) {
            soundHoverTimer.stop();
            soundModule.stopCloseTimer();
            soundModule.visible = false;
        }
    }

    Timer {
        id: networksHoverTimer
        interval: root.hoverDelay
        onTriggered: {
            networksModule.visible = true;
            networksModule.stopCloseTimer();
        }
    }
    Timer {
        id: bluetoothHoverTimer
        interval: root.hoverDelay
        onTriggered: {
            bluetoothModule.visible = true;
            bluetoothModule.stopCloseTimer();
        }
    }
    Timer {
        id: batteryHoverTimer
        interval: root.hoverDelay
        onTriggered: {
            batteryModule.visible = true;
            batteryModule.stopCloseTimer();
        }
    }
    Timer {
        id: calendarHoverTimer
        interval: root.hoverDelay
        onTriggered: {
            calendarModule.visible = true;
            calendarModule.stopCloseTimer();
        }
    }
    Timer {
        id: soundHoverTimer
        interval: root.hoverDelay
        onTriggered: {
            soundModule.visible = true;
            soundModule.stopCloseTimer();
        }
    }

    anchors.fill: parent
    anchors.leftMargin: BarConfig.margins
    anchors.rightMargin: BarConfig.margins
    spacing: BarConfig.spacing

    // Spacer to push widgets to the right
    Item {
        Layout.fillWidth: true
    }

    // Network upload/download speed indicator
    NetworkSpeedWidget {
        Layout.alignment: Qt.AlignVCenter
        fontSize: BarConfig.fontSize - 3
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
            hoverEnabled: true
            onEntered: {
                root.hideOtherModals(networksModule);
                networksHoverTimer.start();
            }
            onExited: {
                networksHoverTimer.stop();
                networksModule.startCloseTimer();
            }
            onClicked: {
                networksHoverTimer.stop();
                networksModule.visible = !networksModule.visible;
            }
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
            hoverEnabled: true
            onEntered: {
                root.hideOtherModals(bluetoothModule);
                bluetoothHoverTimer.start();
            }
            onExited: {
                bluetoothHoverTimer.stop();
                bluetoothModule.startCloseTimer();
            }
            onClicked: {
                bluetoothHoverTimer.stop();
                bluetoothModule.visible = !bluetoothModule.visible;
            }
        }
    }

    // Sound indicator
    Rectangle {
        Layout.preferredWidth: soundIcon.implicitWidth + BarConfig.margins
        Layout.preferredHeight: BarConfig.height
        color: "transparent"

        Text {
            id: soundIcon
            property bool isMuted: Audio.isMuted
            property string icon: {
                if (isMuted)
                    return "󰝟";
                return "󰕾";
            }
            text: icon
            color: Audio.isMuted ? Appearance.colors.secondary : Appearance.colors.text
            font.family: Appearance.font.family
            font.pixelSize: BarConfig.fontSize
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                root.hideOtherModals(soundModule);
                soundHoverTimer.start();
            }
            onExited: {
                soundHoverTimer.stop();
                soundModule.startCloseTimer();
            }
            onClicked: {
                soundHoverTimer.stop();
                soundModule.visible = !soundModule.visible;
            }
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
            hoverEnabled: true
            onEntered: {
                root.hideOtherModals(batteryModule);
                batteryHoverTimer.start();
            }
            onExited: {
                batteryHoverTimer.stop();
                batteryModule.startCloseTimer();
            }
            onClicked: {
                batteryHoverTimer.stop();
                batteryModule.visible = !batteryModule.visible;
            }
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
            hoverEnabled: true
            onEntered: {
                root.hideOtherModals(calendarModule);
                calendarHoverTimer.start();
            }
            onExited: {
                calendarHoverTimer.stop();
                calendarModule.startCloseTimer();
            }
            onClicked: {
                calendarHoverTimer.stop();
                calendarModule.visible = !calendarModule.visible;
            }
        }
    }
}
