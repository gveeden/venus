const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://192.168.0.75');

client.on('connect', () => {
    console.log('Connected to MQTT');
    client.subscribe('felix/homekit/response/list');
    client.publish('felix/homekit/command/list', '{}');
});

client.on('message', (topic, message) => {
    console.log(`Topic: ${topic}`);
    console.log(`Payload: ${message.toString()}`);
    client.end();
});

setTimeout(() => {
    console.log('Timeout waiting for response');
    client.end();
}, 5000);
