var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')
  , net = require('net');

var HOST = '10.1.175.209'
  , PORT = 9000;

app.listen(8008);

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
    server.write(JSON.stringify({
        'cmd': 'join',
        'type': 'spectator'
    }) + '\n');
}

function data(client, str) {
    console.log('Received: ' + str);

    try {
        msg = JSON.parse(str);
        client.emit('frame', msg);
    } catch(e) {}
}

io.sockets.on('connection', function (client) {
    var server = net.connect({port: PORT, host: HOST}).on('connect', function() {
        client.emit('ready', {});
        client.on('join', function() { join(server); });
        server.on('data', function(m) { data(client, m); });
    });
});
