import "../../../config"
import "../../../services"
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var network

    readonly property bool loading: network && Networks.pendingNetwork === network
    readonly property bool connected: network && network.active
    readonly property bool saved: network && Networks.hasSavedProfile(network.ssid)

    // Signal strength calculation
    readonly property int signalStrength: network ? network.strength : 0
    readonly property string signalIcon: {
        if (signalStrength >= 75) return "󰤨"  // Excellent
        if (signalStrength >= 50) return "󰤥"  // Good
        if (signalStrength >= 25) return "󰤢"  // Fair
        return "󰤟"  // Weak
    }

    // Frequency detection (2.4GHz vs 5GHz)
    readonly property int frequency: network ? network.frequency : 0
    readonly property string frequencyBand: {
        if (frequency >= 5000) return "5GHz"
        if (frequency >= 2400) return "2.4GHz"
        return ""
    }

    // Security icon and type
    readonly property bool isSecure: network && network.isSecure
    readonly property string securityType: network ? network.security : ""

    width: parent ? parent.width : 0
    height: 110
    color: connected 
        ? Appearance.colors.surfaceHighlight 
        : Appearance.colors.background
    radius: Appearance.rounding.small

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.spacing.medium
        spacing: Appearance.spacing.small

        // Header row with SSID, signal, security
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            // SSID
            Text {
                text: root.network ? (root.network.ssid || "Unknown Network") : "Unknown"
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.medium
                font.bold: true
                Layout.fillWidth: true
            }

            // Frequency band
            Rectangle {
                visible: root.frequencyBand.length > 0
                Layout.preferredWidth: 50
                Layout.preferredHeight: 18
                color: Appearance.colors.primary
                radius: Appearance.rounding.small

                Text {
                    anchors.centerIn: parent
                    text: root.frequencyBand
                    color: Appearance.colors.background
                    font.pixelSize: Appearance.font.tiny
                    font.bold: true
                }
            }

            // Signal strength icon
            Text {
                text: root.signalIcon
                color: Appearance.colors.text
                font.pixelSize: Appearance.font.medium
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

            Text {
                text: root.network ? root.network.bssid : ""
                color: Appearance.colors.textTertiary
                font.pixelSize: Appearance.font.tiny
            }

            Text {
                visible: root.connected
                text: "(Connected)"
                color: Appearance.colors.primaryContainer
                font.pixelSize: Appearance.font.tiny
                font.bold: true
            }

            Text {
                visible: !root.connected && root.saved
                text: "(Saved)"
                color: Appearance.colors.primary
                font.pixelSize: Appearance.font.tiny
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

        // Signal strength bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 3
            color: Appearance.colors.surface
            radius: 2

            Rectangle {
                width: parent.width * (root.signalStrength / 100)
                height: parent.height
                color: {
                    if (root.signalStrength >= 75) return Appearance.colors.primaryContainer
                    if (root.signalStrength >= 50) return Appearance.colors.primary
                    if (root.signalStrength >= 25) return Appearance.colors.secondaryContainer
                    return Appearance.colors.secondary
                }
                radius: parent.radius
            }
        }

        // Action buttons row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 25
            spacing: Appearance.spacing.small

            // Connect/Disconnect button
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.connected 
                    ? Appearance.colors.secondary 
                    : Appearance.colors.primaryContainer
                radius: Appearance.rounding.small

                Text {
                    anchors.centerIn: parent
                    text: root.loading ? "Loading..." : (root.connected ? "Disconnect" : "Connect")
                    color: Appearance.colors.background
                    font.pixelSize: Appearance.font.small
                    font.bold: true
                    visible: !root.loading
                }

                // Loading spinner
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    visible: root.loading

                    Rectangle {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        radius: 8
                        color: Appearance.colors.background

                        Rectangle {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            radius: 6
                            color: Appearance.colors.primaryContainer

                            RotationAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !root.loading
                    onClicked: {
                        if (root.network) {
                            if (root.connected) {
                                Networks.disconnectFromNetwork()
                            } else {
                                Networks.connectToNetwork(root.network, "")
                            }
                        }
                    }
                }
            }

            // Forget button (only for saved networks)
            Rectangle {
                visible: root.saved && !root.connected
                Layout.preferredWidth: 70
                Layout.fillHeight: true
                color: Appearance.colors.surfaceHighlight
                radius: Appearance.rounding.small

                Text {
                    anchors.centerIn: parent
                    text: "Forget"
                    color: Appearance.colors.text
                    font.pixelSize: Appearance.font.small
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.network) {
                            Networks.forgetNetwork(root.network.ssid)
                        }
                    }
                }
            }
        }
    }
}
