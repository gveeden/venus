import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Window {
    id: launcher
    title: "qs-launcher"
    width: 800
    height: 450
    visible: true 
    color: "transparent"

    property string search: ""

    // Ensures the search box grabs focus every time the window appears
    onVisibleChanged: {
        if (visible) {
            input.forceActiveFocus()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 12
        border.color: "#313244"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            // 1. Search Box
            TextField {
                id: input
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                placeholderText: "Search apps..."
                placeholderTextColor: "#cdd6f4"
                focus: true
                font.pointSize: 14
                
                background: Rectangle {
                    color: "#313244"
                    radius: 8
                }
                color: "#cdd6f4"
                
                onTextChanged: {
                    launcher.search = text;
                    appList.currentIndex = 0; // Highlight first item on new search
                }
                
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        launcher.visible = false;
                    }
                    
                    // Down arrow moves focus to the list
                    if (event.key === Qt.Key_Down) {
                        appList.focus = true;
                        event.accepted = true;
                    }
                    
                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        if (appList.currentItem) appList.currentItem.launch();
                    }
                }
            }

            // 2. The List
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                
                // Enables native arrow key index management
                keyNavigationEnabled: true
                highlightFollowsCurrentItem: true
                
                model: DesktopEntries.applications.values
                    .slice()
                    .sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()))
                    .filter(app => app.name.toLowerCase().includes(launcher.search.toLowerCase()))

                delegate: ItemDelegate {
                    id: delegateItem
                    width: appList.width
                    height: 50
                    
                    // Attached property to detect arrow-key selection
                    readonly property bool isSelected: ListView.isCurrentItem

                    function launch() {
                        modelData.execute();
                        launcher.visible = false;
                        launcher.search = "";
                        input.text = "";
                    }

                    background: Rectangle {
                        // Combines hover and arrow-selection states
                        color: (delegateItem.hovered || delegateItem.isSelected) ? "#45475a" : "transparent"
                        opacity: 0.6
                        radius: 6
                    }

                    contentItem: RowLayout {
                        spacing: 12
                        anchors.fill: parent 
                        anchors.leftMargin: 12
                        Image {
                            source: Quickshell.iconPath(modelData.icon)
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Text {
                            text: modelData.name
                            color: "#cdd6f4"
                            font.pointSize: 12
                            verticalAlignment: Text.AlignVCenter
                            Layout.fillWidth: true 
                            elide: Text.ElideRight
                        }
                    }

                    onClicked: launch()
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            launcher.visible = false;
                            event.accepted = true;
                        }
                        
                        // Up arrow at the top of the list moves focus back to search
                        if (event.key === Qt.Key_Up && appList.currentIndex === 0) {
                            input.focus = true;
                            event.accepted = true;
                        }
                        
                        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                            launch();
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }
}
