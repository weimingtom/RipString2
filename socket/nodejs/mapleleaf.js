//see 
//http://www.iunbug.com/article.html?objNews.id=276003
//http://nodejs.org/
//http://socket.io/

var net = require('net');

var server = net.createServer(function (socket) {
	console.log('New connection');
	socket.write("Echo server\r\n");
	socket.pipe(socket);
});
server.listen(1337, "127.0.0.1");
console.log('Begin listening on 1337');
