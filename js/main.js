;(function() {
    var d = document,
        canvas = d.getElementById('display'),
        socket = io.connect('http://localhost'),
        objs = {};

    if(!canvas.getContext) {
        // error shit
    }

    // Load context & assets
    var ctx = canvas.getContext('2d');
    var bg = d.getElementById('bg');
    var sprites = d.getElementsByClassName('sprite');

    // Draw screen
    var draw = function() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(bg, 0, 0);
        ctx.drawImage(bg, 0, 600);

        for(var id in objs) {
            var obj = objs[id];
            drawRotated(sprites[obj.type], obj.x, obj.y, obj.r);
        }
    };

    // Draw single object
    var drawRotated = function(image, x, y, angle) {
        ctx.save();

        ctx.translate(x, y);
        ctx.rotate(angle);
        ctx.drawImage(image, -image.width/2, -image.height/2);

        ctx.restore();
    };
 
    // Handle middleware communication
    socket.emit('join', {});
    socket.on('frame', function(pkt) {
        console.log('got frame: ');
        console.log(data);

        switch(pkt.cmd) {
            case 'info':
                objs[data.id] = data;
            break;

            case 'delete':
                delete objs[data.id];
            break;
        }
    });
    
    // requestAnimationFrame shim
    window.requestAnimFrame = (function() {
        return window.requestAnimationFrame       ||
               window.webkitRequestAnimationFrame ||
               window.mozRequestAnimationFrame    ||
               function(callback) {
                   window.setTimeout(callback, 1000 / 60);
               };
    })();

    // Try to draw at proper times
    var renderLoop = function() {
        requestAnimFrame(renderLoop);
        draw();
    };
    renderLoop();
})();
