import "../../config"
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: Appearance.spacing.large

    property string search: ""
    signal requestClose()

    function focusSearch() {
        input.forceActiveFocus()
    }

    TextField {
        id: input
        Layout.fillWidth: true
        Layout.preferredHeight: LauncherConfig.searchBoxHeight
        placeholderText: "Search apps..."
        placeholderTextColor: Appearance.colors.text
        focus: true
        font.pointSize: Appearance.font.large
        
        background: Rectangle {
            color: Appearance.colors.surfaceHighlight
            radius: Appearance.rounding.medium
        }
        color: Appearance.colors.text
        
        onTextChanged: {
            root.search = text
            appList.currentIndex = 0
        }
        
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                root.requestClose()
            }
            
            if (event.key === Qt.Key_Down) {
                appList.focus = true
                event.accepted = true
            }
            
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                if (appList.currentItem) appList.currentItem.launch()
            }
        }
    }

    ListView {
        id: appList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: Appearance.spacing.small
        
        keyNavigationEnabled: true
        highlightFollowsCurrentItem: true
        
        model: DesktopEntries.applications.values
            .slice()
            .sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()))
            .filter(app => app.name.toLowerCase().includes(root.search.toLowerCase()))

        delegate: ItemDelegate {
            id: delegateItem
            width: appList.width
            height: LauncherConfig.itemHeight
            
            readonly property bool isSelected: ListView.isCurrentItem

            function launch() {
                modelData.execute()
                root.requestClose()
                root.search = ""
                input.text = ""
            }

            background: Rectangle {
                color: (delegateItem.hovered || delegateItem.isSelected) 
                    ? Appearance.colors.hover 
                    : "transparent"
                opacity: 0.6
                radius: Appearance.rounding.small
            }

            contentItem: RowLayout {
                spacing: Appearance.spacing.medium
                anchors.fill: parent 
                anchors.leftMargin: Appearance.padding.large

                Image {
                    source: Quickshell.iconPath(modelData.icon)
                    Layout.preferredWidth: LauncherConfig.iconSize
                    Layout.preferredHeight: LauncherConfig.iconSize
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: modelData.name
                    color: Appearance.colors.text
                    font.pointSize: Appearance.font.regular
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillWidth: true 
                    elide: Text.ElideRight
                }
            }

            onClicked: launch()
            
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    root.requestClose()
                    event.accepted = true
                }
                
                if (event.key === Qt.Key_Up && appList.currentIndex === 0) {
                    input.focus = true
                    event.accepted = true
                }
                
                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    launch()
                    event.accepted = true
                }
            }
        }
    }
}
