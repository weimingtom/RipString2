var http = require("http");
var url = require('url');
 
http.createServer(function(request, response) {
    response.writeHead(200, {'Content-Type': 'text/plain'}); 
    response.write('Hello World'); 
    response.end();
    
    var p = url.parse(request.url, true);
    console.log("p.href = " + p.href);
    console.log("p.query = ");
    console.log(p.query);
}).listen(8888);

console.log('\nServer running at http://127.0.0.1:8888/');
