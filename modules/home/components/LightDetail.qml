import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../config"
import "../../../services"

Rectangle {
    id: root
    property string title: ""
    property bool isOn: false
    property int brightness: 100
    property string lightColor: "#ffffff"
    
    signal close()
    signal powerToggled()
    signal brightnessRequested(int value)
    signal colorRequested(string value)

    color: Appearance.colors.background
    radius: Appearance.window.radius
    border.color: Appearance.colors.border
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.medium

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.title
                font.family: Appearance.font.family
                font.pixelSize: Appearance.font.large
                font.bold: true
                color: Appearance.colors.text
                Layout.fillWidth: true
            }
            Text {
                text: "󰅖"
                font.family: Appearance.font.family
                font.pixelSize: 20
                color: Appearance.colors.textSecondary
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.close()
                }
            }
        }

        // Power Toggle
        Button {
            Layout.fillWidth: true
            text: root.isOn ? "Turn Off" : "Turn On"
            onClicked: root.powerToggled()
        }

        // Brightness Slider
        ColumnLayout {
            Layout.fillWidth: true
            Text {
                text: "Brightness: " + root.brightness + "%"
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family
                font.pixelSize: Appearance.font.small
            }
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: root.brightness
                onMoved: root.brightnessRequested(Math.round(value))
            }
        }

        // Color Presets (Simple for now)
        Text {
            text: "Colors"
            color: Appearance.colors.textSecondary
            font.family: Appearance.font.family
            font.pixelSize: Appearance.font.small
        }

        Row {
            spacing: Appearance.spacing.small
            Repeater {
                model: ["#ffffff", "#ff0000", "#00ff00", "#0000ff", "#ffff00", "#ff00ff"]
                delegate: Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: modelData
                    border.color: Appearance.colors.border
                    border.width: root.lightColor === modelData ? 2 : 0
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.colorRequested(modelData)
                    }
                }
            }
        }
        
        Item { Layout.fillHeight: true }
    }
}
