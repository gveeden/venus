pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    NotificationServer {
        id: notifServer
        imageSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        persistenceSupported: true
    }

    readonly property var notifications: notifServer.trackedNotifications

    Connections {
        target: notifServer
        function onNotification(notification) {
            console.log("[Notifs] Received notification:", notification.summary)
            notification.tracked = true
        }
    }

    // Dismiss a notification
    function dismiss(notification): void {
        if (notification) {
            notification.dismiss()
        }
    }

    // Dismiss all notifications
    function dismissAll(): void {
        if (!notifications) return

        // Copy to array first since we'll be modifying the list
        let toDismiss = []
        let count = notifications.count || 0
        for (let i = 0; i < count; i++) {
            toDismiss.push(notifications.get(i))
        }

        for (let notif of toDismiss) {
            notif.dismiss()
        }
    }
}
