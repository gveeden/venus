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

    property var topApps: []
    property string _topAppsOutput: ""
    property var _prevAppStats: ({})
    property real _prevAppTime: 0

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

    // Process for overall network stats
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

    // Process for top network apps using ss -tinup to get cumulative bytes
    Process {
        id: topProc
        command: ["sh", "-c", "ss -tinup state established | grep -A 1 \"users:(\""]
        running: false
        stdout: SplitParser {
            onRead: text => {
                root._topAppsOutput += text + "\n";
            }
        }
        onExited: (code) => {
            const now = Date.now() / 1000.0;
            const dt = root._prevAppTime > 0 ? (now - root._prevAppTime) : 1.0;
            root._prevAppTime = now;
            
            const lines = root._topAppsOutput.split("\n");
            const currentStats = {}; // By connection ID
            const appAggr = {}; // By app name
            
            for (let i = 0; i < lines.length - 1; i++) {
                const line = lines[i].trim();
                if (line.includes("users:(")) {
                    // Get connection ID (addresses)
                    const parts = line.split(/\s+/);
                    if (parts.length < 5) continue;
                    const connId = parts[3] + "-" + parts[4];
                    
                    // Get process name
                    const match = line.match(/users:\(\(\"([^\"]+)\"/);
                    if (match) {
                        const name = match[1];
                        const nextLine = lines[i+1];
                        if (!nextLine) continue;
                        
                        // Extract bytes_sent/bytes_received
                        const txMatch = nextLine.match(/bytes_sent:(\d+)/);
                        const rxMatch = nextLine.match(/bytes_received:(\d+)/);
                        
                        if (txMatch && rxMatch) {
                            const tx = parseInt(txMatch[1]);
                            const rx = parseInt(rxMatch[1]);
                            
                            currentStats[connId] = { name: name, tx: tx, rx: rx };
                            
                            if (root._prevAppStats[connId]) {
                                const prev = root._prevAppStats[connId];
                                if (prev.name === name) {
                                    const txDelta = tx - prev.tx;
                                    const rxDelta = rx - prev.rx;
                                    
                                    if (txDelta >= 0 && rxDelta >= 0) {
                                        if (!appAggr[name]) appAggr[name] = { up: 0, down: 0 };
                                        appAggr[name].up += txDelta / dt;
                                        appAggr[name].down += rxDelta / dt;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            root._prevAppStats = currentStats;
            
            const apps = Object.keys(appAggr).map(name => ({
                name: name,
                up: root._formatSpeed(appAggr[name].up),
                down: root._formatSpeed(appAggr[name].down),
                rawUp: appAggr[name].up,
                rawDown: appAggr[name].down,
                total: appAggr[name].up + appAggr[name].down
            })).sort((a, b) => b.total - a.total).filter(a => a.total > 0).slice(0, 5);
            
            root.topApps = apps;
            root._topAppsOutput = "";
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
            topProc.running = true
        }
    }
}
