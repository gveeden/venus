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
                icon: "󱠄"
                title: "Headboard"
                subtitle: Home.headboardOn ? (Home.headboardBrightness + "%") : "Off"
                isOn: Home.headboardOn
                isLoading: Home.headboardLoading
                lightColor: Home.headboardColor
                brightness: Home.headboardBrightness
                onClicked: Home.toggleHeadboard()
                onLongPressed: lightDetail.visible = true
            }

            HomeTile {
                icon: "󱠄"
                title: "Entrance"
                subtitle: Home.entranceOn ? "On" : "Off"
                isOn: Home.entranceOn
                isLoading: Home.entranceLoading
                onClicked: Home.toggleEntrance()
            }

            HomeTile {
                icon: "󱠄"
                title: "Living Room"
                subtitle: Home.livingRoomOn ? "On" : "Off"
                isOn: Home.livingRoomOn
                isLoading: Home.livingRoomLoading
                onClicked: Home.toggleLivingRoom()
            }

            HomeTile {
                icon: "󱠄"
                title: "Kitchen"
                subtitle: Home.kitchenOn ? "On" : "Off"
                isOn: Home.kitchenOn
                isLoading: Home.kitchenLoading
                onClicked: Home.toggleKitchen()
            }
        }
        
        Item { Layout.fillHeight: true } // Spacer to keep items at the top
    }

    LightDetail {
        id: lightDetail
        anchors.fill: parent
        visible: false
        title: "Headboard Light"
        isOn: Home.headboardOn
        brightness: Home.headboardBrightness
        lightColor: Home.headboardColor
        onClose: visible = false
        onPowerToggled: Home.toggleHeadboard()
        onBrightnessRequested: value => Home.setHeadboardBrightness(value)
        onColorRequested: value => Home.setHeadboardColor(value)
        
        // Handle popup state to inhibit auto-close
        onPopupOpened: root.popupOpened()
        onPopupClosed: root.popupClosed()
    }
}
