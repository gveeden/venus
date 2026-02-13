pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    readonly property bool ready: Bluetooth.defaultAdapter !== null
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property bool scanning: Bluetooth.defaultAdapter?.discovering ?? false
    readonly property string status: enabled ? "On" : "Off"
    readonly property var devices: Bluetooth.devices
    readonly property var adapters: Bluetooth.adapters

    property var defaultAdapter: Bluetooth.defaultAdapter

    function toggle(): void {
        const adapter = Bluetooth.defaultAdapter;
        if (adapter) {
            adapter.enabled = !adapter.enabled;
        }
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
