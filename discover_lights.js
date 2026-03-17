const dgram = require('dgram');
const socket = dgram.createSocket('udp4');
const discoveryPort = 48899;
const discoveryMsgs = ['HF-A11ASSISTHREAD', 'Discovery: [HF-A11ASSISTHREAD]'];

socket.on('message', (msg, rinfo) => {
    console.log(`Discovered: ${msg.toString()} from ${rinfo.address}`);
});

socket.on('error', (err) => {
    console.error(`Socket error: ${err}`);
});

socket.bind(() => {
    socket.setBroadcast(true);
    console.log('Sending discovery broadcasts...');
    
    // Send to various broadcast addresses
    const targets = ['255.255.255.255', '192.168.0.255', '192.168.1.255'];
    
    discoveryMsgs.forEach(msg => {
        targets.forEach(target => {
            socket.send(msg, discoveryPort, target);
        });
    });

    // Repeat after 1s
    setTimeout(() => {
        discoveryMsgs.forEach(msg => {
            targets.forEach(target => {
                socket.send(msg, discoveryPort, target);
            });
        });
    }, 1000);

    setTimeout(() => {
        console.log('Discovery finished.');
        process.exit(0);
    }, 5000);
});
