pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    property var server: NotificationServer {}

    readonly property var notifications: server.notifications
    readonly property var currentNotification: notifications && notifications.length > 0 
        ? notifications[notifications.length - 1] 
        : null
}
