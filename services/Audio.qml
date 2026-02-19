pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

Singleton {
    id: root

    property int volume: 0
    property bool isMuted: false
    property string icon: isMuted ? "󰖁" : volume > 70 ? "󰕾" : volume > 30 ? "󰖀" : "󰕿"

    property var sinks: []
    property var sources: []
    property string defaultSink: ""
    property string defaultSource: ""

    signal volumeChangedSignal(int newVolume, bool muted)
    signal devicesChanged()

    // --- Event-driven refresh via pactl subscribe ---

    Process {
        id: subscribeProcess
        command: ["pactl", "subscribe"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                // Ignore client connect/disconnect events — those are just
                // pactl subprocesses we spawned ourselves, not real changes.
                if (data.includes("client")) return

                if (data.includes("sink") || data.includes("server"))
                    sinksDebounce.restart()
                if (data.includes("source") || data.includes("server"))
                    sourcesDebounce.restart()
            }
        }
    }

    // Debounce: collapse rapid bursts of events into a single refresh
    Timer {
        id: sinksDebounce
        interval: 150
        repeat: false
        onTriggered: {
            sinksDetailQuery.running = true
            defaultSinkQuery.running = true
        }
    }

    Timer {
        id: sourcesDebounce
        interval: 150
        repeat: false
        onTriggered: {
            sourcesDetailQuery.running = true
            defaultSourceQuery.running = true
        }
    }

    Timer {
        id: subscribeWatchdog
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!subscribeProcess.running)
                subscribeProcess.running = true
        }
    }

    // --- Default sink/source ---

    Process {
        id: defaultSinkQuery
        command: ["pactl", "get-default-sink"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.defaultSink = text.trim()
        }
    }

    Process {
        id: defaultSourceQuery
        command: ["pactl", "get-default-source"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.defaultSource = text.trim()
        }
    }

    // --- Sinks (outputs) ---

    Process {
        id: sinksDetailQuery
        command: ["pactl", "list", "sinks"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let newSinks = []
                let cur = null

                for (let line of text.split('\n')) {
                    let nameMatch = line.match(/^\s+Name:\s+(.+)$/)
                    if (nameMatch) {
                        if (cur) newSinks.push(cur)
                        cur = { name: nameMatch[1].trim(), description: nameMatch[1].trim(), volume: 0, isMuted: false }
                        continue
                    }
                    if (!cur) continue

                    let descMatch = line.match(/^\s+Description:\s+(.+)$/)
                    if (descMatch) { cur.description = descMatch[1].trim(); continue }

                    let volMatch = line.match(/Volume: front-left: \d+ \/\s*(\d+)%/)
                    if (volMatch) { cur.volume = parseInt(volMatch[1]); continue }

                    let muteMatch = line.match(/Mute:\s*(yes|no)/)
                    if (muteMatch) { cur.isMuted = muteMatch[1] === "yes"; continue }
                }
                if (cur) newSinks.push(cur)

                root.sinks = newSinks
                root.devicesChanged()

                for (let sink of newSinks) {
                    if (sink.name === root.defaultSink) {
                        if (sink.volume !== root.volume || sink.isMuted !== root.isMuted) {
                            root.volume = sink.volume
                            root.isMuted = sink.isMuted
                            root.volumeChangedSignal(root.volume, root.isMuted)
                        }
                        break
                    }
                }
            }
        }
    }

    // --- Sources (inputs) ---

    Process {
        id: sourcesDetailQuery
        command: ["pactl", "list", "sources"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let newSources = []
                let cur = null

                for (let line of text.split('\n')) {
                    let nameMatch = line.match(/^\s+Name:\s+(.+)$/)
                    if (nameMatch) {
                        if (cur && !cur.name.endsWith('.monitor'))
                            newSources.push(cur)
                        cur = { name: nameMatch[1].trim(), description: nameMatch[1].trim() }
                        continue
                    }
                    if (!cur) continue

                    let descMatch = line.match(/^\s+Description:\s+(.+)$/)
                    if (descMatch) { cur.description = descMatch[1].trim(); continue }
                }
                if (cur && !cur.name.endsWith('.monitor'))
                    newSources.push(cur)

                root.sources = newSources
            }
        }
    }

    // --- Set default sink/source ---

    Process {
        id: setDefaultSinkProcess
        running: false
    }

    Process {
        id: setDefaultSourceProcess
        running: false
    }

    function setDefaultSink(sinkName: string): void {
        if (sinkName === root.defaultSink) return
        setDefaultSinkProcess.command = ["pactl", "set-default-sink", sinkName]
        setDefaultSinkProcess.running = true
    }

    function setDefaultSource(sourceName: string): void {
        if (sourceName === root.defaultSource) return
        setDefaultSourceProcess.command = ["pactl", "set-default-source", sourceName]
        setDefaultSourceProcess.running = true
    }

    // --- Volume control ---

    Process {
        id: setVolumeProcess
        running: false
    }

    function setVolume(pct: int): void {
        setVolumeProcess.command = ["pactl", "set-sink-volume", root.defaultSink, pct + "%"]
        setVolumeProcess.running = true
    }

    function toggleMute(): void {
        setVolumeProcess.command = ["pactl", "set-sink-mute", root.defaultSink, "toggle"]
        setVolumeProcess.running = true
    }

    // --- Bluetooth auto-switch ---
    // Poll BT device connected states every second. This is pure in-process
    // property access — no subprocess, no audio impact — unlike the old approach
    // that spawned pactl processes on every poll tick.
    // We track the previous connected state to detect transitions.

    property var _btState: ({})   // address -> bool (last known connected state)

    Timer {
        id: btPollTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            const devs = [...Bluetooth.devices.values]
            for (const dev of devs) {
                if (!dev?.address) continue
                const addr = dev.address
                const nowConnected = dev.connected ?? false
                const wasConnected = root._btState[addr]

                // Skip if state unchanged, or if this is the first time we've
                // seen this device (wasConnected === undefined) — avoids false
                // "just connected" triggers on startup.
                if (wasConnected === undefined || wasConnected === nowConnected) {
                    root._btState[addr] = nowConnected
                    continue
                }

                root._btState[addr] = nowConnected

                if (nowConnected) {
                    const addrU = addr.replace(/:/g, '_')
                    switchToBtTimer.sinkName   = "bluez_output." + addrU
                    switchToBtTimer.sourceName = "bluez_input."  + addrU
                    switchToBtTimer.restart()
                } else {
                    const fallbackSink   = root.sinks.find(s => !s.name.startsWith("bluez_"))
                    const fallbackSource = root.sources.find(s => !s.name.startsWith("bluez_"))
                    if (fallbackSink)   root.setDefaultSink(fallbackSink.name)
                    if (fallbackSource) root.setDefaultSource(fallbackSource.name)
                }
            }
        }
    }

    Timer {
        id: switchToBtTimer
        interval: 1500
        repeat: false
        property string sinkName: ""
        property string sourceName: ""
        onTriggered: {
            if (root.sinks.some(s => s.name === sinkName))     root.setDefaultSink(sinkName)
            if (root.sources.some(s => s.name === sourceName)) root.setDefaultSource(sourceName)
        }
    }

    Component.onCompleted: {
        sinksDetailQuery.running   = true
        sourcesDetailQuery.running = true
        defaultSinkQuery.running   = true
        defaultSourceQuery.running = true
    }
}
