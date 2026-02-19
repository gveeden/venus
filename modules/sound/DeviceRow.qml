import "../../config"
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string deviceName: ""
    property bool isDefault: false

    signal activated

    implicitHeight: 34
    radius: Appearance.rounding.small
    color: isDefault ? Appearance.colors.primary : hoverArea.containsMouse ? Appearance.colors.hover : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 80
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Appearance.spacing.small
            rightMargin: Appearance.spacing.small
        }
        spacing: Appearance.spacing.small

        // Active indicator dot
        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: Appearance.colors.primary
            opacity: root.isDefault ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.deviceName
            color: root.isDefault ? Appearance.colors.text : Appearance.colors.textSecondary
            font.pixelSize: Appearance.font.regular
            font.family: Appearance.font.family
            elide: Text.ElideRight

            Behavior on color {
                ColorAnimation {
                    duration: 80
                }
            }
        }

        Text {
            text: "󰄬"
            color: Appearance.colors.primary
            font.family: Appearance.font.family
            font.pixelSize: Appearance.font.small
            visible: root.isDefault
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
