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
        id: listContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Appearance.colors.surface
        radius: Appearance.rounding.medium

        // Live devices that match the filter
        readonly property var filteredLiveDevices: {
            void(BluetoothStore.listUpdateTrigger)
            void(BluetoothService.scanning)
            if (!Bluetooth.devices) return []
            const list = [...Bluetooth.devices.values]
            return list.filter(function(d) {
                return !!d && root.deviceFilter(d)
            })
        }

        // Offline paired devices that are currently out of BlueZ's D-Bus tree.
        readonly property var offlineDevices: {
            void(BluetoothStore.listUpdateTrigger)
            void(BluetoothService.scanning)
            if (!Bluetooth.devices) return []
            const liveAddrs = {}
            const live = [...Bluetooth.devices.values]
            for (let i = 0; i < live.length; i++) {
                if (live[i]) liveAddrs[live[i].address] = true
            }
            return BluetoothStore.storedDevices.filter(function(s) {
                if (!s.paired || liveAddrs[s.address]) return false
                return root.deviceFilter({
                    address:   s.address,
                    name:      s.name,
                    icon:      s.icon,
                    paired:    true,
                    bonded:    s.bonded ?? false,
                    connected: false,
                    isOffline: true
                })
            })
        }

        readonly property int totalCount: filteredLiveDevices.length + offlineDevices.length

        Flickable {
            anchors.fill: parent
            anchors.margins: Appearance.spacing.small
            clip: true
            contentWidth: width
            contentHeight: innerColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: innerColumn
                width: parent.width
                spacing: Appearance.spacing.small

                // ── Live devices ─────────────────────────────────────────────
                Repeater {
                    model: listContainer.filteredLiveDevices

                    delegate: DeviceItem {
                        required property var modelData
                        width: innerColumn.width
                        device: modelData
                    }
                }

                // ── Offline stored devices ────────────────────────────────────
                Repeater {
                    model: listContainer.offlineDevices

                    delegate: DeviceItem {
                        required property var modelData
                        width: innerColumn.width
                        device: modelData  // plain JS record, isOffline: true
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.emptyMessage
            color: Appearance.colors.textTertiary
            font.pixelSize: Appearance.font.small
            horizontalAlignment: Text.AlignHCenter
            visible: listContainer.totalCount === 0
        }
    }
}
