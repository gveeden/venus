import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"

ColumnLayout {
    id: root
    width: parent.width
    anchors.margins: Appearance.padding.xlarge
    spacing: Appearance.spacing.medium

    // Header: Location
    Text {
        text: WService.location
        color: Appearance.colors.text
        font.family: Appearance.font.family
        font.pixelSize: Appearance.font.large
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 20
    }

    // Current WService Large Icon + Temp
    RowLayout {
        spacing: Appearance.spacing.xlarge
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 20
        Layout.bottomMargin: 20

        Text {
            text: WService.weatherIcon
            color: Appearance.colors.primary
            font.family: Appearance.font.family
            font.pixelSize: 64
        }

        ColumnLayout {
            spacing: 0
            Text {
                text: WService.tempC
                color: Appearance.colors.text
                font.family: Appearance.font.family
                font.pixelSize: 48
                font.bold: true
            }
            Text {
                text: WService.description
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family
                font.pixelSize: Appearance.font.medium
            }
        }
    }

    // Details Grid
    GridLayout {
        columns: 2
        rowSpacing: Appearance.spacing.medium
        columnSpacing: Appearance.spacing.xlarge
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true

        // Feels Like
        RowLayout {
            Layout.alignment: Qt.AlignLeft
            Text { text: "󰈐"; color: Appearance.colors.primary; font.family: Appearance.font.family; font.pixelSize: 18 }
            Text { text: "Feels like: " + WService.feelsLikeC; color: Appearance.colors.textSecondary; font.family: Appearance.font.family; font.pixelSize: 16 }
        }

        // Humidity
        RowLayout {
            Layout.alignment: Qt.AlignLeft
            Text { text: "󰖚"; color: Appearance.colors.primary; font.family: Appearance.font.family; font.pixelSize: 18 }
            Text { text: "Humidity: " + WService.humidity; color: Appearance.colors.textSecondary; font.family: Appearance.font.family; font.pixelSize: 16 }
        }

        // Wind
        RowLayout {
            Layout.alignment: Qt.AlignLeft
            Text { text: "󰖝"; color: Appearance.colors.primary; font.family: Appearance.font.family; font.pixelSize: 18 }
            Text { text: "Wind: " + WService.windSpeed; color: Appearance.colors.textSecondary; font.family: Appearance.font.family; font.pixelSize: 16 }
        }
    }

    // Forecast divider
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.colors.border
        Layout.topMargin: 20
        Layout.bottomMargin: 10
    }

    // Forecast Row
    Row {
        Layout.fillWidth: true
        height: 100
        
        Repeater {
            model: WService.forecast
            delegate: Item {
                width: parent.width / WService.forecast.length
                height: parent.height

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: {
                            const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                            const d = new Date(modelData.date);
                            return days[d.getDay()];
                        }
                        color: Appearance.colors.textTertiary
                        font.family: Appearance.font.family
                        font.pixelSize: Appearance.font.regular
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: modelData.icon
                        color: Appearance.colors.primary
                        font.family: Appearance.font.family
                        font.pixelSize: 32
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: modelData.avgTemp
                        color: Appearance.colors.textSecondary
                        font.family: Appearance.font.family
                        font.pixelSize: Appearance.font.medium
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
    
    // Bottom padding to match Top
    Item { height: 20 }
}
