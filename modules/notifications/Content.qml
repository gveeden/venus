import "../../config"
import Quickshell
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var notification
    signal dismissClicked
    signal actionClicked(string actionId)

    // Match mako dimensions
    width: NotificationConfig.width
    height: mainLayout.height + Appearance.padding.large * 2

    // Urgency-based border color
    border.color: NotificationConfig.getBorderColor(root.notification ? root.notification.urgency : 1, Appearance.colors)
    border.width: NotificationConfig.borderSize

    // Styling
    color: Qt.rgba(Appearance.colors.surface.r, Appearance.colors.surface.g, Appearance.colors.surface.b, 0.95)
    radius: NotificationConfig.borderRadius

    // Track hover state
    property bool isHovered: false

    // Extract first URL from notification body
    readonly property string linkUrl: {
        if (!notification || !notification.body) return ""
        const match = notification.body.match(/https?:\/\/[^\s<>\"'`]+/)
        return match ? match[0] : ""
    }

    // Auto-dismiss timer
    Timer {
        id: dismissTimer
        interval: {
            if (!root.notification) return 5000;
            
            // Check potential property names for timeout from sender
            const timeout = root.notification.expireTimeout || root.notification.timeout || root.notification.expire_timeout;
            if (timeout && timeout > 0) return timeout;
            
            // Otherwise use config-based timeout
            return NotificationConfig.getTimeout(root.notification.urgency, root.notification.category);
        }
        running: interval > 0 && !root.isHovered  // Only run if there's a timeout and not hovering
        repeat: false
        onTriggered: {
            root.dismissClicked();
        }
    }

    // Click to dismiss
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: {
            root.dismissClicked();
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.medium

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.medium

            // App icon
            Rectangle {
                Layout.preferredWidth: NotificationConfig.iconSize
                Layout.preferredHeight: NotificationConfig.iconSize
                radius: Appearance.rounding.medium
                color: Appearance.colors.surfaceHighlight
                visible: root.notification && (root.notification.appIcon || root.notification.image)

                Image {
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.small
                    source: root.notification && root.notification.image ? root.notification.image : (root.notification && root.notification.appIcon ? Quickshell.iconPath(root.notification.appIcon) : "")
                    visible: source != ""
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    anchors.centerIn: parent
                    text: "🔔"
                    font.pixelSize: 24
                    visible: !parent.children[0].visible
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.tiny

                // App name row
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.notification ? (root.notification.appName || "Notification") : ""
                        color: Appearance.colors.textTertiary
                        font.pixelSize: Appearance.font.small
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Close button
                    Text {
                        text: "✕"
                        color: Appearance.colors.textTertiary
                        font.pixelSize: Appearance.font.small

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -5
                            onClicked: root.dismissClicked()
                        }
                    }
                }

                // Summary (title)
                Text {
                    text: root.notification ? root.notification.summary : ""
                    color: Appearance.colors.text
                    font.bold: true
                    font.pixelSize: Appearance.font.large
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                // Body text
                Text {
                    text: root.notification ? root.notification.body : ""
                    color: Appearance.colors.textSecondary
                    font.pixelSize: Appearance.font.regular
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    visible: text !== ""
                }
            }
        }

        // Action buttons row
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small
            visible: root.notification && (root.notification.actions.length > 0 || root.linkUrl !== "")

            // "Open" button — triggers the notification's default action
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: openMouseArea.containsMouse ? Appearance.colors.hover : Appearance.colors.surfaceHighlight
                radius: Appearance.rounding.small
                border.color: Appearance.colors.buttonBorder
                border.width: 1
                visible: root.notification && root.notification.actions.length > 0

                Text {
                    anchors.centerIn: parent
                    text: "Open"
                    color: Appearance.colors.text
                    font.pixelSize: Appearance.font.small
                    font.bold: true
                }

                MouseArea {
                    id: openMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.notification && root.notification.actions.length > 0)
                            root.actionClicked(root.notification.actions[0].identifier)
                    }
                }
            }

            // "Go to link" button — opens URL extracted from body
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: linkMouseArea.containsMouse ? Appearance.colors.hover : Appearance.colors.surfaceHighlight
                radius: Appearance.rounding.small
                border.color: Appearance.colors.buttonBorder
                border.width: 1
                visible: root.linkUrl !== ""

                Text {
                    anchors.centerIn: parent
                    text: "Go to link"
                    color: Appearance.colors.primary
                    font.pixelSize: Appearance.font.small
                    font.bold: true
                }

                MouseArea {
                    id: linkMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.linkUrl)
                            Qt.openUrlExternally(root.linkUrl)
                    }
                }
            }
        }
    }
}
