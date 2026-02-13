import "../../../config"
import "../../../services"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: Appearance.spacing.small

    property string title
    property string emptyMessage
    property var networkFilter: network => true

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
            id: networkList
            anchors.fill: parent
            anchors.margins: Appearance.spacing.small
            clip: true
            spacing: Appearance.spacing.small

            model: [...Networks.networks]
                .filter(root.networkFilter)
                .sort((a, b) => {
                    // First sort by active status
                    if (a.active !== b.active) {
                        return b.active - a.active
                    }
                    // Then by saved status (saved networks first)
                    const aSaved = Networks.hasSavedProfile(a.ssid)
                    const bSaved = Networks.hasSavedProfile(b.ssid)
                    if (aSaved !== bSaved) {
                        return bSaved - aSaved
                    }
                    // Finally by signal strength
                    return b.strength - a.strength
                })

            delegate: Loader {
                id: loader
                property var networkData: modelData
                width: networkList.width
                active: networkData !== null

                sourceComponent: NetworkItem {
                    network: loader.networkData
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.emptyMessage
            color: Appearance.colors.textTertiary
            font.pixelSize: Appearance.font.small
            horizontalAlignment: Text.AlignHCenter
            visible: networkList.count === 0
        }
    }
}
