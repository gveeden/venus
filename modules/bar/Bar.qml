import "../../components/widgets"
import "../../config"
import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "../../services"
import "components"

Item {
    id: root
    required property var bluetoothModule
    required property var networksModule
    required property var batteryModule
    required property var calendarModule
    required property var soundModule
    required property var homeModule
    required property var memoryModule
    required property PanelWindow trayWindow

    implicitWidth: layout.implicitWidth
    implicitHeight: BarConfig.height

    property int hoverDelay: 300
    property bool isExpanded: false

    HoverHandler {
        id: barHover
        onHoveredChanged: {
            if (!hovered) {
                root.isExpanded = false;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.RightButton
        hoverEnabled: true
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                settingsModule.currentTab = "bar";
                settingsModule.visible = true;
            }
        }
    }

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
        if (exceptModule !== homeModule) {
            homeHoverTimer.stop();
            homeModule.stopCloseTimer();
            homeModule.visible = false;
        }
        if (exceptModule !== memoryModule) {
            memoryHoverTimer.stop();
            memoryModule.stopCloseTimer();
            memoryModule.visible = false;
        }
    }

    // Timers
    Timer { id: networksHoverTimer; interval: root.hoverDelay; onTriggered: { networksModule.visible = true; networksModule.stopCloseTimer(); } }
    Timer { id: bluetoothHoverTimer; interval: root.hoverDelay; onTriggered: { bluetoothModule.visible = true; bluetoothModule.stopCloseTimer(); } }
    Timer { id: batteryHoverTimer; interval: root.hoverDelay; onTriggered: { batteryModule.visible = true; batteryModule.stopCloseTimer(); } }
    Timer { id: calendarHoverTimer; interval: root.hoverDelay; onTriggered: { calendarModule.visible = true; calendarModule.stopCloseTimer(); } }
    Timer { id: soundHoverTimer; interval: root.hoverDelay; onTriggered: { soundModule.visible = true; soundModule.stopCloseTimer(); } }
    Timer { id: homeHoverTimer; interval: root.hoverDelay; onTriggered: { homeModule.visible = true; homeModule.stopCloseTimer(); } }
    Timer { id: memoryHoverTimer; interval: root.hoverDelay; onTriggered: { memoryModule.visible = true; memoryModule.stopCloseTimer(); } }

    Component {
        id: trayComponent
        SystemTrayWidget {
            Layout.alignment: Qt.AlignVCenter
            trayWindow: root.trayWindow
        }
    }

        Component {
            id: memoryComponent
            Rectangle {
                implicitWidth: memoryWidget.implicitWidth
                height: BarConfig.height
                color: "transparent"

                MemoryWidget {
                    id: memoryWidget
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { root.hideOtherModals(memoryModule); memoryHoverTimer.start(); }
                    onExited: { memoryHoverTimer.stop(); memoryModule.startCloseTimer(); }
                    onClicked: { memoryHoverTimer.stop(); memoryModule.visible = !memoryModule.visible; }
                }
            }
        }

        Component {
            id: networkComponent
            Rectangle {
                implicitWidth: networkIcon.implicitWidth
                height: BarConfig.height
                color: "transparent"

                Text {
                    id: networkIcon
                    property int signalStrength: networksModule.activeNetwork?.strength ?? 0
                    property string signalIcon: {
                        if (!networksModule.networksEnabled) return "󰤭";
                        if (signalStrength >= 75) return "󰤨";
                        if (signalStrength >= 50) return "󰤥";
                        if (signalStrength >= 25) return "󰤢";
                        return "󰤟";
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
                    onEntered: { root.hideOtherModals(networksModule); networksHoverTimer.start(); }
                    onExited: { networksHoverTimer.stop(); networksModule.startCloseTimer(); }
                    onClicked: { networksHoverTimer.stop(); networksModule.visible = !networksModule.visible; }
                }
            }
        }

        Component {
            id: bluetoothComponent
            Rectangle {
                implicitWidth: bluetoothIcon.implicitWidth
                height: BarConfig.height
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
                    onEntered: { root.hideOtherModals(bluetoothModule); bluetoothHoverTimer.start(); }
                    onExited: { bluetoothHoverTimer.stop(); bluetoothModule.startCloseTimer(); }
                    onClicked: { bluetoothHoverTimer.stop(); bluetoothModule.visible = !bluetoothModule.visible; }
                }
            }
        }

        Component {
            id: soundComponent
            Rectangle {
                implicitWidth: soundIcon.implicitWidth
                height: BarConfig.height
                color: "transparent"

                Text {
                    id: soundIcon
                    property bool isMuted: Audio.isMuted
                    property string icon: isMuted ? "󰝟" : "󰕾"
                    text: icon
                    color: Audio.isMuted ? Appearance.colors.secondary : Appearance.colors.text
                    font.family: Appearance.font.family
                    font.pixelSize: BarConfig.fontSize
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { root.hideOtherModals(soundModule); soundHoverTimer.start(); }
                    onExited: { soundHoverTimer.stop(); soundModule.startCloseTimer(); }
                    onClicked: { soundHoverTimer.stop(); soundModule.visible = !soundModule.visible; }
                }
            }
        }

        Component {
            id: homeComponent
            Rectangle {
                implicitWidth: homeIcon.implicitWidth
                height: BarConfig.height
                color: "transparent"

                Text {
                    id: homeIcon
                    text: "󰛨"
                    color: Home.hasActiveLights ? Appearance.colors.primary : Appearance.colors.textTertiary
                    font.family: Appearance.font.family
                    font.pixelSize: BarConfig.fontSize
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { root.hideOtherModals(homeModule); homeHoverTimer.start(); }
                    onExited: { homeHoverTimer.stop(); homeModule.startCloseTimer(); }
                    onClicked: { homeHoverTimer.stop(); homeModule.visible = !homeModule.visible; }
                }
            }
        }

        Component {
            id: batteryComponent
            Rectangle {
                implicitWidth: batteryText.implicitWidth
                height: BarConfig.height
                color: "transparent"

                Text {
                    id: batteryText
                    property int batteryPercent: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) : 0
                    property string batteryIcon: {
                        if (!UPower.displayDevice) return "󰂑";
                        const state = UPower.displayDevice.state;
                        if (state === UPowerDeviceState.Charging || state === UPowerDeviceState.PendingCharge) return "󰂄";
                        if (state === UPowerDeviceState.FullyCharged) return "󰁹";
                        if (batteryPercent >= 90) return "󰁹";
                        if (batteryPercent >= 70) return "󰂀";
                        if (batteryPercent >= 50) return "󰁾";
                        if (batteryPercent >= 30) return "󰁼";
                        if (batteryPercent >= 10) return "󰁺";
                        return "󰂎";
                    }
                    text: batteryIcon + " " + (UPower.displayDevice ? `${batteryPercent}%` : "No battery")
                    color: {
                        if (!UPower.displayDevice) return Appearance.colors.textTertiary;
                        if (batteryPercent < 20) return Appearance.colors.secondary;
                        return Appearance.colors.text;
                    }
                    font.family: Appearance.font.family
                    font.pixelSize: BarConfig.fontSize
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { root.hideOtherModals(batteryModule); batteryHoverTimer.start(); }
                    onExited: { batteryHoverTimer.stop(); batteryModule.startCloseTimer(); }
                    onClicked: { batteryHoverTimer.stop(); batteryModule.visible = !batteryModule.visible; }
                }
            }
        }

        Component {
            id: clockComponent
            Rectangle {
                implicitWidth: clockWidget.implicitWidth
                height: BarConfig.height
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
                    onEntered: { root.hideOtherModals(calendarModule); }
                    onExited: { calendarModule.startCloseTimer(); }
                    onClicked: { calendarModule.visible = !calendarModule.visible; }
                }
            }
        }


    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: BarConfig.margins
        anchors.rightMargin: 6
        spacing: 20

        Timer {
            id: saveTimer
            interval: 500
            onTriggered: barOrderStorage.save()
        }

        // Helper for reordering
        function swapWidgets(fromId, toId) {
            var order = BarConfig.widgetOrder.slice(); // Create a copy
            var fromIndex = order.indexOf(fromId);
            var toIndex = order.indexOf(toId);
            
            if (fromIndex !== -1 && toIndex !== -1 && fromIndex !== toIndex) {
                // Swap elements
                var temp = order[fromIndex];
                order[fromIndex] = order[toIndex];
                order[toIndex] = temp;
                
                BarConfig.widgetOrder = order;
                saveTimer.restart();
            }
        }

        // Spacer to push widgets to the right
        Item {
            id: leftSpacer
            Layout.fillWidth: true
        }

        // Hidden widgets expander (Three Dots)
        Text {
            id: expander
            text: "󰇙"
            color: Appearance.colors.textTertiary
            font.family: Appearance.font.family
            font.pixelSize: BarConfig.fontSize
            visible: BarConfig.hiddenWidgets.length > 0
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: root.isExpanded = true
                onClicked: root.isExpanded = !root.isExpanded
            }
        }

        // Hidden widgets container
        RowLayout {
            id: hiddenContainer
            spacing: BarConfig.spacing
            clip: true
            visible: root.isExpanded || opacity > 0
            
            Layout.preferredWidth: root.isExpanded ? implicitWidth : 0
            opacity: root.isExpanded ? 1 : 0
            
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Repeater {
                model: BarConfig.hiddenWidgets
                delegate: WidgetWrapper {
                    widgetId: modelData
                    content: {
                        switch(modelData) {
                            case "tray": return trayComponent;
                            case "memory": return memoryComponent;
                            case "network": return networkComponent;
                            case "bluetooth": return bluetoothComponent;
                            case "sound": return soundComponent;
                            case "home": return homeComponent;
                            case "battery": return batteryComponent;
                            case "clock": return clockComponent;
                            default: return null;
                        }
                    }
                }
            }
        }

        // Visible widgets
        Repeater {
            model: BarConfig.widgetOrder
            delegate: WidgetWrapper {
                widgetId: modelData
                onMoved: (from, to) => layout.swapWidgets(from, to)
                content: {
                    switch(modelData) {
                        case "tray": return trayComponent;
                        case "memory": return memoryComponent;
                        case "network": return networkComponent;
                        case "bluetooth": return bluetoothComponent;
                        case "sound": return soundComponent;
                        case "home": return homeComponent;
                        case "battery": return batteryComponent;
                        case "clock": return clockComponent;
                        default: return null;
                    }
                }
            }
        }
    }
}
