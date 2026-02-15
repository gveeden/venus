import "../../config"
import QtQuick
import "." as LauncherPrivate

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
            content.focusSearch();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Appearance.colors.background.r, Appearance.colors.background.g, Appearance.colors.background.b, Appearance.window.opacity)
        radius: Appearance.window.radius
        border.color: Appearance.colors.windowBorder
        border.width: Appearance.window.borderThickness

        LauncherPrivate.Content {
            id: content
            anchors.fill: parent
            anchors.margins: Appearance.padding.xlarge

            search: launcher.search
            onSearchChanged: launcher.search = search
            onRequestClose: launcher.visible = false
        }
    }
}
