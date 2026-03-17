import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"

ColumnLayout {
    id: root
    spacing: 24
    anchors.fill: parent
    anchors.margins: 20

    function moveWidget(fromId, toId, fromType, toType) {
        let visibleOrder = BarConfig.widgetOrder.slice();
        let hiddenOrder = BarConfig.hiddenWidgets.slice();
        
        let sourceList = fromType === "visible" ? visibleOrder : hiddenOrder;
        let targetList = toType === "visible" ? visibleOrder : hiddenOrder;
        
        let fromIdx = sourceList.indexOf(fromId);
        let toIdx = targetList.indexOf(toId);
        
        if (fromIdx !== -1 && toIdx !== -1) {
            // Remove from source
            let item = sourceList.splice(fromIdx, 1)[0];
            
            // If same list, recalculate toIdx after removal and use sourceList as target
            if (fromType === toType) {
                toIdx = targetList.indexOf(toId);
                targetList = sourceList;
            }
            
            // Insert at target position
            targetList.splice(toIdx, 0, item);
            
            // Assign the modified arrays back
            BarConfig.widgetOrder = visibleOrder;
            BarConfig.hiddenWidgets = hiddenOrder;
            barOrderStorage.save();
        }
    }
    
    // Add logic to move a widget to an empty list or container background
    function moveToEmptyList(fromId, fromType, toType) {
        let visibleOrder = BarConfig.widgetOrder.slice();
        let hiddenOrder = BarConfig.hiddenWidgets.slice();
        
        let sourceList = fromType === "visible" ? visibleOrder : hiddenOrder;
        let targetList = toType === "visible" ? visibleOrder : hiddenOrder;
        
        let fromIdx = sourceList.indexOf(fromId);
        if (fromIdx !== -1) {
            let item = sourceList.splice(fromIdx, 1)[0];
            targetList.push(item);
            
            // Assign the modified arrays back
            BarConfig.widgetOrder = visibleOrder;
            BarConfig.hiddenWidgets = hiddenOrder;
            barOrderStorage.save();
        }
    }

    Text {
        text: "Visible Widgets (drag to reorder or hide)"
        color: Appearance.colors.textSecondary
        font.pixelSize: 16
        font.weight: Font.Bold
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        color: Appearance.colors.surface
        radius: 8
        border.color: Appearance.colors.border
        
        Item {
            anchors.fill: parent
            
            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Repeater {
                    model: BarConfig.widgetOrder
                    delegate: SettingsWidgetDelegate {
                        widgetId: modelData
                        listType: "visible"
                        onMoved: (fId, tId, fT, tT) => root.moveWidget(fId, tId, fT, tT)
                    }
                }
            }
            
            // Container DropArea to catch drops on background
            DropArea {
                anchors.fill: parent
                onEntered: drag => {
                    let targetList = BarConfig.widgetOrder;
                    if (drag.source.widgetId && targetList.indexOf(drag.source.widgetId) === -1) {
                        root.moveToEmptyList(drag.source.widgetId, drag.source.listType, "visible");
                    }
                }
            }
        }
    }

    Text {
        text: "Hidden Widgets (autohide list)"
        color: Appearance.colors.textSecondary
        font.pixelSize: 16
        font.weight: Font.Bold
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        color: Appearance.colors.surface
        radius: 8
        border.color: Appearance.colors.border
        
        Item {
            anchors.fill: parent

            Flow {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Repeater {
                    model: BarConfig.hiddenWidgets
                    delegate: SettingsWidgetDelegate {
                        widgetId: modelData
                        listType: "hidden"
                        onMoved: (fId, tId, fT, tT) => root.moveWidget(fId, tId, fT, tT)
                    }
                }
            }
            
            // Container DropArea to catch drops on background
            DropArea {
                anchors.fill: parent
                onEntered: drag => {
                    let targetList = BarConfig.hiddenWidgets;
                    if (drag.source.widgetId && targetList.indexOf(drag.source.widgetId) === -1) {
                        root.moveToEmptyList(drag.source.widgetId, drag.source.listType, "hidden");
                    }
                }
            }
        }
    }
    
    Item { Layout.fillHeight: true }
}
