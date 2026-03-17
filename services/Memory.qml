pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property real totalMemory: _totalMemory
    readonly property real usedMemory: _usedMemory
    readonly property real availableMemory: _availableMemory
    readonly property real memoryUsagePercent: _totalMemory > 0 ? (_usedMemory / _totalMemory) * 100 : 0

    readonly property real swapTotal: _swapTotal
    readonly property real swapFree: _swapFree
    readonly property real swapUsed: _swapTotal - _swapFree
    readonly property real swapUsagePercent: _swapTotal > 0 ? (swapUsed / _swapTotal) * 100 : 0

    readonly property string totalStr: _formatBytes(_totalMemory)
    readonly property string usedStr: _formatBytes(_usedMemory)
    readonly property string availableStr: _formatBytes(_availableMemory)
    readonly property string usagePercentStr: Math.round(memoryUsagePercent) + "%"

    property real _totalMemory: 0
    property real _usedMemory: 0
    property real _availableMemory: 0
    property real _swapTotal: 0
    property real _swapFree: 0

    property var topApps: []
    property string _topAppsOutput: ""

    Process {
        id: topProc
        command: ["sh", "-c", "ps axch -o %mem,comm --sort=-%mem | head -n 5"]
        running: false
        stdout: SplitParser {
            onRead: text => {
                root._topAppsOutput += text + "\n";
            }
        }
        onExited: (code) => {
            const lines = root._topAppsOutput.trim().split("\n");
            const apps = [];
            for (let line of lines) {
                const trimmed = line.trim();
                if (!trimmed) continue;
                const parts = trimmed.split(/\s+/);
                if (parts.length < 2) continue;
                apps.push({ mem: parts[0] + "%", name: parts.slice(1).join(" ") });
            }
            root.topApps = apps;
            root._topAppsOutput = "";
        }
    }

    function _formatBytes(kb: real): string {
        let bytes = kb * 1024
        if (bytes >= 1073741824)
            return (bytes / 1073741824).toFixed(1) + " GB"
        if (bytes >= 1048576)
            return (bytes / 1048576).toFixed(1) + " MB"
        if (bytes >= 1024)
            return Math.round(bytes / 1024) + " KB"
        return Math.round(bytes) + " B"
    }

    Process {
        id: proc
        command: ["cat", "/proc/meminfo"]
        running: false

        stdout: SplitParser {
            onRead: function(data) { root._memInfoOutput += data + "\n" }
        }

        onExited: function(exitCode, exitStatus) {
            root._parseMemInfo(root._memInfoOutput)
            root._memInfoOutput = ""
        }
    }

    property string _memInfoOutput: ""

    function _parseMemInfo(text: string): void {
        const lines = text.split("\n")
        let total = 0
        let available = 0
        let swapTotal = 0
        let swapFree = 0

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            if (line.startsWith("MemTotal:")) {
                let match = line.match(/\d+/)
                if (match) total = parseInt(match[0])
            } else if (line.startsWith("MemAvailable:")) {
                let match = line.match(/\d+/)
                if (match) available = parseInt(match[0])
            } else if (line.startsWith("SwapTotal:")) {
                let match = line.match(/\d+/)
                if (match) swapTotal = parseInt(match[0])
            } else if (line.startsWith("SwapFree:")) {
                let match = line.match(/\d+/)
                if (match) swapFree = parseInt(match[0])
            }
        }

        if (total > 0) {
            _totalMemory = total
            _availableMemory = available
            _usedMemory = total - available
            _swapTotal = swapTotal
            _swapFree = swapFree
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root._memInfoOutput = ""
            proc.running = true
            topProc.running = true
        }
    }
}
