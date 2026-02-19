pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

// Persists paired bluetooth device info to a local JSON file so that
// paired devices remain visible in the UI even when out of range and
// not present in the BlueZ D-Bus tree.
Singleton {
    id: root

    // List of stored device records: { address, name, icon, paired, bonded }
    property var storedDevices: []

    // Full merged list: live devices take precedence over stored records.
    // Stored-only devices (out of range) are marked with isOffline: true.
    readonly property var mergedDevices: {
        if (!Bluetooth.devices) return []
        const live = [...Bluetooth.devices.values]
        const liveAddrs = {}
        for (let i = 0; i < live.length; i++)
            liveAddrs[live[i].address] = true

        const offline = []
        for (let i = 0; i < root.storedDevices.length; i++) {
            const s = root.storedDevices[i]
            if (s.paired && !liveAddrs[s.address]) {
                offline.push({
                    address:   s.address,
                    name:      s.name,
                    icon:      s.icon,
                    paired:    true,
                    bonded:    s.bonded ?? false,
                    connected: false,
                    isOffline: true
                })
            }
        }

        // Tag live devices with isOffline: false.
        // Only snapshot stable identity fields (address, name, icon).
        // All volatile properties (paired, connected, state, trusted, pairing,
        // battery, etc.) must be read via _live at the call site so they are
        // never stale — the wrapper object is intentionally thin.
        const taggedLive = []
        for (let i = 0; i < live.length; i++) {
            const d = live[i]
            taggedLive.push({
                _live:     d,          // live QML object — bindings + signals work
                address:   d.address,  // stable identity
                name:      d.name,     // display (may be aliased by user; ok to cache)
                icon:      d.icon,     // stable device-class icon
                isOffline: false,
                // Convenience accessors delegated to _live so DeviceList filters
                // and sorts always see current values.
                get paired()    { return d.paired },
                get bonded()    { return d.bonded },
                get connected() { return d.connected },
                get trusted()   { return d.trusted },
            })
        }

        return taggedLive.concat(offline)
    }

    function save(): void {
        fileView.setText(JSON.stringify(root.storedDevices, null, 2))
    }

    function remember(device): void {
        if (!device || !device.address) return
        const addr = device.address
        let existing = -1
        for (let i = 0; i < root.storedDevices.length; i++) {
            if (root.storedDevices[i].address === addr) { existing = i; break }
        }
        const record = {
            address: addr,
            name:    device.name || addr,
            icon:    device.icon ?? "audio-headset",
            paired:  device.paired  ?? false,
            bonded:  device.bonded  ?? false,
        }
        let updated = root.storedDevices.slice()
        if (existing >= 0)
            updated[existing] = record
        else
            updated.push(record)
        root.storedDevices = updated
        root.save()
    }

    function forget(address: string): void {
        root.storedDevices = root.storedDevices.filter(function(d) { return d.address !== address })
        root.save()
    }

    FileView {
        id: fileView
        path: Quickshell.shellDir + "/bluetooth-devices.json"

        onLoaded: {
            try {
                root.storedDevices = JSON.parse(text())
            } catch (e) {
                root.storedDevices = []
            }
        }

        onLoadFailed: err => {
            root.storedDevices = []
        }

        onSaveFailed: err => {
            console.error("BluetoothStore: save failed:", FileViewError.toString(err))
        }
    }

    // Sync live devices into the store when they become paired/bonded.
    // Use a poll timer since Instantiator with UntypedObjectModel isn't supported.
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            const devs = [...Bluetooth.devices.values]
            for (let i = 0; i < devs.length; i++) {
                const dev = devs[i]
                if (dev && (dev.paired || dev.bonded))
                    root.remember(dev)
            }
        }
    }
}
