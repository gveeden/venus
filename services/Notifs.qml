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

    // Live notifications (undismissed) — used for popups
    readonly property var notifications: notifServer.trackedNotifications

    // History: retains dismissed notifications that were critical or had actions.
    // Each entry is a plain JS object snapshot so it survives dismissal.
    property var history: []

    Connections {
        target: notifServer
        function onNotification(notification) {
            console.log("[Notifs] Received notification:", notification.summary)
            notification.tracked = true
        }
    }

    // Dismiss a notification, saving it to history if it qualifies
    function dismiss(notification): void {
        if (!notification) return
        _saveToHistory(notification)
        notification.dismiss()
    }

    // Dismiss all notifications
    function dismissAll(): void {
        if (!notifications) return
        let toDismiss = [...notifications]
        for (let notif of toDismiss) {
            if (notif) {
                _saveToHistory(notif)
                notif.dismiss()
            }
        }
    }

    // Remove a single entry from the history list
    function removeFromHistory(entry): void {
        root.history = root.history.filter(e => e !== entry)
    }

    // Clear the entire history
    function clearHistory(): void {
        root.history = []
    }

    // Snapshot a notification into history if it was critical or had actions
    function _saveToHistory(notification): void {
        const isCritical = (notification.urgency === NotificationUrgency.Critical)
        const hasActions = notification.actions && notification.actions.length > 0
        if (!isCritical && !hasActions) return

        const entry = {
            appName:   notification.appName   || "",
            summary:   notification.summary   || "",
            body:      notification.body       || "",
            urgency:   notification.urgency,
            isCritical: isCritical,
            hasActions: hasActions,
            time:      new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
        }
        // Prepend so newest is at the top
        root.history = [entry, ...root.history]
    }
}
