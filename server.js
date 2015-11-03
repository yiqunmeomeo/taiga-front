// npm install ws
// npm install crypto

function generateIds() {
    messages = messages.map(function(item) {
        var hash = crypto.createHash('md5').update(item.message).digest('hex');

        item.id = hash;

        return item;
    });
}

var crypto = require('crypto');
var messages = [];
var WebSocketServer = require('ws').Server;
var wss = new WebSocketServer({
        "port": 8888
});

wss.on('connection', function connection(ws) {
    // INITIAL MESSAGES
    messages = [
        {message: 'test1'},
        {message: 'test2'},
        {message: 'test3'}
    ];

    generateIds();

    ws.send(JSON.stringify(messages));

    // NEW MESSAGE AFTER 3000ms
    setTimeout(function() {
        messages.push({message: 'test4'});

        generateIds();

        // SEND ONLY THE LAST ONE
        ws.send(JSON.stringify([messages[messages.length - 1]]));
    }, 3000);
});
