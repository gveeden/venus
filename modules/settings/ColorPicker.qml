import "../../config"
import "../../components/controls"
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window

RowLayout {
    id: root
    spacing: 10

    property string label: ""
    property color colorValue: "#000000"
    signal colorChanged(color newColor)
    
    // Allow external tracking of the popup
    readonly property bool isOpened: colorPickerPopup.opened
    signal opened()
    signal closed()

    // Store slider values as properties so they persist
    property int rValue: Math.round(root.colorValue.r * 255)
    property int gValue: Math.round(root.colorValue.g * 255)
    property int bValue: Math.round(root.colorValue.b * 255)

    // Function to close the color picker popup from outside
    function closePopup() {
        if (colorPickerPopup.opened) {
            colorPickerPopup.close()
        }
    }

    Text {
        text: root.label
        color: Appearance.colors.text
        font.pixelSize: 13
        Layout.preferredWidth: 130
    }

    Rectangle {
        width: 80
        height: 32
        radius: 4
        color: root.colorValue
        border.width: 1
        border.color: Appearance.colors.border

        Text {
            text: root.colorValue.toString().toUpperCase()
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
            onClicked: {
                root.rValue = Math.round(root.colorValue.r * 255)
                root.gValue = Math.round(root.colorValue.g * 255)
                root.bValue = Math.round(root.colorValue.b * 255)
                colorPickerPopup.open()
            }
        }
    }

    Rectangle {
        width: 32
        height: 32
        radius: 4
        color: Appearance.colors.surfaceHighlight

        Text {
            text: "↻"
            color: Appearance.colors.text
            font.pixelSize: 16
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("ColorPicker: Resetting", root.label, "to default")
                switch (root.label) {
                case "Background": root.colorChanged("#1e1e2e"); break
                case "Surface": root.colorChanged("#181825"); break
                case "Surface Highlight": root.colorChanged("#313244"); break
                case "Text": root.colorChanged("#cdd6f4"); break
                case "Text Secondary": root.colorChanged("#a6adc8"); break
                case "Text Tertiary": root.colorChanged("#6c7086"); break
                case "Primary": root.colorChanged("#89b4fa"); break
                case "Primary Container": root.colorChanged("#a6e3a1"); break
                case "Secondary": root.colorChanged("#f38ba8"); break
                case "Secondary Container": root.colorChanged("#fab387"); break
                case "Border": root.colorChanged("#313244"); break
                case "Hover": root.colorChanged("#45475a"); break
                }
            }
        }
    }

    // Color Picker Popup - centered in parent window
    ColorPickerPopup {
        id: colorPickerPopup
        initialColor: root.colorValue
        onColorPicked: (newColor) => {
            console.log("ColorPicker: Applying color for", root.label, "->", newColor)
            root.colorChanged(newColor)
        }
        onAboutToHide: root.closed()
        onAboutToShow: root.opened()
        
        // Parent to the settings window content area for proper centering
        parent: root.Window ? root.Window.contentItem : root
    }
}
