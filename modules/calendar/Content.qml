import "../../config"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    property date currentDate: new Date()
    readonly property int currMonth: currentDate.getMonth()
    readonly property int currYear: currentDate.getFullYear()

    spacing: 12

    // Month/Year navigation
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            width: 32
            height: 32
            color: "transparent"

            Text {
                text: "<"
                color: Appearance.colors.primary
                font.pixelSize: 18
                font.weight: Font.Bold
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.currentDate = new Date(root.currYear, root.currMonth - 1, 1)
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: grid.title
            color: Appearance.colors.primary
            font.pixelSize: 16
            font.weight: Font.Medium
            font.capitalization: Font.Capitalize
            Layout.alignment: Qt.AlignHCenter

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                onClicked: root.currentDate = new Date()
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Rectangle {
            width: 32
            height: 32
            color: "transparent"

            Text {
                text: ">"
                color: Appearance.colors.primary
                font.pixelSize: 18
                font.weight: Font.Bold
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.currentDate = new Date(root.currYear, root.currMonth + 1, 1)
            }
        }
    }

    // Day of week headers
    DayOfWeekRow {
        Layout.fillWidth: true
        locale: grid.locale

        delegate: Text {
            required property var model

            horizontalAlignment: Text.AlignHCenter
            text: model.shortName
            font.pixelSize: 12
            font.weight: Font.Medium
            color: (model.day === 0 || model.day === 6) ? Appearance.colors.secondary : Appearance.colors.textTertiary
        }
    }

    // Calendar grid
    Item {
        Layout.fillWidth: true
        implicitHeight: grid.implicitHeight

        MonthGrid {
            id: grid

            month: root.currMonth
            year: root.currYear

            anchors.fill: parent

            spacing: 4
            locale: Qt.locale()

            delegate: Item {
                id: dayItem

                required property var model

                implicitWidth: implicitHeight
                implicitHeight: 32

                Rectangle {
                    anchors.fill: parent
                    color: dayItem.model.today ? Appearance.colors.primary : "transparent"
                    radius: 4
                    opacity: dayItem.model.today ? 0.2 : 1
                }

                Text {
                    id: dayText

                    anchors.centerIn: parent

                    horizontalAlignment: Text.AlignHCenter
                    text: grid.locale.toString(dayItem.model.day)
                    color: {
                        if (dayItem.model.today) return Appearance.colors.primary
                        const dayOfWeek = dayItem.model.date.getUTCDay()
                        if (dayOfWeek === 0 || dayOfWeek === 6)
                            return Appearance.colors.secondary
                        return Appearance.colors.text
                    }
                    font.pixelSize: 13
                    font.weight: dayItem.model.today ? Font.Bold : Font.Normal
                    opacity: dayItem.model.month === grid.month ? 1 : 0.4
                }
            }
        }
    }

    // Click on empty space to go to today
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onClicked: root.currentDate = new Date()
    }
}
