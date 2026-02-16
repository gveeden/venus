import "../../config"
import "../../services"
import Quickshell
import QtQuick
import QtQuick.Layouts
import "." as OsdPrivate

Scope {
    PanelWindow {
        id: osdWindow
        
        anchors {
            top: true
            left: true
        }
        
        implicitWidth: OsdConfig.width
        implicitHeight: OsdConfig.height
        
        margins {
            top: OsdConfig.topMargin
            left: OsdConfig.leftMargin
        }

        exclusionMode: ExclusionMode.Ignore
        visible: false
        color: "transparent"

        property string lastType: ""
        property int lastVolume: -1
        property int lastBrightness: -1
        property bool lastMuted: false

        Connections {
            target: Audio
            function onVolumeChangedSignal() {
                osdWindow.lastType = "volume"
                osdWindow.lastVolume = Audio.volume
                osdWindow.lastMuted = Audio.isMuted
                osdWindow.showOsd()
            }
        }

        Connections {
            target: Brightness
            function onBrightnessChangedSignal() {
                osdWindow.lastType = "brightness"
                osdWindow.lastBrightness = Brightness.brightnessPercent
                osdWindow.showOsd()
            }
        }

        function showOsd() {
            osdWindow.visible = true
            hideTimer.restart()
        }

        Timer {
            id: hideTimer
            interval: OsdConfig.displayDuration
            onTriggered: {
                osdWindow.visible = false
            }
        }

        OsdPrivate.Content {
            anchors.fill: parent
            osdType: osdWindow.lastType
            volumeValue: osdWindow.lastVolume
            brightnessValue: osdWindow.lastBrightness
            isMuted: osdWindow.lastMuted
        }
    }
}
