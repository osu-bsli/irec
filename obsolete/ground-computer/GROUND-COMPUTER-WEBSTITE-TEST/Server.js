// To run use "node server.js"
var http = require('http');
var fs = require('fs');
var WebSocket = require('ws');

var server = http.createServer(function(req, res){
    if(req.url === '/'){
        fs.createReadStream('index.html').pipe(res);
    }
});

var wss = new WebSocket.Server({ server });

wss.on('connection', function(ws){
    console.log("Client connected");

    // Simulated telemetry (replace with real data)
    setInterval(function(){
        var data = {
            altitude: Math.random() * 100,
            temperature: 20 + Math.random() * 5,
            time: Date.now()
        };

        ws.send(JSON.stringify(data));
    }, 1000);
});

server.listen(8888);
console.log("Server running on http://localhost:8888");