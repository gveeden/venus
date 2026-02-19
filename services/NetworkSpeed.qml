pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Bytes per second (raw)
    readonly property real uploadSpeed:   _uploadSpeed
    readonly property real downloadSpeed: _downloadSpeed

    // Human-readable strings, e.g. "1.2 MB/s" or "512 KB/s"
    readonly property string uploadStr:   _formatSpeed(_uploadSpeed)
    readonly property string downloadStr: _formatSpeed(_downloadSpeed)

    property real _uploadSpeed:   0
    property real _downloadSpeed: 0

    property var  _prevRx: ({})
    property var  _prevTx: ({})
    property real _prevTime: 0

    function _formatSpeed(bps: real): string {
        if (bps >= 1048576)
            return (bps / 1048576).toFixed(1) + " MB/s"
        if (bps >= 1024)
            return Math.round(bps / 1024) + " KB/s"
        return Math.round(bps) + " B/s"
    }

    // Read /proc/net/dev on an interval
    Process {
        id: proc
        command: ["cat", "/proc/net/dev"]
        running: false

        stdout: SplitParser {
            onRead: function(data) { root._netDevOutput += data + "\n" }
        }

        onExited: function(exitCode, exitStatus) {
            root._parseNetDev(root._netDevOutput)
            root._netDevOutput = ""
        }
    }

    property string _netDevOutput: ""

    function _parseNetDev(text: string): void {
        const now = Date.now() / 1000.0
        const isFirst = _prevTime === 0
        const dt = isFirst ? 1.0 : (now - _prevTime)
        _prevTime = now

        let totalRx = 0
        let totalTx = 0
        let newRx = {}
        let newTx = {}

        const lines = text.split("\n")
        for (let i = 2; i < lines.length; i++) {
            const line = lines[i].trim()
            if (!line) continue

            const colonIdx = line.indexOf(":")
            if (colonIdx < 0) continue

            const iface = line.substring(0, colonIdx).trim()
            // Skip loopback
            if (iface === "lo") continue

            const fields = line.substring(colonIdx + 1).trim().split(/\s+/)
            // /proc/net/dev columns after iface:
            // rx: bytes packets errs drop fifo frame compressed multicast
            // tx: bytes packets errs drop fifo colls carrier compressed
            const rx = parseFloat(fields[0]) || 0
            const tx = parseFloat(fields[8]) || 0

            newRx[iface] = rx
            newTx[iface] = tx

            if (!isFirst && _prevRx[iface] !== undefined && _prevTx[iface] !== undefined) {
                const rxDelta = rx - _prevRx[iface]
                const txDelta = tx - _prevTx[iface]
                // Guard against counter resets (interface restart)
                if (rxDelta >= 0) totalRx += rxDelta
                if (txDelta >= 0) totalTx += txDelta
            }
        }

        _prevRx = newRx
        _prevTx = newTx

        if (!isFirst && dt > 0) {
            _downloadSpeed = totalRx / dt
            _uploadSpeed   = totalTx / dt
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root._netDevOutput = ""
            proc.running = true
        }
    }
}
