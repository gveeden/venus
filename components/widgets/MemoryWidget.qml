import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"

// Memory usage widget for the bar.
// Shows:  <percent>% (Short)
Item {
    id: root
    implicitWidth: iconTextRow.implicitWidth
    implicitHeight: iconTextRow.implicitHeight
    
    property real fontSize: Appearance.font.small

    RowLayout {
        id: iconTextRow
        spacing: Appearance.spacing.small
        anchors.centerIn: parent
        
        Text {
            text: "MEM"
            color: Appearance.colors.textTertiary
            font.pixelSize: root.fontSize
            font.family: Appearance.font.family
            font.bold: true
        }

        Text {
            text: Memory.usagePercentStr
            color: Appearance.colors.textSecondary
            font.pixelSize: root.fontSize
            font.family: Appearance.font.family
        }
    }
}
