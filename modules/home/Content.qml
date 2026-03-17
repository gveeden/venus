import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"
import "../../components/home"
import "components"

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    signal popupOpened()
    signal popupClosed()
    signal detailVisibleChanged(bool visible)

    property string selectedLight: "headboard"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.large
        visible: !lightDetail.visible
        onVisibleChanged: root.detailVisibleChanged(!visible)

        Text {
            text: "Home"
            font.family: Appearance.font.family
            font.pixelSize: Appearance.font.xlarge
            font.weight: Font.Bold
            color: Appearance.colors.text
        }

        Flow {
            Layout.fillWidth: true
            spacing: Appearance.spacing.medium

            HomeTile {
                icon: "󰛨"
                title: "Headboard"
                subtitle: Home.headboardOn ? (Home.headboardBrightness + "%") : "Off"
                isOn: Home.headboardOn
                isLoading: Home.headboardLoading
                lightColor: Home.headboardColor
                brightness: Home.headboardBrightness
                onClicked: Home.toggleHeadboard()
                onLongPressed: {
                    root.selectedLight = "headboard"
                    lightDetail.visible = true
                }
            }

            HomeTile {
                icon: "󰛨"
                title: "Entrance"
                subtitle: Home.entranceOn ? "On" : "Off"
                isOn: Home.entranceOn
                isLoading: Home.entranceLoading
                onClicked: Home.toggleEntrance()
            }

            HomeTile {
                icon: "󰛨"
                title: "Living Room"
                subtitle: Home.livingRoomOn ? "On" : "Off"
                isOn: Home.livingRoomOn
                isLoading: Home.livingRoomLoading
                onClicked: Home.toggleLivingRoom()
            }

            HomeTile {
                icon: "󰛨"
                title: "Kitchen"
                subtitle: Home.kitchenOn ? (Home.kitchenBrightness + "%") : "Off"
                isOn: Home.kitchenOn
                isLoading: Home.kitchenLoading
                lightColor: Home.kitchenColor
                brightness: Home.kitchenBrightness
                onClicked: Home.toggleKitchen()
                onLongPressed: {
                    root.selectedLight = "kitchen"
                    lightDetail.visible = true
                }
            }
        }
        
        Item { Layout.fillHeight: true } // Spacer to keep items at the top
    }

    LightDetail {
        id: lightDetail
        anchors.fill: parent
        visible: false
        title: selectedLight === "headboard" ? "Headboard Light" : "Kitchen Light"
        isOn: selectedLight === "headboard" ? Home.headboardOn : Home.kitchenOn
        brightness: selectedLight === "headboard" ? Home.headboardBrightness : Home.kitchenBrightness
        lightColor: selectedLight === "headboard" ? Home.headboardColor : Home.kitchenColor
        onClose: visible = false
        onPowerToggled: {
            if (selectedLight === "headboard") Home.toggleHeadboard()
            else Home.toggleKitchen()
        }
        onBrightnessRequested: value => {
            if (selectedLight === "headboard") Home.setHeadboardBrightness(value)
            else Home.setKitchenBrightness(value)
        }
        onColorRequested: value => {
            if (selectedLight === "headboard") Home.setHeadboardColor(value)
            else Home.setKitchenColor(value)
        }
        
        // Handle popup state to inhibit auto-close
        onPopupOpened: root.popupOpened()
        onPopupClosed: root.popupClosed()
    }
}
