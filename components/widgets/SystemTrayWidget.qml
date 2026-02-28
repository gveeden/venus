import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../config"

RowLayout {
    id: root
    required property PanelWindow trayWindow

    spacing: Appearance.spacing.tiny

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: trayDelegate
            required property SystemTrayItem modelData

            Layout.preferredWidth: BarConfig.height - 8
            Layout.preferredHeight: BarConfig.height - 8
            Layout.alignment: Qt.AlignVCenter
            color: "transparent"
            radius: Appearance.rounding.small

            IconImage {
                anchors.centerIn: parent
                source: trayDelegate.modelData.icon
                implicitSize: BarConfig.height - 10
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        trayDelegate.modelData.activate();
                    } else if (mouse.button === Qt.MiddleButton) {
                        trayDelegate.modelData.secondaryActivate();
                    } else if (mouse.button === Qt.RightButton) {
                        const mapped = trayDelegate.mapToItem(null, 0, trayDelegate.height);
                        trayDelegate.modelData.display(root.trayWindow, mapped.x, mapped.y);
                    }
                }
            }
        }
    }
}
