import "../../../config"
import "../../../services"
import "../../../components/controls"
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var network

    readonly property bool loading: network && Networks.pendingNetwork === network
    readonly property bool connected: network && network.active
    readonly property bool saved: network && Networks.hasSavedProfile(network.ssid)

    // Clipboard copy process
    Process {
        id: clipboardProc
        running: false
        command: ["wl-copy", ""]
    }

    // Notification process
    Process {
        id: notifyProc
        running: false
        command: ["notify-send", "Network", "MAC address copied to clipboard"]
    }

    function copyToClipboard(text: string): void {
        if (!text || text.length === 0)
            return;
        clipboardProc.command = ["wl-copy", text];
        clipboardProc.running = true;
        notifyProc.running = true;
    }

    // Signal strength calculation
    readonly property int signalStrength: network ? network.strength : 0
    readonly property string signalIcon: {
        if (signalStrength >= 75)
            return "󰤨";  // Excellent
        if (signalStrength >= 50)
            return "󰤥";  // Good
        if (signalStrength >= 25)
            return "󰤢";  // Fair
        return "󰤟";  // Weak
    }

    // Frequency detection (2.4GHz vs 5GHz)
    readonly property int frequency: network ? network.frequency : 0
    readonly property string frequencyBand: {
        if (frequency >= 5000)
            return "5GHz";
        if (frequency >= 2400)
            return "2.4GHz";
        return "";
    }

    // Security icon and type
    readonly property bool isSecure: network && network.isSecure
    readonly property string securityType: network ? network.security : ""

    width: parent ? parent.width : 0
    height: 110
    color: connected ? Appearance.colors.surfaceHighlight : Appearance.colors.background
    radius: Appearance.rounding.small

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.spacing.medium
        spacing: Appearance.spacing.small

        // Header row with SSID, signal, security
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            // Signal strength icon
            Text {
                text: root.signalIcon
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.medium
            }

            // SSID
            Text {
                text: root.network ? (root.network.ssid || "Unknown Network") : "Unknown"
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.medium
                font.bold: true
            }

            // Frequency band
            Rectangle {
                visible: root.frequencyBand.length > 0
                Layout.preferredWidth: 50
                Layout.preferredHeight: 12
                color: Appearance.colors.secondaryContainer
                radius: Appearance.rounding.small

                Text {
                    anchors.centerIn: parent
                    text: root.frequencyBand
                    color: Appearance.colors.background
                    font.pixelSize: Appearance.font.tiny
                    font.bold: true
                }
            }

            // Security icon
            Text {
                visible: root.isSecure
                text: ""
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family
                font.pixelSize: Appearance.font.small
            }
        }

        // Info row with BSSID, status, security type
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.medium

            MouseArea {
                Layout.preferredWidth: bssidText.implicitWidth
                Layout.preferredHeight: bssidText.implicitHeight
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (root.network && root.network.bssid) {
                        copyToClipboard(root.network.bssid);
                    }
                }

                Text {
                    id: bssidText
                    text: root.network ? root.network.bssid : ""
                    color: Appearance.colors.textTertiary
                    font.pixelSize: Appearance.font.tiny
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                visible: root.securityType.length > 0
                text: root.securityType
                color: Appearance.colors.textSecondary
                font.pixelSize: Appearance.font.tiny
            }
        }

        // Action buttons row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 25
            spacing: Appearance.spacing.small
            Layout.alignment: Qt.AlignRight

            // Forget button (only for saved networks)
            Button {
                visible: root.saved && !root.connected
                Layout.preferredWidth: 90
                Layout.preferredHeight: 25
                text: "Forget"
                variant: "outline"
                fontSize: Appearance.font.small
                padding: 0
                onClicked: {
                    if (root.network) {
                        Networks.forgetNetwork(root.network.ssid);
                    }
                }
            }

            // Connect/Disconnect button
            Button {
                Layout.preferredHeight: 25
                Layout.preferredWidth: 90
                text: root.connected ? "Disconnect" : "Connect"
                fontSize: Appearance.font.small
                bold: true
                padding: 0
                loading: root.loading
                variant: root.connected ? "outline" : "solid"
                onClicked: {
                    if (root.network) {
                        if (root.connected) {
                            Networks.disconnectFromNetwork();
                        } else {
                            Networks.connectToNetwork(root.network, "");
                        }
                    }
                }
            }
        }
    }
}
