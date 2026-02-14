import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

Item {
    id: root

    property string settingsPath: Quickshell.appConfigDir + "/theme.json"

    function save() {
        console.log("ThemeStorage: Saving theme...");

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
        };

        fileView.setText(JSON.stringify(data, null, 2));
    }

    function load() {
        // FileView loads automatically
        console.log("ThemeStorage: FileView will load from:", settingsPath);
    }

    FileView {
        id: fileView
        path: settingsPath

        onLoaded: {
            console.log("ThemeStorage: File loaded, attempting to parse...");

            try {
                var data = JSON.parse(text());

                // Validate and apply theme
                if (data.currentTheme) {
                    Appearance.currentTheme = data.currentTheme;
                    console.log("ThemeStorage: Loaded theme:", data.currentTheme);
                }

                // Apply colors
                if (data.colors) {
                    if (data.colors.background)
                        Appearance.colors.background = data.colors.background;
                    if (data.colors.surface)
                        Appearance.colors.surface = data.colors.surface;
                    if (data.colors.surfaceHighlight)
                        Appearance.colors.surfaceHighlight = data.colors.surfaceHighlight;
                    if (data.colors.text)
                        Appearance.colors.text = data.colors.text;
                    if (data.colors.textSecondary)
                        Appearance.colors.textSecondary = data.colors.textSecondary;
                    if (data.colors.textTertiary)
                        Appearance.colors.textTertiary = data.colors.textTertiary;
                    if (data.colors.primary)
                        Appearance.colors.primary = data.colors.primary;
                    if (data.colors.primaryContainer)
                        Appearance.colors.primaryContainer = data.colors.primaryContainer;
                    if (data.colors.secondary)
                        Appearance.colors.secondary = data.colors.secondary;
                    if (data.colors.secondaryContainer)
                        Appearance.colors.secondaryContainer = data.colors.secondaryContainer;
                    if (data.colors.border)
                        Appearance.colors.border = data.colors.border;
                    if (data.colors.hover)
                        Appearance.colors.hover = data.colors.hover;
                    if (data.colors.windowBorder)
                        Appearance.colors.windowBorder = data.colors.windowBorder;
                    console.log("ThemeStorage: Colors applied");
                }

                // Apply window settings
                if (data.window) {
                    if (data.window.borderThickness !== undefined)
                        Appearance.window.borderThickness = data.window.borderThickness;
                    if (data.window.radius !== undefined)
                        Appearance.window.radius = data.window.radius;
                    console.log("ThemeStorage: Window settings applied");
                }

                console.log("ThemeStorage: Theme loaded successfully!");
            } catch (e) {
                console.error("ThemeStorage: Failed to parse or apply theme:", e);
                console.log("ThemeStorage: Using default theme");
            }
        }

        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                console.log("ThemeStorage: No saved theme found, creating default...");
                save();
            } else {
                console.error("ThemeStorage: Failed to load theme:", FileViewError.toString(err));
            }
        }

        onSaveFailed: err => {
            console.error("ThemeStorage: Failed to save theme:", FileViewError.toString(err));
        }
    }

    Component.onCompleted: {
        console.log("ThemeStorage: Initialized");
    }
}
