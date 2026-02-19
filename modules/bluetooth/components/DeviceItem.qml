import "../../../config"
import "../../../services"
import "../../../components/controls"
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    // device may be a live BluetoothDevice (QML object) or an offline JS record
    // from BluetoothStore. Use ?. throughout and check isOffline.
    property var device

    readonly property bool isOffline:   device?.isOffline  ?? false
    // For live devices, _live is the actual QML BluetoothDevice object so property
    // signals (onStateChanged, onPairingChanged, etc.) fire correctly.
    readonly property var  liveDevice:  isOffline ? null : (device?._live ?? device)

    readonly property bool isConnected: !isOffline && (liveDevice?.state === BluetoothDeviceState.Connected)
    readonly property bool isPaired:    !isOffline && (liveDevice?.paired ?? false)
    readonly property bool isPairing:   !isOffline && (liveDevice?.pairing ?? false)

    // Busy = any in-flight connection-state transition OR active pairing handshake
    readonly property bool isBusy: isPairing
        || (!isOffline && liveDevice !== null
            && liveDevice.state !== BluetoothDeviceState.Disconnected
            && liveDevice.state !== BluetoothDeviceState.Connected)

    // ── Internal state machine ────────────────────────────────────────────────
    // Tracks whether we initiated a pair+connect sequence so we can auto-trust
    // and auto-connect once pairing completes.  Stored on the address string so
    // a mergedDevices recompute (which swaps the wrapper object and triggers
    // onLiveDeviceChanged) does NOT reset the flag mid-pairing.
    property string _pendingPairAddress: ""

    readonly property bool _waitingForPair: _pendingPairAddress !== ""
        && !isOffline
        && (liveDevice?.address ?? "") === _pendingPairAddress

    // Whether the last connect attempt failed
    property bool connectFailed: false
    property int  lastState: -1

    onLiveDeviceChanged: {
        // Only reset connectFailed/lastState — do NOT clear _pendingPairAddress
        // here, because liveDevice changes every time mergedDevices recomputes.
        connectFailed = false
        lastState = -1
    }

    // Short delay after pairing completes before calling connect().
    // BlueZ needs a moment to settle the pairing D-Bus transaction before
    // it will accept a Connect() call without rejecting it.
    Timer {
        id: postPairConnectTimer
        interval: 750
        repeat: false
        onTriggered: {
            const dev = root.liveDevice
            if (!dev) {
                root._pendingPairAddress = ""
                return
            }
            if (dev.paired) {
                dev.connect()
            } else {
                // Pairing didn't stick — give up
                root._pendingPairAddress = ""
            }
        }
    }

    // Watch pairing → paired transition to apply trust then schedule connect
    Connections {
        target: root.liveDevice
        enabled: !root.isOffline

        function onPairingChanged(): void {
            if (!root._waitingForPair) return
            const dev = root.liveDevice
            if (!dev) return

            if (!dev.pairing && dev.paired) {
                // Pairing just completed successfully.
                // Trust the device immediately so it can reconnect without confirmation.
                dev.trusted = true
                // Schedule connect after a short delay to let BlueZ settle.
                // _pendingPairAddress stays set until onStateChanged sees Connected
                // or the timer fires and clears it on failure.
                postPairConnectTimer.restart()
            } else if (!dev.pairing && !dev.paired) {
                // Pairing was cancelled or failed — clean up.
                postPairConnectTimer.stop()
                root._pendingPairAddress = ""
            }
        }

        function onStateChanged(): void {
            const s = root.liveDevice?.state
            if (s === undefined) return

            if (s === BluetoothDeviceState.Connecting) {
                root.connectFailed = false
            } else if (s === BluetoothDeviceState.Disconnected
                       && root.lastState === BluetoothDeviceState.Connecting) {
                // Only show the error if this wasn't our own post-pair connect attempt.
                // If _waitingForPair is still set, the timer hasn't fired yet or the
                // connect attempt from the timer failed — clear the pending state too.
                if (!root._waitingForPair) {
                    root.connectFailed = true
                }
                root._pendingPairAddress = ""
                postPairConnectTimer.stop()
            } else if (s === BluetoothDeviceState.Connected) {
                root.connectFailed = false
                root._pendingPairAddress = ""
                postPairConnectTimer.stop()
            }
            root.lastState = s
        }
    }

    // ── Layout ────────────────────────────────────────────────────────────────

    implicitHeight: row.implicitHeight + Appearance.spacing.medium * 2
    color: isConnected ? Appearance.colors.surfaceHighlight : "transparent"
    radius: Appearance.rounding.small

    RowLayout {
        id: row
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: Appearance.spacing.medium
            rightMargin: Appearance.spacing.medium
        }
        spacing: Appearance.spacing.small

        // Device info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.tiny

            Text {
                text: root.device?.name || root.device?.address || "Unknown Device"
                color: root.isOffline ? Appearance.colors.textSecondary : Appearance.colors.text
                font.pixelSize: Appearance.font.medium
                font.bold: true
                font.family: Appearance.font.family
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: {
                    if (!root.device) return ""
                    const addr = root.device.address ?? ""
                    if (root.isOffline)        return addr + " · Out of range"
                    if (root._waitingForPair)  return addr + " · Pairing…"
                    if (root.isConnected)      return addr + " · Connected"
                    if (root.isBusy)           return addr + " · " + BluetoothDeviceState.toString(root.liveDevice.state)
                    if (root.connectFailed)    return addr + " · Try disconnecting from another device"
                    if (root.isPaired)         return addr + " · Paired"
                    return addr
                }
                color: root.isConnected ? Appearance.colors.primary : Appearance.colors.textTertiary
                font.pixelSize: Appearance.font.tiny
                font.family: Appearance.font.family
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                visible: !root.isOffline && (root.liveDevice?.batteryAvailable ?? false)
                text: "Battery: " + Math.round((root.liveDevice?.battery ?? 0) * 100) + "%"
                color: (root.liveDevice?.battery ?? 1) < 0.2
                    ? Appearance.colors.secondary
                    : Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.tiny
                font.family: Appearance.font.family
            }
        }

        // Action buttons
        ColumnLayout {
            spacing: Appearance.spacing.tiny
            Layout.alignment: Qt.AlignVCenter

            // Connect / Disconnect — always visible for live devices and offline paired devices
            Button {
                Layout.preferredWidth: 88
                Layout.preferredHeight: 24
                visible: !root.isOffline || (root.device?.paired ?? false) || (root.device?.bonded ?? false)
                text: root.isConnected ? "Disconnect"
                    : root.isBusy      ? "…"
                    :                    "Connect"
                fontSize: Appearance.font.small
                bold: true
                padding: 0
                loading: root.isBusy || root._waitingForPair
                variant: root.isConnected ? "outline" : "solid"
                opacity: (root.isBusy || root._waitingForPair || root.isOffline) ? 0.5 : 1.0

                onClicked: {
                    if (root.isBusy || root._waitingForPair || root.isOffline) return

                    if (root.isConnected) {
                        root.liveDevice.disconnect()
                        return
                    }

                    if (!root.isPaired) {
                        // New device: pair first. onPairingChanged will trust + connect.
                        root._pendingPairAddress = root.liveDevice.address
                        root.liveDevice.pair()
                    } else {
                        // Already paired: connect directly.
                        root.liveDevice.connect()
                    }
                }
            }

            // Forget — for live paired/bonded devices and offline stored entries
            Button {
                Layout.preferredWidth: 88
                Layout.preferredHeight: 24
                visible: ((root.device?.bonded ?? false) || (root.device?.paired ?? false))
                    && !root.isConnected && !root._waitingForPair
                text: "Forget"
                variant: "ghost"
                fontSize: Appearance.font.small
                padding: 0
                onClicked: {
                    if (!root.device?.address) return
                    root._pendingPairAddress = ""
                    BluetoothStore.forget(root.device.address)
                    if (!root.isOffline && root.liveDevice)
                        root.liveDevice.forget()
                }
            }
        }
    }
}
