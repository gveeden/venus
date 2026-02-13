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

        ListView {
            id: deviceList
            anchors.fill: parent
            anchors.margins: Appearance.spacing.small
            clip: true
            spacing: Appearance.spacing.small

            model: [...Bluetooth.devices.values]
                .filter(root.deviceFilter)
                .sort((a, b) => {
                    return (b.connected - a.connected) 
                        || (b.paired - a.paired) 
                        || a.name.localeCompare(b.name)
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
            visible: deviceList.count === 0
        }
    }
}
