import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"

// Compact two-line upload/download speed indicator for the bar.
// Shows: ↑ <upload>  ↓ <download> stacked vertically.
ColumnLayout {
    id: root

    property real fontSize: Appearance.font.tiny
    spacing: 0

    // Upload row
    RowLayout {
        spacing: 2

        Text {
            text: "↑"
            color: Appearance.colors.textTertiary
            font.pixelSize: root.fontSize
            font.family: Appearance.font.family
        }

        Text {
            id: uploadText
            text: NetworkSpeed.uploadStr
            color: Appearance.colors.textSecondary
            font.pixelSize: root.fontSize
            font.family: Appearance.font.family
            horizontalAlignment: Text.AlignRight
            Layout.minimumWidth: 58
        }
    }

    // Download row
    RowLayout {
        spacing: 2

        Text {
            text: "↓"
            color: Appearance.colors.textTertiary
            font.pixelSize: root.fontSize
            font.family: Appearance.font.family
        }

        Text {
            id: downloadText
            text: NetworkSpeed.downloadStr
            color: Appearance.colors.textSecondary
            font.pixelSize: root.fontSize
            font.family: Appearance.font.family
            horizontalAlignment: Text.AlignRight
            Layout.minimumWidth: 58
        }
    }
}
