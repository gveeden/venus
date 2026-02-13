import "../../config"
import Quickshell
import QtQuick

Window {
    id: launcher
    title: "qs-launcher"
    width: LauncherConfig.width
    height: LauncherConfig.height
    visible: false
    color: "transparent"

    property string search: ""

    onVisibleChanged: {
        if (visible) {
            content.focusSearch()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Appearance.colors.background
        radius: Appearance.rounding.large
        border.color: Appearance.colors.border
        border.width: 1

        Content {
            id: content
            anchors.fill: parent
            anchors.margins: Appearance.padding.xlarge
            
            search: launcher.search
            onSearchChanged: launcher.search = search
            onRequestClose: launcher.visible = false
        }
    }
}
