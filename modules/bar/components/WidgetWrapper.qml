import QtQuick
import QtQuick.Layouts
import "../../../config"
import "../../../services"

Item {
    id: root
    property string widgetId
    property alias content: contentLoader.sourceComponent
    
    width: contentLoader.item ? contentLoader.item.implicitWidth : 0
    height: BarConfig.height
    
    Layout.preferredWidth: width
    Layout.preferredHeight: height

    z: dragHandler.active ? 100 : 1

    signal moved(string fromId, string toId)

    Loader {
        id: contentLoader
        anchors.fill: parent
    }

    // Drag handle and interaction
    DragHandler {
        id: dragHandler
        target: root
        xAxis.enabled: true
        yAxis.enabled: false
        onActiveChanged: {
            if (!active) {
                root.x = 0
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

    Drag.active: dragHandler.active
    Drag.source: root
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    // Smooth transition when layout updates, disabled during drag
    Behavior on x {
        enabled: !dragHandler.active
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
}
