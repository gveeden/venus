import QtQuick
import QtQuick.Layouts
import "../../../config"
import "../../../services"

Item {
    id: root
    property string widgetId
    property alias content: contentLoader.sourceComponent
    
    width: contentLoader.item ? contentLoader.item.implicitWidth + BarConfig.margins : 0
    height: BarConfig.height
    
    Layout.preferredWidth: width
    Layout.preferredHeight: height

    signal moved(string fromId, string toId)

    Loader {
        id: contentLoader
        anchors.fill: parent
    }

    // Drag handle and interaction
    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: root
        drag.axis: Drag.XAxis
        
        onReleased: {
            if (root.Drag.target !== null) {
                // We let the DropArea handle the reorder, but if we're not over anything,
                // we reset our position.
            }
            root.x = 0 // Reset local X relative to the layout (the layout will re-anchor it)
        }

        onPositionChanged: {
            if (drag.active) {
                // Logic to update the layout while dragging can be added here
            }
        }
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        onEntered: drag => {
            if (drag.source !== root && drag.source.widgetId !== undefined) {
                root.moved(drag.source.widgetId, root.widgetId);
            }
        }
    }

    Drag.active: dragArea.drag.active
    Drag.source: root
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    // Smooth transition when layout updates
    Behavior on x {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
}
