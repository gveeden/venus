pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property int volume: 0
    property bool isMuted: false
    property string icon: isMuted ? "󰖁" : volume > 70 ? "󰕾" : volume > 30 ? "󰖀" : "󰕿"
    
    signal volumeChangedSignal(int newVolume, bool muted)
    
    Timer {
        id: pollTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            volumeQuery.running = true
        }
    }
    
    Process {
        id: volumeQuery
        command: ["pactl", "list", "sinks"]
        running: false
        
        property int tempVolume: 0
        property bool tempMuted: false
        
        stdout: StdioCollector {
            id: stdoutCollector
            onStreamFinished: {
                const data = text
                let lines = data.split('\n')
                for (let line of lines) {
                    let volMatch = line.match(/Volume: front-left: \d+ \/\s*(\d+)%/)
                    if (volMatch) {
                        volumeQuery.tempVolume = parseInt(volMatch[1])
                    }
                    let muteMatch = line.match(/Mute:\s*(yes|no)/)
                    if (muteMatch) {
                        volumeQuery.tempMuted = muteMatch[1] === "yes"
                    }
                }
            }
        }
        
        onExited: {
            if (tempVolume !== root.volume || tempMuted !== root.isMuted) {
                root.volume = tempVolume
                root.isMuted = tempMuted
                root.volumeChangedSignal(root.volume, root.isMuted)
            }
        }
    }
}
