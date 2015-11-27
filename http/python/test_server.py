#!/bin/python

# http://blog.csdn.net/linda1000/article/details/8087546

from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler

class TestHTTPHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        buf = 'It works'
        self.protocal_version = 'HTTP/1.1' 
        self.send_response(200)
        self.send_header('Welcome', 'Contect')       
        self.end_headers()
        self.wfile.write(buf)

def start_server(port):
    http_server = HTTPServer(('127.0.0.1', int(port)), TestHTTPHandler)
    http_server.serve_forever()

def stop_server(server):
    server.sorket.close()    
    
if __name__ == '__main__':
    start_server(8888)

