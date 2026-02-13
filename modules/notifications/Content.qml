import "../../config"
import Quickshell
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var notification

    color: Appearance.colors.surface
    radius: Appearance.rounding.large
    border.color: Appearance.colors.border
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.medium

        Rectangle {
            Layout.preferredWidth: NotificationConfig.iconSize
            Layout.preferredHeight: NotificationConfig.iconSize
            radius: Appearance.rounding.medium
            color: Appearance.colors.surfaceHighlight
            
            Image {
                anchors.fill: parent
                anchors.margins: Appearance.padding.small
                source: root.notification && root.notification.icon 
                    ? Quickshell.iconPath(root.notification.icon) 
                    : ""
                visible: source != ""
            }
            
            Text { 
                anchors.centerIn: parent
                text: "🔔" 
                visible: !parent.children[0].visible
            }
        }

        ColumnLayout {
            spacing: Appearance.spacing.tiny
            Layout.fillWidth: true

            Text {
                text: root.notification ? root.notification.summary : ""
                color: Appearance.colors.text
                font.bold: true
                font.pixelSize: Appearance.font.large
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: root.notification ? root.notification.body : ""
                color: Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.regular
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }
}
