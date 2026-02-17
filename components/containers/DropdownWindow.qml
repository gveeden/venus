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
    property int xMargin: 0
    property int yMargin: 0
    property alias content: contentLoader.sourceComponent

    // Close timer - 2 second delay
    Timer {
        id: closeTimer
        interval: 500
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

    // HoverHandler to detect hover over window (doesn't block child events)
    HoverHandler {
        onHoveredChanged: {
            if (hovered) root.stopCloseTimer()
            else root.startCloseTimer()
        }
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
        anchors.leftMargin: root.xMargin
        anchors.rightMargin: root.xMargin
        anchors.topMargin: root.yMargin
        anchors.bottomMargin: root.yMargin
    }
}
