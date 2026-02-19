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

        implicitWidth: NotificationConfig.width
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
                forceActiveFocus();
            }
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

            Text {
                text: "Clear All"
                color: Appearance.colors.error
                font.pixelSize: Appearance.font.small

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    onClicked: Notifs.dismissAll()
                }
            }

            ListView {
                id: historyList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: Appearance.spacing.small
                focus: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        historyWindow.isVisible = false;
                        event.accepted = true;
                    }
                }

                model: Notifs.notifications

                delegate: Rectangle {
                    width: historyList.width
                    height: notificationItem.height + Appearance.padding.medium * 2
                    color: Appearance.colors.surfaceHighlight
                    radius: Appearance.rounding.small

                    property var notif: modelData

                    ColumnLayout {
                        id: notificationItem
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
                                text: notif.appName || "Notification"
                                color: Appearance.colors.textTertiary
                                font.pixelSize: Appearance.font.small
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "✕"
                                color: Appearance.colors.textTertiary
                                font.pixelSize: Appearance.font.small

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -5
                                    onClicked: Notifs.dismiss(notif)
                                }
                            }
                        }

                        Text {
                            text: notif.summary || ""
                            color: Appearance.colors.text
                            font.bold: true
                            font.pixelSize: Appearance.font.regular
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            text: notif.body || ""
                            color: Appearance.colors.textSecondary
                            font.pixelSize: Appearance.font.small
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            visible: notif.body && notif.body !== ""
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
