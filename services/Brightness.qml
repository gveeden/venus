pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property int brightness: 0
    property int maxBrightness: 100
    property string icon: brightnessPercent > 70 ? "󰃠" : brightnessPercent > 30 ? "󰃟" : "󰃞"
    
    signal brightnessChangedSignal(int newBrightness)
    
    readonly property int brightnessPercent: maxBrightness > 0 
        ? Math.round((brightness / maxBrightness) * 100) 
        : 0
    
    Timer {
        id: pollTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            maxBrightnessQuery.running = true
            brightnessQuery.running = true
        }
    }
    
    Process {
        id: brightnessQuery
        command: ["brightnessctl", "get"]
        running: false
        
        stdout: StdioCollector {
            id: brightnessCollector
            onStreamFinished: {
                const data = text.trim()
                let val = parseInt(data)
                if (!isNaN(val) && val !== root.brightness) {
                    root.brightness = val
                    root.brightnessChangedSignal(root.brightnessPercent)
                }
            }
        }
    }
    
    Process {
        id: maxBrightnessQuery
        command: ["brightnessctl", "max"]
        running: false
        
        stdout: StdioCollector {
            id: maxBrightnessCollector
            onStreamFinished: {
                const data = text.trim()
                let val = parseInt(data)
                if (!isNaN(val) && val > 0 && val !== root.maxBrightness) {
                    root.maxBrightness = val
                }
            }
        }
    }
}
