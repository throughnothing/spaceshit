var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')
  , net = require('net');

var HOST = 'localhost'
  , PORT = 8008;

// Packet IDs
var PKT_JOIN  = 0,
    PKT_INFO  = 5,
    PKT_STALL = 253;

app.listen(80);

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }

    res.writeHead(200);
    res.end(data);
  });
}

function join(server) {
    var pkt = new Buffer(2);

    pkt[0] = PKT_JOIN;
    pkt[1] = 1; // observer
    
    server.write(pkt);
}

function data(client, msg) {
    var type = 'unknown';

    switch(msg[0]) {
        case PKT_STALL:
            client.emit('frame', {format: 'stall'});
        break;

        case PKT_INFO:
            client.emit('frame', {
                format: 'info',
                type:   msg[1],
                id:     msg[2],
                x:      msg.readFloatLE(3),
                y:      msg.readFloatLE(7),
                r:      msg.readFloatLE(11)
            });
        break;

        default:
            client.emit('frame', {format: 'unknown'});
        break;
    }
}

io.sockets.on('connection', function (client) {
    var server = new net.socket({type: 'tcp4'});

    server.connect(PORT, HOST).on('connect', function() {
        client.on('join', function() { join(server); });
        server.on('data', function(m) { data(client, m); });
    });
});
