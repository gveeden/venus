pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../config"

Singleton {
    id: root

    // States
    property bool headboardOn: false
    property int headboardBrightness: 100
    property int headboardHue: 0
    property int headboardSaturation: 0
    readonly property string headboardColor: Qt.hsva(headboardHue/360, headboardSaturation/100, 1.0, 1.0).toString()
    property bool headboardLoading: false

    property bool entranceOn: false
    property bool entranceLoading: false

    property bool livingRoomOn: false
    property bool livingRoomLoading: false

    readonly property bool hasActiveLights: headboardOn || entranceOn || livingRoomOn

    // HomeKit MQTT Actions
    function toggleHeadboard() {
        headboardLoading = true;
        headboardOn = !headboardOn; // Optimistic update
        setCharacteristic(HomeConfig.devices.headboard.id, HomeConfig.devices.headboard.aid, HomeConfig.devices.headboard.powerIid, headboardOn);
    }
    function setHeadboardBrightness(value) {
        headboardBrightness = value; // Optimistic update
        setCharacteristic(HomeConfig.devices.headboard.id, HomeConfig.devices.headboard.aid, HomeConfig.devices.headboard.brightnessIid, value);
    }
    
    function setHeadboardColor(value) {
        const c = Qt.color(value);
        let hue = Math.round(c.hsvHue * 360);
        if (hue < 0) hue = 0;
        
        let saturation = Math.round(c.hsvSaturation * 100);
        
        // Handle achromatic colors (white/grey/black)
        if (c.hsvSaturation === 0) {
            hue = 0;
            saturation = 0;
        }

        // Optimistic update
        headboardHue = hue;
        headboardSaturation = saturation;
        
        // Set both Hue and Saturation sequentially via the publish queue
        setCharacteristic(HomeConfig.devices.headboard.id, HomeConfig.devices.headboard.aid, HomeConfig.devices.headboard.colorIid, hue);
        setCharacteristic(HomeConfig.devices.headboard.id, HomeConfig.devices.headboard.aid, 54, saturation);
    }

    function toggleEntrance() {
        entranceLoading = true;
        entranceOn = !entranceOn; // Optimistic update
        setCharacteristic(HomeConfig.devices.entrance.id, HomeConfig.devices.entrance.aid, HomeConfig.devices.entrance.powerIid, entranceOn);
    }
    function toggleLivingRoom() {
        livingRoomLoading = true;
        livingRoomOn = !livingRoomOn; // Optimistic update
        setCharacteristic(HomeConfig.devices.livingroom.id, HomeConfig.devices.livingroom.aid, HomeConfig.devices.livingroom.powerIid, livingRoomOn);
    }

    function setCharacteristic(deviceId, aid, iid, value) {
        const val = (typeof value === 'boolean') ? (value ? 1 : 0) : value;
        const payload = JSON.stringify({ deviceId, aid, iid, "value": val });
        publish(HomeConfig.commandTopic, payload);
    }

    // MQTT Publish Queue to prevent process collisions
    property var publishQueue: []
    property bool isPublishing: false

    function publish(topic, value) {
        publishQueue.push({ topic: topic, value: value });
        if (!isPublishing) {
            processPublishQueue();
        }
    }

    function processPublishQueue() {
        if (publishQueue.length === 0) {
            isPublishing = false;
            return;
        }

        isPublishing = true;
        const next = publishQueue.shift();
        const clientId = "quickshell-pub-" + Math.random().toString(36).substring(7);
        const cmd = [HomeConfig.mosquittoPub, "-h", HomeConfig.mqttHost, "-i", clientId, "-t", next.topic, "-m", next.value];
        
        pubProc.exec(cmd);
    }

    Process {
        id: pubProc
        onExited: code => {
            // Process next message after the current one finishes
            root.processPublishQueue();
        }
    }

    property var pollQueue: []
    property var currentPoll: null

    // Polling timer for status - reduced frequency to stay light on the bridge
    Timer {
        id: pollTimer
        interval: 30000 // 30 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (pollQueue.length === 0) {
                Object.keys(HomeConfig.devices).forEach(key => {
                    const device = HomeConfig.devices[key];
                    pollQueue.push({ deviceId: device.id, aid: device.aid, iid: device.powerIid });
                    if (device.brightnessIid) pollQueue.push({ deviceId: device.id, aid: device.aid, iid: device.brightnessIid });
                    if (device.colorIid) {
                        pollQueue.push({ deviceId: device.id, aid: device.aid, iid: device.colorIid });
                        pollQueue.push({ deviceId: device.id, aid: device.aid, iid: 54 }); // Saturation
                    }
                });
            }
            processNextPoll();
        }
    }

    function processNextPoll() {
        if (pollQueue.length > 0) {
            currentPoll = pollQueue.shift();
            const payload = JSON.stringify({ deviceId: currentPoll.deviceId, aid: currentPoll.aid, iid: currentPoll.iid });
            publish("felix/homekit/command/get", payload);
        }
    }

    // Monitor HomeKit Responses and Events
    Process {
        id: subProc
        running: true
        // Restore the original working client ID
        command: [HomeConfig.mosquittoSub, "-h", HomeConfig.mqttHost, "-i", "quickshell-home-sub-v2", "-v", "-t", "felix/homekit/response/#", "-t", "felix/homekit/event/#"]
        stdout: SplitParser {
            onRead: line => {
                const spaceIdx = line.indexOf(" ");
                if (spaceIdx === -1) return;
                
                const topic = line.substring(0, spaceIdx);
                const payloadStr = line.substring(spaceIdx + 1);
                
                const topicParts = topic.split("/");
                if (topicParts.length < 4 || topicParts[1] !== "homekit") return;
                
                const type = topicParts[2];
                
                try {
                    const data = JSON.parse(payloadStr);
                    
                    let deviceId, aid, iid, value;

                    if (type === "response" && topicParts[3] === "get") {
                        if (!currentPoll) return;
                        
                        if (data.error) {
                            if (data.error === "Device undefined not paired") {
                                pollQueue = []; 
                            }
                            currentPoll = null;
                            return;
                        }

                        deviceId = currentPoll.deviceId;
                        aid = currentPoll.aid;
                        iid = currentPoll.iid;
                        value = data.value;
                        currentPoll = null;
                        Qt.callLater(processNextPoll);
                    } else if (type === "response" && topicParts[3] === "set") {
                        if (data.success === false || data.error) {
                            if (data.error !== "Device undefined not paired") {
                                console.error("[HOME] Set failed:", data.error);
                            }
                            headboardLoading = false;
                            entranceLoading = false;
                            livingRoomLoading = false;
                            return;
                        }
                        
                        deviceId = data.deviceId;
                    } else if (type === "event") {
                        deviceId = topicParts[3];
                        aid = data.aid || 1;
                        iid = data.iid;
                        value = data.value;
                    } else {
                        return;
                    }

                    if (!deviceId || iid === undefined) return;

                    if (deviceId === HomeConfig.devices.headboard.id) {
                        if (iid === HomeConfig.devices.headboard.powerIid) {
                            headboardOn = (value == 1 || value === true);
                            headboardLoading = false;
                        }
                        else if (iid === HomeConfig.devices.headboard.brightnessIid) headboardBrightness = value;
                        else if (iid === HomeConfig.devices.headboard.colorIid) headboardHue = value;
                        else if (iid === 54) headboardSaturation = value;
                    } else if (deviceId === HomeConfig.devices.entrance.id) {
                        if (iid === HomeConfig.devices.entrance.powerIid) {
                            entranceOn = (value == 1 || value === true);
                            entranceLoading = false;
                        }
                    } else if (deviceId === HomeConfig.devices.livingroom.id) {
                        if (iid === HomeConfig.devices.livingroom.powerIid) {
                            livingRoomOn = (value == 1 || value === true);
                            livingRoomLoading = false;
                        }
                    }
                } catch (e) {
                    // console.error("[HOME] Parse error:", e);
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("[HOME] Service initialized. Broker:", HomeConfig.mqttHost);
    }
}
