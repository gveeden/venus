pragma Singleton
import QtQuick

QtObject {
    readonly property string commandTopic: "felix/homekit/command/set"
    readonly property string eventTopic: "felix/homekit/event/#"

    readonly property string mosquittoPub: "/usr/sbin/mosquitto_pub"
    readonly property string mosquittoSub: "/usr/sbin/mosquitto_sub"
    readonly property string mqttHost: "192.168.0.75"

    readonly property var devices: ({
            "headboard": {
                "id": "74:D8:4D:24:D1:9A",
                "aid": 1,
                "powerIid": 51,
                "brightnessIid": 52,
                "colorIid": 53
            },
            "entrance": {
                "id": "0A:4B:0E:02:43:25",
                "aid": 1,
                "powerIid": 51
            },
            "livingroom": {
                "id": "B5:30:8A:03:B8:5A",
                "aid": 1,
                "powerIid": 51
            },
            "kitchen": {
                "id": "E8CA504010B7",
                "name": "Kitchen Light",
                "driver": "tcp",
                "aid": 1,
                "powerIid": 51,
                "brightnessIid": 52,
                "colorIid": 53
            }
        })

    readonly property int tileWidth: 100
    readonly property int tileHeight: 100
    readonly property int spacing: 10
}
