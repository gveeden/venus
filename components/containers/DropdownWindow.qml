import "../../config"
import Quickshell
import QtQuick

PanelWindow {
    id: root

    required property int windowWidth
    required property int windowHeight
    required property int topMargin
    required property int rightMargin
    required property int contentMargins
    property alias content: contentLoader.sourceComponent

    // Close timer - 2 second delay
    Timer {
        id: closeTimer
        interval: 2000
        onTriggered: root.visible = false
    }

    // Public functions for timer control
    function startCloseTimer() {
        closeTimer.start();
    }

    function stopCloseTimer() {
        closeTimer.stop();
    }

    visible: false

    anchors {
        top: true
        right: true
    }

    margins {
        top: 0
        right: 0
    }

    implicitWidth: root.windowWidth
    implicitHeight: root.windowHeight
    color: "transparent"

    // MouseArea to detect hover over window
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.stopCloseTimer()
        onExited: root.startCloseTimer()
        propagateComposedEvents: true
    }

    // Background with radius
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Appearance.colors.background.r, Appearance.colors.background.g, Appearance.colors.background.b, Appearance.window.opacity)
        radius: Appearance.window.radius
        anchors.topMargin: -Appearance.window.radius
        anchors.rightMargin: -Appearance.window.radius
    }

    // Content loader
    Loader {
        id: contentLoader
        anchors.fill: parent
        anchors.margins: Appearance.window.borderThickness + root.contentMargins
    }
}
