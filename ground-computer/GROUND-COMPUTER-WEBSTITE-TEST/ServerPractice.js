// following thenewboston youtube channel
var http = require('http');

function OnRequest(request, response){
    console.log("A user made a request" + request.url);
    response.writeHead(200,{"Context-Type": "text/plain"});
    response.write("Here is some data");
    response.end();
}

http.createServer(OnRequest).listen(8888);
console.log('Server is now running...');