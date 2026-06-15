import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../config"
import "../../services"

ColumnLayout {
    id: root
    width: parent.width
    anchors.margins: Appearance.padding.xlarge
    spacing: Appearance.spacing.medium

    property bool isEditingLocation: false
    property bool requestsKeyboardFocus: isEditingLocation

    // Header: Location
    Item {
        Layout.fillWidth: true
        Layout.topMargin: 20
        Layout.preferredHeight: 30

        Text {
            id: locationText
            visible: !root.isEditingLocation
            anchors.centerIn: parent
            text: WService.location
            color: Appearance.colors.text
            font.family: Appearance.font.family
            font.pixelSize: Appearance.font.large
            font.bold: true
        }

        Rectangle {
            visible: root.isEditingLocation
            anchors.centerIn: parent
            width: 150
            height: 30
            color: "transparent"
            border.color: Appearance.colors.border
            border.width: 1
            radius: 4

            TextInput {
                id: locationInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                color: Appearance.colors.text
                font.family: Appearance.font.family
                font.pixelSize: Appearance.font.medium
                verticalAlignment: TextInput.AlignVCenter
                selectByMouse: true
                
                Timer {
                    id: focusTimer
                    interval: 50
                    onTriggered: locationInput.forceActiveFocus()
                }
                
                onVisibleChanged: {
                    if (visible) focusTimer.restart();
                }
                
                onTextChanged: {
                    if (root.isEditingLocation && text.trim().length > 1) {
                        searchDebounce.restart();
                    } else {
                        suggestionsModel.clear();
                    }
                }
                onAccepted: {
                    WService.customLocation = text;
                    WService.update();
                    root.isEditingLocation = false;
                }
                Keys.onEscapePressed: {
                    root.isEditingLocation = false;
                }
            }

            Rectangle {
                visible: root.isEditingLocation && suggestionsModel.count > 0
                anchors.top: parent.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: parent.horizontalCenter
                width: 250
                height: Math.min(suggestionsModel.count * 30, 150)
                color: Appearance.colors.surfaceHighlight
                border.color: Appearance.colors.primary
                border.width: 1
                radius: 4
                z: 100
                clip: true
                
                ListView {
                    anchors.fill: parent
                    model: suggestionsModel
                    delegate: Rectangle {
                        width: parent.width
                        height: 30
                        color: hoverArea.containsMouse ? Appearance.colors.surface : "transparent"
                        
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: Text.AlignVCenter
                            text: model.name + (model.admin1 ? ", " + model.admin1 : "") + (model.country ? ", " + model.country : "")
                            color: Appearance.colors.text
                            font.family: Appearance.font.family
                            font.pixelSize: Appearance.font.medium
                            elide: Text.ElideRight
                        }
                        
                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                locationInput.text = model.name + (model.admin1 ? ", " + model.admin1 : "") + (model.country ? ", " + model.country : "");
                                WService.customLocation = locationInput.text;
                                WService.update();
                                root.isEditingLocation = false;
                                suggestionsModel.clear();
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            color: Appearance.colors.textSecondary
            font.family: Appearance.font.family
            font.pixelSize: Appearance.font.medium
            
            MouseArea {
                anchors.fill: parent
                anchors.margins: -5
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.isEditingLocation = !root.isEditingLocation;
                    if (root.isEditingLocation) {
                        locationInput.text = WService.customLocation;
                        locationInput.forceActiveFocus();
                    }
                }
            }
        }
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

    ListModel {
        id: suggestionsModel
    }

    Timer {
        id: searchDebounce
        interval: 300
        onTriggered: {
            if (locationInput.text.trim() === "") return;
            searchProcess.command = ["curl", "-s", "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(locationInput.text.trim()) + "&count=5&language=en&format=json"];
            searchProcess.running = true;
        }
    }

    Process {
        id: searchProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(text);
                    suggestionsModel.clear();
                    if (data.results) {
                        for (let i = 0; i < data.results.length; i++) {
                            let res = data.results[i];
                            suggestionsModel.append({
                                name: res.name || "",
                                admin1: res.admin1 || "",
                                country: res.country || ""
                            });
                        }
                    }
                } catch (e) {
                    console.log("[Content] Autocomplete parse error:", e);
                }
            }
        }
    }
}
