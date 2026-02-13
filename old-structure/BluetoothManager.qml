import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland

Scope {
    id: bm
    property alias visible: bluetoothWindow.visible
    property bool bluetoothReady: Bluetooth.defaultAdapter !== null
    property bool bluetoothEnabled: Bluetooth.defaultAdapter?.enabled ?? false
    property string bluetoothStatus: bluetoothEnabled ? "On" : "Off"
    property bool bluetoothScanning: Bluetooth.defaultAdapter?.discovering ?? false

    // Theme colors
    readonly property var colors: ({
            background: "#1e1e2e",
            surface: "#181825",
            surfaceHighlight: "#313244",
            text: "#cdd6f4",
            textSecondary: "#6c7086",
            primary: "#89b4fa",
            primaryContainer: "#a6e3a1",
            secondary: "#f38ba8",
            secondaryContainer: "#fab387",
            onPrimary: "#1e1e2e",
            onSecondary: "#1e1e2e"
        })

    // Native Bluetooth adapter control
    function toggleBluetoothPower() {
        const adapter = Bluetooth.defaultAdapter;
        if (adapter) {
            adapter.enabled = !adapter.enabled;
        }
    }

    function toggleBluetoothScanning() {
        const adapter = Bluetooth.defaultAdapter;
        if (adapter) {
            adapter.discovering = !adapter.discovering;
        }
    }

    // Device management functions
    function toggleDeviceTrust(device) {
        if (device) {
            device.trusted = !device.trusted;
        }
    }

    function toggleDeviceBlock(device) {
        if (device) {
            device.blocked = !device.blocked;
        }
    }

    function renameDevice(device, newName) {
        if (device && newName) {
            device.name = newName;
        }
    }

    // Check if device name is just a MAC address
    function isNameMacAddress(name, address) {
        if (!name || !address)
            return true;
        // Check if name matches MAC address pattern or is very similar
        const macPattern = /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/i;
        if (macPattern.test(name))
            return true;
        // Also check if name is just the address with different separators
        const cleanName = name.replace(/[:-]/g, '').toUpperCase();
        const cleanAddr = address.replace(/[:-]/g, '').toUpperCase();
        return cleanName === cleanAddr;
    }

    HyprlandFocusGrab {
        active: bluetoothWindow.visible
        windows: [bluetoothWindow]
        onCleared: {
            console.log("Bluetooth window focus cleared - closing");
            bluetoothWindow.visible = false;
        }
    }

    PanelWindow {
        id: bluetoothWindow
        visible: bm.bluetoothReady && false // Only show when adapter exists and toggled from bar

        anchors {
            top: true
            right: true
        }
        margins {
            top: 45
            right: 100
        } // Position it under the bar

        implicitWidth: 350
        implicitHeight: 650
        color: bm.colors.background

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            // Header with power and scan buttons
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Bluetooth"
                    color: bm.colors.text
                    font.bold: true
                    font.pixelSize: 16
                    Layout.fillWidth: true
                }

                // Adapter selector (if multiple adapters)
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 25
                    color: bm.colors.surfaceHighlight
                    radius: 5
                    visible: Bluetooth.adapters.length > 1

                    Text {
                        anchors.centerIn: parent
                        text: (Bluetooth.defaultAdapter?.name ?? "Default").substring(0, 8) + "..."
                        color: bm.colors.text
                        font.pixelSize: 10
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Cycle through adapters
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
                    color: bm.bluetoothEnabled ? bm.colors.primaryContainer : bm.colors.secondary
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: bm.bluetoothEnabled ? "ON" : "OFF"
                        color: bm.colors.background
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: bm.toggleBluetoothPower()
                    }
                }

                // Scan toggle
                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    color: bm.bluetoothScanning ? bm.colors.primary : colors.surfaceHighlight
                    radius: 5
                    opacity: bm.bluetoothEnabled ? 1.0 : 0.5

                    Text {
                        anchors.centerIn: parent
                        text: bm.bluetoothScanning ? "Stop" : "Scan"
                        color: bm.colors.text
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: bm.toggleBluetoothScanning()
                    }
                }
            }

            // Device lists
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                // Paired devices section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5

                    Text {
                        text: "Paired Devices"
                        color: bm.colors.text
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: bm.colors.surface
                        radius: 8

                        ListView {
                            id: pairedDeviceList
                            anchors.fill: parent
                            anchors.margins: 5
                            clip: true
                            spacing: 5

                            model: [...Bluetooth.devices.values].sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))

                            delegate: Component {
                                Loader {
                                    id: loader
                                    property var deviceData: modelData
                                    active: deviceData && (deviceData.paired || deviceData.connected)
                                    visible: active
                                    width: pairedDeviceList.width

                                    sourceComponent: deviceDelegate

                                    onLoaded: {
                                        if (item)
                                            item.modelData = deviceData;
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "No paired devices"
                            color: bm.colors.textSecondary
                            font.pixelSize: 11
                            visible: pairedDeviceList.count === 0
                        }
                    }
                }

                // Available devices section (unpaired, recently scanned)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5

                    Text {
                        text: "Available Devices"
                        color: bm.colors.text
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: bm.colors.surface
                        radius: 8

                        ListView {
                            id: availableDeviceList
                            anchors.fill: parent
                            anchors.margins: 5
                            clip: true
                            spacing: 5

                            model: [...Bluetooth.devices.values].filter(device => device.name && !isNameMacAddress(device.name, device.address) && !device.paired && !device.connected).sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))

                            delegate: Component {
                                Loader {
                                    id: loader
                                    property var deviceData: modelData
                                    width: availableDeviceList.width

                                    sourceComponent: deviceDelegate

                                    onLoaded: {
                                        if (item)
                                            item.modelData = deviceData;
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "No devices found\nClick Scan to discover"
                            color: bm.colors.textSecondary
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            visible: availableDeviceList.count === 0
                        }
                    }
                }
            }

            // Shared device delegate component
            Component {
                id: deviceDelegate

                Rectangle {
                    property var modelData
                    readonly property bool loading: modelData && (modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting)
                    readonly property bool connected: modelData && modelData.state === BluetoothDeviceState.Connected

                    width: parent ? parent.width : 0
                    height: 100
                    color: connected ? colors.surfaceHighlight : colors.background
                    radius: 5

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        RowLayout {
                            Layout.fillWidth: true
                            anchors.fill: parent

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.maximumWidth: parent.width / 3
                                spacing: 2

                                Text {
                                    text: modelData ? (modelData.name || "Unknown Device") : "Unknown"
                                    color: colors.text
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    text: (modelData ? modelData.address : "") + (connected ? " (Connected)" : (modelData && modelData.paired) ? " (Paired)" : "")
                                    color: colors.textSecondary
                                    font.pixelSize: 10
                                }

                                Text {
                                    visible: modelData && modelData.batteryAvailable
                                    text: "Battery: " + Math.round(modelData.battery * 100) + "%"
                                    color: modelData && modelData.battery < 0.2 ? colors.secondary : colors.primaryContainer
                                    font.pixelSize: 10
                                }

                                Text {
                                    visible: modelData && (modelData.trusted || modelData.blocked)
                                    text: (modelData.trusted ? "Trusted" : "") + (modelData.trusted && modelData.blocked ? " | " : "") + (modelData.blocked ? "Blocked" : "")
                                    color: modelData.blocked ? colors.secondary : colors.primary
                                    font.pixelSize: 10
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.maximumWidth: parent.width / 3
                                Layout.fillHeight: true
                                spacing: 5
                                Layout.alignment: Qt.AlignRight

                                // Connect/Disconnect button
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 22
                                    color: connected ? bm.colors.secondary : colors.primaryContainer
                                    radius: 4

                                    Text {
                                        anchors.centerIn: parent
                                        text: loading ? "Loading..." : (connected ? "Disconnect" : "Connect")
                                        color: bm.colors.background
                                        font.pixelSize: 11
                                        font.bold: true
                                        visible: !loading
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "transparent"
                                        visible: loading

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: bm.colors.background

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 12
                                                height: 12
                                                radius: 6
                                                color: bm.colors.secondary

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
                                        enabled: !loading
                                        onClicked: {
                                            if (modelData) {
                                                if (connected) {
                                                    modelData.connected = false;
                                                } else if (modelData.paired) {
                                                    modelData.connected = true;
                                                } else {
                                                    modelData.pair();
                                                }
                                            }
                                        }
                                    }
                                }

                                // Pair/Forget button
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 22
                                    color: (modelData && modelData.paired) ? bm.colors.surfaceHighlight : colors.primary
                                    radius: 4
                                    visible: modelData && !connected

                                    Text {
                                        anchors.centerIn: parent
                                        text: (modelData && modelData.paired) ? "Forget" : "Pair"
                                        color: bm.colors.text
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: if (modelData) {
                                            if (modelData.paired) {
                                                modelData.forget();
                                            } else {
                                                modelData.pair();
                                            }
                                        }
                                    }
                                }

                                // Block button (only for unpaired devices)
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 22
                                    color: modelData && modelData.blocked ? bm.colors.secondary : colors.surfaceHighlight
                                    radius: 3
                                    visible: modelData && !modelData.paired

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Block"
                                        color: modelData && modelData.blocked ? bm.colors.textSecondary : colors.text
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: toggleDeviceBlock(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
