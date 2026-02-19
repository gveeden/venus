import "../../../config"
import "../../../services"
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: Appearance.spacing.small

    property string title
    property string emptyMessage
    property var deviceFilter: device => true

    Text {
        text: root.title
        color: Appearance.colors.text
        font.pixelSize: Appearance.font.regular
        font.bold: true
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Appearance.colors.surface
        radius: Appearance.rounding.medium

        // Use BluetoothStore.mergedDevices so out-of-range paired devices
        // (loaded from the local JSON) are included alongside live devices.
        // Also depend on Bluetooth.devices directly so the list re-evaluates
        // whenever any live device property changes (connect, pair, etc.).
        property var filteredDevices: {
            // Explicitly touch Bluetooth.devices to create a reactive dependency
            // so this re-evaluates on any device-model change.
            void(Bluetooth.devices)
            return BluetoothStore.mergedDevices.filter(root.deviceFilter)
        }

        ListView {
            id: deviceList
            anchors.fill: parent
            anchors.margins: Appearance.spacing.small
            clip: true
            spacing: Appearance.spacing.small

            model: parent.filteredDevices.slice().sort((a, b) => {
                // Read through getters (which delegate to _live) so sort order
                // always reflects current connection/pair state.
                const aC = a.connected ? 1 : 0
                const bC = b.connected ? 1 : 0
                const aP = a.paired    ? 1 : 0
                const bP = b.paired    ? 1 : 0
                return (bC - aC) || (bP - aP) || (a.name ?? "").localeCompare(b.name ?? "")
            })

            delegate: Loader {
                id: loader
                property var deviceData: modelData
                width: deviceList.width
                active: deviceData !== null

                sourceComponent: DeviceItem {
                    device: loader.deviceData
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.emptyMessage
            color: Appearance.colors.textTertiary
            font.pixelSize: Appearance.font.small
            horizontalAlignment: Text.AlignHCenter
            visible: parent.filteredDevices.length === 0
        }
    }
}
