import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../config"
import "../../../services"
import "../../../components/controls"

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

    signal popupOpened()
    signal popupClosed()

    ColorPickerPopup {
        id: customColorPicker
        initialColor: root.lightColor
        onColorPicked: color => root.colorRequested(color.toString())
        onOpened: root.popupOpened()
        onClosed: root.popupClosed()
    }

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

        // Color Presets (Pinned colors for quick access)
        Text {
            text: "Colors"
            color: Appearance.colors.textSecondary
            font.family: Appearance.font.family
            font.pixelSize: Appearance.font.small
        }

        Flow {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small
            Repeater {
                model: Appearance.pinnedColors
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
                        onPressAndHold: {
                            // Unpin on long-press
                            var current = Appearance.pinnedColors
                            current.splice(index, 1)
                            Appearance.pinnedColors = [...current]
                            if (typeof themeStorage !== 'undefined') themeStorage.save()
                        }
                    }
                }
            }

            // Current light color pin button (if not already pinned)
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: root.lightColor
                border.color: Appearance.colors.primary
                border.width: 1
                visible: Appearance.pinnedColors.indexOf(root.lightColor.toString().substring(0, 7)) === -1
                
                Text {
                    text: "+"
                    anchors.centerIn: parent
                    color: {
                        var c = root.lightColor
                        var luminance = (0.299 * c.r + 0.587 * c.g + 0.114 * c.b)
                        return luminance > 0.5 ? "#000000" : "#ffffff"
                    }
                    font.family: Appearance.font.family
                    font.pixelSize: 18
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var hex = root.lightColor.toString().substring(0, 7)
                        var current = Appearance.pinnedColors
                        if (current.indexOf(hex) === -1) {
                            Appearance.pinnedColors = [...current, hex]
                            if (typeof themeStorage !== 'undefined') themeStorage.save()
                        }
                    }
                }
            }

            // Open picker button
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: Appearance.colors.surfaceHighlight
                border.color: Appearance.colors.border
                border.width: 1
                
                Text {
                    text: "󰏘"
                    anchors.centerIn: parent
                    color: Appearance.colors.text
                    font.family: Appearance.font.family
                    font.pixelSize: 16
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: customColorPicker.open()
                }
            }
        }
        
        Item { Layout.fillHeight: true }
    }
}
