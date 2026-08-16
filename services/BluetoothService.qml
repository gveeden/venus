pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    property var defaultAdapter: Bluetooth.defaultAdapter

    property bool realEnabled: defaultAdapter ? defaultAdapter.enabled : false

    // ── Startup power-on ──────────────────────────────────────────────────
    // Automatically enable the adapter the first time it appears from BlueZ.
    // Guards against AutoEnable not being set in /etc/bluetooth/main.conf or
    // a boot-time race where the adapter registers as powered-off.
    property bool _initialPowerOnDone: false

    onDefaultAdapterChanged: {
        if (!defaultAdapter || _initialPowerOnDone) return
        _initialPowerOnDone = true
        if (!defaultAdapter.enabled) {
            defaultAdapter.enabled = true
            btToggleProcess.targetState = true
            btToggleProcess.running = true
            realEnabled = true
        }
    }

    // ── Pairing confirmation state ────────────────────────────────────────────
    property bool   pairingPending: false
    property string pairingPasskey: ""
    property string pairingDevice:  ""

    property bool realScanning: defaultAdapter ? defaultAdapter.discovering : false

    // Polling fallback to ensure status is accurate after bluez restarts
    Process {
        id: btCheckProcess
        command: ["sh", "-c", "bluetoothctl show | grep -E 'Powered:|Discovering:'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.realEnabled = text.indexOf("Powered: yes") !== -1;
                root.realScanning = text.indexOf("Discovering: yes") !== -1;
            }
        }
    }

    Process {
        id: btToggleProcess
        property bool targetState: false
        command: ["bluetoothctl", "power", targetState ? "on" : "off"]
    }

    Process {
        id: btScanProcess
        property bool targetState: false
        command: ["bluetoothctl", "scan", targetState ? "on" : "off"]
    }

    Process {
        id: btRemoveProcess
        property string deviceAddress: ""
        command: ["bluetoothctl", "remove", deviceAddress]
    }

    // ── Bluetooth pairing agent (on-demand) ──────────────────────────────────
    // Started only when the user clicks Connect on an unpaired device.
    // The agent exits automatically after handling one RequestConfirmation.
    property var _pendingPairDevice: null

    Process {
        id: btAgentProcess
        command: ["python3", Quickshell.shellDir + "/services/bt_agent.py"]
        // NOT running: true — started on demand by startPairingAgent()
    }

    // Small delay between starting the agent and calling pair() so the agent
    // has time to register with BlueZ before the pairing handshake begins.
    Timer {
        id: pairAfterAgentTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (root._pendingPairDevice) {
                root._pendingPairDevice.pair()
                root._pendingPairDevice = null
            }
        }
    }

    // ── Pairing request poller ────────────────────────────────────────────────
    // Only active while the agent process is running. Picks up the request file
    // the agent writes, and detects cancellation if the file disappears.
    Process {
        id: pairingPollProcess
        command: ["sh", "-c",
            "test -f /tmp/bt_pair_request.json && cat /tmp/bt_pair_request.json || echo NONE"]
        stdout: StdioCollector {
            onStreamFinished: {
                const content = text.trim()
                if (content === "NONE") {
                    if (root.pairingPending) {
                        root.pairingPending = false
                        root.pairingPasskey = ""
                        root.pairingDevice  = ""
                    }
                    return
                }
                if (root.pairingPending) return
                try {
                    const data = JSON.parse(content)
                    if (data.device && data.passkey) {
                        root.pairingDevice  = data.device
                        root.pairingPasskey = data.passkey
                        root.pairingPending = true
                    }
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 500
        running: btAgentProcess.running   // only polls while the agent is alive
        repeat: true
        onTriggered: pairingPollProcess.running = true
    }

    Process {
        id: acceptPairingProcess
        command: ["sh", "-c", "printf '{\"accepted\":true}' > /tmp/bt_pair_response.json"]
    }

    Process {
        id: rejectPairingProcess
        command: ["sh", "-c", "printf '{\"accepted\":false}' > /tmp/bt_pair_response.json"]
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: btCheckProcess.running = true
    }

    readonly property bool ready: defaultAdapter !== null
    readonly property bool enabled: realEnabled
    readonly property bool scanning: (defaultAdapter && defaultAdapter.discovering) || realScanning
    readonly property string status: enabled ? "On" : "Off"
    readonly property var devices: Bluetooth.devices
    readonly property var adapters: Bluetooth.adapters

    function toggle(): void {
        const targetState = !enabled;
        
        if (!targetState && scanning) {
            realScanning = false;
            btScanProcess.targetState = false;
            btScanProcess.running = true;
        }

        // Try the DBus adapter first
        const adapter = Bluetooth.defaultAdapter;
        if (adapter) {
            adapter.enabled = targetState;
            if (!targetState) {
                adapter.discovering = false;
            }
        }
        
        // Also enforce via bluetoothctl as a fallback
        btToggleProcess.targetState = targetState;
        btToggleProcess.running = true;
        
        // Optimistically update
        realEnabled = targetState;
        btCheckProcess.running = true;
    }

    function toggleScanning(): void {
        if (!enabled) return;
        const target = !scanning;

        // Try the DBus adapter
        const adapter = Bluetooth.defaultAdapter;
        if (adapter) {
            adapter.discovering = target;
        }

        // Also enforce via bluetoothctl
        btScanProcess.targetState = target;
        btScanProcess.running = true;

        realScanning = target;
        btCheckProcess.running = true;
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

    function forgetDevice(address: string): void {
        if (!address) return;
        btRemoveProcess.deviceAddress = address;
        btRemoveProcess.running = true;
    }

    function startPairingAgent(device): void {
        root._pendingPairDevice = device
        btAgentProcess.running = true
        pairAfterAgentTimer.restart()
    }

    function confirmPairing(): void {
        root.pairingPending = false
        acceptPairingProcess.running = true
    }

    function rejectPairing(): void {
        root.pairingPending = false
        rejectPairingProcess.running = true
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
