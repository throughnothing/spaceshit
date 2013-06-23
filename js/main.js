;(function() {
    var d = document,
        canvas = d.getElementById('display'),
        socket = io.connect('http://localhost');

    if(!canvas.getContext) {
        // error shit
    }

    var ctx = canvas.getContext('2d');

    // Load BG
    var bg = d.getElementById('bg');
    ctx.drawImage(bg, 0, 0);

    socket.emit('join', {});
    socket.on('frame', function(data) {
        console.log('got frame: ');
        console.log(data);

        if(data.format != 'info' && data.format != 'delete')
            return;

        // display shit, yo
    });
})();
