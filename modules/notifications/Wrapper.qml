import "../../config"
import "../../services"
import Quickshell
import Quickshell.Widgets
import QtQuick

Scope {
    PanelWindow {
        id: notificationWindow
        
        anchors {
            top: true
            right: true
        }
        
        implicitWidth: NotificationConfig.width
        implicitHeight: NotificationConfig.height
        
        margins {
            top: NotificationConfig.topMargin
            right: NotificationConfig.rightMargin
        }

        exclusionMode: ExclusionMode.Ignore
        visible: Notifs.currentNotification != null
        color: "transparent"

        Content {
            anchors.fill: parent
            notification: Notifs.currentNotification
        }

        Timer {
            interval: NotificationConfig.dismissTimeout
            running: notificationWindow.visible
            onTriggered: {
                if (Notifs.currentNotification) {
                    Notifs.currentNotification.dismiss()
                }
            }
        }
    }
}
