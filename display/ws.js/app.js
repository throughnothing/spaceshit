var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')
  , net = require('net');

var HOST = 'localhost'
  , PORT = 8008;

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
    server.write(JSON.stringify({
        'cmd': 'join',
        'type': 'spectator'
    });
}

function data(client, str) {
    var msg = JSON.parse(str);

    if(msg)
        client.emit('frame', msg);
}

io.sockets.on('connection', function (client) {
    var server = new net.socket({type: 'tcp4'});

    server.connect(PORT, HOST).on('connect', function() {
        client.on('join', function() { join(server); });
        server.on('data', function(m) { data(client, m); });
    });
});
