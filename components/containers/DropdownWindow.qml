import "../../config"
import Quickshell
import QtQuick
import Quickshell.Wayland

Scope {
    id: root

    required property int windowWidth
    required property int windowHeight
    required property int topMargin
    required property int rightMargin
    required property int contentMargins
    property int xMargin: 0
    property int yMargin: 0
    property bool inhibitClose: false
    property Component content: null

    property bool visible: false
    property var targetScreen: null

    onVisibleChanged: {
        if (!visible) {
            targetScreen = null;
        }
    }

    // Close timer - 500ms delay
    Timer {
        id: closeTimer
        interval: 500
        onTriggered: {
            if (!root.inhibitClose)
                root.visible = false;
        }
    }

    // Public functions for timer control
    function startCloseTimer() {
        if (!root.inhibitClose)
            closeTimer.start();
    }

    function stopCloseTimer() {
        closeTimer.stop();
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: dropdownWindow
                required property var modelData
                screen: modelData
                visible: root.visible && (modelData === root.targetScreen)
                WlrLayershell.keyboardFocus: root.visible && (modelData === root.targetScreen) && (contentLoader.item && contentLoader.item.requestsKeyboardFocus) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                onVisibleChanged: {
                    if (!visible && (modelData === root.targetScreen)) {
                        root.visible = false;
                    }
                }
                
                anchors {
                    top: true
                    right: true
                }

                margins {
                    top: 0
                    right: 0
                }

                implicitWidth: root.windowWidth
                implicitHeight: root.windowHeight > 0 ? root.windowHeight : contentLoader.item ? contentLoader.item.implicitHeight + (root.yMargin * 2) : 0
                color: "transparent"

                // HoverHandler to detect hover over window (doesn't block child events)
                HoverHandler {
                    onHoveredChanged: {
                        if (hovered)
                            root.stopCloseTimer();
                        else
                            root.startCloseTimer();
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
                    sourceComponent: root.content
                }
            }
        }
    }
}
