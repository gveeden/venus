pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool wifiEnabled: true
    readonly property bool scanning: rescanProc.running
    readonly property list<AccessPoint> networks: []
    readonly property AccessPoint active: networks.find(n => n.active) ?? null
    property list<string> savedConnections: []
    property list<string> savedConnectionSsids: []

    property var wifiConnectionQueue: []
    property int currentSsidQueryIndex: 0
    property var pendingConnection: null
    signal connectionFailed(string ssid)

    property list<var> activeProcesses: []

    // Constants
    readonly property string deviceTypeWifi: "wifi"
    readonly property string connectionTypeWireless: "802-11-wireless"
    readonly property string nmcliCommandDevice: "device"
    readonly property string nmcliCommandConnection: "connection"
    readonly property string nmcliCommandWifi: "wifi"
    readonly property string nmcliCommandRadio: "radio"
    readonly property string connectionListFields: "NAME,TYPE"
    readonly property string wirelessSsidField: "802-11-wireless.ssid"
    readonly property string networkDetailFields: "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY"
    readonly property string securityKeyMgmt: "802-11-wireless-security.key-mgmt"
    readonly property string securityPsk: "802-11-wireless-security.psk"
    readonly property string keyMgmtWpaPsk: "wpa-psk"
    readonly property string connectionParamType: "type"
    readonly property string connectionParamConName: "con-name"
    readonly property string connectionParamIfname: "ifname"
    readonly property string connectionParamSsid: "ssid"
    readonly property string connectionParamPassword: "password"
    readonly property string connectionParamBssid: "802-11-wireless.bssid"

    function detectPasswordRequired(error: string): bool {
        if (!error || error.length === 0) {
            return false
        }

        return (error.includes("Secrets were required") || error.includes("Secrets were required, but not provided") || error.includes("No secrets provided") || error.includes("802-11-wireless-security.psk") || error.includes("password for") || (error.includes("password") && !error.includes("Connection activated") && !error.includes("successfully")) || (error.includes("Secrets") && !error.includes("Connection activated") && !error.includes("successfully")) || (error.includes("802.11") && !error.includes("Connection activated") && !error.includes("successfully"))) && !error.includes("Connection activated") && !error.includes("successfully")
    }

    function parseNetworkOutput(output: string): list<var> {
        if (!output || output.length === 0) {
            return []
        }

        const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED"
        const rep = new RegExp("\\\\:", "g")
        const rep2 = new RegExp(PLACEHOLDER, "g")

        const allNetworks = output.trim().split("\n").filter(line => line && line.length > 0).map(n => {
            const net = n.replace(rep, PLACEHOLDER).split(":")
            return {
                active: net[0] === "yes",
                strength: parseInt(net[1] || "0", 10) || 0,
                frequency: parseInt(net[2] || "0", 10) || 0,
                ssid: (net[3]?.replace(rep2, ":") ?? "").trim(),
                bssid: (net[4]?.replace(rep2, ":") ?? "").trim(),
                security: (net[5] ?? "").trim()
            }
        }).filter(n => n.ssid && n.ssid.length > 0)

        return allNetworks
    }

    function deduplicateNetworks(networks: list<var>): list<var> {
        if (!networks || networks.length === 0) {
            return []
        }

        const networkMap = new Map()
        for (const network of networks) {
            const existing = networkMap.get(network.ssid)
            if (!existing) {
                networkMap.set(network.ssid, network)
            } else {
                if (network.active && !existing.active) {
                    networkMap.set(network.ssid, network)
                } else if (!network.active && !existing.active) {
                    if (network.strength > existing.strength) {
                        networkMap.set(network.ssid, network)
                    }
                }
            }
        }

        return Array.from(networkMap.values())
    }

    function isConnectionCommand(command: list<string>): bool {
        if (!command || command.length === 0) {
            return false
        }

        return command.includes(root.nmcliCommandWifi) || command.includes(root.nmcliCommandConnection)
    }

    function executeCommand(args: list<string>, callback: var): void {
        const proc = commandProc.createObject(root)
        proc.command = ["nmcli", ...args]
        proc.callback = callback

        activeProcesses.push(proc)

        proc.processFinished.connect(() => {
            const index = activeProcesses.indexOf(proc)
            if (index >= 0) {
                activeProcesses.splice(index, 1)
            }
        })

        Qt.callLater(() => {
            proc.exec(proc.command)
        })
    }

    function connectToNetworkWithPasswordCheck(ssid: string, isSecure: bool, callback: var, bssid: string): void {
        if (isSecure) {
            const hasBssid = bssid !== undefined && bssid !== null && bssid.length > 0
            connectWireless(ssid, "", bssid, result => {
                if (result.success) {
                    if (callback)
                        callback({
                            success: true,
                            usedSavedPassword: true,
                            output: result.output,
                            error: "",
                            exitCode: 0
                        })
                } else if (result.needsPassword) {
                    if (callback)
                        callback({
                            success: false,
                            needsPassword: true,
                            output: result.output,
                            error: result.error,
                            exitCode: result.exitCode
                        })
                } else {
                    if (callback)
                        callback(result)
                }
            })
        } else {
            connectWireless(ssid, "", bssid, callback)
        }
    }

    function connectToNetwork(ssid: string, password: string, bssid: string, callback: var): void {
        connectWireless(ssid, password, bssid, callback)
    }

    function connectWireless(ssid: string, password: string, bssid: string, callback: var, retryCount: int): void {
        const hasBssid = bssid !== undefined && bssid !== null && bssid.length > 0
        const retries = retryCount !== undefined ? retryCount : 0
        const maxRetries = 2

        if (callback) {
            root.pendingConnection = {
                ssid: ssid,
                bssid: hasBssid ? bssid : "",
                callback: callback,
                retryCount: retries
            }
            connectionCheckTimer.start()
            immediateCheckTimer.checkCount = 0
            immediateCheckTimer.start()
        }

        if (password && password.length > 0 && hasBssid) {
            const bssidUpper = bssid.toUpperCase()
            createConnectionWithPassword(ssid, bssidUpper, password, callback)
            return
        }

        let cmd = [root.nmcliCommandDevice, root.nmcliCommandWifi, "connect", ssid]
        if (password && password.length > 0) {
            cmd.push(root.connectionParamPassword, password)
        }
        executeCommand(cmd, result => {
            if (result.needsPassword && callback) {
                if (callback)
                    callback(result)
                return
            }

            if (!result.success && root.pendingConnection && retries < maxRetries) {
                console.warn("[NMCLI] Connection failed, retrying... (attempt " + (retries + 1) + "/" + maxRetries + ")")
                Qt.callLater(() => {
                    connectWireless(ssid, password, bssid, callback, retries + 1)
                }, 1000)
            } else if (!result.success && root.pendingConnection) {} else if (result.success && callback) {} else if (!result.success && !root.pendingConnection) {
                if (callback)
                    callback(result)
            }
        })
    }

    function createConnectionWithPassword(ssid: string, bssidUpper: string, password: string, callback: var): void {
        checkAndDeleteConnection(ssid, () => {
            const cmd = [root.nmcliCommandConnection, "add", root.connectionParamType, root.deviceTypeWifi, root.connectionParamConName, ssid, root.connectionParamIfname, "*", root.connectionParamSsid, ssid, root.connectionParamBssid, bssidUpper, root.securityKeyMgmt, root.keyMgmtWpaPsk, root.securityPsk, password]

            executeCommand(cmd, result => {
                if (result.success) {
                    loadSavedConnections(() => {})
                    activateConnection(ssid, callback)
                } else {
                    const hasDuplicateWarning = result.error && (result.error.includes("another connection with the name") || result.error.includes("Reference the connection by its uuid"))

                    if (hasDuplicateWarning || (result.exitCode > 0 && result.exitCode < 10)) {
                        loadSavedConnections(() => {})
                        activateConnection(ssid, callback)
                    } else {
                        console.warn("[NMCLI] Connection profile creation failed, trying fallback...")
                        let fallbackCmd = [root.nmcliCommandDevice, root.nmcliCommandWifi, "connect", ssid, root.connectionParamPassword, password]
                        executeCommand(fallbackCmd, fallbackResult => {
                            if (callback)
                                callback(fallbackResult)
                        })
                    }
                }
            })
        })
    }

    function checkAndDeleteConnection(ssid: string, callback: var): void {
        executeCommand([root.nmcliCommandConnection, "show", ssid], result => {
            if (result.success) {
                executeCommand([root.nmcliCommandConnection, "delete", ssid], deleteResult => {
                    Qt.callLater(() => {
                        if (callback)
                            callback()
                    }, 300)
                })
            } else {
                if (callback)
                    callback()
            }
        })
    }

    function activateConnection(connectionName: string, callback: var): void {
        executeCommand([root.nmcliCommandConnection, "up", connectionName], result => {
            if (callback)
                callback(result)
        })
    }

    function loadSavedConnections(callback: var): void {
        executeCommand(["-t", "-f", root.connectionListFields, root.nmcliCommandConnection, "show"], result => {
            if (!result.success) {
                root.savedConnections = []
                root.savedConnectionSsids = []
                if (callback)
                    callback([])
                return
            }

            parseConnectionList(result.output, callback)
        })
    }

    function parseConnectionList(output: string, callback: var): void {
        const lines = output.trim().split("\n").filter(line => line.length > 0)
        const wifiConnections = []
        const connections = []

        for (const line of lines) {
            const parts = line.split(":")
            if (parts.length >= 2) {
                const name = parts[0]
                const type = parts[1]
                connections.push(name)

                if (type === root.connectionTypeWireless) {
                    wifiConnections.push(name)
                }
            }
        }

        root.savedConnections = connections

        if (wifiConnections.length > 0) {
            root.wifiConnectionQueue = wifiConnections
            root.currentSsidQueryIndex = 0
            root.savedConnectionSsids = []
            queryNextSsid(callback)
        } else {
            root.savedConnectionSsids = []
            root.wifiConnectionQueue = []
            if (callback)
                callback(root.savedConnectionSsids)
        }
    }

    function queryNextSsid(callback: var): void {
        if (root.currentSsidQueryIndex < root.wifiConnectionQueue.length) {
            const connectionName = root.wifiConnectionQueue[root.currentSsidQueryIndex]
            root.currentSsidQueryIndex++

            executeCommand(["-t", "-f", root.wirelessSsidField, root.nmcliCommandConnection, "show", connectionName], result => {
                if (result.success) {
                    processSsidOutput(result.output)
                }
                queryNextSsid(callback)
            })
        } else {
            root.wifiConnectionQueue = []
            root.currentSsidQueryIndex = 0
            if (callback)
                callback(root.savedConnectionSsids)
        }
    }

    function processSsidOutput(output: string): void {
        const lines = output.trim().split("\n")
        for (const line of lines) {
            if (line.startsWith("802-11-wireless.ssid:")) {
                const ssid = line.substring("802-11-wireless.ssid:".length).trim()
                if (ssid && ssid.length > 0) {
                    const ssidLower = ssid.toLowerCase()
                    const exists = root.savedConnectionSsids.some(s => s && s.toLowerCase() === ssidLower)
                    if (!exists) {
                        const newList = root.savedConnectionSsids.slice()
                        newList.push(ssid)
                        root.savedConnectionSsids = newList
                    }
                }
            }
        }
    }

    function hasSavedProfile(ssid: string): bool {
        if (!ssid || ssid.length === 0) {
            return false
        }
        const ssidLower = ssid.toLowerCase().trim()

        if (root.active && root.active.ssid) {
            const activeSsidLower = root.active.ssid.toLowerCase().trim()
            if (activeSsidLower === ssidLower) {
                return true
            }
        }

        const hasSsid = root.savedConnectionSsids.some(savedSsid => savedSsid && savedSsid.toLowerCase().trim() === ssidLower)

        if (hasSsid) {
            return true
        }

        const hasConnectionName = root.savedConnections.some(connName => connName && connName.toLowerCase().trim() === ssidLower)

        return hasConnectionName
    }

    function forgetNetwork(ssid: string, callback: var): void {
        if (!ssid || ssid.length === 0) {
            if (callback)
                callback({
                    success: false,
                    output: "",
                    error: "No SSID specified",
                    exitCode: -1
                })
            return
        }

        const connectionName = root.savedConnections.find(conn => conn && conn.toLowerCase().trim() === ssid.toLowerCase().trim()) || ssid

        executeCommand([root.nmcliCommandConnection, "delete", connectionName], result => {
            if (result.success) {
                Qt.callLater(() => {
                    loadSavedConnections(() => {})
                }, 500)
            }
            if (callback)
                callback(result)
        })
    }

    function disconnectFromNetwork(): void {
        if (active && active.ssid) {
            executeCommand([root.nmcliCommandConnection, "down", active.ssid], result => {
                if (result.success) {
                    getNetworks(() => {})
                }
            })
        } else {
            executeCommand([root.nmcliCommandDevice, "disconnect", root.deviceTypeWifi], result => {
                if (result.success) {
                    getNetworks(() => {})
                }
            })
        }
    }

    function rescanWifi(): void {
        rescanProc.running = true
    }

    function enableWifi(enabled: bool, callback: var): void {
        const cmd = enabled ? "on" : "off"
        executeCommand([root.nmcliCommandRadio, root.nmcliCommandWifi, cmd], result => {
            if (result.success) {
                getWifiStatus(status => {
                    root.wifiEnabled = status
                    if (callback)
                        callback(result)
                })
            } else {
                if (callback)
                    callback(result)
            }
        })
    }

    function toggleWifi(callback: var): void {
        const newState = !root.wifiEnabled
        enableWifi(newState, callback)
    }

    function getWifiStatus(callback: var): void {
        executeCommand([root.nmcliCommandRadio, root.nmcliCommandWifi], result => {
            if (result.success) {
                const enabled = result.output.trim() === "enabled"
                root.wifiEnabled = enabled
                if (callback)
                    callback(enabled)
            } else {
                if (callback)
                    callback(root.wifiEnabled)
            }
        })
    }

    function getNetworks(callback: var): void {
        executeCommand(["-g", root.networkDetailFields, "d", "w"], result => {
            if (!result.success) {
                if (callback)
                    callback([])
                return
            }

            const allNetworks = parseNetworkOutput(result.output)
            const networks = deduplicateNetworks(allNetworks)
            const rNetworks = root.networks

            const destroyed = rNetworks.filter(rn => !networks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid))
            for (const network of destroyed) {
                const index = rNetworks.indexOf(network)
                if (index >= 0) {
                    rNetworks.splice(index, 1)
                    network.destroy()
                }
            }

            for (const network of networks) {
                const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid)
                if (match) {
                    match.lastIpcObject = network
                } else {
                    rNetworks.push(apComp.createObject(root, {
                        lastIpcObject: network
                    }))
                }
            }

            if (callback)
                callback(root.networks)
            checkPendingConnection()
        })
    }

    function handlePasswordRequired(proc: var, error: string, output: string, exitCode: int): bool {
        if (!proc || !error || error.length === 0) {
            return false
        }

        if (!isConnectionCommand(proc.command) || !root.pendingConnection || !root.pendingConnection.callback) {
            return false
        }

        const needsPassword = detectPasswordRequired(error)

        if (needsPassword && !proc.callbackCalled && root.pendingConnection) {
            connectionCheckTimer.stop()
            immediateCheckTimer.stop()
            immediateCheckTimer.checkCount = 0
            const pending = root.pendingConnection
            root.pendingConnection = null
            proc.callbackCalled = true
            const result = {
                success: false,
                output: output || "",
                error: error,
                exitCode: exitCode,
                needsPassword: true
            }
            if (pending.callback) {
                pending.callback(result)
            }
            if (proc.callback && proc.callback !== pending.callback) {
                proc.callback(result)
            }
            return true
        }

        return false
    }

    component CommandProcess: Process {
        id: proc

        property var callback: null
        property list<string> command: []
        property bool callbackCalled: false
        property int exitCode: 0

        signal processFinished

        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })

        stdout: StdioCollector {
            id: stdoutCollector
        }

        stderr: StdioCollector {
            id: stderrCollector

            onStreamFinished: {
                const error = text.trim()
                if (error && error.length > 0) {
                    const output = (stdoutCollector && stdoutCollector.text) ? stdoutCollector.text : ""
                    root.handlePasswordRequired(proc, error, output, -1)
                }
            }
        }

        onExited: code => {
            exitCode = code

            Qt.callLater(() => {
                if (callbackCalled) {
                    processFinished()
                    return
                }

                if (proc.callback) {
                    const output = (stdoutCollector && stdoutCollector.text) ? stdoutCollector.text : ""
                    const error = (stderrCollector && stderrCollector.text) ? stderrCollector.text : ""
                    const success = exitCode === 0
                    const cmdIsConnection = isConnectionCommand(proc.command)

                    if (root.handlePasswordRequired(proc, error, output, exitCode)) {
                        processFinished()
                        return
                    }

                    const needsPassword = cmdIsConnection && root.detectPasswordRequired(error)

                    if (!success && cmdIsConnection && root.pendingConnection) {
                        const failedSsid = root.pendingConnection.ssid
                        root.connectionFailed(failedSsid)
                    }

                    callbackCalled = true
                    callback({
                        success: success,
                        output: output,
                        error: error,
                        exitCode: proc.exitCode,
                        needsPassword: needsPassword || false
                    })
                    processFinished()
                } else {
                    processFinished()
                }
            })
        }
    }

    Component {
        id: commandProc

        CommandProcess {}
    }

    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
        readonly property string security: lastIpcObject.security
        readonly property bool isSecure: security.length > 0
    }

    Component {
        id: apComp

        AccessPoint {}
    }

    Timer {
        id: connectionCheckTimer

        interval: 4000
        onTriggered: {
            if (root.pendingConnection) {
                const connected = root.active && root.active.ssid === root.pendingConnection.ssid

                if (!connected && root.pendingConnection.callback) {
                    let foundPasswordError = false
                    for (let i = 0; i < root.activeProcesses.length; i++) {
                        const proc = root.activeProcesses[i]
                        if (proc && proc.stderr && proc.stderr.text) {
                            const error = proc.stderr.text.trim()
                            if (error && error.length > 0) {
                                if (root.isConnectionCommand(proc.command)) {
                                    const needsPassword = root.detectPasswordRequired(error)

                                    if (needsPassword && !proc.callbackCalled && root.pendingConnection) {
                                        const pending = root.pendingConnection
                                        root.pendingConnection = null
                                        immediateCheckTimer.stop()
                                        immediateCheckTimer.checkCount = 0
                                        proc.callbackCalled = true
                                        const result = {
                                            success: false,
                                            output: (proc.stdout && proc.stdout.text) ? proc.stdout.text : "",
                                            error: error,
                                            exitCode: -1,
                                            needsPassword: true
                                        }
                                        if (pending.callback) {
                                            pending.callback(result)
                                        }
                                        if (proc.callback && proc.callback !== pending.callback) {
                                            proc.callback(result)
                                        }
                                        foundPasswordError = true
                                        break
                                    }
                                }
                            }
                        }
                    }

                    if (!foundPasswordError) {
                        const pending = root.pendingConnection
                        const failedSsid = pending.ssid
                        root.pendingConnection = null
                        immediateCheckTimer.stop()
                        immediateCheckTimer.checkCount = 0
                        root.connectionFailed(failedSsid)
                        pending.callback({
                            success: false,
                            output: "",
                            error: "Connection timeout",
                            exitCode: -1,
                            needsPassword: false
                        })
                    }
                } else if (connected) {
                    root.pendingConnection = null
                    immediateCheckTimer.stop()
                    immediateCheckTimer.checkCount = 0
                }
            }
        }
    }

    Timer {
        id: immediateCheckTimer

        property int checkCount: 0

        interval: 500
        repeat: true
        triggeredOnStart: false

        onTriggered: {
            if (root.pendingConnection) {
                checkCount++
                const connected = root.active && root.active.ssid === root.pendingConnection.ssid

                if (connected) {
                    connectionCheckTimer.stop()
                    immediateCheckTimer.stop()
                    immediateCheckTimer.checkCount = 0
                    if (root.pendingConnection.callback) {
                        root.pendingConnection.callback({
                            success: true,
                            output: "Connected",
                            error: "",
                            exitCode: 0
                        })
                    }
                    root.pendingConnection = null
                } else {
                    for (let i = 0; i < root.activeProcesses.length; i++) {
                        const proc = root.activeProcesses[i]
                        if (proc && proc.stderr && proc.stderr.text) {
                            const error = proc.stderr.text.trim()
                            if (error && error.length > 0) {
                                if (root.isConnectionCommand(proc.command)) {
                                    const needsPassword = root.detectPasswordRequired(error)

                                    if (needsPassword && !proc.callbackCalled && root.pendingConnection && root.pendingConnection.callback) {
                                        connectionCheckTimer.stop()
                                        immediateCheckTimer.stop()
                                        immediateCheckTimer.checkCount = 0
                                        const pending = root.pendingConnection
                                        root.pendingConnection = null
                                        proc.callbackCalled = true
                                        const result = {
                                            success: false,
                                            output: (proc.stdout && proc.stdout.text) ? proc.stdout.text : "",
                                            error: error,
                                            exitCode: -1,
                                            needsPassword: true
                                        }
                                        if (pending.callback) {
                                            pending.callback(result)
                                        }
                                        if (proc.callback && proc.callback !== pending.callback) {
                                            proc.callback(result)
                                        }
                                        return
                                    }
                                }
                            }
                        }
                    }

                    if (checkCount >= 6) {
                        immediateCheckTimer.stop()
                        immediateCheckTimer.checkCount = 0
                    }
                }
            } else {
                immediateCheckTimer.stop()
                immediateCheckTimer.checkCount = 0
            }
        }
    }

    function checkPendingConnection(): void {
        if (root.pendingConnection) {
            Qt.callLater(() => {
                const connected = root.active && root.active.ssid === root.pendingConnection.ssid
                if (connected) {
                    connectionCheckTimer.stop()
                    immediateCheckTimer.stop()
                    immediateCheckTimer.checkCount = 0
                    if (root.pendingConnection.callback) {
                        root.pendingConnection.callback({
                            success: true,
                            output: "Connected",
                            error: "",
                            exitCode: 0
                        })
                    }
                    root.pendingConnection = null
                } else {
                    if (!immediateCheckTimer.running) {
                        immediateCheckTimer.start()
                    }
                }
            })
        }
    }

    Process {
        id: rescanProc

        command: ["nmcli", "dev", root.nmcliCommandWifi, "list", "--rescan", "yes"]
        onExited: root.getNetworks()
    }

    Process {
        id: monitorProc

        running: true
        command: ["nmcli", "monitor"]
        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })
        stdout: SplitParser {
            onRead: root.getNetworks(() => {})
        }
        onExited: monitorRestartTimer.start()
    }

    Timer {
        id: monitorRestartTimer
        interval: 2000
        onTriggered: {
            monitorProc.running = true
        }
    }

    Component.onCompleted: {
        getWifiStatus(() => {})
        getNetworks(() => {})
        loadSavedConnections(() => {})
    }
}
