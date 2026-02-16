import "../../config"
import "../../services"
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "." as NotificationsPrivate

Scope {
    id: root
    
    // Layer mode for overlay (mako: layer=overlay)
    PanelWindow {
        id: notificationArea
        
        anchors {
            top: true
            right: true
        }
        
        // Width matches single notification width
        implicitWidth: NotificationConfig.width
        // Height expands to fit all notifications
        implicitHeight: notificationColumn.height + NotificationConfig.topMargin + 20
        
        margins {
            top: 0  // Handle top margin in the column
            right: NotificationConfig.rightMargin
        }

        // Ignore exclusion zones to overlay on top (mako: layer=overlay)
        exclusionMode: ExclusionMode.Ignore
        visible: notificationRepeater.count > 0
        color: "transparent"

        ColumnLayout {
            id: notificationColumn
            anchors {
                top: parent.top
                topMargin: NotificationConfig.topMargin
                right: parent.right
            }
            width: NotificationConfig.width
            spacing: NotificationConfig.notificationSpacing
            
            Repeater {
                id: notificationRepeater
                model: Notifs.notifications
                
                NotificationsPrivate.Content {
                    notification: modelData
                    onDismissClicked: {
                        Notifs.dismiss(modelData)
                    }
                    onActionClicked: {
                        // Find and invoke the action
                        if (modelData.actions) {
                            for (let i = 0; i < modelData.actions.length; i++) {
                                if (modelData.actions[i].identifier === actionId) {
                                    modelData.actions[i].invoke()
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
