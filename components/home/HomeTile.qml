import QtQuick
import QtQuick.Layouts
import "../../config"

Rectangle {
    id: root
    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool isOn: false
    property bool isLoading: false
    property color lightColor: Appearance.colors.primary
    property int brightness: 100
    signal clicked()
    signal longPressed()

    width: HomeConfig.tileWidth
    height: HomeConfig.tileHeight
    radius: Appearance.rounding.medium
    
    // Computed color based on brightness and actual light color
    readonly property color activeColor: {
        if (!isOn) return Appearance.colors.surface;
        // If color is set, use it, otherwise use primary
        let base = lightColor;
        // Scale brightness: 0-100 -> 0.3-1.0
        let alpha = 0.3 + (brightness / 100.0) * 0.7;
        return Qt.rgba(base.r, base.g, base.b, alpha);
    }

    color: activeColor

    Column {
        anchors.fill: parent
        anchors.margins: Appearance.padding.medium
        spacing: Appearance.spacing.small

        Text {
            text: root.icon
            font.family: Appearance.font.family
            font.pixelSize: 24
            color: root.isOn ? Appearance.colors.background : Appearance.colors.text
            
            // Subtle pulse if loading
            OpacityAnimator on opacity {
                from: 1.0; to: 0.3; duration: 800
                running: root.isLoading
                loops: Animation.Infinite
            }
        }

        Text {
            text: root.title
            font.family: Appearance.font.family
            font.pixelSize: Appearance.font.small
            font.bold: true
            color: root.isOn ? Appearance.colors.background : Appearance.colors.text
            width: parent.width - Appearance.padding.medium * 2
            elide: Text.ElideRight
        }

        Text {
            text: root.subtitle
            font.family: Appearance.font.family
            font.pixelSize: Appearance.font.tiny
            color: root.isOn ? Appearance.colors.background : Appearance.colors.textSecondary
            width: parent.width - Appearance.padding.medium * 2
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        onPressAndHold: root.longPressed()
    }
}
