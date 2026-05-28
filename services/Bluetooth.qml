pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    property var defaultAdapter: Bluetooth.defaultAdapter
    
    property bool realEnabled: defaultAdapter ? defaultAdapter.enabled : false

    // Polling fallback to ensure status is accurate after bluez restarts
    Process {
        id: btCheckProcess
        command: ["sh", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'ON' || echo 'OFF'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.realEnabled = text.trim() === "ON";
            }
        }
    }

    Process {
        id: btToggleProcess
        property bool targetState: false
        command: ["bluetoothctl", "power", targetState ? "on" : "off"]
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: btCheckProcess.running = true
    }

    readonly property bool ready: defaultAdapter !== null
    readonly property bool enabled: realEnabled
    readonly property bool scanning: defaultAdapter ? defaultAdapter.discovering : false
    readonly property string status: enabled ? "On" : "Off"
    readonly property var devices: Bluetooth.devices
    readonly property var adapters: Bluetooth.adapters

    function toggle(): void {
        const targetState = !enabled;
        
        // Try the DBus adapter first
        const adapter = Bluetooth.defaultAdapter;
        if (adapter) {
            adapter.enabled = targetState;
        }
        
        // Also enforce via bluetoothctl as a fallback
        btToggleProcess.targetState = targetState;
        btToggleProcess.running = true;
        
        // Optimistically update
        realEnabled = targetState;
        btCheckProcess.running = true;
    }

    function toggleScanning(): void {
        const adapter = Bluetooth.defaultAdapter;
        if (adapter) {
            adapter.discovering = !adapter.discovering;
        }
    }

    function toggleDeviceTrust(device): void {
        if (device) {
            device.trusted = !device.trusted;
        }
    }

    function toggleDeviceBlock(device): void {
        if (device) {
            device.blocked = !device.blocked;
        }
    }

    function isNameMacAddress(name, address): bool {
        if (!name || !address)
            return true;
        const macPattern = /^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$/i;
        if (macPattern.test(name))
            return true;
        const cleanName = name.replace(/[:-]/g, '').toUpperCase();
        const cleanAddr = address.replace(/[:-]/g, '').toUpperCase();
        return cleanName === cleanAddr;
    }
}
