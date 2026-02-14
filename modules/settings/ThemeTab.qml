import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../config"
import "../../services"

ScrollView {
    id: scrollView
    clip: true
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    // Helper to safely save theme (only if themeStorage is available)
    function saveTheme(source) {
        var caller = source || "unknown"
        console.log("ThemeTab: Theme save triggered from:", caller)
        
        // Check if themeStorage exists in parent scope
        if (typeof themeStorage !== 'undefined' && themeStorage !== null) {
            themeStorage.save()
        } else {
            console.warn("ThemeTab: themeStorage not available, changes won't persist")
        }
    }

    // Function to close all color pickers
    function closeColorPickers() {
        // Find all ColorPicker children and close their popups
        var pickers = [backgroundPicker, surfacePicker, primaryPicker, secondaryPicker,
                       textPicker, textSecondaryPicker, textTertiaryPicker, borderPicker,
                       hoverPicker, surfaceHighlightPicker, primaryContainerPicker, secondaryContainerPicker,
                       buttonBackgroundPicker, buttonTextPicker, buttonBorderPicker]
        for (var i = 0; i < pickers.length; i++) {
            if (pickers[i] && pickers[i].closePopup) {
                pickers[i].closePopup()
            }
        }
    }

    ColumnLayout {
        width: scrollView.width
        spacing: 20

        // Header
        Text {
            text: "Theme Settings"
            color: Appearance.colors.text
            font.pixelSize: 24
            font.weight: Font.Bold
        }

    // Preset themes section
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        Text {
            text: "Preset Themes"
            color: Appearance.colors.textSecondary
            font.pixelSize: 14
            font.weight: Font.Medium
        }

        Flow {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: [
                    { name: "Catppuccin", value: "catppuccin" },
                    { name: "Gruvbox", value: "gruvbox" },
                    { name: "Nord", value: "nord" },
                    { name: "Dracula", value: "dracula" },
                    { name: "One Dark", value: "onedark" }
                ]

                delegate: Rectangle {
                    width: themeButtonText.width + 24
                    height: 36
                    radius: 6
                    color: Appearance.currentTheme === modelData.value
                           ? Appearance.colors.primary
                           : Appearance.colors.surfaceHighlight

                    Text {
                        id: themeButtonText
                        text: modelData.name
                        color: Appearance.currentTheme === modelData.value
                               ? Appearance.colors.background
                               : Appearance.colors.text
                        font.pixelSize: 13
                        font.weight: Appearance.currentTheme === modelData.value
                                     ? Font.Medium
                                     : Font.Normal
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("ThemeTab: Applying preset theme:", modelData.value)
                            Appearance.applyTheme(modelData.value)
                            saveTheme("preset:" + modelData.value)
                        }
                    }
                }
            }
        }
    }

    // Divider
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.colors.border
    }

    // Custom colors section
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        Text {
            text: "Custom Colors"
            color: Appearance.colors.textSecondary
            font.pixelSize: 14
            font.weight: Font.Medium
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 20
            rowSpacing: 12

            // Background
            ColorPicker {
                id: backgroundPicker
                label: "Background"
                colorValue: Appearance.colors.background
                onColorChanged: (newColor) => { Appearance.colors.background = newColor; saveTheme("color:background") }
            }

            // Surface
            ColorPicker {
                id: surfacePicker
                label: "Surface"
                colorValue: Appearance.colors.surface
                onColorChanged: (newColor) => { Appearance.colors.surface = newColor; saveTheme("color:surface") }
            }

            // Primary
            ColorPicker {
                id: primaryPicker
                label: "Primary"
                colorValue: Appearance.colors.primary
                onColorChanged: (newColor) => { Appearance.colors.primary = newColor; saveTheme("color:primary") }
            }

            // Secondary
            ColorPicker {
                id: secondaryPicker
                label: "Secondary"
                colorValue: Appearance.colors.secondary
                onColorChanged: (newColor) => { Appearance.colors.secondary = newColor; saveTheme("color:secondary") }
            }

            // Text
            ColorPicker {
                id: textPicker
                label: "Text"
                colorValue: Appearance.colors.text
                onColorChanged: (newColor) => { Appearance.colors.text = newColor; saveTheme() }
            }

            // Text Secondary
            ColorPicker {
                id: textSecondaryPicker
                label: "Text Secondary"
                colorValue: Appearance.colors.textSecondary
                onColorChanged: (newColor) => { Appearance.colors.textSecondary = newColor; saveTheme() }
            }

            // Text Tertiary
            ColorPicker {
                id: textTertiaryPicker
                label: "Text Tertiary"
                colorValue: Appearance.colors.textTertiary
                onColorChanged: (newColor) => { Appearance.colors.textTertiary = newColor; saveTheme() }
            }

            // Border
            ColorPicker {
                id: borderPicker
                label: "Border"
                colorValue: Appearance.colors.border
                onColorChanged: (newColor) => { Appearance.colors.border = newColor; saveTheme() }
            }

            // Hover
            ColorPicker {
                id: hoverPicker
                label: "Hover"
                colorValue: Appearance.colors.hover
                onColorChanged: (newColor) => { Appearance.colors.hover = newColor; saveTheme() }
            }

            // Surface Highlight
            ColorPicker {
                id: surfaceHighlightPicker
                label: "Surface Highlight"
                colorValue: Appearance.colors.surfaceHighlight
                onColorChanged: (newColor) => { Appearance.colors.surfaceHighlight = newColor; saveTheme() }
            }

            // Primary Container
            ColorPicker {
                id: primaryContainerPicker
                label: "Primary Container"
                colorValue: Appearance.colors.primaryContainer
                onColorChanged: (newColor) => { Appearance.colors.primaryContainer = newColor; saveTheme() }
            }

            // Secondary Container
            ColorPicker {
                id: secondaryContainerPicker
                label: "Secondary Container"
                colorValue: Appearance.colors.secondaryContainer
                onColorChanged: (newColor) => { Appearance.colors.secondaryContainer = newColor; saveTheme() }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.border
        }

        // Window Border Settings
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Window Borders"
                color: Appearance.colors.textSecondary
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Border Thickness"
                    color: Appearance.colors.text
                    font.pixelSize: 13
                    Layout.preferredWidth: 130
                }

                Slider {
                    id: borderThicknessSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 5
                    value: Appearance.window.borderThickness
                    onValueChanged: { Appearance.window.borderThickness = Math.round(value); saveTheme("window:borderThickness") }
                }

                Text {
                    text: Math.round(Appearance.window.borderThickness)
                    color: Appearance.colors.text
                    font.pixelSize: 13
                    Layout.preferredWidth: 30
                }
            }

            // Window Border Color
            ColorPicker {
                label: "Border Color"
                colorValue: Appearance.colors.windowBorder
                onColorChanged: (newColor) => { Appearance.colors.windowBorder = newColor; saveTheme() }
            }

            // Window Radius
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Window Radius"
                    color: Appearance.colors.text
                    font.pixelSize: 13
                    Layout.preferredWidth: 130
                }

                Slider {
                    id: windowRadiusSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 20
                    value: Appearance.window.radius
                    onValueChanged: { Appearance.window.radius = Math.round(value); saveTheme("window:radius") }
                }

                Text {
                    text: Math.round(Appearance.window.radius)
                    color: Appearance.colors.text
                    font.pixelSize: 13
                    Layout.preferredWidth: 30
                }
            }
        }

        // Bottom spacing
        Item {
            Layout.fillWidth: true
            height: 20
        }
    }
}
}
