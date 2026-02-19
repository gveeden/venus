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

        // Suppress all signals fired during the initial service startup window.
        // Audio emits multiple times at startup (Component.onCompleted query +
        // the immediate pactl subscribe event), so a time-based gate is more
        // reliable than counting individual emissions.
        property bool ready: false

        Timer {
            id: readyTimer
            interval: 1500
            repeat: false
            running: true
            onTriggered: osdWindow.ready = true
        }

        Connections {
            target: Audio
            function onVolumeChangedSignal() {
                if (!osdWindow.ready) return
                osdWindow.lastType = "volume"
                osdWindow.lastVolume = Audio.volume
                osdWindow.lastMuted = Audio.isMuted
                osdWindow.showOsd()
            }
        }

        Connections {
            target: Brightness
            function onBrightnessChangedSignal() {
                if (!osdWindow.ready) return
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
