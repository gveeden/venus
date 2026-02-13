import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

Item {
    id: root

    property string settingsPath: Quickshell.appConfigDir + "/theme.json"

    function save() {
        var data = {
            currentTheme: Appearance.currentTheme,
            colors: {
                background: Appearance.colors.background.toString(),
                surface: Appearance.colors.surface.toString(),
                surfaceHighlight: Appearance.colors.surfaceHighlight.toString(),
                text: Appearance.colors.text.toString(),
                textSecondary: Appearance.colors.textSecondary.toString(),
                textTertiary: Appearance.colors.textTertiary.toString(),
                primary: Appearance.colors.primary.toString(),
                primaryContainer: Appearance.colors.primaryContainer.toString(),
                secondary: Appearance.colors.secondary.toString(),
                secondaryContainer: Appearance.colors.secondaryContainer.toString(),
                border: Appearance.colors.border.toString(),
                hover: Appearance.colors.hover.toString(),
                windowBorder: Appearance.colors.windowBorder.toString()
            },
            window: {
                borderThickness: Appearance.window.borderThickness,
                radius: Appearance.window.radius
            }
        }

        var jsonStr = JSON.stringify(data, null, 2)
        saveProc.command = ["sh", "-c", "mkdir -p \"$(dirname '" + settingsPath + "')\" && echo '" + jsonStr.replace(/'/g, "'\\''") + "' > '" + settingsPath + "'"]
        saveProc.running = true
    }

    function load() {
        loadProc.running = true
    }

    Process {
        id: saveProc
        running: false
    }

    Process {
        id: loadProc
        command: ["cat", settingsPath]
        running: false

        property string content: ""

        stdout.onRead: function(data) {
            content += data
        }

        onExited: function(exitCode) {
            console.log("ThemeStorage: Load process exited with code:", exitCode, "content length:", content.length)
            if (exitCode !== 0 || !content) {
                console.log("ThemeStorage: No saved settings found, using defaults")
                return
            }

            try {
                var data = JSON.parse(content)
                console.log("ThemeStorage: Loaded settings, theme:", data.currentTheme)
                
                if (data.currentTheme) {
                    Appearance.currentTheme = data.currentTheme
                }

                if (data.colors) {
                    if (data.colors.background) Appearance.colors.background = data.colors.background
                    if (data.colors.surface) Appearance.colors.surface = data.colors.surface
                    if (data.colors.surfaceHighlight) Appearance.colors.surfaceHighlight = data.colors.surfaceHighlight
                    if (data.colors.text) Appearance.colors.text = data.colors.text
                    if (data.colors.textSecondary) Appearance.colors.textSecondary = data.colors.textSecondary
                    if (data.colors.textTertiary) Appearance.colors.textTertiary = data.colors.textTertiary
                    if (data.colors.primary) Appearance.colors.primary = data.colors.primary
                    if (data.colors.primaryContainer) Appearance.colors.primaryContainer = data.colors.primaryContainer
                    if (data.colors.secondary) Appearance.colors.secondary = data.colors.secondary
                    if (data.colors.secondaryContainer) Appearance.colors.secondaryContainer = data.colors.secondaryContainer
                    if (data.colors.border) Appearance.colors.border = data.colors.border
                    if (data.colors.hover) Appearance.colors.hover = data.colors.hover
                    if (data.colors.windowBorder) Appearance.colors.windowBorder = data.colors.windowBorder
                }

                if (data.window) {
                    if (data.window.borderThickness !== undefined) Appearance.window.borderThickness = data.window.borderThickness
                    if (data.window.radius !== undefined) Appearance.window.radius = data.window.radius
                }

                content = ""  // Reset for next load
            } catch (e) {
                console.error("Failed to parse theme settings:", e)
            }
        }
    }

    Component.onCompleted: {
        console.log("ThemeStorage: Component completed, loading settings from:", settingsPath)
        load()
    }
}
