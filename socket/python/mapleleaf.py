#!c:/python26/python.exe
# -*- coding: utf-8 -*-
#!/usr/bin/env python

#
# fiel:mapple.py
#
# Overview:
# Usage: 
# About:
#

from __future__ import with_statement

import threading
import socket
import sys
import time

VERSION = 0.1

class ListenThread(threading.Thread):
    def __init__(self, server):
        threading.Thread.__init__(self)
        self.server = server
    def run(self):
        while 1:
            try:
                client, addr = self.server.accept()
                data = client.recv(1024)
                client.send('I GOT: %s\n' % data)
                # client.close()
            except:
                print "ListenThread error!"
                break

class ServerThread(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.event = threading.Event()
        self.running = 1
    def run(self):
        try:
            self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server.bind(('127.0.0.1', 1051))
            self.server.listen(1)
            self.lt = ListenThread(self.server)
            self.lt.setDaemon(True)
            self.lt.start()
            self.server.close()
        except socket.error, e:
            print "Socket Error: %s" % e
            self.running = 0
    def stop(self):
        self.event.set()

def main():
    ctrl = ServerThread()
    ctrl.setDaemon(True)
    ctrl.start()
    while(ctrl.running):
        time.sleep(0.1)

if __name__ == '__main__':
    main()
