import "../../../config"
import "../../../services"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property var network: Networks.pendingNetwork
    property bool isClosing: false
    property string passwordBuffer: ""
    property bool connecting: false
    property bool hasError: false

    visible: Networks.showPasswordDialog || isClosing
    enabled: Networks.showPasswordDialog && !isClosing
    focus: enabled

    Keys.onEscapePressed: {
        closeDialog()
    }

    function closeDialog(): void {
        isClosing = true
    }

    // Background overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        opacity: Networks.showPasswordDialog && !root.isClosing ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: closeDialog()
        }
    }

    // Dialog card
    Rectangle {
        id: dialog

        anchors.centerIn: parent

        implicitWidth: 350
        implicitHeight: content.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.medium
        color: Appearance.colors.surface
        border.width: 2
        border.color: Appearance.colors.border
        opacity: Networks.showPasswordDialog && !root.isClosing ? 1 : 0
        scale: Networks.showPasswordDialog && !root.isClosing ? 1 : 0.7

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }

        ParallelAnimation {
            running: root.isClosing
            onFinished: {
                if (root.isClosing) {
                    Networks.showPasswordDialog = false
                    // Clear pending network when closing dialog without connecting
                    Networks.pendingNetwork = null
                    root.isClosing = false
                    root.passwordBuffer = ""
                    root.hasError = false
                    root.connecting = false
                }
            }

            NumberAnimation {
                target: dialog
                property: "opacity"
                to: 0
                duration: 150
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: dialog
                property: "scale"
                to: 0.7
                duration: 150
                easing.type: Easing.InQuad
            }
        }

        Keys.onEscapePressed: closeDialog()

        ColumnLayout {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large

            spacing: Appearance.spacing.medium

            // Lock icon
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "🔒"
                font.pixelSize: Appearance.font.xlarge * 3
            }

            // Title
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Enter Password"
                font.pixelSize: Appearance.font.large
                font.bold: true
                color: Appearance.colors.text
            }

            // Network name
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.network ? ("Network: " + root.network.ssid) : ""
                color: Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.small
            }

            // Status text
            Text {
                id: statusText

                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Appearance.spacing.small
                visible: root.connecting || root.hasError
                text: {
                    if (root.hasError) {
                        return "Connection failed. Please check your password and try again."
                    }
                    if (root.connecting) {
                        return "Connecting..."
                    }
                    return ""
                }
                color: root.hasError ? Appearance.colors.secondary : Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.small
                wrapMode: Text.WordWrap
                Layout.maximumWidth: parent.width - Appearance.padding.large * 2
                horizontalAlignment: Text.AlignHCenter
            }

            // Password input container
            Item {
                id: passwordContainer
                Layout.topMargin: Appearance.spacing.large
                Layout.fillWidth: true
                implicitHeight: 48

                focus: true
                Keys.onPressed: event => {
                    if (!activeFocus) {
                        forceActiveFocus()
                    }

                    if (root.hasError && event.text && event.text.length > 0) {
                        root.hasError = false
                    }

                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        if (connectButton.enabled && !root.connecting) {
                            connectToNetwork()
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_Backspace) {
                        if (event.modifiers & Qt.ControlModifier) {
                            root.passwordBuffer = ""
                        } else {
                            root.passwordBuffer = root.passwordBuffer.slice(0, -1)
                        }
                        event.accepted = true
                    } else if (event.text && event.text.length > 0) {
                        root.passwordBuffer += event.text
                        event.accepted = true
                    }
                }

                Connections {
                    target: Networks
                    function onShowPasswordDialogChanged(): void {
                        if (Networks.showPasswordDialog) {
                            Qt.callLater(() => {
                                passwordContainer.forceActiveFocus()
                                root.passwordBuffer = ""
                                root.hasError = false
                                root.connecting = false
                            })
                        }
                    }
                }

                Connections {
                    target: root
                    function onVisibleChanged(): void {
                        if (root.visible) {
                            Qt.callLater(() => {
                                passwordContainer.forceActiveFocus()
                            })
                        }
                    }
                }

                // Input field background
                Rectangle {
                    anchors.fill: parent
                    radius: Appearance.rounding.small
                    color: passwordContainer.activeFocus 
                        ? Qt.lighter(Appearance.colors.surfaceHighlight, 1.05) 
                        : Appearance.colors.surfaceHighlight
                    border.width: passwordContainer.activeFocus || root.hasError ? 2 : 1
                    border.color: {
                        if (root.hasError) {
                            return Appearance.colors.secondary
                        }
                        if (passwordContainer.activeFocus) {
                            return Appearance.colors.primary
                        }
                        return Appearance.colors.border
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                // Click to focus
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        passwordContainer.forceActiveFocus()
                    }
                }

                // Placeholder text
                Text {
                    id: placeholder
                    anchors.centerIn: parent
                    text: "Enter password"
                    color: Appearance.colors.textTertiary
                    font.pixelSize: Appearance.font.regular
                    visible: root.passwordBuffer.length === 0
                }

                // Password bullets display
                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    visible: root.passwordBuffer.length > 0

                    Repeater {
                        model: root.passwordBuffer.length

                        Text {
                            text: "•"
                            color: Appearance.colors.text
                            font.pixelSize: Appearance.font.large
                            font.bold: true
                        }
                    }
                }
            }

            // Button row
            RowLayout {
                Layout.topMargin: Appearance.spacing.medium
                Layout.fillWidth: true
                spacing: Appearance.spacing.medium

                // Cancel button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: Appearance.colors.surfaceHighlight
                    radius: Appearance.rounding.small

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Appearance.colors.text
                        font.pixelSize: Appearance.font.regular
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: closeDialog()
                    }
                }

                // Connect button
                Rectangle {
                    id: connectButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: enabled 
                        ? Appearance.colors.primaryContainer 
                        : Appearance.colors.surface
                    radius: Appearance.rounding.small
                    enabled: root.passwordBuffer.length >= 8 && !root.connecting

                    Text {
                        anchors.centerIn: parent
                        text: root.connecting ? "Connecting..." : "Connect"
                        color: connectButton.enabled 
                            ? Appearance.colors.background 
                            : Appearance.colors.textTertiary
                        font.pixelSize: Appearance.font.regular
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: connectButton.enabled
                        onClicked: connectToNetwork()
                    }
                }
            }
        }
    }

    function connectToNetwork(): void {
        if (root.connecting || !root.network) return

        root.connecting = true
        root.hasError = false

        Networks.connectToNetwork(root.network, root.passwordBuffer)

        // Monitor connection result
        const connectionTimer = Qt.createQmlObject('
            import QtQuick 2.0
            Timer {
                interval: 100
                repeat: true
                running: true
            }
        ', root)

        let checkCount = 0
        connectionTimer.triggered.connect(() => {
            checkCount++
            
            // Check if connected
            if (root.network && root.network.active) {
                root.connecting = false
                connectionTimer.stop()
                connectionTimer.destroy()
                closeDialog()
                return
            }

            // Check if dialog closed (canceled)
            if (!Networks.showPasswordDialog) {
                root.connecting = false
                connectionTimer.stop()
                connectionTimer.destroy()
                return
            }

            // Timeout after 5 seconds
            if (checkCount > 50) {
                root.connecting = false
                root.hasError = true
                connectionTimer.stop()
                connectionTimer.destroy()
            }
        })
    }

    // Listen for connection failures
    Connections {
        target: Networks
        function onConnectionFailed(ssid): void {
            if (root.network && root.network.ssid === ssid) {
                root.connecting = false
                root.hasError = true
            }
        }
    }
}
