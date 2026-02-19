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
    
    // Auto-dismiss timer - disabled for now to support notification history
    // Timer {
    //     id: dismissTimer
    //     interval: root.notification ? NotificationConfig.getTimeout(root.notification.urgency, root.notification.category) : 5000
    //     running: interval > 0 && !root.isHovered  // Only run if there's a timeout and not hovering
    //     repeat: false
    //     onTriggered: {
    //         root.dismissClicked();
    //     }
    // }

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

        // Action buttons (shown inline in the ColumnLayout)
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small
            visible: root.notification && root.notification.actions && root.notification.actions.length > 0

            Repeater {
                model: root.notification ? root.notification.actions : []

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: mouseArea.containsMouse ? Appearance.colors.hover : Appearance.colors.surfaceHighlight
                    radius: Appearance.rounding.small
                    border.color: Appearance.colors.buttonBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: modelData.text || modelData.identifier
                        color: Appearance.colors.text
                        font.pixelSize: Appearance.font.small
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.actionClicked(modelData.identifier);
                        }
                    }
                }
            }
        }
    }
}
