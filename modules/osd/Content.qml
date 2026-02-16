import "../../config"
import "../../services"
import Quickshell
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string osdType: ""
    property int volumeValue: 0
    property int brightnessValue: 0
    property bool isMuted: false

    color: Qt.rgba(Appearance.colors.surface.r, Appearance.colors.surface.g, Appearance.colors.surface.b, Appearance.window.opacity)
    radius: Appearance.rounding.large
    border.color: Appearance.colors.border
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.medium

        Text {
            id: iconLabel
            text: root.osdType === "volume" ? (root.isMuted ? "󰖁" : root.volumeValue > 70 ? "󰕾" : root.volumeValue > 30 ? "󰖀" : "󰕿") : (root.brightnessValue > 70 ? "󰃠" : root.brightnessValue > 30 ? "󰃟" : "󰃞")
            color: Appearance.colors.primary
            font.pixelSize: OsdConfig.iconSize
            font.family: "JetBrainsMono Nerd Font"
            Layout.preferredWidth: OsdConfig.iconSize
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            spacing: Appearance.spacing.tiny
            Layout.fillWidth: true

            Text {
                text: root.osdType === "volume" ? (root.isMuted ? "Muted" : "Volume " + root.volumeValue + "%") : "Brightness " + root.brightnessValue + "%"
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.regular
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: OsdConfig.barHeight
                radius: OsdConfig.barHeight / 2
                color: Appearance.colors.surfaceHighlight

                Rectangle {
                    width: parent.width * (root.osdType === "volume" ? (root.isMuted ? 0 : root.volumeValue / 100) : root.brightnessValue / 100)
                    height: parent.height
                    radius: parent.radius
                    color: Appearance.colors.primary
                }
            }
        }
    }
}
