import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../config"

Rectangle {
    id: root
    property color colorValue: "#ffffff"
    signal colorChosen(color newColor)

    width: 80
    height: 32
    radius: 4
    color: colorValue
    border.width: 1
    border.color: Appearance.colors.border

    Text {
        text: root.colorValue.toString().toUpperCase().substring(0, 7)
        color: {
            var r = root.colorValue.r
            var g = root.colorValue.g
            var b = root.colorValue.b
            var luminance = (0.299 * r + 0.587 * g + 0.114 * b)
            return luminance > 0.5 ? "#000000" : "#ffffff"
        }
        font.pixelSize: 11
        font.family: "monospace"
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: picker.open()
    }

    ColorPickerPopup {
        id: picker
        parent: root.Window ? root.Window.contentItem : root
        initialColor: root.colorValue
        onColorPicked: color => {
            root.colorValue = color
            root.colorChosen(color)
        }
    }
}
