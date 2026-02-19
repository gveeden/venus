import "../../config"
import "../../services"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    anchors.fill: parent
    anchors.margins: Appearance.padding.xlarge
    spacing: Appearance.spacing.medium

    // Header
    Text {
        text: "Sound"
        color: Appearance.colors.text
        font.bold: true
        font.pixelSize: Appearance.font.xlarge
    }

    // Volume row
    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        // Mute toggle button
        Rectangle {
            width: 28
            height: 28
            radius: Appearance.rounding.small
            color: muteArea.containsMouse ? Appearance.colors.hover : "transparent"

            Text {
                anchors.centerIn: parent
                text: Audio.isMuted ? "󰝟" : Audio.volume > 50 ? "󰕾" : Audio.volume > 0 ? "󰖀" : "󰕿"
                color: Audio.isMuted ? Appearance.colors.secondary : Appearance.colors.text
                font.family: Appearance.font.family
                font.pixelSize: Appearance.font.large
            }

            MouseArea {
                id: muteArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Audio.toggleMute()
            }
        }

        // Volume slider track
        Rectangle {
            id: sliderTrack
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: Appearance.colors.surface

            // Filled portion
            Rectangle {
                width: parent.width * Math.min(Audio.volume, 100) / 100
                height: parent.height
                radius: parent.radius
                color: Audio.isMuted ? Appearance.colors.textTertiary : Appearance.colors.primary
            }

            MouseArea {
                anchors.fill: parent
                // Extend hit area above/below the thin track for easier grab
                anchors.topMargin: -8
                anchors.bottomMargin: -8
                hoverEnabled: true
                onPressed: mouse => Audio.setVolume(Math.round(mouse.x / width * 100))
                onPositionChanged: mouse => {
                    if (pressed)
                        Audio.setVolume(Math.max(0, Math.min(100, Math.round(mouse.x / width * 100))));
                }
            }
        }

        // Volume label
        Text {
            text: Audio.isMuted ? "Muted" : Audio.volume + "%"
            color: Appearance.colors.textSecondary
            font.pixelSize: Appearance.font.small
            font.family: Appearance.font.family
            horizontalAlignment: Text.AlignRight
            Layout.minimumWidth: 40
        }
    }

    // Divider
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.colors.border
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Appearance.spacing.medium

        // Output devices
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            Text {
                text: "Output"
                color: Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.small
                font.bold: true
                font.family: Appearance.font.family
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: outputColumn.implicitHeight + Appearance.spacing.small * 2
                color: Appearance.colors.surface
                radius: Appearance.rounding.medium

                ColumnLayout {
                    id: outputColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Appearance.spacing.small
                    }
                    spacing: Appearance.spacing.tiny

                    Repeater {
                        model: Audio.sinks
                        delegate: DeviceRow {
                            required property var modelData
                            Layout.fillWidth: true
                            deviceName: modelData.description
                            isDefault: modelData.name === Audio.defaultSink
                            onActivated: Audio.setDefaultSink(modelData.name)
                        }
                    }

                    Text {
                        text: "No output devices"
                        color: Appearance.colors.textTertiary
                        font.pixelSize: Appearance.font.small
                        font.family: Appearance.font.family
                        visible: Audio.sinks.length === 0
                        Layout.alignment: Qt.AlignHCenter
                        topPadding: Appearance.spacing.small
                        bottomPadding: Appearance.spacing.small
                    }
                }
            }
        }

        // Input devices
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            Text {
                text: "Input"
                color: Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.small
                font.bold: true
                font.family: Appearance.font.family
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: inputColumn.implicitHeight + Appearance.spacing.small * 2
                color: Appearance.colors.surface
                radius: Appearance.rounding.medium

                ColumnLayout {
                    id: inputColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Appearance.spacing.small
                    }
                    spacing: Appearance.spacing.tiny

                    Repeater {
                        model: Audio.sources
                        delegate: DeviceRow {
                            required property var modelData
                            Layout.fillWidth: true
                            deviceName: modelData.description
                            isDefault: modelData.name === Audio.defaultSource
                            onActivated: Audio.setDefaultSource(modelData.name)
                        }
                    }

                    Text {
                        text: "No input devices"
                        color: Appearance.colors.textTertiary
                        font.pixelSize: Appearance.font.small
                        font.family: Appearance.font.family
                        visible: Audio.sources.length === 0
                        Layout.alignment: Qt.AlignHCenter
                        topPadding: Appearance.spacing.small
                        bottomPadding: Appearance.spacing.small
                    }
                }
            }
        }
    }
}
