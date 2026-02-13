import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

Scope {
    required property var notificationServer

    property var currentNote: notificationServer.notifications && notificationServer.notifications.length > 0 
        ? notificationServer.notifications[notificationServer.notifications.length - 1] 
        : null

    PanelWindow {
        id: notificationWindow
        
        // PanelWindow's native screen anchoring
        anchors {
            top: true
            right: true
        }
        
        implicitWidth: 300
        implicitHeight: 100
        
        margins {
            top: 50
            right: 20
        }

        exclusionMode: ExclusionMode.Ignore
        visible: currentNote != null
        color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#181825"
        radius: 12
        border.color: "#313244"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 45
                Layout.preferredHeight: 45
                radius: 8
                color: "#313244"
                
                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    source: currentNote && currentNote.icon ? Quickshell.iconPath(currentNote.icon) : ""
                    visible: source != ""
                }
                
                Text { 
                    anchors.centerIn: parent
                    text: "🔔" 
                    visible: !parent.children[0].visible
                }
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Text {
                    text: currentNote ? currentNote.summary : ""
                    color: "#cdd6f4"
                    font.bold: true
                    font.pixelSize: 14
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: currentNote ? currentNote.body : ""
                    color: "#a6adc8"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }
    }

        Timer {
            interval: 5000
            running: notificationWindow.visible
            onTriggered: if (currentNote) currentNote.dismiss()
        }
    }
}
