import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../config"

Popup {
    id: root
    width: 340
    height: 480
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Center in parent window if possible
    x: parent ? Math.round((parent.width - width) / 2) : 0
    y: parent ? Math.round((parent.height - height) / 2) : 0

    signal colorPicked(color selectedColor)

    property color initialColor: "#ffffff"

    // Internal state
    property int rValue: Math.round(initialColor.r * 255)
    property int gValue: Math.round(initialColor.g * 255)
    property int bValue: Math.round(initialColor.b * 255)

    onAboutToShow: {
        rValue = Math.round(initialColor.r * 255)
        gValue = Math.round(initialColor.g * 255)
        bValue = Math.round(initialColor.b * 255)
    }

    background: Rectangle {
        color: Appearance.colors.surface
        radius: Appearance.window.radius
        border.width: Appearance.window.borderThickness
        border.color: Appearance.colors.windowBorder
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Title with close button
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Pick a Color"
                color: Appearance.colors.text
                font.family: Appearance.font.family
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: closeMouse.containsPress ? Appearance.colors.hover : (closeMouse.containsMouse ? Appearance.colors.surfaceHighlight : "transparent")

                Text {
                    text: "󰅖"
                    color: Appearance.colors.text
                    font.family: Appearance.font.family
                    font.pixelSize: 16
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.close()
                }
            }
        }

        // Color preview
        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 6
            color: Qt.rgba(root.rValue / 255, root.gValue / 255, root.bValue / 255, 1)
            border.width: 1
            border.color: Appearance.colors.border

            Text {
                text: Qt.rgba(root.rValue / 255, root.gValue / 255, root.bValue / 255, 1).toString().toUpperCase()
                color: {
                    var r = root.rValue / 255
                    var g = root.gValue / 255
                    var b = root.bValue / 255
                    var luminance = (0.299 * r + 0.587 * g + 0.114 * b)
                    return luminance > 0.5 ? "#000000" : "#ffffff"
                }
                font.pixelSize: 14
                font.family: "monospace"
                anchors.centerIn: parent
            }
        }

        // Continuous Color Field
        Rectangle {
            Layout.fillWidth: true
            height: 140
            radius: 6
            clip: true

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#ff0000" }
                    GradientStop { position: 0.17; color: "#ffff00" }
                    GradientStop { position: 0.33; color: "#00ff00" }
                    GradientStop { position: 0.5; color: "#00ffff" }
                    GradientStop { position: 0.67; color: "#0000ff" }
                    GradientStop { position: 0.83; color: "#ff00ff" }
                    GradientStop { position: 1.0; color: "#ff0000" }
                }
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#000000" }
                        GradientStop { position: 0.5; color: "transparent" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: "transparent" }
                        GradientStop { position: 1.0; color: "#ffffff" }
                    }
                }
            }

            Rectangle {
                id: crosshair
                width: 12
                height: 12
                radius: 6
                color: "transparent"
                border.width: 2
                border.color: {
                    var r = root.rValue / 255
                    var g = root.gValue / 255
                    var b = root.bValue / 255
                    var luminance = (0.299 * r + 0.587 * g + 0.114 * b)
                    return luminance > 0.5 ? "#000000" : "#ffffff"
                }
                x: Math.min(Math.max(colorFieldMouse.mouseX - 6, 0), parent.width - 12)
                y: Math.min(Math.max(colorFieldMouse.mouseY - 6, 0), parent.height - 12)
            }

            MouseArea {
                id: colorFieldMouse
                anchors.fill: parent
                hoverEnabled: true
                onPressed: updateColor(mouse.x, mouse.y)
                onPositionChanged: if (pressed) updateColor(mouse.x, mouse.y)
                function updateColor(mouseX, mouseY) {
                    var normX = Math.max(0, Math.min(1, mouseX / parent.width))
                    var normY = Math.max(0, Math.min(1, mouseY / parent.height))
                    var hue = normX * 360
                    var saturation, value
                    if (normY <= 0.5) {
                        value = normY * 2
                        saturation = 1.0
                    } else {
                        value = 1.0
                        saturation = 1.0 - ((normY - 0.5) * 2)
                    }
                    var c = value * saturation
                    var h = hue / 60
                    var x_val = c * (1 - Math.abs((h % 2) - 1))
                    var m = value - c
                    var r, g, b
                    if (h < 1) { r = c; g = x_val; b = 0 }
                    else if (h < 2) { r = x_val; g = c; b = 0 }
                    else if (h < 3) { r = 0; g = c; b = x_val }
                    else if (h < 4) { r = 0; g = x_val; b = c }
                    else if (h < 5) { r = x_val; g = 0; b = c }
                    else { r = c; g = 0; b = x_val }
                    root.rValue = Math.round((r + m) * 255)
                    root.gValue = Math.round((g + m) * 255)
                    root.bValue = Math.round((b + m) * 255)
                }
            }
        }

        // RGB Sliders
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            // Red
            RowLayout {
                Layout.fillWidth: true
                Text { text: "R"; color: "#ff6b6b"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 20 }
                Slider { Layout.fillWidth: true; from: 0; to: 255; value: root.rValue; onValueChanged: root.rValue = Math.round(value) }
                Text { text: root.rValue; color: Appearance.colors.text; font.pixelSize: 12; Layout.preferredWidth: 30; horizontalAlignment: Text.AlignRight }
            }
            // Green
            RowLayout {
                Layout.fillWidth: true
                Text { text: "G"; color: "#6bff6b"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 20 }
                Slider { Layout.fillWidth: true; from: 0; to: 255; value: root.gValue; onValueChanged: root.gValue = Math.round(value) }
                Text { text: root.gValue; color: Appearance.colors.text; font.pixelSize: 12; Layout.preferredWidth: 30; horizontalAlignment: Text.AlignRight }
            }
            // Blue
            RowLayout {
                Layout.fillWidth: true
                Text { text: "B"; color: "#6b6bff"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 20 }
                Slider { Layout.fillWidth: true; from: 0; to: 255; value: root.bValue; onValueChanged: root.bValue = Math.round(value) }
                Text { text: root.bValue; color: Appearance.colors.text; font.pixelSize: 12; Layout.preferredWidth: 30; horizontalAlignment: Text.AlignRight }
            }
        }

        // Preset colors grid
        GridLayout {
            Layout.fillWidth: true
            columns: 8
            columnSpacing: 4
            rowSpacing: 4
            Repeater {
                model: [
                    "#ff6b6b", "#f06595", "#cc5de8", "#845ef7",
                    "#5c7cfa", "#339af0", "#22b8cf", "#20c997",
                    "#51cf66", "#94d82d", "#fcc419", "#ff922b",
                    "#ff8787", "#e64980", "#be4bdb", "#7950f2",
                    "#4c6ef5", "#228be6", "#15aabf", "#12b886",
                    "#40c057", "#82c91e", "#fab005", "#fd7e14"
                ]
                delegate: Rectangle {
                    width: 28; height: 28; radius: 4
                    color: modelData
                    border.width: 1; border.color: Appearance.colors.border
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var c = Qt.color(modelData)
                            root.rValue = Math.round(c.r * 255)
                            root.gValue = Math.round(c.g * 255)
                            root.bValue = Math.round(c.b * 255)
                        }
                    }
                }
            }
        }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 70; height: 32; radius: 4
                color: Appearance.colors.surfaceHighlight
                Text { text: "Cancel"; color: Appearance.colors.text; font.pixelSize: 13; anchors.centerIn: parent }
                MouseArea { anchors.fill: parent; onClicked: root.close() }
            }
            Rectangle {
                width: 70; height: 32; radius: 4
                color: Appearance.colors.primary
                Text { text: "Apply"; color: Appearance.colors.background; font.pixelSize: 13; font.weight: Font.Medium; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var newColor = Qt.rgba(root.rValue / 255, root.gValue / 255, root.bValue / 255, 1)
                        root.colorPicked(newColor)
                        root.close()
                    }
                }
            }
        }
    }
}
