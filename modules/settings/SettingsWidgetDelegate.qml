import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"

Rectangle {
    id: root
    property string widgetId
    property string listType // "visible" or "hidden"
    
    width: 120
    height: 40
    
    color: dragHandler.active ? Appearance.colors.primaryContainer : Appearance.colors.surfaceHighlight
    border.color: dragHandler.active ? Appearance.colors.primary : Appearance.colors.border
    border.width: 1
    radius: 6
    
    signal moved(string fromId, string toId, string fromType, string toType)

    // Ensure dragged item is on top
    z: dragHandler.active ? 100 : 1
    
    // Smooth transition when layout updates, disabled during drag
    Behavior on x { enabled: !dragHandler.active; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on y { enabled: !dragHandler.active; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    Text {
        anchors.centerIn: parent
        text: root.widgetId
        color: Appearance.colors.text
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    DragHandler {
        id: dragHandler
        target: root
        xAxis.enabled: true
        yAxis.enabled: true
        
        onActiveChanged: {
            if (!active) {
                root.x = 0
                root.y = 0
                barOrderStorage.save()
                root.resetDragTracker()
            }
        }
    }

    property bool hasMoved: false

    function resetDragTracker() {
        root.hasMoved = false
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        
        onEntered: drag => {
            if (drag.source !== root && drag.source.widgetId !== undefined && !root.hasMoved) {
                root.hasMoved = true
                root.moved(drag.source.widgetId, root.widgetId, drag.source.listType, root.listType);
            }
        }
    }

    // This makes the item a drag source
    Drag.active: dragHandler.active
    Drag.source: root
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
}
