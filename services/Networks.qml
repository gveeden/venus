pragma Singleton

import Quickshell
import QtQuick
import "." as Services

Singleton {
    id: root

    readonly property bool ready: wifiEnabled !== null
    readonly property bool enabled: wifiEnabled
    readonly property bool scanning: Nmcli.scanning
    readonly property string status: enabled ? "On" : "Off"
    readonly property var networks: Nmcli.networks
    readonly property var activeNetwork: Nmcli.active

    property bool wifiEnabled: true
    property var pendingConnection: null
    property bool showPasswordDialog: false
    property var pendingNetwork: null

    signal connectionFailed(string ssid)

    Component.onCompleted: {
        Nmcli.getWifiStatus(enabled => {
            root.wifiEnabled = enabled
        })
        Nmcli.getNetworks(() => {})
        Nmcli.loadSavedConnections(() => {})
    }

    Connections {
        target: Nmcli
        function onWifiEnabledChanged() {
            root.wifiEnabled = Nmcli.wifiEnabled
        }
        function onConnectionFailed(ssid) {
            root.connectionFailed(ssid)
        }
    }

    function toggle(): void {
        Nmcli.toggleWifi(result => {
            if (result.success) {
                root.wifiEnabled = !root.wifiEnabled
            }
        })
    }

    function toggleScanning(): void {
        if (scanning) {
            // Can't cancel scan, just ignore
            return
        }
        Nmcli.rescanWifi()
    }

    function connectToNetwork(network: var, password: string): void {
        if (!network) return

        const ssid = network.ssid
        const bssid = network.bssid
        const isSecure = network.isSecure

        root.pendingNetwork = network

        if (password && password.length > 0) {
            // Password provided, connect directly
            Nmcli.connectToNetwork(ssid, password, bssid, result => {
                if (result.success) {
                    root.showPasswordDialog = false
                    root.pendingNetwork = null
                } else if (result.needsPassword) {
                    // Still needs password (shouldn't happen)
                    root.showPasswordDialog = true
                } else {
                    // Connection failed
                    root.showPasswordDialog = false
                    root.pendingNetwork = null
                    root.connectionFailed(ssid)
                }
            })
        } else {
            // No password, check if saved or open network
            Nmcli.connectToNetworkWithPasswordCheck(ssid, isSecure, result => {
                if (result.success) {
                    root.showPasswordDialog = false
                    root.pendingNetwork = null
                } else if (result.needsPassword) {
                    // Show password dialog
                    root.showPasswordDialog = true
                } else {
                    // Connection failed
                    root.showPasswordDialog = false
                    root.pendingNetwork = null
                    root.connectionFailed(ssid)
                }
            }, bssid)
        }
    }

    function disconnectFromNetwork(): void {
        Nmcli.disconnectFromNetwork()
    }

    function forgetNetwork(ssid: string): void {
        if (!ssid || ssid.length === 0) return

        Nmcli.forgetNetwork(ssid, result => {
            if (result.success) {
                // Network forgotten successfully
                Nmcli.getNetworks(() => {})
            }
        })
    }

    function hasSavedProfile(ssid: string): bool {
        return Nmcli.hasSavedProfile(ssid)
    }
}
