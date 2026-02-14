import QtQuick
import QtQuick.Layouts
import "../../config"

Rectangle {
    id: root

    // Public properties
    property string text: ""
    property string variant: "solid" // "solid", "outline", "ghost"
    property int fontSize: Appearance.font.regular
    property bool bold: false
    property int padding: Appearance.padding.medium
    property bool loading: false
    property bool enabled: true

    // Signals
    signal clicked

    // Computed colors based on variant
    readonly property color buttonColor: {
        switch (variant) {
        case "outline":
            return "transparent";
        case "ghost":
            return "transparent";
        case "solid":
        default:
            return Appearance.colors.primary;
        }
    }

    readonly property color textColor: {
        switch (variant) {
        case "outline":
            return Appearance.colors.primary;
        case "ghost":
            return Appearance.colors.primary;
        case "solid":
        default:
            return Appearance.colors.background;
        }
    }

    readonly property color borderColor: {
        switch (variant) {
        case "outline":
            return Appearance.colors.primary;
        case "ghost":
            return "transparent";
        case "solid":
        default:
            return "transparent";
        }
    }

    readonly property int borderWidth: variant === "outline" ? 1 : 0

    readonly property color hoverColor: {
        switch (variant) {
        case "outline":
        case "ghost":
            return Appearance.colors.text;
        case "solid":
        default:
            return Appearance.colors.text;
        }
    }

    // Visual properties
    implicitWidth: buttonText.implicitWidth + padding * 2
    implicitHeight: buttonText.implicitHeight + padding * 2
    color: mouseArea.containsMouse && !mouseArea.containsPress ? hoverColor : buttonColor
    radius: Appearance.rounding.small
    border.color: mouseArea.containsMouse && !mouseArea.containsPress ? hoverColor : borderColor
    border.width: borderWidth

    // Hover effect
    opacity: (!root.enabled || root.loading) ? 0.5 : (mouseArea.containsPress ? 0.7 : (mouseArea.containsMouse ? 0.9 : 1.0))

    Behavior on opacity {
        NumberAnimation {
            duration: 100
        }
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        text: root.text
        color: mouseArea.containsMouse && !mouseArea.containsPress ? Appearance.colors.background : root.textColor
        font.pixelSize: root.fontSize
        font.bold: root.bold
        font.family: Appearance.font.family
        visible: !root.loading
    }

    // Loading spinner
    Rectangle {
        anchors.centerIn: parent
        width: 16
        height: 16
        radius: 8
        color: "transparent"
        visible: root.loading

        Rectangle {
            anchors.centerIn: parent
            width: 12
            height: 12
            radius: 6
            color: root.textColor

            RotationAnimation on rotation {
                running: root.loading
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled && !root.loading
        onClicked: root.clicked()
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
