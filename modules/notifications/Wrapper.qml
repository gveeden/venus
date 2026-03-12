import "../../config"
import "../../services"
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "." as NotificationsPrivate

Scope {
    id: root

    PanelWindow {
        id: notificationArea

        anchors {
            top: true
            right: true
        }

        implicitWidth: NotificationConfig.width + NotificationConfig.rightMargin
        implicitHeight: notificationColumn.height + NotificationConfig.topMargin + 20

        exclusionMode: ExclusionMode.Ignore
        visible: notificationRepeater.count > 0
        color: "transparent"

        ColumnLayout {
            id: notificationColumn
            anchors {
                top: parent.top
                topMargin: NotificationConfig.topMargin
                right: parent.right
                rightMargin: NotificationConfig.rightMargin
            }
            width: NotificationConfig.width
            spacing: NotificationConfig.notificationSpacing

            Repeater {
                id: notificationRepeater
                model: Notifs.notifications

                NotificationsPrivate.Content {
                    notification: modelData
                    onDismissClicked: {
                        Notifs.dismiss(modelData);
                    }
                    onActionClicked: {
                        if (modelData.actions) {
                            for (let i = 0; i < modelData.actions.length; i++) {
                                if (modelData.actions[i].identifier === actionId) {
                                    modelData.actions[i].invoke();
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Window {
        id: historyWindow
        title: "qs-notifications"
        width: 400
        height: 500
        visible: false
        color: "transparent"

        property bool isVisible: false

        onIsVisibleChanged: {
            visible = isVisible;
            if (isVisible) {
                historyLayout.forceActiveFocus();
            }
        }

        Shortcut {
            sequence: "Escape"
            onActivated: historyWindow.isVisible = false
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Appearance.colors.background.r, Appearance.colors.background.g, Appearance.colors.background.b, 0.95)
            radius: Appearance.window.radius
            border.color: Appearance.colors.windowBorder
            border.width: Appearance.window.borderThickness
        }

        ColumnLayout {
            id: historyLayout
            focus: true

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.medium

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Notification History"
                    color: Appearance.colors.text
                    font.pointSize: Appearance.font.large
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "✕"
                    color: Appearance.colors.textSecondary
                    font.pixelSize: Appearance.font.regular

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -5
                        onClicked: historyWindow.isVisible = false
                    }
                }
            }

            // Button row: dismiss all live + clear history
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    color: dismissAllHover.containsMouse ? Appearance.colors.hover : Appearance.colors.surfaceHighlight
                    radius: Appearance.rounding.small
                    border.color: Appearance.colors.secondary
                    border.width: 1
                    visible: Notifs.notifications.count > 0

                    Text {
                        anchors.centerIn: parent
                        text: "Dismiss All"
                        color: Appearance.colors.secondary
                        font.pixelSize: Appearance.font.small
                        font.bold: true
                    }

                    MouseArea {
                        id: dismissAllHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.dismissAll()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    color: clearHistoryHover.containsMouse ? Appearance.colors.hover : Appearance.colors.surfaceHighlight
                    radius: Appearance.rounding.small
                    border.color: Appearance.colors.textTertiary
                    border.width: 1
                    visible: Notifs.history.length > 0

                    Text {
                        anchors.centerIn: parent
                        text: "Clear History"
                        color: Appearance.colors.textTertiary
                        font.pixelSize: Appearance.font.small
                        font.bold: true
                    }

                    MouseArea {
                        id: clearHistoryHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.clearHistory()
                    }
                }
            }

            ListView {
                id: historyList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: Appearance.spacing.small

                // Merge live notifications + dismissed history into one list.
                // Live entries come first (most recent action needed), then history.
                model: {
                    let combined = [];
                    // Add live notifications
                    for (let i = 0; i < Notifs.notifications.count; i++) {
                        let n = Notifs.notifications.get(i);
                        combined.push({
                            isLive: true,
                            liveRef: n,
                            appName: n.appName || "",
                            summary: n.summary || "",
                            body: n.body || "",
                            isCritical: n.urgency === 2, // NotificationUrgency.Critical
                            time: ""
                        });
                    }
                    // Add history entries
                    for (let i = 0; i < Notifs.history.length; i++) {
                        let e = Notifs.history[i];
                        let item = { isLive: false };
                        // Manually copy properties since spread isn't supported
                        item.appName = e.appName;
                        item.summary = e.summary;
                        item.body = e.body;
                        item.urgency = e.urgency;
                        item.isCritical = e.isCritical;
                        item.hasActions = e.hasActions;
                        item.time = e.time;
                        combined.push(item);
                    }
                    return combined;
                }

                delegate: Rectangle {
                    width: historyList.width
                    height: notifContent.height + Appearance.padding.medium * 2
                    color: modelData.isCritical ? Qt.rgba(Appearance.colors.secondary.r, Appearance.colors.secondary.g, Appearance.colors.secondary.b, 0.15) : Appearance.colors.surfaceHighlight
                    radius: Appearance.rounding.small
                    border.color: modelData.isCritical ? Appearance.colors.secondary : "transparent"
                    border.width: modelData.isCritical ? 1 : 0

                    ColumnLayout {
                        id: notifContent
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Appearance.padding.medium
                        }
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: modelData.appName || "Notification"
                                color: Appearance.colors.textTertiary
                                font.pixelSize: Appearance.font.small
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            // Timestamp for history entries
                            Text {
                                text: modelData.time || ""
                                color: Appearance.colors.textTertiary
                                font.pixelSize: Appearance.font.tiny
                                visible: !modelData.isLive && modelData.time !== ""
                            }

                            // Dismiss (live) or remove from history
                            Text {
                                text: "✕"
                                color: Appearance.colors.textTertiary
                                font.pixelSize: Appearance.font.small

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -5
                                    onClicked: {
                                        if (modelData.isLive)
                                            Notifs.dismiss(modelData.liveRef);
                                        else
                                            Notifs.removeFromHistory(modelData);
                                    }
                                }
                            }
                        }

                        Text {
                            text: modelData.summary || ""
                            color: Appearance.colors.text
                            font.bold: true
                            font.pixelSize: Appearance.font.regular
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            text: modelData.body || ""
                            color: Appearance.colors.textSecondary
                            font.pixelSize: Appearance.font.small
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            visible: modelData.body !== ""
                        }

                        // "Dismissed" badge for history entries
                        Text {
                            text: modelData.isCritical ? "⚠ Critical · Dismissed" : "Dismissed"
                            color: modelData.isCritical ? Appearance.colors.secondary : Appearance.colors.textTertiary
                            font.pixelSize: Appearance.font.tiny
                            visible: !modelData.isLive
                        }
                    }
                }
            }
        }
    }

    function openHistory() {
        historyWindow.isVisible = true;
    }
}
