import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"

ColumnLayout {
    anchors.fill: parent
    anchors.margins: Appearance.padding.xlarge
    spacing: Appearance.spacing.medium

    // Header
    Text {
        text: "Memory Status"
        color: Appearance.colors.text
        font.pixelSize: Appearance.font.xlarge
        font.bold: true
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.colors.border
    }

    // Main memory section
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        Text {
            text: "Physical RAM"
            color: Appearance.colors.primary
            font.pixelSize: Appearance.font.large
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.medium

            Text {
                text: Memory.usagePercentStr
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.xlarge
                font.bold: true
            }

            Text {
                text: Memory.usedStr + " / " + Memory.totalStr
                color: Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.medium
            }
        }

        // Memory bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            color: Appearance.colors.surfaceHighlight
            radius: Appearance.rounding.small

            Rectangle {
                width: parent.width * (Memory.memoryUsagePercent / 100)
                height: parent.height
                color: {
                    const percent = Memory.memoryUsagePercent;
                    if (percent > 90) return Appearance.colors.secondary;
                    if (percent > 70) return "#FFA500";
                    return Appearance.colors.primary;
                }
                radius: parent.radius
            }
        }
    }

    Item { Layout.preferredHeight: Appearance.spacing.small }

    // Swap section
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        Text {
            text: "Swap Space"
            color: Appearance.colors.primary
            font.pixelSize: Appearance.font.large
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.medium

            Text {
                text: Math.round(Memory.swapUsagePercent) + "%"
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.xlarge
                font.bold: true
            }

            Text {
                text: Math.round(Memory.swapUsed/1024) + "MB / " + Math.round(Memory.swapTotal/1024) + "MB"
                color: Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.medium
            }
        }
        
        // Swap bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            color: Appearance.colors.surfaceHighlight
            radius: Appearance.rounding.small

            Rectangle {
                width: parent.width * (Memory.swapUsagePercent / 100)
                height: parent.height
                color: Appearance.colors.secondaryContainer
                radius: parent.radius
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.colors.border
        Layout.topMargin: Appearance.spacing.medium
        Layout.bottomMargin: Appearance.spacing.medium
    }

    // Top processes section
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Appearance.spacing.small

        Text {
            text: "Top Processes"
            color: Appearance.colors.primary
            font.pixelSize: Appearance.font.large
            font.bold: true
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: topAppsColumn.implicitHeight
            clip: true

            ColumnLayout {
                id: topAppsColumn
                width: parent.width
                spacing: Appearance.spacing.small

                Repeater {
                    model: Memory.topApps
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: Appearance.colors.surfaceHighlight
                        radius: Appearance.rounding.small

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Appearance.padding.medium
                            spacing: Appearance.spacing.medium

                            Text {
                                text: modelData.name
                                color: Appearance.colors.text
                                font.pixelSize: Appearance.font.medium
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.mem
                                color: Appearance.colors.textSecondary
                                font.pixelSize: Appearance.font.medium
                                font.bold: true
                            }
                        }
                    }
                }
                
                // No apps fallback
                Text {
                    text: "No process data available"
                    color: Appearance.colors.textTertiary
                    font.pixelSize: Appearance.font.medium
                    visible: Memory.topApps.length === 0
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
