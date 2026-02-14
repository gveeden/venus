pragma Singleton

import QtQuick

QtObject {
    property string currentTheme: "catppuccin"

    function saveSettings() {
    // Will be called from ThemeTab when settings change
    }

    property QtObject colors: QtObject {
        property color background: "#1e1e2e"
        property color surface: "#181825"
        property color surfaceHighlight: "#313244"
        property color text: "#cdd6f4"
        property color textSecondary: "#a6adc8"
        property color textTertiary: "#6c7086"
        property color primary: "#89b4fa"
        property color primaryContainer: "#a6e3a1"
        property color secondary: "#f38ba8"
        property color secondaryContainer: "#fab387"
        property color border: "#313244"
        property color hover: "#45475a"
        property color windowBorder: "#313244"
        property color buttonBorder: "#45475a"
        property color buttonBackground: "#89b4fa"
        property color buttonText: "#1e1e2e"
    }

    readonly property QtObject button: QtObject {
        property int borderThickness: 1
    }

    readonly property QtObject spacing: QtObject {
        property int tiny: 2
        property int small: 5
        property int medium: 10
        property int large: 15
        property int xlarge: 20
    }

    readonly property QtObject padding: QtObject {
        property int small: 4
        property int medium: 8
        property int large: 12
        property int xlarge: 15
    }

    readonly property QtObject rounding: QtObject {
        property int small: 4
        property int medium: 8
        property int large: 12
    }

    readonly property QtObject window: QtObject {
        property int borderThickness: 1
        property int radius: 8
    }

    readonly property QtObject font: QtObject {
        property string family: "JetBrainsMono Nerd Font"
        property int tiny: 10
        property int small: 11
        property int regular: 12
        property int medium: 13
        property int large: 14
        property int xlarge: 16
    }

    // Preset themes
    function applyTheme(themeName: string): void {
        currentTheme = themeName;
        switch (themeName) {
        case "catppuccin":
            colors.background = "#1e1e2e";
            colors.surface = "#181825";
            colors.surfaceHighlight = "#313244";
            colors.text = "#cdd6f4";
            colors.textSecondary = "#a6adc8";
            colors.textTertiary = "#6c7086";
            colors.primary = "#89b4fa";
            colors.primaryContainer = "#a6e3a1";
            colors.secondary = "#f38ba8";
            colors.secondaryContainer = "#fab387";
            colors.border = "#313244";
            colors.hover = "#45475a";
            colors.windowBorder = "#313244";
            colors.buttonBorder = "#45475a";
            colors.buttonBackground = colors.primary;
            colors.buttonText = colors.background;
            colors.buttonBackground = "#89b4fa";
            colors.buttonText = "#1e1e2e";
            window.borderThickness = 1;
            window.radius = 8;
            break;
        case "gruvbox":
            colors.background = "#282828";
            colors.surface = "#1d2021";
            colors.surfaceHighlight = "#3c3836";
            colors.text = "#ebdbb2";
            colors.textSecondary = "#d5c4a1";
            colors.textTertiary = "#bdae93";
            colors.primary = "#458588";
            colors.primaryContainer = "#98971a";
            colors.secondary = "#cc241d";
            colors.secondaryContainer = "#d79921";
            colors.border = "#3c3836";
            colors.hover = "#504945";
            colors.windowBorder = "#3c3836";
            colors.buttonBorder = "#504945";
            colors.buttonBackground = colors.primary;
            colors.buttonText = colors.background;
            window.borderThickness = 1;
            window.radius = 8;
            break;
        case "nord":
            colors.background = "#2e3440";
            colors.surface = "#242933";
            colors.surfaceHighlight = "#3b4252";
            colors.text = "#eceff4";
            colors.textSecondary = "#d8dee9";
            colors.textTertiary = "#616e88";
            colors.primary = "#88c0d0";
            colors.primaryContainer = "#a3be8c";
            colors.secondary = "#bf616a";
            colors.secondaryContainer = "#ebcb8b";
            colors.border = "#3b4252";
            colors.hover = "#434c5e";
            colors.windowBorder = "#3b4252";
            colors.buttonBorder = "#434c5e";
            colors.buttonBackground = colors.primary;
            colors.buttonText = colors.background;
            window.borderThickness = 1;
            window.radius = 8;
            break;
        case "dracula":
            colors.background = "#282a36";
            colors.surface = "#1e1f29";
            colors.surfaceHighlight = "#44475a";
            colors.text = "#f8f8f2";
            colors.textSecondary = "#e6e6e6";
            colors.textTertiary = "#6272a4";
            colors.primary = "#bd93f9";
            colors.primaryContainer = "#50fa7b";
            colors.secondary = "#ff79c6";
            colors.secondaryContainer = "#ffb86c";
            colors.border = "#44475a";
            colors.hover = "#6272a4";
            colors.windowBorder = "#44475a";
            colors.buttonBorder = "#6272a4";
            colors.buttonBackground = colors.primary;
            colors.buttonText = colors.background;
            window.borderThickness = 1;
            window.radius = 8;
            break;
        case "onedark":
            colors.background = "#282c34";
            colors.surface = "#1e222a";
            colors.surfaceHighlight = "#3e4451";
            colors.text = "#abb2bf";
            colors.textSecondary = "#828997";
            colors.textTertiary = "#5c6370";
            colors.primary = "#61afef";
            colors.primaryContainer = "#98c379";
            colors.secondary = "#e06c75";
            colors.secondaryContainer = "#e5c07b";
            colors.border = "#3e4451";
            colors.hover = "#4b5263";
            colors.windowBorder = "#3e4451";
            colors.buttonBorder = "#4b5263";
            colors.buttonBackground = colors.primary;
            colors.buttonText = colors.background;
            window.borderThickness = 1;
            window.radius = 8;
            break;
        }
    }
}
